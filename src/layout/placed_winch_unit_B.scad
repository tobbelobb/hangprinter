include <../lib/parameters.scad>
include <lib/layout_lib.scad>
include <lib/layout_params.scad>

placed_winch_unit_B();
module placed_winch_unit_B(){
  translate([bc_x_pos, bcspool_y,0])
    rotate([0,0,90]) {
      sandwich_and_motor_ABCD(B=true);
      mirror([0,1,0])
        line_guides_BC();
  }
}
