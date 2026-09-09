# Working with the completed design

Open `../kicad/MA600A-RefWinch-Encoder.kicad_pro` in KiCad. Edit the native schematic/PCB as the authoritative working sources. Both custom libraries use `${KIPRJMOD}` and are included. Use KiCad 10 or newer; this release was checked and its PCB saved with 10.0.6.

After source changes, fill copper zones and run native DRC. `export_release.py` exports the native netlist, PDFs, layers, BOM and centroid. `verify_release.py` compares the original handoff netlist and final PCB and checks the release (needs system Python with pcbnew plus the repository KiCad skill parser). `assembly_drawing.py` regenerates the dimensioned assembly PDF. `render_gerbers.py` renders actual fabrication layers (gerbonara and cairosvg required). Regenerate the analysis/review, source archive, package and checksums after any change; old release artifacts do not automatically follow edits in KiCad.

The other scripts preserve the original construction process: build_design, route_board, finish_board, tidy_silk, add_assembly_features, finalize_fiducials. They are construction utilities, not a safe incremental editor; do not run them on a manually edited board, because they regenerate or change sources. The packaged native sources are the completed result and require no script to open or manufacture.

`check_native.py` runs native ERC, DRC and schematic parity with all severities, checks process status AND JSON findings, and writes the release reports. `sync_kicad10.py` synchronizes metadata and isolated NC net names from the schematic when migrating an older generated board. It is not a general schematic-to-PCB update replacement.

`add_bottom_mask_witness.py` adds the deliberate bottom-mask opening around the existing GND stitching via. PCBWay's audit treats a completely empty bottom-mask Gerber as missing; this witness keeps the bottom masked everywhere else while exposing a useful GND probe. Run it before `export_release.py` when reconstructing this exact release.
