include <lib/parameters.scad>
use <lib/util.scad>

Cable_r = 5.7/2;
clamp_length = Cable_r*3+Base_th;
extra_cable_depth = 0;
difference(){
  union(){
    rotate([90,0,0])
      left_rounded_cube2([Bit_width+2,Bit_width,Base_th], 3, $fn=2*12);
    translate([Bit_width+Cable_r+Base_th,-Base_th/2,0]){
      translate([-(Cable_r*3+Base_th)/2, -(Cable_r*3+Base_th*2)/2-extra_cable_depth, 0])
        rounded_cube2([clamp_length, Cable_r*3+Base_th*2, Bit_width], r=Cable_r+Base_th);
    }
  }
  translate([0,0,-1])
    cube(Bit_width+clamp_length);

  // screw...
  translate([Bit_width/2, 0, Bit_width/2])
    rotate([90,0,0])
    translate([0,0,-1])
    cylinder(d=Mounting_screw_d, h=Base_th+2, $fs=1);
  translate([Bit_width/2, 0, Bit_width/2])
    rotate([90,0,0])
    translate([0,0,Base_th])
    cylinder(d2=Mounting_screw_head_d-4, d1=Mounting_screw_head_d, h=12, $fs=1);
  // cable...
    translate([Bit_width+clamp_length/2,-Base_th*0.5-extra_cable_depth,-1])
      translate([-(clamp_length-2*Base_th)/2, -(Cable_r*3)/2, 0])
        rounded_cube2([clamp_length-2*Base_th, Cable_r*3+extra_cable_depth, Bit_width+2], r=Cable_r);
}
