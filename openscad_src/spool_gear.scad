include <parameters.scad>
include <gear_parameters.scad>
use <sweep.scad>
use <util.scad>
use <gears.scad>

//rotate([0,0,30])
//#prev_art();
module prev_art(){
  translate([0,0,5])
  import("../stl/spool_herringbone.stl");
}

//decoration();
module decoration(height=10){
  d = 2;
  lou = 6.9;
  trou = 52-lou;
  stp = 6;
  inr = 9; // Radius of the corner turns that shape sweeps
  shpr = 2; // Radius of the bend that shape has
  wallr = lou + trou - shpr;
  dd = 10.2;
  //dd = 14;
  start_ang = (180/3.14)*(inr/wallr);
  start_ang2 = (180/3.14)*(inr/(wallr-dd-inr));
  last_ang = 60;
  stop_ang = last_ang - start_ang;
  stop_ang2 = last_ang - start_ang2;

  mirror([0,1,0])
    half_decoration();
  half_decoration();
  module half_decoration(){
    step = 90/10;
    // Shape to drag around in order to make nice round insides of decoration
    function shp(l, h, r, d) = concat(
      [[0,-d], [l, -d], [l, 0]],
      [for(a=[step:step:90])
        [l, 0] + [0,r] + r*[cos(270-a), sin(270-a)]],
      [[l-r, h-r]],
      [for(a=[90+step:step:90+90])
        [l, h-2*r] + [0,r] + r*[cos(270-a), sin(270-a)]],
      [[l, h+d], [0,h+d]]);

    rotate([0,0,-last_ang/2])
    sweep(shp(lou, height, 2, d),
       concat(
        [for(i=[last_ang/2-0.1:stp:stop_ang])
         rotation([0,0,i])
         * translation([trou,0,0])
         * rotation([90,0,0])]
         ,
        [for(i=[stp:stp:90])
        rotation([0,0,stop_ang])
        * translation([trou,0,0])
        * rotation([90,0,0])
        * translation([+lou-inr+shpr,0,0])
        * rotation([0,i*1.1,0])
        * translation([-lou+inr-shpr,0,0])],
        [translation(dd*[-cos(last_ang), -sin(last_ang), 0])
        * rotation([0,0,stop_ang])
        * translation([trou,0,0])
        * rotation([90,0,0])
        * translation([+lou-inr+shpr,0,0])
        * rotation([0,90*1.1,0])
        * translation([-lou+inr-shpr,0,0])],
        [for(i=[stp:stp:90])
        translation(dd*[-cos(last_ang), -sin(last_ang), 0])
        * rotation([0,0,stop_ang])
        * translation([trou,0,0])
        * rotation([90,0,0])
        * translation([+lou-inr+shpr,0,0])
        * rotation([0,90*1.1 + i*0.9,0])
        * translation([-lou+inr-shpr,0,0])],
        [for(i=[start_ang2:stp:last_ang/2+0.1])
        rotation([0,0,-i+start_ang])
        * translation(dd*[-cos(last_ang), -sin(last_ang), 0])
        * rotation([0,0,stop_ang])
        * translation([trou,0,0])
        * rotation([90,0,0])
        * translation([+lou-inr+shpr,0,0])
        * rotation([0,90*1.1 + 90*0.9,0])
        * translation([-lou+inr-shpr,0,0])]));
  }

  function circle_sector(max_ang, r0, r1, steps=30) =
    concat([for (a=[0:max_ang/steps:max_ang])
              r0*[cos(a), sin(a)]],
           [for (a=[0:max_ang/steps:max_ang])
             r1*[cos(max_ang-a), sin(max_ang-a)]]);
  translate([0,0,-d])
    rotate([0,0,-last_ang/2+start_ang/2+1.4])
    sweep(circle_sector(last_ang-start_ang-2.8, wallr-dd-inr+shpr+0.1, wallr-shpr),
        [translation([0,0,0]),translation([0,0,height+2*d])]);

}

spool_gear();
module spool_gear(){
  module half(){
    my_gear(Spool_teeth, Gear_height/2+0.1, Circular_pitch);
  }
  difference(){
    union(){
      translate([0,0,Gear_height/2]){
        half();
        mirror([0,0,1])
          half();
      }
    }
    for(i=[0:60:359])
      rotate([0,0,i])
        decoration(Gear_height);
  }

}
