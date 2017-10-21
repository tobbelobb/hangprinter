## State of Hangprinter firmware as of Aug 2, 2017

Both Hangprinter v2 (master branch) and Hangprinter v3 (Gbg_version_3 branch) uses

 - Arduino Mega + RAMPS running and old fork or Marlin, contained in this directory
 - Three or four Mechaduino controlled steppers, running the firmware in the Mechaduino_subtree directory

The Mechaduinos need to be configured with their own i2c addresses.
Marlin expects motor A to have i2c address 0x0a, motor b to have address 0x0b etc.
Note that the Mechaduinos must also be calibrated with their own individual lookup tables.
See instructions in the Mechaduino_subtree directory.

Mechaduinos are there to provide closed loop control (no skipped steps), torque mode, and for making automatic calibration (locating anchor points) possible.
See https://vimeo.com/227893849 and https://vimeo.com/227891846 for demos of torque mode and autocal data collection.
