//
//  CalendarSelection.swift
//  Luno
//

import Foundation

/// Represents the selection state of the calendar component.
public enum CalendarSelection: Equatable, Sendable {
    case single(Date?)
    case range(CalendarRange?)
    case multi(Set<Date>)

    public var date: Date? {
        if case .single(let date) = self { return date }
        return nil
    }

    public var range: CalendarRange? {
        if case .range(let range) = self { return range }
        return nil
    }

    public var dates: Set<Date> {
        if case .multi(let dates) = self { return dates }
        return []
    }

    public var isSingle: Bool {
        if case .single = self { return true }
        return false
    }

    public var isRange: Bool {
        if case .range = self { return true }
        return false
    }

    public var isMulti: Bool {
        if case .multi = self { return true }
        return false
    }
}

/// A date range with explicit start and end dates.
public struct CalendarRange: Equatable, Sendable {
    public let start: Date
    public let end: Date

    public init(start: Date, end: Date, calendar: Calendar = .current) {
        let s = calendar.startOfDay(for: start)
        let e = calendar.startOfDay(for: end)
        (self.start, self.end) = s <= e ? (s, e) : (e, s)
    }

    /// Whether this range represents a single-day anchor (start == end).
    public var isSingleDay: Bool {
        Calendar.current.isDate(start, inSameDayAs: end)
    }

    public func contains(_ date: Date, calendar: Calendar = .current) -> Bool {
        let day = calendar.startOfDay(for: date)
        return day >= start && day <= end
    }

    /// The position of a given date within this range.
    public func position(of date: Date, calendar: Calendar = .current) -> RangePosition {
        let day = calendar.startOfDay(for: date)

        let isStart = calendar.isDate(day, inSameDayAs: start)
        let isEnd = calendar.isDate(day, inSameDayAs: end)

        if isStart && isEnd { return .single }
        if isStart { return .start }
        if isEnd { return .end }
        if contains(date, calendar: calendar) { return .middle }
        return .none
    }
}

/// The position of a day cell within a selected range.
public enum RangePosition: Sendable {
    case start
    case middle
    case end
    case single
    case none
}
