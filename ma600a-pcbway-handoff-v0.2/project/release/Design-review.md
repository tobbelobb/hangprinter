# MA600A RefWinch encoder v0.3 — pre-fabrication review

Reviewed 2026-09-09. Scope: schematic capture, land patterns, complete two-layer placement/routing, fills, production exports and five-board first-article package. This is the first completed PCB implementation of the supplied v0.2 consulting handoff.

**Verdict: suitable to submit for a five-board prototype fabrication/assembly quote, with the documented ERC coverage limitation and bench-test risks accepted by the owner.** No unresolved native PCB DRC violation or known handoff/netlist/PCB mismatch remains. This is not a production qualification. Native schematic ERC was unavailable through the installed KiCad 7 CLI; static review was performed instead. See `ERC-review.md` before fabrication approval.

## Evidence and coverage

| Check | Result | Confidence / evidence |
|---|---|---|
| Native PCB design-rule check | 0 violations, 0 unconnected pads, 0 footprint errors | High; `DRC.txt`, KiCad 7.0.11 pcbnew DRC |
| Independent release checks | 182 pass, 0 fail | High for checked invariants; `Verification.json`, `Pin-verification.csv` |
| Schematic static checks | No disconnected pins, single-pin nets or multiple drivers; three expected external-SPI no-driver observations | High for parsed connectivity; no native ERC coverage |
| Schematic/PCB cross-analysis | 0 findings | High for compared data; skill analyzer cache |
| Sensor pinout / land pattern | Matches MPS datasheet; TEST grounded, EP floating | High; MA600A pages 5 and package drawing, native pad comparison |
| Regulator pinout / land pattern | Fixed 3.3 V variant; EN→VIN, FB NC; custom MPS recommended lands | High; MP20056 datasheet and pad comparison |
| Magnetic component clearance | Minimum other-component pad edge 6.19 mm from U1 center | High geometry; physical distortion remains unmeasured |
| Keepout enforcement | Copper-pour prohibition plus custom footprint rule; intentionally moved-capacitor negative control rejected | High; native DRC negative-control report retained in analysis only |
| Gerber/drill structure | 9 Gerber layers, 39 plated drills; empty NPTH file | High; native export and separate Gerber parser |
| Visual review | Actual Gerber top/bottom copper and drill alignment, top paste; schematic and assembly PDFs inspected | High for visible geometry; not a fabrication CAM signoff |
| BOM / placement | Seven fitted parts, exact MPNs, all top; positions checked against native PCB | High; native schematic fields and PCB export |
| Deep datasheet review | 4 findings evidence-verified, 0 quarantined | High for cited facts; `analysis/deep_review.json` and evidence gate |
| Lifecycle / stock | Automated lookup returned unknown for all seven parts; exact active IC listings checked manually | Partial; no assembler inventory/reservation or complete lifecycle certification |
| Thermal | Low estimated LDO dissipation; calculation below | Medium; estimates depend on load, ambient and actual PCB thermal resistance |
| EMC | Residual return-path and cable risks retained below | Medium heuristic; no emissions or immunity measurements |

Native sources are self-contained KiCad 7 format, usable in newer KiCad versions. KiCad 9 was named in the original brief; the installed tool is 7.0.11, so the actual version is stated rather than claiming a KiCad 9 build. A STEP assembly is not supplied because verified complete component 3D models were not available. The dimensioned PDF provides the assembly/mechanical reference.

## Component summary and power tree

Seven parts are installed: U1 MA600A sensor, U2 MP20056 fixed 3.3 V regulator, J1 six-pin JST-GH connector and C1–C4 ceramic capacitors. Exact purchasing codes are in `BOM.csv`. C1 is 2.2 µF at VIN, C2 4.7 µF at the LDO output, C3 1 µF at AVDD and C4 0.1 µF at DVDD. J1 supplies 5 V to U2; its 3.3 V output feeds both sensor supply pins. Ground joins J1, U2, both sensor ground/TEST pins and capacitor returns; exposed pad 17 remains isolated.

Analyzer scripts actually run: `analyze_schematic.py`, `analyze_pcb.py --full`, `cross_analysis.py`, `analyze_emc.py`, `analyze_thermal.py`, `analyze_gerbers.py`, `lifecycle_audit.py` (LCSC-only attempt, unknown results), and `deep_review_gate.py`. Native KiCad exports/DRC and the independent `verify_release.py` supplement those analyzers. Actual exported Gerbers were rendered with Gerbonara 1.6.3, independently of KiCad's board preview; top mask openings were also inspected.

## Design and manufacturing decisions

The finished board is 28 × 12 mm, 1.0 mm FR-4, two copper layers. U1 remains at (4,6) mm; the GH connector exits at the opposite end. The layout uses 0.20 mm signal and 0.30 mm supply traces, 0.60/0.30 mm vias and 0.15 mm minimum copper clearance. There are 358 track segments, 39 vias, two filled ground zones, seven test pads and three fiducials. Ground stitching was added behind the magnetic keepout.

The 5 mm magnetic exclusion is deliberately different from a blanket copper exclusion. MPS recommends separation from potentially magnetic components; minimum necessary sensor connections remain. Other component pad edges are at least 6.19 mm away, and pours start behind the tip. The sensor EP has an isolated 1.7 mm square land without a thermal via, with four 0.7 mm square paste windows. U2 uses the MPS recommended TSOT23-5 land dimensions; J1 uses the installed JST-GH library footprint, checked against the manufacturer drawing.

Lead-free HASL is specified in the order guide to avoid adding a nickel finish near the sensor. Assembly flatness/stencil suitability requires ordinary assembler DFM confirmation. Small-board panelization/rails and panel fiducials are also delegated to the fabricator's normal manufacturing process, without changing the circuit or finished board.

## Findings that remain relevant

1. **External back-power risk — high confidence, datasheet.** TP7 is connected to the LDO output. Feeding it externally can back-power VIN; use it only for measurement. The schematic and order instructions now say so. This is an operating constraint, not an unresolved routing defect.
2. **Magnetic and mechanical performance — high confidence that testing is missing.** No fabricated board or actual orbiting magnet has been measured. The required component clearance is satisfied, but it does not establish accuracy or usable orbit radius. Validate the actual magnet, steel hardware and offsets before scaling beyond five units.
3. **Cable/EMC robustness — medium confidence, layout heuristics.** The deliberate sensor-tip ground exclusion reduces return-plane coverage. The analyzer estimates roughly 62% for COPI, 88% for CIPO and 92% for SCLK, and flags several layer transitions without a ground via within 1 mm. Ground fill is about 57% of the front layer; about 61% of the perimeter is grounded. These are credible tradeoffs in this constrained magnetic layout, not proof of compliance failure. SPI is a short, occasional pogo connection; begin slowly and inspect waveforms. ABZ cable behavior must be checked with the motor/controller at maximum intended speed.
4. **Protection and receiver compatibility — high confidence, schematic.** There is no ESD network, line driver or added output damping in the authorized first-article circuit. Verify 3.3 V receiver thresholds, cable mapping and loading. Use a protected nominal 5 V supply; this is not a demonstrated hot-plug or harsh-environment interface. Add protection/damping in a later revision if tests show it is necessary.
5. **Availability — partial evidence.** Exact purchasing part numbers are provided, but stock, lead times and all-passive lifecycle states were not established. PCBWay must source the BOM during the quote and flag any proposed substitute for review.

## Automated findings adjudicated

The PCB analyzer reports nine KO-001 via-in-keepout errors. These are false positives for this design: it does not honor the explicit rule-area allowance for vias. Native KiCad enforces the actual rules and reports zero violations. The extra custom rule excludes other footprints while allowing U1. No rule is waived merely to silence a physical violation.

The decoupling heuristic prefers capacitors within 3 mm and flags the remote sensor capacitors. MPS's explicit magnetic-component spacing requirement takes precedence. The capacitors remain connected through dedicated supply routes; supply ripple and behavior still need bench validation.

PM-002 reports TP7 close to the board edge using a conservative footprint boundary. Its actual pad copper has 1.0 mm clearance to the top edge, above the 0.25 mm design rule. Small fiducials and handling edges are addressed by assembler-added panel rails.

GR-004 compares 41 paste apertures to 87 front copper flashes and flags low coverage. The count is exactly explained: subtract 39 vias, seven test pads and three fiducials (49 non-paste flashes), then add three because the single sensor EP copper flash has four paste windows: 87 − 49 + 3 = 41. Actual paste layers were visually reviewed; bottom paste is intentionally empty.

The EMC clock-to-connector heuristic is conservative for a 28 mm board with an occasional external SPI fixture. It is retained as context, not converted to a claim of measured signal integrity. Raw analyzer scores are screening aids; their severity totals include these adjudicated findings.

## Power and temperature

The ±2% nominal regulator accuracy gives 3.234–3.366 V, within the sensor's 3.0–3.6 V supply range. This is an accuracy comparison, not a complete transient or all-temperature guarantee. At a declared 50 mA total output budget and 5.25 V input, a conservative calculation using 3.234 V output and 0.33 mA quiescent current gives 102.53 mW LDO dissipation. Using the datasheet's 220 °C/W figure gives approximately 82.56 °C junction at 60 °C ambient. Actual thermal resistance depends on this board and mounting, so measure current and temperature on the first article.

The automatic thermal analyzer uses a more optimistic generic package estimate (about 40 °C junction at 25 °C ambient); the explicit calculation above supersedes that estimate. Sensor self-heating and output switching load are not comprehensively simulated. The 50 mA value is a design budget, not a claimed measured consumption or guaranteed worst-case IC current.

## What changed from the handoff / prior analysis

Completed schematic and local symbols; verified custom IC footprints; placed and routed the board; implemented magnetic rules; added stitching, fiducials and explicit power flags; generated BOM and centroid from the final sources; produced assembly/schematic PDFs and fabrication layers. Earlier same-session drafts had a redundant via, missing fiducials and silkscreen clearances that were corrected. There was no earlier completed user PCB against which to claim an electrical revision delta. The original handoff netlist is unchanged.

## Explicit limitations and next gate

Native schematic ERC, SPICE simulation (no supported simulator installed), full real-time lifecycle/stock coverage, complete 3D collision analysis, transient/ESD simulation and physical EMC/thermal/magnetic testing were not performed. C1's manufacturer specification was checked on the web, but its PDF download was unavailable; local passive PDFs cover C2–C4. No manufacturer-wide certification or production-readiness claim follows from these checks.

Submit the package for the normal fabrication/assembly quote and CAM/DFM review. Resolve any reported production conflict against these sources before accepting changes. After assembly, execute `First-article-checklist.md`. Passing those physical tests is the gate to a larger run.

## Primary references

- [MPS MA600A datasheet](https://www.monolithicpower.cn/cn/documentview/productdocument/index/version/2/document_type/Datasheet/lang/EN/sku/MA600A): pinout, supply/output limits, magnetic layout and package recommendations. Local `datasheets/MA600A.pdf`.
- [MPS MP20056 datasheet](https://www.monolithicpower.cn/cn/documentview/productdocument/index/version/2/document_type/Datasheet/lang/en/sku/MP20056/): fixed-output connections, reverse-current behavior, thermal data and recommended lands. Local `datasheets/MP20056.pdf`.
- [JST GH connector catalog](https://www.jst-mfg.com/product/pdf/eng/eGH.pdf): connector geometry and numbering. Local `datasheets/JST-GH.pdf`.
- [PCBWay assembly file requirements](https://www.pcbway.com/assembly-file-requirements.html) and [assembly capabilities](https://m.pcbway.com/assembly-capabilities.html): production inputs and panelization.
