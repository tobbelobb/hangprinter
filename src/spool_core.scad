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
      translate([0,0,b608_width])
        spacer_ABC();
      translate([0,0,1+Spool_height+GT2_gear_height+Spool_height+1-b608_width])
        b608();
    }
}

//spool_core_halve();
module spool_core_halve(twod = false, between){
  w = 15.5; // Width including the lip onto b608
  liplen = 1.2;
  wml = w - liplen; // w minus liplen

  module bit(){
    rotate([0,0,90])
    translate([-wml/2, -wml/2, 0])
    difference(){
      left_rounded_cube2([wml+4,wml,Base_th], 5.5, $fn=28);
      translate([wml/2, wml/2, -1])
        cylinder(d=Mounting_screw_d, h=Base_th+2, $fn=20);
    }
  }

  cubex = 2*bearing_z/sqrt(3)+sqrt(3)*w/2;
  if(!twod){
    difference(){
      union(){
        hull(){
          translate([0,between/2 + liplen,bearing_z])
            rotate([-90,0,0])
            cylinder(d=15, h=wml, $fn=25);
          translate([-cubex/2, between/2 + liplen, 0])
            cube([cubex, wml, Base_th]);
        }
        translate([0,between/2,bearing_z])
          rotate([-90,0,0])
          b608_lips(w);
        for(k=[0,1])
          mirror([k,0,0]){
            translate([cubex/2 + w/2 - 1,between/2 +wml/2 + liplen,0])
              rotate([0,0,90])
              bit();
            translate([cubex/2 - 0.53, wml + between/2+liplen, Base_th - 0.915])
              rotate([90,0,0])
              rotate([0,0,15])
              inner_round_corner(r=5, h=wml, ang=60, $fn=12*4);
          }
      }
      translate([0,0,bearing_z])
        rotate([90,0,0])
        cylinder(d=8.3, h=100, center=true);
      for(k=[0,1])
        mirror([k,0,0]){
          translate([2,w+1 + between/2 + liplen - 1,Base_th])
            rotate([90,0,0])
            rounded_spectri(2*bearing_z/sqrt(3)-4, w+1, 3, $fn=12*3);
          translate([cubex/2 + w/2 - 1,between/2 +wml/2 + liplen,2.3])
            rotate([0,0,90])
            Mounting_screw_countersink();
        }
    }
  } else {
    difference(){
      translate([-cubex/2 - 13.9, between/2 + liplen])
        rounded_cube2_2d([cubex+2*13.9, wml], 5.5, $fn=28);
      for(k=[0,1])
        mirror([k,0])
          translate([-cubex/2 - w/2 + 1 , between/2 + liplen + wml/2])
            Mounting_screw_countersink(twod=true);
    }
  }
}

//spool_cores(false, Sandwich_ABC_width);
//#spool_cores(true, Sandwich_ABC_width);
module spool_cores(twod=false, between){
  for(k=[0,1])
    mirror([0,k,0])
    spool_core_halve(twod, between);
}

// For printing
spool_core();
module spool_core(){
  rotate([-90,0,0])
    spool_core_halve(false, Sandwich_ABC_width);
}
