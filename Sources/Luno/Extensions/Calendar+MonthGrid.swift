//
//  Calendar+MonthGrid.swift
//  Luno
//

import Foundation

extension Calendar {
    /// Returns a 6×7 grid of dates for the month containing `date`,
    /// filling leading/trailing slots with adjacent month days.
    func monthGrid(for date: Date) -> [[Date]] {
        let interval = dateInterval(of: .month, for: date)!
        let firstOfMonth = interval.start
        let daysInMonth = range(of: .day, in: .month, for: date)!.count
        
        let weekday = component(.weekday, from: firstOfMonth)
        let leadingCount = (weekday - firstWeekday + 7) % 7
        
        var cells: [Date] = (0..<leadingCount).map {
            self.date(byAdding: .day, value: $0 - leadingCount, to: firstOfMonth)!
        }
        
        cells += (0..<daysInMonth).map {
            self.date(byAdding: .day, value: $0, to: firstOfMonth)!
        }
        
        let trailingCount = 42 - cells.count
        let dayAfterLast = self.date(byAdding: .day, value: daysInMonth, to: firstOfMonth)!
        cells += (0..<trailingCount).map {
            self.date(byAdding: .day, value: $0, to: dayAfterLast)!
        }
        
        return stride(from: 0, to: cells.count, by: 7).map { Array(cells[$0..<$0 + 7]) }
    }
}
