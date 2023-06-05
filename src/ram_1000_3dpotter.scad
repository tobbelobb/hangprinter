include <lib/parameters.scad>
use <lib/util.scad>

ram_1000_3dpotter();
module ram_1000_3dpotter(){
  lift_tube = 60;
  tube_height = 325;
  tube_inner_d = Ram_1000_3dpotter_tube_inner_d;
  tube_outer_d = Ram_1000_3dpotter_tube_outer_d;
  translate([0,0,lift_tube])
    color([0.9,0.9,0.9], 0.4)
      difference(){
        cylinder(d = tube_outer_d, h=tube_height, $fn=10*4);
        translate([0,0,-1])
          cylinder(d = tube_inner_d, h= tube_height+2, $fn=10*4);
      }

  color([0.15,0.15,0.15])
    difference(){
      translate([0,0,lift_tube-36])
        cylinder(d=70, h=36);
      end_r = 35.7/2;
      circle_r = 47;
      translate([0,0,lift_tube-36])
        rotate_extrude()
          translate([circle_r+end_r,0])
            circle(r=circle_r);
    }

  color([0.93,0.1,0.1])
    cylinder(d1 = 6, d2 = 19, h = 24);

  shim_height = 17;
  color([0.15,0.15,0.15])
    translate([0,0,tube_height + lift_tube])
      cylinder(d = tube_outer_d + 3, h = shim_height);

  color([0.5,0.5,0.5])
    translate([-80/2, -80/2, lift_tube + tube_height + shim_height])
      cube([80, 97, Nema23_cube_width]);
  translate([-Nema23_cube_height-80/2, 97-80/2-Nema23_cube_width/2, lift_tube + tube_height + shim_height + Nema23_cube_width/2])
    rotate([0,90,0])
      Nema23();

  topshim_height = 10;
  color([0.6,0.6,0.6])
    translate([0,0,lift_tube + tube_height + shim_height + Nema23_cube_width])
      cylinder(d=62, h=topshim_height);
  w = Ram_1000_3dpotter_top_square_width;
  color([0.6,0.6,0.6])
    rotate([0,0,45])
      translate([-w/2, -w/2, lift_tube + tube_height + shim_height + Nema23_cube_width])
        cube([w, w, 300]);

}
