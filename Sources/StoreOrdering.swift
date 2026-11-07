import SwiftUI

// MARK: - Ordering & collapsing

extension Store {
    /// All talent books in the user's preferred order.
    func orderedBooks() -> [TalentBook] {
        let order = data.bookOrder
        let books = allBooks
        return books.enumerated().sorted { a, b in
            let ia = order.firstIndex(of: a.element.id) ?? (order.count + a.offset)
            let ib = order.firstIndex(of: b.element.id) ?? (order.count + b.offset)
            return ia < ib
        }.map { $0.element }
    }

    /// Reorders the visible subset of books, keeping hidden ones where they were.
    func moveBooks(visible: [String], from: IndexSet, to: Int) {
        var moved = visible
        moved.move(fromOffsets: from, toOffset: to)
        var full = orderedBooks().map { $0.id }
        var it = moved.makeIterator()
        for i in full.indices where visible.contains(full[i]) {
            if let next = it.next() { full[i] = next }
        }
        data.bookOrder = full
    }

    func moveTasks(frequency: TaskFrequency, from: IndexSet, to: Int) {
        var subset = data.tasks.filter { $0.frequency == frequency }
        subset.move(fromOffsets: from, toOffset: to)
        var it = subset.makeIterator()
        var result = data.tasks
        for i in result.indices where result[i].frequency == frequency {
            if let next = it.next() { result[i] = next }
        }
        data.tasks = result
    }

    /// Material groups (usually character names) in the user's order.
    func orderedGroups() -> [String] {
        var seen: [String] = []
        for g in data.goals where !seen.contains(g.group) { seen.append(g.group) }
        let order = data.groupOrder
        return seen.enumerated().sorted { a, b in
            let ia = order.firstIndex(of: a.element) ?? (order.count + a.offset)
            let ib = order.firstIndex(of: b.element) ?? (order.count + b.offset)
            return ia < ib
        }.map { $0.element }
    }

    func moveGroups(from: IndexSet, to: Int) {
        var groups = orderedGroups()
        groups.move(fromOffsets: from, toOffset: to)
        data.groupOrder = groups
    }

    func isCollapsed(_ group: String) -> Bool { data.collapsedGroups.contains(group) }

    func toggleCollapsed(_ group: String) {
        if let i = data.collapsedGroups.firstIndex(of: group) {
            data.collapsedGroups.remove(at: i)
        } else {
            data.collapsedGroups.append(group)
        }
    }

    func setAllCollapsed(_ collapsed: Bool) {
        data.collapsedGroups = collapsed ? orderedGroups() : []
    }
}

// MARK: - Upgrading generic material names

extension Store {
    /// Replaces placeholder names from older templates ("Boss material", "Talents: common drops (tier 1)", ...)
    /// with each character's real item names, converting units where needed and merging duplicates.
    static func upgradeGenericGoals(in data: inout AppData) {
        let charactersByName = Dictionary(data.characters.map { ($0.name, $0) }, uniquingKeysWith: { a, _ in a })
        let books = GameData.books + data.customBooks
        var changed = false

        for i in data.goals.indices {
            let group = data.goals[i].group
            guard let character = charactersByName[group] else { continue }
            let mats = MaterialData.byCharacter[group]
            let book = books.first(where: { $0.id == character.bookID })
            let key = data.goals[i].name.lowercased().trimmingCharacters(in: .whitespaces)

            var newName: String?
            var multiplier = 1

            func common(_ tier: Int) -> String? {
                guard let m = mats, m.common.count == 3 else { return nil }
                return m.common[tier]
            }

            switch key {
            case "boss material":
                newName = mats?.ascension.first(where: { $0.count == 46 })?.name
            case "local specialty":
                newName = mats?.ascension.first(where: { $0.count == 168 })?.name
            case "weekly boss material":
                if let b = mats?.weeklyBoss, !b.isEmpty { newName = b }
            case "mora (thousands)":
                newName = "Mora"; multiplier = 1000
            case "hero's wit (approx.)":
                newName = "Hero's Wit"
            case "teachings (talent book)":
                newName = book?.tiers[0]
            case "guide (talent book)":
                newName = book?.tiers[1]
            case "philosophies (talent book)":
                newName = book?.tiers[2]
            default:
                // "ascension: common drops (tier 2)", "talents: common drops (tier 2)",
                // "talent common drop (tier 2)", "common drops (tier 2)"
                if key.contains("common drop"), let digit = key.last(where: { $0.isNumber }),
                   let tier = Int(String(digit)), (1...3).contains(tier) {
                    newName = common(tier - 1)
                }
            }

            if let n = newName, n != data.goals[i].name {
                data.goals[i].name = n
                if multiplier != 1 {
                    data.goals[i].have *= multiplier
                    data.goals[i].need *= multiplier
                    data.goals[i].previousHave = data.goals[i].previousHave.map { $0 * multiplier }
                }
                changed = true
            }
        }

        guard changed else { return }

        // Merge goals that now share the same group + name (e.g. ascension and talent common drops).
        var merged: [MaterialGoal] = []
        for g in data.goals {
            if let j = merged.firstIndex(where: { $0.group == g.group && $0.name == g.name }) {
                merged[j].have += g.have
                merged[j].need += g.need
                merged[j].previousHave = nil
                if merged[j].note.isEmpty { merged[j].note = g.note }
            } else {
                merged.append(g)
            }
        }
        data.goals = merged
    }
}
