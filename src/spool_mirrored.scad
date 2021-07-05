use <spool.scad>

spool_mirrored();
module spool_mirrored(){
  mirror([1,0,0])
    spool();
}
