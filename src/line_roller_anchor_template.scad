include <lib/parameters.scad>
use <lib/util.scad>
use <line_roller_anchor.scad>

difference(){
  newer_line_roller_anchor();
  translate([-50,-50,1+Screw_h+Screw_head_h-0.2])
    cube(100);
  translate([-115,-50,-1])
    cube(100);
}
