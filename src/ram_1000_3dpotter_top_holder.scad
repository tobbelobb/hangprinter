include <lib/parameters.scad>
use <lib/util.scad>
use <ram_1000_3dpotter.scad>

ram_1000_3dpotter_top_holder();
module ram_1000_3dpotter_top_holder(){
  difference(){
    w = Ram_1000_3dpotter_top_square_width;
    union(){
      rotate([0,0,45])
        translate([-(w+2*5)/2,-(w+2*5)/2,0])
          cube([w+2*5,w+2*5,10]);
      for(k=[0,1]) mirror([k,0,0])
        translate([4/2+0.2,-1.8*Ram_1000_3dpotter_top_square_width/2-9,10])
          rotate([-atan(4/(1.8*Ram_1000_3dpotter_top_square_width)),90,0])
            difference(){
              rounded_cube2([10,18,4],2, $fn=7*4);
              translate([10/2,5,-1]){
                M3_screw();
                translate([0,0,3.5])
                  nut(h=3);
              }
            }

      for(ang=[0,240]) rotate([0,0,ang+60])
        translate([0,-Ram_1000_3dpotter_tube_outer_d/4.1-13,10])
          rotate([0,90,0])
            translate([0,0,-3/2])
              difference(){
                rounded_cube2([10,13,3],2, $fn=7*4);
                translate([10/2,5,-1])
                  cylinder(d=3.6, h=20);
              }
      rotate([0,0,120+60])
        translate([0,-Ram_1000_3dpotter_tube_outer_d/3-13,10])
          rotate([0,90,0])
            translate([0,0,-3/2])
              difference(){
                rounded_cube2([10,13,3],2, $fn=7*4);
                translate([10/2,5,-1])
                  cylinder(d=3.6, h=20);
              }
    }
    rotate([0,0,45])
      translate([-w/2,-w/2,-1])
        cube([w,w,12]);
    translate([-4/2, -Ram_1000_3dpotter_tube_outer_d,-1])
      cube([4, Ram_1000_3dpotter_tube_outer_d, 12]);
  }
}
