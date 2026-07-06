//
//  CalendarRangeOverlay.swift
//  Luno
//

import SwiftUI

/// Draws the range highlight as a single stroke that snakes across rows.
struct CalendarRangeOverlay: View {
    let weeks: [[Date]]
    let range: CalendarRange?
    let calendar: Calendar

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.calendarMetrics) private var metrics

    @State private var progress: CGFloat = 1
    @State private var reversed: Bool = false

    private var rangeOpacity: Double {
        colorScheme == .dark ? 0.2 : 0.12
    }

    var body: some View {
        GeometryReader { geo in
            if let _ = range, let segments = computeSegments(in: geo.size.width) {
                let orderedSegments = reversed
                    ? segments.reversed().map { Segment(startX: $0.endX, endX: $0.startX, y: $0.y) }
                    : segments

                SnakePath(segments: orderedSegments)
                    .trim(from: 0, to: progress)
                    .stroke(
                        .tint.opacity(rangeOpacity),
                        style: StrokeStyle(lineWidth: metrics.circleSize + 4, lineCap: .round)
                    )
            }
        }
        .clipped()
        .onChange(of: range) { oldValue, newValue in
            guard let newValue, let oldValue, oldValue.isSingleDay, !newValue.isSingleDay else {
                progress = 1
                return
            }

            reversed = Calendar.current.isDate(oldValue.start, inSameDayAs: newValue.end)
            progress = 0
            withAnimation(.easeOut(duration: 0.35)) {
                progress = 1
            }
        }
    }

    // MARK: - Path segments

    struct Segment {
        let startX: CGFloat
        let endX: CGFloat
        let y: CGFloat
    }

    private func computeSegments(in totalWidth: CGFloat) -> [Segment]? {
        guard let range else { return nil }

        let columnWidth = totalWidth / 7
        func cellCenterX(_ col: Int) -> CGFloat {
            (CGFloat(col) + 0.5) * columnWidth
        }

        var segments: [Segment] = []

        for (rowIndex, week) in weeks.enumerated() {
            var firstCol: Int?
            var lastCol: Int?
            var containsStart = false
            var containsEnd = false

            for col in 0..<7 {
                let day = calendar.startOfDay(for: week[col])

                if range.contains(day, calendar: calendar) {
                    if firstCol == nil { firstCol = col }
                    lastCol = col
                    if calendar.isDate(day, inSameDayAs: range.start) { containsStart = true }
                    if calendar.isDate(day, inSameDayAs: range.end) { containsEnd = true }
                }
            }

            guard let first = firstCol, let last = lastCol else { continue }

            let y = CGFloat(rowIndex) * (metrics.cellHeight + metrics.rowSpacing) + metrics.circleSize / 2

            let startX: CGFloat = containsStart ? cellCenterX(first) : 0
            let endX: CGFloat = containsEnd ? cellCenterX(last) : totalWidth

            segments.append(Segment(startX: startX, endX: endX, y: y))
        }

        return segments.isEmpty ? nil : segments
    }
}

// MARK: - Snake path shape

private struct SnakePath: Shape {
    let segments: [CalendarRangeOverlay.Segment]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for segment in segments {
            path.move(to: CGPoint(x: segment.startX, y: segment.y))
            path.addLine(to: CGPoint(x: segment.endX, y: segment.y))
        }
        return path
    }
}
