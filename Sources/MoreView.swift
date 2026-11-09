import SwiftUI
import UIKit

struct MoreView: View {
    @EnvironmentObject var store: Store
    @State private var confirmReset = false
    @State private var importMessage: String?
    @State private var browserPage: BrowserPage?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Server", selection: $store.data.server) {
                        ForEach(GameServer.allCases) { s in Text(s.name).tag(s) }
                    }
                } header: {
                    Text("Game server")
                } footer: {
                    Text("Used for the 4:00 daily reset and which domains are open today.")
                }

                Section {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5), spacing: 12) {
                        ForEach(Theme.accents, id: \.id) { option in
                            Button {
                                store.data.accent = option.id
                            } label: {
                                ZStack {
                                    Circle().fill(option.color).frame(width: 40, height: 40)
                                    if store.data.accent == option.id {
                                        Image(systemName: "checkmark")
                                            .font(.headline.weight(.bold))
                                            .foregroundColor(.white)
                                    }
                                }
                                .overlay(Circle().stroke(Color.primary.opacity(store.data.accent == option.id ? 0.6 : 0), lineWidth: 2).padding(-3))
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(option.name)
                        }
                    }
                    .padding(.vertical, 6)
                    Picker("Appearance", selection: $store.data.appearance) {
                        ForEach(Theme.appearances, id: \.id) { a in Text(a.name).tag(a.id) }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Theme colour")
                } footer: {
                    Text("Currently: \(Theme.accents.first(where: { $0.id == store.data.accent })?.name ?? "Primogem Gold"). Changes buttons, toggles, progress bars and tab icons.")
                }

                DomainRemindersSection()

                Section("Tools") {
                    NavigationLink { WishView() } label: { Label("Wish savings & pity", systemImage: "sparkles") }
                    NavigationLink { PrimoPredictorView() } label: { Label("Primogem income predictor", systemImage: "chart.line.uptrend.xyaxis") }
                    NavigationLink { FarmingPlannerView() } label: { Label("Farming plan", systemImage: "calendar.badge.clock") }
                    NavigationLink { CodesView() } label: { Label("Redemption codes", systemImage: "gift.fill") }
                    Button {
                        browserPage = BrowserPage(url: ExternalPages.yshelperAbyss)
                    } label: {
                        Label("Abyss usage stats (YSHelper)", systemImage: "chart.bar.xaxis")
                    }
                    HStack {
                        Label("Game UID", systemImage: "person.text.rectangle")
                        Spacer()
                        TextField("e.g. 612345678", text: $store.data.uid)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .font(.body.monospacedDigit())
                            .frame(width: 140)
                    }
                    Button {
                        if let url = ExternalPages.akasha(uid: store.data.uid) { browserPage = BrowserPage(url: url) }
                    } label: {
                        Label("My Akasha.cv profile", systemImage: "person.crop.circle.badge.checkmark")
                    }
                    .disabled(ExternalPages.akasha(uid: store.data.uid) == nil)
                    NavigationLink { TaskManagerView() } label: { Label("Edit checklist tasks", systemImage: "list.bullet") }
                    NavigationLink { CustomBooksView() } label: { Label("Custom talent books", systemImage: "book.closed") }
                }

                Section {
                    ShareLink(item: store.exportJSON(), preview: SharePreview("Genshin Tracker backup")) {
                        Label("Share backup (JSON)", systemImage: "square.and.arrow.up")
                    }
                    Button {
                        UIPasteboard.general.string = store.exportJSON()
                        importMessage = "Backup copied to clipboard."
                    } label: {
                        Label("Copy backup to clipboard", systemImage: "doc.on.doc")
                    }
                    Button {
                        if let text = UIPasteboard.general.string, store.importJSON(text) {
                            importMessage = "Backup restored."
                        } else {
                            importMessage = "Clipboard doesn't contain a valid backup."
                        }
                    } label: {
                        Label("Restore from clipboard", systemImage: "doc.on.clipboard")
                    }
                    if let msg = importMessage {
                        Text(msg).font(.footnote).foregroundColor(.secondary)
                    }
                } header: {
                    Text("Backup")
                } footer: {
                    Text("Re-signing or reinstalling a sideloaded app can wipe its data. Copy a backup somewhere safe (e.g. Notes) before you re-sign.")
                }

                Section {
                    Button("Re-download character icons") {
                        Task { await ImageStore.shared.clearDiskCache() }
                    }
                    Button("Reset all data", role: .destructive) { confirmReset = true }
                } footer: {
                    Text("Character icons are loaded from Enka.Network the first time you see them, then saved on your phone.")
                }

                UpdatesSection()

                GameDataSection()

                WidgetStatusSection()

                Section("About") {
                    Text("Unofficial fan-made tracker. Not affiliated with HoYoverse, Enka.Network or KQM. Character data from Enka.Network; guide links go to keqingmains.com. Talent books can be changed on each character's page.")
                        .font(.footnote).foregroundColor(.secondary)
                }
            }
            .navigationTitle("More")
            .inAppBrowser($browserPage, tint: Theme.accent(store.data.accent))
            .keyboardDoneButton()
            .confirmationDialog("Erase everything and start over?", isPresented: $confirmReset, titleVisibility: .visible) {
                Button("Reset all data", role: .destructive) { store.resetAll() }
            }
        }
    }
}

// MARK: - Wish

struct WishView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        let w = store.data.wish
        Form {
            Section("Savings") {
                IntField(title: "Primogems", value: $store.data.wish.primogems)
                IntField(title: "Intertwined Fates", value: $store.data.wish.fates)
                IntField(title: "Masterless Starglitter", value: $store.data.wish.starglitter)
            }
            Section("Pity (character banner)") {
                Stepper("Current pity: \(w.pity)", value: $store.data.wish.pity, in: 0...89)
                Toggle("Next 5★ is guaranteed", isOn: $store.data.wish.guaranteed)
            }
            Section("Summary") {
                HStack {
                    Text("Total pulls available")
                    Spacer()
                    Text("\(w.totalPulls)").font(.title3.weight(.bold).monospacedDigit())
                }
                HStack {
                    Text("Pulls to hard pity")
                    Spacer()
                    Text("\(w.pullsToHardPity)").monospacedDigit()
                }
                let worst = w.guaranteed ? w.pullsToHardPity : w.pullsToHardPity + 90
                HStack {
                    Text("Worst case for the featured 5★")
                    Spacer()
                    Text("\(worst)").monospacedDigit()
                }
                if w.totalPulls >= worst {
                    Label("You're guaranteed the featured character!", systemImage: "checkmark.seal.fill")
                        .foregroundColor(.green)
                } else {
                    Text("\(worst - w.totalPulls) more pulls (\((worst - w.totalPulls) * 160) primos) for a full guarantee.")
                        .font(.footnote).foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Wishes")
        .keyboardDoneButton()
    }
}

// MARK: - Task manager

struct TaskManagerView: View {
    @EnvironmentObject var store: Store
    @State private var title = ""
    @State private var frequency: TaskFrequency = .daily

    var body: some View {
        List {
            ForEach(TaskFrequency.allCases) { freq in
                let items = store.data.tasks.filter { $0.frequency == freq }
                Section(freq.label) {
                    ForEach(items) { task in
                        HStack {
                            TextField("Task", text: store.taskBinding(task.id).title)
                            Menu {
                                ForEach(TaskFrequency.allCases) { f in
                                    Button(f.label) { store.setTaskFrequency(task.id, f) }
                                }
                            } label: {
                                Image(systemName: "arrow.triangle.2.circlepath")
                            }
                        }
                    }
                    .onDelete { offsets in
                        let ids = offsets.map { items[$0].id }
                        store.data.tasks.removeAll { ids.contains($0.id) }
                    }
                }
            }
            Section("New task") {
                TextField("Title", text: $title)
                Picker("Repeats", selection: $frequency) {
                    ForEach(TaskFrequency.allCases) { f in Text(f.label).tag(f) }
                }
                Button("Add") {
                    store.data.tasks.append(TaskItem(title: title, frequency: frequency))
                    title = ""
                }
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            Section {
                Button("Restore default tasks") {
                    let existing = Set(store.data.tasks.map { $0.title })
                    for t in AppData.defaultTasks where !existing.contains(t.title) {
                        store.data.tasks.append(t)
                    }
                }
            }
        }
        .navigationTitle("Checklist tasks")
    }
}

// MARK: - Custom books

struct CustomBooksView: View {
    @EnvironmentObject var store: Store
    @State private var name = ""
    @State private var region = "Snezhnaya"
    @State private var domain = ""
    @State private var group: DayGroup = .monThu

    var body: some View {
        Form {
            Section {
                if store.data.customBooks.isEmpty {
                    Text("No custom books yet.").foregroundColor(.secondary)
                }
                ForEach(store.data.customBooks) { b in
                    VStack(alignment: .leading) {
                        Text(b.name).font(.subheadline.weight(.semibold))
                        Text("\(b.region) · \(b.domain) · \(b.group.short)").font(.caption).foregroundColor(.secondary)
                    }
                }
                .onDelete { store.data.customBooks.remove(atOffsets: $0) }
            } header: {
                Text("Your books")
            } footer: {
                Text("Add talent books from new regions so they appear in Today and Domains, then assign them to characters in Roster.")
            }

            Section("Add a book") {
                TextField("Book name (e.g. 'Freedom', without 'Teachings of')", text: $name)
                Picker("Region", selection: $region) {
                    ForEach(GameData.regions, id: \.self) { Text($0).tag($0) }
                }
                TextField("Domain name", text: $domain)
                Picker("Days", selection: $group) {
                    ForEach(DayGroup.allCases) { g in Text(g.label).tag(g) }
                }
                Button("Add book") {
                    let n = name.trimmingCharacters(in: .whitespaces)
                    store.data.customBooks.append(TalentBook(
                        id: "custom:" + UUID().uuidString,
                        name: n, region: region,
                        group: group,
                        domain: domain.isEmpty ? "Domain of Mastery" : domain,
                        isCustom: true))
                    name = ""
                    domain = ""
                }
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .navigationTitle("Custom books")
    }
}
