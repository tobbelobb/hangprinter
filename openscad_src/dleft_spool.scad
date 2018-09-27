include <parameters.scad>
use <gear_util.scad>
use <spool.scad>

dleft_spool();
module dleft_spool(){
  spool_outer(2);
  spool_center();
}

