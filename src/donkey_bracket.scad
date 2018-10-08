use <util.scad>
use <donkey.scad>
include <parameters.scad>

f = 5;
d = 11;
tail = 5; // behind donkey available th = d/2 + tail
donkey_feet_w = 43.5;
encoder_feet_w = 29;
hole_to_hole_l = 90; //83.0;
th = 2;
elevate_donkey_screw_holes = th + 13.5;
shaft_mid_h = donkey_feet_w/2 + elevate_donkey_screw_holes;
box_depth_donkey = hole_to_hole_l/4+11-4;
ang_donkey = 90-atan((donkey_feet_w/2 + 24)/(box_depth_donkey - Donkey_feet_th));

the_height = shaft_mid_h-10; // encoder
box_depth_encoder = hole_to_hole_l/4;
ang_encoder = -90+atan(the_height/(box_depth_encoder - th));

//to_be_mounted();
module to_be_mounted(){
  translate([hole_to_hole_l/2, 0, shaft_mid_h])
    rotate([0,-90,0])
    rotate([0,0,0])
    import("../stl/donkey.stl");
    //donkey();

  translate([-hole_to_hole_l/2, 0, shaft_mid_h])
    rotate([0,90,0])
    rotate([0,0,45])
    translate([0,0,-34])
    import("../stl/donkey_encoder.stl");
    //donkey();
}



//donkey_face();
module donkey_face(twod=false){
  tr_x = (hole_to_hole_l/2 - box_depth_donkey) - Donkey_feet_th;
  if(!twod){
    difference(){
      union(){
        translate([tr_x, -(donkey_feet_w+20)/2, 0]){
          cube([box_depth_donkey,
                donkey_feet_w + 20,
                elevate_donkey_screw_holes + donkey_feet_w + -14.2]);
          translate([0,(donkey_feet_w + 20)/2, shaft_mid_h])
            rotate([0,90,0])
            difference(){
              cylinder(r=(donkey_feet_w + 20)/2 + 4, h = box_depth_donkey, $fn=60);
              cube([donkey_feet_w + 20 + 10 + 1,
                   (donkey_feet_w + 20)/2 + 3,
                   2*box_depth_donkey + 2], center=true);
              difference(){
                translate([0,0,box_depth_donkey])
                  mirror([0,0,1])
                  rotate_extrude($fn=60)
                    translate([-(Donkey_body_d + 4)/2-8.75,0])
                    inner_round_corner2d(1.5, $fn=50);
                cube([donkey_feet_w + 20 + 10 + 1,
                     donkey_feet_w + 20,
                     2*box_depth_donkey + 4], center=true);
              }
            }
        }
      }
      translate([tr_x - box_depth_encoder/2+1.5, -(donkey_feet_w + 20 - 10)/2, -1])
        cube([box_depth_donkey, donkey_feet_w + 20 - 10, shaft_mid_h]);
      translate([0,-50,shaft_mid_h + + 5])
        cube(100);
      translate([hole_to_hole_l/2, 0, shaft_mid_h])
        rotate([0,-90,0])
        rotate([0,0,-90]){
          teardrop(r=(Donkey_body_d + 4)/2, h=100,$fn =50);
          translate([0,0,Donkey_feet_th]){
            rotate_extrude($fn=50)
              translate([(Donkey_body_d + 4)/2,0])
              inner_round_corner2d(1.5, $fn=50);
          }
        }
      translate([0, -(Donkey_body_d - 19)/2, Donkey_body_d/2])
        cube([100, Donkey_body_d - 19, Donkey_body_d*2]); // Further opens teardrop opening
      translate([(hole_to_hole_l/2 - box_depth_donkey) - Donkey_feet_th,0,0])
        rotate([0,ang_donkey, 0])
        translate([-hole_to_hole_l, -(donkey_feet_w + 50)/2, 0])
        cube([hole_to_hole_l, donkey_feet_w + 50, 100]); // Makes the slant
      translate([hole_to_hole_l/2,0,donkey_feet_w/2 + elevate_donkey_screw_holes])
        rotate([0,-90,0])
        donkey_screw_hole_translate(){
          rotate([0,0,30]){
            cylinder(d=3.3, h=40); // screw
            rotate_extrude($fn=6)
              translate([1.5,Donkey_feet_th+1])
              inner_round_corner2d(1.5, $fn=20); // round corners of screw holes
            translate([0,0,Donkey_feet_th+1 + 6.1])
              cylinder(d=5.6/cos(30) + 0.1, h=40, $fn=6); // put nut in
          }
        }
    }
  } else {
    for(k=[0,1])
      mirror([0,k])
        translate([tr_x, -(donkey_feet_w+20)/2])
        square([box_depth_donkey, f]);
    translate([tr_x+19.75, -(donkey_feet_w+20)/2])
      square([9.75, 64]);
  }
}


//encoder_face();
module encoder_face(twod=false){
  if(!twod){
    difference(){
      translate([-hole_to_hole_l/2, -Encoder_LDP3806_d/2, 0])
        translate([box_depth_encoder,0,0])
        rotate([0,-90,0])
        right_rounded_cube2([the_height, Encoder_LDP3806_d, box_depth_encoder],
                             13, $fn=4*10);
      translate([-hole_to_hole_l/2 + box_depth_encoder,0,0])
        rotate([0,ang_encoder,0])
        translate([0,-(Encoder_LDP3806_d + 2)/2, 0])
        cube([hole_to_hole_l, Encoder_LDP3806_d + 2, 34.56]); // the slant

      translate([-hole_to_hole_l/2 + box_depth_encoder/2 - 1.5,0,32.45])
        translate([0,-(Encoder_LDP3806_d + 2)/2, 0])
        cube([hole_to_hole_l, Encoder_LDP3806_d + 2, 50]); // the slant
      translate([-hole_to_hole_l/2+ 10, 0, shaft_mid_h])
        rotate([0,90,0])
        rotate([0,0,45])
        encoder_screw_hole_translate(-45){
          translate([0,0,-34]){
            translate([0,0,-1])
              rotate([0,0,30])
              cylinder(d=3.3, h=40); // screw
            translate([0,0,4.0])
              rotate([0,0,30])
              cylinder(d=5.6/cos(30) + 0.1, h=40, $fn=6); // Put nut in
            translate([0,0,-4.5])
              rotate([0,0,30])
              rotate_extrude($fn=6)
              translate([1.5,Donkey_feet_th+1])
              inner_round_corner2d(1.5, $fn=20); // round corners of screw holes
          }
        }
      translate([0,0,shaft_mid_h])
        rotate([0,-90,0])
          rotate([0,0,-90]){
            teardrop(r=11, h=50);
          }
      translate([-hole_to_hole_l/2 + box_depth_encoder/2 -1.5, -28/2, -1])
        cube([box_depth_encoder, 28, the_height]);
    }
  } else {
    translate([-hole_to_hole_l/2, -Encoder_LDP3806_d/2])
      square([Bit_width+1, Encoder_LDP3806_d]);
  }
}

//plate();
module plate(twod=false){
  a = hole_to_hole_l/2;
  b = box_depth_encoder;
  c = box_depth_donkey;
  d = (donkey_feet_w + 20)/2;
  e = a - Donkey_feet_th;

  module base_cross_2d(){
    for(k=[0,1])
      mirror([0,k,0]){
        polygon(points = [
                          [-a+b, -Encoder_LDP3806_d/2],
                          [-a+b-10, -Encoder_LDP3806_d/2],
                          [-a+b-10, -Encoder_LDP3806_d/2 + f],
                          [-a+b, -Encoder_LDP3806_d/2 + f],
                          [ e-c, -d + f],
                          [ e-c+10, -d + f],
                          [ e-c+10, -d],
                          [ e-c, -d],
                         ]);
        polygon(points = [
                          [-a+b, -Encoder_LDP3806_d/2],
                          [-a+b-10, -Encoder_LDP3806_d/2],
                          [-a+b-10, -Encoder_LDP3806_d/2 + f],
                          [-a+b, -Encoder_LDP3806_d/2 + f],
                          [ e-c, d],
                          [ e-c+10, d],
                          [ e-c+10, d-f],
                          [ e-c, d-f],
                         ]);
      }
  }

  if(!twod){
    linear_extrude(height=8, convexity=10)
      base_cross_2d();
  } else {
    base_cross_2d();
  }

  module bit(){
    rotate([0,0,90])
    translate([-Bit_width/2, -Bit_width/2, 0])
    if(!twod){
      difference(){
        left_rounded_cube2([Bit_width+4,Bit_width,Base_th], 5.5, $fn=28);
        translate([Bit_width/2, Bit_width/2, -1])
          cylinder(d=Mounting_screw_d, h=Base_th+2, $fn=20);
        translate([Bit_width/2, Bit_width/2, 2.3])
          Mounting_screw_countersink();
      }
    } else {
      difference(){
        left_rounded_cube2_2d([Bit_width+4,Bit_width], 5.5, $fn=28);
        translate([Bit_width/2, Bit_width/2])
          circle(d=Mounting_screw_d, $fn=20);
        translate([Bit_width/2, Bit_width/2, 2.3])
          circle(d=Mounting_screw_d);
      }
    }
  }
  for(k=[0,1])
    mirror([0,k,0]){
      translate([-hole_to_hole_l/2+Bit_width/2,
                 -Encoder_LDP3806_d/2-Bit_width/2,
                 0]){
        bit(); // Wood screw holes encoder
        if(!twod){
          translate([Bit_width/2,Bit_width/2,0])
            rotate([0,0,-90])
            inner_round_corner(r=4, h=Base_th, $fn=28);  // bit-fillet encoder
        } else {
          translate([Bit_width/2,Bit_width/2])
            rotate([0,0,-90])
            inner_round_corner_2d(r=4, $fn=28);  // bit-fillet encoder
        }
      }
      translate([hole_to_hole_l/2 - Donkey_feet_th - Bit_width/2,
                 -(donkey_feet_w + 20)/2 - Bit_width/2,
                 0]){
        bit(); // Wood screw holes donkey
        if(!twod){
          translate([-Bit_width/2,Bit_width/2,0])
            rotate([0,0,180])
            inner_round_corner(r=4, h=Base_th, $fn=28); // bit-fillet donkey
        } else {
          translate([-Bit_width/2,Bit_width/2])
            rotate([0,0,180])
            inner_round_corner_2d(r=4, $fn=28); // bit-fillet donkey
        }
      }
      if(!twod){
        translate([-a+b + 8*tan(ang_encoder) , Encoder_LDP3806_d/2, 8])
          rotate([90,ang_encoder/2,0])
          translate([-0.70,-0.70,0])
          inner_round_corner(h=f, r=6, ang=-ang_encoder, $fn=4*8); // fillet
        translate([e-c + 8*tan(ang_donkey),d-f, 8])
          rotate([90,-ang_donkey/2,180])
          translate([-0.91,-0.91,0])
          inner_round_corner(h=f, r=6, ang=90-ang_donkey, $fn=4*8); // fillet
      }
    }
}

donkey_bracket();
//donkey_bracket(twod=true);
module donkey_bracket(twod=false){
  donkey_face(twod=twod);
  encoder_face(twod=twod);
  plate(twod=twod);
}
