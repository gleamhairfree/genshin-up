import SwiftUI

/// Current limited character banners (tap to show the 4★s) and the next announced banner.
struct BannerCard: View {
    @EnvironmentObject var store: Store
    @State private var expanded: Set<String> = []

    private func character(named name: String) -> CharacterEntry {
        if let c = store.data.characters.first(where: { $0.name == name }) { return c }
        return CharacterEntry(id: "banner:" + name, name: name, element: "", weapon: "", rarity: 5, region: "Other", bookID: "")
    }

    var body: some View {
        let server = store.data.server
        let now = Date()
        let banners = store.liveBanners
        let current = banners.filter { b in
            guard let s = b.startDate(server), let e = b.endDate(server) else { return false }
            return s <= now && now < e
        }
        let next = banners
            .filter { ($0.startDate(server) ?? .distantPast) > now }
            .sorted { ($0.startDate(server) ?? now) < ($1.startDate(server) ?? now) }
            .first

        VStack(alignment: .leading, spacing: 10) {
            if banners.isEmpty {
                Text("Banner info will appear after the app downloads game data. Check More → Game data.")
                    .font(.footnote).foregroundColor(.secondary)
            } else if current.isEmpty {
                Text("No limited character banner is running right now.")
                    .font(.footnote).foregroundColor(.secondary)
            }

            ForEach(current) { b in
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 10) {
                        ForEach(b.featured, id: \.self) { name in
                            VStack(spacing: 3) {
                                CharacterIcon(character: character(named: name), size: 52)
                                Text(name.split(separator: " ").last.map(String.init) ?? name)
                                    .font(.caption2.weight(.semibold)).lineLimit(1)
                            }
                            .frame(width: 60)
                        }
                        Spacer(minLength: 0)
                        VStack(alignment: .trailing, spacing: 3) {
                            if let v = b.version { Text("v\(v)").font(.caption2).foregroundColor(.secondary) }
                            if let end = b.endDate(server) {
                                Text("Ends in").font(.caption2).foregroundColor(.secondary)
                                Text(bannerCountdown(end.timeIntervalSince(now)))
                                    .font(.subheadline.monospacedDigit().weight(.semibold))
                            }
                            Image(systemName: expanded.contains(b.id) ? "chevron.up" : "chevron.down")
                                .font(.caption).foregroundColor(.secondary)
                        }
                    }
                    if expanded.contains(b.id), let rare = b.featuredRare, !rare.isEmpty {
                        HStack(spacing: 10) {
                            Text("4★").font(.caption.weight(.bold)).foregroundColor(.purple)
                            ForEach(rare, id: \.self) { name in
                                VStack(spacing: 2) {
                                    CharacterIcon(character: character(named: name), size: 36)
                                    Text(name.split(separator: " ").last.map(String.init) ?? name)
                                        .font(.system(size: 10)).lineLimit(1)
                                }
                                .frame(width: 48)
                            }
                            Spacer(minLength: 0)
                        }
                        .transition(.opacity)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if expanded.contains(b.id) { expanded.remove(b.id) } else { expanded.insert(b.id) }
                    }
                }
            }

            if !banners.isEmpty {
                Divider()
                HStack(spacing: 8) {
                    Text("Next").font(.caption.weight(.bold)).foregroundColor(.secondary)
                    if let next {
                        HStack(spacing: -6) {
                            ForEach(next.featured, id: \.self) { name in
                                CharacterIcon(character: character(named: name), size: 30)
                            }
                        }
                        Text(next.featured.joined(separator: " & ")).font(.caption.weight(.semibold)).lineLimit(1)
                        Spacer(minLength: 0)
                        if let s = next.startDate(server) {
                            Text(s.formatted(.dateTime.month(.abbreviated).day()))
                                .font(.caption).foregroundColor(.secondary)
                        }
                    } else {
                        Image(systemName: "questionmark.circle").foregroundColor(.secondary)
                        Text("Not announced yet").font(.caption).foregroundColor(.secondary)
                        Spacer(minLength: 0)
                        if let end = current.compactMap({ $0.endDate(server) }).min() {
                            Text("after \(end.formatted(.dateTime.month(.abbreviated).day()))")
                                .font(.caption).foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 2)
    }
}

/// "15 days 4 hours" for 48+ hours left, then "47h 12m".
func bannerCountdown(_ seconds: TimeInterval) -> String {
    let s = max(0, Int(seconds))
    guard s >= 48 * 3600 else { return formatDuration(seconds) }
    let days = s / 86_400
    let hours = (s % 86_400) / 3600
    let d = "\(days) day\(days == 1 ? "" : "s")"
    return hours == 0 ? d : "\(d) \(hours) hour\(hours == 1 ? "" : "s")"
}
