include <../lib/parameters.scad>
include <lib/layout_lib.scad>
include <lib/layout_params.scad>

placed_winch_unit_D();
module placed_winch_unit_D(){
  translate([-ad_x_pos, dspool_y, 0])
    rotate([0,0,90]) {
      sandwich_and_motor_ABCD(D=true);
      translate([move_AD_deflectors, GT2_gear_height/2 + Spool_height/2,0])
        rotate([0,0,180])
          tilted_line_deflector_for_layout(-90);
      for(k=[0, 1]) mirror([0,k,0]){
        line_from_to([0, -Spool_height, hz],
                     [move_AD_deflectors, -Spool_height, hz], twod=twod);
        if (!twod)
          line_from_to([move_AD_deflectors - 7, -Spool_height, hz],
                       [-210, -Spool_height-9, 100+hz], twod=twod);
      }
  }
}
