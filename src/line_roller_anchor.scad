include <lib/parameters.scad>
use <new_tilted_line_deflector.scad>
use <lib/util.scad>

module screw_track(l){
  // These are not M3 machine screws...
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

module screw_tracks(){
  for(k=[0,1])
    mirror([k,0,0])
      translate([6,-5,-0.1])
      rotate([0,0,-90])
      screw_track(100);
}

line_action_lower_z = 11.15;
slide_in_bullet = -17;
module bullet(for_print=false) {
  if (!for_print) {
    translate([0, slide_in_bullet, line_action_lower_z])
      rotate([0,-90,-90])
        rotate([0,0,3])
        bearing_holder(backwall=true, for_render=!for_print);
  } else {
    translate([0,23,0])
      rotate([0,0,90])
      bearing_holder(backwall=true, for_render=!for_print);
  }
}

module bullet_tower() {
  translate([0, slide_in_bullet, line_action_lower_z])
    bearing_holder_holder(backwall=true);
}


w = 27;
l = 35;
front = -l+Depth_of_roller_base/2;
module action_points(){
  translate([0, front+4.5, b623_big_ugroove_small_r + Eyelet_extra_dist + line_action_lower_z]){
    translate([0,15, 0 - b623_big_ugroove_small_r - Eyelet_extra_dist])
      rotate([90,90,0]){
        eyelet(h=20);
      }
    translate([0,-3, Corner_clamp_bearings_center_to_center + b623_big_ugroove_small_r + Eyelet_extra_dist])
      rotate([90,0,0]){
        cylinder(h=3, d=0.5);
      }
  }
}

//cutoff_cube();
module cutoff_cube(){
  translate([0, front+6, b623_big_ugroove_small_r + Eyelet_extra_dist + line_action_lower_z])
    translate([0,0, Corner_clamp_bearings_center_to_center + b623_big_ugroove_small_r + Eyelet_extra_dist])
      rotate([90,0,0])
        translate([-15/2,0,-1])
          cube(15);
}

w_small = 10;
module mid_section() {
  translate([0,0,16])
  linear_extrude(height=0.1)
  hull() {
    translate([ w_small+1, 2]) circle(r=2, $fn=4*6);
    translate([        -1, 2]) circle(r=2, $fn=4*6);
    translate([         0, 7]) circle(r=2, $fn=4*6);
    translate([   w_small, 7]) circle(r=2, $fn=4*6);
  }
}

base_th = 7;
//eiffel();
module eiffel(){
  translate([-w_small/2, front, base_th-0.1])
    difference(){
      union(){
        hull(){
          linear_extrude(height=0.1)
            hull() {
              translate([w_small/2+w/2-2,2])  circle(r=2, $fn=4*6);
              translate([-6.5,2])             circle(r=2, $fn=4*6);
              translate([-6.5,13])            circle(r=2, $fn=4*6);
              translate([w_small/2+w/2-2,13]) circle(r=2, $fn=4*6);
            }
          mid_section();
        }
        hull(){
          mid_section();
          translate([0,0,Corner_clamp_bearings_center_to_center + 2*b623_big_ugroove_small_r + 2*Eyelet_extra_dist + base_th])
            linear_extrude(height=0.1)
              hull() {
                translate([w_small-0.4, 2])   circle(r=2, $fn=4*6);
                translate([0.4, 2])           circle(r=2, $fn=4*6);
                translate([w_small-0.4, 2.8]) circle(r=2, $fn=4*6);
                translate([0.4, 2.8])         circle(r=2, $fn=4*6);
              }
        }
      }
    }
}

module vertical_screws(){
  for(k=[0,1]) mirror([k,0,0]) {
    translate([3.2 + 1,
               front+3.6/2+1.36/2,
               line_action_lower_z + Corner_clamp_bearings_center_to_center + 2*b623_big_ugroove_small_r + 2*Eyelet_extra_dist - 31
              ]){
      translate([0,0,-3])
        M3_screw(h=50);
      translate([0,0.3,0])
        hull(){
          rotate([0,0,30])
            nut(h=2.5);
          translate([0,-10,0])
            rotate([0,0,30])
              nut(h=2.5);
        }

      translate([-3/2, -10, -3])
        cube([3, 10, 4]);
    }
  }

}

module top(){
  difference(){
    intersection(){
      eiffel();
      cutoff_cube();
    }
    vertical_screws();
    action_points();
  }
}

module top2(){
  difference(){
    intersection(){
      eiffel();
      translate([0,0,-3])
        cutoff_cube();
    }
    vertical_screws();
    action_points();
    cutoff_cube();
  }
}

module slit_core(width=0.801){
  translate([0,-30,line_action_lower_z + Corner_clamp_bearings_center_to_center + 2*(b623_big_ugroove_small_r+Eyelet_extra_dist) + 1])
    rotate([0,90,0])
      translate([0,0,-width/2])
        cube([Corner_clamp_bearings_center_to_center + 2*(b623_big_ugroove_small_r+Eyelet_extra_dist) + 1,20,width]);
}

//slit();
module slit(width=0.8){
  difference(){
    intersection(){
      eiffel();
      slit_core(width=width);
    }
    translate([0,0,-3])
      cutoff_cube();
    vertical_screws();
    action_points();
  }
}

newer_line_roller_anchor();
module newer_line_roller_anchor(){
  move_back = 1.5;
  difference(){
    union(){
      translate([-w/2, -l+Depth_of_roller_base/2, 0])
        rounded_cube2([w, l+(b608_vgroove_big_r*1.8-Depth_of_roller_base), base_th], 2, $fn=4*6);
      eiffel();
      translate([0,move_back,0])
        bullet_tower();
    }
    translate([0,Depth_of_roller_base/2, 0])
      screw_tracks();
    action_points();
    translate([0,0,-3])
      cutoff_cube();
    vertical_screws();

    slit_core();
    translate([0, slide_in_bullet+move_back, line_action_lower_z])
      rotate([0,-90,-90])
        cylinder(d=Stick_d, h=Stick_length-Stick_extra, $fn=4*5);
    for(k=[0,1]) mirror([k,0,0])
      translate([-w/2, 14+move_back, -1])
        rotate([0,0,-90])
          inner_round_corner(r=11, h=20, $fn=4*9);
  }

  bullet(for_print=false);


  //translate([-22, 0,-Corner_clamp_bearings_center_to_center-2*b623_big_ugroove_small_r - 2*Eyelet_extra_dist - line_action_lower_z])
    top();

  //translate([-22, -40.5, Corner_clamp_bearings_center_to_center + 2*b623_big_ugroove_small_r + 2*Eyelet_extra_dist + line_action_lower_z])
    //rotate([180,0,0])
      top2();

  //slit_w = 0.79;
  //translate([-42,-24, slit_w/2])
  //  rotate([0,90,90])
  //    slit(slit_w);
}

//difference(){
//  import("../stl/line_roller_anchor.stl");
//  for(k=[0,1]) mirror([k,0,0])
//    translate([3.2 + 1,
//               front+3.6/2+1.36/2,
//               line_action_lower_z + Corner_clamp_bearings_center_to_center + 2*b623_big_ugroove_small_r + 2*Eyelet_extra_dist - 31
//              ])
//      translate([-3/2, -10, -3])
//        cube([3, 10, 4]);
//}
