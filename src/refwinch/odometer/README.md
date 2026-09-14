# RefWinch odometer

[`odometer.scad`](odometer.scad) contains the two-roller frame, MA600A board cradle, shaft magnet carrier, and roller drive hub. [`../conventional_winch.scad`](../conventional_winch.scad) includes the frame and cradle in `base()` when `show_odometer=true` (the default). A 15.2 mm wide, 1.6 mm thick web connects the bases, with 2 mm overlap at each end. The odometer stays at its previous position, 80 mm along Y. Its floor has an opening beneath the lower roller for running clearance. The encoder, magnet, and cradle sit on the +X side, toward the CLN17 board, to shorten the cable route.

The separate electrical project is in [`ma600a_encoder_breakout/`](ma600a_encoder_breakout/), with KiCad sources under `kicad/` and the v0.3 manufacturing files under `release/`. The CAD board envelope follows the 28 × 12 × 1 mm outline and the sensing center 4 mm from its short tip. KiCad remains authoritative for the board and components.

## Print outputs

In the winch Customizer, select `Base`, `Odometer magnet carrier`, `Odometer board cap`, or `Odometer drive hub`. `Odometer review` shows the assembled subsystem. Opening `odometer.scad` directly provides the same small parts plus `Frame` and `Encoder section` through `odometer_part`.

Print the joined base with its flat bottom on the bed; its model bottom is Z = -36 mm, so place it on the bed in the slicer. The small parts already have their bottoms at Z = 0. The board cap exports with its flat top on the bed and its two integral pegs pointing up. Print the carrier with the shaft opening down and magnet pocket up. The blind shaft socket has a small 3 mm bridge at its roof. Check the sliced bearing-pocket roofs and use local support if needed. PETG or nylon are candidates for the split clamp; its printed fit and grip need a trial before use.

## Board mount

The board slides down into two edge rails with its components facing the magnet and connector pointing down. The rails overlap the outer 0.5 mm of the board edges. The bottom seat sets the sensor height; the rear wall sets the axial position. Nominal side clearance is 0.15 mm per edge, and the 1 mm PCB fits a 1.15 mm deep channel.

Push the removable top cap into the two 2.3 mm holes. Its integral split pegs are 4 mm long with tapered tips and 0.10 mm nominal diametral interference. Tune `odometer_cap_pin_interference` if the fit is too tight or loose. Press both ends evenly; lift the cap by its ends to remove it. No separate board fasteners are needed. The cap has 0.15 mm clearance above the PCB and retains it without relying on board mounting holes. The connector and test pads remain exposed. Insert and remove the board with the cable unplugged, then route the cable downwards away from the rollers and line.

## Shaft and magnet assembly

Additional parts:

- A straight, deburred 3 mm shaft cut to **24.6 mm** for the upper roller.
- A **6 × 2.5 mm diametrically magnetized** cylindrical magnet.
- One M2 × 8 mm nylon screw and M2 nylon nut for the split clamp. Both must be plastic, with a nut measuring 4 mm across flats and 1.6 mm thick.
- A small amount of adhesive compatible with the roller, printed hub, shaft, and magnet coating.

1. Bond the 10.4 mm diameter drive hub into the upper roller's 10.5 mm bore. Keep its ends flush with the 5 mm wide roller. Its outer grooves hold adhesive. This hub transmits rotation to the shaft; the bearing outer races stay seated in the frame.
2. Pass the shaft through the bearings and hub. Locate the hub center 8.5 mm from the shaft end on the side opposite the encoder, then bond the shaft to the hub. Keep adhesive out of the bearings and leave the roller free to turn. The model leaves 0.2 mm between each roller face and adjacent bearing.
3. Dry-fit the magnet carrier. The shaft socket is 7.5 mm deep and nominally 3.08 mm in diameter, with an entry chamfer. Push it fully onto the shaft against its blind stop. The carrier's inner end then clears the frame by 1 mm. Seat the nylon nut in the hex recess and tighten the nylon clamp screw gently. Check grip without closing the slit completely or cracking the ears.
4. Seat the magnet flat against the coaxial pocket floor. The pocket is nominally 6.10 mm in diameter and leaves the magnet projecting 0.3 mm. Use a little adhesive in the side reservoir, keeping the locating floor clean so a glue lump cannot tilt the magnet. The 1.2 mm web separates the magnet from the shaft tip.
5. Slide in the board and fit its cap. The nominal magnet-face-to-package-face gap is **2 mm**. Turn the roller through a full revolution, check carrier and fastener clearance, and check the gap and magnet runout before powering the encoder.

The long bore locates the carrier on the shaft, while the concentric pocket locates the magnet. The clamp supplies grip and the two blind stops set axial position. Tune `odometer_shaft_clearance` and `odometer_magnet_clearance` to the actual print and purchased parts; nominal CAD concentricity does not establish physical runout. Shaft endplay and PCB channel clearance also affect the assembled gap.

## Mechanism choices and checks

A split shaft collar gives distributed grip and allows removal. A radial set screw can mark the shaft and push a loose-fitting carrier sideways; a bonded socket alone makes later removal harder. The implemented design combines a split clamp with a stepped socket. [Ruland describes the grip and adjustment advantages of clamp collars](https://www.ruland.com/shaft-collars.html); this small printed version still needs its own grip test.

[MPS's MA600A datasheet](https://www.monolithicpower.com/en/documentview/productdocument/index/version/2/document_type/Datasheet/lang/en/sku/MA600A/document_id/12989/) describes an on-axis diametrically magnetized cylinder and recommends sensor-center offset below 5% of magnet diameter for optimal linearity: below 0.3 mm for this 6 mm magnet. Its 2 mm gap example uses a 5 × 2.5 mm N35 magnet, so the retained 6 mm target must be checked for field strength and encoder error in the actual assembly. The cap uses integral plastic pegs; the shaft clamp uses a nylon screw and nylon nut for adjustable grip. There are no metal fasteners in either new mount.

The joined base, carrier, cap, and hub have been exported and checked as individual connected, closed meshes. Standard views cover the complete winch, standalone odometer, base, carrier, and small parts, with a carrier section for the hidden sockets. These checks establish the digital geometry only. Verify board insertion, cap retention, printed fits, nylon clamp grip, magnet runout, and bidirectional encoder tracking on a physical build.

[`MASLOW4-ODOMETER-STUDY.md`](MASLOW4-ODOMETER-STUDY.md) covers the broader odometer design and validation priorities.
