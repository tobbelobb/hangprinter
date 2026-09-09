# Electrical-rule review — v0.3

Date: 2026-09-09. Sources: released native schematic, KiCad-exported netlist, original `hardware/netlist.csv`, and final native PCB.

**Native KiCad ERC was not run.** Installed KiCad 7.0.11 does not expose ERC in its command-line interface. This report is a static electrical-rule review and independent connectivity check, not a claim of a clean native ERC report. Anyone requiring a native ERC acceptance artifact should run Inspect → Electrical Rules Checker in KiCad on the supplied project before authorizing fabrication.

The schematic analyzer reports no unconnected pins, single-pin nets or multiple-driver nets. Eight intentional no-connect markers cover unused sensor pins, its exposed pad, fixed-regulator FB and J1 pin 6. Its three no-driver observations are SPI_COPI, SPI_CS and SPI_SCLK: those inputs are driven by an external pogo fixture, which is not an onboard component. Power flags identify external 5 V and ground. The LDO output is a power-output pin.

Independent checks compare every handoff pin to both KiCad's native exported netlist and PCB pad assignments, then check land-pattern dimensions, magnetic clearance, centroid transforms, fitted-part references, populated MPN fields and native PCB DRC. Result: **182 passed, 0 failed**. `Pin-verification.csv` contains the pin-level comparison; `Verification.json` contains the full checks and source hashes. The original handoff remains a source of intent, not independent proof of component pinouts: U1 and U2 were additionally checked against MPS datasheets and J1 against JST's drawing.

The generic IO pins in the supplied U1 symbol are bidirectional because they are configurable. Static/ERC checks cannot establish that a programmed IC uses the intended default A/B/Z mapping. The first-article functional test must do that. Off-board supplies, controller thresholds, cable wiring, NVM settings and magnetic behavior are outside static connectivity verification.
