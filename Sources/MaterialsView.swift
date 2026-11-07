import SwiftUI

struct MaterialsView: View {
    @EnvironmentObject var store: Store
    @State private var showCompleted = true
    @State private var showAdd = false
    @State private var showReorder = false
    @State private var editing: MaterialGoal?
    @State private var planTarget: PlanTarget?

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
                        NavigationLink { PlanEditorView(characterID: nil) } label: { Label("Plan a character", systemImage: "wand.and.stars") }
                    }
                } else {
                    Section {
                        let total = store.data.goals.count
                        let done = store.data.goals.filter { $0.isDone }.count
                        ProgressRow(title: "Goals complete", done: done, total: total)
                        Toggle("Show completed", isOn: $showCompleted)
                        Text("Tip: tap a character's name to collapse it. Double-tap an item's name to mark it collected (again to undo); tap once to edit.")
                            .font(.caption).foregroundColor(.secondary)
                        NavigationLink { PlanEditorView(characterID: nil) } label: { Label("Plan a character", systemImage: "wand.and.stars") }
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
                        GroupHeader(group: group, goals: all, collapsed: collapsed) { id in
                            planTarget = PlanTarget(id: id)
                        }
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
            .sheet(item: $planTarget) { target in
                NavigationStack {
                    PlanEditorView(characterID: target.id, showsCloseButton: true)
                }
            }
        }
    }
}

struct GroupHeader: View {
    @EnvironmentObject var store: Store
    let group: String
    let goals: [MaterialGoal]
    let collapsed: Bool
    let onEditPlan: (String) -> Void

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
                    VStack(alignment: .leading, spacing: 0) {
                        Text(group.isEmpty ? "General" : group)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.primary)
                        if let p = store.plan(for: group) {
                            Text(planSummary(p))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
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
                if let c = character {
                    Button {
                        onEditPlan(c.id)
                    } label: {
                        Label("Edit plan (level & talents)", systemImage: "slider.horizontal.3")
                    }
                }
                Button("Mark all collected") {
                    for i in store.data.goals.indices where store.data.goals[i].group == group {
                        store.data.goals[i].have = store.data.goals[i].need
                    }
                }
                Button("Delete group", role: .destructive) {
                    var d = store.data
                    d.goals.removeAll { $0.group == group }
                    d.plans[group] = nil
                    store.data = d
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
        .textCase(nil)
    }
}

struct PlanTarget: Identifiable {
    let id: String
}

private func planSummary(_ p: CharacterPlan) -> String {
    var parts: [String] = []
    if p.targetLevel > p.currentLevel { parts.append("Lv. \(p.currentLevel)→\(p.targetLevel)") }
    if p.talentsToMax > 0 && p.targetTalentLevel > p.startTalentLevel {
        parts.append("\(p.talentsToMax)× talents \(p.startTalentLevel)→\(p.targetTalentLevel)")
    }
    return parts.isEmpty ? "No upgrades planned" : parts.joined(separator: " · ")
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
                .tint(goal.isDone ? Color.green : nil)
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
