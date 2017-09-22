include <parameters.scad>
use <util.scad>

!prev_art();
module prev_art(){
  translate([0,15+2*2.5,0])
    rotate([180,0,0])
    import("../stl/beam_clamp.stl");
}



