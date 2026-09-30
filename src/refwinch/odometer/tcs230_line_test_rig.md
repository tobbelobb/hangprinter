# TCS230 fishing-line test rig

The fixture tests one TCS230 module against a 0.55 mm line. Build three copies
after establishing useful optics on one station. It does not mount the mouse
sensors: their lens geometry, electrical interface and working distance still
need to be specified.

Open `tcs230_line_test_rig.scad`. The default **Assembly** shows the covered
instrument; use **Open assembly** to expose the station, **Section** to inspect
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
| Outer eyelet axes | X = ±28 mm; 1.5 mm below the sensing line |
| Close support pins | X = ±5 mm; 10 mm sensing span |
| Smooth pin inserts | 2 mm diameter × 2.4 mm long, axes across the line |
| Ceramic sockets | Shared `Eyelet_diameter` 4.30 + 0.15 mm diametral allowance |
| Flange recess | Shared `Eyelet_flange_diameter` 5.93 + 0.20 mm; depth 0.8 mm |
| Initial line centre | 38 mm above bed; 8 mm above LED tips |
| Initial aperture | 4 mm along line × 2 mm across line |
| Aperture top below line centre | 3.6 mm at the initial setting |
| Aperture diaphragm | 0.6 mm thick, at end of a tapered black chimney |
| Background | Ribbed black hood underside, minimum 11.5 mm behind initial line |
| Overall covered height | 54 mm |
| Hood line openings | Two sliding opaque plates, each with a 2.5 mm bore |

The supplied board photo shows the two four-pin headers at the short PCB ends,
with pins underneath. Support pads avoid these rows, and the baffle has
5 × 12 mm openings above them. Header offsets are estimated from the photo;
the 16 mm space below the board allows a nominal 15 mm female-jumper envelope.
The preview shows those envelopes translucent purple. Check your actual plugs.

The eyelet interior is intentionally not modelled. Your 2 mm bore permits
about ±0.725 mm lateral movement of the centre of a 0.55 mm line. The close
support pins now establish its height, independently of that bore clearance.
Narrow slits can give
a larger colour contribution, but they can also mistake wandering for a colour
change. Start with the 2 mm slit for pulling tests.

## Supporting the soft line

The original 56 mm unsupported span was too long for a dependable height
datum. Two small cradles are now integrated into the baffle at X = ±5 mm.
Fit a smooth 2 mm diameter pin across each cradle; the line runs over their
rounded tops. Use solid PTFE, ceramic or a burr-free polished metal pin, not a
rough printed contact surface. Pin diameter is a parameter because it sets
the sensing height. Measure the inserts, clean the seats, and bed both firmly
against their seat bottoms. The 0.05 mm diametral seat allowance is compensated
in the nominal pin datum. Secure inserts at their ends without raising them
or putting adhesive on the line contact surface.

The line's central span is 10 mm. Under the same horizontal tension and line
weight, small gravitational sag scales as span squared: (10/56)^2 = 0.032,
about 31 times less than before. This is a relative estimate, not an absolute
sag tolerance for the actual braid. No fixture can keep a completely slack
line straight across a free optical opening. Start with a gently hanging 10 g
weight (about 0.1 N) on the feed, or an equivalent repeatable light tension,
and test several tensions. Keep the outgoing paths at or below the eyelet
height so tension presses the line onto both pins. Avoid pulling upward over
the station. Watch for lifting, vibration, contact wear and braid flattening.

The outer eyelets are 1.5 mm below the sensing span. Even their ±0.725 mm bore
play leaves a downward break angle. The nominal angle is about 3.7 degrees;
these supports are height datums, not clamps. They do add friction, which is
why the contact surfaces must be smooth and why both pulling directions need
testing. The preview's corners approximate the small wrap around the pins.

At the initial setting the sensor's geometric viewing envelope is 5.51 mm
long. The printed cradles start 3.6 mm from the centre and the pins start 4 mm
from it, beyond that envelope. Even the widest longitudinal envelope at the
12 mm gap remains below 6 mm. The cradles are only 1.6 mm wide across the line.
The four LED-centre paths to the central 4 mm of line pass beside them;
sampled paths also check the ±0.725 mm lateral play. This is a geometric check,
not a prediction for the complete LED lens or scattered light. Measure actual
illumination, especially at the ends of the viewing envelope. A full eyelet
post in either close-support position would intercept much more LED light.

## Optical choices and limitations

Use reflection from the board's four white LEDs, with the sensor facing upward
and the line across its optical axis. The black chimney prevents the sensor
from viewing most of the PCB and LED bodies. The ribbed background is recessed
beyond the line and avoids a broad flat surface directly behind it. The hood
encloses the station; its cable exit has an external dogleg cover.

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
and hood remain usable: slide its port plates to the new eyelet height. At each
distance try aperture widths 2.0, 1.2 and 0.8 mm;
only the baffle changes for a width change. Labels identify both settings.

Black filament may still be shiny or transmit some light, especially outside
the visible band. If the background gives a large reading, roughen it or add a
thin matte-black coating. Keep coatings, fibres and adhesive away from the line
and sensor window. If the LEDs are narrow-beam and fail to light the line at all
three distances, aim them inward if their leads allow it, or use a separate
diffuse white source outside the chimney. Recalibrate after changing lighting.

## Enclosure decision

Use the opaque hood during measurements. The earlier main review images hid
it for inspection; that was not the intended operating condition. However,
the previous tall, tape-masked line slots were an incomplete optical seal.
The revised instrument includes two sliding port plates with 2.5 mm round
bores, an overlapping tongue/rebate at the base, and the low wire dogleg.
Seal the port-plate rims and wire exit with opaque tape or black foam after
aligning them. The line passages remain free; this is an optical enclosure,
not an airtight box. A room-light sensitivity measurement verifies its result.

| Reasons for enclosure | Weight here |
| --- | --- |
| Exclude sunlight and room light, whose spectrum and shadows would alter the measured RGB ratios. | Highest: the line is narrow and the signal can be weak. |
| Fix what the sensor sees behind the line; hands, clothing and nearby parts must not become variable coloured background. | Highest: most of the lensless viewing envelope is background. |
| Protect the window and contact area from dust, handling and air currents that disturb the soft line. | Useful, secondary to the optical reasons. |

| Reasons against enclosure | Response here |
| --- | --- |
| It makes threading, alignment and LED adjustment harder to observe. | Real prototype cost; remove the hood for setup and replace it for data collection. This hood requires unthreading the line for removal. |
| Trapped LED heat can change brightness, sensor response and printed dimensions. | Allow warm-up, compare readings over time, and keep the Uno outside; add baffled ventilation if measurements show a thermal problem. |
| Line and wire ports complicate printing/sealing and can introduce rubbing or snagging. | Let ceramic eyelets and smooth pins guide the line; align the roomy hood bores so they do not contact it. |

Ambient rejection and a stable black background carry the most weight. Access
is important during setup but can be handled with a removable hood. Heat is
a measured tradeoff, not a reason to expose this very small target to room
light. Record the same stationary colour with room lights on/off, a lamp moved
around both line ports, and a hand placed near each seam. Compare those shifts
with the separation and scatter of actual line-colour classes. If leakage is
significant, improve sealing before choosing thresholds. Black FDM material
alone does not prove optical opacity.

## What Merlet's experiment tells us

Source: `../papers/merlet_cablecon2019_absolute_encoders.pdf`, printed page 2,
section 2 and figure 1; also the author's
[INRIA copy](https://www-sop.inria.fr/teams/hephaistos/PDF/merlet_cablecon2019.pdf).
The paper reports that tests distinguished at least red, green and blue.
Figure 1 contains a photograph of a four-LED colour breakout and a schematic
of sensor stations in a mast. It does **not** show the RGB test rig. The text
recommends opaque sensor boxes with circular cable openings to reject external
illumination, but does not identify their construction as the experimental rig.

I found no separate rig photo, drawing or experimental protocol in focused
searches for the title, author, RGB tests, Vernier prototype or conference
presentation. The author's bibliography points back to the same paper. The
HAL record and activity-report detail page could not be retrieved during this
search. This is a bounded unsuccessful search, not proof that the rig was
never published. No contact request was sent.

There are no reported aperture dimensions, line diameter, working distance,
speed, confusion matrix or repeatability data for the RGB experiment in this
paper. The photo is consistent with the same general four-LED breakout family;
it does not establish the exact IC or an optical optimum. Its RGB feasibility
claim cannot validate 0.55 mm Saltiga braid or all five colours and fine marks.

Useful lessons are active illumination, opaque housing and discrete colour
landmarks combined with relative travel measurement. Its initialization scheme
also uses unique mark sequences; the repeating stock fishing-line palette
needs homing/sequence tracking or extra unique marks. The plotted Vernier
results are calculated event spacings, not measurements of colour accuracy.

## Printing and assembly

Print the base flat, guides upright, baffle with its broad plate on the bed,
port plates flat, and hood closed roof on the bed. The print layout supplies these orientations
and fits roughly 127 × 121 mm. Use a 0.4 mm nozzle and about 0.15–0.2 mm layers;
check the slit in the slicer and after printing. The guide sockets have short
horizontal bridges that may need cleaning. Avoid supports inside the chimney.
The hood's cable cover and shutter-rail lips may need local support under
their short overhangs. Remove it fully from the sliding channels.

Parts: one module, two ceramic eyelets, two smooth 2 mm × 2.4 mm pins,
two printed port plates, four M3 × 8 mm screws and nuts for the
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
4. Connect jumpers and install the baffle and both smooth support pins. Check
   chip, LED and header clearances. Check both pin tops establish the same height.
   If direct LED light leaks underneath the baffle plate, add a thin opaque
   gasket around the chip without covering its clear window or stressing it.
5. Route jumpers through the low cable port, seat the hood's tongue in the base
   rebate, and slide the two port plates into their external rails from above.
   Align their bores with the ceramic eyelet axes (36.5 mm above bed at the
   8 mm setting). Thread through a port, the first eyelet, over both close pins,
   through the second eyelet and the other port. Tension gently with the outer
   paths lower than the sensing span. Confirm the line contacts both pins and
   clears the aperture, port bores and any adhesive.
6. Fix and seal the port-plate rims with opaque tape. Fit black foam around the
   jumper exit without crushing wires. Verify ambient rejection at the seams
   and ports, and verify empty-station brightness after warm-up. The hood needs
   the line unthreaded to lift off; it is not a split enclosure.

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

The covered station, open station, centre section and print layout were
inspected in all five standard views, including their contact sheets. Shortest/narrowest and
tallest/widest settings were also rendered to check the geometric limits.
Full STL evaluation and individual-part mesh checks are separate from preview
inspection. The Uno sketch compiles for `arduino:avr:uno`.

The revised layout contains seven separate printed parts (base, baffle,
two guides, hood and two port plates). Its full STL and individual exports
have no edges with other than two incident triangles, and the expected surface
component counts. The close-support check samples 2,952 LED-centre rays per
distance, to the central 4 mm of line with ±0.725 mm lateral play and both
the centre and lower surface of the line. None intersect the close cradles or
pins at gaps 4, 8 or 12 mm. This checks those supports, not the complete
illumination system. Results and renders are in `.cad-review/tcs230_line_test_rig/`.

These checks establish a coherent digital prototype, not optical performance,
ceramic fit, filament opacity or assembly fit on the actual module. No circuit
schematic or PCB was supplied for this fixture, so wiring was checked against
the chip datasheet; ERC/DRC, PCB EMC, thermal and analogue simulation analyses
were not applicable to this jumper-wired prototype.
