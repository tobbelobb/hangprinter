use <util.scad>

difference(){
  union(){
    ydir_rounded_cube2([50+2*12, 12, 2], r=2, $fn=10*4);
    translate([0,2,0])
      rotate([90,0,0])
        ydir_rounded_cube2([50+2*12, 9.5, 2], r=2, $fn=10*4);
  }

  translate([3.5+12,0,9.5-3.5])
    rotate([90,0,0])
      cylinder(d=3.2, h=10, center=true, $fn=10);
  translate([50-3.5+12,0,9.5-3.5])
    rotate([90,0,0])
      cylinder(d=3.2, h=10, center=true, $fn=10);
  translate([5, 12-5, 0])
    Mounting_screw_countersink();
  translate([50+2*12-5, 12-5, 0])
    Mounting_screw_countersink();
}
