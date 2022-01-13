include <parameters.scad>
use <util.scad>

bearing_z = Sep_disc_radius+Gap_between_sandwich_and_plate;

//placed_sandwich_ABC();
module placed_sandwich_ABC(){
  translate([0,
             1 + Spool_height + GT2_gear_height/2,
             bearing_z])
    rotate([90,0,0]){
      sandwich_ABC();
      b608();
      translate([0,0,1+Spool_height+GT2_gear_height+Spool_height+1-b608_width])
        b608();
    }
}

//spool_core_halve();
//%rotate([90,0,0])
//import("../stl/spool_core.stl");
//rotate([-90,0,0])
spool_core_halve(false, Sandwich_ABC_width+2*Spool_core_cover_adj);
module spool_core_halve(twod = false, between){
  w = Spool_core_halve_width; // Width
  foot_r = 3;

  module bit(){
    rotate([0,0,90])
      translate([-w/2, -w/2, 0])
        left_rounded_cube2([w+4, w, Base_th], foot_r, $fn=28);
  }

  teeth=16;
  cubex = 2*bearing_z/sqrt(3)+sqrt(3)*w/2;
  if(!twod){
    difference(){
      union(){
        hull(){
          translate([0, between/2, bearing_z])
            rotate([-90,0,0])
            cylinder(d=15, h=w, $fn=25);
          translate([-cubex/2, between/2, 0])
            cube([cubex, w, Base_th]);
        }
        for(k=[0,1])
          mirror([k,0,0]){
            translate([cubex/2 + w/2 - 1, between/2 + w/2, 0])
              rotate([0,0,90])
                bit();
            translate([cubex/2 - 0.53, w + between/2, Base_th - 0.915])
              rotate([90,0,0])
                rotate([0,0,15])
                  inner_round_corner(r=5, h=w, ang=60, $fn=12*4);
          }
      }
      translate([0,0,bearing_z])
        rotate([90,0,0])
          cylinder(d=8.2, h=100, center=true, $fn=teeth);
      for(k=[0,1])
        mirror([k,0,0]){
          translate([2,w+1 + between/2 - 0.5,Base_th])
            rotate([90,0,0])
              rounded_spectri(2*bearing_z/sqrt(3)-4, w+1, 3, $fn=12*3);
          translate([cubex/2 + w/2 - 1, between/2 + w/2, 0.6])
            rotate([0,0,90])
              Mounting_screw();
        }
    }
  } else {
    difference(){
      translate([-Spool_core_tot_length/2, between/2])
        rounded_cube2_2d([Spool_core_tot_length, w], foot_r, $fn=28);
      for(k=[0,1])
        mirror([k,0])
          translate([-cubex/2 - w/2 + 1, between/2 + w/2])
            Mounting_screw(twod=true);
    }
  }
}

//!spool_cores(false, Sandwich_ABC_width + 2*Spool_core_cover_adj);
//spool_cores(true, Sandwich_ABC_width);
module spool_cores(twod=false, between){
  for(k=[0,1])
    mirror([0,k,0])
      spool_core_halve(twod, between);
}

// For printing
//spool_core();
module spool_core(){
  rotate([-90,0,0])
    spool_core_halve(false, Sandwich_ABC_width);
}
