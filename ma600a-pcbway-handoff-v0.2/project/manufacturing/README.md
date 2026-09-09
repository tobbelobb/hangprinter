# Manufacturing package status

This directory intentionally does **not** contain Gerbers yet.

The BOM and centroid are design inputs/drafts. The final BOM, position file and Gerbers must be exported from the KiCad source after ERC/DRC. Do not upload `Centroid-draft.csv` as a production placement file.

## Target process

- 2-layer FR-4
- 1.6 mm board
- 1 oz copper
- lead-free HASL or ENIG
- single-sided SMT assembly
- nominal outline 28 x 12 mm
- no panelization required for first article unless assembler requests it

## Assembly notes

1. U1 orientation is critical; verify pin 1 against MPS package drawing.
2. U1 exposed pad is electrically NC/floating. Do not connect it to GND.
3. Keep magnetic materials away from the U1 tip during inspection/fixture design.
4. All components other than U1 must remain outside the 5 mm magnetic keepout.
5. Use non-magnetic fixture hardware near the sensor if possible.
6. Program NVM only if a release specifies a non-default PPR/configuration.

## First order

Order **5 assembled boards**. Do not jump directly to 10–100 until the orbiting-magnet test passes.
