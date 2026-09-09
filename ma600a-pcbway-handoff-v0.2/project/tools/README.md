# Working with the completed design

Open `../kicad/MA600A-RefWinch-Encoder.kicad_pro` in KiCad. Edit the native schematic/PCB as the authoritative working sources. Both custom libraries use `${KIPRJMOD}` and are included. KiCad 7.0.11 was used for this release; newer versions can open it.

After source changes, fill copper zones and run native DRC. `export_release.py` exports the native netlist, PDFs, layers, BOM and centroid. `verify_release.py` compares the original handoff netlist and final PCB and checks the release (needs system Python with pcbnew plus the repository KiCad skill parser). `assembly_drawing.py` regenerates the dimensioned assembly PDF. `render_gerbers.py` renders actual fabrication layers (gerbonara and cairosvg required). Regenerate the analysis/review, source archive, package and checksums after any change; old release artifacts do not automatically follow edits in KiCad.

The other scripts preserve the original construction process: build_design, route_board, finish_board, tidy_silk, add_assembly_features, finalize_fiducials. They are construction utilities, not a safe incremental editor; do not run them on a manually edited board, because they regenerate or change sources. The packaged native sources are the completed result and require no script to open or manufacture.
