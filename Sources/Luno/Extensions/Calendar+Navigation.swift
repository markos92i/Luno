//
//  Calendar+Navigation.swift
//  Luno
//

import Foundation

extension Calendar {
    /// First instant of the month containing `date`.
    func monthStart(for date: Date) -> Date {
        dateInterval(of: .month, for: date)!.start
    }

    /// First instant of the month offset by `value` months from `date`'s month.
    func addingMonths(_ value: Int, to date: Date) -> Date {
        self.date(byAdding: .month, value: value, to: monthStart(for: date))!
    }

    /// Array of month-start dates from `start` through `end` (inclusive).
    func months(from start: Date, through end: Date) -> [Date] {
        let first = monthStart(for: start)
        let last = monthStart(for: end)

        var result: [Date] = []
        var current = first
        while current <= last {
            result.append(current)
            current = self.date(byAdding: .month, value: 1, to: current)!
        }
        return result
    }
}
