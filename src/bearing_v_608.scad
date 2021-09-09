include <lib/parameters.scad>

$fn=48;

inner_d = b608_vgroove_small_r*2;
small_d = inner_d + 1;;
big_d = b608_vgroove_big_r*2;

difference(){
  cylinder(d=big_d, h=b608_width-0.1, center=true);
  cylinder(d=inner_d, h=b608_width-0.1+2, center=true);
  U_r = 3.7;
  rotate_extrude()
    translate([U_r + small_d/2, 0, 0]){
      scale([1.2,1.4])
      circle(d=6);
      //difference(){
      //  rotate([0,0,45])
      //    square(U_r*sqrt(2), center=true);
      //  translate([-10-U_r+0.25, -5])
      //    square([10, 10]);
      //}
    }
  //translate([-50,-50,0])
  //  cube(100);
}
