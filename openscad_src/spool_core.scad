include <parameters.scad>
include <gear_parameters.scad>
include <lineroller_parameters.scad>
use <sweep.scad>
use <util.scad>
use <gear_util.scad>
use <gears.scad>
use <lineroller_ABC_winch.scad>

spool_core();
module spool_core(twod = false){
  base(center=true, flerp0=Spool_core_flerp0, twod = twod);
  if(!twod){
    cylinder(d=8, h=Gap_between_sandwich_and_plate + Spool_height + Gear_height + 5, $fn=4*5);
    cylinder(d=12, h=Gap_between_sandwich_and_plate, $fn=4*5);

    rotate([0,0,45])
    translate([30,0,0])
    // A little ring to lock the top
    difference(){
      cylinder(d=8+4, h=2);
      translate([0,0,-1])
        cylinder(d=8, h=2+2);
    }
  }
}
