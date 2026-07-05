//
//  CalendarMetrics.swift
//  Luno
//

import SwiftUI

/// Adaptive sizing metrics for the calendar grid.
/// Scales elements proportionally based on horizontal size class.
struct CalendarMetrics {
    let circleSize: CGFloat
    let cellHeight: CGFloat
    let ringExpandedSize: CGFloat
    let dayFont: Font
    let weekdayFont: Font
    let dotSize: CGFloat
    let rowSpacing: CGFloat

    static let compact = CalendarMetrics(
        circleSize: 36,
        cellHeight: 44,
        ringExpandedSize: 40,
        dayFont: .footnote.bold(),
        weekdayFont: .caption.weight(.medium),
        dotSize: 5,
        rowSpacing: 10
    )

    static let regular = CalendarMetrics(
        circleSize: 48,
        cellHeight: 58,
        ringExpandedSize: 54,
        dayFont: .callout.bold(),
        weekdayFont: .footnote.weight(.medium),
        dotSize: 6,
        rowSpacing: 14
    )
}

// MARK: - Environment

extension EnvironmentValues {
    @Entry var calendarMetrics: CalendarMetrics = .compact
}
