use <util.scad>
use <donkey.scad>
include <parameters.scad>

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

donkey_encoder_coupler();
module donkey_encoder_coupler(h = 15){
  //!nutz();
  module nutz(){
  for(k=[0,120,240])
    rotate([0,0,k]){
      translate([0, Encoder_LDP3806_shaft_d/2 + 1.0, 0])
        nutlock();
    }
  }

  difference(){
    cylinder(d = Encoder_LDP3806_shaft_d + 6.05*2, h=h);
    translate([0, 0, -1])
      cylinder(d = Encoder_LDP3806_shaft_d + 0.1, h=h+2, $fn=20);
    translate([0,0,h - 7])
      nutz();
    translate([0,0,7])
      rotate([180, 0, 0])
        nutz();
    translate([0,0,-0.1])
      cylinder(d1 = Encoder_LDP3806_shaft_d + 1,
               d2 = Encoder_LDP3806_shaft_d - 0.1,
               h = 1.1,
               $fn = 20); // phase in
    translate([0,0,h-1.1+0.1])
      cylinder(d2 = Encoder_LDP3806_shaft_d + 1,
               d1 = Encoder_LDP3806_shaft_d - 0.1,
               h = 1.1,
               $fn = 20); // phase in

  }
}

//render_it();
module render_it(){
  donkey();
  translate([0,0,Donkey_h-6])
    import("../openscad_stl/donkey_encoder_coupler.stl");
  //donkey_encoder_coupler();
  translate([0,0,117])
    rotate([0,180,0])
    encoder_LDP3806();
}
