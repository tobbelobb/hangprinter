G95 A1 B1 C1 D1 ; Set all motors in torque mode and drag close to origo
G92 X0 Y0 Z0    ; Assure that line lengths are re-calculated to match origo. Printer should be within ca 10 cm of origo.
G95 B0 C0 D0    ; Set BCD in position mode
G4 P2000        ; Dwell for 2000 ms
G96             ; Set sensor motor reference point

; Ready to collect data points
; Following thetas are what we'll get if anchors are symmetric, length 1500 with abc in z=0
; array([[    0.  , -1500.        ,     0.        ],
;        [ 1299.04,   750.        ,     0.        ],
;        [-1299.04,   750.        ,     0.        ],
;        [    0.  ,     0.        ,  1500.        ]])
; And all positions are in 3x3 square grid with side length 800 centered around (0, 0, 400)
; ... And there are no measurement errors at all.
; A-values are to be filled in by measurement.
; Points are ordered so that highest points are measured first.
; At each height, points closest to C are made first.
; In numpy: s = s[s[:,2].argsort()]
;           s = s[s[:,3].argsort(kind='mergesort')]

G7 B200.0 C200.0 D-800.0 F500
G4 P2000
G97
G7 B322.184 C-281.983 D106.225 F500
G4 P2000
G97
G7 B-456.936 C147.231 D0.0 F500
G4 P2000
G97
G7 B345.249 C345.249 D0.0 F500
G4 P2000
G97
G7 B-492.481 C111.687 D0.0 F500
G4 P2000
G97
G7 B492.279 C-768.881 D93.774 F500
G4 P2000
G97
G7 B291.800 C411.259 D0.0 F500
G4 P2000
G97
G7 B-948.793 C245.733 D0.0 F500
G4 P2000
G97
G7 B411.259 C291.800 D0.0 F500
G4 P2000
G97
G7 B-112.145 C-649.679 D200.0 F500
G4 P2000
G97
G7 B347.380 C-315.174 D70.469 F500
G4 P2000
G97
G7 B-496.230 C166.324 D0.0 F500
G4 P2000
G97
G7 B376.882 C376.882 D0.0 F500
G4 P2000
G97
G7 B-543.206 C119.348 D0.0 F500
G4 P2000
G97
G7 B542.990 C-855.398 D66.461 F500
G4 P2000
G97
G7 B310.037 C469.129 D0.0 F500
G4 P2000
G97
G7 B-1045.871 C266.704 D0.0 F500
G4 P2000
G97
G7 B469.129 C310.037 D0.0 F500
G4 P2000
G97
G7 B-13.528 C-590.270 D263.068 F500
G4 P2000
G97
G7 B357.210 C-329.201 D52.417 F500
G4 P2000
G97
G7 B-511.847 C174.563 D0.0 F500
G4 P2000
G97
G7 B389.572 C389.572 D0.0 F500
G4 P2000
G97
G7 B-564.136 C122.275 D0.0 F500
G4 P2000
G97
G7 B563.914 C-892.446 D50.704 F500
G4 P2000
G97
G7 B316.927 C494.951 D0.0 F500
G4 P2000
G97
G7 B-1086.876 C274.997 D0.0 F500
G4 P2000
G97
G7 B494.951 C316.927 D0.0 F500
G4 P2000
G97

G7 B-40.284  C551.640 D103.121 F500 ; Go back where you started
G92 X0 Y0 Z0                        ; Reset delta (array of line lengths in firmware)
G95 A0                              ; Set A motor back in position mode
