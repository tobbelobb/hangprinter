Hangprinter ![Hangprinter logo](https://vitana.se/opr3d/tbear/bilder/logo_blue_50.png)
===========

This is the main dev branch of Hangprinter v3.3.
Read [blog](http://vitana.se/opr3d/tbear) to stay up to date with what happens here.

Bill of Materials
----------------

  * Printed parts
    * Beam Slider ABC x 3 (End points for ABC-lines)
    * Beam Slider D x 3 (End points for D-lines)
    * Corner Clamp x 3
    * Extruder Holder x 1
    * Lineroller ABC Winch x 3
    * Lineroller D x 3
    * Lineroller Anchor x 6 (The stl contains 2. Print <code>lineroller_anchor.stl</code> 3 times.)
    * Motor Bracket x 4
    * Motor Gear x 4
    * Spool x 4
    * Spool Gear x 4
    * Spacer x 4
    * Spool Core x 4
    * Cable Clamp x ca 12
  * Vitamins
    * 5 x Nema17 steppers (> 40 N/cm holding torque, flat shaft)
    * 60 m FireLine 0.5 mm (0.39 mm also works)
    * ca 50x50 cm MDF or plywood sheet, thickness 10-14 mm
    * 1 x Arduino Mega
    * 1 x RAMPS
    * 5 x drivers (Special configuration options exist if you use Mechaduinos or tmc2130SilentStepSticks)
    * 1 x USB cable, type B plug
    * 3 x 40 cm rectangular/square beams, widths from 12.5 mm to 17.5 mm supported
    * 1 x 27.5 cm rectangular/square beam
    * 1 x Power supply (12 V, 12.5 A or higher recommended)
    * 18 x zipties, widths between 3 and 4.5 mm recommended
    * 16 x M3 screws, length 5 mm
    * 12 x M3 screws, length 12 mm
    * 4  x M8 screws, length > 50 mm, head countersunk
    * 8  x 608 bearings
    * 12 x 623 V-groove bearings
    * 10 cm PTFE tube (standard bowden, 4 mm outer dia, >1.75 mm inner dia)
    * ca 90 self tapping wood screws, thickness 2.5-4.5 mm, length 10 mm, head diameter 8-14 mm, non-countersunk head.
    * 4 x self tapping wood screws, thickness ca 4 mm, head diameter ca 8 mm, length ca 45 mm. Forfastening spool core.
    * 4 x self tapping wood screws, thickness ca 2 mm, head diameter ca 4 mm. For mounting Mega onto sheet material.
    * 18 x self tapping wood screws, thickness ca 2 mm, head diameter 5 mm, length 10 mm, countersunk head. For attaching linerollers on ABC anchors.
    * 5 m of 15-lead ribbon wire
    * Nuts and washers for all screws
    * Extruder + hot end (any setup that fits Nema17 mount will work)
    * Ca 0.5 m red and black power cable for connecting 12 V to RAMPS
    * Mechaduino optional addon
      * 4 x Mechaduino PCB
      * More than 20 jumper cables (if Mechaduinos)
      * 5V->3V3 level converter for i2c usage (if Mechaduinos)
      * Ca 2 m red and black power cable for connecting 12 V to Mechaduinos
    * Tmc2130SilentStepStick addon
      * A few more jumper wires

Using Nema23?
----------------
Then you need different sized motor brackets, extruder holders and motor gears.
To compile those do
```
make nema23
```
This compiles the files and puts them in the `openscad_stl_nema23/` directory.
