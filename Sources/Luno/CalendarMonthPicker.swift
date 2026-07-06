//
//  CalendarMonthPicker.swift
//  Luno
//

import SwiftUI

/// Inline 4×3 grid for quick month/year navigation.
struct CalendarMonthPicker: View {
    let selectedMonth: Date
    let calendar: Calendar
    let configuration: CalendarConfiguration
    var onMonthSelected: (Date) -> Void

    @Environment(\.calendarMetrics) private var metrics

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    private var displayedYear: Int {
        calendar.component(.year, from: selectedMonth)
    }

    private var selectedMonthIndex: Int {
        calendar.component(.month, from: selectedMonth)
    }

    private var isViewingCurrentMonth: Bool {
        calendar.isDate(selectedMonth, equalTo: .now, toGranularity: .month)
    }

    var body: some View {
        VStack(spacing: 20) {
            LazyVGrid(columns: columns, spacing: metrics.rowSpacing) {
                ForEach(0..<12, id: \.self) { monthIndex in
                    let month = monthIndex + 1
                    let monthDate = dateFor(month: month)
                    let isDisabled = isMonthDisabled(monthDate)
                    let isSelected = month == selectedMonthIndex

                    Button {
                        onMonthSelected(monthDate)
                    } label: {
                        Text(monthSymbol(monthIndex))
                            .font(metrics.dayFont)
                            .foregroundStyle(monthForeground(isSelected: isSelected, isDisabled: isDisabled))
                            .frame(height: metrics.circleSize)
                            .padding(.horizontal, 16)
                            .background {
                                if isSelected {
                                    Capsule().fill(.tint)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: metrics.cellHeight)
                    }
                    .disabled(isDisabled)
                    .buttonStyle(.plain)
                }
            }

            if !isViewingCurrentMonth {
                Button {
                    onMonthSelected(calendar.monthStart(for: .now))
                } label: {
                    Text("Hoy")
                        .font(metrics.dayFont)
                        .foregroundStyle(.tint)
                        .frame(height: metrics.circleSize)
                        .padding(.horizontal, 24)
                        .background(.tint.opacity(0.1), in: Capsule())
                }
                .buttonStyle(.plain)
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
    }

    // MARK: - Helpers

    private func monthForeground(isSelected: Bool, isDisabled: Bool) -> AnyShapeStyle {
        if isSelected { return AnyShapeStyle(.white) }
        if isDisabled { return AnyShapeStyle(.primary.opacity(0.3)) }
        return AnyShapeStyle(.primary)
    }

    private func monthSymbol(_ index: Int) -> String {
        calendar.shortMonthSymbols[index].capitalized
    }

    private func dateFor(month: Int) -> Date {
        var components = DateComponents()
        components.year = displayedYear
        components.month = month
        components.day = 1
        return calendar.date(from: components) ?? .now
    }

    private func isMonthDisabled(_ date: Date) -> Bool {
        // A month is disabled if ALL its days are disabled
        let interval = calendar.dateInterval(of: .month, for: date)!
        // Check first and last day as a quick heuristic
        return !configuration.isDateEnabled(interval.start) &&
               !configuration.isDateEnabled(calendar.date(byAdding: .day, value: -1, to: interval.end)!)
    }
}
