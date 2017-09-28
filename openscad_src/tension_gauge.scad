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
  rounded_cube2([13,11,Lineroller_wall_th],2, $fn=4*4);
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
        translate([-gap-1, -Bearing_width/2-Lineroller_wall_th-0.5])
        cube([2*gap+2,Lineroller_wall_th, h]);
    translate([0,0,h])
      rotate([90,0,0])
      cylinder(r=gap, h=base_w+1, center=true, $fn=30);
  }

  end = h + 2.5*(Bearing_r + Bearing_wall);
  maxl = 20*(1-0.7*sin(4*floor(end)));

  module spring(){
    sweep([[-10,-1], [10, -1], [10, 1], [-10,1]],
      [for(i=[0:end])
        translation([ 0 ,
         i < Lineroller_wall_th ? 2 : 0
         , 0])
        * translation([0,
         i < h/2 ?
         -0.5-base_w-1-0.4*i:
         i < h ?
           -0.5-base_w-1-0.4*h + 0.4*i:
           -0.5-base_w-1-0.4*h + 0.4*h
         ,i])
         * scaling([
         1-0.7*sin(4*i)
         ,
         i < Lineroller_wall_th ? 3 : 1
         ,1])]);
  }

  module leg(){
    sweep([[-10,-1], [10, -1], [10, 1], [-10,1]],
        [for(i=[0:end])
        translation([0, 0.5+base_w+1 ,i])
        * scaling([
          i < 90/4 ?
          0.3 :
          1-0.7*sin(4*(i))
          ,1,1])]);
  }

  difference(){
    union(){
    spring();
    leg();
    translate([-maxl/2, -base_w-2.5, floor(end)-0.1])
      cube([maxl/4, 2*base_w + 5, Lineroller_wall_th]);
    translate([maxl/4, -base_w-2.5, floor(end)-0.1])
      cube([maxl/4, 2*base_w + 5, Lineroller_wall_th]);
    heigh = +0.5+base_w+1-Bearing_width/2;
    translate([0,0,floor(end) - 0.75*(Bearing_r + Bearing_wall)])
      rotate([-90,0,0])
        translate([0,0,-heigh-Bearing_width/2])
        cylinder(r1=Bearing_bore_r+heigh, r2=Bearing_bore_r+1, h=heigh);
    }

    translate([0,0,floor(end) - 0.75*(Bearing_r + Bearing_wall)])
      rotate([90,0,0])
        cylinder(d=4.3, h=50, center=false, $fs=1);
    translate([-maxl/4, -base_w-2.5, floor(end)-0.1])
      cube([maxl/2, 2*base_w + 5, Lineroller_wall_th]);
  }


}
