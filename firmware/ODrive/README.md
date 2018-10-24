The bin and elf files posted here are for v3.5 24V ODrive boards unless otherwise noted.

The only difference compared to stock ODrive firmware is that step/dir for motor0 connects to GPIO 3 and 4, so that we can use GPIO 1 and 2 for UART.

The board I'm using while developing is an ODrive v3.5 24V.
The binaries in this directory only works for that board.
If you have another version, I recommend that you head over to the source and compile it for the board that you have.

The source is kept here:
https://github.com/tobbelobb/ODrive/tree/devel-hangprinter
