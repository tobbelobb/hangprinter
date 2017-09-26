include <parameters.scad>
include <gear_parameters.scad>
use <util.scad>
use <gears.scad>

//%prev_art();
module prev_art(){
  import("../stl/hgear_6t_setscrew.stl");
}

motor_gear();
module motor_gear(){

  module half(){
    my_gear(Motor_teeth, Gear_height/2+0.1, Circular_pitch);
  }

  difference(){
    union(){
      translate([0,0,Gear_height/2]){
        half();
        mirror([0,0,1])
          half();
      }
      translate([0,0,Gear_height])
        cylinder(r=Motor_outer_radius, h=7);
    }
    translate([0,0,-1])
      D_shaft(37);
    translate([0,Nema17_shaft_radius+0.5,Gear_height])
      nutlock();

    // Cut bottom to avoid problems with elephant foot
    translate([0,0,-0.3])
    rotate_extrude(angle=360, convexity=5)
      translate([6,0])
      rotate([0,0,-70])
      square([4,5]);

  }
}
//  translate([0,0,-2-Nema17_cube_height])
//    Nema17();
