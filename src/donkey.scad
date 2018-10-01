include <parameters.scad>
use <util.scad>
use <motor_gear.scad>


module encoder_screw_hole_translate(twist=0){
  rotate([0,0,twist])
    for(rot=[0:120:359])
      rotate([0,0,rot])
        for(k=[1,-1])
          translate([14, k*7.5/2, 34 - 10])
            children();
}

module encoder_screw_holes(h = 11){
  encoder_screw_hole_translate()
    cylinder(d=3, h=h); // screw holes
}

module donkey_screw_hole_translate(){
  for(rot=[0:90:359])
    rotate([0,0,rot])
      translate([0,56/2 + 6/2,-1])
        rotate([0,0,-rot])
          children();
}

module donkey_screw_holes(){
  donkey_screw_hole_translate()
    rotate([0,0,90]) // center these round ends...
    translate([-3, -4.5/2, 0])
    round_ends([6, 4.5, 3.5 + 2], $fn=14);
}

donkey();
module donkey(){
  difference(){
    cylinder(d = 73,h = 12);
    translate([0,0,Donkey_feet_th])
    rotate_extrude()
      translate([73/2-9.6,0])
      square(12);
    for(rot=[0:90:359])
      rotate([0,0,rot]){
        translate([5,5,-1])
          rounded_cube2([73,73,12+2], 10, $fn=4*7);
      }
    donkey_screw_holes();
    translate([0,0,-1])
      cylinder(d = 46, h = 8.7 + 1);
  }
  translate([0, 0, 13.3]){
    color("dimgray"){
      cylinder(d = Donkey_body_d, h = 23);
      cylinder(d = 18, h = 23 + 5.6);
    }
    cylinder(d = Donkey_shaft_d, h = 23 + 5.6 + 23.22);
  }
  translate([0,0,Donkey_h - GT2_motor_gear_height - 6.5])
    motor_gear();
}

//encoder_LDP3806();
module encoder_LDP3806(){
  difference(){
    union(){
      color("slategrey")
        cylinder(d = Encoder_LDP3806_d, h = 32);     // black body
      translate([0,0,1])
        cylinder(d = Encoder_LDP3806_d - 0.1, h = 34-1); // shiny body
    }
    encoder_screw_holes();
  }
  translate([0,0,1]){
    difference(){
      cylinder(d = 20, h = 34 + 5 - 1);
      translate([0, 0, 34 + 5 - 1.5])
        cylinder(d = 15, h = 10 - 1);  // down to bearing
    }
    difference(){
      cylinder(d = Encoder_LDP3806_shaft_d, h = 51.3 - 1, $fn=20); // shaft
      translate([-2, 2.5, 51.3 - 10 - 1])
        cube([4,2,10 + 1]);              // D-side of shaft
    }
  }
}
