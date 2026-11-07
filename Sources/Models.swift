import SwiftUI
import UserNotifications

// MARK: - Server / reset logic

enum GameServer: String, Codable, CaseIterable, Identifiable {
    case america, europe, asia, twhkmo

    var id: String { rawValue }

    var name: String {
        switch self {
        case .america: return "America (UTC-5)"
        case .europe: return "Europe (UTC+1)"
        case .asia: return "Asia (UTC+8)"
        case .twhkmo: return "TW/HK/MO (UTC+8)"
        }
    }

    var utcOffsetHours: Int {
        switch self {
        case .america: return -5
        case .europe: return 1
        case .asia, .twhkmo: return 8
        }
    }
}

enum ResetClock {
    static let utcCalendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "UTC")!
        c.firstWeekday = 2
        c.minimumDaysInFirstWeek = 4
        return c
    }()

    /// A date shifted so that its UTC components equal the "game day" (server time minus the 4:00 reset).
    static func shifted(_ date: Date, server: GameServer) -> Date {
        date.addingTimeInterval(TimeInterval((server.utcOffsetHours - 4) * 3600))
    }

    static func gameDay(_ date: Date = Date(), server: GameServer) -> GameDay {
        let weekday = utcCalendar.component(.weekday, from: shifted(date, server: server))
        return GameDay(rawValue: weekday) ?? .sunday
    }

    static func dailyKey(_ date: Date = Date(), server: GameServer) -> String {
        let c = utcCalendar.dateComponents([.year, .month, .day], from: shifted(date, server: server))
        return "\(c.year ?? 0)-\(c.month ?? 0)-\(c.day ?? 0)"
    }

    static func weeklyKey(_ date: Date = Date(), server: GameServer) -> String {
        let c = utcCalendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: shifted(date, server: server))
        return "\(c.yearForWeekOfYear ?? 0)-W\(c.weekOfYear ?? 0)"
    }

    /// Seconds until the next daily reset.
    static func secondsToNextReset(_ date: Date = Date(), server: GameServer) -> TimeInterval {
        let s = shifted(date, server: server)
        let startOfDay = utcCalendar.startOfDay(for: s)
        let next = startOfDay.addingTimeInterval(86400)
        return next.timeIntervalSince(s)
    }
}

// MARK: - Models

struct CharacterEntry: Codable, Identifiable, Hashable {
    var id: String
    var name: String
    var element: String
    var weapon: String
    var rarity: Int
    var region: String
    var bookID: String
    var owned: Bool = false
    var building: Bool = false
    var constellation: Int = 0
    var level: Int = 1
    var talents: [Int] = [1, 1, 1]
    var friendship: Int = 1
    var notes: String = ""
    var isCustom: Bool = false
    var iconName: String = ""
    var kqmSlug: String = ""
    /// True once the user picks a talent book themselves, so app updates don't overwrite it.
    var bookEdited: Bool = false

    init(id: String, name: String, element: String, weapon: String, rarity: Int, region: String, bookID: String, isCustom: Bool = false) {
        self.id = id
        self.name = name
        self.element = element
        self.weapon = weapon
        self.rarity = rarity
        self.region = region
        self.bookID = bookID
        self.isCustom = isCustom
    }

    enum CodingKeys: String, CodingKey {
        case id, name, element, weapon, rarity, region, bookID, owned, building, constellation, level, talents, friendship, notes, isCustom, iconName, kqmSlug, bookEdited
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        element = try c.decodeIfPresent(String.self, forKey: .element) ?? ""
        weapon = try c.decodeIfPresent(String.self, forKey: .weapon) ?? ""
        rarity = try c.decodeIfPresent(Int.self, forKey: .rarity) ?? 4
        region = try c.decodeIfPresent(String.self, forKey: .region) ?? "Other"
        bookID = try c.decodeIfPresent(String.self, forKey: .bookID) ?? ""
        owned = try c.decodeIfPresent(Bool.self, forKey: .owned) ?? false
        building = try c.decodeIfPresent(Bool.self, forKey: .building) ?? false
        constellation = try c.decodeIfPresent(Int.self, forKey: .constellation) ?? 0
        level = try c.decodeIfPresent(Int.self, forKey: .level) ?? 1
        talents = try c.decodeIfPresent([Int].self, forKey: .talents) ?? [1, 1, 1]
        if talents.count < 3 { talents += Array(repeating: 1, count: 3 - talents.count) }
        friendship = try c.decodeIfPresent(Int.self, forKey: .friendship) ?? 1
        notes = try c.decodeIfPresent(String.self, forKey: .notes) ?? ""
        isCustom = try c.decodeIfPresent(Bool.self, forKey: .isCustom) ?? false
        iconName = try c.decodeIfPresent(String.self, forKey: .iconName) ?? ""
        kqmSlug = try c.decodeIfPresent(String.self, forKey: .kqmSlug) ?? ""
        bookEdited = try c.decodeIfPresent(Bool.self, forKey: .bookEdited) ?? false
    }

    /// Icon candidates, best first. Images are loaded at runtime from Enka.Network's public asset host.
    var iconURLs: [URL] {
        guard !iconName.isEmpty else { return [] }
        return [
            "https://enka.network/ui/UI_AvatarIcon_\(iconName).png",
            "https://enka.network/ui/UI_AvatarIcon_Side_\(iconName).png",
        ].compactMap { URL(string: $0) }
    }

    var kqmQuickGuideURL: URL? {
        let slug = kqmSlug.trimmingCharacters(in: .whitespaces)
        guard !slug.isEmpty else { return nil }
        return URL(string: "https://keqingmains.com/q/\(slug)-quickguide/")
    }

    var kqmInfographicURL: URL? {
        let slug = kqmSlug.trimmingCharacters(in: .whitespaces)
        guard !slug.isEmpty else { return nil }
        return URL(string: "https://keqingmains.com/i/\(slug)/")
    }

    var needsTalents: Bool { talents.contains { $0 < 10 } }
    var talentSummary: String { talents.map(String.init).joined(separator: "/") }

    static let placeholder = CharacterEntry(id: "missing", name: "?", element: "", weapon: "", rarity: 4, region: "Other", bookID: "")
}

struct MaterialGoal: Codable, Identifiable, Hashable {
    var id = UUID()
    var name: String
    var group: String = ""
    var have: Int = 0
    var need: Int = 1
    var note: String = ""

    var remaining: Int { max(0, need - have) }
    var progress: Double { need <= 0 ? 1 : min(1, Double(have) / Double(need)) }
    var isDone: Bool { have >= need }
}

enum TaskFrequency: String, Codable, CaseIterable, Identifiable {
    case daily, weekly, once
    var id: String { rawValue }
    var label: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .once: return "One-off / Event"
        }
    }
}

struct TaskItem: Codable, Identifiable, Hashable {
    var id = UUID()
    var title: String
    var frequency: TaskFrequency
    var done: Bool = false
}

struct ResinState: Codable, Hashable {
    var value: Int = 0
    var recordedAt: Date = Date()
    var cap: Int = 200
    var notify: Bool = false

    static let secondsPerResin: Double = 480

    func current(at now: Date = Date()) -> Int {
        let gained = Int(max(0, now.timeIntervalSince(recordedAt)) / Self.secondsPerResin)
        return min(cap, max(value, 0) + gained)
    }

    func fullDate() -> Date? {
        if value >= cap { return nil }
        return recordedAt.addingTimeInterval(Double(cap - value) * Self.secondsPerResin)
    }
}

struct WishState: Codable, Hashable {
    var primogems: Int = 0
    var fates: Int = 0
    var starglitter: Int = 0
    var pity: Int = 0
    var guaranteed: Bool = false

    var totalPulls: Int { fates + primogems / 160 + starglitter / 5 }
    var pullsToHardPity: Int { max(0, 90 - pity) }
}

struct AppData: Codable {
    var server: GameServer = .america
    var characters: [CharacterEntry] = GameData.presetCharacters
    var goals: [MaterialGoal] = []
    var tasks: [TaskItem] = AppData.defaultTasks
    var customBooks: [TalentBook] = []
    var resin = ResinState()
    var wish = WishState()
    var lastDailyKey: String = ""
    var lastWeeklyKey: String = ""

    init() {}

    enum CodingKeys: String, CodingKey {
        case server, characters, goals, tasks, customBooks, resin, wish, lastDailyKey, lastWeeklyKey
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        server = try c.decodeIfPresent(GameServer.self, forKey: .server) ?? .america
        characters = try c.decodeIfPresent([CharacterEntry].self, forKey: .characters) ?? GameData.presetCharacters
        goals = try c.decodeIfPresent([MaterialGoal].self, forKey: .goals) ?? []
        tasks = try c.decodeIfPresent([TaskItem].self, forKey: .tasks) ?? AppData.defaultTasks
        customBooks = try c.decodeIfPresent([TalentBook].self, forKey: .customBooks) ?? []
        resin = try c.decodeIfPresent(ResinState.self, forKey: .resin) ?? ResinState()
        wish = try c.decodeIfPresent(WishState.self, forKey: .wish) ?? WishState()
        lastDailyKey = try c.decodeIfPresent(String.self, forKey: .lastDailyKey) ?? ""
        lastWeeklyKey = try c.decodeIfPresent(String.self, forKey: .lastWeeklyKey) ?? ""
    }

    static let defaultTasks: [TaskItem] = [
        TaskItem(title: "Daily Commissions (4)", frequency: .daily),
        TaskItem(title: "Claim commission reward at Adventurers' Guild", frequency: .daily),
        TaskItem(title: "Spend Original Resin", frequency: .daily),
        TaskItem(title: "Collect & resend Expeditions", frequency: .daily),
        TaskItem(title: "Serenitea Pot: realm currency & trust rank", frequency: .daily),
        TaskItem(title: "HoYoLAB daily check-in", frequency: .daily),
        TaskItem(title: "Weekly bosses (3 discounted)", frequency: .weekly),
        TaskItem(title: "Reputation requests & bounties", frequency: .weekly),
        TaskItem(title: "Parametric Transformer", frequency: .weekly),
        TaskItem(title: "Battle Pass weekly missions", frequency: .weekly),
        TaskItem(title: "Serenitea Pot: Realm Depot shop", frequency: .weekly),
        TaskItem(title: "Spiral Abyss / Imaginarium Theater", frequency: .once),
    ]
}

// MARK: - Store

final class Store: ObservableObject {
    @Published var data: AppData {
        didSet { save() }
    }

    private static var fileURL: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("genshin-tracker.json")
    }

    init() {
        var loaded = AppData()
        if let raw = try? Data(contentsOf: Store.fileURL),
           let decoded = try? Store.decoder.decode(AppData.self, from: raw) {
            loaded = decoded
        }
        Store.mergePresets(into: &loaded)
        data = loaded
        refreshResets()
    }

    static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.outputFormatting = [.prettyPrinted, .sortedKeys]
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    /// Adds any new preset characters that a newer app version ships with, without touching user edits.
    static func mergePresets(into data: inout AppData) {
        let presets = GameData.presetCharacters
        let byID = Dictionary(presets.map { ($0.id, $0) }, uniquingKeysWith: { a, _ in a })
        // Refresh game facts on characters the user already has, keeping their progress.
        for i in data.characters.indices {
            guard let p = byID[data.characters[i].id] else { continue }
            data.characters[i].name = p.name
            data.characters[i].element = p.element
            data.characters[i].weapon = p.weapon
            data.characters[i].rarity = p.rarity
            data.characters[i].region = p.region
            data.characters[i].iconName = p.iconName
            if data.characters[i].kqmSlug.isEmpty { data.characters[i].kqmSlug = p.kqmSlug }
            if !data.characters[i].bookEdited && !p.bookID.isEmpty {
                data.characters[i].bookID = p.bookID
            }
        }
        let existing = Set(data.characters.map { $0.id })
        for p in presets where !existing.contains(p.id) {
            data.characters.append(p)
        }
    }

    func save() {
        guard let raw = try? Store.encoder.encode(data) else { return }
        try? raw.write(to: Store.fileURL, options: .atomic)
    }

    // MARK: Resets

    func refreshResets(now: Date = Date()) {
        let dKey = ResetClock.dailyKey(now, server: data.server)
        let wKey = ResetClock.weeklyKey(now, server: data.server)
        var copy = data
        var changed = false
        if copy.lastDailyKey != dKey {
            for i in copy.tasks.indices where copy.tasks[i].frequency == .daily { copy.tasks[i].done = false }
            copy.lastDailyKey = dKey
            changed = true
        }
        if copy.lastWeeklyKey != wKey {
            for i in copy.tasks.indices where copy.tasks[i].frequency == .weekly { copy.tasks[i].done = false }
            copy.lastWeeklyKey = wKey
            changed = true
        }
        if changed { data = copy }
    }

    // MARK: Lookups

    var allBooks: [TalentBook] { GameData.books + data.customBooks }

    func book(_ id: String) -> TalentBook? { allBooks.first { $0.id == id } }

    func characters(using book: TalentBook) -> [CharacterEntry] {
        data.characters.filter { $0.bookID == book.id }.sorted { $0.name < $1.name }
    }

    func characterBinding(_ id: String) -> Binding<CharacterEntry> {
        Binding(
            get: { self.data.characters.first { $0.id == id } ?? CharacterEntry.placeholder },
            set: { newValue in
                if let i = self.data.characters.firstIndex(where: { $0.id == id }) {
                    self.data.characters[i] = newValue
                }
            }
        )
    }

    func goalBinding(_ id: UUID) -> Binding<MaterialGoal> {
        Binding(
            get: { self.data.goals.first { $0.id == id } ?? MaterialGoal(name: "?") },
            set: { newValue in
                if let i = self.data.goals.firstIndex(where: { $0.id == id }) {
                    self.data.goals[i] = newValue
                }
            }
        )
    }

    func taskBinding(_ id: UUID) -> Binding<TaskItem> {
        Binding(
            get: { self.data.tasks.first { $0.id == id } ?? TaskItem(title: "", frequency: .once) },
            set: { newValue in
                if let i = self.data.tasks.firstIndex(where: { $0.id == id }) {
                    self.data.tasks[i] = newValue
                }
            }
        )
    }

    func setTaskFrequency(_ id: UUID, _ f: TaskFrequency) {
        if let i = data.tasks.firstIndex(where: { $0.id == id }) {
            data.tasks[i].frequency = f
        }
    }

    func adjustGoal(_ id: UUID, by delta: Int) {
        if let i = data.goals.firstIndex(where: { $0.id == id }) {
            data.goals[i].have = max(0, data.goals[i].have + delta)
        }
    }

    func toggleOwned(_ id: String) {
        if let i = data.characters.firstIndex(where: { $0.id == id }) {
            data.characters[i].owned.toggle()
        }
    }

    func toggleTask(_ id: UUID) {
        if let i = data.tasks.firstIndex(where: { $0.id == id }) {
            data.tasks[i].done.toggle()
        }
    }

    // MARK: Backup

    func exportJSON() -> String {
        guard let raw = try? Store.encoder.encode(data) else { return "" }
        return String(data: raw, encoding: .utf8) ?? ""
    }

    @discardableResult
    func importJSON(_ text: String) -> Bool {
        guard let raw = text.data(using: .utf8),
              var decoded = try? Store.decoder.decode(AppData.self, from: raw) else { return false }
        Store.mergePresets(into: &decoded)
        data = decoded
        return true
    }

    func resetAll() {
        data = AppData()
        refreshResets()
    }

    // MARK: Resin notifications

    func scheduleResinNotification() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["resin-full"])
        guard data.resin.notify, let full = data.resin.fullDate(), full > Date() else { return }
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = "Original Resin is full"
            content.body = "Your resin has reached \(self.data.resin.cap). Time to spend it!"
            content.sound = .default
            let interval = max(5, full.timeIntervalSinceNow)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
            center.add(UNNotificationRequest(identifier: "resin-full", content: content, trigger: trigger))
        }
    }
}
