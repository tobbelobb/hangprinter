include <lib/parameters.scad>
use <lib/util.scad>
use <bearing_u_big_623.scad>

u_width = 7;
extra = Stick_extra;
stick_length = Stick_length;
b_z = (stick_length - extra - 3)/2;
stick_d = Stick_d;
housing_width = b623_width + 2*0.5 + 2*2;
housing_height = b623_big_ugroove_big_r*2 + extra;
slit_w = 2;
bz = Gap_between_sandwich_and_plate + Sep_disc_radius - Spool_r;

new_tilted_line_deflector();
module new_tilted_line_deflector(twod = false, for_render = false, ang = -55){
  if(!twod && for_render) {
    translate([-16.5,0,9.9])
      rotate([-90,ang,0])
      bearing_holder(backwall=false, for_render=for_render);
    translate([0,0,9.9])
      rotate([-90,ang,0])
      bearing_holder(backwall=false, for_render=for_render);
  } else if (!twod) {
    translate([30,30,0])
       bearing_holder(backwall=false, for_render=for_render);
    translate([30,0,0])
       bearing_holder(backwall=false, for_render=for_render);
  }
  translate([0,0,bz]){
    bearing_holder_holder(twod=twod);
    translate([-(Spool_height + GT2_gear_height), 0, 0])
      bearing_holder_holder(twod=twod);
  }
  if (!twod) {
    translate([-(Spool_height + GT2_gear_height)/2, -2, 0])
      cylinder(d=10, h=Base_th);
  } else {
    translate([-(Spool_height + GT2_gear_height)/2, -2])
      circle(d=10);
  }
}



//bearing_holder();
module bearing_holder(backwall = false, for_render = false){
  if (for_render)
    translate([b623_big_ugroove_small_r+1.2, 0, b_z])
      rotate([90,0,0])
        bearing_u_big_623();
  difference(){
    union(){
      if (!backwall) {
        cylinder(d=stick_d, h=stick_length, $fn=4*8);
      } else {
        cylinder(d=stick_d, h=stick_length-extra, $fn=4*8);
      }
      intersection(){
        difference(){
          translate([0, -housing_width/2, u_width-1.5])
            right_rounded_cube2([b623_big_ugroove_small_r*2 + 1.2, housing_width, housing_height], 2, $fn=4*5);
          translate([b623_big_ugroove_small_r+1.2, 0, b_z])
            rotate([90,0,0])
              cylinder(d=3.5, h=housing_height+2, center=true);
        }
        translate([-7.5,0,29.5])
          scale([1,1,1])
            rotate([90,0,0])
              cylinder(d=55, h=housing_width+2, center=true, $fn=4*20);
      }
    }

    for(k=[0,1]) mirror([0,k,0])
      translate([b623_big_ugroove_small_r+1.2, -b623_width/2-1.5, b_z])
        rotate([90,0,0])
          scale(1.02)
            nut();

    translate([0,0,-1-10])
      cylinder(d2=4, d1=10, h=b_z+10, $fn=4*4);
    translate([0,0,-1])
      cylinder(d=4, h=b_z+b623_big_ugroove_big_r, $fn=4*4);
    //translate([50/2,0,(stick_length-extra)/2])
    //  cube([50, b623_width + 2*0.5, b623_big_ugroove_big_r*2], center=true);
    translate([50/2,0,(stick_length-extra)/2])
      translate([-50/2, -(b623_width + 2*0.5)/2, -(b623_big_ugroove_big_r*2)/2])
        translate([0, 0, b623_big_ugroove_big_r*2])
          if (!backwall) {
            rotate([0, -22, 0])
              translate([0, 0, -b623_big_ugroove_big_r*2])
                cube([50, b623_width + 2*0.5, b623_big_ugroove_big_r*2]);
          } else {
            translate([0, 0, -b623_big_ugroove_big_r*2+1])
              cube([50, b623_width + 2*0.5, b623_big_ugroove_big_r*2]);
          }
    if (!backwall)
      translate([b623_big_ugroove_small_r+1.2, 0, b_z])
        rotate([0,-90+41,0])
          translate([0,0,b623_big_ugroove_small_r+2])
            rotate([0,90,0])
              scale([1.1, 0.83, 1])
                cylinder(d1=2.5, d2=20, h=40);
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
            cylinder(d=3.5, h=2.6);
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
            cylinder(d=3.5, h=2.6);
  }
}


//bearing_holder_holder(twod=true);
module bearing_holder_holder(twod=false, backwall=false){
  hll = stick_length + 2.5;
  hdd = stick_d + 8;

  //color([0.2,0.5,0.5])
  //  %rotate([0,-90,-90])
  //    translate([0,0,-0.1])
  //      rotate([0,0,0])
  //        bearing_holder();

  $fn=10*4;
  if (!twod) {
    rotate([-90,0,0])
      translate([0,0,-5/2])
        difference(){
          union(){
            difference(){
              if (!backwall) {
                cylinder(d=hdd, h=hll);
              } else {
                cylinder(d=hdd, h=hll-extra);
              }
              translate([-(30)/2, 9, -1])
                cube([30, 20, hll+2]);
            }
            translate([-hdd/2, 0, 0])
              if(!backwall) {
                cube([hdd, bz, hll]);
              } else {
                cube([hdd, bz, hll-extra]);
              }
            if (!backwall)
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
            if (!backwall) {
              cube([4*top_w, stick_d, housing_height+5]);
            } else {
              cube([4*top_w, stick_d, housing_height+6-extra]);
            }
          translate([-(4*top_w)/2, -stick_d+9.9-Base_th, 13])
            rounded_cube([4*top_w, stick_d, 7], 1);
        }
    } else { // twod=true
      union() {
        for(h = [0, hll-12])
          translate([-(hdd+2*10)/2, -5/2+h, -bz]){
            difference(){
              rounded_cube2_2d([hdd+2*10, 12], 3);
              translate([5, 6, 0])
                Mounting_screw(twod=twod);
              translate([hdd+2*10-5, 6, 0])
                Mounting_screw(twod=twod);
            }
          }
          translate([-(20)/2, 0, -bz])
            square([20, 30]);
      }
    }
}
