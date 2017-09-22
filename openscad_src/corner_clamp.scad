include <parameters.scad>
use <sweep.scad>
use <util.scad>

//prev_art();
module prev_art(){
  translate([0,-Wall_th-Beam_width/2,25])
    import("../stl/corner_clamp.stl");
}

corner_clamp();
module corner_clamp(){
  little_r = 3/2;
  big_r = 9.35;
  step = 3;
  l = 72.75;

  function my_rounded_eqtri(l, r) = [
    for (i=[-30:step:360-30.01])
      (i < 120 - 30) ?
      [r*sqrt(3),r] - r*[cos(i), sin(i)] :
      (i < 240 - 30) ?
      [l-r*sqrt(3),r] - r*[cos(i), sin(i)] :
      [l/2,sqrt(3)*l/2-r*2] - r*[cos(i), sin(i)]];

  difference(){
    rotate([90,0,0])
      sweep(my_rounded_eqtri(l,big_r),
          [for(i=[-little_r:2*little_r/20:little_r])
          scaling([1+little_r*sqrt(1-i*i/(little_r*little_r))/(l*sqrt(3)/6),
            1+little_r*sqrt(1-i*i/(little_r*little_r))/(l*sqrt(3)/6), 1])
          * translation([0,0,i])
          * translation([-l/2,-l*sqrt(3)/6,0])
          ]);
    translate([0,0,-10])
      cube([l, 30, 38+2*10], center=true);
  }
}
