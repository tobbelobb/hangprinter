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

  gear_height = Gear_height + 1; //Want extra millimeter to avoid first- and last layer problems.
  module half(){
    my_gear(Motor_teeth, gear_height/2+0.1, Circular_pitch, fac=-1, slices = 2*gear_height);
  }

  difference(){
    union(){
      translate([0,0,gear_height/2]){
        half();
        mirror([0,0,1])
          half();
      }
      translate([0,0,gear_height])
        cylinder(r=Motor_outer_radius, h=7);
    }
    for(k=[0,120,240])
      rotate([0,0,k]){
        translate([0,0,-1])
          D_shaft(37);
        translate([0,Nema17_shaft_radius+0.5,gear_height])
          nutlock();
      }

    // Cut bottom to avoid problems with elephant foot
    translate([0,0,-0.3])
    rotate_extrude(angle=360, convexity=5)
      translate([Motor_pitch-1.3,0])
      rotate([0,0,-70])
      square([4,5]);

  }
}
//  translate([0,0,-2-Nema17_cube_height])
//    Nema17();

echo("Motor gear outer radius",  Motor_outer_radius);
echo("Motor gear pitch", Motor_pitch);
