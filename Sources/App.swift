import SwiftUI
import UserNotifications

@main
struct GenshinTrackerApp: App {
    @StateObject private var store = Store()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .onChange(of: scenePhase) { phase in
                    if phase == .active {
                        store.refreshResets()
                        store.rescheduleDomainReminders()
                    }
                }
        }
    }
}

enum Theme {
    static let accents: [(id: String, name: String, color: Color)] = [
        ("gold", "Primogem Gold", Color(red: 0.85, green: 0.68, blue: 0.35)),
        ("pyro", "Pyro", Color(red: 0.94, green: 0.42, blue: 0.30)),
        ("hydro", "Hydro", Color(red: 0.25, green: 0.58, blue: 0.95)),
        ("anemo", "Anemo", Color(red: 0.25, green: 0.75, blue: 0.62)),
        ("electro", "Electro", Color(red: 0.66, green: 0.42, blue: 0.93)),
        ("dendro", "Dendro", Color(red: 0.45, green: 0.72, blue: 0.20)),
        ("cryo", "Cryo", Color(red: 0.40, green: 0.75, blue: 0.88)),
        ("geo", "Geo", Color(red: 0.88, green: 0.62, blue: 0.15)),
        ("sakura", "Sakura", Color(red: 0.93, green: 0.45, blue: 0.62)),
        ("abyss", "Abyss", Color(red: 0.45, green: 0.35, blue: 0.85)),
    ]

    static func accent(_ id: String) -> Color {
        accents.first(where: { $0.id == id })?.color ?? accents[0].color
    }

    static let appearances: [(id: String, name: String)] = [("system", "System"), ("light", "Light"), ("dark", "Dark")]

    static func scheme(_ id: String) -> ColorScheme? {
        switch id {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
}

struct RootView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label("Today", systemImage: "checklist") }
            RosterView()
                .tabItem { Label("Roster", systemImage: "person.3.fill") }
            MaterialsView()
                .tabItem { Label("Materials", systemImage: "shippingbox.fill") }
            DomainsView()
                .tabItem { Label("Domains", systemImage: "calendar") }
            MoreView()
                .tabItem { Label("More", systemImage: "ellipsis.circle.fill") }
        }
        .tint(Theme.accent(store.data.accent))
        .preferredColorScheme(Theme.scheme(store.data.appearance))
    }
}

// MARK: - Shared little views

struct ElementDot: View {
    let element: String
    var size: CGFloat = 10
    var body: some View {
        Circle()
            .fill(GameData.color(for: element))
            .frame(width: size, height: size)
    }
}

struct Stars: View {
    let count: Int
    var body: some View {
        Text(String(repeating: "★", count: max(0, min(5, count))))
            .font(.caption2)
            .foregroundColor(count >= 5 ? Color.orange : Color.purple)
    }
}

struct ProgressRow: View {
    let title: String
    let done: Int
    let total: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title).font(.subheadline.weight(.semibold))
                Spacer()
                Text("\(done)/\(total)").font(.subheadline.monospacedDigit()).foregroundColor(.secondary)
            }
            ProgressView(value: total == 0 ? 0 : Double(done), total: Double(max(total, 1)))
        }
    }
}

func formatDuration(_ seconds: TimeInterval) -> String {
    let s = max(0, Int(seconds))
    let h = s / 3600
    let m = (s % 3600) / 60
    if h > 0 { return "\(h)h \(m)m" }
    return "\(m)m"
}
