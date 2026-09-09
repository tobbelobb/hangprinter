# KiCad capture instructions

The source-of-truth electrical connectivity is `netlist.csv`; placement constraints are in `placement.md`.

The next EDA step is intentionally explicit rather than shipping an unvalidated hand-written KiCad file:

1. KiCad 9 project name: `MA600A-RefWinch-Encoder`.
2. Create custom U1 symbol from the MA600A datasheet pin table.
3. Use MPS QFN-16 3x3 recommended land pattern: 0.5 mm pitch; verify every dimension against Rev. 1.0 page 48.
4. Exposed pad is a physical pad with no net; do not connect it to GND.
5. Use standard `Package_TO_SOT_SMD:SOT-23-5` / verified TSOT23-5 footprint for U2 after checking pin numbering.
6. Use `Connector_JST:JST_GH_SM06B-GHS-TB_1x06-1MP_P1.25mm_Horizontal` for J1 or manufacturer-equivalent verified footprint.
7. Implement a 5 mm circular footprint/board keepout around U1 center for components and pours.
8. Place C3/C4 outside keepout but route AVDD/DVDD to them with short, low-impedance traces.
9. No copper fill inside keepout; keep essential traces minimal.
10. All SMT on front side.
11. Run ERC/DRC and inspect Gerbers before release.

A hand-authored `.kicad_pcb` is deliberately not included in v0.1 because this environment does not have KiCad installed to validate it. The manufacturing release should contain EDA-generated files, not syntactically plausible but unchecked artwork.
