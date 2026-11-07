import SwiftUI

struct TodayView: View {
    @EnvironmentObject var store: Store
    @State private var showResinEditor = false
    @State private var newTaskTitle = ""
    @State private var newTaskFrequency: TaskFrequency = .daily

    var body: some View {
        NavigationStack {
            TimelineView(.periodic(from: Date(), by: 30)) { context in
                content(now: context.date)
            }
            .navigationTitle("Today")
            .sheet(isPresented: $showResinEditor) { ResinEditor() }
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
            }

            resinSection(now: now)

            farmSection(day: day)

            taskSection(.daily)
            taskSection(.weekly)
            taskSection(.once)

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

    // MARK: Resin

    @ViewBuilder
    private func resinSection(now: Date) -> some View {
        let resin = store.data.resin
        let current = resin.current(at: now)
        Section("Original Resin") {
            Button {
                showResinEditor = true
            } label: {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "moon.fill").foregroundColor(.cyan)
                        Text("\(current) / \(resin.cap)")
                            .font(.title3.monospacedDigit().weight(.bold))
                            .foregroundColor(.primary)
                        Spacer()
                        if let full = resin.fullDate(), full > now {
                            Text("Full in \(formatDuration(full.timeIntervalSince(now)))")
                                .font(.caption).foregroundColor(.secondary)
                        } else {
                            Text("FULL").font(.caption.weight(.bold)).foregroundColor(.red)
                        }
                    }
                    ProgressView(value: Double(current), total: Double(resin.cap))
                    Text("Tap to update").font(.caption2).foregroundColor(.secondary)
                }
            }
        }
    }

    // MARK: Farming

    @ViewBuilder
    private func farmSection(day: GameDay) -> some View {
        let books = store.allBooks.filter { day.includes($0.group) }
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
                            Image(systemName: "book.fill").foregroundColor(.orange)
                            Text(pair.book.name).font(.subheadline.weight(.semibold))
                            Text("· \(pair.book.domain)").font(.caption).foregroundColor(.secondary)
                        }
                        Text(pair.characters.map { c in c.building ? "⭐️ \(c.name)" : c.name }.joined(separator: ", "))
                            .font(.caption)
                    }
                }
            }
            NavigationLink("See all of today's domains") { DomainDayList(day: day) }
        } header: {
            Text("Farm today")
        } footer: {
            Text("⭐️ = marked as currently building.")
        }
    }

    // MARK: Tasks

    @ViewBuilder
    private func taskSection(_ freq: TaskFrequency) -> some View {
        let items = store.data.tasks.filter { $0.frequency == freq }
        if !items.isEmpty {
            Section {
                ProgressRow(title: freq.label, done: items.filter { $0.done }.count, total: items.count)
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

// MARK: - Resin editor

struct ResinEditor: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var value: Int = 0
    @State private var notify = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Current resin in game") {
                    Stepper(value: $value, in: 0...store.data.resin.cap) {
                        Text("\(value)").font(.title2.monospacedDigit().weight(.bold))
                    }
                    HStack {
                        ForEach([0, 20, 40, 60, 160], id: \.self) { v in
                            Button("\(v)") { value = v }
                                .buttonStyle(.bordered)
                        }
                    }
                }
                Section {
                    Toggle("Notify me when full", isOn: $notify)
                } footer: {
                    Text("Resin regenerates 1 per 8 minutes, up to 200.")
                }
            }
            .navigationTitle("Update Resin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.data.resin.value = value
                        store.data.resin.recordedAt = Date()
                        store.data.resin.notify = notify
                        store.scheduleResinNotification()
                        dismiss()
                    }
                }
            }
            .onAppear {
                value = store.data.resin.current()
                notify = store.data.resin.notify
            }
        }
        .presentationDetents([.medium])
    }
}
