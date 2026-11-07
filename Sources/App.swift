import SwiftUI

@main
struct GenshinTrackerApp: App {
    @StateObject private var store = Store()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .onChange(of: scenePhase) { phase in
                    if phase == .active { store.refreshResets() }
                }
        }
    }
}

struct RootView: View {
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
        .tint(Color(red: 0.85, green: 0.68, blue: 0.35))
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
