import SwiftUI
import UIKit

enum AppInfo {
    static let repo = "gleamhairfree/genshin-up"
    static let sourceURL = "https://github.com/\(repo)/releases/latest/download/source.json"
    static let releasesURL = URL(string: "https://github.com/\(repo)/releases/latest")!

    static var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
    }
    static var build: Int {
        Int(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "") ?? 0
    }
}

@MainActor
final class UpdateChecker: ObservableObject {
    enum State: Equatable {
        case idle, checking, upToDate
        case available(version: String, notes: String)
        case failed(String)
    }

    @Published var state: State = .idle

    private struct Source: Decodable {
        struct App: Decodable {
            struct Version: Decodable {
                let version: String
                let buildVersion: String?
                let localizedDescription: String?
            }
            let versions: [Version]?
            let version: String?
        }
        let apps: [App]
    }

    func check() async {
        state = .checking
        guard let url = URL(string: AppInfo.sourceURL) else { return }
        do {
            var req = URLRequest(url: url)
            req.cachePolicy = .reloadIgnoringLocalCacheData
            req.timeoutInterval = 20
            let (data, response) = try await URLSession.shared.data(for: req)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                state = .failed("Couldn't reach GitHub. Is the repository public?")
                return
            }
            let source = try JSONDecoder().decode(Source.self, from: data)
            guard let latest = source.apps.first?.versions?.first else {
                state = .failed("The update source looks empty.")
                return
            }
            let latestBuild = Int(latest.buildVersion ?? "") ?? 0
            if latestBuild > AppInfo.build {
                state = .available(version: latest.version, notes: latest.localizedDescription ?? "")
            } else {
                state = .upToDate
            }
        } catch {
            state = .failed("Couldn't check for updates: \(error.localizedDescription)")
        }
    }
}

struct UpdatesSection: View {
    @StateObject private var checker = UpdateChecker()
    @State private var copied = false

    var body: some View {
        Section {
            HStack {
                Text("Installed version")
                Spacer()
                Text("\(AppInfo.version) (\(AppInfo.build))")
                    .foregroundColor(.secondary).font(.body.monospacedDigit())
            }

            Button {
                Task { await checker.check() }
            } label: {
                HStack {
                    Label("Check for updates", systemImage: "arrow.triangle.2.circlepath")
                    Spacer()
                    if checker.state == .checking { ProgressView() }
                }
            }
            .disabled(checker.state == .checking)

            switch checker.state {
            case .upToDate:
                Label("You're on the latest version.", systemImage: "checkmark.seal.fill")
                    .foregroundColor(.green)
            case .available(let version, let notes):
                VStack(alignment: .leading, spacing: 4) {
                    Label("Version \(version) is available", systemImage: "arrow.down.app.fill")
                        .foregroundColor(.orange).font(.subheadline.weight(.semibold))
                    if !notes.isEmpty {
                        Text(notes.components(separatedBy: "\n\nCo-Authored-By").first ?? notes)
                            .font(.caption).foregroundColor(.secondary).lineLimit(6)
                    }
                    Text("Open Feather → Sources to install it.").font(.caption).foregroundColor(.secondary)
                }
                Button {
                    if let url = URL(string: "feather://") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label("Open Feather", systemImage: "arrow.up.forward.app")
                }
            case .failed(let message):
                Text(message).font(.footnote).foregroundColor(.red)
            default:
                EmptyView()
            }

            Button {
                UIPasteboard.general.string = AppInfo.sourceURL
                copied = true
            } label: {
                Label(copied ? "Copied!" : "Copy Feather source link", systemImage: "link")
            }
            Link(destination: AppInfo.releasesURL) {
                Label("Latest release on GitHub", systemImage: "safari")
            }
        } header: {
            Text("Updates")
        } footer: {
            Text("Add the source link in Feather once (Sources → +). New versions then show up there as one-tap updates, and your data is kept.")
        }
        .task { if checker.state == .idle { await checker.check() } }
    }
}
