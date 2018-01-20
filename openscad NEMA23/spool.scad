include <parameters.scad>
include <gear_parameters.scad>
use <sweep.scad>
use <util.scad>
use <gear_util.scad>
use <gears.scad>

spool();
module spool(){
  difference(){
    union(){
      // Edge to keep line in place
      cylinder(r = Spool_outer_radius-6, h = 1, $fn=100);
      cylinder(r = Spool_r, h = Spool_height+1, $fn=100);
      translate([0,0,Spool_height+1-0.4]) // Sink 0.4 mm back to make extra space for torx
        torx(h=Torx_depth, female=false);
    }
    for(i=[0:60:359])
      rotate([0,0,i])
        spool_decoration();
    for(v=[0:120:359])
      rotate([0,0,v])
        translate([Spool_r-4, 0, 1+Spool_height/2])
          rotate([0,90,0])
            for(i=[-2,2])
              translate([0,i,0])
                cylinder(r=0.9, h=Spool_r);

    translate([0,0,-1])
      cylinder(d=b608_outer_dia,h=Spool_height+Torx_depth-0.4+1+2);
    translate([0,0,-1])
      cylinder(d1=b608_outer_dia+2.5, d2=b608_outer_dia-0.1,h=2.2);
  }
}
