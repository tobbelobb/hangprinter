include <../lib/parameters.scad>
include <lib/layout_params.scad>
include <lib/layout_lib.scad>


placed_winch_unit_A();
module placed_winch_unit_A(){
  translate([lx3,aspool_y,0])
    rotate([0,0,-90]) {
      sandwich_and_motor_ABCD(A=true);
      translate([-120, GT2_gear_height/2 + Spool_height/2,0])
        rotate([0,0,180])
          tilted_line_deflector_for_layout(-90);
      for(k=[0, 1]) mirror([0,k,0]){
        line_from_to([0, -Spool_height, hz],
                     [-120, -Spool_height, hz], twod=twod);
        if (!twod)
          line_from_to([-127, -Spool_height, hz],
                       [-210, -Spool_height-9, 100+hz], twod=twod);
      }
  }
}

