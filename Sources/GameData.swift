import SwiftUI

// MARK: - Day groups

enum DayGroup: Int, Codable, CaseIterable, Identifiable {
    case monThu = 0
    case tueFri = 1
    case wedSat = 2

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .monThu: return "Mon / Thu / Sun"
        case .tueFri: return "Tue / Fri / Sun"
        case .wedSat: return "Wed / Sat / Sun"
        }
    }

    var short: String {
        switch self {
        case .monThu: return "Mon/Thu"
        case .tueFri: return "Tue/Fri"
        case .wedSat: return "Wed/Sat"
        }
    }
}

/// Weekday as used by the game. 1 = Sunday ... 7 = Saturday (same as Calendar).
enum GameDay: Int, CaseIterable, Identifiable {
    case monday = 2, tuesday = 3, wednesday = 4, thursday = 5, friday = 6, saturday = 7, sunday = 1

    var id: Int { rawValue }

    static var ordered: [GameDay] { [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday] }

    var name: String {
        switch self {
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        case .sunday: return "Sunday"
        }
    }

    var short: String { String(name.prefix(3)) }

    /// nil means Sunday: everything is available.
    var group: DayGroup? {
        switch self {
        case .monday, .thursday: return .monThu
        case .tuesday, .friday: return .tueFri
        case .wednesday, .saturday: return .wedSat
        case .sunday: return nil
        }
    }

    func includes(_ g: DayGroup) -> Bool {
        guard let mine = group else { return true }
        return mine == g
    }
}

// MARK: - Books & weapon materials

struct TalentBook: Codable, Identifiable, Hashable {
    var id: String
    var name: String
    var region: String
    var group: DayGroup
    var domain: String
    var isCustom: Bool = false

    var tiers: [String] {
        ["Teachings of \(name)", "Guide to \(name)", "Philosophies of \(name)"]
    }
}

struct WeaponMaterial: Identifiable, Hashable {
    var id: String { name }
    var name: String
    var region: String
    var group: DayGroup
    var domain: String
}

enum GameData {
    static let regions = ["Mondstadt", "Liyue", "Inazuma", "Sumeru", "Fontaine", "Natlan", "Nod-Krai", "Snezhnaya", "Other"]
    static let elements = ["Pyro", "Hydro", "Anemo", "Electro", "Dendro", "Cryo", "Geo"]
    static let weapons = ["Sword", "Claymore", "Polearm", "Bow", "Catalyst"]

    static let books: [TalentBook] = [
        TalentBook(id: "freedom", name: "Freedom", region: "Mondstadt", group: .monThu, domain: "Forsaken Rift"),
        TalentBook(id: "resistance", name: "Resistance", region: "Mondstadt", group: .tueFri, domain: "Forsaken Rift"),
        TalentBook(id: "ballad", name: "Ballad", region: "Mondstadt", group: .wedSat, domain: "Forsaken Rift"),
        TalentBook(id: "prosperity", name: "Prosperity", region: "Liyue", group: .monThu, domain: "Taishan Mansion"),
        TalentBook(id: "diligence", name: "Diligence", region: "Liyue", group: .tueFri, domain: "Taishan Mansion"),
        TalentBook(id: "gold", name: "Gold", region: "Liyue", group: .wedSat, domain: "Taishan Mansion"),
        TalentBook(id: "transience", name: "Transience", region: "Inazuma", group: .monThu, domain: "Violet Court"),
        TalentBook(id: "elegance", name: "Elegance", region: "Inazuma", group: .tueFri, domain: "Violet Court"),
        TalentBook(id: "light", name: "Light", region: "Inazuma", group: .wedSat, domain: "Violet Court"),
        TalentBook(id: "admonition", name: "Admonition", region: "Sumeru", group: .monThu, domain: "Steeple of Ignorance"),
        TalentBook(id: "ingenuity", name: "Ingenuity", region: "Sumeru", group: .tueFri, domain: "Steeple of Ignorance"),
        TalentBook(id: "praxis", name: "Praxis", region: "Sumeru", group: .wedSat, domain: "Steeple of Ignorance"),
        TalentBook(id: "equity", name: "Equity", region: "Fontaine", group: .monThu, domain: "Pale Forgotten Glory"),
        TalentBook(id: "justice", name: "Justice", region: "Fontaine", group: .tueFri, domain: "Pale Forgotten Glory"),
        TalentBook(id: "order", name: "Order", region: "Fontaine", group: .wedSat, domain: "Pale Forgotten Glory"),
        TalentBook(id: "contention", name: "Contention", region: "Natlan", group: .monThu, domain: "Blazing Ruins"),
        TalentBook(id: "kindling", name: "Kindling", region: "Natlan", group: .tueFri, domain: "Blazing Ruins"),
        TalentBook(id: "conflict", name: "Conflict", region: "Natlan", group: .wedSat, domain: "Blazing Ruins"),
        TalentBook(id: "moonlight", name: "Moonlight", region: "Nod-Krai", group: .monThu, domain: "Lightless Capital"),
        TalentBook(id: "elysium", name: "Elysium", region: "Nod-Krai", group: .tueFri, domain: "Lightless Capital"),
        TalentBook(id: "vagrancy", name: "Vagrancy", region: "Nod-Krai", group: .wedSat, domain: "Lightless Capital"),
    ]

    static let weaponMaterials: [WeaponMaterial] = [
        WeaponMaterial(name: "Decarabian", region: "Mondstadt", group: .monThu, domain: "Cecilia Garden"),
        WeaponMaterial(name: "Boreal Wolf", region: "Mondstadt", group: .tueFri, domain: "Cecilia Garden"),
        WeaponMaterial(name: "Dandelion Gladiator", region: "Mondstadt", group: .wedSat, domain: "Cecilia Garden"),
        WeaponMaterial(name: "Guyun", region: "Liyue", group: .monThu, domain: "Hidden Palace of Lianshan Formula"),
        WeaponMaterial(name: "Mist Veiled Elixir", region: "Liyue", group: .tueFri, domain: "Hidden Palace of Lianshan Formula"),
        WeaponMaterial(name: "Aerosiderite", region: "Liyue", group: .wedSat, domain: "Hidden Palace of Lianshan Formula"),
        WeaponMaterial(name: "Distant Sea", region: "Inazuma", group: .monThu, domain: "Court of Flowing Sand"),
        WeaponMaterial(name: "Narukami", region: "Inazuma", group: .tueFri, domain: "Court of Flowing Sand"),
        WeaponMaterial(name: "Oni Mask", region: "Inazuma", group: .wedSat, domain: "Court of Flowing Sand"),
        WeaponMaterial(name: "Forest Dew", region: "Sumeru", group: .monThu, domain: "Tower of Abject Pride"),
        WeaponMaterial(name: "Oasis Garden", region: "Sumeru", group: .tueFri, domain: "Tower of Abject Pride"),
        WeaponMaterial(name: "Scorching Might", region: "Sumeru", group: .wedSat, domain: "Tower of Abject Pride"),
        WeaponMaterial(name: "Ancient Chord", region: "Fontaine", group: .monThu, domain: "Echoes of the Deep Tides"),
        WeaponMaterial(name: "Pure Sacred Dewdrop", region: "Fontaine", group: .tueFri, domain: "Echoes of the Deep Tides"),
        WeaponMaterial(name: "Pristine Sea", region: "Fontaine", group: .wedSat, domain: "Echoes of the Deep Tides"),
        WeaponMaterial(name: "Blazing Sacrificial Heart", region: "Natlan", group: .monThu, domain: "Ancient Watchtower"),
        WeaponMaterial(name: "Sacred Lord", region: "Natlan", group: .tueFri, domain: "Ancient Watchtower"),
        WeaponMaterial(name: "Night-Wind", region: "Natlan", group: .wedSat, domain: "Ancient Watchtower"),
        WeaponMaterial(name: "Artful Device", region: "Nod-Krai", group: .monThu, domain: "Lost Mooncourt"),
        WeaponMaterial(name: "Long Night Flint", region: "Nod-Krai", group: .tueFri, domain: "Lost Mooncourt"),
        WeaponMaterial(name: "Far-North Scions", region: "Nod-Krai", group: .wedSat, domain: "Lost Mooncourt"),
    ]

    /// Name|Element|Weapon|Rarity|Region|BookID  (book may be blank = set it yourself in the app)
    static let presetCharacterData = """
    Albedo|Geo|Sword|5|Mondstadt|ballad
    Amber|Pyro|Bow|4|Mondstadt|freedom
    Barbara|Hydro|Catalyst|4|Mondstadt|freedom
    Bennett|Pyro|Sword|4|Mondstadt|resistance
    Diluc|Pyro|Claymore|5|Mondstadt|resistance
    Diona|Cryo|Bow|4|Mondstadt|freedom
    Eula|Cryo|Claymore|5|Mondstadt|resistance
    Fischl|Electro|Bow|4|Mondstadt|ballad
    Jean|Anemo|Sword|5|Mondstadt|resistance
    Kaeya|Cryo|Sword|4|Mondstadt|ballad
    Klee|Pyro|Catalyst|5|Mondstadt|freedom
    Lisa|Electro|Catalyst|4|Mondstadt|ballad
    Mika|Cryo|Polearm|4|Mondstadt|
    Mona|Hydro|Catalyst|5|Mondstadt|resistance
    Noelle|Geo|Claymore|4|Mondstadt|resistance
    Razor|Electro|Claymore|4|Mondstadt|ballad
    Rosaria|Cryo|Polearm|4|Mondstadt|ballad
    Sucrose|Anemo|Catalyst|4|Mondstadt|freedom
    Venti|Anemo|Bow|5|Mondstadt|ballad
    Baizhu|Dendro|Catalyst|5|Liyue|gold
    Beidou|Electro|Claymore|4|Liyue|gold
    Chongyun|Cryo|Claymore|4|Liyue|diligence
    Gaming|Pyro|Claymore|4|Liyue|prosperity
    Ganyu|Cryo|Bow|5|Liyue|diligence
    Hu Tao|Pyro|Polearm|5|Liyue|diligence
    Keqing|Electro|Sword|5|Liyue|prosperity
    Lan Yan|Anemo|Catalyst|4|Liyue|
    Ningguang|Geo|Catalyst|4|Liyue|prosperity
    Qiqi|Cryo|Sword|5|Liyue|prosperity
    Shenhe|Cryo|Polearm|5|Liyue|prosperity
    Xiangling|Pyro|Polearm|4|Liyue|diligence
    Xianyun|Anemo|Catalyst|5|Liyue|gold
    Xiao|Anemo|Polearm|5|Liyue|prosperity
    Xingqiu|Hydro|Sword|4|Liyue|gold
    Xinyan|Pyro|Claymore|4|Liyue|gold
    Yanfei|Pyro|Catalyst|4|Liyue|gold
    Yaoyao|Dendro|Polearm|4|Liyue|diligence
    Yelan|Hydro|Bow|5|Liyue|prosperity
    Yun Jin|Geo|Polearm|4|Liyue|diligence
    Zhongli|Geo|Polearm|5|Liyue|gold
    Arataki Itto|Geo|Claymore|5|Inazuma|elegance
    Chiori|Geo|Sword|5|Inazuma|
    Gorou|Geo|Bow|4|Inazuma|light
    Kaedehara Kazuha|Anemo|Sword|5|Inazuma|diligence
    Kamisato Ayaka|Cryo|Sword|5|Inazuma|elegance
    Kamisato Ayato|Hydro|Sword|5|Inazuma|elegance
    Kirara|Dendro|Sword|4|Inazuma|transience
    Kujou Sara|Electro|Bow|4|Inazuma|elegance
    Kuki Shinobu|Electro|Sword|4|Inazuma|elegance
    Raiden Shogun|Electro|Polearm|5|Inazuma|light
    Sangonomiya Kokomi|Hydro|Catalyst|5|Inazuma|transience
    Sayu|Anemo|Claymore|4|Inazuma|light
    Shikanoin Heizou|Anemo|Catalyst|4|Inazuma|transience
    Thoma|Pyro|Polearm|4|Inazuma|transience
    Yae Miko|Electro|Catalyst|5|Inazuma|light
    Yoimiya|Pyro|Bow|5|Inazuma|transience
    Yumemizuki Mizuki|Anemo|Catalyst|5|Inazuma|
    Alhaitham|Dendro|Sword|5|Sumeru|ingenuity
    Candace|Hydro|Polearm|4|Sumeru|admonition
    Collei|Dendro|Bow|4|Sumeru|praxis
    Cyno|Electro|Polearm|5|Sumeru|admonition
    Dehya|Pyro|Claymore|5|Sumeru|praxis
    Dori|Electro|Claymore|4|Sumeru|ingenuity
    Faruzan|Anemo|Bow|4|Sumeru|admonition
    Kaveh|Dendro|Claymore|4|Sumeru|ingenuity
    Layla|Cryo|Sword|4|Sumeru|ingenuity
    Nahida|Dendro|Catalyst|5|Sumeru|ingenuity
    Nilou|Hydro|Sword|5|Sumeru|praxis
    Sethos|Electro|Bow|4|Sumeru|
    Tighnari|Dendro|Bow|5|Sumeru|admonition
    Wanderer|Anemo|Catalyst|5|Sumeru|praxis
    Arlecchino|Pyro|Polearm|5|Fontaine|order
    Charlotte|Cryo|Catalyst|4|Fontaine|
    Chevreuse|Pyro|Polearm|4|Fontaine|order
    Clorinde|Electro|Sword|5|Fontaine|
    Emilie|Dendro|Polearm|5|Fontaine|
    Escoffier|Cryo|Polearm|5|Fontaine|
    Freminet|Cryo|Claymore|4|Fontaine|
    Furina|Hydro|Sword|5|Fontaine|justice
    Lynette|Anemo|Sword|4|Fontaine|order
    Lyney|Pyro|Bow|5|Fontaine|equity
    Navia|Geo|Claymore|5|Fontaine|
    Neuvillette|Hydro|Catalyst|5|Fontaine|equity
    Sigewinne|Hydro|Bow|5|Fontaine|
    Wriothesley|Cryo|Catalyst|5|Fontaine|order
    Chasca|Anemo|Bow|5|Natlan|conflict
    Citlali|Cryo|Catalyst|5|Natlan|
    Iansan|Electro|Polearm|4|Natlan|
    Ifa|Anemo|Catalyst|4|Natlan|conflict
    Kachina|Geo|Polearm|4|Natlan|conflict
    Kinich|Dendro|Claymore|5|Natlan|kindling
    Mavuika|Pyro|Claymore|5|Natlan|
    Mualani|Hydro|Catalyst|5|Natlan|
    Ororon|Electro|Bow|4|Natlan|kindling
    Varesa|Electro|Catalyst|5|Natlan|conflict
    Xilonen|Geo|Sword|5|Natlan|kindling
    Aino|Hydro|Claymore|4|Nod-Krai|elysium
    Durin|Pyro|Sword|5|Nod-Krai|ballad
    Flins|Electro|Polearm|5|Nod-Krai|vagrancy
    Ineffa|Electro|Polearm|5|Nod-Krai|
    Lauma|Dendro|Catalyst|5|Nod-Krai|moonlight
    Nefer|Dendro|Catalyst|5|Nod-Krai|elysium
    Odette|Cryo|Sword|5|Snezhnaya|
    Alyosha|Electro|Polearm|4|Snezhnaya|
    Tartaglia|Hydro|Bow|5|Snezhnaya|freedom
    Aloy|Cryo|Bow|5|Other|freedom
    Skirk|Cryo|Sword|5|Other|
    """

    static var presetCharacters: [CharacterEntry] {
        presetCharacterData
            .split(separator: "\n")
            .compactMap { line -> CharacterEntry? in
                let parts = line.trimmingCharacters(in: .whitespaces)
                    .split(separator: "|", omittingEmptySubsequences: false)
                    .map { String($0).trimmingCharacters(in: .whitespaces) }
                guard parts.count >= 5 else { return nil }
                let name = parts[0]
                return CharacterEntry(
                    id: "preset:" + name.lowercased(),
                    name: name,
                    element: parts[1],
                    weapon: parts[2],
                    rarity: Int(parts[3]) ?? 4,
                    region: parts[4],
                    bookID: parts.count > 5 ? parts[5] : ""
                )
            }
    }

    static func color(for element: String) -> Color {
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

    // MARK: Material totals used by templates

    /// One talent, level 1 -> 10.
    static let talentTotals: [(tier: Int, count: Int)] = [(0, 9), (1, 63), (2, 114)]
    static let talentExtras: [(String, Int)] = [
        ("Common drops (tier 1)", 18),
        ("Common drops (tier 2)", 66),
        ("Common drops (tier 3)", 93),
        ("Weekly boss material", 6),
        ("Crown of Insight", 1),
        ("Mora (thousands)", 1653),
    ]
    /// Character ascension, level 1 -> 90.
    static let ascensionTotals: [(String, Int)] = [
        ("Gem Sliver", 1),
        ("Gem Fragment", 9),
        ("Gem Chunk", 9),
        ("Gemstone", 6),
        ("Boss material", 46),
        ("Local specialty", 168),
        ("Common drops (tier 1)", 18),
        ("Common drops (tier 2)", 30),
        ("Common drops (tier 3)", 36),
        ("Mora (thousands)", 420),
        ("Hero's Wit (approx.)", 419),
    ]
}
