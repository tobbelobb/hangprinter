include <parameters.scad>
use <util.scad>
use <gear_util.scad>
use <gears.scad>
use <lineroller_ABC_winch.scad>

module GT2_flanged_spool_gear(teeth){
  // Magic number 161.83 is big GT pulley outer diameter. Printed in console.
  cylinder(d1 = 161.83, d2 = 160.83, h = 1, $fn=teeth);
  translate([0, 0, GT2_belt_width + 1])
    cylinder(d2 = 161.83, d1 = 160.83, h = 1, $fn=teeth);
  GT2_2mm_pulley_extrusion(GT2_gear_height, teeth);
}

spool_gear();
module spool_gear(){
  difference(){
    GT2_flanged_spool_gear(GT2_spool_gear_teeth);
    translate([0,0,GT2_gear_height+GT2_gear_height-Torx_depth])
      rotate([180,0,0])
      torx(h = GT2_gear_height, female=true);
    translate([0,0,-(GT2_gear_height+2)/2])
      torx(h = GT2_gear_height+2, female=true);
  }
}
