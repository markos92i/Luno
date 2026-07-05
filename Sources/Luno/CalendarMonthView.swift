//
//  CalendarMonthView.swift
//  Luno
//

import SwiftUI

/// Renders a single month grid with weekday headers and day cells.
public struct CalendarMonthView: View {
    let month: Date
    @Binding var selection: CalendarSelection
    var events: [CalendarEvent]
    var configuration: CalendarConfiguration

    @Environment(\.calendarMetrics) private var metrics

    private var calendar: Calendar { configuration.calendar }

    public init(
        month: Date,
        selection: Binding<CalendarSelection>,
        events: [CalendarEvent] = [],
        configuration: CalendarConfiguration = .default
    ) {
        self.month = month
        self._selection = selection
        self.events = events
        self.configuration = configuration
    }

    // MARK: - Computed grid data

    private var weekdaySymbols: [String] {
        let symbols = calendar.veryShortWeekdaySymbols
        let offset = calendar.firstWeekday - 1
        return Array(symbols[offset...]) + Array(symbols[..<offset])
    }

    private var monthInterval: DateInterval {
        calendar.dateInterval(of: .month, for: month) ?? DateInterval(start: month, end: month)
    }

    private var weeks: [[Date]] {
        calendar.monthGrid(for: month)
    }

    private var dotsByDay: [Int: [Color]] {
        let start = monthInterval.start
        let end = monthInterval.end
        let filtered = events.filter { $0.date >= start && $0.date < end && $0.style == .dot }

        var result: [Int: [Color]] = [:]
        for event in filtered {
            let day = calendar.component(.day, from: event.date)
            result[day, default: []].append(event.color)
        }
        return result
    }

    private var badgesByDay: [Int: Color] {
        let start = monthInterval.start
        let end = monthInterval.end
        let filtered = events.filter { $0.date >= start && $0.date < end && $0.style == .badge }

        var result: [Int: Color] = [:]
        for event in filtered {
            let day = calendar.component(.day, from: event.date)
            if result[day] == nil { result[day] = event.color }
        }
        return result
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: metrics.rowSpacing) {
            HStack(spacing: 0) {
                ForEach(0..<weekdaySymbols.count, id: \.self) { index in
                    Text(weekdaySymbols[index])
                        .font(metrics.weekdayFont)
                        .foregroundStyle(.primary.opacity(0.5))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, metrics.rowSpacing)

            VStack(spacing: metrics.rowSpacing) {
                ForEach(0..<weeks.count, id: \.self) { weekIndex in
                    HStack(spacing: 0) {
                        ForEach(0..<7, id: \.self) { dayIndex in
                            let day = weeks[weekIndex][dayIndex]

                            if calendar.isDate(day, equalTo: month, toGranularity: .month) {
                                dayCell(for: day)
                                    .frame(maxWidth: .infinity)
                            } else {
                                adjacentDayCell(for: day)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }
            .background {
                CalendarRangeOverlay(
                    weeks: weeks,
                    range: currentRange,
                    calendar: calendar
                )
            }
        }
    }

    // MARK: - Day cell

    private var currentRange: CalendarRange? {
        if case .range(let range) = selection { return range }
        return nil
    }

    @ViewBuilder
    private func dayCell(for date: Date) -> some View {
        let dayNumber = calendar.component(.day, from: date)
        let isToday = calendar.isDateInToday(date)
        let isSelected = isDaySelected(date)
        let isDisabled = isDayDisabled(date)
        let dots = dotsByDay[dayNumber] ?? []
        let badgeColor = badgesByDay[dayNumber]

        CalendarDayView(
            day: dayNumber,
            isToday: isToday,
            isSelected: isSelected,
            isDisabled: isDisabled,
            events: dots,
            badgeColor: badgeColor
        )
        .contentShape(Rectangle())
        .onTapGesture {
            guard !isDisabled else { return }
            handleTap(on: date)
        }
    }

    private func adjacentDayCell(for date: Date) -> some View {
        VStack(spacing: 2) {
            Text("\(calendar.component(.day, from: date))")
                .font(metrics.dayFont)
                .foregroundStyle(.primary.opacity(0.15))
                .frame(width: metrics.circleSize, height: metrics.circleSize)

            Color.clear
                .frame(width: metrics.dotSize, height: metrics.dotSize)
        }
        .frame(minWidth: metrics.circleSize, minHeight: metrics.cellHeight, maxHeight: metrics.cellHeight)
    }

    // MARK: - Selection logic

    private func isDaySelected(_ date: Date) -> Bool {
        switch selection {
        case .single(let selected):
            guard let selected else { return false }
            return calendar.isDate(date, inSameDayAs: selected)

        case .range(let range):
            guard let range else { return false }
            return calendar.isDate(date, inSameDayAs: range.start) ||
                   calendar.isDate(date, inSameDayAs: range.end)

        case .multi(let dates):
            return dates.contains { calendar.isDate($0, inSameDayAs: date) }
        }
    }

    private func isDayDisabled(_ date: Date) -> Bool {
        !configuration.isDateEnabled(date)
    }

    // MARK: - Tap handling

    private func handleTap(on date: Date) {
        switch selection {
        case .single:
            handleSingleTap(on: date)
        case .range:
            handleRangeTap(on: date)
        case .multi:
            handleMultiTap(on: date)
        }
    }

    private func handleSingleTap(on date: Date) {
        let isDeselect = selection.date.map { calendar.isDate($0, inSameDayAs: date) } ?? false
        withAnimation(.spring(duration: 0.35, bounce: 0.3)) {
            selection = .single(isDeselect ? nil : date)
        }
    }

    private func handleRangeTap(on date: Date) {
        guard let current = selection.range else {
            // First tap — anchor point
            withAnimation(.spring(duration: 0.35, bounce: 0.3)) {
                selection = .range(CalendarRange(start: date, end: date))
            }
            return
        }

        if current.isSingleDay {
            // Second tap — extend or deselect
            let isDeselect = calendar.isDate(date, inSameDayAs: current.start)
            withAnimation(.spring(duration: 0.35, bounce: 0.3)) {
                selection = isDeselect ? .range(nil) : .range(CalendarRange(start: current.start, end: date))
            }
        } else {
            // Third tap — restart with new anchor
            var transaction = Transaction(animation: nil)
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                selection = .range(CalendarRange(start: date, end: date))
            }
        }
    }

    private func handleMultiTap(on date: Date) {
        var dates = selection.dates
        let normalized = calendar.startOfDay(for: date)

        if let existing = dates.first(where: { calendar.isDate($0, inSameDayAs: normalized) }) {
            dates.remove(existing)
        } else {
            dates.insert(normalized)
        }

        withAnimation(.spring(duration: 0.35, bounce: 0.3)) {
            selection = .multi(dates)
        }
    }
}

// MARK: - Preview

#Preview("Single") {
    @Previewable @State var selection: CalendarSelection = .single(nil)

    CalendarMonthView(
        month: .now,
        selection: $selection,
        events: [
            .init(date: Date(), color: .blue),
            .init(date: Date(), color: .red),
            .init(date: Date().addingTimeInterval(-86400 * 3), color: .teal),
            .init(date: Date().addingTimeInterval(-86400 * 1), color: .orange, style: .badge),
            .init(date: Date().addingTimeInterval(-86400 * 2), color: .green, style: .badge)
        ]
    )
    .tint(.blue)
    .padding()
}

#Preview("Range") {
    @Previewable @State var selection: CalendarSelection = .range(nil)

    CalendarMonthView(
        month: .now,
        selection: $selection,
        events: [
            .init(date: Date(), color: .blue),
            .init(date: Date().addingTimeInterval(-86400 * 5), color: .red, style: .badge),
            .init(date: Date().addingTimeInterval(-86400 * 6), color: .red, style: .badge),
            .init(date: Date().addingTimeInterval(-86400 * 7), color: .red, style: .badge)
        ]
    )
    .tint(.indigo)
    .padding()
}

#Preview("Multi") {
    @Previewable @State var selection: CalendarSelection = .multi([])

    CalendarMonthView(
        month: .now,
        selection: $selection,
        events: [
            .init(date: Date(), color: .green, style: .badge),
            .init(date: Date().addingTimeInterval(86400 * 1), color: .green, style: .badge),
            .init(date: Date().addingTimeInterval(86400 * 2), color: .orange, style: .badge),
            .init(date: Date().addingTimeInterval(86400 * 2), color: .mint)
        ]
    )
    .tint(.purple)
    .padding()
}
