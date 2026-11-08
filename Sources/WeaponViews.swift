import SwiftUI

// MARK: - List

struct WeaponsList: View {
    @EnvironmentObject var store: Store
    let search: String

    private var weapons: [TrackedWeapon] {
        store.data.weapons.filter { search.isEmpty || $0.name.localizedCaseInsensitiveContains(search) || $0.equippedOn.localizedCaseInsensitiveContains(search) }
    }

    var body: some View {
        List {
            if store.data.weapons.isEmpty {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("No weapons yet").font(.headline)
                        Text("Tap + to add a weapon you own or want to build. You can track its level and refinement, who uses it, and plan its ascension materials.")
                            .font(.subheadline).foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            Section {
                ForEach(weapons) { w in
                    NavigationLink {
                        WeaponDetailView(weaponID: w.id)
                    } label: {
                        WeaponRow(weapon: w)
                    }
                }
            } footer: {
                if !store.data.weapons.isEmpty {
                    Text("Tap a weapon to set its level, refinement and who uses it, or to plan its materials.")
                }
            }
        }
    }
}

struct WeaponRow: View {
    let weapon: TrackedWeapon

    var body: some View {
        let info = weapon.info
        HStack(spacing: 12) {
            WeaponIcon(weaponID: weapon.weaponID, rarity: info?.rarity ?? 4, size: 44)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(weapon.name).font(.body.weight(.semibold))
                    Stars(count: info?.rarity ?? 4)
                }
                Text("Lv \(weapon.level)/\(info?.maxLevel ?? 90) · R\(weapon.refinement)\(weapon.equippedOn.isEmpty ? "" : " · \(weapon.equippedOn)")")
                    .font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            if weapon.plan != nil {
                Image(systemName: "list.bullet.clipboard").foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Add

struct AddWeaponView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var search = ""
    @State private var type = "All"
    @State private var minRarity = 4

    private var results: [WeaponInfo] {
        WeaponCatalog.all
            .filter { type == "All" || $0.type == type }
            .filter { $0.rarity >= minRarity }
            .filter { search.isEmpty || $0.name.localizedCaseInsensitiveContains(search) }
            .sorted { a, b in a.rarity != b.rarity ? a.rarity > b.rarity : a.name < b.name }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Type", selection: $type) {
                        Text("All").tag("All")
                        ForEach(GameData.weapons, id: \.self) { Text($0).tag($0) }
                    }
                    Picker("Rarity", selection: $minRarity) {
                        Text("5★").tag(5)
                        Text("4★+").tag(4)
                        Text("3★+").tag(3)
                        Text("All").tag(1)
                    }
                    .pickerStyle(.segmented)
                }
                Section {
                    ForEach(results) { info in
                        Button {
                            let w = TrackedWeapon(info: info, groupName: store.uniqueWeaponGroupName(for: info, equippedOn: ""))
                            store.data.weapons.append(w)
                            dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                WeaponIcon(weaponID: info.id, rarity: info.rarity, size: 40)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(info.name).foregroundColor(.primary)
                                    Text("\(info.type) · \(String(repeating: "★", count: info.rarity))")
                                        .font(.caption).foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                } footer: {
                    Text("\(results.count) weapons")
                }
            }
            .searchable(text: $search, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search weapons")
            .navigationTitle("Add weapon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
        }
    }
}

// MARK: - Detail

struct WeaponDetailView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    let weaponID: UUID
    @State private var confirmDelete = false

    var body: some View {
        let binding = store.weaponBinding(weaponID)
        let w = binding.wrappedValue
        let info = w.info
        let maxLevel = info?.maxLevel ?? 90
        Form {
            Section {
                HStack(spacing: 16) {
                    WeaponIcon(weaponID: w.weaponID, rarity: info?.rarity ?? 4, size: 76)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(w.name).font(.title3.weight(.bold))
                        Stars(count: info?.rarity ?? 4)
                        Text(info?.type ?? "").font(.caption).foregroundColor(.secondary)
                        if let g = info?.domainGroup, let item = info?.domainItem {
                            HStack(spacing: 6) {
                                ItemIcon(name: item, size: 20)
                                Text("Domain: \(g.short)").font(.caption).foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            Section("Progress") {
                IntField(title: "Level", value: binding.level, range: 1...maxLevel, width: 80)
                Stepper("Refinement R\(w.refinement)", value: binding.refinement, in: 1...5)
                Picker("Equipped on", selection: binding.equippedOn) {
                    Text("Nobody").tag("")
                    ForEach(equipCandidates(type: info?.type ?? "", current: w.equippedOn), id: \.self) { name in
                        Text(name).tag(name)
                    }
                }
            }

            Section {
                NavigationLink {
                    WeaponPlanEditor(weaponID: weaponID)
                } label: {
                    Label(w.plan == nil ? "Plan materials" : "Edit plan", systemImage: "wand.and.stars")
                }
                if let p = w.plan {
                    Text("Planned: Lv. \(p.currentLevel) → \(p.targetLevel)")
                        .font(.caption).foregroundColor(.secondary)
                }
            } footer: {
                Text("Planned items appear on the Materials tab under \"\(w.groupName)\".")
            }

            Section("Notes") {
                TextField("Who it's for, refinement goals…", text: binding.notes, axis: .vertical)
                    .lineLimit(2...6)
            }

            Section {
                Button("Remove weapon", role: .destructive) { confirmDelete = true }
            }
        }
        .navigationTitle(w.name)
        .navigationBarTitleDisplayMode(.inline)
        .keyboardDoneButton()
        .confirmationDialog("Remove \(w.name)?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Remove weapon & planned items", role: .destructive) {
                let id = weaponID
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { store.deleteWeapon(id) }
            }
        }
    }

    private func equipCandidates(type: String, current: String) -> [String] {
        var names = store.data.characters
            .filter { $0.owned && ($0.weapon == type || type.isEmpty) }
            .map { $0.name }
            .sorted()
        if !current.isEmpty && !names.contains(current) { names.insert(current, at: 0) }
        return names
    }
}

// MARK: - Plan editor

struct WeaponPlanEditor: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    let weaponID: UUID
    var showsCloseButton = false

    @State private var plan = WeaponPlan()
    @State private var loaded = false
    @State private var savedMessage: String?
    @State private var confirmRemove = false

    private var weapon: TrackedWeapon? { store.data.weapons.first(where: { $0.id == weaponID }) }

    var body: some View {
        Form {
            if let w = weapon, let info = w.info {
                let caps = PlanCalculator.caps.filter { $0 <= info.maxLevel }
                let preview = WeaponCalculator.items(for: info, plan: plan)
                Section {
                    HStack(spacing: 12) {
                        WeaponIcon(weaponID: w.weaponID, rarity: info.rarity, size: 48)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(w.name).font(.headline)
                            Text(w.plan == nil ? "New plan" : "Editing plan").font(.caption).foregroundColor(.secondary)
                        }
                    }
                }

                Section {
                    IntField(title: "Current level", value: $plan.currentLevel, range: 1...info.maxLevel, width: 70)
                    Picker("Raise to", selection: $plan.targetLevel) {
                        ForEach(caps, id: \.self) { lvl in
                            Text(PlanCalculator.ascensionLabel(forTarget: lvl)).tag(lvl)
                        }
                    }
                    if plan.targetLevel <= plan.currentLevel {
                        Text("Already at or above this level.").font(.caption).foregroundColor(.secondary)
                    }
                    Toggle("Include Mora & Enhancement Ore", isOn: $plan.includeExtras)
                } header: {
                    Text("Level & ascension")
                } footer: {
                    Text("Enhancement Ore is counted as Mystic Enhancement Ore (10,000 EXP each).")
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
                            Text(item.count.formatted()).font(.subheadline.monospacedDigit()).foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Needed in total")
                }

                Section {
                    Button {
                        store.applyWeaponPlan(plan, to: weaponID)
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        if showsCloseButton { dismiss() } else { savedMessage = "Saved! Check the Materials tab." }
                    } label: {
                        Label(w.plan == nil ? "Add to Materials" : "Update plan", systemImage: "checkmark.circle.fill")
                            .font(.headline)
                    }
                    if let msg = savedMessage {
                        Text(msg).font(.footnote).foregroundColor(.green)
                    }
                    if w.plan != nil {
                        Button("Remove plan & its items", role: .destructive) { confirmRemove = true }
                    }
                }
            } else {
                Text("This weapon couldn't be found.").foregroundColor(.secondary)
            }
        }
        .navigationTitle("Plan weapon")
        .navigationBarTitleDisplayMode(.inline)
        .keyboardDoneButton()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                if showsCloseButton { Button("Close") { dismiss() } }
            }
        }
        .confirmationDialog("Remove this plan?", isPresented: $confirmRemove, titleVisibility: .visible) {
            Button("Remove plan & planned items", role: .destructive) {
                store.removeWeaponPlan(weaponID)
                savedMessage = nil
                if showsCloseButton { dismiss() }
            }
        }
        .onAppear {
            guard !loaded, let w = weapon, let info = w.info else { return }
            loaded = true
            if let p = w.plan {
                plan = p
            } else {
                plan.currentLevel = max(1, w.level)
                plan.targetLevel = info.maxLevel
            }
        }
    }
}
