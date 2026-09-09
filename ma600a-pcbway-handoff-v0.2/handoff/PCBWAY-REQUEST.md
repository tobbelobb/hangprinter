# MA600A magnetic encoder breakout — PCBWay design-service request

## Requested service

Please quote **Schematic & PCB Layout** in **KiCad**, followed by fabrication and assembly of **5 first-article boards**.

This is a very small magnetic encoder breakout. The attached project package contains the electrical netlist, connector pinout, BOM intent, placement constraints, magnetic keepout requirement, reference links, and first-article test checklist.

Please do **not** treat the draft centroid in the package as manufacturing data. It is illustrative only. Generate final schematic, PCB, BOM and pick-and-place data from the completed KiCad design.

## Product goal

A small, low-cost, no-MCU magnetic incremental encoder board for a line-length odometer. It is powered from nominal 5 V and outputs native 3.3 V push-pull quadrature A/B plus Z index.

The board will be used with an **off-axis/orbiting magnet**, so magnetic cleanliness around the sensor is a first-class requirement.

## Required architecture

- U1: **Monolithic Power Systems MA600A**, preferred orderable part **MA600AGQE-0000-Z** unless MPS identifies a newer directly equivalent order code.
- U2: **MP20056GJ-33** fixed 3.3 V LDO, or the exact MPS-recommended fixed-3.3-V variant after pinout/availability verification.
- J1: **JST-GH 6-pin, 1.25 mm pitch, horizontal SMT**, preferred `SM06B-GHS-TB(LF)(SN)`.
- No MCU.
- No level shifter unless an electrical review proves it necessary; MA600A A/B/Z are intended to connect directly to a 3.3-V-compatible controller input.
- All assembly on one PCB side if practical.

## Main connector pinout

1. GND
2. +5V input
3. A output
4. B output
5. Z output
6. RESERVED / NC

Please put this pinout on the schematic and clearly mark pin 1 on PCB silkscreen.

## MA600A functional configuration

The board must work from factory defaults without an MCU:

- IO2 = A
- IO4 = B
- IO3 = Z
- default ABZ resolution = 512 pulses/revolution

SPI access is still required for production/programming/calibration, but only as compact labeled test pads/pogo pads:

- /CS
- SCLK
- COPI / MOSI
- CIPO / MISO
- GND
- 3V3

Do not put a bulky SPI connector on the production board.

## Magnetic-layout requirements — critical

Use the MPS MA600A datasheet/layout guidance as the design authority.

- Put the MA600A at the **tip/edge of the board** to maximize magnet access.
- Keep **all ferromagnetic and magnetically disturbing components at least 5 mm from the MA600A sensing center**; target 6 mm where practical.
- Keep the regulator, JST connector, mounting hardware, capacitors, test pads and other discrete parts outside this region.
- Avoid copper pours in the magnetic keepout unless MPS guidance indicates otherwise; only essential short sensor traces should enter the region.
- Do not place steel mounting hardware close to the sensor.
- The MA600A exposed pad must follow MPS datasheet guidance; current project notes call for it to be **electrically floating**, so please verify this against the latest datasheet before layout.
- Decoupling must satisfy the electrical datasheet while respecting the magnetic-spacing guidance. If these requirements conflict, please flag the conflict before fabrication rather than silently changing the geometry.

## Target board geometry

Current target: approximately **28 mm × 12 mm**, with the sensor centered near one narrow tip and the JST-GH connector at the opposite end.

The exact outline may be adjusted modestly to make routing/assembly robust. Please prioritize:

1. magnetic cleanliness around U1,
2. simple one-sided assembly,
3. mechanical robustness of the cable connector,
4. low cost,
5. compact size.

Please send a placement screenshot/render for approval before fabrication if you make substantial geometric changes.

## Power

Nominal input: +5 V.

Target 3.3 V rail using the fixed 3.3 V MP20056. Current intended capacitors:

- LDO input bypass: 2.2 uF
- LDO output bypass: 4.7 uF
- MA600A AVDD bypass: 1 uF
- MA600A DVDD bypass: 0.1 uF

Please verify the latest MPS datasheets and adjust values/package sizes only if required. Prefer small non-magnetic MLCCs and keep them outside the magnetic keepout.

## PCB defaults

Unless your engineer sees a reason to change them:

- 2-layer FR-4
- 1.0 or 1.6 mm finished thickness (prefer 1.0 mm if cost/rigidity are reasonable)
- 1 oz copper
- lead-free HASL or ENIG; choose the lower-cost reliable option for QFN assembly
- standard green solder mask is fine
- standard manufacturer design rules; no controlled impedance

## Required deliverables

Please return all of the following to us, even if PCBWay also manufactures the first batch:

1. Complete editable **KiCad project** (`.kicad_pro`, `.kicad_sch`, `.kicad_pcb`, any custom symbol/footprint libraries).
2. Schematic PDF.
3. Gerber + drill ZIP.
4. Final BOM with manufacturer part numbers.
5. Pick-and-place / centroid file.
6. Assembly drawing or clear top-side placement drawing.
7. STEP/3D board model if easily generated.
8. ERC report / confirmation.
9. DRC report / confirmation.
10. Any design assumptions or substitutions made.

We intend to publish the finished hardware as open hardware, so please ensure the deliverables are editable and do not depend on inaccessible proprietary libraries.

## Component substitutions

Do **not** substitute the MA600A for another sensor without approval.

Do **not** change the connector series without approval.

Passives may be substituted with normal assembly-house equivalents of the same electrical specification and suitable package. If the exact MP20056 variant is unavailable, propose an alternative low-noise 5 V to 3.3 V LDO and wait for approval before changing it.

## First-article order

Please quote fabrication + turnkey assembly for **5 boards** after design review.

Before shipping, if possible perform basic electrical checks only:

- no short between 5 V and GND,
- 3.3 V regulator output in tolerance when powered from 5 V,
- visual/AOI inspection of MA600A QFN soldering and connector orientation.

We will perform the magnetic/orbit-angle validation ourselves after receiving the boards. Please do not claim magnetic performance as verified unless you have actually tested it with an appropriate rotating magnet fixture.

## References

Primary design authority:
- MPS MA600A datasheet: https://www.monolithicpower.com/en/documentview/productdocument/index/version/2/document_type/Datasheet/lang/EN/sku/MA600A
- MPS MP20056 datasheet: https://www.monolithicpower.com/en/documentview/productdocument/index/version/2/document_type/Datasheet/lang/en/sku/MP20056/

Secondary reference only — do not copy blindly:
- MA600A + MP20056GJ open reference project: https://oshwhub.com/mps-core-source-square/ma600a-mp20056gj

Repository/manufacturing-package quality benchmark:
- Westly Bouchard AS5047P board: https://github.com/Westly-Bouchard/AS5047P-Board

## Approval gate

Please **do not fabricate** until the completed schematic, PCB placement/layout and BOM have been sent for our review/approval.
