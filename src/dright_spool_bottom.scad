include <lib/parameters.scad>
use <lib/gear_util.scad>

use <spool.scad>


//intersection(){
//  dright_spool_bottom();
//  translate([0,0,6])
//    cylinder(r=Spool_r/2, h=10);
//}
dright_spool_bottom();
module dright_spool_bottom(){
  difference(){
    spool_outer_small();
    translate([0,0,Spool_height+1])
      scale([1.005,1.005,1])
        spool_center();
    translate([0,0,-1])
      cylinder(d=b608_outer_dia, h=20);
    translate([0,0,Spool_height+1])
      cylinder(d=b608_outer_dia+1, h=20);
  }
}
