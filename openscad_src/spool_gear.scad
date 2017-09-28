include <parameters.scad>
include <gear_parameters.scad>
use <sweep.scad>
use <util.scad>
use <gear_util.scad>
use <gears.scad>

//translate([0,0,13.5])
//%prev_art();
module prev_art(){
  translate([0,0,5])
  import("../stl/spool_herringbone.stl");
}

spool_gear();
module spool_gear(){
  module half(){
    my_gear(Spool_teeth, Gear_height/2+0.1, Circular_pitch);
  }
  difference(){
    union(){
      translate([0,0,Gear_height/2]){
        half();
        mirror([0,0,1])
          half();
      }
    }
    for(i=[0:60:359])
      rotate([0,0,i])
        decoration(Gear_height);
    for(i=[0:60:359])
      rotate([0,0,i])
        decoration(height=Spool_height+1+Gear_height, wallr=Spool_r-2, dd=3, lou=4, inr=7);
    translate([0,0,Gear_height+Spool_height+2-Torx_depth])
      rotate([180,0,0])
      torx(h = Spool_height+2, female=true);
    // Space for 608 bearing
    translate([0,0,-1])
      cylinder(r=12,h=Gear_height+2);
    // Cut bottom to avoid problems with elephant foot
    translate([0,0,-0.3])
    rotate_extrude(angle=360, convexity=5)
      translate([Spool_pitch-1.3,0])
        rotate([0,0,-70])
          square([4,5]);
  }

}

echo("Spool gear outer radius",  Spool_outer_radius);
echo("Spool gear pitch", Spool_pitch);
