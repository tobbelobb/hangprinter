# Hangprinter-marlin (Modified Marlin 3D Printer Firmware for Hangprinter)

Hangprinter uses a modified Marlin version where the XYZ-axis are changed to ABCD-axis.
A lot of other small changes are also done, so it is not recommended to install this version of Marlin on your own microcontroller
  unless you know how to (and want to) read, change and debug the source code.

If you find bugs, they are probably the Hangprinter projects bugs, so do not bother the original Marlin project with bugs from this repo.

I have this running on an Arduino Mega (Atmega 2560) with a RAMPS shield myself.
Get in contact if you seriously plan on building a Hangprinter and want to use this firmware.

## Credits

Hangprinter-marlin (this modified version of Marlin) is developed by:

 - Torbjørn Ludvigsen ([@tobbelobb](https://github.com/tobbelobb))

The current Marlin dev team consists of:

 - Erik van der Zalm ([@ErikZalm](https://github.com/ErikZalm))
 - [@daid](https://github.com/daid)
 
Sprinters lead developers are Kliment and caru.
Grbls lead developer is Simen Svale Skogsrud.
Sonney Jeon (Chamnit) improved some parts of grbl
A fork by bkubicek for the Ultimaker was merged.

More features have been added by:
  - Lampmaker,
  - Bradley Feldman,
  - and others...

## Licence

[GPL license](/Documentation/COPYING.md)
