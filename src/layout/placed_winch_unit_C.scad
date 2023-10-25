include <../lib/parameters.scad>
include <lib/layout_lib.scad>
include <lib/layout_params.scad>

placed_winch_unit_C();
module placed_winch_unit_C(){
  translate([-bc_x_pos, bcspool_y,0])
    rotate([0,0,90]) {
      sandwich_and_motor_ABCD(C=true);
      line_guides_BC();
      for(k=[0, 1]) translate([0,k*2*Spool_height, 0]){
        line_from_to([0, -Spool_height, hz],
                     [move_BC_deflectors+6, -Spool_height, hz], twod=twod);
        if (!twod && k==0)
          line_from_to([move_BC_deflectors - 2, -Spool_height, hz],
                       [-anchors[C][X] + 93, anchors[C][Y] + 43, anchors[I][Z] - anchors[C][Z] - 9], twod=false);
        if (!twod && k==1)
          line_from_to([move_BC_deflectors - 2, -Spool_height, hz],
                       [-anchors[C][X] + 93 - Sidelength, anchors[C][Y] + 28,  anchors[I][Z] - anchors[C][Z] - 9], twod=false);
      }
  }
}
