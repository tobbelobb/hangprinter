include <conventional_guide/self_reversing_thread_bosl2.scad>
include <../lib/parameters.scad>
include <../lib/util.scad>

stroke = 42;
rod_l = stroke + 2*4 + 2*b608_width;
rod_d = 11;

module grooved_rod(){
    self_reversing_grooved_rod(
      rod_d=rod_d,
      rod_l= stroke+5,
      stroke=stroke,
      turns_per_stroke=4,
      cycles=1,
      groove_d=1.8,
      groove_depth=1.75,
      samples_per_turn=120,
      reversal_frac=0.250
  );
}

//pawl();
module pawl(){
  intersection(){
  color("orange")
    self_reversing_follower_pawl(
        rod_d=rod_d,
        stroke=stroke,
        turns_per_stroke=4,
        groove_d=1.8,
        groove_depth=1.75,
        half_index=0,
        q_center=0.5,
        angular_span=125,
        samples_per_turn=120,
        reversal_frac=0.250
    );
  rotate([53,0,0])
    self_reversing_follower_pawl(
        rod_d=rod_d,
        stroke=stroke,
        turns_per_stroke=4,
        groove_d=1.8,
        groove_depth=1.75,
        half_index=1,
        q_center=0.5,
        angular_span=125,
        samples_per_turn=120,
        reversal_frac=0.250
    );
  }
}

//%translate([0,0,2.835])
//   rotate([0,0,90])
//   grooved_rod();


full_shaft();
// Full shaft is still missing its torx part for push-on gear to snap fit onto
module full_shaft(){
  union(){
    grooved_rod();
    for(k=[0,1]) mirror([0,0,k]) {
      translate([0,0,-rod_l/2])
        cylinder(d=8, h=b608_width);
      translate([0,0,-rod_l/2 + b608_width])
        cylinder(d1=8, d2 = rod_d, h=rod_l/2 - b608_width - (stroke+5)/2);
    }
  }
}

//cut_pawl();
module cut_pawl(){
  intersection(){
    translate([0,0,rod_d/2])
    rotate([0,90,0])
      pawl();
    translate([0,0,-5])
      cylinder(d=rod_d+2, h=12);
    down(4)
      cube(13, center=true);
  }
  translate([0,0,-5-1])
    cylinder(d=8, h=5);
}

//translate([6,0,0])
//  rotate([0,90,0])
//cut_pawl();
//full_shaft();
