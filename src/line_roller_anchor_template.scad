include <parameters.scad>
use <util.scad>
use <line_roller_anchor.scad>

rotate([-90,0,0])
difference(){
  //line_roller_anchor();
  new_line_roller_anchor();
  translate([-50,-50,1+Screw_h+Screw_head_h-0.2])
    cube(100);
}
