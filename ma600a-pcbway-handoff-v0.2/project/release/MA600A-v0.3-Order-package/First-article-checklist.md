# First-article validation

## Before ordering

- [x] Open and verify the project using KiCad 10.0.6
- [x] Verify MA600A symbol pins against Rev. 1.0 datasheet
- [x] Verify QFN land pattern against MPS recommended pattern
- [x] Verify MP20056GJ-33 pin 4 treatment for fixed output
- [x] Verify JST-GH footprint and pin numbering
- [x] Add 5 mm circular magnetic keepout around U1
- [x] Static electrical checks and 182 independent source/netlist/PCB/release checks passed
- [x] Native KiCad 10 ERC: zero errors, warnings or exclusions; reports included
- [x] Native KiCad 10 schematic-to-PCB parity: zero findings after synchronization
- [x] DRC clean
- [x] Gerber visual inspection
- [x] BOM and centroid generated from same revision

## Electrical first article

- [ ] No-short resistance checks before power
- [ ] Apply 5.0 V with current limit
- [ ] Measure +3V3 rail
- [ ] Verify current consumption is plausible
- [ ] Verify A/B quadrature with hand-rotated magnet
- [ ] Verify Z occurs once/rev
- [ ] Verify direction convention
- [ ] Read MA600A over SPI
- [ ] Confirm factory 512-PPR behavior

## RefWinch magnetic/mechanical test

Use the actual proposed magnet and odometer shaft.

- [ ] Measure operation at orbit radius 4 mm
- [ ] 6 mm
- [ ] 8 mm
- [ ] 10 mm
- [ ] 12 mm if field remains sufficient
- [ ] Record MA600A field-strength diagnostic / signal quality if available
- [ ] Record missing/extra AB edges over >=100 revolutions in each direction
- [ ] Test rapid direction reversals
- [ ] Test likely shaft/steel hardware configuration
- [ ] Check whether PCB/capacitor placement produces periodic angle error

## Release criterion

Tag v1.0 fabrication-ready only when the first-article board passes electrical tests and the intended orbiting-magnet geometry has been physically measured.
