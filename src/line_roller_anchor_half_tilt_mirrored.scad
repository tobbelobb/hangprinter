use <line_roller_anchor_half_tilt.scad>

newer_line_roller_anchor_half_tilt_mirrored();
module newer_line_roller_anchor_half_tilt_mirrored(){
  mirror([1,0,0]){
    newer_line_roller_anchor_half_tilt();
  }
}
