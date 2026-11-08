import SwiftUI

/// Turns everything still missing on the Materials tab into resin runs and a day-by-day schedule.
/// Drop rates are averages at the top domain tier / World Level 8 (from paimon.moe's data).
enum FarmingPlanner {
    // Average drops per run, in lowest-tier units (each tier up = 3 of the one below).
    static let bookUnitsPerRun = 2.197 + 1.977 * 3 + 0.227 * 9          // ≈ 10.2 Teachings
    static let weaponUnitsPerRun = 2.205 + 2.404 * 3 + 0.626 * 9 + 0.073 * 27   // ≈ 17.0 tier-1 items
    static let worldBossDropsPerRun = 2.55
    static let weeklyDropsPerRun = 2.0
    static let witsPerEXPBlossom = 4.5
    static let moraPerMoraBlossom = 60_000.0

    enum Kind: Hashable {
        case talentDomain(bookID: String)
        case weaponDomain(series: String)
        case worldBoss(item: String)
        case weeklyBoss(item: String)
        case expLeyLine
        case moraLeyLine
    }

    struct Task: Identifiable, Hashable {
        let kind: Kind
        var id: String { "\(kind)" }
        let title: String
        let subtitle: String
        let iconItem: String
        let days: DayGroup?          // nil = any day
        let resinPerRun: Int
        var runs: Int
        let priority: Int
        let forGroups: [String]
        var isWeekly: Bool { if case .weeklyBoss = kind { return true } else { return false } }
    }

    struct FreeItem: Identifiable, Hashable {
        var id: String { name }
        let name: String
        var remaining: Int
        let category: String
    }

    struct DayPlan: Identifiable {
        var id: Int { offset }
        let offset: Int
        let day: GameDay
        var entries: [(task: Task, runs: Int, resin: Int)]
        var resinUsed: Int { entries.reduce(0) { $0 + $1.resin } }
    }

    struct Result {
        var tasks: [Task]
        var free: [FreeItem]
        var schedule: [DayPlan]
        var totalResin: Int
        var daysToFinish: Int?
    }

    // MARK: Lookups

    private static let weaponTiers: [String: (series: String, tier: Int)] = {
        var map: [String: (series: String, tier: Int)] = [:]
        for w in WeaponCatalog.all {
            var seq: [String] = []
            for p in w.phases { if let first = p.first?.name, !seq.contains(first) { seq.append(first) } }
            guard let series = seq.first else { continue }
            for (i, name) in seq.enumerated() where map[name] == nil { map[name] = (series, i) }
        }
        return map
    }()

    private static let worldBossItems: Set<String> = {
        Set(MaterialData.byCharacter.values.compactMap { $0.ascension.first(where: { $0.count == 46 })?.name })
    }()

    private static let weeklyBossItems: Set<String> = {
        Set(MaterialData.byCharacter.values.map { $0.weeklyBoss }.filter { !$0.isEmpty })
    }()

    private static let localSpecialties: Set<String> = {
        Set(MaterialData.byCharacter.values.compactMap { $0.ascension.first(where: { $0.count == 168 })?.name })
    }()

    /// Shortfall in lowest-tier units, letting spare lower tiers be crafted upwards.
    private static func shortfallUnits(have: [Int], need: [Int]) -> Int {
        var carry = 0
        var units = 0
        var factor = 1
        for i in 0..<need.count {
            let avail = have[i] + carry
            let short = max(0, need[i] - avail)
            carry = max(0, avail - need[i]) / 3
            units += short * factor
            factor *= 3
        }
        return units
    }

    // MARK: Build

    static func build(store: Store, dailyResin: Int, includeLeyLines: Bool, startDay: GameDay) -> Result {
        let data = store.data
        let groupOrder = store.orderedGroups()
        func priority(_ groups: [String]) -> Int { groups.compactMap { groupOrder.firstIndex(of: $0) }.min() ?? Int.max }

        let open = data.goals.filter { !$0.isDone }
        var tasks: [Task] = []
        var free: [String: FreeItem] = [:]

        // Talent books, per series.
        for book in store.orderedBooks() {
            let related = data.goals.filter { book.tiers.contains($0.name) }
            guard related.contains(where: { !$0.isDone }) else { continue }
            let have = book.tiers.map { t in related.filter { $0.name == t }.reduce(0) { $0 + $1.have } }
            let need = book.tiers.map { t in related.filter { $0.name == t }.reduce(0) { $0 + $1.need } }
            let units = shortfallUnits(have: have, need: need)
            guard units > 0 else { continue }
            let groups = Array(Set(related.filter { !$0.isDone }.map { $0.group }))
            tasks.append(Task(kind: .talentDomain(bookID: book.id), title: "\(book.name) talent domain",
                              subtitle: book.domain, iconItem: book.tiers[2], days: book.group, resinPerRun: 20,
                              runs: Int((Double(units) / bookUnitsPerRun).rounded(.up)),
                              priority: priority(groups), forGroups: groups.sorted()))
        }

        // Weapon domain materials, per series.
        var seriesGoals: [String: [MaterialGoal]] = [:]
        for g in data.goals { if let t = weaponTiers[g.name] { seriesGoals[t.series, default: []].append(g) } }
        for (series, goals) in seriesGoals where goals.contains(where: { !$0.isDone }) {
            var have = [0, 0, 0, 0], need = [0, 0, 0, 0]
            for g in goals { if let t = weaponTiers[g.name] { have[t.tier] += g.have; need[t.tier] += g.need } }
            let units = shortfallUnits(have: have, need: need)
            guard units > 0 else { continue }
            let groups = Array(Set(goals.filter { !$0.isDone }.map { $0.group }))
            tasks.append(Task(kind: .weaponDomain(series: series), title: "Weapon domain: \(series)",
                              subtitle: "Weapon ascension", iconItem: series, days: WeaponCatalog.domainDays[series],
                              resinPerRun: 20, runs: Int((Double(units) / weaponUnitsPerRun).rounded(.up)),
                              priority: priority(groups), forGroups: groups.sorted()))
        }

        // Everything else, item by item.
        var bossNeed: [String: (Int, [String])] = [:]
        var weeklyNeed: [String: (Int, [String])] = [:]
        var wits = 0, mora = 0
        for g in open {
            let short = g.remaining
            if worldBossItems.contains(g.name) {
                bossNeed[g.name, default: (0, [])].0 += short
                bossNeed[g.name]!.1.append(g.group)
            } else if weeklyBossItems.contains(g.name) {
                weeklyNeed[g.name, default: (0, [])].0 += short
                weeklyNeed[g.name]!.1.append(g.group)
            } else if g.name == "Hero's Wit" {
                wits += short
            } else if g.name == "Mora" {
                mora += short
            } else if weaponTiers[g.name] != nil || store.allBooks.contains(where: { $0.tiers.contains(g.name) }) {
                continue
            } else {
                let category: String
                if g.name.hasSuffix(" Sliver") || g.name.hasSuffix(" Fragment") || g.name.hasSuffix(" Chunk") || g.name.hasSuffix(" Gemstone") {
                    category = "Gems (world bosses & crafting)"
                } else if localSpecialties.contains(g.name) {
                    category = "Local specialties"
                } else if g.name == "Mystic Enhancement Ore" || g.name == "Crown of Insight" {
                    category = "Forging, events & shops"
                } else {
                    category = "Enemy drops"
                }
                free[g.name, default: FreeItem(name: g.name, remaining: 0, category: category)].remaining += short
            }
        }
        for (item, v) in bossNeed {
            tasks.append(Task(kind: .worldBoss(item: item), title: "World boss for \(item)", subtitle: "40 resin",
                              iconItem: item, days: nil, resinPerRun: 40,
                              runs: Int((Double(v.0) / worldBossDropsPerRun).rounded(.up)),
                              priority: priority(v.1), forGroups: Array(Set(v.1)).sorted()))
        }
        for (item, v) in weeklyNeed {
            tasks.append(Task(kind: .weeklyBoss(item: item), title: "Weekly boss for \(item)", subtitle: "Once per week",
                              iconItem: item, days: nil, resinPerRun: 30,
                              runs: Int((Double(v.0) / weeklyDropsPerRun).rounded(.up)),
                              priority: priority(v.1), forGroups: Array(Set(v.1)).sorted()))
        }
        if includeLeyLines && wits > 0 {
            tasks.append(Task(kind: .expLeyLine, title: "Ley Line: Revelation (EXP)", subtitle: "Hero's Wit",
                              iconItem: "Hero's Wit", days: nil, resinPerRun: 20,
                              runs: Int((Double(wits) / witsPerEXPBlossom).rounded(.up)), priority: Int.max - 1, forGroups: []))
        }
        if includeLeyLines && mora > 0 {
            tasks.append(Task(kind: .moraLeyLine, title: "Ley Line: Wealth (Mora)", subtitle: "Mora",
                              iconItem: "Mora", days: nil, resinPerRun: 20,
                              runs: Int((Double(mora) / moraPerMoraBlossom).rounded(.up)), priority: Int.max, forGroups: []))
        }

        tasks.sort { a, b in
            if a.isWeekly != b.isWeekly { return a.isWeekly }          // weekly bosses first (cheap, limited)
            if a.priority != b.priority { return a.priority < b.priority }
            return a.title < b.title
        }

        let totalResin = tasks.reduce(0) { $0 + $1.runs * $1.resinPerRun }
        let (schedule, finish) = simulate(tasks: tasks, dailyResin: max(20, dailyResin), startDay: startDay)
        let freeSorted = free.values.sorted { a, b in a.category != b.category ? a.category < b.category : a.name < b.name }
        return Result(tasks: tasks, free: freeSorted, schedule: schedule, totalResin: totalResin, daysToFinish: finish)
    }

    /// Greedy day-by-day allocation. Talent/weapon domains only on their days (all on Sunday);
    /// each weekly boss at most once per week, first 3 weekly runs at 30 resin then 60.
    private static func simulate(tasks: [Task], dailyResin: Int, startDay: GameDay) -> ([DayPlan], Int?) {
        var remaining = tasks.map { $0.runs }
        var plans: [DayPlan] = []
        var weeklyDone: Set<String> = []
        var discountedUsed = 0
        let ordered = GameDay.ordered
        var dayIndex = ordered.firstIndex(of: startDay) ?? 0
        var finished: Int?

        for offset in 0..<180 {
            let day = ordered[dayIndex % 7]
            if day == .monday && offset > 0 { weeklyDone.removeAll(); discountedUsed = 0 }
            var budget = dailyResin
            var plan = DayPlan(offset: offset, day: day, entries: [])

            for (i, t) in tasks.enumerated() where remaining[i] > 0 {
                if let g = t.days, !day.includes(g) { continue }
                if t.isWeekly {
                    guard !weeklyDone.contains(t.id) else { continue }
                    let cost = discountedUsed < 3 ? 30 : 60
                    guard budget >= cost else { continue }
                    budget -= cost
                    remaining[i] -= 1
                    weeklyDone.insert(t.id)
                    discountedUsed += 1
                    plan.entries.append((t, 1, cost))
                } else {
                    let runs = min(remaining[i], budget / t.resinPerRun)
                    guard runs > 0 else { continue }
                    budget -= runs * t.resinPerRun
                    remaining[i] -= runs
                    plan.entries.append((t, runs, runs * t.resinPerRun))
                }
                if budget < 20 { break }
            }
            plans.append(plan)
            dayIndex += 1
            if remaining.allSatisfy({ $0 == 0 }) { finished = offset + 1; break }
        }
        return (plans, finished)
    }
}
