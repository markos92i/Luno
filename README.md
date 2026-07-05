# Luno

Componente calendario SwiftUI con soporte para selección individual y por rango. Tint-based, sin dependencias externas, dark mode adaptativo.

## Uso básico

```swift
import Luno

@State var selection: CalendarSelection = .single(nil)

LunoCalendarView(selection: $selection)
    .tint(.blue)
```

## Modos de selección

### Single

Selecciona un día. Tap de nuevo para deseleccionar.

```swift
@State var selection: CalendarSelection = .single(nil)
```

### Range

Primer tap marca inicio, segundo tap extiende el rango. Tercer tap resetea.

```swift
@State var selection: CalendarSelection = .range(nil)
```

Acceso al rango seleccionado:

```swift
if let range = selection.range {
    print("Desde \(range.start) hasta \(range.end)")
}
```

## Eventos

Los eventos se muestran como dots de color debajo de cada día (máximo 3 visibles por día):

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

## Tint (color scheme)

El componente no usa colores hardcoded. Toda la gama se deriva del `.tint` del view hierarchy:

- Selección: `.tint` al 100%
- Hoy (no seleccionado): ring con `.tint`
- Rango: stroke con `.tint` a baja opacidad (12% light, 20% dark)
- Texto normal: `.primary`
- Texto seleccionado: `.white`

```swift
// Azul
LunoCalendarView(...).tint(.blue)

// Brand custom
LunoCalendarView(...).tint(.brandPrimary)

// Por pantalla
LunoCalendarView(...).tint(.indigo)
```

## Configuración

```swift
let config = CalendarConfiguration(
    calendar: .current,          // Locale y primer día de semana
    minimumDate: Date.now,       // Días anteriores deshabilitados
    maximumDate: someDate,       // Días posteriores deshabilitados
    showEvents: true,            // Mostrar dots de eventos
    fixedHeight: true            // Siempre 6 filas (altura constante)
)

CalendarPagerView(
    selection: $selection,
    events: myEvents,
    configuration: config
)
```

## Control del mes visible

Si necesitas saber/controlar qué mes se muestra (por ejemplo para lazy-load datos):

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

Si no pasas `month`, el calendario lo gestiona internamente.

## Componentes

### LunoCalendarView

Vista principal con header de navegación y paging horizontal por meses.

```swift
// Mínimo
LunoCalendarView(selection: $selection)

// Completo
LunoCalendarView(
    selection: $selection,
    events: myEvents,
    month: $visibleMonth,
    configuration: config
)
```

### CalendarMonthView

Solo la cuadrícula del mes (sin header ni paging). Para integración en layouts custom.

```swift
CalendarMonthView(
    month: someDate,
    selection: $selection,
    events: myEvents,
    onDateTapped: { date in
        // Acción adicional al pulsar un día
    }
)
```

## Animaciones

- **Selección de día**: spring scale pop-in del círculo
- **Ring de hoy**: spring al expandir/contraer cuando se selecciona
- **Rango**: trim animation del path snake que crece desde el primer día seleccionado
- **Dirección**: la animación respeta el sentido — crece forward o backward según el segundo tap
- **Haptic**: `sensoryFeedback(.selection)` al seleccionar/deseleccionar

## Dark mode

Adaptación automática via `@Environment(\.colorScheme)`:

- Opacidad del rango: 12% (light) → 20% (dark)
- Texto: usa `.primary` y `.white` que adaptan solos
- Tint: el mismo color funciona en ambos modos

## Jerarquía visual

| Estado | Texto | Fondo | Extra |
|--------|-------|-------|-------|
| Normal | `.primary` | ninguno | — |
| Hoy | `.tint` | ninguno | ring `.tint` 2pt |
| Seleccionado | `.white` | `.tint` fill | spring scale |
| Hoy + Seleccionado | `.white` | `.tint` fill | ring expandido a 40pt |
| Deshabilitado | `.primary` 30% | ninguno | no interactivo |
| Rango (middle) | `.primary` | strip `.tint` 12% | — |

## Arquitectura

```
Luno/Sources/Luno/
├── LunoCalendarView.swift        — Vista principal con pager horizontal
├── CalendarMonthView.swift       — Cuadrícula mensual con selección y eventos
├── CalendarDayView.swift         — Celda individual (círculo, ring, dots)
├── CalendarRangeOverlay.swift    — Snake path con trim animation
├── CalendarSelection.swift       — .single(Date?) | .range(CalendarRange?)
├── CalendarConfiguration.swift   — Config: calendar, min/max, height
└── CalendarEvent.swift           — Modelo de evento (date + color)
```
