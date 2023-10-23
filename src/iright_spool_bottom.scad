include <lib/parameters.scad>
use <lib/gear_util.scad>

use <spool.scad>

//spool_outer_small();
module spool_outer_small(){
  small_r = Spool_r/4;
  difference(){
    union(){
      // Edge to keep line in place
      cylinder(r = Sep_disc_radius, h = 1, $fn=100);
      cylinder(r = small_r, h = Spool_height+1+Torx_depth-0.1, $fn=150);
    }
    for(v=[0:120:359])
      rotate([0,0,v + 30])
        translate([0, small_r/2, 1+Spool_height/2])
          rotate([-90,00,0]){
            for(i=[-2.2,2.2])
              translate([i,0,0])
                cylinder(r=1.2, h=Spool_r);
            translate([-7/2,-3/2,0])
              cube([7,3,5]);
          }
    translate([0,0,-1]){
      cylinder(d1=b608_outer_dia+1.5, d2=b608_outer_dia-0.1,h=1.5);
      cylinder(d=b608_outer_dia,h=b608_width+1.5);
      cylinder(d=b608_outer_dia-1.5,h=b608_width+2*GT2_belt_width);
    }
  }
}


//intersection(){
//  iright_spool_bottom();
//  translate([0,0,6])
//    cylinder(r=Spool_r/2, h=10);
//}
iright_spool_bottom();
module iright_spool_bottom(){
  difference(){
    spool_outer_small();
    translate([0,0,Spool_height+1])
      scale([1.005,1.005,1])
        spool_center();
    translate([0,0,Spool_height+1])
      cylinder(d=b608_outer_dia+1, h=20);
  }
}
