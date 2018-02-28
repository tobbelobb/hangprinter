include <parameters.scad>
include <gear_parameters.scad>
use <sweep.scad>
use <util.scad>
use <gear_util.scad>
use <gears.scad>

//spool_outer();
module spool_outer(){
  difference(){
    union(){
      // Edge to keep line in place
      cylinder(r = Spool_outer_radius-7, h = 1, $fn=100);
      cylinder(r = Spool_r, h = Spool_height+1, $fn=150);
      translate([0,0,Spool_height+1-0.4]) // Sink 0.4 mm back to make extra space for torx
        torx(h=Torx_depth, female=false);
    }
    translate([0,0,-1])
      cylinder(r=Spool_r-Spool_outer_wall_th, h=Spool_height+Torx_depth+2,$fn=150);
  }
}

spool(30); // Rotate just to match previous version
module spool(rot){
  rotate([0,0,rot]){
    spool_outer();
    spool_center();
  }
}
