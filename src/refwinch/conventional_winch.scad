include <conventional_guide/self_reversing_thread_bosl2.scad>
include <../lib/parameters.scad>
include <../lib/util.scad>

stroke = 42;
rod_l = 42 + 2*4 + 2*b608_width;
rod_d = 11;

module grooved_rod(){
    self_reversing_grooved_rod(
      rod_d=rod_d,
      rod_l= stroke+5,
      stroke=42,
      turns_per_stroke=4,
      cycles=1,
      groove_d=1.8,
      groove_depth=1.75,
      samples_per_turn=120,
      reversal_frac=0.50
  );
}

module pawl(half_index = 0){
  color("orange")
    self_reversing_follower_pawl(
        rod_d=rod_d,
        stroke=stroke,
        turns_per_stroke=4,
        groove_d=2.2,
        groove_depth=1.35,
        half_index=half_index,
        q_center=0.0,
        angular_span=200,
        samples_per_turn=120,
        reversal_frac=0.50
    );
}


full_shaft();
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
  rotate([180,0,0]){
    intersection(){
      rotate([0,0,0])
        rotate([0,-90,0])
          translate([-rod_d/2,0,0])
          rotate([0,0,-101.56/2])
          translate([0,0,stroke/2])
          pawl();
      rotate([0,0,10])
        rotate([0,-90,0])
          translate([-rod_d/2,0,0])
          rotate([0,0,-101.56/2])
          translate([0,0,stroke/2])
          pawl();
      rotate([0,0,-10])
        rotate([0,-90,0])
          translate([-rod_d/2,0,0])
          rotate([0,0,-101.56/2])
          translate([0,0,stroke/2])
          pawl();
      translate([0,0,-5])
        cylinder(d=7.7, h=7);
    }
    translate([0,0,0.5])
      cylinder(d=7.7, h=1.5+2);
    ang=40;
    for(k=[0,1])
      down(.45)
      rotate([0,0,k*180-ang/2+90+(1-k)*7.5])
      linear_extrude(height=3) polygon(circle_sector(ang,0,7.7/2));
  }
}

//translate([6,0,0])
//  rotate([0,90,0])
//  cut_pawl();
full_shaft();
