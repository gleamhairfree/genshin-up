import SwiftUI
import UserNotifications

struct LiveCode: Codable, Hashable, Identifiable {
    var code: String
    var rewards: String?
    var added: String?
    var expires: String?

    var id: String { key }
    var key: String { code.uppercased() }

    var rewardList: [(name: String, count: Int)] {
        (rewards ?? "").split(separator: ";").compactMap { part in
            let bits = part.split(separator: "*", maxSplits: 1).map { String($0).trimmingCharacters(in: .whitespaces) }
            guard let name = bits.first, !name.isEmpty else { return nil }
            return (name.trimmingCharacters(in: CharacterSet(charactersIn: "\"")), bits.count > 1 ? Int(bits[1]) ?? 1 : 1)
        }
    }

    var primogems: Int { rewardList.first(where: { $0.name == "Primogem" })?.count ?? 0 }

    /// Official redemption page with the code filled in.
    var redeemURL: URL? {
        var c = URLComponents(string: "https://genshin.hoyoverse.com/en/gift")
        c?.queryItems = [URLQueryItem(name: "code", value: code)]
        return c?.url
    }
}

extension Store {
    var activeCodes: [LiveCode] { liveData?.codes ?? [] }
    var unredeemedCodes: [LiveCode] { activeCodes.filter { !data.redeemedCodes.contains($0.key) } }

    func toggleRedeemed(_ code: LiveCode) {
        if let i = data.redeemedCodes.firstIndex(of: code.key) {
            data.redeemedCodes.remove(at: i)
        } else {
            data.redeemedCodes.append(code.key)
        }
    }

    /// Posts a notification for codes not seen before (only if notifications are already allowed).
    func announceNewCodes(_ codes: [LiveCode]) {
        let keys = codes.map { $0.key }
        let firstRun = data.seenCodes.isEmpty
        let fresh = codes.filter { !data.seenCodes.contains($0.key) && !data.redeemedCodes.contains($0.key) }
        if Set(keys) != Set(data.seenCodes) { data.seenCodes = keys }
        guard !firstRun, !fresh.isEmpty else { return }
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            let content = UNMutableNotificationContent()
            content.title = fresh.count == 1 ? "New redemption code" : "\(fresh.count) new redemption codes"
            content.body = fresh.map { c in
                c.primogems > 0 ? "\(c.code) – \(c.primogems) Primogems" : c.code
            }.joined(separator: "\n")
            content.sound = .default
            UNUserNotificationCenter.current().add(UNNotificationRequest(
                identifier: "new-codes-\(Int(Date().timeIntervalSince1970))", content: content,
                trigger: UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)))
        }
    }
}

/// One code with rewards, a redeemed checkbox and a Redeem button.
struct CodeRow: View {
    @EnvironmentObject var store: Store
    let code: LiveCode
    var compact = false
    let onRedeem: (URL) -> Void

    private var redeemed: Bool { store.data.redeemedCodes.contains(code.key) }

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Button {
                withAnimation { store.toggleRedeemed(code) }
            } label: {
                Image(systemName: redeemed ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(redeemed ? .green : .secondary)
            }
            .buttonStyle(.borderless)

            VStack(alignment: .leading, spacing: 4) {
                Text(code.code)
                    .font(.system(.subheadline, design: .monospaced).weight(.bold))
                    .foregroundColor(redeemed ? .secondary : .primary)
                    .strikethrough(redeemed)
                    .textSelection(.enabled)
                let rewards = code.rewardList
                if !rewards.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(Array(rewards.prefix(compact ? 3 : 6).enumerated()), id: \.offset) { _, r in
                            HStack(spacing: 2) {
                                ItemIcon(name: r.name, size: 20)
                                Text("×\(r.count.formatted())").font(.caption2.monospacedDigit()).foregroundColor(.secondary)
                            }
                        }
                    }
                }
                if !compact, let added = code.added, !added.isEmpty {
                    Text("Found \(added)\(code.expires.map { $0.isEmpty ? "" : " · expires \($0)" } ?? "")")
                        .font(.caption2).foregroundColor(.secondary)
                }
            }
            Spacer(minLength: 4)
            if let url = code.redeemURL, !redeemed {
                Button("Redeem") {
                    UIPasteboard.general.string = code.code
                    onRedeem(url)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
        }
        .contextMenu {
            Button { UIPasteboard.general.string = code.code } label: { Label("Copy code", systemImage: "doc.on.doc") }
            if let url = code.redeemURL {
                Button { UIApplication.shared.open(url) } label: { Label("Redeem in Safari", systemImage: "safari") }
            }
            Button { store.toggleRedeemed(code) } label: {
                Label(redeemed ? "Mark as not redeemed" : "Mark as redeemed", systemImage: "checkmark.circle")
            }
        }
    }
}

struct CodesView: View {
    @EnvironmentObject var store: Store
    @State private var browserPage: BrowserPage?
    @State private var refreshing = false

    var body: some View {
        let active = store.unredeemedCodes
        let done = store.activeCodes.filter { store.data.redeemedCodes.contains($0.key) }
        List {
            Section {
                if store.activeCodes.isEmpty {
                    Text("No active codes right now. New ones are picked up automatically every few hours.")
                        .font(.footnote).foregroundColor(.secondary)
                } else if active.isEmpty {
                    Label("You've redeemed every active code.", systemImage: "checkmark.seal.fill").foregroundColor(.green)
                }
                ForEach(active) { c in CodeRow(code: c) { browserPage = BrowserPage(url: $0) } }
            } header: {
                Text("To redeem (\(active.count))")
            } footer: {
                Text("Redeem opens HoYoverse's official redemption page with the code filled in (and copies it). Log in there once – the popup remembers you. Then tick the code off.")
            }

            if !done.isEmpty {
                Section("Redeemed (\(done.count))") {
                    ForEach(done) { c in CodeRow(code: c) { browserPage = BrowserPage(url: $0) } }
                }
            }

            Section {
                Button {
                    refreshing = true
                    Task { await store.refreshLiveData(force: true); refreshing = false }
                } label: {
                    HStack {
                        Label("Check for new codes", systemImage: "arrow.clockwise")
                        Spacer()
                        if refreshing { ProgressView() }
                    }
                }
                .disabled(refreshing)
            } footer: {
                Text("Codes come from the community hoyo-codes list and the Genshin wiki, refreshed every 3 hours. Codes can expire or hit their usage limit early.")
            }
        }
        .navigationTitle("Redemption codes")
        .navigationBarTitleDisplayMode(.inline)
        .inAppBrowser($browserPage, tint: Theme.accent(store.data.accent))
    }
}

/// Compact Today section content.
struct TodayCodesCard: View {
    @EnvironmentObject var store: Store
    @State private var browserPage: BrowserPage?

    var body: some View {
        let open = store.unredeemedCodes
        Group {
            if open.isEmpty {
                Label(store.activeCodes.isEmpty ? "No active codes right now" : "All codes redeemed",
                      systemImage: "checkmark.seal").font(.subheadline).foregroundColor(.secondary)
            } else {
                ForEach(open.prefix(3)) { c in CodeRow(code: c, compact: true) { browserPage = BrowserPage(url: $0) } }
            }
            NavigationLink {
                CodesView()
            } label: {
                Text(open.count > 3 ? "All codes (\(open.count) to redeem)" : "All codes").font(.subheadline)
            }
        }
        .inAppBrowser($browserPage, tint: Theme.accent(store.data.accent))
    }
}
