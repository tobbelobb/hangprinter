include <lib/parameters.scad>
use <lib/util.scad>
use <lib/gear_util.scad>

use <spool_cover.scad>

dleft_spool_cover();
module dleft_spool_cover(){
  mirror([1,0,0])
    difference(){
      spool_cover(tot_height=Spool_cover_D_left_tot_height);
      translate([72.5,0,Spool_cover_bottom_th+Spool_cover_shoulder+1+Spool_height+1])
        cube([Spool_cover_outer_r-74,100,Spool_height]);
    }
}
