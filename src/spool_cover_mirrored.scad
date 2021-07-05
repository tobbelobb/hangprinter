include <lib/parameters.scad>

use <spool_cover.scad>

spool_cover_mirrored();
module spool_cover_mirrored(tot_height=Spool_cover_tot_height, bottom_th=Spool_cover_bottom_th){
  mirror([1, 0, 0])
    spool_cover(tot_height, bottom_th);
}
