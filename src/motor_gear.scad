include <parameters.scad>
use <util.scad>
use <gear_util.scad>
use <gears.scad>
use <lineroller_ABC_winch.scad>

module GT2_flanged_motor_gear(teeth){
  difference(){
    union(){
      cylinder(d = GT2_motor_gear_outer_dia, h = 7.4);
      translate([0,0,GT2_motor_gear_height - 1.5])
        cylinder(r1 = GT2_motor_gear_outer_dia/2 - 1.5,
            r2 = GT2_motor_gear_outer_dia/2,
            h = 1.5);
      GT2_2mm_pulley_extrusion(GT2_motor_gear_height, teeth);
    }
    translate([0,0,-1])
      cylinder(d = Donkey_shaft_d + 0.2, h = GT2_motor_gear_height + 2, $fn=20);
    translate([0,0,-1])
      cylinder(r1 = (Donkey_shaft_d + 0.2)/2 + 2,
               r2 = (Donkey_shaft_d + 0.2)/2 - 1,
               h = 3, $fn=20);
    translate([0,0,GT2_motor_gear_height-2])
      cylinder(r1 = (Donkey_shaft_d + 0.2)/2 - 1,
               r2 = (Donkey_shaft_d + 0.2)/2 + 2,
               h = 3, $fn=20);
    for(zrot=[0,90])
      translate([0,0,7.4/2])
        rotate([90,0,zrot])
        cylinder(d=4, h=GT2_motor_gear_outer_dia/2 + 1);
  }
}

motor_gear();
module motor_gear(){
  GT2_flanged_motor_gear(GT2_motor_gear_teeth);
}
