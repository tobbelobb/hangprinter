include <lib/parameters.scad>
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

line_action_lower_z = 9.15;
module tower() {
  tilt=10;
  rotate([0,tilt-90,0]) {
    translate([b623_vgroove_small_r + Eyelet_extra_dist,0,0]){
      %b623_vgroove();
      down_from_top = b623_vgroove_big_r+b623_vgroove_room_to_grow_r+2;
      shoulder = 0.5;
      difference() {
        union() {
          difference() {
            translate([-Depth_of_roller_base+down_from_top-1, -Depth_of_roller_base/2, -b623_width/2-shoulder-Line_roller_wall_th])
              right_rounded_cube2([Depth_of_roller_base+1, Depth_of_roller_base, Line_roller_wall_th*2 + shoulder*2 + b623_width], 2, $fn=6*4);
            translate([-Depth_of_roller_base+down_from_top,-Depth_of_roller_base/2,-b623_width/2-shoulder-Line_roller_wall_th])
              translate([-2, -4, Line_roller_wall_th])
                cube([Depth_of_roller_base, Depth_of_roller_base+2, b623_width + 2*shoulder]);
            rotate([0,0,45])
              translate([b623_vgroove_small_r + Eyelet_extra_dist,0,0])
                rotate([90,0,0])
                  cylinder(d1=0.3, d2=21.15, h=16);
          }
          translate([0,0,b623_width/2])
            cylinder(h=shoulder+1, d=5, $fn=4*6);
          translate([0,0,-b623_width/2-shoulder-1])
            cylinder(h=shoulder+1, d=5, $fn=4*6);
        }
        translate([0,0,-b623_width/2-shoulder-Line_roller_wall_th-0.1]) {
          translate([0,0,b623_width+2*shoulder+2*Line_roller_wall_th-1.5])
          nut(2);
          M3_screw(h=20);
          translate([0,0,-0.5])
            nut(2);
        }
      }
    }
  }
  translate([7.45,0,-1.97])
  rotate([90,0,0])
  translate([0,0,-Depth_of_roller_base/2])
  rotate([0,0,-tilt/2])
  inner_round_corner(r=2, h=Depth_of_roller_base, ang=90+tilt, back=1, $fn=7*4);
  translate([-7.49,0,-2.15])
  rotate([90,0,0])
  translate([0,0,-Depth_of_roller_base/2])
  rotate([0,0,90])
  inner_round_corner(r=3, h=Depth_of_roller_base, ang=90-tilt, back=1, $fn=8*4);
}

w = 27;
l = 35;
front = -l+Depth_of_roller_base/2;
module action_points(){
  translate([0, front+4.5, b623_vgroove_small_r + Eyelet_extra_dist + line_action_lower_z]){
    translate([0,15, 0 - b623_vgroove_small_r - Eyelet_extra_dist])
      rotate([90,90,0]){
        eyelet(h=20);
      }
    translate([0,-3, Corner_clamp_bearings_center_to_center + b623_vgroove_small_r + Eyelet_extra_dist])
      rotate([90,0,0]){
        cylinder(h=3, d=0.5);
      }
  }
}

//cutoff_cube();
module cutoff_cube(){
  translate([0, front+4.5, b623_vgroove_small_r + Eyelet_extra_dist + line_action_lower_z])
    translate([0,0, Corner_clamp_bearings_center_to_center + b623_vgroove_small_r + Eyelet_extra_dist])
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

module eiffel(){
  translate([-w_small/2, front, 7-0.1])
    union(){
      hull(){
        linear_extrude(height=0.1)
        hull() {
          translate([w_small/2+w/2-2,2])
          circle(r=2, $fn=4*6);
          translate([-6.5,2])
          circle(r=2, $fn=4*6);
          translate([-6.5,13])
          circle(r=2, $fn=4*6);
          translate([w_small/2+w/2-2,13])
          circle(r=2, $fn=4*6);
        }
        mid_section();
      }
      hull(){
        mid_section();
        translate([0,0,Corner_clamp_bearings_center_to_center + 2*b623_vgroove_small_r + 2*Eyelet_extra_dist + 5])
        linear_extrude(height=0.1)
        hull() {
          translate([w_small-1.5,2])
          circle(r=2, $fn=4*6);
          translate([1.5,2])
          circle(r=2, $fn=4*6);
          translate([w_small-1.5,2.5])
          circle(r=2, $fn=4*6);
          translate([1.5,2.5])
          circle(r=2, $fn=4*6);
        }
      }
    }
}

module vertical_screws(){
  for(k=[0,1]) mirror([k,0,0]) {
    translate([3.2,front+3.3/2+1.36/2,7+Corner_clamp_bearings_center_to_center-7]){
      M3_screw(h=30);
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

newer_line_roller_anchor();
module newer_line_roller_anchor(){
  difference(){
    union(){
      translate([-w/2, -l+Depth_of_roller_base/2, 0])
        rounded_cube2([w, l, 7], 2, $fn=4*6);
      eiffel();
      translate([0,0,line_action_lower_z])
        tower();
    }
    translate([0,Depth_of_roller_base/2, 0])
      screw_tracks();
    action_points();
    cutoff_cube();
    vertical_screws();
  }
}

translate([-22, 0,-Corner_clamp_bearings_center_to_center-2*b623_vgroove_small_r - 2*Eyelet_extra_dist - line_action_lower_z])
top();
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
