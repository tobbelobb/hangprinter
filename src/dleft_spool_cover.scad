include <lib/parameters.scad>
use <lib/util.scad>
use <lib/gear_util.scad>

use <spool_cover.scad>

dleft_spool_cover();
module dleft_spool_cover(){
  spool_cover(height=1+Spool_height+1+Spool_height+1);
}
