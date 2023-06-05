include <lib/parameters.scad>
use <lib/util.scad>
use <ram_1000_3dpotter.scad>

ram_1000_3dpotter_holder();
module ram_1000_3dpotter_holder(){
  difference(){
    union(){
      cylinder(d = Ram_1000_3dpotter_tube_outer_d + 2*5, h=10, $fn=15*4);
      for(k=[0,1]) mirror([k,0,0])
        translate([4/2+0.2,-Ram_1000_3dpotter_tube_outer_d/2-16,10])
          rotate([-atan(4/Ram_1000_3dpotter_tube_outer_d),90,0])
            difference(){
              rounded_cube2([10,18,3],2, $fn=7*4);
              translate([10/2,5,-1]){
                M3_screw();
                translate([0,0,3])
                  nut(h=3);
              }
            }

      for(ang=[0,120,240]) rotate([0,0,ang+60])
        translate([0,-Ram_1000_3dpotter_tube_outer_d/2-13,10])
          rotate([0,90,0])
            translate([0,0,-3/2])
              difference(){
                rounded_cube2([10,13,3],2, $fn=7*4);
                translate([10/2,5,-1])
                  cylinder(d=3.6, h=20);
              }
    }
    translate([0,0,-1])
      cylinder(d = Ram_1000_3dpotter_tube_outer_d, h=12, $fn=15*4);
    translate([-4/2, -Ram_1000_3dpotter_tube_outer_d,-1])
      cube([4, Ram_1000_3dpotter_tube_outer_d, 12]);
  }
}
