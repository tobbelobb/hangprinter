include <parameters.scad>
use <util.scad>
use <gear_util.scad>
use <gears.scad>

//spool_outer();
module spool_spacer(){
          difference(){
                    cylinder(r = Spool_outer_radius-7, h = 1, $fn=100);
                    cylinder(r= Spool_r, h = 1, $fn=100);
                    for(v=[0:180:359]) // to fit the grooves of the spool
                          rotate([0,0,v+6])
                            translate([0, Spool_r+2, 0])
                                    cylinder(r=1, h=1);
                      }
    for(v=[0:60:359]) // to fit the grooves of the spool
          rotate([0,0,v])
            translate([0, Spool_r, 0])
                    cylinder(r=1.5, h=1, $fn=100);
}


spool_spacer();

