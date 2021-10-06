$fn=48;

inner_d = 10.15;
small_d = 11.1;
big_d = 13.1;

difference(){
  cylinder(d=big_d, h=3.95, center=true);
  cylinder(d=inner_d, h=3.95+2, center=true);
  U_r = 2.0;
  rotate_extrude()
    translate([U_r + small_d/2, 0, 0]){
      scale([1,1.6])
      difference(){
        rotate([0,0,45])
          square(U_r*sqrt(2), center=true);
        translate([-10-U_r+0.25, -5])
          square([10, 10]);
      }
    }
  //translate([-50,-50,0])
  //  cube(100);
}
