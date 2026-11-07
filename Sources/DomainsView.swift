import SwiftUI

struct DomainsView: View {
    @EnvironmentObject var store: Store
    @State private var selected: GameDay = .monday
    @State private var didSetInitial = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Day", selection: $selected) {
                    ForEach(GameDay.ordered) { d in Text(d.short).tag(d) }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)

                DomainDayList(day: selected, setsTitle: false)
            }
            .navigationTitle("Domains")
            .onAppear {
                if !didSetInitial {
                    selected = ResetClock.gameDay(server: store.data.server)
                    didSetInitial = true
                }
            }
        }
    }
}

struct DomainDayList: View {
    @EnvironmentObject var store: Store
    let day: GameDay
    var setsTitle = true
    @State private var ownedOnly = false

    var body: some View {
        let books = store.allBooks.filter { day.includes($0.group) }
        let mats = GameData.weaponMaterials.filter { day.includes($0.group) }
        let regions = GameData.regions.filter { r in
            books.contains { $0.region == r } || mats.contains { $0.region == r }
        }

        List {
            Section {
                Toggle("Only show characters I own", isOn: $ownedOnly)
                if day == .sunday {
                    Text("Sunday: you can pick any reward in every domain.")
                        .font(.footnote).foregroundColor(.secondary)
                }
            }
            ForEach(regions, id: \.self) { region in
                Section(region) {
                    ForEach(books.filter { $0.region == region }) { book in
                        bookRow(book)
                    }
                    ForEach(mats.filter { $0.region == region }) { mat in
                        HStack(alignment: .top) {
                            Image(systemName: "hammer.fill").foregroundColor(.gray)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(mat.name).font(.subheadline.weight(.semibold))
                                Text("Weapon ascension · \(mat.domain) · \(mat.group.short)")
                                    .font(.caption).foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(setsTitle ? day.name : "Domains")
    }

    @ViewBuilder
    private func bookRow(_ book: TalentBook) -> some View {
        let all = store.characters(using: book)
        let shown = ownedOnly ? all.filter { $0.owned } : all
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "book.fill").foregroundColor(.orange)
                Text(book.name).font(.subheadline.weight(.semibold))
                if book.isCustom { Text("custom").font(.caption2).foregroundColor(.secondary) }
            }
            Text("Talent books · \(book.domain) · \(book.group.short)")
                .font(.caption).foregroundColor(.secondary)
            if !shown.isEmpty {
                FlowText(characters: shown)
            }
        }
        .padding(.vertical, 2)
    }
}

/// Character names joined, owned ones bold and coloured.
struct FlowText: View {
    let characters: [CharacterEntry]
    var body: some View {
        characters.enumerated().reduce(Text("")) { acc, pair in
            let c = pair.element
            let sep = pair.offset == 0 ? "" : ", "
            let name: Text = c.owned
                ? Text(c.name).bold().foregroundColor(GameData.color(for: c.element))
                : Text(c.name).foregroundColor(.secondary)
            return acc + Text(sep).foregroundColor(.secondary) + name
        }
        .font(.caption)
    }
}
