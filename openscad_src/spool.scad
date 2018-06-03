include <parameters.scad>
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
      for(n=[1:1:num_sep_holes])
        for(v=[0:60:359]){
          rotate([0,0,v])
            translate([0, Spool_r/2, (Spool_height/(num_sep_holes+0.5))*n])
              rotate([-90,00,0])
              //  for(i=[-2.2,2.2])
               //   translate([i,0,0])
                    //cylinder(r=1.5, h=Spool_r, $fn=100);
                    cube([4,1.1,Spool_r], $fn=100);
        // grooves for separation discs
          rotate([0,0,v+1])
            translate([0, Spool_r, 1])
              rotate([0,00,0]) 
                    cylinder(r=1.5, h=Spool_r-1, $fn=100);
                           }
               }
    }

spool(30); // Rotate just to match previous version
module spool(rot){
  rotate([0,0,rot]){
    spool_outer();
    spool_center();
  }
}
