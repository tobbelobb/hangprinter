include <lib/parameters.scad>
use <lib/util.scad>
use <bearing_u_big_623.scad>

u_width = 7;
extra = 5;
stick_length = b623_big_ugroove_big_r*2 + u_width*2 + 1*2 + extra;
b_z = (stick_length - extra - 3)/2;
stick_d = 14;
housing_width = b623_width + 2*0.5 + 2*2;
housing_height = b623_big_ugroove_big_r*2 + extra;
slit_w = 2;


translate([30,0,0])
!bearing_holder();
module bearing_holder(){
  //%translate([b623_big_ugroove_small_r+1.2, 0, b_z])
  //  rotate([90,0,0])
  //    bearing_u_big_623();
  difference(){
    union(){
      cylinder(d=stick_d, h=stick_length, $fn=4*8);
      intersection(){
        difference(){
          translate([0, -housing_width/2, u_width-1.5])
            right_rounded_cube2([b623_big_ugroove_small_r*2 + 1.2, housing_width, housing_height], 2, $fn=4*5);
          translate([b623_big_ugroove_small_r+1.2, 0, b_z])
            rotate([90,0,0])
              cylinder(d=3.3, h=housing_height+2, center=true);
        }
        translate([-7.5,0,29.5])
          scale([1,1,1])
            rotate([90,0,0])
              cylinder(d=55, h=housing_width+2, center=true, $fn=4*20);
      }
    }

    translate([0,0,-1])
      cylinder(d=4, h=b_z+b623_big_ugroove_big_r, $fn=4*4);
    //translate([50/2,0,(stick_length-extra)/2])
    //  cube([50, b623_width + 2*0.5, b623_big_ugroove_big_r*2], center=true);
    translate([50/2,0,(stick_length-extra)/2])
      translate([-50/2, -(b623_width + 2*0.5)/2, -(b623_big_ugroove_big_r*2)/2])
        translate([0, 0, b623_big_ugroove_big_r*2])
          rotate([0, -22, 0])
            translate([0, 0, -b623_big_ugroove_big_r*2])
              cube([50, b623_width + 2*0.5, b623_big_ugroove_big_r*2]);
    translate([b623_big_ugroove_small_r+1.2, 0, b_z])
      rotate([0,-90+45,0])
        translate([0,0,b623_big_ugroove_small_r+2])
          rotate([0,90,0])
            scale([1.1, 0.94, 1])
              cylinder(d1=2, d2=20, h=40);
    translate([0,-1,-1])
      cube([11, slit_w, stick_length/2 + 3]);
    translate([b623_big_ugroove_small_r+1.2, 0, b_z])
      rotate([90,0,0])
        cylinder(d = b623_big_ugroove_big_r*2 + b623_ugroove_room_to_grow_r*2,
                 h = b623_width + 1, center = true);

    for(k = [0,1]) mirror([0,k,0])
      translate([b623_big_ugroove_small_r+1.2, -b623_width/2, b_z])
        rotate([90,0,0])
          translate([0,0,-1])
            cylinder(d=3.3, h=2.6);
  }

  difference(){
    for(k = [0,1]) mirror([0,k,0])
      translate([b623_big_ugroove_small_r+1.2, -b623_width/2, b_z])
        rotate([90,0,0])
          cylinder(d=6, h=0.6);
    for(k = [0,1]) mirror([0,k,0])
      translate([b623_big_ugroove_small_r+1.2, -b623_width/2, b_z])
        rotate([90,0,0])
          translate([0,0,-1])
            cylinder(d=3.3, h=2.6);
  }
}


bz = Gap_between_sandwich_and_plate + Sep_disc_radius - Spool_r;
translate([0,0,bz])
bearing_holder_holder();
module bearing_holder_holder(){
  hll = stick_length + 2.5;
  hdd = stick_d + 8;

  color([0.2,0.5,0.5])
    %rotate([0,-90,-90])
      translate([0,0,-0.1])
        rotate([0,0,0])
          bearing_holder();

  $fn=10*4;
  rotate([-90,0,0])
    translate([0,0,-5/2])
      difference(){
        union(){
          difference(){
            cylinder(d=hdd, h=hll);
            translate([-(30)/2, 9, -1])
              cube([30, 20, hll+2]);
          }
          translate([-hdd/2, 0, 0])
            cube([hdd, bz, hll]);
          for(h = [0, hll-12])
            translate([-(hdd+2*10)/2,bz,h]){
              rotate([90,0,0]){
                difference(){
                  rounded_cube2([hdd+2*10, 12, Base_th], 3);
                  translate([5, 6, 0.3])
                    Mounting_screw();
                  translate([hdd+2*10-5, 6, 0.3])
                    Mounting_screw();
                }
              }
              translate([20,0,0])
                for(k=[0,1]) mirror([k,0,0])
                  translate([10,-Base_th,0])
                    rotate([0,0,3*90])
                      inner_round_corner(h=12, r=1.5, $fn=4*4);
            }
        }

        translate([0,0,5/2])
          cylinder(d=stick_d, h=hll + 2);
        translate([0,0,-1])
          cylinder(d=stick_d-2, h=hll + 2);
        top_w = b623_width+2*2.5;
        translate([-(top_w)/2, -stick_d, -1])
          cube([top_w, stick_d, hll+2]);
        translate([-(3*top_w)/2, -stick_d-stick_d/2+1.7, -1])
          cube([3*top_w, stick_d, hll+2]);
        translate([-(4*top_w)/2, -stick_d, u_width+0.5])
          cube([4*top_w, stick_d, housing_height+5]);
        translate([-(4*top_w)/2, -stick_d+9.9-Base_th, 13])
          rounded_cube([4*top_w, stick_d, 7], 1);

      }
}
