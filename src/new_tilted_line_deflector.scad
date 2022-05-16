include <lib/parameters.scad>
use <lib/util.scad>
use <bearing_u_608.scad>

u_width = 6;
extra = 8;
tot_length = b608_ugroove_big_r*2 + u_width*2 + 1*2 + extra;


bearing_holder();
module bearing_holder(){
  //%translate([b608_ugroove_small_r+1.2 ,0,(tot_length-extra)/2])
  //  rotate([90,0,0])
  //    bearing_u_608();
  difference(){
    union(){
      difference(){
        cylinder(d=b608_width + 7, h=tot_length, $fn=4*8);
        translate([0,-1,-1])
          cube([10, 2, tot_length/2 + 1]);
      }
      housing_width = b608_width + 2*0.5 + 2*3;
      housing_height = b608_ugroove_big_r*2 + extra;
      intersection(){
        difference(){
          translate([0, -housing_width/2, u_width + 1])
            right_rounded_cube2([b608_ugroove_small_r*2 + 1.2, housing_width, housing_height], 2, $fn=4*5);
          translate([b608_ugroove_small_r+1.2 ,0,(tot_length-extra)/2])
            rotate([90,0,0])
              cylinder(d=8.3, h=housing_height+2, center=true);
        }
        translate([-1.5,0,33.5])
          scale([1,1,1])
            rotate([90,0,0])
              cylinder(d=55, h=housing_width+2, center=true, $fn=4*20);
      }
    }

    translate([0,0,-1])
      cylinder(d=4, h=tot_length+2, $fn=4*4);
    translate([50/2,0,(tot_length-extra)/2])
      cube([50, b608_width + 2*0.5, b608_ugroove_big_r*2], center=true);
    translate([50/2,0,(tot_length-extra)/2])
      translate([-50/2, -(b608_width + 2*0.5)/2, -(b608_ugroove_big_r*2)/2])
        translate([0, 0, b608_ugroove_big_r*2])
          rotate([0, -22, 0])
            translate([0, 0, -b608_ugroove_big_r*2])
              cube([50, b608_width + 2*0.5, b608_ugroove_big_r*2]);
     translate([b608_ugroove_small_r+1.2 ,0,(tot_length-extra)/2])
       rotate([0,-90+45,0])
         translate([0,0,b608_ugroove_small_r+2])
           rotate([0,90,0])
             cylinder(d1=2, d2=20, h=40);
  }
  for(k = [0,1]) mirror([0,k,0])
    translate([b608_ugroove_small_r+1.2, -b608_width/2, (tot_length-extra)/2])
      rotate([90,0,0])
        difference(){
          cylinder(d=10, h=0.6);
          translate([0,0,-1])
            cylinder(d=8.3, h=2.6);
        }

}
