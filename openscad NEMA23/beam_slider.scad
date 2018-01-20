include <parameters.scad>
use <util.scad>
use <sweep.scad>

// Bends arms outwards, so pressure is distributed over beam flat-sides
beam_slider();
module beam_slider(){
  wall_th = Wall_th;
  h = 10;
  extra_length = 6;
  w = Fat_beam_width+2*wall_th;

  module arm(){
    difference(){
      clamp_wall(10);
      translate([Beam_width/2+3.5/2+2.4, 0, h/2])
        rotate([90,0,0])
        cylinder(d=3.5, h=w+10, center=true, $fs=1);
    }
  }
  arm();
  mirror([0,1,0])
    arm();
  translate([-wall_th-Fat_beam_width/2,-w/2,0])
    rounded_cube2([wall_th, w, h],1,$fn=4*4);
  // Hooks for line
  hook_h = 6;
  module hook(ang=2){
    translate([-2.5/2,w/2-1,h-1])
      rotate([-90,0,0])
      rounded_cube2([2.5, h-1, 2.5+2],0.8,$fn=4*4);
    translate([0,2+w/2+2.5/2,0])
      rotate([0,0,ang])
      translate([-hook_h/2,-2.5/2,0])
      rounded_cube([hook_h, 2.5, h],1,$fn=4*3);
  }
  rotate([0,0,90])
    hook(0);

  for(k=[0,1])
    mirror([0,k,0]){
      hook();
    }
}

