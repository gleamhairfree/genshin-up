import SwiftUI

// MARK: - Patch calendar

/// Versions last 42 days. Anchored on the latest started version from live game data
/// (fallback: 7.2 on Nov 4 2026, 06:00 UTC+8).
enum PatchCalendar {
    static let length: TimeInterval = 42 * 86_400

    private struct Anchor { let major: Int; let minor: Int; let start: Date }

    private static let anchor: Anchor = {
        let fallback = Anchor(major: 7, minor: 2, start: Date(timeIntervalSince1970: 1_793_743_200))
        guard let patches = LiveCatalog.cached?.patches else { return fallback }
        let now = Date()
        let started = patches.compactMap { p -> Anchor? in
            let parts = p.version.split(separator: ".").compactMap { Int($0) }
            guard parts.count == 2, let d = p.startDate, d <= now else { return nil }
            return Anchor(major: parts[0], minor: parts[1], start: d)
        }.max { $0.start < $1.start }
        return started ?? fallback
    }()

    struct Patch: Hashable {
        let index: Int          // 0 = anchor version
        let start: Date
        var end: Date { start.addingTimeInterval(PatchCalendar.length) }
        var label: String { "\(PatchCalendar.anchor.major).\(PatchCalendar.anchor.minor + index)" }
    }

    static func patch(at date: Date = Date()) -> Patch {
        let i = Int(floor(date.timeIntervalSince(anchor.start) / length))
        return Patch(index: i, start: anchor.start.addingTimeInterval(Double(i) * length))
    }

    static func upcoming(_ count: Int, from date: Date = Date()) -> [Patch] {
        let current = patch(at: date)
        return (1...count).map { Patch(index: current.index + $0, start: anchor.start.addingTimeInterval(Double(current.index + $0) * length)) }
    }
}

// MARK: - Income profile (quiz answers)

struct IncomeProfile: Codable, Hashable {
    var battlePass = false
    var welkin = false
    /// 0 = rarely, 1 = most days, 2 = every day
    var dailies = 2
    /// Resin refreshes bought with primogems per day (0...3)
    var refreshes = 0
    /// 0 = little, 1 = some, 2 = most or all events & endgame
    var content = 2
    /// Start of the patch the quiz was answered in (nil = never)
    var answeredPatchStart: Date?

    init() {}

    enum CodingKeys: String, CodingKey { case battlePass, welkin, dailies, refreshes, content, answeredPatchStart }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        battlePass = try c.decodeIfPresent(Bool.self, forKey: .battlePass) ?? false
        welkin = try c.decodeIfPresent(Bool.self, forKey: .welkin) ?? false
        dailies = try c.decodeIfPresent(Int.self, forKey: .dailies) ?? 2
        refreshes = try c.decodeIfPresent(Int.self, forKey: .refreshes) ?? 0
        content = try c.decodeIfPresent(Int.self, forKey: .content) ?? 2
        answeredPatchStart = try c.decodeIfPresent(Date.self, forKey: .answeredPatchStart)
    }

    var quizIsCurrent: Bool {
        guard let answered = answeredPatchStart else { return false }
        return answered >= PatchCalendar.patch().start.addingTimeInterval(-60)
    }
}

// MARK: - Estimates

enum PrimoIncome {
    struct Line: Identifiable { var id: String { name }; let name: String; let primos: Int; let fates: Int }

    /// Primogem cost of refreshing resin N times every day (50, 100, 100).
    static let refreshCostPerDay = [0, 50, 150, 250]

    /// Live per-version estimate (from the game data file), if one exists for that version.
    static func override(for version: String) -> LiveIncome? { LiveCatalog.cached?.income?[version] }

    /// Estimated income for one 42-day patch. Free content figures come from the version's
    /// community estimate when available, otherwise averages of recent patches.
    static func perPatch(_ p: IncomeProfile, version: String? = nil) -> [Line] {
        var lines: [Line] = []
        let o = version.flatMap { override(for: $0) }
        let dailyShare = [0.25, 0.75, 1.0][min(max(p.dailies, 0), 2)]
        lines.append(Line(name: "Daily commissions", primos: Int(2_520 * dailyShare), fates: 0))
        let c = min(max(p.content, 0), 2)
        let events = Double(o?.events ?? 3_000) * [0.23, 0.63, 1.0][c]
        let endgame = Double(o?.endgame ?? 2_400) * [0.125, 0.54, 1.0][c]
        let exploration = Double(o?.exploration ?? 1_000) * [0.4, 0.7, 1.0][c]
        lines.append(Line(name: o == nil ? "Events & story quests" : "Events, story & new areas", primos: Int(events), fates: 0))
        lines.append(Line(name: "Abyss, Theater & Stygian", primos: Int(endgame), fates: 0))
        lines.append(Line(name: "Exploration, codes & compensation", primos: Int(exploration), fates: 0))
        lines.append(Line(name: "Stardust shop & quest fates", primos: 0, fates: o?.fates ?? 7))
        if p.welkin { lines.append(Line(name: "Blessing of the Welkin Moon", primos: 3_780, fates: 0)) }
        if p.battlePass { lines.append(Line(name: "Gnostic Hymn (paid Battle Pass)", primos: 680, fates: 4)) }
        let refresh = refreshCostPerDay[min(max(p.refreshes, 0), 3)] * 42
        if refresh > 0 { lines.append(Line(name: "Resin refreshes", primos: -refresh, fates: 0)) }
        return lines
    }

    static func pullsPerPatch(_ p: IncomeProfile, version: String? = nil) -> Double {
        let lines = perPatch(p, version: version)
        let primos = lines.reduce(0) { $0 + $1.primos }
        let fates = lines.reduce(0) { $0 + $1.fates }
        return Double(primos) / 160 + Double(fates)
    }

    static func pullsPerDay(_ p: IncomeProfile, at date: Date = Date()) -> Double {
        pullsPerPatch(p, version: PatchCalendar.patch(at: date).label) / 42
    }

    /// Projected total pulls at a date, adding each day's income for the version that day falls in.
    static func projectedPulls(at date: Date, savings: Int, profile: IncomeProfile, now: Date = Date()) -> Int {
        var total = Double(savings)
        var day = now
        while day < date {
            let step = min(86_400, date.timeIntervalSince(day))
            total += pullsPerDay(profile, at: day) * step / 86_400
            day = day.addingTimeInterval(step)
        }
        return Int(total)
    }

    /// Date when savings reach `target` pulls, or nil if income doesn't get there within ~2 years.
    static func dateReaching(_ target: Int, savings: Int, profile: IncomeProfile, now: Date = Date()) -> Date? {
        if savings >= target { return now }
        var total = Double(savings)
        var day = now
        for _ in 0..<730 {
            let rate = pullsPerDay(profile, at: day)
            if rate <= 0.001 { return nil }
            if total + rate >= Double(target) {
                return day.addingTimeInterval((Double(target) - total) / rate * 86_400)
            }
            total += rate
            day = day.addingTimeInterval(86_400)
        }
        return nil
    }
}

// MARK: - Quiz

struct IncomeQuizView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var step = 0
    @State private var answers = IncomeProfile()

    private struct Question {
        let title: String
        let detail: String
        let options: [(label: String, icon: String)]
    }

    private let questions: [Question] = [
        Question(title: "Do you buy the premium Battle Pass?", detail: "Gnostic Hymn: 680 Primogems + 4 Intertwined Fates per patch.",
                 options: [("Yes, this patch", "checkmark.circle.fill"), ("No", "xmark.circle")]),
        Question(title: "Do you have the Welkin Moon?", detail: "90 Primogems a day for the whole patch.",
                 options: [("Yes", "moon.stars.fill"), ("No", "xmark.circle")]),
        Question(title: "How consistent are your dailies?", detail: "Commissions give 60 Primogems a day.",
                 options: [("Every day", "flame.fill"), ("Most days", "calendar"), ("Rarely", "zzz")]),
        Question(title: "Do you refresh resin with Primogems?", detail: "Refreshes cost 50, then 100, then 100 Primogems each day.",
                 options: [("Never", "hand.raised.fill"), ("Once a day", "1.circle"), ("Twice a day", "2.circle"), ("Three times a day", "3.circle")]),
        Question(title: "How much event & endgame content do you clear?", detail: "Events, Spiral Abyss, Imaginarium Theater and Stygian Onslaught.",
                 options: [("Most or all", "star.fill"), ("Some", "star.leadinghalf.filled"), ("Very little", "star")]),
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HStack(spacing: 6) {
                    ForEach(0..<questions.count, id: \.self) { i in
                        Capsule().fill(i <= step ? Color.accentColor : Color.secondary.opacity(0.3)).frame(height: 5)
                    }
                }
                .padding(.horizontal)

                let q = questions[step]
                VStack(spacing: 8) {
                    Text("Question \(step + 1) of \(questions.count)").font(.caption).foregroundColor(.secondary)
                    Text(q.title).font(.title2.weight(.bold)).multilineTextAlignment(.center)
                    Text(q.detail).font(.subheadline).foregroundColor(.secondary).multilineTextAlignment(.center)
                }
                .padding(.horizontal)

                VStack(spacing: 10) {
                    ForEach(Array(q.options.enumerated()), id: \.offset) { i, option in
                        Button {
                            choose(i)
                        } label: {
                            HStack {
                                Image(systemName: option.icon).frame(width: 28)
                                Text(option.label).font(.headline)
                                Spacer()
                                if isSelected(i) { Image(systemName: "checkmark") }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(RoundedRectangle(cornerRadius: 14).fill(isSelected(i) ? Color.accentColor.opacity(0.2) : Color(.secondarySystemBackground)))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                Spacer()
            }
            .padding(.top)
            .navigationTitle("Income quiz – v\(PatchCalendar.patch().label)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .navigationBarLeading) {
                    if step > 0 { Button("Back") { withAnimation { step -= 1 } } }
                }
            }
            .onAppear { answers = store.data.incomeProfile }
        }
    }

    private func isSelected(_ i: Int) -> Bool {
        guard answers.answeredPatchStart != nil else { return false }
        switch step {
        case 0: return answers.battlePass == (i == 0)
        case 1: return answers.welkin == (i == 0)
        case 2: return answers.dailies == 2 - i
        case 3: return answers.refreshes == i
        default: return answers.content == 2 - i
        }
    }

    private func choose(_ i: Int) {
        switch step {
        case 0: answers.battlePass = (i == 0)
        case 1: answers.welkin = (i == 0)
        case 2: answers.dailies = 2 - i
        case 3: answers.refreshes = i
        default: answers.content = 2 - i
        }
        if step < questions.count - 1 {
            withAnimation { step += 1 }
        } else {
            answers.answeredPatchStart = PatchCalendar.patch().start
            store.data.incomeProfile = answers
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            dismiss()
        }
    }
}

// MARK: - Predictor screen

struct PrimoPredictorView: View {
    @EnvironmentObject var store: Store
    @State private var showQuiz = false

    var body: some View {
        let profile = store.data.incomeProfile
        let currentLabel = PatchCalendar.patch().label
        let lines = PrimoIncome.perPatch(profile, version: currentLabel)
        let primos = lines.reduce(0) { $0 + $1.primos }
        let fates = lines.reduce(0) { $0 + $1.fates }
        let pulls = PrimoIncome.pullsPerPatch(profile, version: currentLabel)
        let savings = store.data.wish.totalPulls
        let current = PatchCalendar.patch()
        let w = store.data.wish
        let guarantee = w.guaranteed ? w.pullsToHardPity : w.pullsToHardPity + 90

        List {
            if !profile.quizIsCurrent {
                Section {
                    Button { showQuiz = true } label: {
                        Label(profile.answeredPatchStart == nil ? "Take the 5-question income quiz" : "New patch! Retake the quiz for v\(current.label)",
                              systemImage: "questionmark.bubble.fill")
                            .font(.headline)
                    }
                } footer: {
                    Text("Your answers tune the predictions. The quiz comes back every new version.")
                }
            }

            Section {
                HStack(alignment: .firstTextBaseline) {
                    Text("≈ \(Int(pulls.rounded()))").font(.largeTitle.weight(.bold).monospacedDigit())
                    Text("pulls").foregroundColor(.secondary)
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("\(primos.formatted()) primos").font(.subheadline.monospacedDigit())
                        Text("+ \(fates) Intertwined Fates").font(.caption).foregroundColor(.secondary)
                    }
                }
                if let source = PrimoIncome.override(for: currentLabel)?.source {
                    Text(source).font(.caption).foregroundColor(.secondary)
                }
                ForEach(lines) { l in
                    HStack {
                        Text(l.name).font(.subheadline)
                        Spacer()
                        if l.primos != 0 {
                            Text(l.primos > 0 ? "+\(l.primos.formatted())" : l.primos.formatted())
                                .font(.subheadline.monospacedDigit())
                                .foregroundColor(l.primos < 0 ? .red : .primary)
                        }
                        if l.fates > 0 {
                            Text("+\(l.fates) fates").font(.subheadline.monospacedDigit()).foregroundColor(.secondary)
                        }
                    }
                }
            } header: {
                Text("Estimated income – v\(currentLabel)")
            }

            Section {
                projectionRow("Now", date: Date(), pulls: savings)
                projectionRow("End of v\(current.label)", date: current.end,
                              pulls: PrimoIncome.projectedPulls(at: current.end, savings: savings, profile: profile))
                ForEach(PatchCalendar.upcoming(3), id: \.self) { p in
                    projectionRow("End of v\(p.label)", date: p.end,
                                  pulls: PrimoIncome.projectedPulls(at: p.end, savings: savings, profile: profile))
                }
            } header: {
                Text("Projected pulls")
            } footer: {
                Text("Starts from your Wish savings (\(savings) pulls) and adds income day by day.")
            }

            Section("Featured 5★ guarantee") {
                HStack {
                    Text("Pulls needed (worst case)")
                    Spacer()
                    Text("\(guarantee)").monospacedDigit()
                }
                if let date = PrimoIncome.dateReaching(guarantee, savings: savings, profile: profile) {
                    HStack {
                        Text(savings >= guarantee ? "You can guarantee it now" : "Guaranteed by around")
                        Spacer()
                        if savings < guarantee {
                            Text(date.formatted(date: .abbreviated, time: .omitted)).font(.body.weight(.semibold))
                        }
                    }
                    if savings < guarantee {
                        Text("That's during v\(PatchCalendar.patch(at: date).label).").font(.caption).foregroundColor(.secondary)
                    }
                }
            }

            Section {
                Toggle("Premium Battle Pass", isOn: $store.data.incomeProfile.battlePass)
                Toggle("Welkin Moon", isOn: $store.data.incomeProfile.welkin)
                Picker("Dailies", selection: $store.data.incomeProfile.dailies) {
                    Text("Every day").tag(2)
                    Text("Most days").tag(1)
                    Text("Rarely").tag(0)
                }
                Picker("Resin refreshes per day", selection: $store.data.incomeProfile.refreshes) {
                    Text("None").tag(0)
                    Text("1").tag(1)
                    Text("2").tag(2)
                    Text("3").tag(3)
                }
                Picker("Events & endgame", selection: $store.data.incomeProfile.content) {
                    Text("Most or all").tag(2)
                    Text("Some").tag(1)
                    Text("Very little").tag(0)
                }
                Button("Retake quiz") { showQuiz = true }
            } header: {
                Text("Your answers")
            } footer: {
                Text("Estimates are averages of recent patches (free players ≈ 60 pulls, Welkin + Battle Pass ≈ 95). Anniversary and Lantern Rite patches usually give more.")
            }
        }
        .navigationTitle("Primogem predictor")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showQuiz) { IncomeQuizView() }
    }

    private func projectionRow(_ title: String, date: Date, pulls: Int) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.subheadline)
                Text(date.formatted(date: .abbreviated, time: .omitted)).font(.caption2).foregroundColor(.secondary)
            }
            Spacer()
            Text("\(pulls)").font(.headline.monospacedDigit())
            Text("pulls").font(.caption).foregroundColor(.secondary)
        }
    }
}
