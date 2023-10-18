include <../lib/parameters.scad>
include <lib/layout_lib.scad>
include <lib/layout_params.scad>

placed_winch_unit_C();
module placed_winch_unit_C(){
  translate([-bc_x_pos, bcspool_y,0])
    rotate([0,0,90]) {
      sandwich_and_motor_ABCD(C=true);
      line_guides_BC();
  }
}
