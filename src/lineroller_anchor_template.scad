include <parameters.scad>
use <util.scad>
use <lineroller_ABC_winch.scad>
use <lineroller_anchor.scad>



difference(){
  union(){
    translate([0,-Depth_of_lineroller_base-5,0])
      mirror([0,1,0])
        lineroller_anchor();
    lineroller_anchor();
  }
  translate([-50,-50,1+Screw_h+Screw_head_h-0.2])
  cube(100);
}
