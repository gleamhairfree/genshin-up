import WidgetKit
import SwiftUI

// Mirrors WidgetSnapshot in the app (same JSON).
struct Snapshot: Codable {
    struct Character: Codable { var name: String; var element: String; var icon: String? }
    struct DomainLine: Codable { var book: String; var domain: String; var characters: [Character] }
    struct PlanLine: Codable { var title: String; var runs: Int; var resin: Int }

    var updated: Date
    var serverOffset: Int
    var accent: String
    var days: [String: [DomainLine]]
    var plans: [String: [PlanLine]]
    var dailyKey: String
    var checklistDone: Int
    var checklistTotal: Int
    var pulls: Int
    var pity: Int
}

let appGroup = "group.com.sideload.genshintracker"

func containerURL() -> URL? {
    FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup)
}

func loadSnapshot() -> Snapshot? {
    guard let url = containerURL()?.appendingPathComponent("widget.json"),
          let raw = try? Data(contentsOf: url) else { return nil }
    let d = JSONDecoder()
    d.dateDecodingStrategy = .iso8601
    return try? d.decode(Snapshot.self, from: raw)
}

// MARK: - Game day maths (server time minus the 4:00 reset)

enum Clock {
    static func utc() -> Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "UTC")!
        return c
    }

    static func shifted(_ date: Date, offset: Int) -> Date {
        date.addingTimeInterval(TimeInterval((offset - 4) * 3600))
    }

    /// 1 = Sunday ... 7 = Saturday
    static func weekday(_ date: Date, offset: Int) -> Int {
        utc().component(.weekday, from: shifted(date, offset: offset))
    }

    static func dailyKey(_ date: Date, offset: Int) -> String {
        let c = utc().dateComponents([.year, .month, .day], from: shifted(date, offset: offset))
        return "\(c.year ?? 0)-\(c.month ?? 0)-\(c.day ?? 0)"
    }

    static func nextReset(after date: Date, offset: Int) -> Date {
        let s = shifted(date, offset: offset)
        let start = utc().startOfDay(for: s)
        return date.addingTimeInterval(start.addingTimeInterval(86_400).timeIntervalSince(s) + 30)
    }

    static func dayName(_ weekday: Int) -> String {
        ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"][max(0, min(6, weekday - 1))]
    }
}

/// Books open per weekday when no snapshot is available.
enum FallbackBooks {
    static let groups: [[String]] = [
        ["Freedom", "Prosperity", "Transience", "Admonition", "Equity", "Contention", "Moonlight", "Charity"],
        ["Resistance", "Diligence", "Elegance", "Ingenuity", "Justice", "Kindling", "Elysium", "Fortitude"],
        ["Ballad", "Gold", "Light", "Praxis", "Order", "Conflict", "Vagrancy", "Glory"],
    ]

    static func books(weekday: Int) -> [String] {
        switch weekday {
        case 2, 5: return groups[0]
        case 3, 6: return groups[1]
        case 4, 7: return groups[2]
        default: return []   // Sunday: everything
        }
    }
}

func accentColor(_ id: String) -> Color {
    switch id {
    case "pyro": return Color(red: 0.94, green: 0.42, blue: 0.30)
    case "hydro": return Color(red: 0.25, green: 0.58, blue: 0.95)
    case "anemo": return Color(red: 0.25, green: 0.75, blue: 0.62)
    case "electro": return Color(red: 0.66, green: 0.42, blue: 0.93)
    case "dendro": return Color(red: 0.45, green: 0.72, blue: 0.20)
    case "cryo": return Color(red: 0.40, green: 0.75, blue: 0.88)
    case "geo": return Color(red: 0.88, green: 0.62, blue: 0.15)
    case "sakura": return Color(red: 0.93, green: 0.45, blue: 0.62)
    case "abyss": return Color(red: 0.45, green: 0.35, blue: 0.85)
    default: return Color(red: 0.85, green: 0.68, blue: 0.35)
    }
}

func elementColor(_ element: String) -> Color {
    switch element {
    case "Pyro": return Color(red: 0.94, green: 0.42, blue: 0.30)
    case "Hydro": return Color(red: 0.25, green: 0.62, blue: 0.95)
    case "Anemo": return Color(red: 0.36, green: 0.82, blue: 0.70)
    case "Electro": return Color(red: 0.70, green: 0.48, blue: 0.95)
    case "Dendro": return Color(red: 0.55, green: 0.80, blue: 0.25)
    case "Cryo": return Color(red: 0.55, green: 0.85, blue: 0.95)
    case "Geo": return Color(red: 0.92, green: 0.72, blue: 0.25)
    default: return .gray
    }
}

// MARK: - Timeline

struct DayEntry: TimelineEntry {
    let date: Date
    let weekday: Int
    let lines: [Snapshot.DomainLine]
    let fallbackBooks: [String]
    let plan: [Snapshot.PlanLine]
    let checklistDone: Int
    let checklistTotal: Int
    let pulls: Int?
    let accent: Color
    let hasData: Bool

    var isSunday: Bool { weekday == 1 }
    var characterCount: Int { Set(lines.flatMap { $0.characters.map { $0.name } }).count }
    var bookNames: [String] { hasData ? lines.map { $0.book } : fallbackBooks }
}

struct Provider: TimelineProvider {
    func entry(for date: Date, snapshot: Snapshot?) -> DayEntry {
        let offset = snapshot?.serverOffset ?? -5
        let weekday = Clock.weekday(date, offset: offset)
        let key = Clock.dailyKey(date, offset: offset)
        let sameDay = snapshot?.dailyKey == key
        return DayEntry(
            date: date, weekday: weekday,
            lines: snapshot?.days[String(weekday)] ?? [],
            fallbackBooks: FallbackBooks.books(weekday: weekday),
            plan: snapshot?.plans[key] ?? [],
            checklistDone: sameDay ? (snapshot?.checklistDone ?? 0) : 0,
            checklistTotal: snapshot?.checklistTotal ?? 0,
            pulls: snapshot?.pulls,
            accent: accentColor(snapshot?.accent ?? "gold"),
            hasData: snapshot != nil)
    }

    func placeholder(in context: Context) -> DayEntry {
        DayEntry(date: Date(), weekday: 2,
                 lines: [.init(book: "Freedom", domain: "Forsaken Rift", characters: [.init(name: "Klee", element: "Pyro", icon: nil)]),
                         .init(book: "Moonlight", domain: "Lightless Capital", characters: [.init(name: "Lauma", element: "Dendro", icon: nil)])],
                 fallbackBooks: [], plan: [.init(title: "Moonlight talent domain", runs: 6, resin: 120)],
                 checklistDone: 2, checklistTotal: 6, pulls: 42, accent: accentColor("gold"), hasData: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (DayEntry) -> Void) {
        completion(context.isPreview ? placeholder(in: context) : entry(for: Date(), snapshot: loadSnapshot()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DayEntry>) -> Void) {
        let snap = loadSnapshot()
        let now = Date()
        let offset = snap?.serverOffset ?? -5
        let reset = Clock.nextReset(after: now, offset: offset)
        let entries = [entry(for: now, snapshot: snap), entry(for: reset, snapshot: snap)]
        completion(Timeline(entries: entries, policy: .after(reset.addingTimeInterval(60))))
    }
}

// MARK: - Views

struct CharacterBubble: View {
    let character: Snapshot.Character
    var size: CGFloat = 22

    var body: some View {
        ZStack {
            Circle().fill(elementColor(character.element).opacity(0.35))
            if let file = character.icon, let dir = containerURL(),
               let img = UIImage(contentsOfFile: dir.appendingPathComponent("icons").appendingPathComponent(file).path) {
                Image(uiImage: img).resizable().scaledToFill().clipShape(Circle())
            } else {
                Text(String(character.name.prefix(1)))
                    .font(.system(size: size * 0.45, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .frame(width: size, height: size)
        .overlay(Circle().stroke(elementColor(character.element), lineWidth: 1.2))
    }
}

struct Header: View {
    let entry: DayEntry
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "book.fill").foregroundColor(entry.accent)
            Text(Clock.dayName(entry.weekday)).font(.caption.weight(.bold))
            Spacer(minLength: 0)
            if entry.checklistTotal > 0 {
                Image(systemName: "checklist").font(.caption2).foregroundColor(.secondary)
                Text("\(entry.checklistDone)/\(entry.checklistTotal)").font(.caption2.monospacedDigit()).foregroundColor(.secondary)
            }
        }
    }
}

struct SmallView: View {
    let entry: DayEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Header(entry: entry)
            if entry.isSunday && !entry.hasData {
                Text("Every domain is open today").font(.caption)
            } else if entry.hasData && entry.lines.isEmpty {
                Text("Nothing to farm today 🎉").font(.caption).foregroundColor(.secondary)
            } else {
                ForEach(Array(entry.bookNames.prefix(4).enumerated()), id: \.offset) { i, name in
                    HStack(spacing: 4) {
                        Text(name).font(.caption.weight(.semibold)).lineLimit(1)
                        Spacer(minLength: 0)
                        if entry.hasData, i < entry.lines.count {
                            Text("\(entry.lines[i].characters.count)").font(.caption2.monospacedDigit()).foregroundColor(.secondary)
                        }
                    }
                }
                if entry.bookNames.count > 4 {
                    Text("+\(entry.bookNames.count - 4) more").font(.caption2).foregroundColor(.secondary)
                }
            }
            Spacer(minLength: 0)
        }
    }
}

struct MediumView: View {
    let entry: DayEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Header(entry: entry)
            if entry.hasData {
                if entry.lines.isEmpty {
                    Text("None of your characters need today's books.").font(.caption).foregroundColor(.secondary)
                }
                ForEach(Array(entry.lines.prefix(3).enumerated()), id: \.offset) { _, line in
                    HStack(spacing: 6) {
                        Text(line.book).font(.caption.weight(.semibold)).frame(width: 78, alignment: .leading).lineLimit(1)
                        HStack(spacing: -4) {
                            ForEach(Array(line.characters.prefix(6).enumerated()), id: \.offset) { _, c in
                                CharacterBubble(character: c, size: 24)
                            }
                        }
                        if line.characters.count > 6 {
                            Text("+\(line.characters.count - 6)").font(.caption2).foregroundColor(.secondary)
                        }
                        Spacer(minLength: 0)
                    }
                }
            } else {
                Text(entry.isSunday ? "Sunday – every talent domain is open." : entry.fallbackBooks.joined(separator: " · "))
                    .font(.caption).lineLimit(3)
                Text("Open Teyvat Tracker to show your characters here.").font(.caption2).foregroundColor(.secondary)
            }
            Spacer(minLength: 0)
            if let pulls = entry.pulls {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles").font(.caption2).foregroundColor(.yellow)
                    Text("\(pulls) pulls saved").font(.caption2).foregroundColor(.secondary)
                    Spacer(minLength: 0)
                    if let first = entry.plan.first {
                        Text("\(first.title) ×\(first.runs)").font(.caption2).foregroundColor(.secondary).lineLimit(1)
                    }
                }
            }
        }
    }
}

struct LargeView: View {
    let entry: DayEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            MediumView(entry: entry)
            if !entry.plan.isEmpty {
                Divider()
                Text("Today's farming plan").font(.caption.weight(.bold))
                ForEach(Array(entry.plan.prefix(5).enumerated()), id: \.offset) { _, p in
                    HStack {
                        Text(p.title).font(.caption).lineLimit(1)
                        Spacer()
                        Text("×\(p.runs)").font(.caption.monospacedDigit().weight(.semibold))
                        Text("\(p.resin)").font(.caption2.monospacedDigit()).foregroundColor(.secondary).frame(width: 34, alignment: .trailing)
                    }
                }
            }
            Spacer(minLength: 0)
        }
    }
}

struct WidgetRoot: View {
    @Environment(\.widgetFamily) var family
    let entry: DayEntry

    var body: some View {
        switch family {
        case .accessoryInline:
            Text(entry.bookNames.isEmpty ? "All domains open" : entry.bookNames.prefix(3).joined(separator: " · "))
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: 0) {
                    Image(systemName: "book.fill").font(.caption2)
                    Text(entry.hasData ? "\(entry.characterCount)" : "\(entry.bookNames.count)").font(.headline)
                }
            }
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 1) {
                Text("Talent domains · \(String(Clock.dayName(entry.weekday).prefix(3)))").font(.caption.weight(.bold))
                Text(entry.bookNames.isEmpty ? "Everything is open" : entry.bookNames.prefix(3).joined(separator: ", "))
                    .font(.caption).lineLimit(2)
                if entry.hasData {
                    Text("\(entry.characterCount) of your characters").font(.caption2).foregroundColor(.secondary)
                }
            }
        case .systemLarge:
            LargeView(entry: entry).widgetBackground()
        case .systemMedium:
            MediumView(entry: entry).widgetBackground()
        default:
            SmallView(entry: entry).widgetBackground()
        }
    }
}

extension View {
    @ViewBuilder
    func widgetBackground() -> some View {
        if #available(iOS 17.0, *) {
            self.containerBackground(for: .widget) { Color(UIColor.systemBackground) }
        } else {
            self.padding().background(Color(UIColor.systemBackground))
        }
    }
}

struct TeyvatTodayWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "TeyvatToday", provider: Provider()) { entry in
            WidgetRoot(entry: entry)
        }
        .configurationDisplayName("Today in Teyvat")
        .description("Today's talent domains with your characters, plus your checklist and farming plan.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryRectangular, .accessoryCircular, .accessoryInline])
    }
}

@main
struct TeyvatWidgets: WidgetBundle {
    var body: some Widget {
        TeyvatTodayWidget()
    }
}
