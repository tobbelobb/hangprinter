include <lib/parameters.scad>
use <lib/util.scad>
use <clay_extruder.scad>

clay_extruder_holder();
module clay_extruder_holder(){
  difference(){
    union(){
      cylinder(d = Clay_extruder_tube_outer_d + 2*5, h=10, $fn=15*4);
      for(k=[0,1]) mirror([k,0,0])
        translate([4/2+0.2,-Clay_extruder_tube_outer_d/2-16,10])
          rotate([-atan(4/Clay_extruder_tube_outer_d),90,0])
            difference(){
              rounded_cube2([10,18,3],2, $fn=7*4);
              translate([10/2,5,-1]){
                M3_screw();
                translate([0,0,3])
                  nut(h=3);
              }
            }

      for(ang=[0,120,240]) rotate([0,0,ang+60])
        translate([0,-Clay_extruder_tube_outer_d/2-13,10])
          rotate([0,90,0])
            translate([0,0,-3/2])
              difference(){
                rounded_cube2([10,13,3],2, $fn=7*4);
                translate([10/2,5,-1])
                  cylinder(d=3.6, h=20);
              }
    }
    translate([0,0,-1])
      cylinder(d = Clay_extruder_tube_outer_d, h=12, $fn=15*4);
    translate([-4/2, -Clay_extruder_tube_outer_d,-1])
      cube([4, Clay_extruder_tube_outer_d, 12]);
  }
}

!clay_extruder_top_holder();
module clay_extruder_top_holder(){
  difference(){
    w = Clay_extruder_top_square_width;
    union(){
      rotate([0,0,45])
        translate([-(w+2*5)/2,-(w+2*5)/2,0])
          cube([w+2*5,w+2*5,10]);
      for(k=[0,1]) mirror([k,0,0])
        translate([4/2+0.2,-1.8*Clay_extruder_top_square_width/2-9,10])
          rotate([-atan(4/(1.8*Clay_extruder_top_square_width)),90,0])
            difference(){
              rounded_cube2([10,18,4],2, $fn=7*4);
              translate([10/2,5,-1]){
                M3_screw();
                translate([0,0,3.5])
                  nut(h=3);
              }
            }

      for(ang=[0,240]) rotate([0,0,ang+60])
        translate([0,-Clay_extruder_tube_outer_d/4.1-13,10])
          rotate([0,90,0])
            translate([0,0,-3/2])
              difference(){
                rounded_cube2([10,13,3],2, $fn=7*4);
                translate([10/2,5,-1])
                  cylinder(d=3.6, h=20);
              }
      rotate([0,0,120+60])
        translate([0,-Clay_extruder_tube_outer_d/3-13,10])
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
    translate([-4/2, -Clay_extruder_tube_outer_d,-1])
      cube([4, Clay_extruder_tube_outer_d, 12]);
  }
}
