include <BOSL2/std.scad>
include <BOSL2/screws.scad>
$fn = 100;


//rotate([0,90,0])
difference() {
  cylinder(d=150, h=100);
  //screw("M100,250", head="none");
  trapezoidal_threaded_rod(
      d = 100,             // outer diameter
      l = 250,             // axial length of threaded part
      pitch = 2,           // distance between turns
      thread_depth = 1.5,  // radial tooth height/depth
      thread_angle = 30,
      $fn = 128
  );
  down(1)
  for(ang=[0,120,240]) {
    rotate([0,0,ang])
      fwd(10)
      cube([130/2, 20, 110]);
  }

}
