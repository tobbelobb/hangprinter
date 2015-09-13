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
    translate([-25,75,-1])
      cube(50);
  }
}
corner_test();

//lock(Lock_radius_1, Lock_radius_2, Lock_height);
