include <parameters.scad>
use <util.scad>
use <gears.scad>

motor_gear();
module motor_gear(){

  gear_height = Gear_height + 1; //Want extra millimeter to avoid first- and last layer problems.
  foot_height = 7;
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
        cylinder(r=Motor_outer_radius, h=foot_height);
    }

    translate([0,0,-1])
      D_shaft(37);
    for(k=[0,120,240])
      rotate([0,0,k]){
        translate([0,Nema17_shaft_radius+0.5,gear_height])
          nutlock();
      }
    translate([0,0,gear_height+foot_height-1])
      cylinder(r1=2.5, r2=4, h=3);
    translate([0,0,gear_height+foot_height-7])
      cylinder(r=2.5, h=8);
    translate([-0.5,0,gear_height+foot_height-0.3])
      cube([1,Motor_outer_radius+1,1]);
    translate([-0.5,0,-0.7])
      cube([1,Motor_outer_radius+1,1]);

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
