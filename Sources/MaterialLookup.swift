import SwiftUI

struct CharacterMaterials {
    var ascension: [(name: String, count: Int)]
    var common: [String]      // 3 tiers, low -> high
    var weeklyBoss: String
}

extension MaterialData {
    static let byCharacter: [String: CharacterMaterials] = {
        var result: [String: CharacterMaterials] = [:]
        for line in (LiveCatalog.raw(\.materialsRaw) ?? characterMaterialsRaw).split(separator: "\n") {
            let parts = line.trimmingCharacters(in: .whitespaces)
                .split(separator: "|", omittingEmptySubsequences: false)
                .map(String.init)
            guard parts.count >= 4 else { continue }
            let asc: [(name: String, count: Int)] = parts[1].split(separator: ";").compactMap { pair -> (name: String, count: Int)? in
                let kv = pair.split(separator: ":")
                guard kv.count == 2, let n = Int(kv[1]) else { return nil }
                return (String(kv[0]), n)
            }
            let common = parts[2].split(separator: ";").map(String.init)
            result[parts[0]] = CharacterMaterials(ascension: asc, common: common, weeklyBoss: parts[3])
        }
        return result
    }()

    /// normalized display name -> paimon.moe item id
    static let itemIDs: [String: String] = {
        var result: [String: String] = [:]
        for line in liveItems.split(separator: "\n") {
            let parts = line.trimmingCharacters(in: .whitespaces)
                .split(separator: "|", omittingEmptySubsequences: false).map(String.init)
            guard parts.count >= 2 else { continue }
            result[normalize(parts[0])] = parts[1]
            result[normalize(parts[1])] = parts[1]
        }
        return result
    }()

    /// paimon.moe item id -> numeric in-game id (for fallback icon hosts)
    static let numericIDs: [String: String] = {
        var result: [String: String] = [:]
        for line in liveItems.split(separator: "\n") {
            let parts = line.trimmingCharacters(in: .whitespaces)
                .split(separator: "|", omittingEmptySubsequences: false).map(String.init)
            guard parts.count >= 3, !parts[2].isEmpty else { continue }
            result[parts[1]] = parts[2]
        }
        return result
    }()

    static var liveItems: String { LiveCatalog.raw(\.itemsRaw) ?? itemsRaw }

    static func normalize(_ s: String) -> String {
        var t = s.lowercased()
        // Drop anything in parentheses, e.g. "Mora (thousands)".
        if let r = t.range(of: "(") { t = String(t[..<r.lowerBound]) }
        return t.filter { $0.isLetter || $0.isNumber }
    }

    /// Icon sources to try in order: paimon.moe, then Enka and Yatta by in-game id.
    static func iconURLs(forItem name: String) -> [URL] {
        guard let primary = iconURL(forItem: name) else { return [] }
        var urls = [primary]
        let pid = primary.deletingPathExtension().lastPathComponent
        if let num = numericIDs[pid] {
            urls.append(contentsOf: [
                "https://enka.network/ui/UI_ItemIcon_\(num).png",
                "https://gi.yatta.moe/assets/UI/UI_ItemIcon_\(num).png",
            ].compactMap { URL(string: $0) })
        }
        return urls
    }

    static func iconURL(forItem name: String) -> URL? {
        let key = normalize(name)
        guard !key.isEmpty else { return nil }
        var id = itemIDs[key]
        if id == nil {
            // Friendly aliases for generic template names.
            let aliases: [String: String] = [
                "herowit": "heros_wit", "heroswit": "heros_wit", "exp": "heros_wit",
                "crown": "crown_of_insight", "crowns": "crown_of_insight",
                "primogem": "primogem", "primogems": "primogem",
            ]
            id = aliases[key]
        }
        guard let found = id else { return nil }
        return URL(string: "https://paimon.moe/images/items/\(found).png")
    }
}

/// Item picture for a material name, loaded from paimon.moe and cached on the phone.
struct ItemIcon: View {
    let name: String
    var size: CGFloat = 36

    @State private var image: UIImage?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.22)
                .fill(Color(.secondarySystemBackground))
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding(size * 0.06)
            } else {
                Image(systemName: "shippingbox.fill")
                    .font(.system(size: size * 0.42))
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: size, height: size)
        .task(id: name) {
            let urls = MaterialData.iconURLs(forItem: name)
            guard !urls.isEmpty else { image = nil; return }
            image = await ImageStore.shared.image(for: urls)
        }
    }
}
