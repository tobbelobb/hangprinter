include <lib/parameters.scad>

$fn=48;

inner_d = 10.15;
small_d = 11.1+3;
big_d = 13.1+3;
U_r = (big_d - small_d)/2;

bearing_u_big_623();
module bearing_u_big_623(){
  rotate_extrude(){
    difference(){
      translate([inner_d/2,-(b623_width-0.05)/2])
        square([(big_d-inner_d)/2, b623_width-0.05]);
      scl_x = 1.0;
      scl_y = 0.85;
      circ_d = 5;
      translate([big_d/2 + circ_d*scl_x/2 - U_r, 0])
        scale([scl_x, scl_y])
          circle(d=circ_d);
    }
  }
}
//#cylinder(d=small_d+0.01, h=b623_width, center=true);

//import("../stl/bearing_v_623.stl");
//#cylinder(d=13.1, h=b623_width, center=true);
