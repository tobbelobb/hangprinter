include <parameters.scad>
use <util.scad>
use <sweep.scad>

//%prev_art();
module prev_art(){
  //translate([0,15+2*2.5,0])
    rotate([0,0,-90])
    import("../stl/linetensioner.stl");
}

//beam_slider();
module beam_slider(){
  wall_th = Wall_th;
  h = 10;
  extra_length = 6;
  w = Beam_width+2*wall_th;
  difference(){
    translate([-Beam_width/2 - wall_th, -Beam_width/2 - wall_th, 0])
      cube([w+extra_length, w, h]);
    translate([-Fat_beam_width/2, -Fat_beam_width/2, -1])
      cube([Fat_beam_width+extra_length+wall_th+1, Fat_beam_width, h+2]);
    translate([Beam_width/2+3.5/2+2, 0, h/2])
      rotate([90,0,0])
      cylinder(d=3.5, h=w+2, center=true, $fs=1);
  }
}

// Bends arms outwards, so pressure is distributed over beam flat-sides
beam_slider2();
module beam_slider2(){
  wall_th = Wall_th;
  h = 10;
  extra_length = 6;
  w = Beam_width+2*wall_th;

  module arm(){
    function my_sq(v) =
      [[0,0], [v[0],0], [v[0], v[1]], [0, v[1]]];
    difference(){
      union(){
        sweep(my_sq([h, wall_th]),
          [for(i=[0.2:0.3:w+extra_length])
            translation([w/2+extra_length-i,
            // Bend arm outwards, following a log graph
            -w/2 - 1.5*(log(1+w+extra_length) - log(1+i)), 0])
            * rotation([0, -90, 0])
            // Round off tip of arm...
            * translation([0,2*wall_th/3,0])
            * scaling([1, (i < 3) ? log(1 + 9*i/3) : 1, 1])
            * translation([0,-2*wall_th/3,0])]);
        rotate([0,0,-4])
          translate([Fat_beam_width/2+0.9,-Fat_beam_width/2-wall_th,0])
          scale([1.3,1,1])
          standing_ls_tri(wall_th+1.4, h);
      }
      translate([Beam_width/2+3.5/2+2.4, 0, h/2])
        rotate([90,0,0])
        cylinder(d=3.5, h=w+10, center=true, $fs=1);
    }
  }
  arm();
  mirror([0,1,0])
    arm();
  translate([-wall_th-Beam_width/2,-w/2,0])
    cube([wall_th, w, h]);
}

