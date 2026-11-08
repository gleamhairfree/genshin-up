import SwiftUI

/// What a character should be raised to. Stored per material group (character name).
struct CharacterPlan: Codable, Hashable {
    var currentLevel: Int = 1
    var targetLevel: Int = 90
    var talentsToMax: Int = 3
    var startTalentLevel: Int = 1
    var targetTalentLevel: Int = 10
    var includeExtras: Bool = true

    init() {}

    enum CodingKeys: String, CodingKey { case currentLevel, targetLevel, talentsToMax, startTalentLevel, targetTalentLevel, includeExtras }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        currentLevel = try c.decodeIfPresent(Int.self, forKey: .currentLevel) ?? 1
        targetLevel = try c.decodeIfPresent(Int.self, forKey: .targetLevel) ?? 90
        talentsToMax = try c.decodeIfPresent(Int.self, forKey: .talentsToMax) ?? 3
        startTalentLevel = try c.decodeIfPresent(Int.self, forKey: .startTalentLevel) ?? 1
        targetTalentLevel = try c.decodeIfPresent(Int.self, forKey: .targetTalentLevel) ?? 10
        includeExtras = try c.decodeIfPresent(Bool.self, forKey: .includeExtras) ?? true
    }

    static let full: CharacterPlan = CharacterPlan()
}

enum PlanCalculator {
    /// Level caps for ascension phases 0...6.
    static let caps = [20, 40, 50, 60, 70, 80, 90]

    /// Cumulative character EXP needed to reach level N is cumulativeEXP[N - 1].
    static let cumulativeEXP: [Int] = [0,  1000,  2325,  4025,  6175,  8800,  11950,  15675,  20025,  25025,  30725,  37175,  44400,  52450,  61375,  71200,  81950,  93675,  106400,  120175,  135050,  151850,  169850,  189100,  209650,  231525,  254775,  279425,  305525,  333100,  362200,  392850,  425100,  458975,  494525,  531775,  570750,  611500,  654075,  698500,  744800,  795425,  848125,  902900,  959800,  1018875,  1080150,  1143675,  1209475,  1277600,  1348075,  1424575,  1503625,  1585275,  1669550,  1756500,  1846150,  1938550,  2033725,  2131725,  2232600,  2341550,  2453600,  2568775,  2687100,  2808625,  2933400,  3061475,  3192875,  3327650,  3465825,  3614525,  3766900,  3922975,  4082800,  4246400,  4413825,  4585125,  4760350,  4939525,  5122700,  5338925,  5581950,  5855050,  6161850,  6506450,  6893400,  7327825,  7815450,  8362650]

    /// Ascension phases already done at a given level (being exactly at 40 means phase 1 is done).
    static func phasesDone(atLevel level: Int) -> Int {
        caps.dropLast().filter { $0 < level }.count
    }

    static func ascensionLabel(forTarget level: Int) -> String {
        "Lv. \(level) · Ascension \(phasesDone(atLevel: level))"
    }

    private struct Phase {
        let gemTier: Int; let gem: Int; let boss: Int; let local: Int
        let commonTier: Int; let common: Int; let mora: Int
    }

    /// Standard per-phase ascension costs (same for every 4★ and 5★ character).
    private static let phases: [Phase] = [
        Phase(gemTier: 0, gem: 1, boss: 0, local: 3, commonTier: 0, common: 3, mora: 20_000),
        Phase(gemTier: 1, gem: 3, boss: 2, local: 10, commonTier: 0, common: 15, mora: 40_000),
        Phase(gemTier: 1, gem: 6, boss: 4, local: 20, commonTier: 1, common: 12, mora: 60_000),
        Phase(gemTier: 2, gem: 3, boss: 8, local: 30, commonTier: 1, common: 18, mora: 80_000),
        Phase(gemTier: 2, gem: 6, boss: 12, local: 45, commonTier: 2, common: 12, mora: 100_000),
        Phase(gemTier: 3, gem: 6, boss: 20, local: 60, commonTier: 2, common: 24, mora: 120_000),
    ]

    private struct TalentStep {
        let bookTier: Int; let book: Int; let commonTier: Int; let common: Int
        let weekly: Int; let crown: Int; let mora: Int
    }

    /// Cost to go from level (index + 1) to (index + 2), i.e. index 0 = Lv1->2 ... index 8 = Lv9->10.
    private static let talentSteps: [TalentStep] = [
        TalentStep(bookTier: 0, book: 3, commonTier: 0, common: 6, weekly: 0, crown: 0, mora: 12_500),
        TalentStep(bookTier: 1, book: 2, commonTier: 1, common: 3, weekly: 0, crown: 0, mora: 17_500),
        TalentStep(bookTier: 1, book: 4, commonTier: 1, common: 4, weekly: 0, crown: 0, mora: 25_000),
        TalentStep(bookTier: 1, book: 6, commonTier: 1, common: 6, weekly: 0, crown: 0, mora: 30_000),
        TalentStep(bookTier: 1, book: 9, commonTier: 1, common: 9, weekly: 0, crown: 0, mora: 37_500),
        TalentStep(bookTier: 2, book: 4, commonTier: 2, common: 4, weekly: 1, crown: 0, mora: 120_000),
        TalentStep(bookTier: 2, book: 6, commonTier: 2, common: 6, weekly: 1, crown: 0, mora: 260_000),
        TalentStep(bookTier: 2, book: 12, commonTier: 2, common: 9, weekly: 2, crown: 0, mora: 450_000),
        TalentStep(bookTier: 2, book: 16, commonTier: 2, common: 12, weekly: 2, crown: 1, mora: 700_000),
    ]

    private static func gemBase(_ element: String) -> String {
        switch element {
        case "Pyro": return "Agnidus Agate"
        case "Hydro": return "Varunada Lazurite"
        case "Anemo": return "Vayuda Turquoise"
        case "Electro": return "Vajrada Amethyst"
        case "Dendro": return "Nagadus Emerald"
        case "Cryo": return "Shivada Jade"
        case "Geo": return "Prithiva Topaz"
        default: return "Brilliant Diamond"
        }
    }

    /// Every item needed for the plan, merged, in a sensible display order.
    static func items(for character: CharacterEntry, book: TalentBook?, plan: CharacterPlan) -> [(name: String, count: Int)] {
        let mats = MaterialData.byCharacter[character.name]
        let asc = mats?.ascension ?? []

        let gemTiers = ["Sliver", "Fragment", "Chunk", "Gemstone"]
        let gem = asc.first(where: { $0.name.hasSuffix(" Sliver") })
            .map { String($0.name.dropLast(" Sliver".count)) } ?? gemBase(character.element)
        // Traveler has data but no boss drop; unknown characters get a placeholder.
        let boss: String? = asc.first(where: { $0.count == 46 })?.name ?? (mats == nil ? "Boss material" : nil)
        let local = asc.first(where: { $0.count == 168 })?.name ?? "Local specialty"
        let ascCommon: [String] = [18, 30, 36].enumerated().map { i, n in
            asc.first(where: { $0.count == n && !$0.name.contains(gem) })?.name ?? "Common drop (tier \(i + 1))"
        }
        let talentCommon: [String] = (mats?.common.count ?? 0) == 3
            ? mats!.common
            : (0..<3).map { "Talent common drop (tier \($0 + 1))" }
        let weekly = (mats?.weeklyBoss.isEmpty ?? true) ? "Weekly boss material" : mats!.weeklyBoss
        let bookNames = book?.tiers ?? ["Teachings (talent book)", "Guide (talent book)", "Philosophies (talent book)"]

        var out: [(name: String, count: Int)] = []
        func add(_ name: String, _ n: Int) {
            guard n > 0 else { return }
            if let i = out.firstIndex(where: { $0.name == name }) { out[i].count += n } else { out.append((name, n)) }
        }

        var mora = 0

        // Ascension
        let current = min(max(plan.currentLevel, 1), 90)
        let target = min(max(plan.targetLevel, 1), 90)
        if target > current {
            let from = phasesDone(atLevel: current)
            let to = phasesDone(atLevel: target)
            if to > from {
                for p in phases[from..<to] {
                    add("\(gem) \(gemTiers[p.gemTier])", p.gem)
                    if let boss { add(boss, p.boss) }
                    add(local, p.local)
                    add(ascCommon[p.commonTier], p.common)
                    mora += p.mora
                }
            }
            let exp = cumulativeEXP[target - 1] - cumulativeEXP[current - 1]
            let wits = Int((Double(exp) / 20_000).rounded(.up))
            if plan.includeExtras {
                add("Hero's Wit", wits)
                mora += exp / 5
            }
        }

        // Talents
        let count = min(max(plan.talentsToMax, 0), 3)
        let start = min(max(plan.startTalentLevel, 1), 10)
        let end = min(max(plan.targetTalentLevel, 1), 10)
        if count > 0 && start < end {
            let steps = talentSteps[(start - 1)..<(end - 1)]
            for step in steps {
                add(bookNames[step.bookTier], step.book * count)
            }
            for step in steps {
                add(talentCommon[step.commonTier], step.common * count)
            }
            for step in steps {
                add(weekly, step.weekly * count)
                add("Crown of Insight", step.crown * count)
                mora += step.mora * count
            }
        }

        if plan.includeExtras { add("Mora", mora) }

        // Group by type so related items sit together (e.g. all three common-drop tiers).
        let gemNames = gemTiers.map { "\(gem) \($0)" }
        let order: [String] = gemNames + [boss ?? "", local] + ascCommon + talentCommon + bookNames
            + [weekly, "Crown of Insight", "Hero's Wit", "Mora"]
        return out.enumerated().sorted { a, b in
            let ia = order.firstIndex(of: a.element.name) ?? (order.count + a.offset)
            let ib = order.firstIndex(of: b.element.name) ?? (order.count + b.offset)
            return ia < ib
        }.map { $0.element }
    }

    /// Display order for a character's items (used to tidy existing lists).
    static func sortOrder(for character: CharacterEntry, book: TalentBook?) -> [String] {
        items(for: character, book: book, plan: .full).map { $0.name }
    }
}

// MARK: - Applying plans to the Materials list

extension Store {
    func plan(for group: String) -> CharacterPlan? { data.plans[group] }

    /// Best guess at the plan behind goals created before plans existed.
    func inferredPlan(for character: CharacterEntry) -> CharacterPlan {
        var plan = CharacterPlan()
        let goals = data.goals.filter { $0.group == character.name }
        plan.currentLevel = max(1, character.level)
        if goals.isEmpty { return plan }
        if let crown = goals.first(where: { $0.name == "Crown of Insight" }) {
            plan.talentsToMax = min(max(crown.need, 0), 3)
        } else {
            plan.talentsToMax = 0
        }
        let hasAscension = goals.contains { $0.name.hasSuffix("Gemstone") || $0.name.hasSuffix("Sliver") }
        if hasAscension {
            plan.currentLevel = 1
            plan.targetLevel = 90
        } else {
            plan.targetLevel = max(plan.currentLevel, 20)
            plan.currentLevel = plan.targetLevel
        }
        return plan
    }

    /// Saves the plan and rewrites that character's planned items: needs are updated,
    /// new items are added, items the plan no longer needs are removed. "Have" counts and
    /// items you added by hand are kept.
    func applyPlan(_ plan: CharacterPlan, to character: CharacterEntry) {
        let group = character.name
        let theBook = self.book(character.bookID)
        let computed = PlanCalculator.items(for: character, book: theBook, plan: plan)
        // Names a full plan could produce, used to recognise items from older templates.
        let fullNames = Set(PlanCalculator.items(for: character, book: theBook, plan: .full).map { $0.name })
        var newData = data
        newData.goals = Store.rewriteGoals(data.goals, group: group, computed: computed, fullNames: fullNames)
        newData.plans[group] = plan
        data = newData
    }

    /// Updates needs for a group from a computed list, adds new items, removes planned items no
    /// longer needed, and orders the group like the computed list. Have counts and hand-added items stay.
    static func rewriteGoals(_ input: [MaterialGoal], group: String,
                             computed: [(name: String, count: Int)], fullNames: Set<String>) -> [MaterialGoal] {
        let neededNames = computed.map { $0.name }
        var goals = input
        for (name, need) in computed {
            if let i = goals.firstIndex(where: { $0.group == group && $0.name == name }) {
                goals[i].need = need
                goals[i].fromPlan = true
                goals[i].previousHave = nil
            } else {
                var g = MaterialGoal(name: name, group: group, have: 0, need: need)
                g.fromPlan = true
                goals.append(g)
            }
        }
        goals.removeAll { g in
            g.group == group && !neededNames.contains(g.name)
                && (g.fromPlan == true || (g.fromPlan == nil && fullNames.contains(g.name)))
        }
        let firstIndex = goals.firstIndex(where: { $0.group == group }) ?? goals.count
        let groupGoals = goals.filter { $0.group == group }
            .enumerated()
            .sorted { a, b in
                let ka = neededNames.firstIndex(of: a.element.name) ?? (neededNames.count + a.offset)
                let kb = neededNames.firstIndex(of: b.element.name) ?? (neededNames.count + b.offset)
                return ka < kb
            }
            .map { $0.element }
        goals.removeAll { $0.group == group }
        goals.insert(contentsOf: groupGoals, at: min(firstIndex, goals.count))
        return goals
    }

    /// Removes the plan and the items it created; hand-added items stay.
    func removePlan(for character: CharacterEntry) {
        let group = character.name
        let fullNames = Set(PlanCalculator.items(for: character, book: self.book(character.bookID), plan: .full).map { $0.name })
        var newData = data
        newData.goals.removeAll { g in
            g.group == group && (g.fromPlan == true || (g.fromPlan == nil && fullNames.contains(g.name)))
        }
        newData.plans[group] = nil
        data = newData
    }
}
