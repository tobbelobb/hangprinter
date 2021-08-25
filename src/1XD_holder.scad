use <lib/util.scad>

difference(){
  union(){
    ydir_rounded_cube2([50+2*12, 12, 2], r=5, $fn=10*4);
    translate([0,2,0])
      rotate([90,0,0])
        ydir_rounded_cube2([50+2*12, 9.5, 2], r=2, $fn=10*4);
    translate([3.5+12,1.1,9.5-3.5])
      rotate([90,0,0])
        nut_wall(h=2);
    translate([50-3.5+12,1.1,9.5-3.5])
      rotate([90,0,0])
        nut_wall(h=2);
    translate([3.5+12,1.1+5,9.5-3.5])
      rotate([90,0,0]){
        cylinder(h=5, d=6, $fn=20);
        translate([-3,-6,0])
          cube([6,6,5]);
      }
    translate([50-3.5+12,1.1+5,9.5-3.5])
      rotate([90,0,0]){
        cylinder(h=5, d=6, $fn=20);
        translate([-3,-6,0])
          cube([6,6,5]);
      }
  }
  translate([3.5+12,0,9.5-3.5])
    rotate([90,0,0])
      M3_screw(h=20, center=true);
  translate([50-3.5+12,0,9.5-3.5])
    rotate([90,0,0])
      M3_screw(h=20, center=true);
  translate([50-3.5+12,1,9.5-3.5])
    rotate([90,0,0])
      M3_nut(h=2);
  translate([3.5+12,1,9.5-3.5])
    rotate([90,0,0])
      M3_nut(h=2);
  translate([5, 12-5, 0.3])
    Mounting_screw();
  translate([50+2*12-5, 12-5, 0.3])
    Mounting_screw();
  translate([17, 6, -1])
    ymdir_rounded_cube2([50+2*12-2*17, 8.1, 3.1], r=2, $fn=10*4);
  translate([17, 12, -1])
    rotate([0,0,180])
      inner_round_corner(r=2, h=5, $fn=4*10);
  translate([50+2*12-17, 12, -1])
    rotate([0,0,-90])
      inner_round_corner(r=2, h=5, $fn=4*10);
}
