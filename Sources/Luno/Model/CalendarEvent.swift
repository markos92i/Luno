//
//  CalendarEvent.swift
//  Luno
//

import SwiftUI

/// Represents a calendar event marker for a specific date.
public struct CalendarEvent: Identifiable, Equatable, Sendable {
    public let id = UUID()
    public var date: Date
    public var color: Color
    public var style: Style

    /// How the event is rendered on the calendar.
    public enum Style: Sendable {
        /// Small colored dot below the day number.
        case dot
        /// Subtle colored halo behind the day circle.
        case badge
    }

    public init(date: Date, color: Color = .blue, style: Style = .dot) {
        self.date = date
        self.color = color
        self.style = style
    }
}
