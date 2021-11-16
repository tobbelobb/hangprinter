use <lib/util.scad>

$fn=4*6;

difference(){
  union(){
    cylinder(d=13, h=10);
    for(k=[0,1]) mirror([k,0,0])
      translate([1.8, 4.5, 0])
        rotate([0,0,-5])
          cube([2+k, 7, 10]);
    for(ang=[80,60+120,40-120])
      rotate([0,0,ang])
        translate([-2.5/2, 13/2-1, 0])
          hull(){
            cube([2.5, 1, 10]);
            translate([0,1.5,5])
              rotate([0,90,0])
                cylinder(d=8, h=2.5);
          }
          //cube([2.5, 4, 10]);
  }
  translate([0,0,-1])
    cylinder(d=10, h=12);
  translate([-4/2,0,-1])
    cube([4, 10, 12]);
  translate([0,8,5])
    rotate([0,90,0])
      cylinder(d=3.3, h=12, center=true);
  translate([-7.5,8,5])
    rotate([0,90,0])
      nut(h=4);
  for(ang=[10,50+120,30-120])
    rotate([0,0,ang])
      translate([13/2 + 1.2, 0, 5])
        rotate([90,0,0])
          cylinder(d=1.7, h=4, center=true);
}
