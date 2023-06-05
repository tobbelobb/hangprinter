include <lib/parameters.scad>
use <lib/util.scad>

wasp_extruder_xl30();
module wasp_extruder_xl30(){
  // Gearbox
  cylinder(d=36, h=22.6 + 1);
  // Motor spacer
  difference() {
    translate([-20,-20,22.6])
      cube([40,40,5.3]);
    for(ang = [0, 90, 180, 270])
      rotate([0,0,45 + ang])
        translate([10*2*sqrt(2) - 3, -5, 22.6 - 1])
          cube(10);
  }
  // Motor
  translate([0,0,59 + 22.6 + 5.3])
    rotate([180,0,0])
      Nema17(ch=59);
  // Fan bracket
  translate([-22.4 - Nema17_cube_width/2 + 12, -Nema17_cube_width/2, 22.6 - 2]) {
    cube([22.4, Nema17_cube_width, 2]);
    cube([2,Nema17_cube_width, 67]);
    translate([0, -19/2 + Nema17_cube_width/2, 67 + 6])
      cube([2, 19, 5]);
    translate([0, -7.5/2 + Nema17_cube_width/2, 67 - 1])
      cube([2, 7.5, 7]);
  }
  // Fan
  color("black")
    translate([-20 -22.4 - Nema17_cube_width/2 + 12, -20, 21 + 22.6 -2])
      cube([20, 40, 40]);
  // Widest metal ring above inlet
  translate([0,0,-22.2])
    cylinder(d=58.3, h=22.2);
  // Largest blue part
  color("blue")
    difference() {
      translate([0,0,-22.2-98.3])
        cylinder(d=46, h=98.3, $fn=12*4);
      translate([46/2 - 10.58, -38.6/2, -22.2-80.4])
        cube([30,38.6,58.45]);
    }
  // Inlet
  translate([46/2 - 10.58, -35.4/2, -22.2-80.4 + (58.45-56.9)/2]){
    cube([6.75, 35.4, 56.9]);
  }
  translate([46/2 - 10.58 + 6.75, 0, -22.2-80.4 + (58.45-56.9)/2])
    translate([33.9,0,0])
      rotate([90,0,180]) {
        rotate_extrude(angle=90) {
          translate([21.9/2 + 35, 0, 0])
            circle(d=21.9);
        }
        translate([0, 21.9/2 + 35, 0])
          rotate([0,-90, 0]) {
            cylinder(d=21.9, h=16);
            translate([0,0,8])
               cylinder(d=27, h=28.5);
          }
      }
  // Hexagonal plate
  translate([0,0,-22.2-98.3-4])
    cylinder(d=65.7, h=4, $fn=6);
  // Small blue cylinder
  color("blue")
    translate([0,0,-22.2-98.3-4-26.4])
      cylinder(d=32, h=26.4);
  // Large nut
  translate([0,0,-22.2-98.3-4-26.4-13.5])
    cylinder(d=34, h=13.5, $fn=6);
  // Funnel shaped part of nozzle
  difference(){
    union(){
      translate([0,0,-22.2-98.3-4-26.4-13.5-11.11])
        cylinder(d=26.3, h=11.11);
      translate([0,0,-22.2-98.3-4-26.4-13.5-11.11 - 18.59])
        cylinder(d2=Wasp_xl30_funnel_d2, d1=Wasp_xl30_funnel_d1, h=Wasp_xl30_funnel_h);
      translate([0,0,-22.2-98.3-4-26.4-13.5-11.11 - Wasp_xl30_funnel_h - 11.8])
        cylinder(d=Wasp_xl30_funnel_d1, h=11.8);
    }
    for(k = [0,1]) mirror([k, 0, 0])
      translate([24/2,-10,-200])
        cube([20, 20, 40]);
  }
}

translate([0,0,-194])
  color("black")
    wasp_extruder_xl30_bottom_holder();
module wasp_extruder_xl30_bottom_holder() {
  wall_th = 3;
  difference() {
    union() {
      translate([0,0,0.05])
        cylinder(d1=Wasp_xl30_funnel_d1+2*wall_th, d2=Wasp_xl30_funnel_d2+2*wall_th, h=Wasp_xl30_funnel_h-0.1);
      for(ang = [0, 120, 240]) rotate([0,0,ang])
      translate([Wasp_xl30_funnel_d2/2 + 10/2, 0, Wasp_xl30_funnel_h])
        rotate([90,0,0]) {
          difference(){
            union(){
              cylinder(h=wall_th, d=10, center=true);
              rotate([0,0,-90-atan((Wasp_xl30_funnel_d2/2 - Wasp_xl30_funnel_d1/2) / Wasp_xl30_funnel_h) - 19])
              translate([0,-6/2,-wall_th/2])
                cube([21, 8, wall_th]);
            }
            cylinder(h=wall_th+2, d=4, center=true);
          }
        }
    }
    cylinder(d1=Wasp_xl30_funnel_d1, d2=Wasp_xl30_funnel_d2, h=Wasp_xl30_funnel_h);
    translate([0,0,Wasp_xl30_funnel_h-0.01])
      cylinder(d=Wasp_xl30_funnel_d2, h=Wasp_xl30_funnel_h);
  }
}

//!rotate([180,0,0])
color("black")
wasp_extruder_xl30_top_holder();
module wasp_extruder_xl30_top_holder() {
  translate([-22.4 - Nema17_cube_width/2 + 12 + 2, -Nema17_cube_width/2, 22.6 - 2 + 67 - 9.5/2 - 9.8]) {
    difference(){
      union(){
        cube([3.5, Nema17_cube_width, 10.5]);
        rotate([90,0,-60])
          translate([0,0,-3.5])
            difference(){
              right_rounded_cube2([13, 10.5, 3.5], r=2);
              translate([13-4/2-2,10.5/2,-1])
                cylinder(d=4, h=3.5+2);
            }
        translate([0,Nema17_cube_width,0])
          rotate([90,0,60])
            difference(){
              right_rounded_cube2([13, 10.5, 3.5], r=2);
              translate([13-4/2-2,10.5/2,-1])
                cylinder(d=4, h=3.5+2);
            }

      }
      translate([-1, Nema17_cube_width/2, -40/2+10.5-1])
        rotate([0,90,0])
          cylinder(d=40, h=10.5+2);
      // Super thin part
      translate([20/2+1.5, Nema17_cube_width/2, 0])
        rotate([0,0,0])
          cylinder(d=20, h=10.5+2);
      translate([-1,Nema17_cube_width/2 - 32/2, 10.5-4.3/2-1.5])
        rotate([0,90,0])
          cylinder(d=4.3, h=10.5+2);
      for (k = [-1,1])
        translate([-1,Nema17_cube_width/2 + k*32/2, 10.5-4.3/2-1.5])
          rotate([0,90,0])
            cylinder(d=4.3, h=10.5+2);
    }
  }
}

