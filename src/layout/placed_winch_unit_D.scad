include <../lib/parameters.scad>
include <lib/layout_lib.scad>
include <lib/layout_params.scad>

placed_winch_unit_D();
module placed_winch_unit_D(){
  translate([-lx3+0, dspool_y,0])
    rotate([0,0,90]) {
      sandwich_and_motor_ABCD(D=true);
      translate([move_BC_deflectors+spd/sqrt(3)+1, GT2_gear_height/2 + Spool_height/2,0])
        rotate([0,0,180])
          tilted_line_deflector_for_layout(-90);
  }
}
