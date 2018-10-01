use <util.scad>
use <donkey.scad>
include <parameters.scad>

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
    donkey_encoder_coupler();
  translate([0,0,117])
    rotate([0,180,0])
    encoder_LDP3806();
}
