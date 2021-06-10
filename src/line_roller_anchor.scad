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

module side_rounders(ydepth){
  for(k=[0,1])
    mirror([k,0,0])
      translate([101,1,57])
      rotate([90,0,0])
      cylinder(r=100, h=ydepth+3, $fn=200);
}

module screw_holes(s){
  translate([0,Front_bearing_x-Back_bearing_x-9,Lower_bearing_z])
    rotate([0,90,0]){
    cylinder(d=3.3, h=49, center=true, $fn=12);
    for(k=[0,1])
      mirror([0,0,k])
        translate([0,0,s/2+3])
        nut(20);
  }
  translate([0,Back_bearing_x-Back_bearing_x-9,Higher_bearing_z])
    rotate([0,90,0]){
    cylinder(d=3.3, h=49, center=true, $fn=12);
    for(k=[0,1])
      mirror([0,0,k])
        translate([0,0,s/2+2])
        nut(20);
  }
  // thread hole
  translate([0,Front_bearing_x-Back_bearing_x-9-1,Higher_bearing_z-3])
    rotate([0,90,0])
    cylinder(d=2, h=49, center=true, $fn=12);
}

rotate([-90,0,0])
new_line_roller_anchor();
module new_line_roller_anchor(){
  s = b623_width + 0.8;
  tower_h = Higher_bearing_z + b623_vgroove_big_r;
  ydepth = b623_vgroove_big_r*4+9;
  difference(){
    scale([0.7, 1,1])
      rotate([90,0,0])
      rounded_eqtri(48, ydepth, 2.2, $fn=12*4);
    for(k=[0,1])
      mirror([k,0,0])
        translate([6,-5,-0.1])
        rotate([0,0,-90])
        screw_track(100);
    translate([-s/2, -ydepth-1, 10])
      cube([s, ydepth+2, 50]);
    translate([0,1,6.5])
      scale([0.45, 0.45/0.7, 0.44/0.7])
        rotate([90,0,0])
        rounded_eqtri(44, ydepth+20, 3, $fn=12*4);
    translate([-5, -ydepth-1, Higher_bearing_z+5.5])
      cube([10, ydepth+2, 7]);
    side_rounders(ydepth);
    screw_holes(s);
  }
  difference(){
    union(){
      for(k=[0,1])
        mirror([k,0,0]){
          translate([s/2-0.4,Back_bearing_x-Back_bearing_x-9, Higher_bearing_z])
          rotate([0,90,0])
            cylinder(d=5.5, h=2, $fn=12*5);
          translate([s/2-0.4,Front_bearing_x-Back_bearing_x-9, Lower_bearing_z])
          rotate([0,90,0])
            cylinder(d=5.5, h=2, $fn=12*5);
        }
      translate([-(b623_width+5)/2, -5-ydepth/2+1, Higher_bearing_z+0.5])
        cube([b623_width+5, 5, 5]);
      translate([0,-Back_bearing_x-9, 0]){
        translate([0,Back_bearing_x, 0])
          rotate([0,0,90])
          preventor_edges(Higher_bearing_z+Depth_of_roller_base/2,
              s, false, -79, 68, back1=4, back2=2.7);
        translate([0,Front_bearing_x, 0])
          rotate([0,0,90])
          preventor_edges(Lower_bearing_z+Depth_of_roller_base/2,
              s, false, -17, 100);
        the_r = b623_vgroove_small_r+2.5;
        translate([0,1.5,0])
          for(k=[0,1])
            mirror([k,0,0])
              translate([s/2,Front_bearing_x, Lower_bearing_z])
              rotate([0,90,0]){
                cylinder(r=the_r, h=2, $fn=12*5);
                rotate([0,0,-45])
                  translate([-the_r,0,0])
                  cube([2*(the_r),20, 2]);
              }
        the_r2 = b623_vgroove_small_r+3.7;
      }
    }
    translate([-50,0,0])
      cube(100);
    translate([-5, -ydepth-1, Higher_bearing_z+5.5])
      cube([10, ydepth+2, 7]);
    translate([-5, -ydepth-1, -50])
      cube([10, ydepth+2, 56]);
    side_rounders(ydepth);
    screw_holes(s);
  }
  scale([1.2,1,1])
  translate([0,-Back_bearing_x-9, 0])
    translate([0, Front_bearing_x, Higher_bearing_z])
    difference(){
      rotate([0,90,0])
        b623_vgroove();
      translate([0,0,-4])
      rotate([90,0,0])
        difference(){
          cylinder(d=5.6, h=7, $fn=24);
          translate([0,0,-1])
            cylinder(d=3.2, h=9, $fn=25);
        }
    }
}

//translate([0,-Back_bearing_x-9, 0])
//the_bearings();
module the_bearings(){
  translate([0, Front_bearing_x, Lower_bearing_z])
    rotate([0,90,0])
    b623_vgroove();
  translate([0, Back_bearing_x, Higher_bearing_z])
    rotate([0,90,0])
    b623_vgroove();
  translate([0, Front_bearing_x, Higher_bearing_z])
    rotate([0,90,0])
    color("white")
    b623_vgroove();
}
