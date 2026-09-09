# Placement specification

Nominal board outline: **28 mm x 12 mm**, 2-layer, 1.6 mm FR-4, single-sided assembly.

Coordinate origin: lower-left corner, component-side view.

| Ref | Nominal center (mm) | Purpose |
|---|---:|---|
| U1 MA600A | (4.0, 6.0) | sensor at board tip |
| C3 | (10.2, 4.8) | AVDD 1uF; >6mm from U1 center |
| C4 | (10.2, 7.2) | DVDD 0.1uF; >6mm from U1 center |
| U2 LDO | (14.0, 6.0) | 5V -> 3.3V |
| C1 | (14.0, 2.8) | LDO input |
| C2 | (14.0, 9.2) | LDO output |
| TP row | x=18..24 | SPI / power fixture pads |
| J1 JST-GH | (24.0, 6.0) | cable exits away from magnet |

### Keepout

Circle of radius **5.0 mm minimum** around U1 center:

- no capacitors
- no regulator
- no connector
- no mounting holes/screws
- no test pads
- no copper pours
- only essential U1 signal/supply traces

Target practical placement is >=6 mm for any discrete component.

### Mounting

Do not put a steel screw near U1. v0.1 assumes the board slides/clips into a printed holder. If holes are needed later, place them near the connector end, >12 mm from U1 center, and prefer non-magnetic hardware.
