import SwiftUI
import WidgetKit

/// Small summary the home-screen widget reads. Shared through an App Group container;
/// if the signing setup doesn't keep App Groups, the widget falls back to built-in schedules.
struct WidgetSnapshot: Codable {
    struct Character: Codable { var name: String; var element: String; var icon: String? }
    struct DomainLine: Codable { var book: String; var domain: String; var characters: [Character] }
    struct PlanLine: Codable { var title: String; var runs: Int; var resin: Int }

    var updated: Date
    var serverOffset: Int
    var accent: String
    var days: [String: [DomainLine]]      // GameDay rawValue -> lines
    var plans: [String: [PlanLine]]       // daily reset key -> runs
    var dailyKey: String
    var checklistDone: Int
    var checklistTotal: Int
    var pulls: Int
    var pity: Int
}

enum WidgetBridge {
    static let appGroup = "group.com.sideload.genshintracker"

    static var containerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup)
    }
}

extension Store {
    /// Writes the widget snapshot (and copies cached character icons) then asks widgets to refresh.
    func updateWidget() {
        guard let container = WidgetBridge.containerURL else { return }
        let now = Date()
        let server = data.server

        // Characters to show: tracked ones still needing books, else owned ones still needing talents.
        var chars = trackedCharacters.filter { needsBooks($0) && book($0.bookID) != nil }
        if chars.isEmpty {
            chars = data.characters.filter { $0.owned && $0.needsTalents && book($0.bookID) != nil }
        }

        let iconDir = container.appendingPathComponent("icons", isDirectory: true)
        try? FileManager.default.createDirectory(at: iconDir, withIntermediateDirectories: true)
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("icons", isDirectory: true)

        func iconFile(for c: CharacterEntry) -> String? {
            for url in c.iconURLs {
                let cached = cacheDir.appendingPathComponent(url.absoluteString
                    .replacingOccurrences(of: "https://", with: "")
                    .replacingOccurrences(of: "/", with: "_"))
                guard FileManager.default.fileExists(atPath: cached.path) else { continue }
                let name = "\(c.iconName).png"
                let dest = iconDir.appendingPathComponent(name)
                if !FileManager.default.fileExists(atPath: dest.path) {
                    try? FileManager.default.copyItem(at: cached, to: dest)
                }
                return name
            }
            return nil
        }

        var days: [String: [WidgetSnapshot.DomainLine]] = [:]
        for day in GameDay.allCases {
            var lines: [WidgetSnapshot.DomainLine] = []
            for b in orderedBooks() where day.includes(b.group) {
                let users = chars.filter { $0.bookID == b.id }
                guard !users.isEmpty else { continue }
                lines.append(.init(book: b.name, domain: b.domain, characters: users.map {
                    .init(name: $0.name, element: $0.element, icon: iconFile(for: $0))
                }))
            }
            days[String(day.rawValue)] = lines
        }

        var plans: [String: [WidgetSnapshot.PlanLine]] = [:]
        let result = farmingPlan(now: now)
        for p in result.schedule.prefix(8) {
            let key = ResetClock.dailyKey(now.addingTimeInterval(Double(p.offset) * 86_400), server: server)
            plans[key] = p.entries.map { .init(title: $0.task.title, runs: $0.runs, resin: $0.resin) }
        }

        let daily = data.tasks.filter { $0.frequency == .daily }
        let snapshot = WidgetSnapshot(
            updated: now, serverOffset: server.utcOffsetHours, accent: data.accent,
            days: days, plans: plans, dailyKey: ResetClock.dailyKey(now, server: server),
            checklistDone: daily.filter { $0.done }.count, checklistTotal: daily.count,
            pulls: data.wish.totalPulls, pity: data.wish.pity)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let raw = try? encoder.encode(snapshot) {
            try? raw.write(to: container.appendingPathComponent("widget.json"), options: .atomic)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
