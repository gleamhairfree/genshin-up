import SwiftUI
import UserNotifications

// MARK: - Scheduling

private var reminderWorkItem: DispatchWorkItem?

extension Store {
    /// Characters the reminders can cover: anything with a plan or materials, or marked as building.
    var trackedCharacters: [CharacterEntry] {
        let groups = Set(data.goals.map { $0.group })
        return data.characters
            .filter { groups.contains($0.name) || data.plans[$0.name] != nil || $0.building }
            .sorted { $0.name < $1.name }
    }

    /// Characters the reminders actually include right now.
    var reminderCharacters: [CharacterEntry] {
        if data.reminderMode == "selected" {
            let ids = Set(data.reminderCharacterIDs)
            return data.characters.filter { ids.contains($0.id) }.sorted { $0.name < $1.name }
        }
        return trackedCharacters
    }

    /// Characters still needing talent books (plan not finished, or talents below 10).
    func needsBooks(_ c: CharacterEntry) -> Bool {
        // If the Materials tab tracks this character's talent books, they only count while
        // at least one book item is still short – regardless of the notification toggle.
        if let b = book(c.bookID) {
            let bookGoals = data.goals.filter { $0.group == c.name && b.tiers.contains($0.name) }
            if !bookGoals.isEmpty { return bookGoals.contains { !$0.isDone } }
        }
        if let p = data.plans[c.name] {
            return p.talentsToMax > 0 && p.targetTalentLevel > p.startTalentLevel
        }
        return c.needsTalents
    }

    /// Body text for a given game day, or nil if nothing to farm.
    func reminderText(for day: GameDay) -> (title: String, body: String)? {
        let chars = reminderCharacters.filter { book($0.bookID) != nil && needsBooks($0) }
        guard !chars.isEmpty else { return nil }
        var lines: [String] = []
        for b in orderedBooks() where day.includes(b.group) {
            let users = chars.filter { $0.bookID == b.id }
            if !users.isEmpty {
                lines.append("\(b.name): \(users.map { $0.name }.joined(separator: ", "))")
            }
        }
        guard !lines.isEmpty else { return nil }
        let title = day == .sunday
            ? "Sunday – every talent domain is open"
            : "\(day.name)'s talent domains are open"
        return (title, lines.joined(separator: "\n"))
    }

    /// Debounced so rapid edits don't reschedule on every keystroke.
    func scheduleReminderRefresh() {
        reminderWorkItem?.cancel()
        let item = DispatchWorkItem { [weak self] in
            self?.rescheduleDomainReminders()
            self?.updateWidget()
        }
        reminderWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: item)
    }

    static let reminderIDs = GameDay.allCases.map { "domain-reminder-\($0.rawValue)" }

    /// One weekly-repeating notification per weekday at 4:00 server time, with that day's list baked in.
    /// Repeats keep firing even if the app isn't opened; contents refresh whenever the app runs.
    func rescheduleDomainReminders() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: Store.reminderIDs)
        guard data.domainReminders else { return }

        let offset = data.server.utcOffsetHours
        guard let tz = TimeZone(secondsFromGMT: offset * 3600) else { return }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = tz

        for day in GameDay.allCases {
            guard let text = reminderText(for: day) else { continue }
            let content = UNMutableNotificationContent()
            content.title = text.title
            content.body = text.body
            content.sound = .default
            content.threadIdentifier = "domain-reminders"

            var comps = DateComponents()
            comps.calendar = calendar
            comps.timeZone = tz
            comps.weekday = day.rawValue
            comps.hour = 4
            comps.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
            center.add(UNNotificationRequest(identifier: "domain-reminder-\(day.rawValue)", content: content, trigger: trigger))
        }
    }

    func requestNotificationPermission(_ completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    func sendTestReminder() {
        let today = ResetClock.gameDay(server: data.server)
        let text = reminderText(for: today)
            ?? (title: "No domains needed today", body: "None of your reminder characters use today's talent books.")
        let content = UNMutableNotificationContent()
        content.title = text.title
        content.body = text.body
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: "domain-reminder-test", content: content, trigger: trigger))
    }
}

/// Lets notifications show as banners even while the app is open.
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .list])
    }
}

// MARK: - Settings UI

struct DomainRemindersSection: View {
    @EnvironmentObject var store: Store
    @State private var denied = false
    @State private var testSent = false

    private var localResetTime: String {
        let offset = store.data.server.utcOffsetHours
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: offset * 3600)!
        let now = Date()
        var comps = cal.dateComponents([.year, .month, .day], from: now)
        comps.hour = 4
        guard let date = cal.date(from: comps) else { return "" }
        let f = DateFormatter()
        f.timeStyle = .short
        f.dateStyle = .none
        return f.string(from: date)
    }

    var body: some View {
        Section {
            Toggle(isOn: Binding(
                get: { store.data.domainReminders },
                set: { on in
                    if on {
                        store.requestNotificationPermission { granted in
                            denied = !granted
                            store.data.domainReminders = granted
                        }
                    } else {
                        store.data.domainReminders = false
                    }
                }
            )) {
                Label("Talent domain reminders", systemImage: "bell.badge.fill")
            }

            if denied {
                Text("Notifications are turned off for this app. Enable them in iOS Settings → Notifications → Teyvat Tracker.")
                    .font(.footnote).foregroundColor(.red)
            }

            if store.data.domainReminders {
                Picker("Remind me for", selection: $store.data.reminderMode) {
                    Text("All tracked").tag("all")
                    Text("Choose…").tag("selected")
                }
                .pickerStyle(.segmented)

                NavigationLink {
                    ReminderCharacterPicker()
                } label: {
                    HStack {
                        Text(store.data.reminderMode == "all" ? "Included characters" : "Choose characters")
                        Spacer()
                        Text("\(store.reminderCharacters.count)")
                            .foregroundColor(.secondary)
                    }
                }

                Button(testSent ? "Test sent – check in 5 seconds" : "Send a test for today") {
                    store.sendTestReminder()
                    testSent = true
                }
            }
        } header: {
            Text("Notifications")
        } footer: {
            Text("Sent at the daily reset, 4:00 AM \(store.data.server.name) (\(localResetTime) your time), listing which of your characters can farm talent books that day. Days with nothing to farm are skipped. \"All tracked\" means characters with a plan, materials, or marked as building. Characters whose talent books are all collected on the Materials tab are left out.")
        }
    }
}

struct ReminderCharacterPicker: View {
    @EnvironmentObject var store: Store
    @State private var showAllOwned = false

    private var candidates: [CharacterEntry] {
        if store.data.reminderMode == "all" { return store.trackedCharacters }
        let tracked = store.trackedCharacters
        if showAllOwned {
            let ids = Set(tracked.map { $0.id })
            let extra = store.data.characters.filter { ($0.owned || store.data.reminderCharacterIDs.contains($0.id)) && !ids.contains($0.id) }
            return (tracked + extra).sorted { $0.name < $1.name }
        }
        let selectedExtra = store.data.characters.filter {
            store.data.reminderCharacterIDs.contains($0.id) && !tracked.contains($0)
        }
        return (tracked + selectedExtra).sorted { $0.name < $1.name }
    }

    var body: some View {
        List {
            if store.data.reminderMode == "selected" {
                Section {
                    Toggle("Show all owned characters", isOn: $showAllOwned)
                    HStack {
                        Button("Select all") {
                            store.data.reminderCharacterIDs = candidates.map { $0.id }
                        }
                        .buttonStyle(.borderless)
                        Spacer()
                        Button("Clear") { store.data.reminderCharacterIDs = [] }
                            .buttonStyle(.borderless)
                    }
                }
            }
            Section {
                if candidates.isEmpty {
                    Text("No tracked characters yet. Plan a character on the Materials tab, or mark one as building in Roster.")
                        .font(.footnote).foregroundColor(.secondary)
                }
                ForEach(candidates) { c in
                    let selected = store.data.reminderMode == "all" || store.data.reminderCharacterIDs.contains(c.id)
                    Button {
                        guard store.data.reminderMode == "selected" else { return }
                        if let i = store.data.reminderCharacterIDs.firstIndex(of: c.id) {
                            store.data.reminderCharacterIDs.remove(at: i)
                        } else {
                            store.data.reminderCharacterIDs.append(c.id)
                        }
                    } label: {
                        HStack(spacing: 12) {
                            CharacterIcon(character: c, size: 36)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(c.name).foregroundColor(.primary)
                                if let b = store.book(c.bookID) {
                                    Text("\(b.name) · \(b.group.short)").font(.caption).foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            if store.data.reminderMode == "selected" {
                                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selected ? .accentColor : .secondary)
                                    .font(.title3)
                            }
                        }
                    }
                }
            } footer: {
                if store.data.reminderMode == "all" {
                    Text("Switch to \"Choose…\" to pick specific characters.")
                }
            }
        }
        .navigationTitle("Reminder characters")
        .navigationBarTitleDisplayMode(.inline)
    }
}
