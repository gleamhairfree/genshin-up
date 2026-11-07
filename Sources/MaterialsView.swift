import SwiftUI

struct MaterialsView: View {
    @EnvironmentObject var store: Store
    @State private var showCompleted = true
    @State private var showAdd = false
    @State private var editing: MaterialGoal?

    private var groups: [String] {
        var seen: [String] = []
        for g in store.data.goals where !seen.contains(g.group) { seen.append(g.group) }
        return seen
    }

    var body: some View {
        NavigationStack {
            List {
                if store.data.goals.isEmpty {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("No materials tracked yet").font(.headline)
                            Text("Tap + to add an item with how many you have and how many you need, or use a template to fill in a character's full ascension or talent shopping list.")
                                .font(.subheadline).foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                        NavigationLink("Use a character template") { TemplateView(preselected: nil) }
                    }
                } else {
                    Section {
                        let total = store.data.goals.count
                        let done = store.data.goals.filter { $0.isDone }.count
                        ProgressRow(title: "Goals complete", done: done, total: total)
                        Toggle("Show completed", isOn: $showCompleted)
                        NavigationLink("Use a character template") { TemplateView(preselected: nil) }
                    }
                }

                ForEach(groups, id: \.self) { group in
                    let items = store.data.goals.filter { $0.group == group && (showCompleted || !$0.isDone) }
                    if !items.isEmpty {
                        Section {
                            ForEach(items) { goal in
                                GoalRow(goal: goal) { editing = goal }
                                    .swipeActions {
                                        Button(role: .destructive) {
                                            store.data.goals.removeAll { $0.id == goal.id }
                                        } label: { Label("Delete", systemImage: "trash") }
                                    }
                            }
                        } header: {
                            HStack {
                                Text(group.isEmpty ? "General" : group)
                                Spacer()
                                Menu {
                                    Button("Mark all collected") {
                                        for i in store.data.goals.indices where store.data.goals[i].group == group {
                                            store.data.goals[i].have = store.data.goals[i].need
                                        }
                                    }
                                    Button("Delete group", role: .destructive) {
                                        store.data.goals.removeAll { $0.group == group }
                                    }
                                } label: {
                                    Image(systemName: "ellipsis.circle")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Materials")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showAdd = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showAdd) {
                GoalEditor(goal: MaterialGoal(name: "", group: groups.first ?? "", have: 0, need: 1), isNew: true)
            }
            .sheet(item: $editing) { goal in
                GoalEditor(goal: goal, isNew: false)
            }
        }
    }
}

struct GoalRow: View {
    @EnvironmentObject var store: Store
    let goal: MaterialGoal
    let onEdit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Button(action: onEdit) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(goal.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(goal.isDone ? .secondary : .primary)
                            .multilineTextAlignment(.leading)
                        if goal.isDone {
                            Label("Done", systemImage: "checkmark.circle.fill")
                                .font(.caption).foregroundColor(.green)
                        } else {
                            Text("\(goal.remaining) more to go")
                                .font(.caption).foregroundColor(.orange)
                        }
                    }
                }
                .buttonStyle(.borderless)
                Spacer()
                Button { store.adjustGoal(goal.id, by: -1) } label: {
                    Image(systemName: "minus.circle").font(.title3)
                }
                .buttonStyle(.borderless)
                Text("\(goal.have)/\(goal.need)")
                    .font(.subheadline.monospacedDigit())
                    .frame(minWidth: 64)
                Button { store.adjustGoal(goal.id, by: 1) } label: {
                    Image(systemName: "plus.circle.fill").font(.title3)
                }
                .buttonStyle(.borderless)
            }
            ProgressView(value: goal.progress)
                .tint(goal.isDone ? .green : .accentColor)
        }
        .padding(.vertical, 2)
    }
}

struct GoalEditor: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @State var goal: MaterialGoal
    let isNew: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section("Item") {
                    TextField("Item name (e.g. Philosophies of Ballad)", text: $goal.name)
                    TextField("Group (e.g. character name)", text: $goal.group)
                }
                Section("Count") {
                    IntField(title: "Have", value: $goal.have, range: 0...9_999_999)
                    IntField(title: "Need", value: $goal.need, range: 0...9_999_999)
                    Text("\(goal.remaining) more to go").foregroundColor(.secondary)
                }
                Section("Note") {
                    TextField("Where to farm, etc.", text: $goal.note, axis: .vertical)
                }
                if !isNew {
                    Section {
                        Button("Delete", role: .destructive) {
                            store.data.goals.removeAll { $0.id == goal.id }
                            dismiss()
                        }
                    }
                }
            }
            .keyboardDoneButton()
            .navigationTitle(isNew ? "New item" : "Edit item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var g = goal
                        g.name = g.name.trimmingCharacters(in: .whitespaces)
                        g.group = g.group.trimmingCharacters(in: .whitespaces)
                        g.have = max(0, g.have)
                        g.need = max(0, g.need)
                        if let i = store.data.goals.firstIndex(where: { $0.id == g.id }) {
                            store.data.goals[i] = g
                        } else {
                            store.data.goals.append(g)
                        }
                        dismiss()
                    }
                    .disabled(goal.name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

// MARK: - Templates

struct TemplateView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    let preselected: String?

    @State private var characterID: String = ""
    @State private var ascension = true
    @State private var talentCount = 3
    @State private var includeExtras = true
    @State private var added = false

    private var sortedCharacters: [CharacterEntry] {
        store.data.characters.sorted { a, b in
            if a.owned != b.owned { return a.owned && !b.owned }
            return a.name < b.name
        }
    }

    private var selected: CharacterEntry? {
        store.data.characters.first { $0.id == characterID }
    }

    var body: some View {
        Form {
            Section("Character") {
                Picker("Character", selection: $characterID) {
                    Text("Choose…").tag("")
                    ForEach(sortedCharacters) { c in Text(c.name).tag(c.id) }
                }
                if let c = selected, store.book(c.bookID) == nil {
                    Text("This character has no talent book set, so book items will be named generically. You can set it in Roster.")
                        .font(.caption).foregroundColor(.orange)
                }
            }
            Section {
                Toggle("Ascension (Lv 1 → 90)", isOn: $ascension)
                Stepper("Talents to raise 1 → 10: \(talentCount)", value: $talentCount, in: 0...3)
                Toggle("Include mora, EXP & common drops", isOn: $includeExtras)
            } footer: {
                Text("Totals assume starting from scratch. Edit the 'have' counts afterwards for what you already own.")
            }
            Section {
                Button("Add to Materials") {
                    generate()
                    added = true
                }
                .disabled(selected == nil || (!ascension && talentCount == 0))
                if added {
                    Label("Added! Check the Materials tab.", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
        }
        .navigationTitle("Template")
        .onAppear {
            if characterID.isEmpty, let p = preselected { characterID = p }
        }
    }

    private func gemName(_ element: String) -> String {
        switch element {
        case "Pyro": return "Agnidus Agate"
        case "Hydro": return "Varunada Lazurite"
        case "Anemo": return "Vayuda Turquoise"
        case "Electro": return "Vajrada Amethyst"
        case "Dendro": return "Nagadus Emerald"
        case "Cryo": return "Shivada Jade"
        case "Geo": return "Prithiva Topaz"
        default: return "Element gem"
        }
    }

    private func generate() {
        guard let c = selected else { return }
        var items: [(String, Int)] = []

        if ascension {
            let gem = gemName(c.element)
            for (name, count) in GameData.ascensionTotals {
                let isGem = name.hasPrefix("Gem")
                let isExtra = name.hasPrefix("Common") || name.hasPrefix("Mora") || name.hasPrefix("Hero")
                if isExtra && !includeExtras { continue }
                if isGem {
                    let tier = name.replacingOccurrences(of: "Gem ", with: "")
                    items.append(("\(gem) \(tier)", count))
                } else if name.hasPrefix("Common") {
                    items.append(("Ascension: \(name.lowercased())", count))
                } else {
                    items.append((name, count))
                }
            }
        }

        if talentCount > 0 {
            let book = store.book(c.bookID)
            for (tier, count) in GameData.talentTotals {
                let name = book?.tiers[tier] ?? ["Teachings (talent book)", "Guide (talent book)", "Philosophies (talent book)"][tier]
                items.append((name, count * talentCount))
            }
            for (name, count) in GameData.talentExtras {
                let isExtra = name.hasPrefix("Common") || name.hasPrefix("Mora")
                if isExtra && !includeExtras { continue }
                let label = name.hasPrefix("Common") ? "Talents: \(name.lowercased())" : name
                items.append((label, count * talentCount))
            }
        }

        // Merge "Mora" lines from ascension + talents.
        var merged: [(String, Int)] = []
        for (n, v) in items {
            if let i = merged.firstIndex(where: { $0.0 == n }) {
                merged[i].1 += v
            } else {
                merged.append((n, v))
            }
        }

        for (name, need) in merged {
            if let i = store.data.goals.firstIndex(where: { $0.group == c.name && $0.name == name }) {
                store.data.goals[i].need += need
            } else {
                store.data.goals.append(MaterialGoal(name: name, group: c.name, have: 0, need: need))
            }
        }
    }
}
