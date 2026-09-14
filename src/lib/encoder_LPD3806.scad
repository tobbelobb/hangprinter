// Mechanical model of the LPD3806 incremental encoder.
//
// The model was recovered from the old Donkey motor assembly.  The encoder
// body is nominally 38 mm in diameter and 34 mm high.  Its six mounting
// holes are arranged as three pairs at 120 degree intervals.

LPD3806_shaft_d = 6;

module encoder_LPD3806() {
  difference() {
    union() {
      color("slategrey")
        cylinder(d=38, h=32); // black body
      translate([0, 0, 1])
        cylinder(d=38 - 0.1, h=34 - 1); // shiny body
    }

    // Two holes in each of three mounting ears.
    for (rot = [0:120:359])
      rotate([0, 0, rot])
        for (k = [1, -1])
          translate([14, k * 7.5 / 2, 34 - 10])
            cylinder(d=3, h=11);
  }

  translate([0, 0, 1]) {
    difference() {
      cylinder(d=20, h=34 + 5 - 1);
      translate([0, 0, 34 + 5 - 1.5])
        cylinder(d=15, h=10 - 1); // down to bearing
    }

    difference() {
      cylinder(d=LPD3806_shaft_d, h=51.3 - 1, $fn=20); // shaft
      translate([-2, 2.5, 51.3 - 10 - 1])
        cube([4, 2, 10 + 1]); // D-side of shaft
    }
  }
}
