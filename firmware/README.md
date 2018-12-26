## State of Hangprinter v4 firmware as of Dec 26, 2018

HP4 will use RepRapFirmware and ODrive firmware.
The ODrive stock firmware will run without modifications.
Working RepRapFirmware versions that are adapted for HP usage will be copied, or at least linked here.

Later on, HP4 support will hopefully stabilize and be merged into all major firmwares, and this directory can simply contain instructions and configuration recommendations.

Read the the config files closely, they provide the most detail about how to use HP4 firmware.

## HP4 Firmware Compared to HP3 Firmware
Special commands like G95, G96, M114 S1 will be sent through UART instead of i2c.
The RepRapFirmware binary in this directory can still send G95, G96, and M114 S1 through i2c, if you're building a HP3 with DuetWifi/RRF.

A new special command M114 S2 that outputs angle diff instead of line length diff has been added (UART only).


