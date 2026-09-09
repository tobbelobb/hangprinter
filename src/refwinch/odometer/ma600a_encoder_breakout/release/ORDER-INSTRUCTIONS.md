# MA600A v0.3 — five assembled first articles

The schematic, routed PCB and manufacturing files are complete. Order through PCBWay's normal **PCB fabrication + PCB assembly** service. This replaces the original request for schematic/layout consulting. No order has been submitted.

This is an electrically reviewed prototype release. Magnet geometry, the controller cable and operation on real hardware still require the tests below. KiCad 10.0.6 native ERC, DRC and schematic parity pass with zero findings; 182 independent checks pass. The reports are included.

## Step through the order

1. Extract the current `MA600A-v0.3-Order-package.zip`. Use these refreshed files, which include KiCad 10 native check reports.
2. Sign in and open [PCBWay Standard PCB quote](https://www.pcbway.com/orderonline.aspx). Upload `MA600A-v0.3-Gerbers.zip`.
3. Enter the settings in the table below: 28 × 12 mm, five individual boards, two layers, FR-4, 1.0 mm, 1 oz, green mask, white legend, lead-free HASL.
4. Select **Panel by Supplier**, handling rails, and **Panel as PCBWay prefer** where offered. Keep the requested delivered quantity at five individual boards; the supplier determines the panel arrangement.
5. In the **Assembly Service** section, select **Turnkey**, **Single pieces**, **Top side**, quantity **5**, and leave “Do you accept alternatives/substitutes made in China?” set to **No**. The screen shown in the screenshot is this parameter page. Leave **Single pieces** selected because the supplied Gerbers describe one finished board; PCBWay should panelize that design for assembly.
6. Click the green **Calculate** button at the bottom. Save the calculated assembly quote to the cart, then continue to **Submit Order Now**. The file-upload page appears after this step; it is not shown on the parameter page.
7. On that upload page, put `BOM.csv` in **BOM / Parts List**, `Pick-and-place.csv` in **Centroid / Pick-and-Place**, and `Assembly-drawing.pdf`, `Schematic.pdf` and these instructions in **Assembly Other Files**. The drawing is an assembly reference, not a Gerber or PCB fabrication file.
8. Add the order note below. Submit for fabrication/assembly review and quotation.
9. Review the final quote for five assembled, depanelized boards, exact BOM parts, finish and shipping. Resolve any substitution or manufacturing change before paying and releasing production.
10. On delivery, follow the acceptance tests at the end of this document and `First-article-checklist.md`.

The field names above follow PCBWay's current assembly workflow: click **Calculate**, save to cart, then upload BOM, centroid and other assembly files on the submission page. BOM and centroid are required assembly files, while assembly drawings and special instructions belong in the optional “Other Files” area. [PCBWay file requirements](https://www.pcbway.com/assembly-file-requirements.html). If the upload page offers **Skip**, you can continue and upload later from **Order List → Under Review → Upload Files**. If a size/quantity field switches to panel units, ask the quote reviewer to confirm that the total delivered quantity remains five boards.

### If PCBWay shows “Audit Failed: Lack of the Bottom Soldermask layer”

Click **Re-upload File** on the red **PCB Production** order and upload the refreshed `MA600A-v0.3-Gerbers.zip` from this package. Do not re-use the earlier ZIP. The refreshed bottom-mask file contains one deliberate 0.70 mm opening around the existing GND stitching via at (119.7, 103.5) mm; the rest of the bottom remains masked. In any “Other special request” or comment field, paste: “Bottom soldermask is intentionally closed except for the one 0.70 mm GND-via opening at (119.7, 103.5) mm; please keep this opening and do not remove the bottom mask.” If the linked assembly order has its own Gerber upload control, replace that copy with the same refreshed ZIP as well; BOM and centroid are unchanged. PCBWay documents this exact empty-mask audit behavior and asks customers to state whether the whole side should be covered. [PCBWay empty solder-mask guidance](https://www.pcbway.com/helpcenter/file_issues/Solder_mask_file_is_empty_or_None.html)

### Order note to paste

> MA600A RefWinch encoder v0.3, KiCad 10 checked release. Please fabricate and turnkey assemble five individual boards, top side only, and deliver depanelized. Supplier panelization, handling rails and panel fiducials required; preserve the supplied 28 × 12 mm finished outline and circuit. Use exact BOM parts. U1 exposed pad 17 is electrically floating: do not ground it or add thermal vias. Confirm lead-free HASL suitability for the 0.5 mm-pitch QFN and use the supplied paste layer. Match U1/U2/J1 pin 1 to the assembly drawing. No programming required. The bottom solder-mask Gerber contains one intentional 0.70 mm opening around an existing GND stitching via at (119.7, 103.5) mm; keep it as a plated GND probe point and do not interpret it as a missing mask layer. Flag proposed substitutions or design changes before manufacture.

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
| Material | FR-4, **1.0 mm finished thickness** |
| Copper | 2 layers, 1 oz finished outer copper |
| Mask / legend | Green solder mask, white top legend |
| Surface finish | Lead-free HASL; assembler to confirm suitability for 0.5 mm-pitch QFN during normal DFM |
| Minimum design clearance | 0.15 mm copper; 0.25 mm copper to edge |
| Minimum trace / spacing quote fields | **0.20 mm / 0.15 mm** (8 / 6 mil). If PCBWay provides one combined “Min track/spacing” choice, select **6 / 6 mil**; the board’s narrowest track is 0.20 mm and its narrowest spacing is 0.15 mm. |
| Vias | 0.60 mm diameter / 0.30 mm finished drill; 39 plated holes |
| Minimum hole size | **0.30 mm finished hole** (12 mil); all holes are plated vias and there are no component or mounting holes |
| Impedance control | None |
| Electrical test | Bare-board electrical test |
| Panel | PCBWay to panelize for assembly, add tooling rails and panel fiducials, and deliver depanelized boards |

The individual board is below PCBWay's assembly handling size. Panelization is therefore part of the manufacturing job. Keep the supplied finished outline, placements and copper unchanged; use routed tabs/rails clear of components, including the overhanging connector. Do not add holes or residual metal near the sensor tip. PCBWay's [assembly capabilities](https://m.pcbway.com/assembly-capabilities.html) specify panelization for small boards; its [assembly FAQ](https://www.pcbway.com/assembly-faq.html) also describes handling rails. The quantity above is boards, not panels.

### Thickness warning

The quote form may preselect **1.6 mm** after Gerber upload because that is a common default. Change it to **1.0 mm** before continuing. The Gerber job file explicitly records `BoardThickness: 1.0`, and the editable KiCad board is also 1.0 mm. A 1.6 mm board would be mechanically wrong for this design even though the copper artwork would look unchanged in the viewer. PCBWay lists both 1.0 and 1.6 mm as available standard choices, so select the value specified here. [PCBWay standard thickness options](https://www.pcbway.com/capabilities.html)

The selected finish avoids an intentional nickel finish near the magnetic sensor. Flatness and stencil compatibility need the assembler's ordinary process review. If it proposes ENIG or a different finish, review that change before accepting it; it is not included in this release's magnetic-performance evidence.

## Assembly notes

- Use the exact seven manufacturer part numbers in `BOM.csv`. Quantities are per board; PCBWay determines purchasing attrition for five assemblies. No unreviewed IC or connector substitutions.
- U1 is **MA600AGQE-0000-Z**. Its exposed pad 17 is soldered mechanically but **electrically floating**. Do not connect it to ground or add a thermal via. The supplied top paste has four 0.7 × 0.7 mm windows, about 68% coverage of its 1.7 mm square copper land.
- U2 is the fixed **MP20056GJ-33-Z**. EN is tied to VIN; FB pin 4 is deliberately unconnected. Use the custom supplied MPS footprint, not an arbitrary SOT-23 substitute.
- J1 is **SM06B-GHS-TB(LF)(SN)**. The cable exit points away from U1, beyond the right edge. Confirm U1/U2/J1 pin 1 against the drawing when preparing machine rotations. The CSV uses native KiCad angles; do not assume another machine's zero-degree convention.
- TP1–TP7 and FID1–FID3 are bare copper features, not purchased parts. No parts are fitted on the bottom. The NPTH drill file is intentionally empty.
- The bottom mask is intentionally closed everywhere except one 0.70 mm opening around the existing GND stitching via at (119.7, 103.5) mm. This explicit opening is present so the PCBWay audit recognizes the bottom-mask layer; it is a useful ground probe and has no component-placement function.
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
