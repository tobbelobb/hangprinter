# TCS230 fishing-line test rig

The fixture tests one TCS230 module against a 0.55 mm line. Build three copies
after establishing useful optics on one station. It does not mount the mouse
sensors: their lens geometry, electrical interface and working distance still
need to be specified.

Open `tcs230_line_test_rig.scad`. The default view removes the hood to expose
the station; use **Assembly** for the covered instrument, **Section** to inspect
the optical path, and **Print layout** or individual part outputs for printing.
Preview colours distinguish parts; print everything black.

## Starting dimensions

| Feature | Dimension |
| --- | --- |
| Base | 80 × 60 × 4 mm |
| PCB | 30.9 × 24 × 1.25 mm; window centred |
| PCB underside above bed | 20 mm; 16 mm clearance above the base |
| LED centres | Assumed 17 × 15.5 mm rectangle |
| LED tips above PCB underside | 10 mm |
| Eyelet axes | X = ±28 mm; 56 mm centre spacing |
| Ceramic sockets | Shared `Eyelet_diameter` 4.30 + 0.15 mm diametral allowance |
| Flange recess | Shared `Eyelet_flange_diameter` 5.93 + 0.20 mm; depth 0.8 mm |
| Initial line centre | 38 mm above bed; 8 mm above LED tips |
| Initial aperture | 4 mm along line × 2 mm across line |
| Aperture top below line centre | 3.6 mm at the initial setting |
| Aperture diaphragm | 0.6 mm thick, at end of a tapered black chimney |
| Background | Ribbed black hood underside, minimum 11.5 mm behind initial line |
| Overall covered height | 54 mm |

The supplied board photo shows the two four-pin headers at the short PCB ends,
with pins underneath. Support pads avoid these rows, and the baffle has
5 × 12 mm openings above them. Header offsets are estimated from the photo;
the 16 mm space below the board allows a nominal 15 mm female-jumper envelope.
The preview shows those envelopes translucent purple. Check your actual plugs.

The eyelet interior is intentionally not modelled. Your 2 mm bore permits
about ±0.725 mm movement of the centre of a 0.55 mm line. Narrow slits can give
a larger colour contribution, but they can also mistake wandering for a colour
change. Start with the 2 mm slit for pulling tests.

## Optical choices and limitations

Use reflection from the board's four white LEDs, with the sensor facing upward
and the line across its optical axis. The black chimney prevents the sensor
from viewing most of the PCB and LED bodies. The ribbed background is recessed
beyond the line and avoids a broad flat surface directly behind it. The hood
excludes room light; its cable exit has an external dogleg cover.

The aperture is deliberately separated from the line. With the LEDs far to
either side, a chimney mouth immediately beneath the line would shadow their
light. Its top is placed 45% of the LED-tip gap below the line: the geometric
centre rays from all four LEDs pass outside the mouth and reach the line.
This checks obstruction, not LED brightness. LED lens beam angle, tilt and
actual centre spacing are still unknown, so illumination must be measured.
Check that "17 × 15.5" describes LED centres; adjust `led_rectangle` if it
describes their outer edges instead.

The [TAOS TCS230 datasheet, pages 1, 2 and 8](https://www.mouser.com/datasheet/2/588/cs230-e33-1214740.pdf)
describes an interleaved 1.15 × 1.15 mm photodiode array and a frequency output.
This is a lensless light receiver. A slit restricts the view; it does not focus
a sharp image of the line onto the die. The tube opens broadly around the die
instead of placing a 0.55 mm mask directly against selected photodiodes.

Using a nominal die height of PCB thickness + 0.88 mm from the package drawing,
the initial die-to-line distance is about 15.87 mm. The package top is a
different datum: its assumed height is 3.0 mm above the PCB underside, with
0.2 mm clearance below the baffle plate. **Measure package-top height before
printing** and adjust `sensor_package_top_from_pcb_bottom` if needed. The
nominal die height only estimates viewing distance; it is not a measurement of
your board. LED diameter is provisionally 5 mm; clearance holes are 7 mm.

For the initial setting, projecting rays from the full die through the aperture
gives an approximate envelope of 5.51 × 2.92 mm at the line. The 0.55 mm line
therefore occupies only about 19% of the transverse envelope. This is not a
prediction of signal strength: illumination, reflection, braid shape and
angular response weight the received light unevenly. A matte, stable background
and measurements of the empty station are essential.

There is no established perfect aperture or distance for this board and braid.
The fixture provides a controlled experiment:

| LED tip to line | Approx. die to line | Aperture top to line | Background to line, minimum |
| --- | --- | --- | --- |
| 4 mm | 11.87 mm | 1.8 mm | 15.5 mm |
| **8 mm** | **15.87 mm** | **3.6 mm** | **11.5 mm** |
| 12 mm | 19.87 mm | 5.4 mm | 7.5 mm |

Change `led_to_line` and print a matching **Guide pair** and **Baffle**. The base
and hood remain usable. At each distance try aperture widths 2.0, 1.2 and 0.8 mm;
only the baffle changes for a width change. Labels identify both settings.

Black filament may still be shiny or transmit some light, especially outside
the visible band. If the background gives a large reading, roughen it or add a
thin matte-black coating. Keep coatings, fibres and adhesive away from the line
and sensor window. If the LEDs are narrow-beam and fail to light the line at all
three distances, aim them inward if their leads allow it, or use a separate
diffuse white source outside the chimney. Recalibrate after changing lighting.

## Printing and assembly

Print the base flat, guides upright, baffle with its broad plate on the bed,
and hood closed roof on the bed. The print layout supplies these orientations
and fits roughly 127 × 121 mm. Use a 0.4 mm nozzle and about 0.15–0.2 mm layers;
check the slit in the slicer and after printing. The guide sockets have short
horizontal bridges that may need cleaning. Avoid supports inside the chimney.
The hood's cable cover may need local support under its short overhang.

Parts: one module, two ceramic eyelets, four M3 × 8 mm screws and nuts for the
guides, four approximately 2.5 × 8 mm plastic-thread screws for the baffle,
an Uno R3, USB cable, and jumpers. A small breadboard helps distribute power.
The baffle pedestals have 2.1 mm pilot holes; choose screws that suit your print.

1. Test one eyelet socket before forcing in ceramic. Adjust
   `eyelet_socket_clearance` for your printer. The present 4.45 mm socket is a
   clearance-fit starting point; reduce the allowance for a firmer fit. Recess
   depth and the 4 mm post thickness depend on your eyelets' unmeasured flange
   and barrel lengths.
2. Press or secure the eyelets into the guides from the outside. Install the
   captured M3 nuts from underneath and bolt the guides to the base. Confirm
   both axes align before tensioning the line.
3. Seat the module on the four PCB edge pads. Fix it with small pieces of tape
   at unused edges; no unmeasured PCB mounting-hole pattern is assumed. Verify
   the centred window is beneath the chimney and the board cannot slide.
4. Connect jumpers and install the baffle. Check chip, LED and header clearances.
   If direct LED light leaks underneath the baffle plate, add a thin opaque
   gasket around the chip without covering its clear window or stressing it.
5. Route jumpers through the low cable port, seat the hood, and thread the line
   through the hood slot, first ceramic eyelet, sensor station, second eyelet,
   and opposite hood slot. Pull straight with light, repeatable tension. The
   line must clear the chimney throughout the eyelet's available movement.
6. Mask unused heights of the hood's line slots with opaque black tape or foam,
   leaving about a 2.5–3 mm passage around the line. Seal the hood/base seam if
   needed. Verify ambient rejection by turning room lights on and off. The hood
   needs the line unthreaded to lift off; it is not a split enclosure.

## Uno and jumper wiring

Yes: one TCS230 module is a straightforward Uno R3 bench test. The sensor's
recommended supply is 2.7–5.5 V and the Uno R3 operates at 5 V.
See the [TCS230 datasheet](https://www.mouser.com/datasheet/2/588/cs230-e33-1214740.pdf)
and [Arduino Uno R3 documentation](https://docs.arduino.cc/hardware/uno-rev3/).

| Module label | Uno R3 |
| --- | --- |
| VCC | 5V |
| GND | GND |
| OUT | D2 |
| S0 | D4 |
| S1 | D5 |
| S2 | D6 |
| S3 | D7 |
| OE (visible on your board) | GND, active low |

Your photo shows GND, OE, S1 and S0 on one row; VCC, OUT, S2 and S3
are on the opposite row. Wire by the printed labels, checking orientation. Leave onboard LEDs enabled
through the module's normal supply. If there is a separate LED-control pin,
check that board's control polarity; do not power the LEDs from an Uno I/O pin.
Power the Uno by USB for this test. Check that the module has local supply
decoupling: the sensor datasheet calls for 10–100 nF close to the chip. Keep OUT
and its ground return short, preferably under 20 cm. Actual module LED current
and LED-control circuitry have not been measured.

Load `tcs230_line_test/tcs230_line_test.ino`, select Uno, and open Serial Monitor
at **115200 baud**. No external library is required. It starts at 20% output
scaling. Send **2** to change to 2%, or **0** to return to 20%. Do not compare raw
frequencies recorded at different scales without dividing by the scale fraction.

The sketch selects R=00, G=11, B=01, Clear=10 on S2/S3. It discards two rising
edges after each channel change, then measures up to eight complete periods,
with a 125 ms acquisition limit per channel. CSV includes each channel's time,
raw Hz, uncorrected RGB fractions, a validity mask and the selected scale. Mask
bits R/G/B/C are 1/2/4/8; **15** means all readings passed the reader checks.
Missing or excessive-frequency readings print `nan`, not false zero readings.
This software reader rejects measured frequencies above 15 kHz; use 2% scaling
if readings approach that threshold. Never select 100% for this sketch. Weak
signals can take about half a second per RGB+clear set, so start with stationary
line segments. Micros timestamps wrap about every 72 minutes.

Three colour modules can share S0–S3, with separate OUT wires and common ground;
their outputs must not simply be tied together. The supplied sketch reads one
module. A three-module implementation needs additional interrupt handling or
sequential counting. Whether the Uno can also handle three mouse sensors
depends on their exact models, voltage levels, interface and required sample
rate; do not connect unidentified mouse boards directly to 5 V signals.

## Measurements to run

1. Record at least 100 samples of every actual line colour and every marker type,
   first stationary. Record an empty station with LEDs on, and an opaque-covered
   sensor as a separate dark check. If the background times out, extend the
   acquisition interval for that check or treat it as a measured upper bound;
   do not silently substitute zero.
2. For each channel subtract its empty-station baseline, then normalize the
   positive R/G/B differences by their sum. Compare class means and scatter;
   retain raw and clear-channel brightness so dark marks are not confused with
   a missing line. The sketch's fractions are preliminary and do not perform
   this subtraction or white balancing.
3. Repeat while twisting the braid and changing tension. Deliberately move the
   line toward either side of the eyelet bore. Prefer the geometry that keeps
   colours separated under these perturbations, not only at ideal centring.
4. Compare the nine distance/aperture combinations, keeping lighting and scale
   fixed. Check empty-background drift and room-light sensitivity for each.
5. Pull a marked length slowly in both directions, then increase speed. Channels
   are sampled sequentially and can straddle a transition. Use their timestamps
   to flag mixed samples. If the full-set duration is T and the narrowest useful
   marker is L, a conservative initial speed target is v*T < L/10. Derive the
   operating speed from the measured data rather than assuming a fixed frame
   rate. Add hysteresis and require several consistent samples before accepting
   a transition.

Saltiga marking patterns depend on the product generation. Daiwa describes
five repeating 10 m colours and additional 1 m/5 m marks for
[Saltiga Sensor 12Braid](https://daiwa.my/product/uvf-sg-sensor-12braid-ex/),
and a different colour palette for
[Saltiga Durasensor x8](https://daiwa.sg/product/uvf-saltiga-durasensor-x8si2/).
Map your physical spool before assigning positions. Repeating colours provide
landmarks for drift correction after homing and sequence tracking; a colour
alone cannot identify a unique absolute position along the whole spool. Measure
mark spacing under representative tension before using it as a length standard.

## Verification

The open station, centre section and print layout were inspected in all five
standard views, including their contact sheets. Shortest/narrowest and
tallest/widest settings were also rendered to check the geometric limits.
Full STL evaluation and individual-part mesh checks are separate from preview
inspection. The Uno sketch compiles for `arduino:avr:uno`.

These checks establish a coherent digital prototype, not optical performance,
ceramic fit, filament opacity or assembly fit on the actual module. No circuit
schematic or PCB was supplied for this fixture, so wiring was checked against
the chip datasheet; ERC/DRC, PCB EMC, thermal and analogue simulation analyses
were not applicable to this jumper-wired prototype.
