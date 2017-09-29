include <parameters.scad>
include <lineroller_parameters.scad>
use <sweep.scad>
use <util.scad>
use <lineroller_ABC_winch.scad>

//translate([0,30,0])
//%prev_art();
module prev_art(){
  import("../stl/tension_gauge.stl");
}

base_w = Bearing_width/2+Lineroller_wall_th+1;

module base_tension_gauge(base_th = 2, flerp0 = 7, flerp1 = 4){
  l = d + 2*Bearing_r + 2*Bearing_wall + flerp0 + flerp1;
  translate([-d/2-flerp0, -d/2, 0])
    difference(){
      rounded_cube2([l, d, base_th], d/2, $fn=10*4);
        for(x=[l - (d/2-1)])
          translate([x, d/2, -1])
            cylinder(d=4, h=base_th+2, $fs=1);
    }

  translate([-22,base_w-3,0])
  rounded_cube2([13,11,base_th],2, $fn=4*4);
}

tension_gauge();
module tension_gauge(){
  gap = -Bearing_wall-Bearing_r+2*Bearing_small_r;
  h = Tower_h-Bearing_r-Bearing_wall;

  for(k=[0,1])
    mirror([k,0,0])
      translate([gap,0,0])
        lineroller_ABC_winch(edge_start=0, the_wall=false) base_tension_gauge();

  difference(){
    for(k=[0,1])
      mirror([0,k,0])
        translate([-gap-1, d/2 - Lineroller_wall_th, 0])
        cube([2*gap+2,Lineroller_wall_th, h]);
    translate([0,0,h])
      rotate([90,0,0])
      cylinder(r=gap, h=d+1, center=true, $fn=30);
  }

  end = h + 2.5*(Bearing_r + Bearing_wall);
  maxl = 20*(1-0.7*sin(4*floor(end)));
  leg_gap = 3.3;

  module spring(){
    upw = 4.5;
    sweep([[-10,-Lineroller_wall_th/2], [10, -Lineroller_wall_th/2], [10, Lineroller_wall_th/2], [-10,Lineroller_wall_th/2]],
      [for(i=[0:end])
        translation([ 0 ,
         i < Lineroller_wall_th ? 2 : 0
         , 0])
        * translation([0,
         i < (h+upw)/2 ?
         -Lineroller_wall_th/2 - d/2 - leg_gap - 0.4*i:
         i < (h+upw) ?
           -Lineroller_wall_th/2 - d/2 - leg_gap - 0.4*(h+upw) + 0.4*i:
           -Lineroller_wall_th/2 - d/2 - leg_gap - 0.4*(h+upw) + 0.4*(h+upw)
         ,i])
         * scaling([
         1-0.7*sin(4*i)
         ,
         i < Lineroller_wall_th ? 3 : 1
         ,1])]);
  }

  module leg(){
    sweep([[-10,-Lineroller_wall_th/2], [10, -Lineroller_wall_th/2], [10, Lineroller_wall_th/2], [-10,Lineroller_wall_th/2]],
        [for(i=[0:end])
        translation([0,
        i < 3 ?
        Lineroller_wall_th/2+d/2+leg_gap + Lineroller_wall_th/2 :
        Lineroller_wall_th/2+d/2+leg_gap
        ,i])
        * scaling([
          i < 90/4 ?
          0.3 :
          1-0.7*sin(4*(i))
          ,
          i < 3 ?
          2.0 : 1
          ,1])]);
  }

  difference(){
    union(){
    spring();
    leg();
    translate([-maxl/2, -d/2 - leg_gap - Lineroller_wall_th, floor(end)-0.1])
      cube([maxl/4, d + 2*leg_gap + 2*Lineroller_wall_th, 2*Lineroller_wall_th]);
    translate([maxl/4, -d/2 - leg_gap - Lineroller_wall_th, floor(end)-0.1])
      cube([maxl/4, d + 2*leg_gap + 2*Lineroller_wall_th, 2*Lineroller_wall_th]);
    heigh = d/2+leg_gap-Bearing_width/2+0.1;
    for(k=[0,1])
      mirror([0,k,0])
        translate([0,0,floor(end) - 0.75*(Bearing_r + Bearing_wall)])
          rotate([-90,0,0])
            translate([0,0,-heigh-Bearing_width/2])
            cylinder(r1=Bearing_bore_r+heigh, r2=Bearing_bore_r+1, h=heigh);
    }

    translate([0,0,floor(end) - 0.75*(Bearing_r + Bearing_wall)])
      rotate([90,0,0])
        cylinder(d=4.3, h=50, center=true, $fs=1);
    translate([-maxl/4, -d/2-leg_gap-Lineroller_wall_th, floor(end)-0.1])
      cube([maxl/2, d + 2*leg_gap + 2*Lineroller_wall_th, 10]);
  }


}
