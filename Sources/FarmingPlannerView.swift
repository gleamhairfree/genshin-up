import SwiftUI

extension Store {
    func farmingPlan(now: Date = Date()) -> FarmingPlanner.Result {
        FarmingPlanner.build(store: self, dailyResin: data.plannerDailyResin,
                             includeLeyLines: data.plannerLeyLines,
                             startDay: ResetClock.gameDay(now, server: data.server))
    }
}

struct FarmingPlannerView: View {
    @EnvironmentObject var store: Store
    @State private var showAllDays = false

    var body: some View {
        let result = store.farmingPlan()
        let days = result.schedule.filter { !$0.entries.isEmpty }
        let shown = showAllDays ? days : Array(days.prefix(7))
        List {
            Section {
                Stepper(value: $store.data.plannerDailyResin, in: 40...600, step: 20) {
                    HStack {
                        Text("Resin per day")
                        Spacer()
                        Text("\(store.data.plannerDailyResin)").font(.body.monospacedDigit()).foregroundColor(.secondary)
                    }
                }
                Toggle("Include Ley Lines (EXP & Mora)", isOn: $store.data.plannerLeyLines)
            } header: {
                Text("Budget")
            } footer: {
                Text("180 is a day of natural resin. Add more if you use Fragile Resin or Condensed Resin regularly.")
            }

            Section("Summary") {
                if result.tasks.isEmpty {
                    Label("Nothing left to farm with resin.", systemImage: "checkmark.seal.fill").foregroundColor(.green)
                } else {
                    summaryRow("Total resin needed", "\(result.totalResin.formatted())")
                    summaryRow("Estimated time", result.daysToFinish.map { "\($0) day\($0 == 1 ? "" : "s")" } ?? "180+ days")
                    if let finish = result.daysToFinish,
                       let date = Calendar.current.date(byAdding: .day, value: finish - 1, to: Date()) {
                        summaryRow("Done around", date.formatted(date: .abbreviated, time: .omitted))
                    }
                }
            }

            ForEach(shown) { plan in
                Section {
                    ForEach(Array(plan.entries.enumerated()), id: \.offset) { _, e in
                        HStack(spacing: 10) {
                            ItemIcon(name: e.task.iconItem, size: 34)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(e.task.title).font(.subheadline.weight(.semibold))
                                Text(e.task.forGroups.isEmpty ? e.task.subtitle : e.task.forGroups.joined(separator: ", "))
                                    .font(.caption).foregroundColor(.secondary).lineLimit(2)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("×\(e.runs)").font(.subheadline.monospacedDigit().weight(.semibold))
                                Text("\(e.resin)").font(.caption.monospacedDigit()).foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text(dayTitle(plan))
                        Spacer()
                        Text("\(plan.resinUsed) resin").monospacedDigit()
                    }
                }
            }

            if days.count > 7 {
                Section {
                    Button(showAllDays ? "Show first week only" : "Show all \(days.count) days") {
                        withAnimation { showAllDays.toggle() }
                    }
                }
            }

            if !result.tasks.isEmpty {
                Section("Runs needed in total") {
                    ForEach(result.tasks) { t in
                        HStack(spacing: 10) {
                            ItemIcon(name: t.iconItem, size: 28)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(t.title).font(.subheadline)
                                Text(t.days.map { $0.short } ?? (t.isWeekly ? "Once a week" : "Any day"))
                                    .font(.caption2).foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("\(t.runs) × \(t.resinPerRun)").font(.caption.monospacedDigit()).foregroundColor(.secondary)
                        }
                    }
                }
            }

            if !result.free.isEmpty {
                let categories = Array(Set(result.free.map { $0.category })).sorted()
                ForEach(categories, id: \.self) { cat in
                    Section {
                        ForEach(result.free.filter { $0.category == cat }) { item in
                            HStack(spacing: 10) {
                                ItemIcon(name: item.name, size: 28)
                                Text(item.name).font(.subheadline)
                                Spacer()
                                Text("\(item.remaining.formatted()) left").font(.caption.monospacedDigit()).foregroundColor(.secondary)
                            }
                        }
                    } header: {
                        Text("No resin: \(cat)")
                    }
                }
            }

            Section {
                EmptyView()
            } footer: {
                Text("Estimates use average drops at the top domain tier and World Level 8 (talent domain ≈ 10 Teachings-equivalent per run, weapon domain ≈ 17, world boss ≈ 2.5 drops, weekly boss ≈ 2). Spare lower-tier items count toward higher tiers via crafting. Real drops vary.")
            }
        }
        .navigationTitle("Farming plan")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func summaryRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value).font(.body.monospacedDigit().weight(.semibold))
        }
    }

    private func dayTitle(_ plan: FarmingPlanner.DayPlan) -> String {
        switch plan.offset {
        case 0: return "Today · \(plan.day.name)"
        case 1: return "Tomorrow · \(plan.day.name)"
        default:
            let date = Calendar.current.date(byAdding: .day, value: plan.offset, to: Date()) ?? Date()
            return "\(plan.day.name) · \(date.formatted(.dateTime.month(.abbreviated).day()))"
        }
    }
}

/// Compact "today's runs" card for the Today tab.
struct TodayFarmingCard: View {
    @EnvironmentObject var store: Store

    var body: some View {
        let result = store.farmingPlan()
        let today = result.schedule.first
        NavigationLink {
            FarmingPlannerView()
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                if let today, !today.entries.isEmpty {
                    ForEach(Array(today.entries.prefix(4).enumerated()), id: \.offset) { _, e in
                        HStack(spacing: 8) {
                            ItemIcon(name: e.task.iconItem, size: 24)
                            Text(e.task.title).font(.subheadline).lineLimit(1)
                            Spacer()
                            Text("×\(e.runs)").font(.subheadline.monospacedDigit())
                        }
                    }
                    if today.entries.count > 4 {
                        Text("+\(today.entries.count - 4) more").font(.caption).foregroundColor(.secondary)
                    }
                    Text("\(today.resinUsed) resin today · \(result.daysToFinish.map { "done in ~\($0) days" } ?? "180+ days")")
                        .font(.caption).foregroundColor(.secondary)
                } else if result.tasks.isEmpty {
                    Text("Nothing to farm with resin. Plan characters or weapons on the Materials tab.")
                        .font(.footnote).foregroundColor(.secondary)
                } else {
                    Text("Nothing scheduled today – open the plan to see upcoming days.")
                        .font(.footnote).foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 2)
        }
    }
}
