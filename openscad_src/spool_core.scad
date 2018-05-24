include <parameters.scad>
use <util.scad>
use <gear_util.scad>
use <gears.scad>
use <lineroller_ABC_winch.scad>

spool_core();
module spool_core(twod = false, letter="A"){
  big_h = Gap_between_sandwich_and_plate + Spool_height + Gear_height - 0.1;
  difference(){
    union(){
      if(!twod){
        base(center=true, flerp0=Spool_core_flerp0, twod = twod);
        cylinder(d=8.12, h=big_h, $fn=4*5);
        cylinder(d=12, h=Gap_between_sandwich_and_plate, $fn=4*5);
      } else {
        circle(r=Spool_outer_radius);
      }
    }
    if(twod){
      difference(){
        base(center=true, flerp0=Spool_core_flerp0, twod = twod);
        circle(r=2.4);
      }
      translate([Spool_outer_radius/2,0])
        text(letter);
    }
    else{
      translate([0,0,-1])
        cylinder(r=2.4, h=big_h+2);
    }
  }
}
