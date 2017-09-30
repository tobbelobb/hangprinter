include <parameters.scad>
include <gear_parameters.scad>
use <sweep.scad>
use <util.scad>

//decoration();
module decoration(height=10, wallr = 50, dd=10.2, lou=6.9, inr=9){
  d = 2;
  shpr = 2; // Radius of the bend that shape has
  trou = wallr+shpr-lou;
  stp = 6;
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
        [for(i=[start_ang2:stp:last_ang/2+1])
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
  skip_ang = 8;
  translate([0,0,-d])
    rotate([0,0,-last_ang/2+start_ang/2+skip_ang/2])
    sweep(circle_sector(last_ang-start_ang-skip_ang, wallr-dd-inr+shpr+0.3, wallr-shpr),
        [translation([0,0,0]),translation([0,0,height+2*d+2])]);

}

//torx(remale=true);
module torx(h = Spool_height + 2, r = Spool_r, female=false){
  circs = 12;
  intersection(){
    if(female){
      cylinder(r=r+0.1, h=h, $fn=150);
    } else {
      cylinder(r=r, h=h, $fn=150);
    }
    for(i=[0:1:circs])
      rotate([0,0,i*360/circs]){
        translate([r-5,0,-1])
        cylinder(r=r/4.2, h=h+2, $fn=50);
      if(female){
        rotate([0,0,360/(2*circs)])
          translate([r-7,0,-1])
          cylinder(r2=1, r1=r/1.9, h=h+2, $fn=50);
        }
      }
  }
  cylinder(r=r-5,h=h);
}

