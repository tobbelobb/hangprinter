G95 A-40 B-40 C-40 D-20 ; Set all motors in torque mode and drag close to origo
G92 X0 Y0 Z0    ; Assure that line lengths are re-calculated to match origo. Printer should be within ca 10 cm of origo.
G95 A0 B0 D0    ; Set ABD in position mode
G4 P2000        ; Dwell for 2000 ms
G96 A B C D     ; Set sensor reference points

; Ready to collect data points
; Following thetas are what we'll get if anchors are symmetric, length 1500 with abc in z=0
;a = np.array([[0.0, -2163.0, -75.5],
;              [-1841.0, 741.0, -75.5],
;              [1639.0, 1404.0, -75.5],
;              [0.0, 0.0, 3250.5]])
; And all positions are in 3x3 square grid with side length 600 centered around (0, 0, 300)
; ... And there are no measurement errors at all.
; A-values are to be filled in by measurement.
; Points are ordered so that points farthes away from C anchor are measured first.
; In numpy: s = s[s[:,1].argsort()]
;           s = s[s[:,2].argsort(kind='mergesort')]
G95 C-50
G96 C
G95 C-3

G8 A0.000    B0.000    D0.000    F1500 ; C0.000
G95 C-50
G4 P2000        ; Dwell for 2000 ms
G97 a b c d
G95 C-3

G8 A-160.054 B-7.415   D-566.258 F1500 ; C508.811
G95 C-50
G4 P2000        ; Dwell for 2000 ms
G97 a b c d
G95 C-3

G8 A-240.319 B-88.767  D-269.652 F1500 ; C449.059
G95 C-50
G4 P2000        ; Dwell for 2000 ms
G97 a b c d
G95 C-3

G8 A-275.807 B-124.767 D27.571   F1500 ; C422.994
G95 C-50
G4 P2000        ; Dwell for 2000 ms
G97 a b c d
G95 C-3

G8 A121.480  B-147.471 D-583.076 F1500 ; C327.962
G95 C-50
G4 P2000        ; Dwell for 2000 ms
G97 a b c d
G95 C-3

G8 A-182.633 B234.227  D-583.076 F1500 ; C299.456
G95 C-50
G4 P2000        ; Dwell for 2000 ms
G97 a b c d
G95 C-3

G8 A51.437   B-235.320 D-284.787 F1500 ; C263.755
G95 C-50
G4 P2000        ; Dwell for 2000 ms
G97 a b c d
G95 C-3

G8 A20.692   B-274.399 D13.814   F1500 ; C235.674
G95 C-50
G4 P2000        ; Dwell for 2000 ms
G97 a b c d
G95 C-3

G8 A-263.851 B162.047  D-284.787 F1500 ; C234.484
G95 C-50
G4 P2000        ; Dwell for 2000 ms
G97 a b c d
G95 C-3

G8 A-299.788 B130.318  D13.814   F1500 ; C206.056
G95 C-50
G4 P2000        ; Dwell for 2000 ms
G97 a b c d
G95 C-3

G8 A407.193  B-246.580 D-566.258 F1500 ; C171.820
G95 C-50
G4 P2000        ; Dwell for 2000 ms
G97 a b c d
G95 C-3

G8 A-160.054 B488.677  D-566.258 F1500 ; C110.533
G95 C-50
G4 P2000        ; Dwell for 2000 ms
G97 a b c d
G95 C-3

G8 A345.138  B-339.709 D-269.652 F1500 ; C103.186
G95 C-50
G4 P2000        ; Dwell for 2000 ms
G97 a b c d
G95 C-3

G8 A101.707  B110.378  D-600.000 F1500 ; C101.926
G95 C-50
G4 P2000        ; Dwell for 2000 ms
G97 a b c d
G95 C-3

G8 A318.034  B-381.328 D27.571   F1500 ; C73.087
G95 C-50
G4 P2000        ; Dwell for 2000 ms
G97 a b c d
G95 C-3

G8 A-240.319 B424.129  D-269.652 F1500 ; C39.987
G95 C-50
G4 P2000        ; Dwell for 2000 ms
G97 a b c d
G95 C-3

G8 A31.034   B33.776   D-300.000 F1500 ; C31.103
G95 C-50
G4 P2000        ; Dwell for 2000 ms
G97 a b c d
G95 C-3

G8 A-275.807 B395.894  D27.571   F1500 ; C9.011
G95 C-50
G4 P2000        ; Dwell for 2000 ms
G97 a b c d
G95 C-3

G8 A389.634  B24.024   D-583.076 F1500 ; C-71.047
G95 C-50
G4 P2000        ; Dwell for 2000 ms
G97 a b c d
G95 C-3

G8 A121.480  B378.195  D-583.076 F1500 ; C-105.082
G95 C-50
G4 P2000        ; Dwell for 2000 ms
G97 a b c d
G95 C-3

G8 A327.141  B-56.002  D-284.787 F1500 ; C-147.951
G95 C-50
G4 P2000        ; Dwell for 2000 ms
G97 a b c d
G95 C-3

G8 A299.839  B-91.378  D13.814   F1500 ; C-181.869
G95 C-50
G4 P2000        ; Dwell for 2000 ms
G97 a b c d
G95 C-3

G8 A51.437   B310.544  D-284.787 F1500 ; C-183.310
G95 C-50
G4 P2000        ; Dwell for 2000 ms
G97 a b c d
G95 C-3

G8 A20.692   B280.895  D13.814   F1500 ; C-217.846
G95 C-50
G4 P2000        ; Dwell for 2000 ms
G97 a b c d
G95 C-3

G8 A407.193  B301.972  D-566.258 F1500 ; C-297.186
G95 C-50
G4 P2000        ; Dwell for 2000 ms
G97 a b c d
G95 C-3

G8 A345.138  B231.997  D-269.652 F1500 ; C-383.858
G95 C-50
G4 P2000        ; Dwell for 2000 ms
G97 a b c d
G95 C-3

G8 A318.034  B201.283  D27.571   F1500 ; C-422.375
G95 C-50
G4 P2000        ; Dwell for 2000 ms
G97 a b c d
G95 C-3
