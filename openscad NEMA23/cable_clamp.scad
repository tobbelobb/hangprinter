include <parameters.scad>
include <lineroller_parameters.scad>
use <util.scad>

bit_width = 12;
screw_head_dia = 16; // Slightly unofficially supporting 14 mm dia wood screw heads
cable_r=2.5;

difference(){
  union(){
    rotate([90,0,0])
      left_rounded_cube2([bit_width+2,bit_width,Base_th], Lineroller_base_r);
    translate([bit_width+cable_r+Base_th,-Base_th/2,0])
      cylinder(r=cable_r+Base_th, h=bit_width, $fs=1);
  }
  translate([0,0,-1])
    cube(bit_width+2*cable_r+2*Base_th);

  // screw...
  translate([bit_width/2, 0, bit_width/2])
    rotate([90,0,0])
    translate([0,0,-1])
    cylinder(d=4, h=Base_th+2, $fs=1);
  translate([bit_width/2, 0, bit_width/2])
    rotate([90,0,0])
    translate([0,0,Base_th])
    cylinder(d2=screw_head_dia-4, d1=screw_head_dia, h=12, $fs=1);
  // cable...
    translate([bit_width+cable_r+Base_th,-Base_th/2,-1])
      cylinder(r=cable_r, h=bit_width+2, $fs=1);
}
