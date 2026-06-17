include <conventional_guide/self_reversing_thread_bosl2.scad>
include <../lib/parameters.scad>

stroke = 42;
rod_l = 42 + 2*4 + 2*b608_width;
rod_d = 10;

union(){
  self_reversing_grooved_rod(
      rod_d=rod_d,
      rod_l= stroke+5,
      stroke=42,
      turns_per_stroke=4,
      cycles=1,
      groove_d=2.2,
      groove_depth=1.35,
      samples_per_turn=120,
      reversal_frac=0.50
  );
  for(k=[0,1]) mirror([0,0,k]) {
    translate([0,0,-rod_l/2])
      cylinder(d=8, h=b608_width);
    translate([0,0,-rod_l/2 + b608_width])
      cylinder(d1=8, d2 = rod_d, h=rod_l/2 - b608_width - (stroke+5)/2);
  }
}

//down(rod_l/2 - b608_width)
//  cylinder(d = 9, h = 1);
//up(rod_l/2 - b608_width - 1)
//  cylinder(d = 9, h = 1);

