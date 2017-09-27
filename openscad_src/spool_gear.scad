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
    //translate([0,0,0])
    //  #cylinder(r=28,0, h=Gear_height+8,$fn=100);
    translate([0,0,Gear_height+Spool_height+2-Torx_depth])
      rotate([180,0,0])
      torx(h = Spool_height+2, female=true);
    // Space for 608 bearing
    translate([0,0,-1])
      cylinder(r=12,h=Gear_height+2);
  }

}

echo("Spool gear outer radius",  Spool_outer_radius);
echo("Spool gear pitch", Spool_pitch);
