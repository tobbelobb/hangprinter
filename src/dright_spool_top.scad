include <lib/parameters.scad>
use <lib/gear_util.scad>

use <spool.scad>
use <dright_spool_bottom.scad>

//intersection(){
//  dright_spool_top();
//  translate([0,0,-6])
//    cylinder(r=Spool_r/3, h=9);
//}
dright_spool_top();
module dright_spool_top(){
  spool_outer(1);
  difference(){
    union(){
      spool_center();
      difference(){
        cylinder(r=Spool_r-1, h=0.4);
        translate([0,0,-1])
          cylinder(r=Spool_r/4+1, h=3);
      }
    }
  }
}
