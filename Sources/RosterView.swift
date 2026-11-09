import SwiftUI

enum RosterFilter: String, CaseIterable, Identifiable {
    case all = "All", owned = "Owned", missing = "Not owned", building = "Building"
    var id: String { rawValue }
}

struct RosterView: View {
    @EnvironmentObject var store: Store
    @State private var search = ""
    @State private var filter: RosterFilter = .all
    @State private var element: String = "All"
    @State private var showAdd = false
    @State private var showAddWeapon = false
    @State private var tab = 0

    private var filtered: [CharacterEntry] {
        store.data.characters
            .filter { c in
                switch filter {
                case .all: return true
                case .owned: return c.owned
                case .missing: return !c.owned
                case .building: return c.building
                }
            }
            .filter { element == "All" || $0.element == element }
            .filter { search.isEmpty || $0.name.localizedCaseInsensitiveContains(search) }
            .sorted { a, b in
                if a.owned != b.owned { return a.owned && !b.owned }
                return a.name < b.name
            }
    }

    var body: some View {
        NavigationStack {
            Group {
                if tab == 0 { charactersList } else { WeaponsList(search: search) }
            }
            .searchable(text: $search, prompt: tab == 0 ? "Search characters" : "Search weapons")
            .navigationTitle(tab == 0 ? "Roster" : "Weapons")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker("Roster", selection: $tab) {
                        Text("Characters").tag(0)
                        Text("Weapons").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 220)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        if tab == 0 { showAdd = true } else { showAddWeapon = true }
                    } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showAdd) { AddCharacterView() }
            .sheet(isPresented: $showAddWeapon) { AddWeaponView() }
        }
    }

    private var charactersList: some View {
            List {
                Section {
                    let owned = store.data.characters.filter { $0.owned }.count
                    ProgressRow(title: "Collected", done: owned, total: store.data.characters.count)
                    Picker("Show", selection: $filter) {
                        ForEach(RosterFilter.allCases) { f in Text(f.rawValue).tag(f) }
                    }
                    .pickerStyle(.segmented)
                    Picker("Element", selection: $element) {
                        Text("All elements").tag("All")
                        ForEach(GameData.elements, id: \.self) { e in
                            Label { Text(e) } icon: { ElementDot(element: e) }.tag(e)
                        }
                    }
                }
                Section {
                    ForEach(filtered) { c in
                        NavigationLink {
                            CharacterDetailView(character: store.characterBinding(c.id))
                        } label: {
                            CharacterRow(character: c)
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                store.toggleOwned(c.id)
                            } label: {
                                Label(c.owned ? "Unown" : "Own", systemImage: c.owned ? "xmark" : "checkmark")
                            }
                            .tint(c.owned ? .gray : .green)
                        }
                    }
                } footer: {
                    Text("Swipe right on a character to quickly mark owned. Tap to edit level, constellation and talents.")
                }
            }
    }
}

struct CharacterRow: View {
    @EnvironmentObject var store: Store
    let character: CharacterEntry

    var body: some View {
        HStack(spacing: 12) {
            CharacterIcon(character: character, size: 44, dimmed: !character.owned)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(character.name)
                        .font(.body.weight(character.owned ? .semibold : .regular))
                        .foregroundColor(character.owned ? .primary : .secondary)
                    Stars(count: character.rarity)
                    if character.building {
                        Image(systemName: "hammer.fill").font(.caption2).foregroundColor(.orange)
                    }
                }
                if character.owned {
                    Text("Lv \(character.level) · C\(character.constellation) · Talents \(character.talentSummary)")
                        .font(.caption).foregroundColor(.secondary)
                } else {
                    Text("\(character.weapon) · \(store.book(character.bookID)?.name ?? "book not set")")
                        .font(.caption).foregroundColor(.secondary)
                }
            }
            Spacer()
            if character.owned {
                Image(systemName: "checkmark.seal.fill").foregroundColor(.green)
            }
        }
    }
}

struct CharacterDetailView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @Binding var character: CharacterEntry
    @State private var confirmDelete = false
    @State private var browserPage: BrowserPage?

    private let talentNames = ["Normal Attack", "Elemental Skill", "Elemental Burst"]

    /// Marks the book as user-chosen so future app updates don't overwrite it.
    private var bookBinding: Binding<String> {
        Binding(
            get: { character.bookID },
            set: { newValue in
                character.bookID = newValue
                character.bookEdited = true
            }
        )
    }

    var body: some View {
        Form {
            Section {
                HStack(spacing: 16) {
                    CharacterIcon(character: character, size: 76)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(character.name).font(.title3.weight(.bold))
                        Stars(count: character.rarity)
                        HStack(spacing: 6) {
                            ElementDot(element: character.element)
                            Text("\(character.element) · \(character.weapon)")
                                .font(.caption).foregroundColor(.secondary)
                        }
                        if let b = store.book(character.bookID) {
                            Text("\(b.name) books · \(b.group.short)")
                                .font(.caption).foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            Section {
                Toggle("Owned", isOn: $character.owned)
                Toggle("Currently building", isOn: $character.building)
            } footer: {
                Text("Characters you're building show up first in Today's farming list.")
            }

            Section("Progress") {
                IntField(title: "Level", value: $character.level, range: 1...100, width: 80)
                Stepper("Constellation C\(character.constellation)", value: $character.constellation, in: 0...6)
                Stepper("Friendship \(character.friendship)", value: $character.friendship, in: 1...10)
            }

            Section("Talents") {
                ForEach(0..<3, id: \.self) { i in
                    Stepper("\(talentNames[i]): \(character.talents[i])", value: $character.talents[i], in: 1...15)
                }
            }

            if true {
                Section {
                    if let url = character.kqmQuickGuideURL {
                        Button {
                            browserPage = BrowserPage(url: url)
                        } label: {
                            Label("KQM Quick Guide", systemImage: "book.pages")
                        }
                    }
                    if let url = character.kqmInfographicURL {
                        Button {
                            browserPage = BrowserPage(url: url)
                        } label: {
                            Label("KQM Infographic", systemImage: "photo")
                        }
                    }
                    Button {
                        browserPage = BrowserPage(url: ExternalPages.yshelperAbyss)
                    } label: {
                        Label("Abyss usage stats (YSHelper)", systemImage: "chart.bar.xaxis")
                    }
                } header: {
                    Text("Guides")
                } footer: {
                    Text("Opens in a popup – tap Done to come back. KQM guides are per character; YSHelper shows current Spiral Abyss usage for everyone. If a link doesn't load, KQM may not have that guide yet or uses a different name – you can change the guide name below.")
                }
            }

            Section("Info") {
                Picker("Talent book", selection: bookBinding) {
                    Text("Not set").tag("")
                    ForEach(store.allBooks) { b in
                        Text("\(b.name) (\(b.group.short))").tag(b.id)
                    }
                }
                Picker("Element", selection: $character.element) {
                    ForEach(GameData.elements, id: \.self) { Text($0).tag($0) }
                    if !GameData.elements.contains(character.element) {
                        Text(character.element.isEmpty ? "Unknown" : character.element).tag(character.element)
                    }
                }
                Picker("Weapon", selection: $character.weapon) {
                    ForEach(GameData.weapons, id: \.self) { Text($0).tag($0) }
                    if !GameData.weapons.contains(character.weapon) {
                        Text(character.weapon.isEmpty ? "Unknown" : character.weapon).tag(character.weapon)
                    }
                }
                Picker("Rarity", selection: $character.rarity) {
                    Text("4★").tag(4)
                    Text("5★").tag(5)
                }
                Picker("Region", selection: $character.region) {
                    ForEach(GameData.regions, id: \.self) { Text($0).tag($0) }
                }
                HStack {
                    Text("KQM guide name")
                    Spacer()
                    TextField("e.g. hu-tao", text: $character.kqmSlug)
                        .multilineTextAlignment(.trailing)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .foregroundColor(.secondary)
                }
            }

            Section("Notes") {
                TextField("Artifacts, weapon, team ideas…", text: $character.notes, axis: .vertical)
                    .lineLimit(3...8)
            }

            Section {
                NavigationLink("Plan materials for \(character.name)") {
                    PlanEditorView(characterID: character.id)
                }
            }

            if character.isCustom {
                Section {
                    Button("Delete character", role: .destructive) { confirmDelete = true }
                }
            }
        }
        .navigationTitle(character.name)
        .navigationBarTitleDisplayMode(.inline)
        .keyboardDoneButton()
        .inAppBrowser($browserPage, tint: Theme.accent(store.data.accent))
        .confirmationDialog("Delete \(character.name)?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                let id = character.id
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    store.data.characters.removeAll { $0.id == id }
                }
            }
        }
    }
}

struct AddCharacterView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var element = "Pyro"
    @State private var weapon = "Sword"
    @State private var rarity = 5
    @State private var region = "Snezhnaya"
    @State private var bookID = ""
    @State private var owned = true

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                    Toggle("Owned", isOn: $owned)
                } footer: {
                    Text("Use this for new characters that aren't in the built-in list yet.")
                }
                Section {
                    Picker("Element", selection: $element) {
                        ForEach(GameData.elements, id: \.self) { Text($0).tag($0) }
                    }
                    Picker("Weapon", selection: $weapon) {
                        ForEach(GameData.weapons, id: \.self) { Text($0).tag($0) }
                    }
                    Picker("Rarity", selection: $rarity) {
                        Text("4★").tag(4)
                        Text("5★").tag(5)
                    }
                    Picker("Region", selection: $region) {
                        ForEach(GameData.regions, id: \.self) { Text($0).tag($0) }
                    }
                    Picker("Talent book", selection: $bookID) {
                        Text("Not set").tag("")
                        ForEach(store.allBooks) { b in Text("\(b.name) (\(b.group.short))").tag(b.id) }
                    }
                }
            }
            .navigationTitle("Add character")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        var c = CharacterEntry(
                            id: "custom:" + UUID().uuidString,
                            name: name.trimmingCharacters(in: .whitespaces),
                            element: element, weapon: weapon, rarity: rarity,
                            region: region, bookID: bookID, isCustom: true)
                        c.owned = owned
                        c.bookEdited = true
                        c.kqmSlug = c.name.lowercased().replacingOccurrences(of: " ", with: "-")
                        store.data.characters.append(c)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
