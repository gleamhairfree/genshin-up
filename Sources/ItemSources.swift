import SwiftUI

/// Where an item comes from: a domain (with days) and/or enemies that drop it.
struct ItemSource {
    var domain: String
    var region: String
    var days: [String]          // "Mon", "Thu", "Sun"
    var type: String
    var enemies: [(name: String, boss: Bool)]

    var dayGroup: DayGroup? {
        if days.contains("Mon") { return .monThu }
        if days.contains("Tue") { return .tueFri }
        if days.contains("Wed") { return .wedSat }
        return nil
    }
}

extension MaterialData {
    static let sources: [String: ItemSource] = {
        var result: [String: ItemSource] = [:]
        for line in (LiveCatalog.raw(\.itemSourcesRaw) ?? "").split(separator: "\n") {
            let p = line.split(separator: "|", omittingEmptySubsequences: false).map(String.init)
            guard p.count >= 6 else { continue }
            let enemies = p[5].split(separator: ";").map { e -> (name: String, boss: Bool) in
                let s = String(e)
                return s.hasPrefix("★") ? (String(s.dropFirst()), true) : (s, false)
            }
            result[normalize(p[0])] = ItemSource(domain: p[1], region: p[2],
                                                 days: p[3].split(separator: ",").map(String.init),
                                                 type: p[4], enemies: enemies)
        }
        return result
    }()

    static func source(for name: String) -> ItemSource? {
        let key = normalize(name)
        if let s = sources[key] { return s }
        // Built-in fallback for talent books (before game data has downloaded).
        if let book = GameData.books.first(where: { $0.tiers.map(normalize).contains(key) }) {
            let days = book.group.short.split(separator: "/").map(String.init) + ["Sun"]
            return ItemSource(domain: book.domain, region: book.region, days: days, type: "Character Talent Material", enemies: [])
        }
        return nil
    }
}

/// "Where to get it" section shown when tapping an item on the Materials tab.
struct ItemSourceSection: View {
    @EnvironmentObject var store: Store
    let itemName: String

    var body: some View {
        if let src = MaterialData.source(for: itemName) {
            let today = ResetClock.gameDay(server: store.data.server)
            Section {
                if !src.domain.isEmpty {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "building.columns.fill").foregroundColor(.accentColor).frame(width: 24)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(src.domain).font(.subheadline.weight(.semibold))
                            Text([src.region, src.days.joined(separator: " / ")].filter { !$0.isEmpty }.joined(separator: " · "))
                                .font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                        if let g = src.dayGroup {
                            if today.includes(g) {
                                Text("Open today")
                                    .font(.caption2.weight(.bold)).foregroundColor(.white)
                                    .padding(.horizontal, 8).padding(.vertical, 3)
                                    .background(Capsule().fill(Color.green))
                            } else {
                                Text("Next: \(nextOpenDay(g, from: today).name)")
                                    .font(.caption2).foregroundColor(.secondary)
                            }
                        }
                    }
                }
                if !src.enemies.isEmpty {
                    let bosses = src.enemies.filter { $0.boss }
                    let others = src.enemies.filter { !$0.boss }
                    if !bosses.isEmpty {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "crown.fill").foregroundColor(.orange).frame(width: 24)
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Bosses").font(.caption).foregroundColor(.secondary)
                                Text(bosses.map { $0.name }.joined(separator: ", ")).font(.subheadline)
                            }
                        }
                    }
                    if !others.isEmpty {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "figure.fencing").foregroundColor(.red).frame(width: 24)
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Enemies").font(.caption).foregroundColor(.secondary)
                                Text(others.map { $0.name }.joined(separator: ", ")).font(.subheadline)
                            }
                        }
                    }
                }
                if src.domain.isEmpty && src.enemies.isEmpty && src.type.hasPrefix("Local Specialty") {
                    HStack(spacing: 10) {
                        Image(systemName: "leaf.fill").foregroundColor(.green).frame(width: 24)
                        Text("Gathered in the open world – \(src.type.replacingOccurrences(of: "Local Specialty ", with: "").trimmingCharacters(in: CharacterSet(charactersIn: "()")))")
                            .font(.subheadline)
                    }
                }
            } header: {
                Text("Where to get it")
            }
        }
    }

    private func nextOpenDay(_ g: DayGroup, from today: GameDay) -> GameDay {
        let order = GameDay.ordered
        let start = order.firstIndex(of: today) ?? 0
        for i in 1...7 {
            let d = order[(start + i) % 7]
            if d != .sunday && d.includes(g) { return d }
        }
        return .sunday
    }
}
