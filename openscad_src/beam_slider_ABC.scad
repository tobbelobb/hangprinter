include <parameters.scad>
use <util.scad>

// Bends arms outwards, so pressure is distributed over beam flat-sides
beam_slider_ABC();
module beam_slider_ABC(){
  wall_th = Wall_th;
  h = 10;
  extra_length = 6;
  w = Min_beam_width + wall_th;

  translate([-w/2,-w/2,0])
    rounded_cube2([w, wall_th, h],1,$fn=4*4);
  translate([-w/2,-w/2,0])
    rounded_cube2([wall_th, w, h],1,$fn=4*4);
  // Hooks for line
  difference(){
  translate([-w/2+4-Zip_th,0,0])
    rotate([0,0,90]){
      translate([-2.5/2,0,h])
        rotate([-90,0,0])
        rounded_cube2([2.5, h, 4+2.5/2],0.8,$fn=4*4);
      translate([-6/2,4,0])
        rounded_cube([6, 2.5, h],1,$fn=4*3);
    }
    translate([-Zip_th+0.005-w/2,-wall_th/2 -1,(h-Zip_w)/2])
      cube([Zip_th-0.005, wall_th+2, Zip_w]);
  }
}

