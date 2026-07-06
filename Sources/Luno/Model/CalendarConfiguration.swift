//
//  CalendarConfiguration.swift
//  Luno
//

import Foundation

/// A rule that determines which dates are selectable.
///
/// Rules combine logically:
/// - Inclusion rules (`.range`, `.only`): date must match **at least one** if any exist.
/// - Exclusion rules (`.except`): date is disabled if it matches **any** exclusion.
///
/// Final: `enabled = (no inclusions || matches any inclusion) && not in any exclusion`
public enum DateAvailability: Sendable, Equatable {
    /// Only dates within this range are enabled.
    case range(ClosedRange<Date>)
    /// These specific dates are disabled.
    case except(Set<Date>)
    /// Only these specific dates are enabled.
    case only(Set<Date>)
}

/// Configuration for the calendar component.
public struct CalendarConfiguration: Sendable, Equatable {
    /// The calendar to use for date calculations and locale.
    public var calendar: Calendar

    /// Availability rules that determine which dates are selectable.
    /// Empty array means all dates are enabled.
    public var availability: [DateAvailability]

    public init(
        calendar: Calendar = .current,
        availability: [DateAvailability] = []
    ) {
        self.calendar = calendar
        self.availability = availability
    }

    /// Whether a given date is enabled according to the availability rules.
    public func isDateEnabled(_ date: Date) -> Bool {
        let day = calendar.startOfDay(for: date)

        let inclusions = availability.filter { rule in
            switch rule {
            case .range, .only: true
            case .except: false
            }
        }

        let exclusions = availability.filter { rule in
            switch rule {
            case .except: true
            case .range, .only: false
            }
        }

        // Check inclusions (OR): if any exist, date must match at least one
        if !inclusions.isEmpty {
            let matchesAny = inclusions.contains { rule in
                switch rule {
                case .range(let range): range.contains(day)
                case .only(let dates): dates.contains(day)
                case .except: false
                }
            }
            if !matchesAny { return false }
        }

        // Check exclusions (AND NOT): if date is in any exclusion → disabled
        for rule in exclusions {
            if case .except(let dates) = rule, dates.contains(day) {
                return false
            }
        }

        return true
    }

    public static let `default` = CalendarConfiguration()
}
