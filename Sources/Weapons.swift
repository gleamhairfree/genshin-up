import SwiftUI

// MARK: - Static weapon info

struct WeaponInfo: Identifiable, Hashable {
    let id: String          // paimon.moe id
    let name: String
    let type: String
    let rarity: Int
    /// Ascension phases 1...6; each a list of (item, count) plus Mora.
    let phases: [[ItemCount]]
    let phaseMora: [Int]

    struct ItemCount: Hashable { let name: String; let count: Int }

    var maxLevel: Int { phases.count >= 6 && !phases[4].isEmpty ? 90 : 70 }
    var domainItem: String? { phases.first?.first?.name }
    var domainGroup: DayGroup? {
        guard let item = domainItem else { return nil }
        return WeaponCatalog.domainDays[item]
    }
    var iconURL: URL? { URL(string: "https://paimon.moe/images/weapons/\(id).png") }
}

enum WeaponCatalog {
    static let all: [WeaponInfo] = {
        (LiveCatalog.raw(\.weaponsRaw) ?? WeaponData.weaponsRaw).split(separator: "\n").compactMap { line -> WeaponInfo? in
            let parts = line.trimmingCharacters(in: .whitespaces)
                .split(separator: "|", omittingEmptySubsequences: false).map(String.init)
            guard parts.count >= 5 else { return nil }
            var phases: [[WeaponInfo.ItemCount]] = []
            var mora: [Int] = []
            for phase in parts[4].split(separator: ";", omittingEmptySubsequences: false) {
                let halves = phase.split(separator: "~", omittingEmptySubsequences: false)
                let items: [WeaponInfo.ItemCount] = (halves.first ?? "").split(separator: ",").compactMap { pair -> WeaponInfo.ItemCount? in
                    let kv = pair.split(separator: ":")
                    guard kv.count == 2, let n = Int(kv[1]) else { return nil }
                    return WeaponInfo.ItemCount(name: String(kv[0]), count: n)
                }
                phases.append(items)
                mora.append(halves.count > 1 ? Int(halves[1]) ?? 0 : 0)
            }
            return WeaponInfo(id: parts[3], name: parts[0], type: parts[1],
                              rarity: Int(parts[2]) ?? 3, phases: phases, phaseMora: mora)
        }
    }()

    static let byID: [String: WeaponInfo] = Dictionary(all.map { ($0.id, $0) }, uniquingKeysWith: { a, _ in a })

    static let domainDays: [String: DayGroup] = {
        var result: [String: DayGroup] = [:]
        for line in (LiveCatalog.raw(\.weaponDomainDaysRaw) ?? WeaponData.domainItemDaysRaw).split(separator: "\n") {
            let parts = line.trimmingCharacters(in: .whitespaces).split(separator: "|").map(String.init)
            if parts.count == 2, let v = Int(parts[1]), let g = DayGroup(rawValue: v) { result[parts[0]] = g }
        }
        return result
    }()
}

// MARK: - Tracked weapons

struct WeaponPlan: Codable, Hashable {
    var currentLevel: Int = 1
    var targetLevel: Int = 90
    var includeExtras: Bool = true

    init() {}

    enum CodingKeys: String, CodingKey { case currentLevel, targetLevel, includeExtras }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        currentLevel = try c.decodeIfPresent(Int.self, forKey: .currentLevel) ?? 1
        targetLevel = try c.decodeIfPresent(Int.self, forKey: .targetLevel) ?? 90
        includeExtras = try c.decodeIfPresent(Bool.self, forKey: .includeExtras) ?? true
    }
}

struct TrackedWeapon: Codable, Identifiable, Hashable {
    var id = UUID()
    var weaponID: String
    var name: String
    var level: Int = 1
    var refinement: Int = 1
    var equippedOn: String = ""
    var notes: String = ""
    /// Key of this weapon's group on the Materials tab.
    var groupName: String
    var plan: WeaponPlan? = nil

    init(info: WeaponInfo, groupName: String) {
        weaponID = info.id
        name = info.name
        self.groupName = groupName
    }

    enum CodingKeys: String, CodingKey { case id, weaponID, name, level, refinement, equippedOn, notes, groupName, plan }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        weaponID = try c.decode(String.self, forKey: .weaponID)
        name = try c.decodeIfPresent(String.self, forKey: .name) ?? weaponID
        level = try c.decodeIfPresent(Int.self, forKey: .level) ?? 1
        refinement = try c.decodeIfPresent(Int.self, forKey: .refinement) ?? 1
        equippedOn = try c.decodeIfPresent(String.self, forKey: .equippedOn) ?? ""
        notes = try c.decodeIfPresent(String.self, forKey: .notes) ?? ""
        groupName = try c.decodeIfPresent(String.self, forKey: .groupName) ?? name
        plan = try? c.decodeIfPresent(WeaponPlan.self, forKey: .plan)
    }

    var info: WeaponInfo? { WeaponCatalog.byID[weaponID] }
}

// MARK: - Calculator

enum WeaponCalculator {
    static func items(for info: WeaponInfo, plan: WeaponPlan) -> [(name: String, count: Int)] {
        let current = min(max(plan.currentLevel, 1), info.maxLevel)
        let target = min(max(plan.targetLevel, 1), info.maxLevel)
        guard target > current else { return [] }

        // (slot: 0 domain, 1 elite, 2 common; order of first appearance)
        var out: [(name: String, count: Int, slot: Int, seen: Int)] = []
        var seen = 0
        func add(_ name: String, _ n: Int, slot: Int) {
            guard n > 0 else { return }
            if let i = out.firstIndex(where: { $0.name == name }) {
                out[i].count += n
            } else {
                out.append((name, n, slot, seen)); seen += 1
            }
        }

        var mora = 0
        let from = PlanCalculator.phasesDone(atLevel: current)
        let to = PlanCalculator.phasesDone(atLevel: target)
        if to > from {
            for p in from..<min(to, info.phases.count) {
                for (slot, item) in info.phases[p].enumerated() { add(item.name, item.count, slot: slot) }
                mora += p < info.phaseMora.count ? info.phaseMora[p] : 0
            }
        }

        if info.rarity >= 3 {
            let tables = (LiveCatalog.cached?.weaponExp?.count == 3 ? LiveCatalog.cached?.weaponExp : nil) ?? WeaponData.expTables
            let table = tables[min(info.rarity, 5) - 3]
            if target - 1 < table.count && current - 1 < table.count {
                let exp = table[target - 1] - table[current - 1]
                if plan.includeExtras && exp > 0 {
                    add("Mystic Enhancement Ore", Int((Double(exp) / 10_000).rounded(.up)), slot: 3)
                    mora += exp / 10
                }
            }
        }
        if plan.includeExtras { add("Mora", mora, slot: 4) }

        return out.sorted { a, b in a.slot != b.slot ? a.slot < b.slot : a.seen < b.seen }
            .map { (name: $0.name, count: $0.count) }
    }

    static func fullPlan(for info: WeaponInfo) -> WeaponPlan {
        var p = WeaponPlan()
        p.currentLevel = 1
        p.targetLevel = info.maxLevel
        return p
    }
}

// MARK: - Store helpers

extension Store {
    func weaponForGroup(_ group: String) -> TrackedWeapon? {
        data.weapons.first(where: { $0.groupName == group })
    }

    /// A Materials group name that doesn't clash with characters or other weapons.
    func uniqueWeaponGroupName(for info: WeaponInfo, equippedOn: String) -> String {
        let taken = Set(data.characters.map { $0.name } + data.weapons.map { $0.groupName } + data.goals.map { $0.group })
        let base = equippedOn.isEmpty ? info.name : "\(info.name) (\(equippedOn))"
        if !taken.contains(base) { return base }
        var n = 2
        while taken.contains("\(base) #\(n)") { n += 1 }
        return "\(base) #\(n)"
    }

    func weaponBinding(_ id: UUID) -> Binding<TrackedWeapon> {
        Binding(
            get: { self.data.weapons.first(where: { $0.id == id }) ?? TrackedWeapon(info: WeaponCatalog.all[0], groupName: "?") },
            set: { newValue in
                if let i = self.data.weapons.firstIndex(where: { $0.id == id }) { self.data.weapons[i] = newValue }
            }
        )
    }

    func applyWeaponPlan(_ plan: WeaponPlan, to weaponID: UUID) {
        guard let i = data.weapons.firstIndex(where: { $0.id == weaponID }),
              let info = data.weapons[i].info else { return }
        let group = data.weapons[i].groupName
        let computed = WeaponCalculator.items(for: info, plan: plan)
        let fullNames = Set(WeaponCalculator.items(for: info, plan: WeaponCalculator.fullPlan(for: info)).map { $0.name })
        var newData = data
        newData.goals = Store.rewriteGoals(data.goals, group: group, computed: computed, fullNames: fullNames)
        newData.weapons[i].plan = plan
        data = newData
    }

    func removeWeaponPlan(_ weaponID: UUID) {
        guard let i = data.weapons.firstIndex(where: { $0.id == weaponID }) else { return }
        let group = data.weapons[i].groupName
        var newData = data
        newData.goals.removeAll { $0.group == group && $0.fromPlan == true }
        newData.weapons[i].plan = nil
        data = newData
    }

    func deleteWeapon(_ weaponID: UUID) {
        guard let w = data.weapons.first(where: { $0.id == weaponID }) else { return }
        var newData = data
        newData.goals.removeAll { $0.group == w.groupName && $0.fromPlan == true }
        newData.weapons.removeAll { $0.id == weaponID }
        data = newData
    }
}

// MARK: - Icon

struct WeaponIcon: View {
    let weaponID: String
    var rarity: Int = 4
    var size: CGFloat = 40

    @State private var image: UIImage?

    private var background: [Color] {
        switch rarity {
        case 5: return [Color(red: 0.62, green: 0.42, blue: 0.22), Color(red: 0.86, green: 0.62, blue: 0.32)]
        case 4: return [Color(red: 0.36, green: 0.30, blue: 0.55), Color(red: 0.56, green: 0.44, blue: 0.75)]
        case 3: return [Color(red: 0.25, green: 0.38, blue: 0.55), Color(red: 0.35, green: 0.55, blue: 0.75)]
        default: return [Color(red: 0.35, green: 0.40, blue: 0.40), Color(red: 0.50, green: 0.55, blue: 0.55)]
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.22)
                .fill(LinearGradient(colors: background, startPoint: .top, endPoint: .bottom))
            if let image {
                Image(uiImage: image).resizable().scaledToFit().padding(size * 0.06)
            } else {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: size * 0.42)).foregroundColor(.white.opacity(0.8))
            }
        }
        .frame(width: size, height: size)
        .task(id: weaponID) {
            guard let url = WeaponCatalog.byID[weaponID]?.iconURL else { return }
            image = await ImageStore.shared.image(for: [url])
        }
    }
}

/// Icon for a Materials group: character portrait, weapon, or a box.
struct GroupIcon: View {
    @EnvironmentObject var store: Store
    let group: String
    var size: CGFloat = 26

    var body: some View {
        if let c = store.data.characters.first(where: { $0.name == group }) {
            CharacterIcon(character: c, size: size)
        } else if let w = store.weaponForGroup(group) {
            WeaponIcon(weaponID: w.weaponID, rarity: w.info?.rarity ?? 4, size: size)
        } else {
            Image(systemName: "shippingbox").frame(width: size, height: size)
        }
    }
}
