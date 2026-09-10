# RefWinch odometer

This directory contains the mechanical odometer model and its encoder-board placement model.

- [`odometer.scad`](odometer.scad) is the standalone OpenSCAD model. It displays the two roller odometer with the MA600A board envelope outside the upper frame wall, facing a placeholder magnet on the upper shaft end. The reusable board module is `ma600a_encoder_breakout_board()`.
- [`ma600a_encoder_breakout/`](ma600a_encoder_breakout/) is the electrical subproject. Its KiCad source is under `kicad/`, and its current v0.3 first-article manufacturing files are under `release/`.
- [`MASLOW4-ODOMETER-STUDY.md`](MASLOW4-ODOMETER-STUDY.md) examines Maslow 4.1's belt odometer, setup burden, field failures, and the resulting RefWinch design and validation priorities.

The board model uses the released 28 × 12 × 1 mm outline, puts the MA600A sensing center 4 mm from the short tip, and shows the 5 mm magnetic keepout. The magnet is a 6 × 2.5 mm planning placeholder with a short shaft stub; the final shaft attachment remains to be designed. The board model is an envelope for mechanical planning; the KiCad project remains authoritative for the electrical design and manufacturing geometry.
