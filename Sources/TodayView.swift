import SwiftUI

struct TodayView: View {
    @EnvironmentObject var store: Store
    @State private var newTaskTitle = ""
    @State private var newTaskFrequency: TaskFrequency = .daily
    @State private var editMode: EditMode = .inactive

    var body: some View {
        NavigationStack {
            TimelineView(.periodic(from: Date(), by: 30)) { context in
                content(now: context.date)
            }
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(editMode.isEditing ? "Done" : "Reorder") {
                        withAnimation { editMode = editMode.isEditing ? .inactive : .active }
                    }
                }
            }
            .environment(\.editMode, $editMode)
        }
        .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { _ in
            store.refreshResets()
        }
    }

    @ViewBuilder
    private func content(now: Date) -> some View {
        let server = store.data.server
        let day = ResetClock.gameDay(now, server: server)

        List {
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Server day: \(day.name)").font(.headline)
                        Text(server.name).font(.caption).foregroundColor(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Reset in").font(.caption).foregroundColor(.secondary)
                        Text(formatDuration(ResetClock.secondsToNextReset(now, server: server)))
                            .font(.subheadline.monospacedDigit().weight(.semibold))
                    }
                }
                if editMode.isEditing {
                    Label("Drag the ≡ handles to reorder domains and tasks.", systemImage: "arrow.up.arrow.down")
                        .font(.footnote).foregroundColor(.secondary)
                }
            }

            wishSection()

            farmSection(day: day)

            weaponSection(day: day)

            taskSection(.daily)
            taskSection(.weekly)
            taskSection(.once)

            if !editMode.isEditing {
                Section("Add a task") {
                    TextField("e.g. Buy Stardust shop items", text: $newTaskTitle)
                    Picker("Repeats", selection: $newTaskFrequency) {
                        ForEach(TaskFrequency.allCases) { f in Text(f.label).tag(f) }
                    }
                    Button("Add task") {
                        let t = newTaskTitle.trimmingCharacters(in: .whitespaces)
                        guard !t.isEmpty else { return }
                        store.data.tasks.append(TaskItem(title: t, frequency: newTaskFrequency))
                        newTaskTitle = ""
                    }
                    .disabled(newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    // MARK: Wish savings (compact)

    @ViewBuilder
    private func wishSection() -> some View {
        let w = store.data.wish
        let worst = w.guaranteed ? w.pullsToHardPity : w.pullsToHardPity + 90
        Section("Wish savings") {
            NavigationLink {
                WishView()
            } label: {
                HStack(spacing: 0) {
                    wishStat(value: "\(w.totalPulls)", label: "pulls", icon: "sparkles", color: .yellow)
                    Divider().frame(height: 30)
                    wishStat(value: "\(w.pity)", label: "pity", icon: "gauge.medium", color: .purple)
                    Divider().frame(height: 30)
                    if w.totalPulls >= worst {
                        wishStat(value: "Yes", label: "guaranteed", icon: "checkmark.seal.fill", color: .green)
                    } else {
                        wishStat(value: "\(worst - w.totalPulls)", label: "to guarantee", icon: "target", color: .orange)
                    }
                }
            }
        }
    }

    private func wishStat(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.caption).foregroundColor(color)
                Text(value).font(.headline.monospacedDigit())
            }
            Text(label).font(.caption2).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Farming

    @ViewBuilder
    private func farmSection(day: GameDay) -> some View {
        let books = store.orderedBooks().filter { day.includes($0.group) }
        let relevant = books.compactMap { book -> BookUsage? in
            let chars = store.characters(using: book).filter { $0.owned && ($0.building || $0.needsTalents) }
            return chars.isEmpty ? nil : BookUsage(book: book, characters: chars)
        }
        Section {
            if day == .sunday {
                Text("Sunday: every talent book and weapon material is available.")
                    .font(.subheadline)
            }
            if relevant.isEmpty {
                Text("None of your owned characters need talent books from today's domains. Mark characters as owned in Roster to see suggestions.")
                    .font(.footnote).foregroundColor(.secondary)
            } else {
                ForEach(relevant) { pair in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            ItemIcon(name: pair.book.tiers[2], size: 28)
                            Text(pair.book.name).font(.subheadline.weight(.semibold))
                            Text("· \(pair.book.domain)").font(.caption).foregroundColor(.secondary)
                        }
                        if !editMode.isEditing {
                            characterStrip(pair.characters)
                        }
                    }
                }
                .onMove { from, to in
                    store.moveBooks(visible: relevant.map { $0.book.id }, from: from, to: to)
                }
            }
            if !editMode.isEditing {
                NavigationLink("See all of today's domains") { DomainDayList(day: day) }
            }
        } header: {
            Text("Farm today")
        } footer: {
            Text("★ = marked as currently building.")
        }
    }

    @ViewBuilder
    private func weaponSection(day: GameDay) -> some View {
        // Planned weapons whose domain is open today and still need domain materials.
        let planned = store.data.weapons.filter { w in
            guard w.plan != nil, let info = w.info, let g = info.domainGroup, day.includes(g) else { return false }
            let names = Set(info.phases.flatMap { $0.prefix(1).map { $0.name } })
            let goals = store.data.goals.filter { $0.group == w.groupName && names.contains($0.name) }
            return goals.isEmpty || goals.contains { !$0.isDone }
        }
        if !planned.isEmpty && !editMode.isEditing {
            Section("Weapon materials today") {
                ForEach(planned) { w in
                    HStack(spacing: 10) {
                        WeaponIcon(weaponID: w.weaponID, rarity: w.info?.rarity ?? 4, size: 36)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(w.name).font(.subheadline.weight(.semibold))
                            if let item = w.info?.domainItem {
                                Text(item).font(.caption).foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        if let item = w.info?.domainItem {
                            ItemIcon(name: item, size: 28)
                        }
                    }
                }
            }
        }
    }

    private func characterStrip(_ characters: [CharacterEntry]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(characters) { c in
                    VStack(spacing: 2) {
                        CharacterIcon(character: c, size: 40)
                            .overlay(alignment: .topTrailing) {
                                if c.building {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(.yellow)
                                        .padding(2)
                                        .background(Circle().fill(Color.black.opacity(0.6)))
                                }
                            }
                        Text(c.name.split(separator: " ").last.map(String.init) ?? c.name)
                            .font(.system(size: 10))
                            .lineLimit(1)
                            .frame(width: 52)
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }

    // MARK: Tasks

    @ViewBuilder
    private func taskSection(_ freq: TaskFrequency) -> some View {
        let items = store.data.tasks.filter { $0.frequency == freq }
        if !items.isEmpty {
            Section {
                ProgressRow(title: freq.label, done: items.filter { $0.done }.count, total: items.count)
                    .moveDisabled(true)
                ForEach(items) { task in
                    Button {
                        store.toggleTask(task.id)
                    } label: {
                        HStack {
                            Image(systemName: task.done ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(task.done ? .green : .secondary)
                                .font(.title3)
                            Text(task.title)
                                .foregroundColor(task.done ? .secondary : .primary)
                                .strikethrough(task.done)
                        }
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            store.data.tasks.removeAll { $0.id == task.id }
                        } label: { Label("Delete", systemImage: "trash") }
                    }
                }
                .onMove { from, to in
                    store.moveTasks(frequency: freq, from: from, to: to)
                }
            } footer: {
                switch freq {
                case .daily: Text("Resets automatically at 4:00 server time.")
                case .weekly: Text("Resets Monday at 4:00 server time.")
                case .once: Text("Never resets. Swipe left to delete.")
                }
            }
        }
    }
}

struct BookUsage: Identifiable {
    let book: TalentBook
    let characters: [CharacterEntry]
    var id: String { book.id }
}
