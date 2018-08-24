include <parameters.scad>
use <util.scad>
use <gear_util.scad>
use <gears.scad>

spool_spacer();
module spool_spacer(){
  difference(){
    cylinder(r = Spool_outer_radius-7, h = Sep_disc_th, $fn=100);
    translate([0,0,-1])
      cylinder(r= Spool_r, h = 3, $fn=100);
  }
  for(v=[0:60:359]) // to fit the grooves of the spool
    rotate([0,0,v])
      translate([0, Spool_r, 0])
      cylinder(r=1.5, h=1, $fn=20);
}
