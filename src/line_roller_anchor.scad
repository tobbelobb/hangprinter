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
module bullet(for_print=false) {
  if (!for_print) {
    translate([0,-15.5,line_action_lower_z])
      rotate([0,-90,-90])
        bearing_holder(backwall=true);
  } else {
    translate([0,23,0])
      rotate([0,0,90])
      bearing_holder(backwall=true);
  }
}

module bullet_tower() {
  translate([0,-15.5,line_action_lower_z])
    bearing_holder_holder(backwall=true);
}


//color("lightgrey")
//translate([-40,0,0])
//import("../stl/line_roller_anchor.stl");
//!tower();
module tower(tilt=10) {
  rotate([0,tilt-90,0]) {
    translate([b608_vgroove_small_r + Eyelet_extra_dist,0,0]){
      %b608_vgroove();
      //import("../stl/bearing_u_608.stl");
      down_from_top = 3;
      shoulder = 0.5;
      difference() {
        union() {
          difference() {
            translate([-b608_vgroove_big_r-3.6, -Depth_of_roller_base/2, -b608_width/2-shoulder-Line_roller_wall_th])
              right_rounded_cube2([b608_vgroove_big_r*2+6, b608_vgroove_big_r*1.8, Line_roller_wall_th*2 + shoulder*2 + b608_width], 2, $fn=6*4);
            difference(){
              translate([-Depth_of_roller_base+down_from_top,-Depth_of_roller_base/2,-b608_width/2-shoulder-Line_roller_wall_th])
                translate([-2, -4, Line_roller_wall_th])
                  cube([b608_vgroove_big_r*3, b608_vgroove_big_r*1.8+3, b608_width + 2*shoulder]);
              translate([12,-20,-20])
                translate([0,0,20])
                  rotate([0,-tilt,0])
                    translate([0,0,-20])
                      cube(40);
            }
            rotate([0,0,54])
              translate([b608_vgroove_small_r + Eyelet_extra_dist,0,0])
                rotate([90,0,0])
                  scale([1.2,1,1])
                    cylinder(d1=0.4, d2=29.4, h=18);
            // Take off sharp edge so we don't rub into bearing U
            translate([-2, -b608_vgroove_small_r-4,0])
              rotate([0,0,54])
                translate([b608_vgroove_small_r + Eyelet_extra_dist, 0,0])
                  rotate([90,0,0])
                    scale([1.2,1,1])
                      cylinder(d1=2.4, d2=35.4, h=18);
          }
          translate([0,0,b608_width/2])
            cylinder(h=shoulder+1, d=10, $fn=4*6);
          translate([0,0,-b608_width/2-shoulder-1])
            cylinder(h=shoulder+1, d=10, $fn=4*6);
        }
        translate([0,0,-b608_width/2-shoulder-Line_roller_wall_th-0.1]) {
          translate([0,0,b608_width+2*shoulder+2*Line_roller_wall_th-1.5])
          M8_nut(2);
          M8_screw(h=20);
          translate([0,0,-0.5])
            M8_nut(2);
        }
      }
    }
  }
  translate([9.0,0,-1.97])
    rotate([90,0,0])
      translate([0,0,-Depth_of_roller_base/2-(b608_vgroove_big_r*1.8-Depth_of_roller_base)])
        rotate([0,0,-tilt/2])
          inner_round_corner(r=2, h=b608_vgroove_big_r*1.8, ang=90+tilt, back=1, $fn=7*4);
  translate([-9.1,0,-2.15])
    rotate([90,0,0])
      translate([0,0,-Depth_of_roller_base/2-(b608_vgroove_big_r*1.8-Depth_of_roller_base)])
        rotate([0,0,90])
          inner_round_corner(r=3, h=b608_vgroove_big_r*1.8, ang=90-tilt, back=1, $fn=8*4);
}

w = 27;
l = 37;
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
    translate([w_small+1,2])
    circle(r=2, $fn=4*6);
    translate([-1,2])
    circle(r=2, $fn=4*6);
    translate([0,7])
    circle(r=2, $fn=4*6);
    translate([w_small,7])
    circle(r=2, $fn=4*6);
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
          translate([0,0,Corner_clamp_bearings_center_to_center + 2*b623_big_ugroove_small_r + 2*Eyelet_extra_dist + 5])
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
module newer_line_roller_anchor(tilt=10){
  difference(){
    union(){
      translate([-w/2, -l+Depth_of_roller_base/2, 0])
        rounded_cube2([w, l+(b608_vgroove_big_r*1.8-Depth_of_roller_base), base_th], 2, $fn=4*6);
      eiffel();
      //translate([0,0,line_action_lower_z])
      //  tower(tilt);
      bullet_tower();
    }
    translate([0,Depth_of_roller_base/2, 0])
      screw_tracks();
    action_points();
    translate([0,0,-3])
      cutoff_cube();
    vertical_screws();

    slit_core();
    translate([0,-15.5,line_action_lower_z])
      rotate([0,-90,-90])
        cylinder(d=Stick_d, h=Stick_length-Stick_extra);
  }

  bullet(for_print=true);


  translate([-22, 0,-Corner_clamp_bearings_center_to_center-2*b623_big_ugroove_small_r - 2*Eyelet_extra_dist - line_action_lower_z])
    top();

  translate([-22, -40.5, Corner_clamp_bearings_center_to_center + 2*b623_big_ugroove_small_r + 2*Eyelet_extra_dist + line_action_lower_z])
    rotate([180,0,0])
      top2();

  slit_w = 0.79;
  translate([-42,-24, slit_w/2])
    rotate([0,90,90])
      slit(slit_w);
}
