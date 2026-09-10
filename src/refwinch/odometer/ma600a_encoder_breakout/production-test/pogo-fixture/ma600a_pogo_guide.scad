// Six-probe guide for MA600A breakout TP1..TP6.
// Units: mm. Measure your pogo-pin barrels and tune pogo_hole_d before printing.

$fn = 64;

pogo_hole_d = 0.80;
plate_thickness = 4.0;
plate_width = 10.0;
plate_height = 16.0;

pattern_x = 3.5;
pattern_y = 4.0;
probe_points = [
    [pattern_x,       pattern_y],       // TP1 +5V
    [pattern_x,       pattern_y + 2],   // TP2 GND
    [pattern_x,       pattern_y + 4],   // TP3 /CS
    [pattern_x,       pattern_y + 6],   // TP4 SCLK
    [pattern_x,       pattern_y + 8],   // TP5 COPI
    [pattern_x + 2.0, pattern_y + 8]    // TP6 CIPO
];

assert(pogo_hole_d > 0.4 && pogo_hole_d < 1.6,
       "Set pogo_hole_d to a plausible measured probe-barrel diameter");
assert(pattern_x - pogo_hole_d / 2 > 1.2,
       "TP1..TP5 holes are too close to the plate edge");
assert(pattern_y - pogo_hole_d / 2 > 1.2,
       "TP1 hole is too close to the plate edge");

module orientation_notch() {
    translate([-0.01, 1.0, -0.1])
        linear_extrude(height = plate_thickness + 0.2)
            polygon(points = [[0, 0], [2.2, 0], [0, 2.2]]);
}

module guide() {
    difference() {
        linear_extrude(height = plate_thickness)
            offset(r = 1.0)
                offset(delta = -1.0)
                    square([plate_width, plate_height]);

        for (point = probe_points)
            translate([point[0], point[1], -0.1])
                cylinder(d = pogo_hole_d,
                         h = plate_thickness + 0.2);

        orientation_notch();

        translate([7.0, pattern_y - 0.7, plate_thickness - 0.5])
            linear_extrude(height = 0.6)
                text("1", size = 1.8, halign = "center", font = "Liberation Sans:style=Bold");
        translate([7.0, pattern_y + 7.3, plate_thickness - 0.5])
            linear_extrude(height = 0.6)
                text("6", size = 1.8, halign = "center", font = "Liberation Sans:style=Bold");
    }
}

guide();
