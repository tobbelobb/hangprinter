include <parameters.scad>
use <util.scad>
use <gear_util.scad>
use <gears.scad>

module GT2_flanged_spool_gear(teeth, ad){
  // Magic number 161.83 is big GT pulley outer diameter. Printed in console.
  cylinder(d1 = 161.83, d2 = 160.83, h = 1, $fn=teeth);
  translate([0, 0, GT2_belt_width + 1])
    cylinder(d2 = 161.83, d1 = 160.83, h = 1, $fn=teeth);
  GT2_2mm_pulley_extrusion(GT2_gear_height, teeth, additional_tooth_depth=ad);
}

GT2_spool_gear(true);
module GT2_spool_gear(print_on_bad_printer=false){
  difference(){
    if(print_on_bad_printer)
      //scale([161.83/161, 161.83/161, 1])
      scale([162.1/161, 162.1/161, 1])
        GT2_flanged_spool_gear(GT2_spool_gear_teeth, 0.21);
    else
      GT2_flanged_spool_gear(GT2_spool_gear_teeth);
    translate([0,0,GT2_gear_height+GT2_gear_height-Torx_depth])
      rotate([180,0,0])
      torx(h = GT2_gear_height, female=true);
    translate([0,0,-(GT2_gear_height+2)/2])
      torx(h = GT2_gear_height+2, female=true);
  }
}
