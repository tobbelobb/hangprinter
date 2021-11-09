include <lib/parameters.scad>
use <lib/util.scad>

translate([-50,0,0])
%import("../stl/extruder_holder.stl");

bltouch();
module bltouch(){
  cylinder(d=2, h=11);
  // The pin when fully stretched is 10.4 mm long
  translate([0,0,10.4])
    difference(){
      union(){
        translate([-12.61/2, 0, 0])
          cube([12.61, 12.61/2, 26.2]);
        cylinder(d=12.61, h=26.2);
        cylinder(d=10.7, h=26.2+8);
        translate([0,0,26.2+8]){
          for(k=[0,1]) mirror([k,0,0])
            linear_extrude(height=2)
              difference(){
                hull(){
                  translate([7.2/2, -10.6/2])
                    square([0.1, 10.6]);
                  translate([18/2, 0])
                    circle(r=3.65);
                }
                translate([18/2, 0])
                  circle(d=3.2);
              }
          translate([-7.2/2, -10.6/2])
            cube([7.2, 10.6, 2]);
        }
      }
      rotate_extrude()
        translate([9/2*sqrt(2)+7.5/2,-(9*sqrt(2))/2])
        rotate([0,0,45])
        square(9);
    }
}


bltouch_arm();
module bltouch_arm(){
  ydir_rounded_cube2([6, 145-43, 4], 3, $fn=6*4);
}
