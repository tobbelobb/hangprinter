include <lib/parameters.scad>
use <lib/util.scad>
use <lib/gear_util.scad>

module GT2_flanged_spool_gear(teeth, additional_tooth_depth=0){
  // Magic number 161.83 is big GT pulley outer diameter. Printed in console.
  cylinder(d1 = 161.83+1, d2 = 161.83, h = 1, $fn=teeth);
  translate([0, 0, GT2_belt_width + 1])
    cylinder(d2 = 161.83+1, d1 = 161.83, h = 1, $fn=teeth);
  GT2_2mm_pulley_extrusion(GT2_gear_height, teeth, additional_tooth_depth=additional_tooth_depth);
}

GT2_spool_gear(false);
module GT2_spool_gear(perfect_world=true){
  difference(){
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
    extra_space = 0.05;
    scale([(Spool_r+extra_space)/Spool_r, (Spool_r+extra_space)/Spool_r, 1])
      translate([0,0,GT2_gear_height+GT2_gear_height-Torx_depth])
      rotate([180,0,0])
      torx(h = GT2_gear_height, female=true);
    scale([(Spool_r+extra_space)/Spool_r, (Spool_r+extra_space)/Spool_r, 1])
      translate([0,0,-(GT2_gear_height+2)/2])
      torx(h = GT2_gear_height+2, female=true);
  }
}
