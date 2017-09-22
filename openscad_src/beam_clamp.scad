include <parameters.scad>
use <sweep.scad>
use <util.scad>

//%prev_art();
module prev_art(){
  translate([0,15+2*2.5,0])
    rotate([180,0,0])
    import("../stl/beam_clamp.stl");
}

beam_clamp();
module beam_clamp(){
  wall_th = Wall_th;
  l = 23;
  l2 = 30;
  h = Beam_width + 2*wall_th;
  little_r = 0.5;
  step = 15*little_r;
  function my_rounded_square(v, r) = [
    for (i=[0:step:360])
      i < 90 ?
      [r,r] - r*[cos(i), sin(i)] :
      i < 180 ?
      [v[0]-r,r] - r*[cos(i), sin(i)] :
      i < 270 ?
      [v[0]-r,v[1]-r] - r*[cos(i), sin(i)] :
      [r,v[1]-r] - r*[cos(i), sin(i)]];

  difference(){
    // Sweep up basic outline
    sweep(my_rounded_square([l,h],0.5),
      [translation([0,0,0]),
       translation([0,0,h]),
       translation([l2/2,0,h + l2*sqrt(3)/2])
       ]);
    // Cut top straight
    translate([l2/2, 0, h + l2*sqrt(3)/2])
      rotate([0,30,0])
      translate([-1,-1,0])
      cube(30);
    translate([-1, wall_th, wall_th])
      fat_beam(l+2);
    // Diggin out angled part
    translate([0,0,h])
      rotate([0,30,0])
      translate([wall_th,wall_th,-1]){
        fat_beam(l2+2, standing=true);
        m = 3.5;
        translate([-wall_th-1, m/2, -2])
          cube([Beam_width+2*wall_th+4, Beam_width - m, l2+4]);
      }
    // Slanting the inside
    ang = 8.5;
    lift = h-2.25;
    inwards = wall_th+0.25;
    for(i=[0,1]){
      y_tr = (i == 1) ? Beam_width+2*wall_th-inwards : inwards;
      translate([-1,y_tr,lift])
        rotate([ang*(2*i-1),0,0]){
          mirror([0,i,0])
          translate([0,0,-1])
          cube([10,wall_th,30]);
          translate([l-2*wall_th,0,-1])
            mirror([0,i,0])
            cube([10,wall_th,30]);
        }
    }
    // Screw holes
    translate([l/2, -1, h/2])
      rotate([-90,0,0])
      cylinder(d=3.2, h=2*(Fat_beam_width + wall_th) + 2, $fs=1);
    translate([l/3, -1, h + 4])
      rotate([-90,0,0])
      cylinder(d=3.2, h=2*(Fat_beam_width + wall_th) + 2, $fs=1);
    translate([0,0,h])
      rotate([0,30,0])
      translate([h/2, -1, l2-h/2])
      rotate([-90,0,0])
      cylinder(d=3.2, h=2*(Fat_beam_width + wall_th) + 2, $fs=1);
  }
}

