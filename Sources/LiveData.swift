import SwiftUI

// MARK: - Model (all optional so an older/newer file never breaks the app)

struct LiveBanner: Codable, Identifiable, Hashable {
    var name: String
    var version: String?
    var start: String
    var end: String
    var timezoneDependent: Bool?
    var featured: [String]
    var featuredRare: [String]?

    var id: String { name + start }

    /// paimon.moe times are server-local for timezone-dependent banners, otherwise UTC+8.
    private func parse(_ s: String, server: GameServer) -> Date? {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let offset = (timezoneDependent ?? false) ? server.utcOffsetHours : 8
        f.timeZone = TimeZone(secondsFromGMT: offset * 3600)
        return f.date(from: s)
    }

    func startDate(_ server: GameServer) -> Date? { parse(start, server: server) }
    func endDate(_ server: GameServer) -> Date? { parse(end, server: server) }
}

struct LivePatch: Codable, Hashable {
    var version: String
    var start: String

    /// Patch starts are given in UTC+8.
    var startDate: Date? {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        f.timeZone = TimeZone(secondsFromGMT: 8 * 3600)
        return f.date(from: start)
    }
}

/// Per-version free income for a player who clears most content (dailies not included).
struct LiveIncome: Codable, Hashable {
    var events: Int?
    var endgame: Int?
    var exploration: Int?
    var fates: Int?
    var source: String?
}

struct LiveData: Codable {
    var schema: Int?
    var generated: String?
    var charactersRaw: String?
    var booksRaw: String?
    var materialsRaw: String?
    var itemsRaw: String?
    var weaponsRaw: String?
    var weaponDomainDaysRaw: String?
    var weaponExp: [[Int]]?
    var banners: [LiveBanner]?
    var patches: [LivePatch]?
    var income: [String: LiveIncome]?
    var notes: String?

    var generatedDate: Date? {
        guard let g = generated else { return nil }
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f.date(from: g) ?? ISO8601DateFormatter().date(from: g)
    }

    /// Basic sanity check so a broken file never replaces good data.
    var looksValid: Bool {
        (charactersRaw?.split(separator: "\n").count ?? 0) > 50 && (itemsRaw?.split(separator: "\n").count ?? 0) > 100
    }
}

// MARK: - Catalog

/// Game data downloaded from GitHub (rebuilt automatically every few hours by the repo's
/// "Update game data" workflow from Enka.Network, paimon.moe and genshin-db).
/// The copy saved on the phone is read once at launch; static tables use it, falling back to
/// the data built into the app.
enum LiveCatalog {
    static let remoteURLs: [URL] = [
        "https://raw.githubusercontent.com/\(AppInfo.repo)/main/data/live.json",
        "https://cdn.jsdelivr.net/gh/\(AppInfo.repo)@main/data/live.json",
    ].compactMap { URL(string: $0) }

    static var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("live-data.json")
    }

    static let cached: LiveData? = {
        guard let raw = try? Data(contentsOf: fileURL),
              let data = try? JSONDecoder().decode(LiveData.self, from: raw),
              data.looksValid else { return nil }
        return data
    }()

    static func raw(_ keyPath: KeyPath<LiveData, String?>) -> String? {
        guard let s = cached?[keyPath: keyPath], !s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        return s
    }
}

extension Store {
    /// Latest live data: downloaded this session, else the copy from launch.
    var liveData: LiveData? { downloadedLive ?? LiveCatalog.cached }

    var liveBanners: [LiveBanner] { liveData?.banners ?? [] }

    func refreshLiveData(force: Bool = false) async {
        let key = "liveDataLastCheck"
        let last = UserDefaults.standard.double(forKey: key)
        if !force && Date().timeIntervalSince1970 - last < 3 * 3600 { return }
        var found: (Data, LiveData)?
        for url in LiveCatalog.remoteURLs {
            var req = URLRequest(url: url)
            req.cachePolicy = .reloadIgnoringLocalCacheData
            req.timeoutInterval = 30
            let fetched = try? await URLSession.shared.data(for: req)
            if let raw = fetched?.0,
               (fetched?.1 as? HTTPURLResponse)?.statusCode == 200,
               let decoded = try? JSONDecoder().decode(LiveData.self, from: raw),
               decoded.looksValid {
                found = (raw, decoded)
                break
            }
        }
        guard let pair = found else {
            await MainActor.run { self.liveStatus = "Couldn't download game data – using the saved copy." }
            return
        }
        let raw = pair.0
        let data = pair.1
        try? raw.write(to: LiveCatalog.fileURL, options: .atomic)
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: key)
        await MainActor.run {
            self.downloadedLive = data
            self.liveStatus = nil
            // New characters can join the roster right away; other tables refresh next launch.
            if let chars = data.charactersRaw {
                var copy = self.data
                Store.mergePresets(into: &copy, presets: GameData.parseCharacters(chars))
                self.data = copy
            }
        }
    }
}

// MARK: - Settings UI

struct GameDataSection: View {
    @EnvironmentObject var store: Store
    @State private var checking = false

    var body: some View {
        Section {
            let live = store.liveData
            HStack {
                Text("Game data")
                Spacer()
                if let d = live?.generatedDate {
                    Text("Updated \(d.formatted(.relative(presentation: .named)))").foregroundColor(.secondary)
                } else {
                    Text("Built-in").foregroundColor(.secondary)
                }
            }
            if let live {
                Text("\(live.charactersRaw?.split(separator: "\n").count ?? 0) characters · \(live.weaponsRaw?.split(separator: "\n").count ?? 0) weapons · \(live.banners?.count ?? 0) recent banners")
                    .font(.caption).foregroundColor(.secondary)
            }
            if let status = store.liveStatus {
                Text(status).font(.caption).foregroundColor(.orange)
            }
            Button {
                checking = true
                Task {
                    await store.refreshLiveData(force: true)
                    checking = false
                }
            } label: {
                HStack {
                    Label("Check for new game data", systemImage: "arrow.down.circle")
                    Spacer()
                    if checking { ProgressView() }
                }
            }
            .disabled(checking)
        } header: {
            Text("Game data")
        } footer: {
            Text("Characters, talent books, materials, weapons, banners and patch dates update automatically from Enka.Network, paimon.moe and genshin-db – no reinstall needed. Banners and new characters apply right away; other changes apply the next time you open the app.")
        }
    }
}
