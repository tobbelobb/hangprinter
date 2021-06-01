include <lib/parameters.scad>
use <lib/util.scad>

difference(){
  union(){
    rotate([90,0,0])
      left_rounded_cube2([Bit_width+2,Bit_width,Base_th], 3, $fn=2*12);
    translate([Bit_width+Cable_r+Base_th,-Base_th/2,0])
      cylinder(r=Cable_r+Base_th, h=Bit_width, $fs=1);
  }
  translate([0,0,-1])
    cube(Bit_width+2*Cable_r+2*Base_th);

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
    translate([Bit_width+Cable_r+Base_th,-Base_th/2,-1])
      cylinder(r=Cable_r, h=Bit_width+2, $fs=1);
}
