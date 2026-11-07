struct MaterialsView: View {
    @EnvironmentObject var store: Store
    @State private var showCompleted = true
    @State private var showAdd = false
    @State private var showReorder = false
    @State private var editing: MaterialGoal?

    private var groups: [String] { store.orderedGroups() }

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
                        Text("Tip: tap a character's name to collapse it. Double-tap an item's name to mark it collected (again to undo); tap once to edit.")
                            .font(.caption).foregroundColor(.secondary)
                        NavigationLink("Use a character template") { TemplateView(preselected: nil) }
                    }
                }

                ForEach(groups, id: \.self) { group in
                    let all = store.data.goals.filter { $0.group == group }
                    let items = all.filter { showCompleted || !$0.isDone }
                    let collapsed = store.isCollapsed(group)
                    Section {
                        if !collapsed {
                            if items.isEmpty {
                                Text("All collected! 🎉").font(.subheadline).foregroundColor(.secondary)
                            }
                            ForEach(items) { goal in
                                GoalRow(goal: goal) { editing = goal }
                                    .swipeActions {
                                        Button(role: .destructive) {
                                            store.data.goals.removeAll { $0.id == goal.id }
                                        } label: { Label("Delete", systemImage: "trash") }
                                    }
                            }
                        }
                    } header: {
                        GroupHeader(group: group, goals: all, collapsed: collapsed)
                    }
                }
            }
            .navigationTitle("Materials")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button { showReorder = true } label: {
                            Label("Reorder characters", systemImage: "arrow.up.arrow.down")
                        }
                        Button { withAnimation { store.setAllCollapsed(true) } } label: {
                            Label("Collapse all", systemImage: "rectangle.compress.vertical")
                        }
                        Button { withAnimation { store.setAllCollapsed(false) } } label: {
                            Label("Expand all", systemImage: "rectangle.expand.vertical")
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                    .disabled(store.data.goals.isEmpty)
                }
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
            .sheet(isPresented: $showReorder) { GroupReorderView() }
        }
    }
}

struct GroupHeader: View {
    @EnvironmentObject var store: Store
    let group: String
    let goals: [MaterialGoal]
    let collapsed: Bool

    private var character: CharacterEntry? {
        store.data.characters.first(where: { $0.name == group })
    }

    var body: some View {
        HStack(spacing: 8) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { store.toggleCollapsed(group) }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .rotationEffect(.degrees(collapsed ? 0 : 90))
                    if let c = character {
                        CharacterIcon(character: c, size: 26)
                    }
                    Text(group.isEmpty ? "General" : group)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)
                    let done = goals.filter { $0.isDone }.count
                    Text("\(done)/\(goals.count)")
                        .font(.caption.monospacedDigit())
                        .foregroundColor(done == goals.count ? .green : .secondary)
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
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
        .textCase(nil)
    }
}

struct GroupReorderView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(store.orderedGroups(), id: \.self) { group in
                        HStack(spacing: 10) {
                            if let c = store.data.characters.first(where: { $0.name == group }) {
                                CharacterIcon(character: c, size: 32)
                            } else {
                                Image(systemName: "shippingbox").frame(width: 32)
                            }
                            Text(group.isEmpty ? "General" : group)
                        }
                    }
                    .onMove { from, to in store.moveGroups(from: from, to: to) }
                } footer: {
                    Text("Drag the handles to change the order on the Materials tab.")
                }
            }
            .environment(\.editMode, .constant(.active))
            .navigationTitle("Reorder characters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
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
            HStack(spacing: 10) {
                HStack(spacing: 10) {
                    ItemIcon(name: goal.name, size: 38)
                        .opacity(goal.isDone ? 0.5 : 1)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(goal.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(goal.isDone ? .secondary : .primary)
                            .strikethrough(goal.isDone)
                            .multilineTextAlignment(.leading)
                        if goal.isDone {
                            Label("Done", systemImage: "checkmark.circle.fill")
                                .font(.caption).foregroundColor(.green)
                        } else {
                            Text("\(goal.remaining.formatted()) more to go")
                                .font(.caption).foregroundColor(.orange)
                        }
                    }
                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
                .onTapGesture(count: 2) {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    withAnimation(.easeInOut(duration: 0.2)) {
                        store.toggleGoalComplete(goal.id)
                    }
                }
                .onTapGesture(count: 1) { onEdit() }

                Button { store.adjustGoal(goal.id, by: -1) } label: {
                    Image(systemName: "minus.circle").font(.title3)
                }
                .buttonStyle(.borderless)
                Text("\(goal.have)/\(goal.need)")
                    .font(.footnote.monospacedDigit())
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .frame(minWidth: 56)
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
                    HStack(spacing: 12) {
                        ItemIcon(name: goal.name, size: 44)
                        TextField("Item name (e.g. Philosophies of Ballad)", text: $goal.name)
                    }
                    TextField("Group (e.g. character name)", text: $goal.group)
                }
                Section("Count") {
                    IntField(title: "Have", value: $goal.have, range: 0...999_999_999)
                    IntField(title: "Need", value: $goal.need, range: 0...999_999_999)
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
                Toggle("Include Mora & Hero's Wit", isOn: $includeExtras)
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
        let mats = MaterialData.byCharacter[c.name]
        let book = store.book(c.bookID)

        if ascension {
            if let mats {
                for (name, count) in mats.ascension { items.append((name, count)) }
            } else {
                let gem = gemName(c.element)
                for (name, count) in GameData.ascensionTotals where name.hasPrefix("Gem") || name == "Boss material" || name == "Local specialty" {
                    if name.hasPrefix("Gem") {
                        items.append(("\(gem) \(name.replacingOccurrences(of: "Gem ", with: ""))", count))
                    } else {
                        items.append((name, count))
                    }
                }
            }
            if includeExtras {
                items.append(("Mora", 420_000))
                items.append(("Hero's Wit", 419))
            }
        }

        if talentCount > 0 {
            for (tier, count) in GameData.talentTotals {
                let name = book?.tiers[tier] ?? ["Teachings (talent book)", "Guide (talent book)", "Philosophies (talent book)"][tier]
                items.append((name, count * talentCount))
            }
            let commonTotals = [18, 66, 93]
            for t in 0..<3 {
                let name = (mats?.common.count ?? 0) == 3 ? mats!.common[t] : "Talent common drop (tier \(t + 1))"
                items.append((name, commonTotals[t] * talentCount))
            }
            let boss = (mats?.weeklyBoss.isEmpty ?? true) ? "Weekly boss material" : mats!.weeklyBoss
            items.append((boss, 6 * talentCount))
            items.append(("Crown of Insight", 1 * talentCount))
            if includeExtras {
                items.append(("Mora", 1_652_500 * talentCount))
            }
        }

        // Merge duplicates (e.g. common drops used by both ascension and talents, Mora).
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
