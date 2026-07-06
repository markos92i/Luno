# Luno

![Swift 6.0](https://img.shields.io/badge/Swift-6.0-F05138?logo=swift&logoColor=white)
![iOS 18+](https://img.shields.io/badge/iOS-18%2B-007AFF)
![SPM](https://img.shields.io/badge/SPM-Compatible-blue)
![No Dependencies](https://img.shields.io/badge/Dependencies-None-green)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow)

A pure SwiftUI calendar component with single and range selection, tint-based theming, dark mode support, and smooth animations. No external dependencies.

## Demo

https://github.com/user-attachments/assets/demo.mov

> Upload `demo.mov` to a GitHub release or drag it into the repo's issue/PR editor to get a permanent URL, then replace the link above.

## Features

- **Single & range selection** — Tap to select a date, or define a range with two taps
- **Tint-based theming** — All colors derived from `.tint()`, works with any brand color
- **Dark mode adaptive** — Automatic adjustment of opacities and contrast
- **Event dots** — Display up to 3 colored dots per day
- **Smooth animations** — Spring scale on selection, trim animation on range path, haptic feedback
- **Configurable bounds** — Set minimum/maximum selectable dates
- **Month paging** — Horizontal swipe between months with navigation header
- **External month control** — Bind the visible month for lazy-loading or external navigation
- **Fixed height mode** — Always render 6 rows for consistent layout
- **Zero dependencies** — Pure SwiftUI, no external packages

## Installation

Add Luno to your project via Swift Package Manager:

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/markos92i/Luno.git", from: "1.0.0")
]
```

Or in Xcode: **File → Add Package Dependencies** → paste the repository URL.

## Quick Start

```swift
import Luno

struct ContentView: View {
    @State var selection: CalendarSelection = .single(nil)

    var body: some View {
        LunoCalendarView(selection: $selection)
            .tint(.blue)
    }
}
```

## Selection Modes

### Single

Tap a day to select. Tap again to deselect.

```swift
@State var selection: CalendarSelection = .single(nil)
```

### Range

First tap marks the start, second tap extends the range. Third tap resets.

```swift
@State var selection: CalendarSelection = .range(nil)

// Access the selected range
if let range = selection.range {
    print("From \(range.start) to \(range.end)")
}
```

## Events

Display colored dots below each day (up to 3 visible per day):

```swift
LunoCalendarView(
    selection: $selection,
    events: [
        .init(date: Date(), color: .red),
        .init(date: Date(), color: .blue),
        .init(date: someDate, color: .orange)
    ]
)
```

## Theming

The component uses no hardcoded colors. The entire palette is derived from the `.tint` modifier:

```swift
// System blue
LunoCalendarView(selection: $selection).tint(.blue)

// Custom brand color
LunoCalendarView(selection: $selection).tint(.brandPrimary)

// Per-screen theming
LunoCalendarView(selection: $selection).tint(.indigo)
```

| State | Text | Background | Extra |
|-------|------|------------|-------|
| Normal | `.primary` | none | — |
| Today | `.tint` | none | ring `.tint` 2pt |
| Selected | `.white` | `.tint` fill | spring scale |
| Today + Selected | `.white` | `.tint` fill | ring expanded to 40pt |
| Disabled | `.primary` 30% | none | non-interactive |
| Range (middle) | `.primary` | `.tint` strip 12% | — |

## Configuration

```swift
let config = CalendarConfiguration(
    calendar: .current,          // Locale and first day of week
    minimumDate: Date.now,       // Disable past dates
    maximumDate: futureDate,     // Disable future dates
    showEvents: true,            // Show event dots
    fixedHeight: true            // Always 6 rows (constant height)
)

LunoCalendarView(
    selection: $selection,
    events: myEvents,
    configuration: config
)
```

## Controlling the Visible Month

Bind the visible month for lazy-loading or external navigation:

```swift
@State var visibleMonth = Date.now

LunoCalendarView(
    selection: $selection,
    events: events,
    month: $visibleMonth
)
.onChange(of: visibleMonth) { _, month in
    Task { await vm.loadEvents(for: month) }
}
```

If you don't pass `month`, the calendar manages navigation internally.

## Components

### LunoCalendarView

Main view with navigation header and horizontal month paging.

```swift
LunoCalendarView(
    selection: $selection,
    events: myEvents,
    month: $visibleMonth,
    configuration: config
)
```

### CalendarMonthView

Just the month grid (no header, no paging). For custom layout integration.

```swift
CalendarMonthView(
    month: someDate,
    selection: $selection,
    events: myEvents,
    onDateTapped: { date in
        // Additional action on tap
    }
)
```

## Animations

- **Day selection** — Spring scale pop-in of the circle
- **Today ring** — Spring expand/contract when selected
- **Range** — Trim animation of the snake path growing from the first selected day
- **Direction-aware** — Animation grows forward or backward based on second tap position
- **Haptic** — `sensoryFeedback(.selection)` on select/deselect

## Architecture

```
Luno/Sources/Luno/
├── LunoCalendarView.swift        — Main view with horizontal pager
├── CalendarMonthView.swift       — Monthly grid with selection and events
├── CalendarDayView.swift         — Individual cell (circle, ring, dots)
├── CalendarRangeOverlay.swift    — Snake path with trim animation
├── CalendarSelection.swift       — .single(Date?) | .range(CalendarRange?)
├── CalendarConfiguration.swift   — Config: calendar, min/max, height
└── CalendarEvent.swift           — Event model (date + color)
```

## Requirements

| Requirement | Version |
|------------|---------|
| Swift | 6.0+ |
| iOS | 18.0+ |
| macOS | 15.0+ |
| Xcode | 26+ |

## License

Luno is available under the MIT license. See the [LICENSE](LICENSE) file for details.
