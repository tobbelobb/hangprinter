# MA600A v0.3 — five assembled first articles

The schematic, routed PCB and manufacturing files are complete. Order through PCBWay's normal **PCB fabrication + PCB assembly** service. This replaces the original request for schematic/layout consulting. No order has been submitted.

This is an electrically reviewed prototype release. Magnet geometry, the controller cable and operation on real hardware still require the tests below. KiCad 10.0.6 native ERC, DRC and schematic parity pass with zero findings; 182 independent checks pass. The reports are included.

## Step through the order

1. Extract the current `MA600A-v0.3-Order-package.zip`. Use these refreshed files, which include KiCad 10 native check reports.
2. Sign in and open [PCBWay Standard PCB quote](https://www.pcbway.com/orderonline.aspx). Upload `MA600A-v0.3-Gerbers.zip`.
3. Enter the settings in the table below: 28 × 12 mm, five individual boards, two layers, FR-4, 1.0 mm, 1 oz, green mask, white legend, lead-free HASL.
4. Select **Panel by Supplier**, handling rails, and **Panel as PCBWay prefer** where offered. Keep the requested delivered quantity at five individual boards; the supplier determines the panel arrangement.
5. Add PCB assembly: **Turnkey**, **Top side**, quantity **5**. Upload `BOM.csv`, `Pick-and-place.csv`, `Assembly-drawing.pdf` and these instructions to the corresponding assembly/other-files fields.
6. Add the order note below. Submit for fabrication/assembly review and quotation.
7. Review the final quote for five assembled, depanelized boards, exact BOM parts, finish and shipping. Resolve any substitution or manufacturing change before paying and releasing production.
8. On delivery, follow the acceptance tests at the end of this document and `First-article-checklist.md`.

The field names above were checked against the [current PCBWay quote form](https://www.pcbway.com/orderonline.aspx). If a size/quantity field switches to panel units, ask the quote reviewer to confirm that the total delivered quantity remains five boards.

### Order note to paste

> MA600A RefWinch encoder v0.3, KiCad 10 checked release. Please fabricate and turnkey assemble five individual boards, top side only, and deliver depanelized. Supplier panelization, handling rails and panel fiducials required; preserve the supplied 28 × 12 mm finished outline and circuit. Use exact BOM parts. U1 exposed pad 17 is electrically floating: do not ground it or add thermal vias. Confirm lead-free HASL suitability for the 0.5 mm-pitch QFN and use the supplied paste layer. Match U1/U2/J1 pin 1 to the assembly drawing. No programming required. Flag proposed substitutions or design changes before manufacture.

## Files to upload

| Order field | File |
|---|---|
| PCB fabrication / Gerber | `MA600A-v0.3-Gerbers.zip` |
| Assembly BOM | `BOM.csv` |
| Centroid / pick-and-place | `Pick-and-place.csv` |
| Assembly instructions | `Assembly-drawing.pdf` and this document |
| Additional reference | `Schematic.pdf` |

The outer order-package ZIP contains these files and the editable KiCad source ZIP. Upload the inner Gerber ZIP to the PCB fabrication field. Do not upload the original draft centroid or the old design-service request.

PCBWay requests Gerber, BOM and centroid data for assembly; the supplied centroid contains reference, position, rotation and side. [PCBWay file requirements](https://www.pcbway.com/assembly-file-requirements.html).

## Quote settings

| Setting | Requested value |
|---|---|
| Delivered quantity | **5 individual assembled boards** |
| Assembly | Turnkey sourcing, top side only; seven installed parts per board |
| Finished board | 28.00 × 12.00 mm rectangle; no mounting holes |
| Material | FR-4, 1.0 mm finished thickness |
| Copper | 2 layers, 1 oz finished outer copper |
| Mask / legend | Green solder mask, white top legend |
| Surface finish | Lead-free HASL; assembler to confirm suitability for 0.5 mm-pitch QFN during normal DFM |
| Minimum design clearance | 0.15 mm copper; 0.25 mm copper to edge |
| Vias | 0.60 mm diameter / 0.30 mm finished drill; 39 plated holes |
| Impedance control | None |
| Electrical test | Bare-board electrical test |
| Panel | PCBWay to panelize for assembly, add tooling rails and panel fiducials, and deliver depanelized boards |

The individual board is below PCBWay's assembly handling size. Panelization is therefore part of the manufacturing job. Keep the supplied finished outline, placements and copper unchanged; use routed tabs/rails clear of components, including the overhanging connector. Do not add holes or residual metal near the sensor tip. PCBWay's [assembly capabilities](https://m.pcbway.com/assembly-capabilities.html) specify panelization for small boards; its [assembly FAQ](https://www.pcbway.com/assembly-faq.html) also describes handling rails. The quantity above is boards, not panels.

The selected finish avoids an intentional nickel finish near the magnetic sensor. Flatness and stencil compatibility need the assembler's ordinary process review. If it proposes ENIG or a different finish, review that change before accepting it; it is not included in this release's magnetic-performance evidence.

## Assembly notes

- Use the exact seven manufacturer part numbers in `BOM.csv`. Quantities are per board; PCBWay determines purchasing attrition for five assemblies. No unreviewed IC or connector substitutions.
- U1 is **MA600AGQE-0000-Z**. Its exposed pad 17 is soldered mechanically but **electrically floating**. Do not connect it to ground or add a thermal via. The supplied top paste has four 0.7 × 0.7 mm windows, about 68% coverage of its 1.7 mm square copper land.
- U2 is the fixed **MP20056GJ-33-Z**. EN is tied to VIN; FB pin 4 is deliberately unconnected. Use the custom supplied MPS footprint, not an arbitrary SOT-23 substitute.
- J1 is **SM06B-GHS-TB(LF)(SN)**. The cable exit points away from U1, beyond the right edge. Confirm U1/U2/J1 pin 1 against the drawing when preparing machine rotations. The CSV uses native KiCad angles; do not assume another machine's zero-degree convention.
- TP1–TP7 and FID1–FID3 are bare copper features, not purchased parts. No parts are fitted on the bottom. The NPTH drill file is intentionally empty.
- All placement coordinates are millimetres, viewed from the top, with origin at the lower-left finished-board corner, +X right, +Y up. The bottom copper preview is viewed through the board from the top.
- Maintain the component-free 5 mm radius around the sensor center (4, 6 mm from the lower-left corner). The nearest other component pad edge is 6.19 mm away. Required sensor tracks/vias are allowed there; copper pours and other components are not.
- Ask for inspection of QFN orientation and soldering, including hidden joints where the assembler's process supports it. No NVM programming or functional magnetic fixture is included in this assembly order.

## Power, cable and programming

Supply nominal 5 V (design budget: 4.75–5.25 V) at J1 pin 2, ground at pin 1. Pins 3/4/5 are native 3.3 V A/B/Z outputs; pin 6 is unconnected. Make a cable mapping for the actual controller revision: this is not an assertion that a CLN17 cable is pin-compatible. Check its input thresholds and loading; the MA600A datasheet specifies a 2.4 V minimum high output under its 12 mA test load.

TP1=5V, TP2=GND, TP3=CS, TP4=SCLK, TP5=COPI, TP6=CIPO, TP7=3V3. **TP7 is for measurement only. Never feed it from an external 3.3 V supply.** The LDO can conduct backwards when its output exceeds its input. Use a 3.3 V logic programmer, common ground, and power the board from 5 V only. Avoid driving signal pins while the board is unpowered. Start SPI testing slowly (for example 100 kHz); this is a bring-up recommendation, not a measured maximum.

## Acceptance after delivery

1. Inspect orientation, connector joints and the sensor area. With power off, check for shorts between 5 V, 3V3 and ground.
2. Apply 5.0 V with a bench current limit initially around 30 mA. Investigate a persistent current-limit condition before increasing it. Measure the 3.3 V rail and current; record temperature and operating conditions.
3. Read the MA600A over SPI. Verify A/B phase sequence, direction and Z with a rotating magnet, and confirm the intended factory resolution before relying on edge counts.
4. Connect the actual controller and cable. Check input compatibility, pulse levels/ringing, missing/extra counts, maximum intended speed and rapid reversals with the motor operating.
5. Test the actual odometer shaft/magnet and nearby steel at the intended offsets. Record field diagnostics and counts over at least 100 revolutions in both directions. The original validation checklist covers the proposed 4–12 mm orbit sweep.
6. Increase quantity only after these tests pass. There is no demonstrated magnetic accuracy, EMC compliance, ESD robustness or production yield yet.
