use <util.scad>

Donkey_shaft_d = 6;
Encoder_LDP3806_shaft_d = 6;
Donkey_h = 65.12;

//donkey();
module donkey(){
  module hole(d, l, h){
    between = l - d;
    for(k=[1,-1])
      translate([0, k*between/2, 0])
        cylinder(d = d, h=h);
    translate([-d/2, -between/2, 0])
      cube([d, between, h]);
  }

  difference(){
    cylinder(d = 73,h = 12);
    translate([0,0,3.5])
    rotate_extrude()
      translate([73/2-9.6,0])
      square(12);
    for(rot=[0:90:359])
      rotate([0,0,rot]){
        translate([5,5,-1])
          rounded_cube2([73,73,12+2], 10, $fn=4*7);
        translate([0,56/2 + 6/2,-1])
          hole(4.5, 6, 3.5 + 2, $fn=14);
      }
    translate([0,0,-1])
      cylinder(d = 46, h = 8.7 + 1);
  }
  translate([0, 0, 13.3]){
    color("dimgray"){
      cylinder(d = 50, h = 23);
      cylinder(d = 18, h = 23 + 5.6);
    }
    cylinder(d = Donkey_shaft_d, h = 23 + 5.6 + 23.22);
  }
}

//encoder_LDP3806();
module encoder_LDP3806(){
  difference(){
    union(){
      color("slategrey")
        cylinder(d = 38, h = 32);     // black body
      translate([0,0,1])
        cylinder(d = 38 - 0.1, h = 34-1); // shiny body
    }
    for(rot=[0:120:359])
      rotate([0,0,rot])
        for(k=[1,-1])
          translate([14, k*7.5/2, 34 - 10])
            cylinder(d=3, h=11); // screw holes
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
