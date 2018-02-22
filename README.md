Hangprinter ![Hangprinter logo](https://vitana.se/opr3d/tbear/bilder/logo_blue_50.png)
===========

This is the main dev branch of Hangprinter v3.
Read [blog](http://vitana.se/opr3d/tbear) to stay up to date with what happens here.

Bill of Materials
----------------
You can help fund future development of this project by using the affiliate links below when sourcing vitamins.
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
    * 5 x Nema17 steppers (> 40 N/cm holding torque, flat shaft) [Ebay](https://rover.ebay.com/rover/1/711-53200-19255-0/1?icep_id=114&ipn=icep&toolid=20004&campid=5338261873&mpre=https%3A%2F%2Fwww.ebay.com%2Fitm%2FEU-UK-5PCS-Nema17-Stepper-Motor-40Ncm-56oz-in-1-7A-D-Shaft-Connector-42BYGHW609%2F282269299534%3Fhash%3Ditem41b88fb34e%3Ag%3A1RIAAOSwa~BYOSvo)
    * 60 m FireLine 0.5 mm (0.39 mm also works) [Ebay](https://rover.ebay.com/rover/1/711-53200-19255-0/1?icep_id=114&ipn=icep&toolid=20004&campid=5338261873&mpre=https%3A%2F%2Fwww.ebay.com%2Fitm%2FBerkley-Fireline-Fused-Braid-270m-200m-Red-or-Flame-Green-HALF-RRP%2F152722109171%3Fhash%3Ditem238ef272f3%3Am%3AmlH_QITtLjoiiv5Mi0Va5ww)
    * ca 50x50 cm MDF or plywood sheet, thickness 10-14 mm
    * 1 x Arduino Mega [Ebay](https://rover.ebay.com/rover/1/711-53200-19255-0/1?icep_id=114&ipn=icep&toolid=20004&campid=5338261873&mpre=https%3A%2F%2Fwww.ebay.com%2Fitm%2FArduino-Mega-2560-R3-Development-Board-3D-Printer-Controller-Kit-RAMPS-1-4%2F172861877756%3Fhash%3Ditem283f5eedfc%3Ag%3Au70AAOSwAHtaQ~tD)
    * 1 x RAMPS
    * 5 x drivers (Special configuration options exist if you use Mechaduinos or tmc2130SilentStepSticks)
    * 1 x USB cable, type B plug
    * 3 x 40 cm rectangular/square beams, widths from 12.5 mm to 17.5 mm supported [Ebay](https://rover.ebay.com/rover/1/711-53200-19255-0/1?icep_id=114&ipn=icep&toolid=20004&campid=5338261873&mpre=https%3A%2F%2Fwww.ebay.com%2Fitm%2F2PCS-15x15x500mm-3K-Carbon-Fiber-Square-Tube-for-Quadcopter-Drone-Frame-Building%2F262636073453%3Fhash%3Ditem3d265471ed%3Ag%3AbusAAOSwLF1X4qPT)
    * 1 x 27.5 cm rectangular/square beam
    * 1 x Power supply (12 V, 12.5 A or higher recommended) [Ebay](https://rover.ebay.com/rover/1/711-53200-19255-0/1?icep_id=114&ipn=icep&toolid=20004&campid=5338261873&mpre=https%3A%2F%2Fwww.ebay.com%2Fitm%2FPower-Supply-Transformer-ACDC-12V-5A-10A-15A-20A-30A-Switching-Strip-Light-Drive%2F311987089539%3Fhash%3Ditem48a3e13083%3Am%3Am3F7iYPDhcHjSskMFnM4UqA)
    * 18 x zipties, widths between 4 and 5 mm recommended [Ebay](https://rover.ebay.com/rover/1/711-53200-19255-0/1?icep_id=114&ipn=icep&toolid=20004&campid=5338261873&mpre=https%3A%2F%2Fwww.ebay.com%2Fitm%2F100PCS-Strong-Cable-Ties-Tie-Wraps-Zip-Ties-BG-U4X3%2F253211433768%3Fepid%3D2070384363%26hash%3Ditem3af493db28%3Am%3AmM63kF5A1xS58LVwzSU10lQ)
    * 16 x M3 screws, length 5 mm [Ebay](https://rover.ebay.com/rover/1/711-53200-19255-0/1?icep_id=114&ipn=icep&toolid=20004&campid=5338261873&mpre=https%3A%2F%2Fwww.ebay.com%2Fitm%2F24-50-100pc-M3-Black-12-9-Alloy-Steel-Hex-Socket-Cap-Head-Screws-Bolts-Durable%2F232348638920%3Fhash%3Ditem36190edec8%3Am%3AmLIA5MGiNeQRxwcpshX8H9A)
    * 12 x M3 screws, length 12 mm [Ebay](https://rover.ebay.com/rover/1/711-53200-19255-0/1?icep_id=114&ipn=icep&toolid=20004&campid=5338261873&mpre=https%3A%2F%2Fwww.ebay.com%2Fitm%2F24-50-100pc-M3-Black-12-9-Alloy-Steel-Hex-Socket-Cap-Head-Screws-Bolts-Durable%2F232348638920%3Fhash%3Ditem36190edec8%3Am%3AmLIA5MGiNeQRxwcpshX8H9A)
    * 8  x 608 bearings [Ebay](https://rover.ebay.com/rover/1/711-53200-19255-0/1?icep_id=114&ipn=icep&toolid=20004&campid=5338261873&mpre=https%3A%2F%2Fwww.ebay.com%2Fitm%2F10Pcs-608-2RS-Miniature-Deep-Groove-Steel-Sealed-Ball-Bearings-High-Quality%2F172278791736%3Fepid%3D583929394%26hash%3Ditem281c9dbe38%3Ag%3AsGEAAOSwB-1Yps8B)
    * 12 x 623 V-groove bearings [Ebay](https://rover.ebay.com/rover/1/711-53200-19255-0/1?icep_id=114&ipn=icep&toolid=20004&campid=5338261873&mpre=https%3A%2F%2Fwww.ebay.com%2Fitm%2F10PCS-V623ZZ-3-12-4mm-Skateboard-Bearing-Miniature-Bearing-V-groove-bearings%2F222720565018%3Fhash%3Ditem33db2e1f1a%3Ag%3A67UAAOSwBjdaDFNO)
    * 10 cm PTFE tube (standard bowden, 4 mm outer dia) [Ebay](https://rover.ebay.com/rover/1/711-53200-19255-0/1?icep_id=114&ipn=icep&toolid=20004&campid=5338261873&mpre=https%3A%2F%2Fwww.ebay.com%2Fitm%2F1M-3-28FT-Teflon-Tube-Bowden-Reprap-2x4mm-Feed-Tube-PTFE-3D-Printer-1-75mm%2F263099849998%3Fepid%3D9005836645%26hash%3Ditem3d41f91d0e%3Ag%3AxhsAAOSwENhZccax)
    * ca 90 self tapping wood screws, thickness 2.5-4.5 mm, length 10 mm, head diameter 8-14 mm, non-countersunk head. [Ebay](https://rover.ebay.com/rover/1/711-53200-19255-0/1?icep_id=114&ipn=icep&toolid=20004&campid=5338261873&mpre=https%3A%2F%2Fwww.ebay.com%2Fitm%2FM3-M4-Phillips-Truss-Head-Self-Tapping-Screws-A4-Marine-Stainless-Steel-G316%2F272989838286%3Fhash%3Ditem3f8f765bce%3Am%3AmItjJDdPrHtWtEWfCkRMWvQ)
    * 4 x self tapping wood screws, thickness ca 4 mm, head diameter ca 8 mm, length ca 45 mm. For fastening spool core. [Ebay](https://rover.ebay.com/rover/1/711-53200-19255-0/1?icep_id=114&ipn=icep&toolid=20004&campid=5338261873&mpre=https%3A%2F%2Fwww.ebay.com%2Fitm%2FM3-M4-Phillips-Truss-Head-Self-Tapping-Screws-A4-Marine-Stainless-Steel-G316%2F272989838286%3Fhash%3Ditem3f8f765bce%3Am%3AmItjJDdPrHtWtEWfCkRMWvQ)
    * 4 x self tapping wood screws, thickness ca 2 mm, head diameter ca 4 mm. For mounting Mega onto sheet material. [Ebay](https://rover.ebay.com/rover/1/711-53200-19255-0/1?icep_id=114&ipn=icep&toolid=20004&campid=5338261873&mpre=https%3A%2F%2Fwww.ebay.com%2Fitm%2FM2-M3-5-Socket-Cap-Head-Screws-Allen-Key-Self-Tapping-Tappers-8-8-High-Tensile%2F273011763636%3Fhash%3Ditem3f90c4e9b4%3Am%3Am1iJL-UyDpUQE8KKQp_WCcQ)
    * 18 x self tapping wood screws, thickness ca 3 mm, head diameter 7 mm, length 10 mm, countersunk head. For attaching linerollers on ABC anchors. [Ebay](https://rover.ebay.com/rover/1/711-53200-19255-0/1?icep_id=114&ipn=icep&toolid=20004&campid=5338261873&mpre=https%3A%2F%2Fwww.ebay.com%2Fitm%2FM3-5-M4-2-Thread-Forming-Phillips-Flat-Head-Self-Tapping-Screws-Wood-Bolts%2F332429620615%3Fhash%3Ditem4d66597587%3Am%3Am4WJ8Dqnvx-EgeRF9Q1SUUA)
    * 5 m of 15-lead ribbon wire (or 30-lead 28AWF with quadrupled wires to/from the heater element) [Ebay](https://rover.ebay.com/rover/1/711-53200-19255-0/1?icep_id=114&ipn=icep&toolid=20004&campid=5338261873&mpre=https%3A%2F%2Fwww.ebay.com%2Fitm%2F15ft-30-Way-Flat-Color-Rainbow-Multicolor-Ribbon-Cable-Wire-28-AWG-%2F252373148128%3Fhash%3Ditem3ac29ca1e0%3Ag%3AmocAAOSwaG9XJIUC)
    * 12 x M3 Nuts [Ebay](https://rover.ebay.com/rover/1/711-53200-19255-0/1?icep_id=114&ipn=icep&toolid=20004&campid=5338261873&mpre=https%3A%2F%2Fwww.ebay.com%2Fitm%2F100pcs-M2-M3-M4-M6-Hex-Screw-Nut-Steel-Hexagon-Galvanized-Nuts-NEW-DIY-Craft%2F121999369069%3Fhash%3Ditem1c67baa36d%3Am%3AmnT9Q7CYFJnxhbLgmomTezQ)
    * Extruder + hot end (any setup that fits Nema17 mount will work)
    * Ca 0.5 m red and black power cable for connecting 12 V to RAMPS
    * Mechaduino optional addon
      * 4 x Mechaduino PCB
      * More than 20 jumper cables (if Mechaduinos) [Ebay](https://rover.ebay.com/rover/1/711-53200-19255-0/1?icep_id=114&ipn=icep&toolid=20004&campid=5338261873&mpre=https%3A%2F%2Fwww.ebay.com%2Fitm%2F120pcs-Dupont-Wire-Male-to-Male-Male-to-Female-Female-to-Female-Jumper-Cable%2F400932483189%3Fhash%3Ditem5d59703075%3Ag%3AFEgAAOSw42dZLnrH)
      * 5V->3V3 level converter for i2c usage (if Mechaduinos) [Ebay](https://rover.ebay.com/rover/1/711-53200-19255-0/1?icep_id=114&ipn=icep&toolid=20004&campid=5338261873&mpre=https%3A%2F%2Fwww.ebay.com%2Fitm%2F2Pcs-4-Channel-IIC-I2C-Logic-Level-Converter-Bi-Directional-Module-5V-3-3V%2F221919114584%3Fhash%3Ditem33ab68f558%3Ag%3ANvIAAOSw5VFWJwmj)
      * Ca 2 m red and black power cable for connecting 12 V to Mechaduinos
    * Tmc2130SilentStepStick addon
      * A few more jumper wires [Ebay](https://rover.ebay.com/rover/1/711-53200-19255-0/1?icep_id=114&ipn=icep&toolid=20004&campid=5338261873&mpre=https%3A%2F%2Fwww.ebay.com%2Fitm%2F120pcs-Dupont-Wire-Male-to-Male-Male-to-Female-Female-to-Female-Jumper-Cable%2F400932483189%3Fhash%3Ditem5d59703075%3Ag%3AFEgAAOSw42dZLnrH)

Using Nema23?
----------------
Then you need different sized motor brackets, extruder holders and motor gears.
To compile those do
```
make nema23
```
This compiles the files and puts them in the `openscad_stl_nema23/` directory.

