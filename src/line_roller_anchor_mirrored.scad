use <line_roller_anchor.scad>


newer_line_roller_anchor_mirrored();
module newer_line_roller_anchor_mirrored(){
  mirror([1,0,0])
    newer_line_roller_anchor();
}
