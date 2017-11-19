# TMC2130 notes
The tmc2130 register fiddling are done in the stepper.cpp file's ```tmc_init()``` function.
Default settings have been tested with Wantai 42BYGH610P1 steppers.
  - Rated current: 1.2 A
  - Coil resistance: 6 ohm
  - Holding torque: 45 Ncm

## Hangprinter-Marlin

Hangprinter uses a modified Marlin version where the XYZ-axis are changed to ABCD-axis.
A lot of other small changes are also done, so it is not recommended to install this version of Marlin on your own microcontroller
  unless you know how to (and want to) read, change and debug the source code.

I have this running on an Arduino Mega (Atmega 2560) with a RAMPS shield myself.
Get in contact if you seriously plan on building a Hangprinter and want to use this firmware.

If you find bugs, they are probably the Hangprinter projects bugs, so do not bother the original Marlin project with bugs from this repo.

## Credits

Hangprinter-marlin (this modified version of Marlin) is developed by:

 - Torbjørn Ludvigsen ([@tobbelobb](https://github.com/tobbelobb))

Most code in this repo was originally written by Marlin devs.
Creds also to Sprinter devs and Grbl devs for various contributions.

To get the original Marlin firmware, head over to
([MarlinFirmware/Marlin](https://github.com/MarlinFirmware/Marlin)).

## Licence

[GPL license](/Documentation/COPYING.md)
