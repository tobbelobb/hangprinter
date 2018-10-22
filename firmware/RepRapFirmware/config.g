; Configuration file for testing Duet Ethernet and Wifi

; Communication and general
M111 S0                            		; Debug off
M550 PHP4Test					; Machine name and Netbios name (can be anything you like)
M551 Preprap                   			; Machine password (used for FTP)
;*** If you have more than one Duet on your network, they must all have different MAC addresses, so change the last digits
M540 P0xBE:0xEF:0xDE:0xAD:0xFE:0xED		; MAC Address

;*** Networking - Enable for both WiFi and Ethernet boards.
M552 S1						; Turn network on

;*** Ethernet networking: Adjust the IP address and gateway in the following 2 lines to suit your network
M552 P192.168.1.14				; (0 = DHCP)
M554 P192.168.1.255				; Gateway
M553 P255.255.255.0				; Netmask

M555 P2						; Set output to look like Marlin
G21						; Work in millimetres
G90						; Send absolute coordinates...
M83						; ...but relative extruder moves

; Enable Fan 1 thermostatic mode for heater 1 (E0 HEAT) at 45 degrees
M106 P1 T45 H1

; Axis and motor configuration
M669 K6				; This is a Hangprinter enables ABCD-parameters in gcodes that refer to motors
M584 A5 B6 C7 D8 P4	 	; map ABCD-axes to ext driver pins (four visible)
M584 E0:1:2:3:4 		; Regard all TMC2660s as extruder motor drivers

M569 P0 S1					; Drive 0 goes forwards
M569 P1 S1					; Drive 1 goes forwards
M569 P2 S1					; Drive 2 goes forwards
M569 P3 S1					; Drive 3 goes forwards
M569 P4 S1					; Drive 4 goes forwards
M569 P5 S1					; Drive 5 (A) goes forwards
M569 P6 S1					; Drive 6 (B) goes forwards
M569 P7 S1					; Drive 7 (C) goes forwards
M569 P8 S1					; Drive 8 (D) goes forwards
M669 J200:200:200:200		; Full steps per ABCD motor revolution

M669 A0.0:1000.0:-100.0 B 1000.0:1000.0:-100.0 C-1000.0:1000.0:-100.0 D2000.0	; Anchor positions in mm
M669 P2000.0                                    ; Printable radius
M669 Q0.7                                       ; Spool buildup factor
M669 W7500.0:7500.0:7500.0:4000.0               ; Mounted ABCD line lengths are
M669 R65.0:65.0:65.0:65.0                       ; Spool ABCD radii
M669 U2:2:2:2                                   ; Mechanical advantages on ABCD
M669 O1:1:1:1                                   ; Number of lines per spool
M669 L20:20:20:20                               ; Motor gear teeth of ABCD axes
M669 H255:255:255:255                           ; Spool gear teeth of ABCD axes

M569 P5 I"0x0a" ; i2c addresses set up, but will probably not be used on HP4
M569 P6 I"0x0b"
M569 P7 I"0x0c"
M569 P8 I"0x0d"

M906 D1000									; Motor D current 1000 mA

M574 X2 Y2 Z2 S1				; set endstop configuration (all endstops at high end, active high)
;*** The homed height is deliberately set too high in the following - you will adjust it during calibration
;M665 R105.6 L215.0 B85 H250			; set delta radius, diagonal rod length, printable radius and homed height
M666 X0 Y0 Z0					; put your endstop adjustments here, or let auto calibration find them
M350 X16 Y16 Z16 E16:16 I1			; Set 16x microstepping with interpolation
;M92 X80 Y80 Z80					; Set axis steps/mm
M906 X1000 Y1000 Z1000 E800 I60			; Set motor currents (mA) and increase idle current to 60%
M201 X1000 Y1000 Z1000 E1000			; Accelerations (mm/s^2)
M203 X20000 Y20000 Z20000 E3600			; Maximum speeds (mm/min)
M566 X1200 Y1200 Z1200 E1200			; Maximum instant speed changes mm/minute

; Thermistors
M305 P0 T100000 B3950 R4700 H30 L0		; Put your own H and/or L values here to set the bed thermistor ADC correction
M305 P1 T100000 B3974 R4700 H30 L0		; Put your own H and/or L values here to set first nozzle thermistor ADC correction
M305 P2 T100000 B3974 R4700 H30 L0		; Put your own H and/or L values here to set 2nd nozzle thermistor ADC correction

M570 S180					; Hot end may be a little slow to heat up so allow it 180 seconds

; Adjustments for J-heads used as dummy heaters on test rig
M307 H0 A250 C140 D5.5 B1
M307 H1 A250 C140 D5.5 B0
M307 H2 A250 C140 D5.5 B0

; Fans
M106 P1 S-1					; disable thermostatic mode for fan 1

; Tool definitions
M563 P0 D0 H1					; Define tool 0
G10 P0 S0 R0					; Set tool 0 operating and standby temperatures
;*** If you have a single-nozzle build, comment the next 2 lines
M563 P1 D1 H2					; Define tool 1
G10 P1 S0 R0					; Set tool 1 operating and standby temperatures
M92 E663:663					; Set extruder steps per mm

; Z probe and compensation definition
;*** If you have a switch instead of an IR probe, change P1 to P4 in the following M558 command
M558 P1 X0 Y0 Z0				; Z probe is an IR probe and is not used for homing any axes
G31 X0 Y0 Z4.80 P500				; Set the zprobe height and threshold (put your own values here)

;*** If you are using axis compensation, put the figures in the following command
M556 S78 X0 Y0 Z0				; Axis compensation here

M208 S1 Z-0.2					; set minimum Z

T0						; select first hot end
