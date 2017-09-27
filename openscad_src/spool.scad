include <parameters.scad>
include <gear_parameters.scad>
use <sweep.scad>
use <util.scad>
use <gear_util.scad>
use <gears.scad>

//rotate([0,0,30])
//translate([0,0,-12])
//%prev_art();
module prev_art(){
  translate([0,0,5])
  import("../stl/spool_herringbone.stl");
}

spool();
module spool(){
  difference(){
    union(){
      // Edge to keep line in place
      cylinder(r = Spool_outer_radius-15, h = 1, $fn=100);
      cylinder(r = Spool_r, h = Spool_height+1, $fn=100);
      translate([0,0,Spool_height+1-0.4]) // Sink 0.4 mm back to make extra space for torx
        torx(h=Torx_depth, female=false);
    }
    //for(i=[0:60:359])
    for(i=[0:60:50])
      rotate([0,0,i])
        decoration(height=Spool_height+Torx_depth-0.4+1, wallr=Spool_r-2, dd=3, lou=4, inr=7);
    for(v=[0:120:359])
      rotate([0,0,v])
        translate([Spool_r-4, 0, 1+Spool_height/2])
          rotate([0,90,0])
            for(i=[-1,1])
              translate([0,i,0])
                cylinder(r=0.7, h=Spool_r);

    translate([0,0,-1])
      cylinder(r=12,h=Spool_height+Torx_depth-0.4+1+2);
  }
}
