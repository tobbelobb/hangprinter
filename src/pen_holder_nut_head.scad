include <lib/parameters.scad>
use <lib/util.scad>

pen_holder_nut_head();
module pen_holder_nut_head(){
  difference(){
    cylinder(d=12, h=8, $fn=12*4, center=true);
    for(k=[0,1]) mirror([0,0,k])
    translate([0,0,-1.5-4])
      rotate_extrude($fn=12*4)
        translate([6, 0])
          rotate([0,0,45])
            square(2);
    cylinder(d=3.3, h=9, center=true);
    translate([0,0,-4.7])
      M3_nut(h=3);
    translate([0,0,1])
      cylinder(d1=1, d2=10, h=5, $fn=12*4);
    rad_sub_0 = 19;
    rad_sub_1 = 5*sqrt(2);
    rad = rad_sub_1+rad_sub_0;
    for(ang=[0:20:359]) rotate([0,0,ang])
      for(k=[0,1]) mirror([k,0,0])
        rotate([0,60,0])
          translate([0,-rad_sub_0+5.7,-rad_sub_1])
            rotate_extrude(angle=180)
              translate([rad,0])
                rotate([0,0,45])
                  square(10);

    //translate([0,0,-4])
    //  #linear_extrude(height=8, twist=360/3, slices=12)
    //    translate([8,0])
    //      rotate([0,0,45])
    //        square(10);
  }
}
