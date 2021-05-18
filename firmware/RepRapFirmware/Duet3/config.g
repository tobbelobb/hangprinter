; Communication and general
M552 P0.0.0.0 S1 ; Enable network
G21              ; Work in millimetres
G90              ; Send absolute coordinates...
M83              ; ...but relative extruder moves

; Kinematics
G4 S1                           ; Wait 1 second because expansion boards might not be ready to receive CAN signal yet.
M584 X40.0 Y41.0 Z42.0 D43.0 P4 ; map ABCD-axes to CAN addresses, and set four visible axes. Please excuse that ABC motors are called XYZ here.
M584 E0:1:2:3:4:5               ; Regard all built in stepper drivers as extruder drives
M669 K6                         ; "This is a Hangprinter"
M669 P2000.0                    ; Printable radius (unused by Hangprinters for now)
M669 S200                       ; Segments per second

; Output of auto calibration script for Hangprinter
M669 A0.0:-1604.54:-114.08 B1312.51:1270.88:-162.19 C-1440.27:741.63:-161.23 D2345.00
M666 Q0.035619 R65.239:65.135:65.296:64.673
; Explanation:
; ; M669 defines the positions of the anchors, expressed as X:Y:Z distances between a line's pivot points, when the machine is homed.
; ; M666 sets Q=spool buildup, R=spool radii (incl buildup, when homed)

M208 Z2000.00  ; set maximum Z somewhere below to D anchor. See M669 ... D<number>
M208 S1 Z-10.0 ; set minimum Z

; The following values must also be in the auto calibration script for Hangprinter (if you plan to use it)
M666 U2:2:2:2         ; Mechanical advantages on ABCD
M666 O1:1:1:1         ; Number of lines per spool
M666 L20:20:20:20     ; Motor gear teeth of ABCD axes
M666 H255:255:255:255 ; Spool gear teeth of ABCD axes

; Uncomment M564 S0 if you don't want G0/G1 moves to be be limited to a software defined volume
; M564 S0

; Drives
M666 J25:25:25:25 ; Full steps per ABCD motor revolution (match with ODrives...)

M569 P0 S1 ; Drive 0 goes forwards
M569 P1 S1 ; Drive 1 goes forwards
M569 P2 S1 ; Drive 2 goes forwards
M569 P3 S1 ; Drive 3 goes forwards
M569 P4 S1 ; Drive 4 goes forwards
M569 P5 S1 ; Drive 5 goes forwards
M569 P6 S1 ; Drive 6 (A) goes forwards
M569 P7 S0 ; Drive 7 (B) goes backwards
M569 P8 S1 ; Drive 8 (C) goes forwards
M569 P9 S0 ; Drive 9 (D) goes backwards

;M569 P5 I"0x0a" ; i2c addresses set up, but will probably not be used on HP4
;M569 P6 I"0x0b"
;M569 P7 I"0x0c"
;M569 P8 I"0x0d"
;;;; DRIVER CONFIG END

;;;; CAN SETTINGS
;;;; CAN SETTINGS END

; Speeds
M201 X10000 Y10000 Z10000 E1000              ; Accelerations (mm/s^2)
M203 X36000 Y36000 Z36000 E3600              ; Maximum speeds (mm/min)
M566 X1200 Y1200 Z1200 E1200                 ; Maximum instant speed changes mm/minute

; Currents
M906 X1200 Y1200 Z1200 E1400 I60             ; Set motor currents (mA) and increase idle current to 60%

; Endstops
M574 X2 Y2 Z2 S1                             ; set endstop configuration (all endstops at high end, active high)

; Thermistors and heaters
M308 S1 P"temp1" Y"thermistor" T100000 B3950 ; Configure sensor 1 as thermistor on temp1
M950 H1 C"out1" T1                           ; create nozzle heater output on out1 and map it to sensor 1
M307 H1 B0 S1.00                             ; disable bang-bang mode for nozzle heater and set PWM limit
M307 H1 A1271.9 C432.5 D8.2 V24              ; Set heater parameters (for Super Volcano 80W. You probably want to tune this yourself with M303.)
M143 H1 S280                                 ; set temp limit for nozzle heater to 280C
M570 S180                                    ; Hot end may be a little slow to heat up so allow it 180 seconds

; Fans
M950 F1 C"out4" Q500
M106 P1 X150 T45 H1                                ; Enable Fan 1 thermostatic mode for sensor or heater 1 at 45 degrees

; Find "temp1" and "out4" pins in the wiring diagram:
; https://duet3d.dozuki.com/Wiki/Duet_3_Mainboard_6HC_Wiring_Diagram

; Tool definitions
M563 P0 D0 H1                                      ; Tool number 0, with extruder drive 0 uses heater 1 and no fan
G10 P0 S0 R0                                       ; Set initial tool 0 active at standby temperature 0

; Miscellaneous
M92 E415                                           ; Set extruder steps per mm
M911 S10 R11 P"M913 X0 Y0 G91 M83 G1 Z3 E-5 F1000" ; set voltage thresholds and actions to run on power loss
T0                                                 ; Select tool 0
