//
//  CalendarPagerView.swift
//  Luno
//

import SwiftUI

/// A horizontally-paged calendar with single date and range selection.
public struct LunoCalendar: View {
    @Binding var selection: CalendarSelection
    @Binding var month: Date

    var events: [CalendarEvent]
    var configuration: CalendarConfiguration

    @State private var scrolledMonth: Date?
    @State private var months: [Date]
    @State private var isExternalMonth: Bool
    @State private var showingMonthPicker = false
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var calendar: Calendar { configuration.calendar }

    /// Creates a calendar view with optional external month control.
    ///
    /// When `month` is provided, the binding is kept in sync with the visible page.
    /// When omitted, the calendar manages its own scroll position internally.
    public init(
        selection: Binding<CalendarSelection>,
        events: [CalendarEvent] = [],
        month: Binding<Date>? = nil,
        configuration: CalendarConfiguration = .default
    ) {
        self._selection = selection
        self._month = month ?? .constant(.now)
        self.events = events
        self.configuration = configuration
        self._isExternalMonth = State(initialValue: month != nil)

        let cal = configuration.calendar
        let current = cal.monthStart(for: month?.wrappedValue ?? .now)
        self._months = State(initialValue: Self.generateInitialMonths(around: current, calendar: cal))
        self._scrolledMonth = State(initialValue: current)
    }

    private var monthTitle: String {
        let displayDate = scrolledMonth ?? month
        return displayDate.formatted(.dateTime.month(.wide).year().locale(calendar.locale ?? .current))
    }

    private var yearTitle: String {
        let displayDate = scrolledMonth ?? month
        return displayDate.formatted(.dateTime.year().locale(calendar.locale ?? .current))
    }

    public var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Text(showingMonthPicker ? yearTitle : monthTitle)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.2), value: scrolledMonth)
                    .animation(.easeInOut(duration: 0.2), value: showingMonthPicker)
                    .onTapGesture {
                        withAnimation(.spring(duration: 0.3, bounce: 0.2)) {
                            showingMonthPicker.toggle()
                        }
                    }

                HStack(spacing: 0) {
                    Button("Anterior", systemImage: "chevron.left") {
                        let current = scrolledMonth ?? month
                        navigate(to: calendar.addingMonths(showingMonthPicker ? -12 : -1, to: current))
                    }
                    .frame(maxWidth: .infinity)

                    ForEach(0..<5, id: \.self) { _ in
                        Color.clear.frame(maxWidth: .infinity)
                    }

                    Button("Siguiente", systemImage: "chevron.right") {
                        let current = scrolledMonth ?? month
                        navigate(to: calendar.addingMonths(showingMonthPicker ? 12 : 1, to: current))
                    }
                    .frame(maxWidth: .infinity)
                }
                .fontWeight(.bold)
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
            }

            if showingMonthPicker {
                CalendarMonthPicker(
                    selectedMonth: scrolledMonth ?? month,
                    calendar: calendar,
                    configuration: configuration
                ) { selectedMonth in
                    navigate(to: selectedMonth, animated: false)
                    withAnimation(.spring(duration: 0.3, bounce: 0.2)) {
                        showingMonthPicker = false
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
            } else {
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 50) {
                        ForEach(months, id: \.self) { month in
                            CalendarMonthView(
                                month: month,
                                selection: $selection,
                                events: events,
                                configuration: configuration
                            )
                            .containerRelativeFrame(.horizontal)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
                .scrollPosition(id: $scrolledMonth)
                .scrollIndicators(.hidden)
                .onChange(of: scrolledMonth) { _, newMonth in
                    guard let newMonth else { return }
                    if isExternalMonth {
                        month = newMonth
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
            }
        }
        .opacity(isEnabled ? 1 : 0.3)
        .allowsHitTesting(isEnabled)
        .environment(\.calendarMetrics, sizeClass == .regular ? .regular : .compact)
    }

    // MARK: - Navigation

    private func navigate(to target: Date, animated: Bool = true) {
        let normalized = calendar.monthStart(for: target)

        if let first = months.first, normalized < first {
            months.insert(contentsOf: calendar.months(from: normalized, through: calendar.addingMonths(-1, to: first)), at: 0)
        } else if let last = months.last, normalized > last {
            months.append(contentsOf: calendar.months(from: calendar.addingMonths(1, to: last), through: normalized))
        }

        if animated {
            withAnimation(.spring) { scrolledMonth = normalized }
        } else {
            scrolledMonth = normalized
        }

        if isExternalMonth { month = normalized }
    }

    // MARK: - Helpers

    private static func generateInitialMonths(around current: Date, calendar: Calendar) -> [Date] {
        calendar.months(from: calendar.addingMonths(-6, to: current), through: calendar.addingMonths(6, to: current))
    }
}

// MARK: - Preview

#Preview("Single selection") {
    @Previewable @State var selection: CalendarSelection = .single(nil)

    ScrollView {
        LunoCalendar(
            selection: $selection,
            events: [
                .init(date: Date(), color: .blue),
                .init(date: Date(), color: .red),
                .init(date: Date().addingTimeInterval(-86400 * 5), color: .teal),
                .init(date: Date().addingTimeInterval(-86400 * 2), color: .orange, style: .badge),
                .init(date: Date().addingTimeInterval(-86400 * 3), color: .green, style: .badge),
                .init(date: Date().addingTimeInterval(-86400 * 3), color: .purple)
            ]
        )
        .tint(.blue)
        .padding()
    }
}

#Preview("Range selection") {
    @Previewable @State var selection: CalendarSelection = .range(nil)

    ScrollView {
        LunoCalendar(
            selection: $selection,
            events: [
                .init(date: Date(), color: .blue),
                .init(date: Date().addingTimeInterval(-86400 * 1), color: .orange, style: .badge),
                .init(date: Date().addingTimeInterval(-86400 * 2), color: .orange, style: .badge),
                .init(date: Date().addingTimeInterval(-86400 * 3), color: .orange, style: .badge)
            ]
        )
        .tint(.indigo)
        .padding()
    }
}

#Preview("Multi selection") {
    @Previewable @State var selection: CalendarSelection = .multi([])

    ScrollView {
        LunoCalendar(
            selection: $selection,
            events: [
                .init(date: Date(), color: .green, style: .badge),
                .init(date: Date().addingTimeInterval(-86400 * 4), color: .red, style: .badge),
                .init(date: Date().addingTimeInterval(-86400 * 4), color: .mint),
                .init(date: Date().addingTimeInterval(86400 * 2), color: .orange, style: .badge)
            ]
        )
        .tint(.purple)
        .padding()
    }
}
