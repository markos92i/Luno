//
//  CalendarDayView.swift
//  Luno
//

import SwiftUI

/// Individual day cell within the calendar grid.
struct CalendarDayView: View {
    let day: Int
    let isToday: Bool
    let isSelected: Bool
    let isDisabled: Bool
    let events: [Color]
    var badgeColor: Color?

    @Environment(\.calendarMetrics) private var metrics

    var body: some View {
        VStack(spacing: 2) {
            Text("\(day)")
                .font(metrics.dayFont)
                .foregroundStyle(isSelected ? AnyShapeStyle(.white) : isToday ? AnyShapeStyle(.tint) : AnyShapeStyle(.primary))
                .frame(width: metrics.circleSize, height: metrics.circleSize)
                .background {
                    if let badgeColor {
                        Circle()
                            .fill(badgeColor.opacity(0.18))
                            .frame(width: metrics.circleSize, height: metrics.circleSize)
                    }
                }
                .background {
                    Circle()
                        .fill(.tint)
                        .scaleEffect(isSelected ? 1 : 0.001)
                        .animation(isSelected ? .spring(duration: 0.3, bounce: 0.4) : .easeOut(duration: 0.2), value: isSelected)
                }
                .overlay {
                    if isToday {
                        Circle()
                            .strokeBorder(
                                isSelected ? AnyShapeStyle(.white.opacity(0.5)) : AnyShapeStyle(.tint),
                                lineWidth: 2
                            )
                            .frame(width: metrics.circleSize, height: metrics.circleSize)
                    }
                }

            if !events.isEmpty {
                HStack(spacing: 2) {
                    ForEach(0..<min(events.count, 3), id: \.self) { index in
                        Circle()
                            .fill(events[index])
                            .frame(width: metrics.dotSize, height: metrics.dotSize)
                    }
                }
            } else {
                Color.clear
                    .frame(width: metrics.dotSize, height: metrics.dotSize)
            }
        }
        .frame(minWidth: metrics.circleSize, minHeight: metrics.cellHeight, maxHeight: metrics.cellHeight)
        .opacity(isDisabled ? 0.3 : 1)
        .accessibilityLabel(accessibilityText)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .sensoryFeedback(.selection, trigger: isSelected)
    }

    // MARK: - Accessibility

    private var accessibilityText: String {
        var label = "\(day)"
        if isToday { label += ", hoy" }
        if isSelected { label += ", seleccionado" }
        if !events.isEmpty { label += ", \(events.count) evento\(events.count == 1 ? "" : "s")" }
        return label
    }
}

// MARK: - Preview

#Preview("States") {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            CalendarDayView(day: 14, isToday: false, isSelected: false, isDisabled: false, events: [])
            CalendarDayView(day: 15, isToday: true, isSelected: false, isDisabled: false, events: [.red])
            CalendarDayView(day: 16, isToday: false, isSelected: true, isDisabled: false, events: [])
            CalendarDayView(day: 17, isToday: true, isSelected: true, isDisabled: false, events: [.orange])
            CalendarDayView(day: 18, isToday: false, isSelected: false, isDisabled: true, events: [])
        }
        HStack(spacing: 20) {
            CalendarDayView(day: 1, isToday: false, isSelected: false, isDisabled: false, events: [], badgeColor: .orange)
            CalendarDayView(day: 2, isToday: false, isSelected: true, isDisabled: false, events: [], badgeColor: .green)
            CalendarDayView(day: 3, isToday: true, isSelected: false, isDisabled: false, events: [.red], badgeColor: .orange)
        }
    }
    .tint(.indigo)
    .padding()
}

#Preview("Regular metrics (iPad)") {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            CalendarDayView(day: 14, isToday: false, isSelected: false, isDisabled: false, events: [])
            CalendarDayView(day: 15, isToday: true, isSelected: false, isDisabled: false, events: [.red])
            CalendarDayView(day: 16, isToday: false, isSelected: true, isDisabled: false, events: [])
            CalendarDayView(day: 17, isToday: true, isSelected: true, isDisabled: false, events: [.orange])
        }
    }
    .environment(\.calendarMetrics, .regular)
    .tint(.blue)
    .padding()
}
