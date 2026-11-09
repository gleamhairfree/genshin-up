import SwiftUI
import SafariServices

enum ExternalPages {
    static let yshelperAbyss = URL(string: "https://www.yshelper.com/#/pages/rank/rank")!

    static func akasha(uid: String) -> URL? {
        let digits = uid.filter { $0.isNumber }
        guard digits.count >= 9 else { return nil }
        return URL(string: "https://akasha.cv/profile/\(digits)")
    }
}

/// A URL that can drive `.sheet(item:)`.
struct BrowserPage: Identifiable {
    let url: URL
    var id: String { url.absoluteString }
}

/// Safari shown inside the app (with Done, share, reader mode, and the user's Safari settings).
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    var tint: Color = .accentColor

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        config.barCollapsingEnabled = true
        let vc = SFSafariViewController(url: url, configuration: config)
        vc.preferredControlTintColor = UIColor(tint)
        vc.dismissButtonStyle = .done
        return vc
    }

    func updateUIViewController(_ vc: SFSafariViewController, context: Context) {}
}

extension View {
    /// Presents a page in an in-app Safari popup.
    func inAppBrowser(_ page: Binding<BrowserPage?>, tint: Color) -> some View {
        sheet(item: page) { p in
            SafariView(url: p.url, tint: tint)
                .ignoresSafeArea()
        }
    }
}
