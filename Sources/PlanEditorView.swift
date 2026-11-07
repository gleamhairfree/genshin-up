import SwiftUI

/// Create or edit a character's material plan (target level / ascension and talents).
struct PlanEditorView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss

    /// nil = let the user pick a character.
    let characterID: String?
    var showsCloseButton = false

    @State private var selectedID: String = ""
    @State private var plan = CharacterPlan()
    @State private var loadedFor: String = ""
    @State private var savedMessage: String?
    @State private var confirmRemove = false

    private var character: CharacterEntry? {
        store.data.characters.first(where: { $0.id == selectedID })
    }

    private var hasExistingPlan: Bool {
        guard let c = character else { return false }
        return store.plan(for: c.name) != nil || store.data.goals.contains { $0.group == c.name }
    }

    private var sortedCharacters: [CharacterEntry] {
        store.data.characters.sorted { a, b in
            if a.owned != b.owned { return a.owned && !b.owned }
            return a.name < b.name
        }
    }

    private var preview: [(name: String, count: Int)] {
        guard let c = character else { return [] }
        return PlanCalculator.items(for: c, book: store.book(c.bookID), plan: plan)
    }

    var body: some View {
        Form {
            if characterID == nil {
                Section("Character") {
                    Picker("Character", selection: $selectedID) {
                        Text("Choose…").tag("")
                        ForEach(sortedCharacters) { c in Text(c.name).tag(c.id) }
                    }
                }
            } else if let c = character {
                Section {
                    HStack(spacing: 12) {
                        CharacterIcon(character: c, size: 48)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(c.name).font(.headline)
                            Text(hasExistingPlan ? "Editing plan" : "New plan")
                                .font(.caption).foregroundColor(.secondary)
                        }
                    }
                }
            }

            if let c = character {
                Section {
                    IntField(title: "Current level", value: $plan.currentLevel, range: 1...90, width: 70)
                    Picker("Raise to", selection: $plan.targetLevel) {
                        ForEach(PlanCalculator.caps, id: \.self) { lvl in
                            Text(PlanCalculator.ascensionLabel(forTarget: lvl)).tag(lvl)
                        }
                    }
                    if plan.targetLevel <= plan.currentLevel {
                        Text("Already at or above this level, so no level-up materials are needed.")
                            .font(.caption).foregroundColor(.secondary)
                    }
                } header: {
                    Text("Level & ascension")
                } footer: {
                    Text("Being exactly at a cap (e.g. Lv. 40) counts as already ascended to reach it.")
                }

                Section {
                    Stepper("Talents to max (Lv. 10): \(plan.talentsToMax)", value: $plan.talentsToMax, in: 0...3)
                    if plan.talentsToMax > 0 {
                        Stepper("Starting from talent Lv. \(plan.startTalentLevel)", value: $plan.startTalentLevel, in: 1...9)
                        Button("Use \(c.name)'s current talents") {
                            plan.startTalentLevel = min(9, max(1, c.talents.min() ?? 1))
                        }
                        .font(.footnote)
                    }
                    Toggle("Include Mora & Hero's Wit", isOn: $plan.includeExtras)
                } header: {
                    Text("Talents")
                }

                Section {
                    if preview.isEmpty {
                        Text("Nothing needed for this plan.").foregroundColor(.secondary)
                    }
                    ForEach(preview, id: \.name) { item in
                        HStack(spacing: 10) {
                            ItemIcon(name: item.name, size: 30)
                            Text(item.name).font(.subheadline)
                            Spacer()
                            Text(item.count.formatted()).font(.subheadline.monospacedDigit())
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Needed in total")
                } footer: {
                    Text("Saving updates the 'need' counts on the Materials tab. Your 'have' counts and any items you added by hand are kept.")
                }

                Section {
                    Button {
                        store.applyPlan(plan, to: c)
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        if showsCloseButton {
                            dismiss()
                        } else {
                            savedMessage = "Saved! Check the Materials tab."
                        }
                    } label: {
                        Label(hasExistingPlan ? "Update plan" : "Add to Materials", systemImage: "checkmark.circle.fill")
                            .font(.headline)
                    }
                    if let msg = savedMessage {
                        Text(msg).font(.footnote).foregroundColor(.green)
                    }
                    if hasExistingPlan {
                        Button("Remove plan & its items", role: .destructive) { confirmRemove = true }
                    }
                }
            }
        }
        .navigationTitle("Plan materials")
        .navigationBarTitleDisplayMode(.inline)
        .keyboardDoneButton()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                if showsCloseButton { Button("Close") { dismiss() } }
            }
        }
        .confirmationDialog("Remove this plan?", isPresented: $confirmRemove, titleVisibility: .visible) {
            Button("Remove plan & planned items", role: .destructive) {
                if let c = character { store.removePlan(for: c) }
                savedMessage = nil
                if showsCloseButton { dismiss() }
            }
        } message: {
            Text("Items you added by hand stay.")
        }
        .onAppear {
            if selectedID.isEmpty, let id = characterID { selectedID = id }
            loadPlan()
        }
        .onChange(of: selectedID) { _ in
            savedMessage = nil
            loadPlan()
        }
    }

    private func loadPlan() {
        guard let c = character, loadedFor != c.id else { return }
        loadedFor = c.id
        if let existing = store.plan(for: c.name) {
            plan = existing
        } else {
            plan = store.inferredPlan(for: c)
        }
    }
}
