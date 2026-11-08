import SwiftUI
import WidgetKit

/// Shows whether the widget survived signing, so problems can be pinned down.
struct WidgetStatusSection: View {
    @EnvironmentObject var store: Store
    @State private var installedKinds: [String]?

    private var appBundleID: String { Bundle.main.bundleIdentifier ?? "?" }

    private var plugin: (present: Bool, bundleID: String?) {
        guard let dir = Bundle.main.builtInPlugInsURL,
              let bundle = Bundle(url: dir.appendingPathComponent("TeyvatWidget.appex")) else { return (false, nil) }
        return (true, bundle.bundleIdentifier)
    }

    var body: some View {
        let p = plugin
        let groupOK = WidgetBridge.containerURL != nil
        Section {
            statusRow("Widget included in app", ok: p.present,
                      detail: p.present ? nil : "Your signer removed it. Turn off any \"remove extensions/plugins\" option and sign again.")
            if let id = p.bundleID {
                let prefixOK = id.hasPrefix(appBundleID + ".")
                statusRow("Widget ID matches app", ok: prefixOK,
                          detail: prefixOK ? nil : "App: \(appBundleID)\nWidget: \(id)\nThe signer changed the app's ID but not the widget's.")
            }
            statusRow("Shared data (App Group)", ok: groupOK,
                      detail: groupOK ? nil : "Not available with this certificate. The widget still works, but shows open domains instead of your characters.")
            if let kinds = installedKinds {
                statusRow("On your home or lock screen", ok: !kinds.isEmpty,
                          detail: kinds.isEmpty ? "Not added yet (or iOS hasn't registered it – try restarting the phone)." : nil)
            }
            Button("Refresh widget now") {
                store.updateWidget()
                WidgetCenter.shared.reloadAllTimelines()
                checkInstalled()
            }
        } header: {
            Text("Widget status")
        } footer: {
            Text("If the widget isn't in the Add Widget list: open this app once after installing, then restart your phone. iOS often only picks up new widgets from sideloaded apps after a restart.")
        }
        .onAppear { checkInstalled() }
    }

    private func checkInstalled() {
        WidgetCenter.shared.getCurrentConfigurations { result in
            let kinds = (try? result.get())?.map { $0.kind } ?? []
            DispatchQueue.main.async { installedKinds = kinds }
        }
    }

    private func statusRow(_ title: String, ok: Bool, detail: String?) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Image(systemName: ok ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundColor(ok ? .green : .orange)
                Text(title)
            }
            if let detail {
                Text(detail).font(.caption).foregroundColor(.secondary)
            }
        }
    }
}
