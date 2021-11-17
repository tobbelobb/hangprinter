include <lib/parameters.scad>
use <lib/util.scad>

//translate([-2.79-6,-4,2.5+145-42.65])
//  rotate([90,0,90])
//    %import("../stl/extruder_holder.stl");

//translate([0,0,-10.4-26.2-8-2])
//bltouch();
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
                    circle(r=3.65, $fn=6*4);
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


rotate([90,0,0])
bltouch_arm(len = 98.5, rotit = false);
module bltouch_arm(len = 98.5, rotit = false){
  difference(){
    translate([-8/2, 3.65, 0])
      rotate([90,0,0])
        ydir_rounded_cube2([8, len, 2*3.65], 3, $fn=6*4);
    for(k=[-1,1])
      translate([0,0,len+1.85-Nema17_cube_width/2+k*(Nema17_screw_hole_width/sqrt(2))/2])
        if (rotit)
          rotate([0,90,0]){
            cylinder(d=3.4, h=8, center=true, $fn=11);
            translate([0,0,-6.5])
              nut(5);
          }
        else
          rotate([90,0,0]){
            cylinder(d=3.4, h=8, center=true, $fn=11);
            translate([0,0,-6.5])
              nut(5);
          }
  }
  difference(){
    translate([-(19+2*3.65)/2, -3.65, 0])
      rounded_cube2([19+2*3.65, 2*3.65, 4], r=3.65, $fn=6*4);
    for(k=[0,1]) mirror([k,0,0])
      translate([18/2, 0, -1]){
        cylinder(d=3.3, h=6);
        translate([0,0,2.5])
          nut(5);
      }
  }
  for(k=[0,1]) mirror([k,0,0])
    translate([4,0,4])
      rotate([90,0,0])
        translate([0,0,-3.65])
          inner_round_corner(r=1.5, h=2*3.65, $fn=6*4);
}

// For use with flying pen braces
//rotate([90,0,0])
//bltouch_arm(len = 98.5 - 49, rotit = true);
