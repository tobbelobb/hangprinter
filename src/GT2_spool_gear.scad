include <lib/parameters.scad>
use <lib/util.scad>
use <lib/gear_util.scad>

module GT2_flanged_spool_gear(teeth, additional_tooth_depth=0){
  GT2_2mm_pulley_extrusion(GT2_gear_height, teeth, additional_tooth_depth=additional_tooth_depth);
}

GT2_spool_gear(false);
module GT2_spool_gear(perfect_world=true){
  difference(){
    union(){
      // Magic number 161.83 is big GT pulley outer diameter. Printed in console.
      cylinder(d1 = Sep_disc_radius*2, d2 = 161.83, h = 1, $fn=GT2_spool_gear_teeth);
      translate([0, 0, GT2_belt_width + 1])
        cylinder(d2 = Sep_disc_radius*2, d1 = 161.83, h = 1, $fn=GT2_spool_gear_teeth);
      if(perfect_world) {
        // In a perfect world, belt and 3d-printer both meet tolerances with nanometer precision
        // ... and we don't have to adjust size or tooth depth at all
        GT2_flanged_spool_gear(GT2_spool_gear_teeth);
      } else {
        // Fits with new belts. "GT2_spool_gear_deeper_teeth_and_smaller_radius.stl"
        scale([160.6/161, 160.6/161, 1])
          GT2_flanged_spool_gear(GT2_spool_gear_teeth, additional_tooth_depth=0.25);
        // Fits with old belts. "GT2_spool_gear_smaller_but_deeper_than_half_deep.stl"
        //scale([161.45/161, 161.45/161, 1])
        //  GT2_flanged_spool_gear(GT2_spool_gear_teeth, additional_tooth_depth=0.12);
      }
    }
    extra_space = 0.05;
    scale([(Spool_r+extra_space)/Spool_r, (Spool_r+extra_space)/Spool_r, 1])
      translate([0,0,GT2_gear_height+GT2_gear_height-Torx_depth])
        rotate([180,0,0])
          torx(h = GT2_gear_height, female=true);
    scale([(Spool_r+extra_space)/Spool_r, (Spool_r+extra_space)/Spool_r, 1])
      translate([0,0,-(GT2_gear_height+2)/2])
        torx(h = GT2_gear_height+2, female=true);
    difference(){
      for(k=[0,1])
        translate([0,0,k*GT2_gear_height])
          mirror([0,0,k])
            translate([0,0,GT2_gear_height+6])
              rotate_extrude($fn=150) {
                translate([Spool_r,0])
                  rotate([0,0,45])
                    square(10, center=true);
              }
      for(ang=[0:30:359]) {
        rotate([0,0,15+ang])
          translate([-3/2, 0, -1])
            cube([3, Spool_r+10, GT2_gear_height*3]);
      }
    }
  }
}
