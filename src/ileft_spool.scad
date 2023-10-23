include <lib/parameters.scad>
use <lib/gear_util.scad>

use <spool.scad>

ileft_spool();
module ileft_spool(){
  spool_outer(2);
  spool_center();
}

