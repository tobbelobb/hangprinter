include <lib/parameters.scad>
use <lib/util.scad>


pen_holder_stationary_part();
module pen_holder_stationary_part(){
  w = Pen_holder_w;
  rail_w = Pen_holder_rail_w;
  bottom_th = Pen_holder_bottom_th;
  full_th = bottom_th+13.16;
  leg_th = 7;
  difference(){
    translate([-w/2,-w/2,0])
      rounded_cube2([w,2*w,full_th], r=3, $fn=6*4);
    translate([-(w+2)/2, (w+2)/2-0.01, bottom_th])
      cube([w+2, w+2, full_th]);
    translate([-(w/3)/2, -(w+2)/2, bottom_th])
      cube([w/3, w+2, full_th]);
    translate([-(w+2)/2, -(w-2*leg_th)/2, bottom_th])
      cube([w+2, w-2*leg_th, full_th]);
    translate([0,w,-1])
      Nema17_screw_holes(3.5, bottom_th+2, $fs=1);
    translate([0,w,2.5])
      Nema17_screw_translate()
        M3_nut(10);
    for(k=[0,1]) mirror([k,0,0])
      translate([-rail_w/2, 0, full_th-2.65])
        rotate([90,0,0])
          cylinder(d=7.93, h=w+2, center=true, $fn=2*24);
  }
  translate([-7/2, -w/2, 0])
    difference(){
      cube([7, 5, bottom_th+6]);
      translate([0,-3,bottom_th-3])
        rotate([45,0,0])
          translate([-0.5,0,0])
            cube([8,8,6]);
    }
  for(k=[0,(w-6)/2, w-6]) translate([k,0,0])
      translate([-w/2, -w/2-4, 0])
        difference(){
          cube([6,11,bottom_th]);
          translate([3, 4, bottom_th/2])
            rotate([90,0,0])
              ring(d1=10, d2=bottom_th+0.5, h=2, $fn=24);
        }
}
