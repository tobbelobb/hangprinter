use <../../lib/util.scad>

//translate([-2,0,0])
//rotate([0,90,0])
//urethane_stock();
module urethane_stock() {
  color([0.1,0.1,0.1])
  difference(){
    cylinder(d=25, h=40);
    translate([0,0,-1])
      cylinder(d=10.5, h=42);
  }
}

jig();
module jig(){
  difference(){
    rotate([0,90,0])
      difference(){
        union() {
          td(d=30, h=40);
          translate([5,-10,0])
            cube([10, 20, 40]);
        }
        translate([0,0,-2])
          td(d=25, h=40);
      }
    translate([40-2-1, -30, 0])
      cube([60,60,30]);
    translate([-4-7, -25, 0])
      cube([40,40,30]);
    translate([40-0.5-2-5, -25, -10])
      cube([1,40,40]);
  }
}


module td(d,h) {
  rotate([0,0,90])
    teardrop(r=d/2, h=h);
}
