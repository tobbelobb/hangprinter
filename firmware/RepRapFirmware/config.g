; Configuration file for testing Duet Ethernet and Wifi

; Communication and general
M111 S0 ; Debug off
M550 PHP4Test ; Machine name and Netbios name (can be anything you like)
M551 Preprap ; Machine password (used for FTP)
;*** If you have more than one Duet on your network, they must all have different MAC addresses, so change the last digits
M540 P0xBE:0xEF:0xDE:0xAD:0xFE:0xED ; MAC Address

;*** Networking - Enable for both WiFi and Ethernet boards.
M552 S1 ; Turn network on

;*** Ethernet networking: Adjust the IP address and gateway in the following 2 lines to suit your network
M552 P192.168.1.14 ; (0 = DHCP)
M554 P192.168.1.255 ; Gateway
M553 P255.255.255.0 ; Netmask

M555 P2 ; Set output to look like Marlin
G21 ; Work in millimetres
G90 ; Send absolute coordinates...
M83 ; ...but relative extruder moves

;;;; HANGPRINTER SPECIALS (M669, M666) BEGIN HERE ;;;;
M669 K6 ; This is a Hangprinter enables ABCD-parameters in gcodes that refer to motors
M584 A5 B6 C7 D8 P4 ; map ABCD-axes to ext driver pins (four visible)
M584 E0:1:2:3:4 ; Regard all TMC2660s as extruder motor drivers
M569 P0 S1 ; Drive 0 goes forwards
M569 P1 S1 ; Drive 1 goes forwards
M569 P2 S1 ; Drive 2 goes forwards
M569 P3 S1 ; Drive 3 goes forwards
M569 P4 S1 ; Drive 4 goes forwards
M569 P5 S1 ; Drive 5 (A) goes forwards
M569 P6 S0 ; Drive 6 (B) goes backwards
M569 P7 S1 ; Drive 7 (C) goes forwards
M569 P8 S0 ; Drive 8 (D) goes backwards

M669 P2000.0 ; Hangprinter printable radius (unused for now)
M669 S200 ; Hangprinter segments per second

; Output of auto calibration script for Hangprinter
M669 A0.0:-1604.54:-114.08 B1312.51:1270.88:-162.19 C-1440.27:741.63:-161.23 D2345.00
M666 Q0.035619 R65.239:65.135:65.296:64.673

; End of output auto calibration script for Hangprinter

; The following is assumed
; by the auto calibration script
; to be constant for all HP4s
M666 U2:2:2:2 ; Mechanical advantages on ABCD
M666 O1:1:1:1 ; Number of lines per spool
M666 L20:20:20:20 ; Motor gear teeth of ABCD axes
M666 H255:255:255:255 ; Spool gear teeth of ABCD axes

; Adjust the following to match your ODrive settings
M666 J25:25:25:25 ; Full steps per ABCD motor revolution

M208 Z2309.54 ; set maximum Z at D anchor. See M669 ... D<number>

; Use
; M564 S0
; If you don't want G0/G1 moves to be be limited to a software defined volume

;M569 P5 I"0x0a" ; i2c addresses set up, but will probably not be used on HP4
;M569 P6 I"0x0b"
;M569 P7 I"0x0c"
;M569 P8 I"0x0d"

; Connect ODrive 0 to Serial device 1 at 115200 baud
M569 Q0:1:115200
; Connect ODrive 1 to Serial device 99 at 115200 baud
M569 Q1:99:115200
; Device 99 is the two middle pins on DuetWifi's SPIO header
; (sometimes called Temp Daughterboard header)
; The special number 99 is used because this serial device
; is special. It's really meant to be used for
; SPI communication with temp daughterboards and such.
; MOSI = TX (Connects to ODrive's RX)
; MISO = RX (Connects to ODrive's TX)
; Look for SPI0_MISO and SPI0_MOSI on DuetWifi wiring diagram

M201 X10000 Y10000 Z10000 E1000 ; Accelerations (mm/s^2)
M203 X36000 Y36000 Z36000 E3600 ; Maximum speeds (mm/min)

M574 X2 Y2 Z2 S1 ; set endstop configuration (all endstops at high end, active high)
M906 X1200 Y1200 Z1200 E1400 I60 ; Set motor currents (mA) and increase idle current to 60%
M566 X1200 Y1200 Z1200 E1200 ; Maximum instant speed changes mm/minute

; Thermistors
M305 P0 T100000 B3950 R4700 H30 L0 ; Put your own H and/or L values here to set the bed thermistor ADC correction
M305 P1 T100000 B3974 R4700 H30 L0 ; Put your own H and/or L values here to set first nozzle thermistor ADC correction
M305 P2 T100000 B3974 R4700 H30 L0 ; Put your own H and/or L values here to set 2nd nozzle thermistor ADC correction

M570 S180 ; Hot end may be a little slow to heat up so allow it 180 seconds

; Adjustments for J-heads used as dummy heaters on test rig
M307 H0 A250 C140 D5.5 B1

# Super Volcano 80W 24V
M307 H1 A1271.9 C432.5 D8.2 B0

M307 H2 A250 C140 D5.5 B0

; Tool definitions
M563 P0 D0 H1 ; Define tool 0
G10 P0 S0 R0 ; Set tool 0 operating and standby temperatures

;*** If you have a single-nozzle build, comment the next 2 lines
M563 P1 D1 H2 ; Define tool 1
G10 P1 S0 R0 ; Set tool 1 operating and standby temperatures

M92 E415 ; Set extruder steps per mm

M208 S1 Z-10.0 ; set minimum Z

T0 ; select first hot end

; Enable Fan 1 thermostatic mode for heater 1 (E0 HEAT) at 45 degrees
M106 P2 X150 T45 H1

