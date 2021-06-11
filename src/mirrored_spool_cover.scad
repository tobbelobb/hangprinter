include <lib/parameters.scad>

use <spool_cover.scad>

mirrored_spool_cover();
module mirrored_spool_cover(tot_height=Spool_cover_tot_height, bottom_th=Spool_cover_bottom_th){
  mirror([1, 0, 0])
    spool_cover(tot_height, bottom_th);
}
