use <lib/util.scad>

$fn=4*6;

difference(){
  union(){
    cylinder(d=13, h=10);
    mirror([1,0,0])
      for(k=[0,1]) mirror([k,0,0])
        translate([1.8, 4.5, 0])
          rotate([0,0,-5])
            translate([0,-k,0])
              cube([3+k, 11.5+k*1.5, 10]);
    for(ang=[90,60+120,30-120])
      rotate([0,0,ang])
        translate([-2.5/2, 13/2-1, 0])
          hull(){
            cube([2.5, 1, 10]);
            translate([0,1.5,5])
              rotate([0,90,0])
                cylinder(d=9, h=2.5);
          }
          //cube([2.5, 4, 10]);

    translate([0,12,5])
      rotate([0,90,0])
        hull(){
          translate([-0.5,0,-5])
            rotate([-5,0,0])
            cylinder(d=5, h=1.7, center=true);
          translate([0.5,0,-5])
            rotate([-5,0,0])
            cylinder(d=5, h=1.7, center=true);
        }
  }
  translate([0,0,-1])
    cylinder(d=10, h=12);
  translate([-4/2,0,-1])
    cube([4, 10, 12]);
  translate([0,12,5])
    rotate([0,90,0])
      hull(){
        translate([-0.5,0,0])
        cylinder(d=3.5, h=14, center=true);
        translate([0.5,0,0])
        cylinder(d=3.5, h=14, center=true);
      }
  mirror([1,0,0])
    translate([-2.6,5,0])
      rotate([0,0,90+5])
        translate([4.425,0,1.5])
          point_cube([5.6,2.5,11],120);
  for(ang=[00,60+120,30-120])
    rotate([0,0,ang])
      translate([13/2 + 1.2, 0, 5])
        rotate([90,0,0])
          cylinder(d=2, h=4, center=true);
}
