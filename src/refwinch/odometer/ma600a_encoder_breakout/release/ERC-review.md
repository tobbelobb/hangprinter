# Electrical-rule review — v0.3

Date: 2026-09-09. Sources: released native schematic, KiCad-exported netlist, retained `reference/handoff-netlist.csv`, and final native PCB.

**Native KiCad 10.0.6 ERC passed: zero errors, warnings or exclusions.** Native PCB DRC also passed, with zero unconnected items and zero schematic-parity findings after copper-zone refill. Both checks used `--severity-all --exit-code-violations`. Machine-readable evidence is in `ERC.json` and `DRC.json`; human-readable reports are `ERC.txt` and `DRC.txt`.

The first KiCad 10 parity check identified missing footprint fields and missing net names on eight intentionally unconnected pads. Footprint MPN/manufacturer/datasheet fields now match the schematic. Each NC pad has its own isolated schematic-derived net name; U1 exposed pad 17 remains electrically floating. Copper zones and fabrication exports were refreshed with KiCad 10.

No finding exclusions were added and no rule severities were lowered. “All severities” does not turn on optional ignored checks. The JSON reports list the configured/default ignored checks explicitly: ERC ignores single-global-label, four-way-junction, SPICE-model and footprint-filter checks; DRC ignores missing-courtyard, track-centering, tuning-profile, footprint-filter, PTH/NPTH-in-courtyard and footprint-type checks. These are not hidden waived findings. Connectivity, shorts, clearances and schematic parity were checked.

The schematic analyzer reports no unconnected pins, single-pin nets or multiple-driver nets. Eight intentional no-connect markers cover unused sensor pins, its exposed pad, fixed-regulator FB and J1 pin 6. Its three no-driver observations are SPI_COPI, SPI_CS and SPI_SCLK: those inputs are driven by an external pogo fixture, which is not an onboard component. Power flags identify external 5 V and ground. The LDO output is a power-output pin.

Independent checks compare every handoff pin to both KiCad's native exported netlist and PCB pad assignments, then check land-pattern dimensions, magnetic clearance, centroid transforms, fitted-part references, populated MPN fields and native PCB DRC. Result: **182 passed, 0 failed**. `Pin-verification.csv` contains the pin-level comparison; `Verification.json` contains the full checks and source hashes. The retained handoff netlist remains a source of intent, not independent proof of component pinouts: U1 and U2 were additionally checked against MPS datasheets and J1 against JST's drawing.

The generic IO pins in the supplied U1 symbol are bidirectional because they are configurable. Static/ERC checks cannot establish that a programmed IC uses the intended default A/B/Z mapping. The first-article functional test must do that. Off-board supplies, controller thresholds, cable wiring, NVM settings and magnetic behavior are outside static connectivity verification.
