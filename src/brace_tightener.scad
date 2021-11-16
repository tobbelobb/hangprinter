use <lib/util.scad>

module sector(r1=3, r2=2, sq=[10,10], angle=90){
    rotate_extrude(angle=angle, $fn=4*10)
    translate([r1,0])
    rounded_square(sq, r2, $fn=20);
}

rotate([90,0,0])
brace_tightener(7.2);
module brace_tightener(b){
  shorten = 7;
  difference(){
    union(){
      cube([22.9-shorten, b, b]);
      translate([16.9-shorten, 0, 0])
        cube([b-1, b, 10]);
      translate([12.9-shorten,b,0])
        rotate([90,90,0])
        translate([-b-3,0,0])
        intersection(){
          sector(3, 0, [b, b], 180+90, $fn = 4*12);
          translate([2.0,2.5,-1])
            cylinder(r=7.9, h=12, $fn = 4*12);
        }
    }
    translate([-1,b/2,b/2])
      rotate([0,90,0])
      teardrop(r=3.4/2, h=30, $fn=20);
    translate([9.5,b/2,b/2])
      rotate([0,90,0])
        rotate([0,0,30])
          nut(h=12);
    // to view section cut...
    //translate([-50,5,-50])
    //  cube(100);
  }
}



