shaft_d = 48.4;
spring_steel_d = 3.15;

module shaft() {
  color("white")
    cylinder(d=shaft_d, h=100, center=true);
}

// Spring steel
//spring_steel();
module spring_steel(d=spring_steel_d) {
  color("grey")
    translate([0,shaft_d/2 + 2, 0])
      rotate([-22,0,0])
        translate([0,0,3])
          cylinder(d=d, h=200);
}

difference(){
  translate([-shaft_d/2, 10, 0])
    cube([shaft_d*3/3, 33, 40]);
  shaft();
  spring_steel(spring_steel_d+1);
  translate([0,0,-1])
  scale([1.05,1.8])
    rotate_extrude()
      translate([shaft_d/2,0])
        square([11,42]);


}
