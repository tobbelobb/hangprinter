# Saltiga / TCS230 bench fixture

Print **base.stl, carrier_18mm.stl, hood_18mm_1p2x0p8.stl and lid.stl** first. Open `saltiga_fixture.scad` to inspect the assembly or change dimensions. All STL coordinates are millimetres and already oriented for printing. The sketch is in `uno_saltiga_test/uno_saltiga_test.ino`.

This is a designed and digitally checked prototype. Optical performance, PCB fit and printer tolerances still need a bench test. There is no defensible universal “optimal distance” without measuring this particular board's LED beam, window position and the line's reflectance. The adjustable geometry makes that comparison straightforward.

For labelled RGBC sample collection, cluster plots and the on-Uno nearest-centroid classifier, see [PALETTE.md](PALETTE.md). Its acquisition commands describe the current sketch.

## Starting geometry

| Feature | Default |
|---|---|
| Enclosure footprint / assembled height | 58 × 42 / 38.5 mm |
| PCB | 30.9 × 24 × 1.25 mm; pocket 31.5 × 24.6 mm |
| PCB orientation | Components and LEDs down; 30.9 mm dimension along line |
| PCB solder-side underside → line centre | 18 mm |
| LED tips → line centre | 8 mm, from your 10 mm LED height |
| Clear sensor-package top → line centre | Approx. 15 mm; package top assumed 3 mm from PCB underside |
| Aperture | 1.2 mm along travel × 0.8 mm across line |
| Aperture exit → nearest line surface | 1.2 mm; centre separation 1.475 mm |
| Aperture membrane / minimum tip wall | 0.6 / 0.6 mm |
| Hood top → package window | Assumed 0.5 mm |
| Ceramic-eyelet seating holes | Two Ø4 mm through-holes, 4.5 mm axial depth, along line |
| Default unsupported gap / socket centre spacing | 9.2 mm between inner faces / 13.7 mm centre-to-centre |
| Eyelet holder outer diameter | 6 mm; line/bore axes at y=0, z=16 mm |
| Background | Deep sloping black cavity; floor 12 mm below line at centre |

The aperture is close to the line to restrict the field of view. It is **not a focusing lens**, and its dimensions are not exactly the observed spot size: allowing for the finite detector, the default geometric footprint is roughly 1.4 × 1.0 mm at the line plane. The line occupies only part of it, so background subtraction matters. The hood isolates the detector from LED bodies and bright surroundings; it has no broad flange near the line that would shade the target. LED light travels outside the hood and illuminates the line from four diagonal directions.

The aperture gap is slightly larger than a very close 0.5 mm slit because the hood lip can otherwise shade the line from the four off-axis LEDs. LED-centre positions are assumed to be ±8.5 and ±7.75 mm. LED diameters are assumed 5 mm for the preview; the carrier clears a larger open volume rather than using precision LED holes. The 22 mm head automatically increases the gap to about 1.82 mm to maintain diagonal light clearance. These are geometric estimates, not a measured LED illumination model.

## Parts and printing

Use opaque black PLA or PETG, preferably matte. Start with a 0.4 mm nozzle, 0.15–0.20 mm layers, three walls, 25–35% infill and no supports. Inspect thin-wall handling in the slicer; the hood tip has 0.6 mm walls. At 0.20 mm layers the membrane is three layers. Print the hood with its long arms flat on the bed and narrow tip pointing up, as supplied. A brim on the arms is useful if adhesion is poor. The tiny slit must remain open; clear strings gently without enlarging it. The M3 nut pockets have a short bridge; clean any sag before seating nuts.

Insert your ceramic eyelets from the outer faces into the two horizontal Ø4 mm bores, each 4.5 mm long, so their flanges remain outside the central gap. The default seating faces are x=±4.6 mm, giving a 9.2 mm clear gap; socket centres are x=±6.85 mm. This replaces the previous 46 mm V-guide spacing. The rounded Ø6 mm holders are mounted on pedestals below the line and leave the centre background cavity open. No printed plastic contacts the line. Thread the line through the ceramic bores and use light tension. The short span reduces sag; it cannot guarantee zero sag without tension. The ceramic bore diameter and where the soft line sits inside it determine the exact running height, so check that against the 1.2 mm aperture gap. Lateral movement should remain roughly within ±0.1 mm for repeatable readings.

The socket positions were checked against the finite 5 mm LED emitting-face envelopes, all four diagonal light paths and the full upper surface of the 0.55 mm line over x=−1.4..+1.4 mm. The 9.2 mm default gap is rounded up from the shortest gap meeting a 0.25 mm radial clearance margin in that model. Supports remain outside the detector field at the line plane. This check assumes eyelet flanges fit within the Ø6 mm holder envelope and do not protrude inward into the clear gap. Larger flanges or protruding ceramic lips require moving the sockets outward and repeating the clearance check. You can bond inserts in place; keep glue clear of the line path. Printed horizontal bores can shrink or sag, so clean or carefully ream them to 4 mm before insertion rather than forcing the ceramics.

Black plastic can still reflect LED light. If the empty-fixture reading is high, use a thin matte-black coating inside the hood and background cavity, keeping it off the slit and ceramic eyelets. If light is visible through the walls, the filament is not sufficiently opaque. Keep the fixture closed during readings and cover excess jumper/line-port openings with black tape. Leave clearance so the line cannot touch tape adhesive.

Hardware: four M3 × 40 mm bolts, four M3 nuts and washers for the default head; two M2 × 6 mm self-tapping screws for the hood arms; two small strips of compressible foam for the lid to hold the PCB down. M3 nuts are nominally 5.5 mm across flats; pockets allow 5.7 mm. Trial-fit screws and nuts gently. The 14 mm head can use 35–40 mm bolts; the 22 mm head needs 45 mm bolts. Longer bolts can protrude below the base, so support it clear of your bench or use suitable washers.

## Assembly

1. Inspect the board and locate its optical window. The model assumes it is centred on the PCB. Check the underside-to-window height too; 3 mm is an assumption, not a supplied measurement. If necessary, edit `sensor_x`, `sensor_y` and `sensor_window_depth`, then re-export. Small x/y offsets tilt the hood towards the detector while keeping the slit centred over the line. Offsets of 1 mm or more require a clearance review, enforced by the model.
2. Seat four M3 nuts in the bottom pockets. Put the carrier on the base with its four holes aligned; its bottom is assembly z=14 mm.
3. Lower the hood arms into the two carrier slots. The narrow aperture points down; the slot floors set its height. Secure the arms with the M2 screws. The hood should not touch the sensor package when the board is fitted.
4. Fit the ceramic eyelets in the two Ø4 × 4.5 mm sockets on the base, with their inner faces flush and their bores aligned. Thread the line through both ceramics and the enclosure ports, keeping it gently taut through the centre. The optical aperture never contacts the line.
5. Seat the board on its edge ledges, components down. Route jumpers through the generous slots at the short ends. Check your actual header locations and connector height before closing; standard module layouts vary. If they need more room, enlarge the exits or change the lid/foam clearance in the source and re-export. Never force the lid against pins or solder joints.
6. Place small foam strips over the PCB's clear edge areas, over the ledges, to fill the 2 mm space to the lid. Keep foam away from headers and sharp solder points. Fit the lid and tighten the M3 bolts lightly. The board should stay seated without bending.

There are no assumed PCB mounting-hole coordinates: edge ledges and the foam lid hold it. Check that those narrow ledges do not touch components on your board.

## Arduino Uno R3 wiring

Use one module and short jumpers (preferably under 20 cm). Connect by **printed pin label**, not by connector order. Your pin labels may say `EO` instead of `OE`.

| TCS230 / TCS3200 module | Uno R3 |
|---|---|
| VCC | 5V |
| GND | GND |
| OE / EO | GND, enables output |
| S0 | D8 |
| S1 | D9 |
| S2 | D10 |
| S3 | D11 |
| OUT | **D5**, the Timer1 external clock input |

Power the Uno from USB for this test. Use the module's existing LED resistors; its LEDs normally turn on with module power. Do not supply module power from a GPIO pin. If the board has a separate LED enable, check its marking or schematic first. A nearby 100 nF capacitor across module VCC/GND is useful if one is not already fitted. Uno R3 and this sensor family can interface directly at 5 V; no level shifter is required. This sketch specifically targets the ATmega328P Uno R3, not Uno R4.

The sketch uses Timer1 as a hardware pulse counter, so it does not need an interrupt for every sensor pulse. D5 is essential; moving OUT to D2 will not work with this sketch. Timer1 is reserved: do not use Servo or PWM on D9/D10 at the same time. S1/S2 can still use those pins as ordinary digital outputs.

## Readable RGB graph

Without a trained palette, the sketch starts in **Serial Plotter mode**, with labelled `R`, `G`, and `B` curves. A saved palette starts with category indicators; send `p` to select these RGB curves. Each is a fraction from **0 to 1**, using the existing baseline subtraction and optional white calibration. The `Min` and `Max` reference lines are always 0 and 1; leave them enabled to keep the graph scale steady. Raw frequencies and status text are omitted in graph mode.

1. Re-upload `uno_saltiga_test/uno_saltiga_test.ino` from this repo folder.
2. Close Serial Monitor and open **Tools → Serial Plotter**, on the same Uno port at **115200 baud**.
3. Watch the curves while moving coloured sections slowly under the aperture. They normally sum to 1 when there is a signal; all three are 0 when the baseline-subtracted total is zero.
4. Slow mode uses 100 ms per channel and a 200 ms minimum reporting interval, giving roughly 2.5 rows/s. Send `f` for fast acquisition with no extra reporting delay. `[` increases the reporting interval (from zero to 20 ms, then doubling); `]` halves it, with intervals of 20 ms or less returning to zero. The supported range is 0–5000 ms.

Display pacing does not change the selected per-channel measurement window and does not smooth or average away transitions. Very low light or a longer measurement gate can make updates slower than the selected interval. The horizontal axis is sample index rather than a precise time axis. These normalised detector fractions are not independent white-normalised intensities or sRGB values.

Send `p` to select graph mode and RGB measurement. Send `v` to restore the full diagnostic CSV at the same slower display rate; use Serial Monitor for it. Calibration commands `e` and `w` still work in graph mode and briefly pause the graph, but their status messages are suppressed to keep the graph clean. Use CSV mode when checking calibration acceptance or low-signal warnings. Calibration is saved in EEPROM and restored after opening a viewer resets the Uno. Acquisition mode, window and scaling also survive resets. Brightness is plotted after a successful white calibration; it is net clear divided by white net clear, independently of the RGB fractions.

See [Arduino's Serial Plotter guide](https://docs.arduino.cc/software/ide-v2/tutorials/ide-v2-serial-plotter/) for the viewer controls.

## First test and calibration

1. Open the sketch in Arduino IDE, select **Arduino Uno**, upload, then open Serial Monitor at **115200 baud**. No libraries need installing. The default output is graph-friendly RGB. Send `v` for the diagnostic CSV used in the steps below; lines starting with `#` are status messages. Send `p` afterwards to return to the graph.
2. Without line in the optical span, close the lid and send `e`. This averages eight readings of each channel and stores the illuminated **empty fixture** baseline in EEPROM. Keep illumination and enclosure unchanged afterwards. This is not a true lights-off detector dark calibration.
3. Insert a stationary coloured Saltiga section, close the fixture, and observe `R_Hz, G_Hz, B_Hz, C_Hz`. More Hz means more light. Confirm a repeatable increase above the empty fixture. Repeat for each colour before pulling the line.
4. Optional: put an undyed white piece of braid of similar diameter in the same position and send `w`. This equalises channel gains after baseline subtraction. A large white card is only a rough gain reference because it fills a different field of view. If no white line is available, use `e` alone and compare the uncalibrated ratios across the actual colours.
5. Pull slowly, around 1–5 mm/s initially. Watch the normalised `r,g,b` and total baseline-subtracted `signal_Hz`. Those fractions sum to about 1 when RGB signal exists. They are detector ratios, **not sRGB values or calibrated colour coordinates**.

| Command | Effect |
|---|---|
| `e` | Empty-fixture baseline; clears white gains |
| `w` | Optional stationary white reference; rejected when signal is too low |
| `x` | Clear baseline and gain calibration |
| `p` / `v` | RGB graph (default) / full diagnostic CSV |
| `[` / `]` | Slower / faster reporting; 0–5000 ms, default slow 200 ms / fast 0 |
| `c` / `r` | Clear-only CSV / sequential RGB + clear; `p` also enables RGB |
| `1` / `2` / `3` | 100% / 20% / 2% output scaling; clears calibrations |
| `f` / `s` | Fast 2 ms reciprocal timing / slow 100 ms pulse counting; keeps calibration |
| `+` / `-` | Double / halve window; fast 0.1–100 ms / slow 2–100 ms |

On first use, defaults are **RGB graph mode, 200 ms display interval, 100% scaling and a 100 ms measurement window per channel**. Saved acquisition settings and calibrations are restored after reset. The small aperture reduces light substantially, so keeping the full pulse rate helps resolution. Filter changes wait for two output edges, up to 50 ms; `settled=0` flags a timeout. `min_count` is the smallest count in the measured channels. In slow pulse-counting mode, below 20 counts, quantisation alone can be several percent; aim for 100 or more when comparing subtle differences. In fast reciprocal mode it reports timed periods instead: the 1/count quantisation estimate no longer applies; the Uno's 4 µs clock resolution, endpoint polling jitter and settling affect precision. Empty subtraction can make a weak net signal much noisier than the raw count suggests.

RGB and clear are sampled sequentially. In slow mode, acquiring a complete row takes at least about 400 ms, plus settling, computation and serial output; display pacing then waits as needed before the next scan. `t_ms` timestamps the start of the scan; it is not a simultaneous RGB timestamp. A 400 ms scan spans 2 mm at 5 mm/s, or 400 mm at 1 m/s. Fast mode targets 2 ms of reciprocal timing per channel, plus settling and serial output; use its reported `scan_us` and `row_us` to measure actual timing. Do not interpret these rows as high-speed boundary positions. Use clear-only to inspect intensity edges at a higher rate; colour identification still needs RGB. Use `p` for the Serial Plotter so raw Hz, timestamps and counts do not stretch its vertical scale.

If readings barely exceed empty: confirm aperture alignment, inspect the slit for blockage, increase gate time, and compare the larger aperture. If a white braid still gives little extra signal, the module LEDs may not illuminate the line adequately at this distance. Compare the shorter head; if necessary, add a diffused white source aimed at the line from outside the detector hood. More counting time cannot cure poor optical contrast. If direct sunlight saturates the sensor, close light leaks; lowering output scaling does not remove internal detector saturation.

## Included variants and choosing a geometry

| Match these parts | Underside → centre | LED tip → centre | Aperture surface gap | Eyelet clear gap |
|---|---:|---:|---:|---:|
| base_14mm + carrier_14mm + hood_14mm_1p2x0p8 | 14 mm | 4 mm | 1.20 mm | 11.4 mm |
| base + carrier_18mm + hood_18mm_1p2x0p8 | 18 mm | 8 mm | 1.20 mm | 9.2 mm |
| base_22mm + carrier_22mm + hood_22mm_1p2x0p8 | 22 mm | 12 mm | 1.82 mm | 7.6 mm |

Match the base, carrier and hood distance; only the lid is common. The taller heads allow the LEDs to shine over closer eyelet sockets. Use the 18 mm base for all three 18 mm aperture variants. At 18 mm also try `hood_18mm_0p8x0p8.stl` for finer along-line resolution, or `hood_18mm_2p0x1p0.stl` for more light. The latter automatically uses a 1.32 mm surface gap to clear illumination. Apertures are specified along × across the line.

For each geometry recalibrate empty, hold each coloured section stationary and capture at least 20 rows per colour. Compare the separation of mean r/g/b ratios with their repeat-to-repeat variation and the net brightness above empty. Select the **smallest aperture and shortest gate that still separate your colours reliably**, then increase hand-pull speed. The narrower aperture is useful only if its lower light level remains sufficient. The longer viewing distance may help LED coverage but reduces collected line light. None of these alternatives is claimed to be experimentally optimal.

Export a customised part, for example:

```sh
openscad -o carrier_custom.stl -D 'part="carrier"' -D 'pcb_to_line=18' saltiga_fixture.scad
openscad -o hood_custom.stl -D 'part="hood"' -D 'pcb_to_line=18' -D 'slit_x=1.2' -D 'slit_y=0.8' saltiga_fixture.scad
```

Export the base with the same `pcb_to_line` value too. Use the same PCB/window/offset parameters for all parts. Eyelet spacing is validated for centred optics; changing sensor offsets needs an optical clearance review. `part="assembly"` previews the geometry and `part="exploded"` separates the lid and upper assembly. Preview board and line objects are illustrative; do not export the assembly as a printable STL.

## Verification and sources

All twelve supplied part STLs were exported from this OpenSCAD source. Each was checked for a single connected component, closed edges, consistent winding and positive volume. Digital collision checks cover the printed assembly, the modelled PCB, package and LED envelopes; numerical light-path checks also cover the eyelet-holder clearances; the unknown headers and actual module parts require the fit check above. The original delivery sketch compiled for Uno R3 at 6,854 bytes flash and 252 bytes static RAM. Current firmware checks and measured sensor data are documented in [PALETTE.md](PALETTE.md); printed fit and optical alignment still depend on the physical fixture.

Primary references: [ams OSRAM TCS3200 datasheet](https://look.ams-osram.com/m/664723bdb31f55db/original/TCS3200-DS000107.pdf), especially selection tables, supply requirements, switching response and frequency measurement; [Microchip ATmega328P datasheet](https://ww1.microchip.com/downloads/en/devicedoc/atmel-7810-automotive-microcontrollers-atmega328p_datasheet.pdf), external T1 clock and Timer1; [Arduino Uno R3 documentation](https://docs.arduino.cc/hardware/uno-rev3/). TCS230-labelled boards commonly use the same control convention; check the actual chip marking and module labelling before applying power. This package assumes the supplied board uses that convention.

This folder in the hangprinter repo is now the active source. Edit the sketch here rather than older copies in the chat outputs folder.
