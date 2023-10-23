include <lib/parameters.scad>
use <lib/gear_util.scad>

use <spool.scad>

//intersection(){
//  iright_spool_top();
//  translate([0,0,-6])
//    cylinder(r=Spool_r/3, h=9);
//}
iright_spool_top();
module iright_spool_top(){
  mirror([1,0,0]) {
    spool_outer(2);
    difference(){
      union(){
        spool_center();
        difference(){
          cylinder(r=Spool_r-1, h=0.4);
          translate([0,0,-1])
            cylinder(r=Spool_r/4+1, h=3, $fn=100);
        }
      }
    }
  }
}
