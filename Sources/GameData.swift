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

    /// Built-in books merged with any new ones from downloaded game data (new regions).
    static let books: [TalentBook] = {
        guard let raw = LiveCatalog.raw(\.booksRaw) else { return builtInBooks }
        var result = builtInBooks
        for line in raw.split(separator: "\n") {
            let p = line.split(separator: "|", omittingEmptySubsequences: false).map(String.init)
            guard p.count >= 5, !result.contains(where: { $0.id == p[0] }),
                  let g = Int(p[3]), let group = DayGroup(rawValue: g) else { continue }
            result.append(TalentBook(id: p[0], name: p[1], region: p[2], group: group,
                                     domain: p[4].isEmpty ? "Domain of Mastery" : p[4]))
        }
        return result
    }()

    static let builtInBooks: [TalentBook] = [
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
        TalentBook(id: "charity", name: "Charity", region: "Snezhnaya", group: .monThu, domain: "Relics of the Fallen Grace"),
        TalentBook(id: "fortitude", name: "Fortitude", region: "Snezhnaya", group: .tueFri, domain: "Relics of the Fallen Grace"),
        TalentBook(id: "glory", name: "Glory", region: "Snezhnaya", group: .wedSat, domain: "Relics of the Fallen Grace"),
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
        WeaponMaterial(name: "Pale Star Army", region: "Snezhnaya", group: .monThu, domain: "Scars of Cursed Obsession"),
        WeaponMaterial(name: "Cellared Spiritual Nectar", region: "Snezhnaya", group: .tueFri, domain: "Scars of Cursed Obsession"),
        WeaponMaterial(name: "Frost Emperor", region: "Snezhnaya", group: .wedSat, domain: "Scars of Cursed Obsession"),
    ]

    /// Name|Element|Weapon|Rarity|Region|BookID|IconName|KQMSlug
    /// Generated from Enka.Network's public game data (store/gi/avatars.json).
    static let presetCharacterData = """
    Aino|Hydro|Claymore|4|Nod-Krai|elysium|Aino|aino
    Albedo|Geo|Sword|5|Mondstadt|ballad|Albedo|albedo
    Alhaitham|Dendro|Sword|5|Sumeru|ingenuity|Alhatham|alhaitham
    Aloy|Cryo|Bow|5|Other|freedom|Aloy|aloy
    Alyosha|Electro|Polearm|4|Snezhnaya|fortitude|Alyosha|alyosha
    Amber|Pyro|Bow|4|Mondstadt|freedom|Ambor|amber
    Arataki Itto|Geo|Claymore|5|Inazuma|elegance|Itto|itto
    Arlecchino|Pyro|Polearm|5|Fontaine|order|Arlecchino|arlecchino
    Baizhu|Dendro|Catalyst|5|Liyue|gold|Baizhuer|baizhu
    Barbara|Hydro|Catalyst|4|Mondstadt|freedom|Barbara|barbara
    Beidou|Electro|Claymore|4|Liyue|gold|Beidou|beidou
    Bennett|Pyro|Sword|4|Mondstadt|resistance|Bennett|bennett
    Candace|Hydro|Polearm|4|Sumeru|admonition|Candace|candace
    Charlotte|Cryo|Catalyst|4|Fontaine|justice|Charlotte|charlotte
    Chasca|Anemo|Bow|5|Natlan|conflict|Chasca|chasca
    Chevreuse|Pyro|Polearm|4|Fontaine|order|Chevreuse|chevreuse
    Chiori|Geo|Sword|5|Inazuma|light|Chiori|chiori
    Chongyun|Cryo|Claymore|4|Liyue|diligence|Chongyun|chongyun
    Citlali|Cryo|Catalyst|5|Natlan|kindling|Citlali|citlali
    Clorinde|Electro|Sword|5|Fontaine|justice|Clorinde|clorinde
    Collei|Dendro|Bow|4|Sumeru|praxis|Collei|collei
    Columbina|Hydro|Catalyst|5|Nod-Krai|moonlight|Columbina|columbina
    Cyno|Electro|Polearm|5|Sumeru|admonition|Cyno|cyno
    Dahlia|Hydro|Sword|4|Mondstadt|ballad|Dahlia|dahlia
    Dehya|Pyro|Claymore|5|Sumeru|praxis|Dehya|dehya
    Diluc|Pyro|Claymore|5|Mondstadt|resistance|Diluc|diluc
    Diona|Cryo|Bow|4|Mondstadt|freedom|Diona|diona
    Dori|Electro|Claymore|4|Sumeru|ingenuity|Dori|dori
    Durin|Pyro|Sword|5|Nod-Krai|ballad|Durin|durin
    Emilie|Dendro|Polearm|5|Fontaine|order|Emilie|emilie
    Escoffier|Cryo|Polearm|5|Fontaine|justice|Escoffier|escoffier
    Eula|Cryo|Claymore|5|Mondstadt|resistance|Eula|eula
    Faruzan|Anemo|Bow|4|Sumeru|admonition|Faruzan|faruzan
    Fischl|Electro|Bow|4|Mondstadt|ballad|Fischl|fischl
    Flins|Electro|Polearm|5|Nod-Krai|vagrancy|Flins|flins
    Freminet|Cryo|Claymore|4|Fontaine|justice|Freminet|freminet
    Furina|Hydro|Sword|5|Fontaine|justice|Furina|furina
    Gaming|Pyro|Claymore|4|Liyue|prosperity|Gaming|gaming
    Ganyu|Cryo|Bow|5|Liyue|diligence|Ganyu|ganyu
    Gorou|Geo|Bow|4|Inazuma|light|Gorou|gorou
    Hu Tao|Pyro|Polearm|5|Liyue|diligence|Hutao|hu-tao
    Iansan|Electro|Polearm|4|Natlan|contention|Iansan|iansan
    Ifa|Anemo|Catalyst|4|Natlan|conflict|Ifa|ifa
    Illuga|Geo|Polearm|4|Nod-Krai|elysium|Illuga|illuga
    Ineffa|Electro|Polearm|5|Nod-Krai|conflict|Ineffa|ineffa
    Jahoda|Anemo|Bow|4|Nod-Krai|vagrancy|Jahoda|jahoda
    Jean|Anemo|Sword|5|Mondstadt|resistance|Qin|jean
    Kachina|Geo|Polearm|4|Natlan|conflict|Kachina|kachina
    Kaedehara Kazuha|Anemo|Sword|5|Inazuma|diligence|Kazuha|kazuha
    Kaeya|Cryo|Sword|4|Mondstadt|ballad|Kaeya|kaeya
    Kamisato Ayaka|Cryo|Sword|5|Inazuma|elegance|Ayaka|ayaka
    Kamisato Ayato|Hydro|Sword|5|Inazuma|elegance|Ayato|ayato
    Kaveh|Dendro|Claymore|4|Sumeru|ingenuity|Kaveh|kaveh
    Keqing|Electro|Sword|5|Liyue|prosperity|Keqing|keqing
    Kinich|Dendro|Claymore|5|Natlan|kindling|Kinich|kinich
    Kirara|Dendro|Sword|4|Inazuma|transience|Momoka|kirara
    Klee|Pyro|Catalyst|5|Mondstadt|freedom|Klee|klee
    Kujou Sara|Electro|Bow|4|Inazuma|elegance|Sara|sara
    Kuki Shinobu|Electro|Sword|4|Inazuma|elegance|Shinobu|shinobu
    Lan Yan|Anemo|Catalyst|4|Liyue|diligence|Lanyan|lan-yan
    Lauma|Dendro|Catalyst|5|Nod-Krai|moonlight|Lauma|lauma
    Layla|Cryo|Sword|4|Sumeru|ingenuity|Layla|layla
    Linnea|Geo|Bow|5|Nod-Krai|vagrancy|Linnea|linnea
    Lisa|Electro|Catalyst|4|Mondstadt|ballad|Lisa|lisa
    Lohen|Cryo|Polearm|5|Mondstadt|resistance|Lohen|lohen
    Lynette|Anemo|Sword|4|Fontaine|order|Linette|lynette
    Lyney|Pyro|Bow|5|Fontaine|equity|Liney|lyney
    Mavuika|Pyro|Claymore|5|Natlan|contention|Mavuika|mavuika
    Mika|Cryo|Polearm|4|Mondstadt|ballad|Mika|mika
    Mitya|Electro|Catalyst|5|Snezhnaya|charity|Mitya|mitya
    Mona|Hydro|Catalyst|5|Mondstadt|resistance|Mona|mona
    Mualani|Hydro|Catalyst|5|Natlan|contention|Mualani|mualani
    Nahida|Dendro|Catalyst|5|Sumeru|ingenuity|Nahida|nahida
    Navia|Geo|Claymore|5|Fontaine|equity|Navia|navia
    Nefer|Dendro|Catalyst|5|Nod-Krai|elysium|Nefer|nefer
    Neuvillette|Hydro|Catalyst|5|Fontaine|equity|Neuvillette|neuvillette
    Nicole|Pyro|Catalyst|5|Nod-Krai|elysium|Nicole|nicole
    Nilou|Hydro|Sword|5|Sumeru|praxis|Nilou|nilou
    Ningguang|Geo|Catalyst|4|Liyue|prosperity|Ningguang|ningguang
    Noelle|Geo|Claymore|4|Mondstadt|resistance|Noel|noelle
    Odette|Cryo|Sword|5|Snezhnaya|charity|Odette|odette
    Ororon|Electro|Bow|4|Natlan|kindling|Olorun|ororon
    Prune|Anemo|Catalyst|4|Nod-Krai|resistance|Prune|prune
    Qiqi|Cryo|Sword|5|Liyue|prosperity|Qiqi|qiqi
    Raiden Shogun|Electro|Polearm|5|Inazuma|light|Shougun|raiden
    Razor|Electro|Claymore|4|Mondstadt|resistance|Razor|razor
    Rosaria|Cryo|Polearm|4|Mondstadt|ballad|Rosaria|rosaria
    Sandrone|Cryo|Claymore|5|Nod-Krai|vagrancy|MarionetteNew|sandrone
    Sangonomiya Kokomi|Hydro|Catalyst|5|Inazuma|transience|Kokomi|kokomi
    Sayu|Anemo|Claymore|4|Inazuma|light|Sayu|sayu
    Sethos|Electro|Bow|4|Sumeru|praxis|Sethos|sethos
    Shenhe|Cryo|Polearm|5|Liyue|prosperity|Shenhe|shenhe
    Shikanoin Heizou|Anemo|Catalyst|4|Inazuma|transience|Heizo|heizou
    Sigewinne|Hydro|Bow|5|Fontaine|equity|Sigewinne|sigewinne
    Skirk|Cryo|Sword|5|Other|contention|SkirkNew|skirk
    Sucrose|Anemo|Catalyst|4|Mondstadt|freedom|Sucrose|sucrose
    Tartaglia|Hydro|Bow|5|Snezhnaya|freedom|Tartaglia|tartaglia
    Thoma|Pyro|Polearm|4|Inazuma|transience|Tohma|thoma
    Tighnari|Dendro|Bow|5|Sumeru|admonition|Tighnari|tighnari
    Traveler||Sword|5|Other||PlayerGirl|
    Valeriy|Electro|Sword|4|Snezhnaya|glory|Valeriy|valeriy
    Varesa|Electro|Catalyst|5|Natlan|conflict|Varesa|varesa
    Varka|Anemo|Claymore|5|Mondstadt|freedom|Varka|varka
    Venti|Anemo|Bow|5|Mondstadt|ballad|Venti|venti
    Vesna|Anemo|Sword|5|Snezhnaya|glory|Vesna|vesna
    Vodyanitsa|Hydro|Catalyst|5|Snezhnaya|fortitude|Vodyanitsa|vodyanitsa
    Wanderer|Anemo|Catalyst|5|Sumeru|praxis|Wanderer|wanderer
    Wriothesley|Cryo|Catalyst|5|Fontaine|order|Wriothesley|wriothesley
    Xiangling|Pyro|Polearm|4|Liyue|diligence|Xiangling|xiangling
    Xianyun|Anemo|Catalyst|5|Liyue|gold|Liuyun|xianyun
    Xiao|Anemo|Polearm|5|Liyue|prosperity|Xiao|xiao
    Xilonen|Geo|Sword|5|Natlan|kindling|Xilonen|xilonen
    Xingqiu|Hydro|Sword|4|Liyue|gold|Xingqiu|xingqiu
    Xinyan|Pyro|Claymore|4|Liyue|gold|Xinyan|xinyan
    Yae Miko|Electro|Catalyst|5|Inazuma|light|Yae|yae-miko
    Yanfei|Pyro|Catalyst|4|Liyue|gold|Feiyan|yanfei
    Yaoyao|Dendro|Polearm|4|Liyue|diligence|Yaoyao|yaoyao
    Yelan|Hydro|Bow|5|Liyue|prosperity|Yelan|yelan
    Yoimiya|Pyro|Bow|5|Inazuma|transience|Yoimiya|yoimiya
    Yumemizuki Mizuki|Anemo|Catalyst|5|Inazuma|transience|Mizuki|mizuki
    Yun Jin|Geo|Polearm|4|Liyue|diligence|Yunjin|yun-jin
    Zhongli|Geo|Polearm|5|Liyue|gold|Zhongli|zhongli
    Zibai|Geo|Sword|5|Liyue|gold|Zibai|zibai
    """

    static var presetCharacters: [CharacterEntry] {
        parseCharacters(LiveCatalog.raw(\.charactersRaw) ?? presetCharacterData)
    }

    static func parseCharacters(_ raw: String) -> [CharacterEntry] {
        raw
            .split(separator: "\n")
            .compactMap { line -> CharacterEntry? in
                let parts = line.trimmingCharacters(in: .whitespaces)
                    .split(separator: "|", omittingEmptySubsequences: false)
                    .map { String($0).trimmingCharacters(in: .whitespaces) }
                guard parts.count >= 5 else { return nil }
                let name = parts[0]
                var c = CharacterEntry(
                    id: "preset:" + name.lowercased(),
                    name: name,
                    element: parts[1],
                    weapon: parts[2],
                    rarity: Int(parts[3]) ?? 4,
                    region: parts[4],
                    bookID: parts.count > 5 ? parts[5] : ""
                )
                c.iconName = parts.count > 6 ? parts[6] : ""
                c.kqmSlug = parts.count > 7 ? parts[7] : ""
                return c
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
