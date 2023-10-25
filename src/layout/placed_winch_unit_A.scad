include <../lib/parameters.scad>
include <lib/layout_params.scad>
include <lib/layout_lib.scad>


placed_winch_unit_A();
module placed_winch_unit_A(){
  translate([ad_x_pos, aspool_y, 0])
    rotate([0,0,-90]) {
      sandwich_and_motor_ABCD(A=true);
      translate([move_AD_deflectors, GT2_gear_height/2 + Spool_height/2,0])
        rotate([0,0,180])
          tilted_line_deflector_for_layout(-90);
      for(k=[0, 1]) mirror([0,k,0]){
        line_from_to([0, -Spool_height, hz],
                     [move_AD_deflectors, -Spool_height, hz], twod=twod);
        *if (!twod && k==0 && guy_wires)
          line_from_to([move_AD_deflectors - 7, -Spool_height, hz],
                       [anchors[A][Y] - 136 - 61, -anchors[A][X] + 134, anchors[I][Z] - anchors[A][Z] - 16], twod=false);
        *if (!twod && k==1 && guy_wires)
          line_from_to([move_AD_deflectors - 7, -Spool_height, hz],
                       [anchors[A][Y] - 136 - 61, -anchors[A][X] - 100 + Sidelength,  anchors[I][Z] - anchors[A][Z] - 16], twod=false);
      }
  }
}

