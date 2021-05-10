use <util.scad>

difference(){
  union(){
    ydir_rounded_cube2([50+2*12, 12, 2], r=5, $fn=10*4);
    translate([0,2,0])
      rotate([90,0,0])
        ydir_rounded_cube2([50+2*12, 9.5, 2], r=2, $fn=10*4);
    translate([3.5+12,1.1,9.5-3.5])
      rotate([90,0,0])
        cylinder(d=7/cos(30), 2, $fn=6);
    translate([50-3.5+12,1.1,9.5-3.5])
      rotate([90,0,0])
        cylinder(d=7/cos(30), 2, $fn=6);
  }

  translate([3.5+12,0,9.5-3.5])
    rotate([90,0,0])
      cylinder(d=3.2, h=10, center=true, $fn=10);
  translate([50-3.5+12,0,9.5-3.5])
    rotate([90,0,0])
      cylinder(d=3.2, h=10, center=true, $fn=10);
  translate([50-3.5+12,1,9.5-3.5])
    rotate([90,0,0])
      nut(h=2);
  translate([3.5+12,1,9.5-3.5])
    rotate([90,0,0])
      nut(h=2);
  translate([5, 12-5, 0])
    Mounting_screw_countersink();
  translate([50+2*12-5, 12-5, 0])
    Mounting_screw_countersink();
  translate([17, 4, -1])
    ymdir_rounded_cube2([50+2*12-2*17, 8.1, 5], r=2, $fn=10*4);
  translate([17, 12, -1])
    rotate([0,0,180])
      inner_round_corner(r=2, h=5, $fn=4*10);
  translate([50+2*12-17, 12, -1])
    rotate([0,0,-90])
      inner_round_corner(r=2, h=5, $fn=4*10);
}
