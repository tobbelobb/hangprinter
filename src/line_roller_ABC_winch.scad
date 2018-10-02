include <parameters.scad>
use <util.scad>
use <line_roller_single.scad>

line_roller_ABC_winch();
module line_roller_ABC_winch(twod = false){
  if(!twod){
    line_roller_single();
    translate([0,-Spool_height - GT2_gear_height, 0]){
      line_roller_single();
    }
  }
}

