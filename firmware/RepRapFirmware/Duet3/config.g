; Communication and general
G21              ; Work in millimetres
G90              ; Send absolute coordinates...
M83              ; ...but relative extruder moves

; Kinematics
G4 S1                           ; Wait 1 second because expansion boards might not be ready to receive CAN signal yet.
M584 X40.0 Y41.0 Z42.0 U43.0 P4 ; map ABCD-axes to CAN addresses, and set four visible axes. Please excuse that ABCD motors are called XYZU here.
M584 E0:1:2:3:4:5               ; Regard all built in stepper drivers as extruder drives
M669 K6                         ; "This is a Hangprinter"
M669 P2000.0                    ; Printable radius (unused by Hangprinters for now)
M669 S430 T0.1                  ; Segments per second and min segment length

; Output of auto calibration script for Hangprinter
M669 A0.0:-1610.98:-131.53 B1314.22:1268.14:-121.28 C-1415.73:707.61:-121.82 D-0.00:0.01:2299.83
M666 Q0.128181 R75.546:75.659:76.128:75.192
; Explanation:
; ; M669 defines the positions of the anchors, expressed as X:Y:Z distances between a line's pivot points, when the machine is homed.
; ; M666 sets Q=spool buildup, R=spool radii (incl buildup, when homed)

M208 Z2000.00  ; set maximum Z somewhere below to D anchor. See M669 ... D<number>
M208 S1 Z-10.0 ; set minimum Z

; The following values must also be in the auto calibration script for Hangprinter (if you plan to use it)
M666 U2:2:2:4         ; Mechanical advantages on ABCD
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

;; Warning: On a Hangprinter, ABCD motor directions shouldn't be changed, at least not
;;          via this config.g file.
;;          They are duplicated and hard coded into the firmware
;;          to make ODrive's torque mode go the right way.
;;          Please connect BLDC wires, from left to right, looking at the board
;;          from the front, so that ODrive silk screen is readable from left to right:
;;          |---------------------------------------------------------------|
;;          |                                                               |
;;          |                     ODrive                                    |
;;          |                                                               |
;;          |                          AUX                                  |
;;          |--||---||---||------------------------------------||---||---||-|
;;             ||   ||   ||                                    ||   ||   ||
;;          Black, Red, Blue                                Black, Red, Blue
;;
;;
;; Also, as of Aug 18, 2021, Hangprinter users must use the unstable repository for the Duet3 Rpi.
;; See here for how to set that up:
;; https://duet3d.dozuki.com/Wiki/Getting_Started_With_Duet_3#Section_Software_Installation

M569 P40.0 S1 ; Drive 40.0 (A) goes forwards
M569 P41.0 S1 ; Drive 41.0 (B) goes forwards
M569 P42.0 S0 ; Drive 42.0 (C) goes backwards
M569 P43.0 S0 ; Drive 43.0 (D) goes backwards

; Speeds and accelerations
M201 X10000 Y10000 Z10000 U10000 E1000       ; Max accelerations (mm/s^2)
M203 X36000 Y36000 Z36000 E3600              ; Max speeds (mm/min)
M204 P2000 T4000                            ; Accelerations while printing and for travel moves
M566 X240 Y240 Z1200 E1200                 ; Maximum instant speed changes mm/minute

; Currents
M906 E1400 I60             ; Set motor currents (mA) and increase idle current to 60%

; Endstops
M574 X0 Y0 Z0                                ; set endstop configuration (no endstops)

; Thermistors and heaters
M308 S1 P"temp0" Y"thermistor" T100000 B3950 ; Configure sensor 1 as thermistor on temp1
M950 H1 C"out1" T1                           ; create nozzle heater output on out1 and map it to sensor 1
M307 H1 B0 S1.00                             ; disable bang-bang mode for nozzle heater and set PWM limit
M307 H1 A1271.9 C432.5 D8.2 V24              ; Set heater parameters (for Super Volcano 80W. You probably want to tune this yourself with M303.)
M143 H1 S280                                 ; set temp limit for nozzle heater to 280C
M570 S180                                    ; Hot end may be a little slow to heat up so allow it 180 seconds

; Fans
M950 F1 C"out7"
M106 P1 X255 T45 H1                                ; Enable Fan 1 thermostatic mode for sensor or heater 1 at 45 degrees
M950 F0 C"out8"                                    ; Defines a part cooling fan

; Find "temp0" and "out7" pins in the wiring diagram:
; https://duet3d.dozuki.com/Wiki/Duet_3_Mainboard_6HC_Wiring_Diagram

; Bltouch
; If you have a bltouch, see
; https://duet3d.dozuki.com/Wiki/Connecting_a_Z_probe#Section_BLTouch
; for how to install it
; Some of the commands below here might be different for you
; (eg if you don't have a Duet3 board, don't use the io7 headers, or have your bltouch mounted differently than me)
M950 S0 C"io7.out"
M558 P9 C"io7.in" H5 F120 T6000
G31 X15 Y27 Z8 P25 ; Measure these values in your own setup.

; These affect how you create and your mesh/grid bed compensation heightmap.csv values
; M557 X-200.001:200 Y-277.001:277 S80 ; Define a A2 sized grid with 1 cm margin...
; M376 H20 ; Taper the mesh bed compensation over 20 mm of z-height
; G29 S1 ; Load the default heightmap.csv and enable grid compensation


; Tool definitions
M563 P0 D0 H1                                      ; Tool number 0, with extruder drive 0 uses heater 1 and no fan
G10 P0 S0 R0                                       ; Set initial tool 0 active at standby temperature 0

; Miscellaneous
M92 E415                                           ; Set extruder steps per mm
M911 S10 R11 P"M913 X0 Y0 Z0 G91 M83 G1 Z3 E-5 F1000" ; set voltage thresholds and actions to run on power loss
T0                                                 ; Select tool 0
