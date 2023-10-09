include <lib/parameters.scad>
use <lib/util.scad>
use <lib/gears.scad>
use <GT2_spool_gear.scad>
use <motor_bracket_A.scad>
use <sep_disc.scad>
use <spool.scad>
use <spool_cover.scad>

%sandwich_for_render_with_reciprocating_wheel();
module sandwich_for_render_with_reciprocating_wheel() {
  stls = true;
  translate([0,0,Sep_disc_radius + Gap_between_sandwich_and_plate]) {
    // GT2 spool gear
    translate([0,0.25,0])
    translate([0,Spool_height/2, 0])
      rotate([90,0,0])
        if(stls) import("../stl/GT2_spool_gear.stl");
        else GT2_spool_gear();
    // Spools
    for(k=[0,1]) mirror([0,k,0])
      translate([0,Spool_height+Torx_depth+1, 0])
        rotate([90,0,0])
          if(stls) import("../stl/spool_mirrored.stl");
          else spool_mirrored();
  }
}

//reciprocating_eyelet();
module reciprocating_eyelet() {
  translate([50,-Spool_height/2+$t*Spool_height,10+4/2])
  translate([0,-GT2_gear_height/2 - Spool_height/2 - 0.15, 0])
    rotate([0,90,0])
      difference(){
        eyelet(4, center=true);
        cylinder(d=2.5, h=10, center=true, $fn=10);
      }
}

//for(k=[0,1]) mirror([0,k,0]){
//  reciprocating_thread(rot=k*180);
//}
module reciprocating_thread(rot=0) {
  translate([50,0,10/2])
    translate([0,-GT2_gear_height/2 - Spool_height/2 - 0.15, 0])
      rotate([90,0,0])
        rotate([0,0,$t*360 + rot])
        difference(){
          cylinder(d=10, h=Spool_height+10, center=true);
          for(k=[0,1]) mirror([0,k,0])
          translate([0,0,-Spool_height/2])
            linear_extrude(height=Spool_height, twist=1*180){
              translate([3.5,-3/2])
                square([5,3]);
          }
        }
}

opening = 8;

translate([52,0,Gap_between_sandwich_and_plate + (Sep_disc_radius - Spool_r)])
my_rack();
module my_rack() {
  modul=0.57;

  //translate([0,sin(360*$t)*(Spool_height/2-1),0])
  difference(){
    translate([0,0,-opening/2]) {
      for(k=[0,1]) mirror([0,0,k])
      translate([0,0,-opening*k])
      rotate([90,0,90]) {
        rack(modul=modul, length=Spool_height, height=5, width=2, pressure_angle=20, helix_angle=0);
        translate([-(Sandwich_ABCD_width-2)/2,-5.1,0])
          rounded_cube2([Sandwich_ABCD_width-2,4,2], r=2);
        translate([-(Sandwich_ABCD_width-2)/2,-5.1,0])
          rounded_cube2([7.1,opening+5.1+0.1,2], r=2);
        mirror([1,0,0])
          translate([-(Sandwich_ABCD_width-2)/2,-5.1,0])
            rounded_cube2([7.1,opening+5.1+0.1,2], r=2);
      }
      for(mirr=[0,1]) mirror([0,mirr,0])
        rotate([90,0,90])
          mirror([1,0,0])
            translate([-(Sandwich_ABCD_width-2)/2,-1,-12])
              rounded_cube2([7.1,8,14], r=2);
    }
    for(mirr=[0,1]) mirror([0,mirr,0]){
      translate([-0.1,-Sandwich_ABCD_width/2+1+Spool_height/2, 0])
        rotate([0,90,0]){
          eyelet(2.2,center=false);
          cylinder(d=2, h=27, center=true);
          translate([0,0,-12])
            eyelet(2,center=false);
        }
      translate([-5.1, -(Spool_height-2)/2, 0])
        rotate([0,90,0]){
          cylinder(d=8, h=5);
        }
      translate([-5.1, -9/2, 5.4])
        rotate([0,90,0]){
          hull(){
            cylinder(d=8, h=5);
            translate([0,-Spool_height,0])
              cylinder(d=8, h=5);
          }
        }
    }
  }

  rotate([90-360/12/2,0,0])
  translate([0,0,0])
  rotate([90,0,90])
  rotate([0,0,360/12/2]) {
    difference(){
      rotate([0,0,360/12/2]){
        translate([0,0,-2])
color("yellow", 0.5)
        spur_gear(modul=modul, tooth_number=12, width=4, bore=3, pressure_angle=20, helix_angle=0, optimized=false);
      }
      translate([0,-10,-1])
        cube(20);
      rotate([0,0,360/12])
        translate([0,-10,-1])
          cube(20);
    }
    translate([0,0,-4])
      rotate([0,0,360/12/2]){
color("yellow", 0.5)
        spur_gear(modul=modul, tooth_number=12, width=2, bore=3, pressure_angle=20, helix_angle=0, optimized=false);
      }
  }
  rotate([90,0,0])
  translate([0,5.4,-GT2_gear_height/2])
  rotate([90,0,90])
  translate([0,0,-4])
color("yellow", 0.5)
    spur_gear(modul=modul, tooth_number=11, width=3, bore=3, pressure_angle=20, helix_angle=0, optimized=false);
}

color("red", 0.5)
slide_frame();
module slide_frame() {
  translate([52,0,0])
    translate([-7.5,-Spool_height,0])
      cube([10.5, 2*Spool_height, 3]);
  translate([52,0,0])
    translate([-7.5,-Spool_height/4,0])
      cube([3, Spool_height/2, opening+5.1+2]);
    difference(){
      translate([52,0,0])
        translate([-7.5,-Spool_height,opening+5.1+0.4])
          cube([10.5, 2*Spool_height, 7]);
      translate([0,0,Gap_between_sandwich_and_plate + Sep_disc_radius])
        rotate([90,0,0])
          cylinder(r=Sep_disc_radius+1, h=Sandwich_ABCD_width, center=true);
      translate([52,0,0])
        translate([-1.5,-Spool_height-1,opening+2])
          cube([10.5, 2*Spool_height+2, 7]);
      translate([51.5,0,0])
        translate([-4.2, 9/2, opening+5.1+2])
          rotate([0,90,0])
            hull(){
              cylinder(d=9, h=5);
              translate([-5,0,0])
                cylinder(d=9, h=5);
            }
    }
}
