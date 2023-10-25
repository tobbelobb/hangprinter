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
      for(k=[0, 1]) translate([0,k*2*Spool_height, 0]){
        line_from_to([0, -Spool_height, hz],
                     [move_BC_deflectors+6, -Spool_height, hz], twod=twod);
        if (!twod && k==0 && guy_wires)
          line_from_to([move_BC_deflectors - 2, -Spool_height, hz],
                       [anchors[B][Y] + 3, -anchors[B][X]+47-61, anchors[I][Z] - anchors[B][Z] - 16], twod=false);
        if (!twod && k==1 && guy_wires)
          line_from_to([move_BC_deflectors - 2, -Spool_height, hz],
                       [anchors[B][Y]+5-Sidelength, -anchors[B][X]+31-61,  anchors[I][Z] - anchors[B][Z] - 16], twod=false);
      }
  }
}
