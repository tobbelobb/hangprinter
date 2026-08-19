include <conventional_guide/self_reversing_thread_bosl2.scad>
include <../lib/parameters.scad>
include <../lib/util.scad>
include <../lib/gears.scad>

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

gear_th = 8;
module torx_thing(gear_th=8){
  intersection(){
    for(ang=[0:360/6:359])
      rotate([0,0,ang])
        translate([3,0,0])
        cylinder(d=3.2,h=gear_th);
      cylinder(d=8,h=gear_th);
  }
  cylinder(d=6.4,h=gear_th);

}

//full_shaft();
module full_shaft(){
  union(){
    grooved_rod();
    for(k=[0,1]) mirror([0,0,k]) {
      translate([0,0,-rod_l/2-1])
        cylinder(d=8, h=b608_width+1);
      translate([0,0,-rod_l/2 + b608_width])
        cylinder(d1=8, d2 = rod_d, h=rod_l/2 - b608_width - (stroke+5)/2);
    }
    translate([0,0,-rod_l/2-gear_th-1])
    torx_thing(gear_th);
  }

  for(k=[0,1]) mirror([0,0,k])
    translate([0,0,-rod_l/2-0.5])
    b608();
}

//helix_gear_big();
module helix_gear_big(
  modul=1,
  tooth_number=60,
  width=8,
  bore=12,
  pressure_angle=20,
  helix_angle=45
){
  for(k=[0,1]) mirror([0,0,k])
  spur_gear(
    modul=modul,
    tooth_number=tooth_number,
    width=width/2,
    bore=bore,
    pressure_angle=pressure_angle,
    helix_angle=helix_angle,
    optimized=true
  );
  tol = 0.3;
  torx_thing_w = 6.4;
  s = (torx_thing_w+tol)/torx_thing_w;
  difference() {
    cylinder(d=13, h=width, center=true);
    translate([0,0,-(width+2)/2])
    scale([s,s,1])
    torx_thing(width+2);
  }
}

//cut_pawl();
module cut_pawl(){
  intersection(){
    translate([0,0,rod_d/2])
    rotate([0,90,0])
      pawl();
    translate([0,0,-5])
      cylinder(d=rod_d, h=12);
    down(4)
      cube(13, center=true);
  }
  translate([0,0,-5-1])
    cylinder(d=8, h=5);
}

rotate([0,90,0]) {
  translate([6,0,0])
    rotate([0,-90,0])
    cut_pawl();
  full_shaft();
  translate([0,0,-rod_l/2-gear_th/2-1])
  helix_gear_big();
}
