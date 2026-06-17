include <conventional_guide/self_reversing_thread_bosl2.scad>
include <../lib/parameters.scad>

stroke = 42;
rod_l = 42 + 2*4 + 2*b608_width;
rod_d = 10;

module grooved_rod(){
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
        q_center=0.5,
        angular_span=45,
        samples_per_turn=120,
        reversal_frac=0.50
    );
}


//union(){
//  grooved_rod();
//  for(k=[0,1]) mirror([0,0,k]) {
//    translate([0,0,-rod_l/2])
//      cylinder(d=8, h=b608_width);
//    translate([0,0,-rod_l/2 + b608_width])
//      cylinder(d1=8, d2 = rod_d, h=rod_l/2 - b608_width - (stroke+5)/2);
//  }
//}

//// Follower/pawl tooth building block preview.  Uncomment to inspect the
//// positive insert that matches the groove cutter profile.
difference(){
  //rotate([60,0,0])
  difference() {
     rotate([138,0,0])
       pawl();
    translate([0,0,-2.8])
     rotate([0,0,90])
     grooved_rod();
  }
  //#grooved_rod();
}
