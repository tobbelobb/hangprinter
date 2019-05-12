use <util.scad>

module sector(r1=3, r2=2, sq=[10,10], angle=90){
    rotate_extrude(angle=angle, $fn=4*10)
    translate([r1,0])
    rounded_square(sq, r2, $fn=20);
}

rotate([90,0,0])
brace_tightener(7.2);
module brace_tightener(b){
  difference(){
    union(){
      cube([22.9, b, b]);
      translate([16.9, 0, 0])
        cube([b-1, b, 10]);
      translate([12.9,b,0])
        rotate([90,90,0])
        translate([-b-3,0,0])
        sector(3, 0, [b, b], 180+45, $fn = 4*12);
    }
    translate([-1,b/2,b/2])
      rotate([0,90,0])
      teardrop(r=3.4/2, h=30, $fn=20);
  }
}



