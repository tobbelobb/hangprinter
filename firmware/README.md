## State of Hangprinter v4 firmware as of Sep 20, 2018

HP4 will probably use RepRapFirmware and oDrive firmware.
The oDrive stock firmware will run with very small modifications (preferrably none, but not there yet).

Working RepRapFirmware versions that are adapted for HP usage will be copied, or at least linked here.
Later on, HP4 support will hopefully stabilize and be merged into all major firmwares, and this directory can simply contain instructions and configuration recommendations.

## HP4 Firmware Compared to HP3 Firmware
Special commands G95, G96, M114 S1 will be sent through UART instead of i2c.
A new special command M114 S2 that outputs angle diff instead of line length diff will be added.


