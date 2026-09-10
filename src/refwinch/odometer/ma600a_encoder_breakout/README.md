# MA600A RefWinch Encoder Breakout

A small magnetic incremental encoder board for the Hangprinter RefWinch odometer. The mechanical odometer model is in the sibling [`../odometer.scad`](../odometer.scad); this directory contains the electrical board project and its reviewed v0.3 manufacturing release.

**Status:** v0.3 KiCad schematic, routed PCB and five-board first-article manufacturing package completed. Start with [ordering instructions](release/ORDER-INSTRUCTIONS.md) and [design review](release/Design-review.md). KiCad 10.0.6 native ERC, DRC and schematic parity pass with zero findings; 182 independent checks pass. Physical first-article validation remains. No order has been placed.

**Applicable RefWinch variants:** buildup and no-buildup. The board measures the odometer wheel, independent of collector-spool architecture.

## Design goal

A cheap, keyed, no-MCU magnetic encoder board that can plug into a motor controller such as CLN17 and output native A/B/Z quadrature.

## Architecture

```text
JST-GH 6-pin
5 V ────────┐
            │   MP20056GJ-33
            └──► 3.3 V LDO ─────────┐
GND ───────────────────────────────┐ │
                                   │ │
                             ┌─────▼─▼─────┐
                             │   MA600A    │
                             │             │
                        A ◄──┤ IO2         │
                        B ◄──┤ IO4         │
                        Z ◄──┤ IO3         │
                             │             │
SPI pogo pads: /CS,SCLK,COPI,CIPO         │
                             └─────────────┘
```

## Main connector

J1: JST-GH 6-pin, right-angle, `SM06B-GHS-TB(LF)(SN)`.

| Pin | Signal | Direction | Notes |
|---:|---|---|---|
| 1 | GND | power | 0 V |
| 2 | +5V | input | nominal 5 V from controller |
| 3 | A | output | 3.3 V push-pull quadrature A |
| 4 | B | output | 3.3 V push-pull quadrature B |
| 5 | Z | output | 3.3 V push-pull index |
| 6 | RSV | — | no-connect in v0.1 |

Using our own connector makes the sensor PCB independent of CLN17-V3 connector revisions. The CLN17 end is handled by a cable mapping.

## Default behavior

The MA600A factory-default interface maps IO2=A, IO4=B, IO3=Z. Factory-default quadrature resolution is 512 pulses/rev (2048 edges/rev), so the board works without configuration. Resolution can later be stored in the MA600A NVM from 1 to 4096 pulses/rev.

## Magnetic-layout rule

The MA600A sits at the **tip of the PCB**. All capacitors, regulator, connector, mounting holes, and test pads are kept at least 5 mm from the sensor center; v0.1 targets 6 mm or more. No ground pour is planned inside the magnetic keepout except the minimum traces required by the sensor.

This is unusually important: MPS documents measurable magnetic distortion from nearby SMD capacitors and recommends at least 5 mm distance.

## Power

The MA600A requires 3.3 V. The board therefore uses an `MP20056GJ-33` low-noise LDO from the 5 V encoder supply.

- C1: 2.2 uF LDO input bypass
- C2: 4.7 uF LDO output bypass
- C3: 1 uF MA600A AVDD bypass
- C4: 0.1 uF MA600A DVDD bypass
- LDO EN tied to VIN
- LDO FB left open for the fixed 3.3 V version

## Project layout

- `kicad/` — editable, self-contained KiCad sources and local libraries
- `release/` — current v0.3 Gerber ZIP, BOM, centroid, PDFs, reports and order instructions
- `tools/` — design-generation and release-verification utilities
- `reference/` — retained handoff netlist used to reproduce and verify the design
- `production-test/` — Arduino SPI/NVM programmer, BCT commissioning guide and printable pogo guide
- `docs/` — design decisions and source notes
- `analysis/` — current machine-readable review evidence and run manifest

## Current deliverables and remaining validation

Use the v0.3 release for manufacturing. Start with [`release/ORDER-INSTRUCTIONS.md`](release/ORDER-INSTRUCTIONS.md), then read [`release/Design-review.md`](release/Design-review.md) before ordering five first articles. The electrical design and release checks are complete; physical board, cable, controller and actual magnet-geometry tests remain the gate before a larger run.

## Primary references

- MPS MA600A datasheet: https://www.monolithicpower.com/en/documentview/productdocument/index/version/2/document_type/Datasheet/lang/EN/sku/MA600A
- MPS MP20056 datasheet: https://www.monolithicpower.com/en/documentview/productdocument/index/version/2/document_type/Datasheet/lang/en/sku/MP20056/
- Chinese MA600A + MP20056GJ reference project: https://oshwhub.com/mps-core-source-square/ma600a-mp20056gj
- Project-structure benchmark (not circuit source): https://github.com/Westly-Bouchard/AS5047P-Board

## License

Not selected yet. Choose an open-hardware license before publishing the repository.
