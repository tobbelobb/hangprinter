include <design_numbers.scad>
use <parts.scad>

module tower_test(){
  intersection(){
    bottom_plate();
    translate([0,0,-1])
      cylinder(r=10, h=50);
  }
}
//tower_test();

module corner_test(){
  intersection(){
    bottom_plate();
    for(i=[0,1,2])
    rotate([0,0,i*120])
    translate([-25,75,-1])
      cube(50);
  }
}
//rotate([0,0,15])
//corner_test();

rotate([0,0,-45])
side_plate2();

//lock(Lock_radius_1, Lock_radius_2, Lock_height);
