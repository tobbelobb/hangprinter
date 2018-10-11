use <util.scad>
use <donkey.scad>
include <parameters.scad>

f = 5;
d = 11;
tail = 5; // behind donkey available th = d/2 + tail
donkey_feet_w = 43.5;
encoder_feet_w = 29;
hole_to_hole_l = 83; //90.0;
th = 2;
bw = Bit_width-1;

elevate_donkey_screw_holes = th + 6.5;
shaft_mid_h = donkey_feet_w/2 + elevate_donkey_screw_holes;
box_depth_donkey = 2*bw+5;
ang_donkey = 90-atan((donkey_feet_w/2 + 43)/(box_depth_donkey - Donkey_feet_th));

the_height = shaft_mid_h-10; // encoder
box_depth_encoder = bw;
ang_encoder = -90+atan((the_height-Base_th+2)/(box_depth_encoder - th));

// for donkey face
tr_x = (hole_to_hole_l/2 - box_depth_donkey) - Donkey_feet_th;

module bit(twod, two=true){
  rotate([0,0,90])
    translate([-bw/2, -bw/2, 0])
    if(!twod){
      difference(){
        if(two){
          left_rounded_cube2([bw+4,2*bw,Base_th], 5.5, $fn=28);
        } else {
          left_rounded_cube2([bw+4,bw,Base_th], 5.5, $fn=28);
        }
        translate([bw/2, bw/2, -1])
          cylinder(d=Mounting_screw_d, h=Base_th+2, $fn=20);
        translate([bw/2, bw/2, 2.3])
          Mounting_screw_countersink();
        if(two){
          translate([bw/2, 3*bw/2, 2.3])
            Mounting_screw_countersink();
        }
      }
    } else { // 2d
      difference(){
        if(two){
          left_rounded_cube2_2d([bw+4,2*bw], 5.5, $fn=28);
        } else {
          left_rounded_cube2_2d([bw+4,bw], 5.5, $fn=28);
        }
        translate([bw/2, bw/2])
          circle(d=Mounting_screw_d, $fn=20);
        translate([bw/2, bw/2, 2.3])
          circle(d=Mounting_screw_d);
        if(two){
          translate([bw/2, 3*bw/2])
            circle(d=Mounting_screw_d);
        }
      }
    }
}

//to_be_mounted();
module to_be_mounted(){
  translate([hole_to_hole_l/2, 0, shaft_mid_h])
    rotate([0,-90,0])
    rotate([0,0,45])
    import("../stl/donkey.stl");
    //donkey();
  translate([box_depth_donkey+tr_x,0,0])
    donkey_face();

  translate([-hole_to_hole_l/2, 0, shaft_mid_h])
    rotate([0,90,0])
    rotate([0,0,45])
    translate([0,0,-34])
    import("../stl/donkey_encoder.stl");
    //donkey();
  translate([-hole_to_hole_l/2,0,0])
    encoder_face();
}

//donkey_face();
module donkey_face(twod=false){
  if(!twod){
    translate([-box_depth_donkey-tr_x,0,0]){
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
                translate([-14,0,0])
                cube([donkey_feet_w,
                    (donkey_feet_w + 20)/2 + 3,
                    2*box_depth_donkey + 2], center=true);
                translate([14,0,0])
                  cube([donkey_feet_w,
                      (donkey_feet_w + 20)/2 + 7,
                      2*box_depth_donkey + 2], center=true);
              }
          }
        }
        translate([8,0, -1])
          cylinder(d=Donkey_body_d,h= shaft_mid_h);
        //cube([box_depth_donkey, donkey_feet_w + 20 - 10, shaft_mid_h]);
        translate([0,-50,shaft_mid_h+donkey_feet_w/2+4])
          cube(100);
        translate([hole_to_hole_l/2, 0, shaft_mid_h])
          rotate([0,-90,0])
          rotate([0,0,-90]){
            teardrop(r=(Donkey_body_d + 4)/2, h=100,$fn =50);
          }
        translate([-hole_to_hole_l+tr_x+5,
            -(donkey_feet_w + 50)/2, -1])
          cube([hole_to_hole_l, donkey_feet_w + 50, 100]); // Makes the slant
        translate([(hole_to_hole_l/2 - box_depth_donkey) - Donkey_feet_th,0,0])
          rotate([0,ang_donkey, 0])
          translate([-hole_to_hole_l, -(donkey_feet_w + 50)/2, 0])
          cube([hole_to_hole_l, donkey_feet_w + 50, 100]); // Makes the slant
        translate([hole_to_hole_l/2,0,donkey_feet_w/2 + elevate_donkey_screw_holes])
          rotate([0,-90,0])
          rotate([0,0,45])
          donkey_screw_hole_translate(){
            rotate([0,0,15]){
              cylinder(d=3.3, h=40); // screw
              translate([0,0,Donkey_feet_th+1 + 6.1])
                cylinder(d=5.6/cos(30) + 0.1, h=40, $fn=6); // put nut in
            }
          }
      }
      for(k=[0,1])
        mirror([0,k,0])
          translate([tr_x+box_depth_donkey-bw/2,
              -(donkey_feet_w+20)/2-7,0]){
            bit(twod);
            translate([0,7,Base_th])
              rotate([0,-90,180])
              translate([0,0,-bw-bw/2])
              inner_round_corner(r=3, h=2*bw, $fn=36);
          }
    }
  } else {
    difference(){
      translate([tr_x+box_depth_donkey-2*bw, -(donkey_feet_w+20)/2])
        square([2*bw,
            donkey_feet_w + 20]);
      translate([8,0])
        circle(d=Donkey_body_d);
    }
    for(k=[0,1])
      mirror([0,k])
        translate([tr_x+box_depth_donkey-bw/2,
            -(donkey_feet_w+20)/2-7])
          bit(twod);

  }
}


//encoder_face();
module encoder_face(twod=false){
  emd = Encoder_LDP3806_d - 19;
  if(!twod){
    translate([hole_to_hole_l/2,0,0]){
      difference(){
        union(){
          translate([-hole_to_hole_l/2, -emd/2, 0])
            cube([box_depth_encoder, emd, the_height]);
          for(k=[0,1])
            mirror([0,k,0]){
              translate([-hole_to_hole_l/2+bw/2,-emd/2-7,0])
                bit(twod,two=false);
              translate([bw-hole_to_hole_l/2,emd/2,Base_th])
                rotate([0,-90,0])
                inner_round_corner(r=3, h=bw, $fn=36);
            }
        }
        for(k=[0,1])
          mirror([0,k,0])
            translate([-hole_to_hole_l/2-1,-emd/2,the_height])
            rotate([0,90,0])
            inner_round_corner(r=4, h=20, $fn=5*12);

        translate([-hole_to_hole_l/2 + box_depth_encoder,0,Base_th])
          rotate([0,ang_encoder,0])
          translate([0,-(emd + 6)/2, 0])
          cube([hole_to_hole_l, emd + 6, 34.56]); // the slant
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
                inner_round_corner_2d(1.5, $fn=20); // round corners of screw holes
            }
          }
        translate([0,0,shaft_mid_h])
          rotate([0,-90,0])
          rotate([0,0,-90]){
            teardrop(r=11, h=50, $fn=5*12);
          }
        //translate([-hole_to_hole_l/2 + box_depth_encoder/2 +0.6, -28/2, -1])
        //  cube([box_depth_encoder, 28, the_height]);
      }
    }
  } else {
    translate([-hole_to_hole_l/2, -emd/2])
      square([box_depth_encoder, emd]);
    translate([-hole_to_hole_l/2, 0])
      for(k=[0,1])
        mirror([0,k,0])
          translate([bw/2,-emd/2-7])
            bit(twod,two=false);
  }
}

//to_be_mounted();
//donkey_bracket(twod=true);
donkey_bracket(twod=false);
module donkey_bracket(twod=false){
  if(twod){
    encoder_face(twod);
    donkey_face(twod);
  } else {
    rotate([0,-90,0])
      encoder_face(twod);
    translate([-36,0,0])
      rotate([0,90,0])
      donkey_face(twod);
  }
  //donkey_face(twod=twod);
  //encoder_face(twod=twod);
  //plate(twod=twod);
}
