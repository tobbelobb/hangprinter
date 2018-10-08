include <parameters.scad>
use <util.scad>

//translate([40,40,0])
//rotate([0,-90,0])
//import("../stl/line_roller_double.stl");

//translate([-3,40,0])
//%import("../stl/lineroller_anchor.stl");

//!import("../stl/corner_clamp.stl");

module screw_track(l){
  head_r = 3.5;
  screw_r = 1.5;
  $fn=40;
  module screw_head(){
    translate([0,0,Screw_h])
      cylinder(r1=screw_r, r2=head_r, h=Screw_head_h);
    translate([0,0,Screw_h+Screw_head_h])
      cylinder(r=head_r, h=1);
  }
  hull(){
    screw_head();
    translate([l,0,0])
      screw_head();
  }
  hull(){
    cylinder(r=screw_r, h=Screw_h+1);
    translate([l,0,0])
      cylinder(r=screw_r, h=Screw_h+1);
  }
}

//custom_wall();
module custom_walls(s, wall_th, h, d){
  for(k=[0,1])
    mirror([0,k,0]){
      difference(){
        union(){
          translate([0, s/2,0])
            rotate([-90,0,0])
            translate([-d/2, -h,0])
            //cube([d, h, wall_th]);
            one_rounded_cube2([d, h, wall_th], 3, $fn=12*3);
          translate([Back_bearing_x, s/2 - 0.4, Higher_bearing_z])
            rotate([-90,0,0])
            cylinder(d=3.4+2, h=wall_th + 2, $fn=12);
          translate([Front_bearing_x, s/2 - 0.4, Lower_bearing_z])
            rotate([-90,0,0])
            cylinder(d=3.4+2, h=wall_th + 2, $fn=12);
          translate([Front_bearing_x, s/2+0.1, Higher_bearing_z])
            rotate([90,0,0])
            cylinder(r1=b623_vgroove_big_r+0.1, r2=b623_vgroove_small_r,
                h=b623_width/2, $fn=12*4);
        }
        translate([Back_bearing_x,s/2 - 1, Higher_bearing_z])
          rotate([-90,0,0]){
            cylinder(d=3.4, h=wall_th + 2, $fn=12);
            translate([0,0,1+wall_th - min(wall_th/2, 2)])
              nut(h=8);
          }
        translate([Front_bearing_x,s/2 - 1, Lower_bearing_z])
          rotate([-90,0,0]){
            cylinder(d=3.4, h=wall_th + 2, $fn=12);
            translate([0,0,1+wall_th - min(wall_th/2, 2)])
              nut(h=8);
          }
      }
    }
  translate([Front_bearing_x, -s/2-0.1, Higher_bearing_z])
    rotate([-90,0,0])
    cylinder(r=b623_vgroove_small_r, h=s+0.2, $fn=12*4);

   translate([Back_bearing_x, 0, 0])
     preventor_edges(Higher_bearing_z+Depth_of_roller_base/2,
       s, false, -90, 90);
   translate([Front_bearing_x, 0, 0])
     preventor_edges(Lower_bearing_z+Depth_of_roller_base/2,
       s, false, -67, -67+180);
}

rotate([0,90,0])
line_roller_anchor();
module line_roller_anchor(){
  s = b623_width + 0.8;
  wall_th =Line_roller_wall_th;
  d = Depth_of_roller_base;
  dm = 2*wall_th+s;
  tower_h = Higher_bearing_z + b623_vgroove_big_r;

  difference(){
    union(){
      translate([-dm, -dm/2, 0])
        cube([2*dm, dm, 6]);
      translate([0, -dm/2, 0])
        left_rounded_cube2([dm, 2*dm, 6], 3, $fn=12*3);
      custom_walls(s, wall_th, tower_h, 2*dm);
      translate([dm, dm/2, 6])
        rotate([0,-90,0])
        inner_round_corner(r=3, h=dm+3, $fn=12*2);
      translate([0, dm/2, 0])
        rotate([0,0,90])
        inner_round_corner(r=3, h=6, $fn=12*2);
    }
    translate([0, dm/2, -1])
      rotate([0,0,90])
      translate([3,3,0])
      cylinder(r=3, h=10, $fn=12*2);
    for(k=[0,1])
      mirror([0,k,0]){
        translate([-dm,-s/2-wall_th,-1])
          inner_round_corner(r=3, h=tower_h+2, $fn=12*3);
        translate([-dm-1,-s/2-wall_th,tower_h])
          rotate([0,90,0])
          inner_round_corner(r=3, h=2*dm+2, $fn=12*3);
      }

    translate([9,0,-0.1])
      screw_track(-2*dm);
    translate([9,dm,-0.1])
      screw_track(-2*dm);
    translate([dm, -dm, -1])
      cube([20,2*dm, tower_h+2]);
    translate([0, -dm, tower_h])
      cube([20,2*dm, 20]);
    for(k=[0,1])
      mirror([0,k,0])
        translate([-dm+3,dm/2-3,tower_h])
        rotate([0,180,0])
        inner_corner_rounder(3, $fn=12*3);
    translate([0,dm+dm/2,6])
      rotate([90,0,0])
      rotate([0,0,90])
      corner_rounder(3, 3, [dm,dm]);
    translate([-dm-1,dm*3/2,6])
      rotate([-90,0,-90])
      inner_round_corner(r=3, h=2*dm+2, $fn=12*3);
    translate([3,dm+dm/2-3,6])
      rotate([0,180,0])
      inner_corner_rounder(3, $fn=12*3);
  }

}


//    roller_base(twod=false,
//        yextra=0,
//        mv_edg=0,
//        wall_th=wall_th,
//        space_between_walls=s);



