include <lib/parameters.scad>
use <lib/util.scad>

pen_holder_nut_head();
module pen_holder_nut_head(){
  difference(){
    cylinder(d=10, h=8, $fn=12*4, center=true);
    for(k=[0,1]) mirror([0,0,k])
    translate([0,0,-1.5-4])
      rotate_extrude($fn=12*4)
        translate([6, 0])
          rotate([0,0,45])
            square(2);
    cylinder(d=3.3, h=9, center=true);
    translate([0,0,-4.1])
      M3_nut(h=3);
    translate([0,0,1])
      cylinder(d1=1, d2=10, h=5, $fn=12*4);
  }
}
