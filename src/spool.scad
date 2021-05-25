include <parameters.scad>
use <util.scad>
use <gear_util.scad>
use <spool_core.scad>

//spool_outer();
module spool_outer(spools = 1){
  difference(){
    union(){
      // Edge to keep line in place
      cylinder(r = Sep_disc_radius, h = 1, $fn=100);
      cylinder(r = Spool_r, h = Spool_height+1, $fn=150);
      for(s=[0:spools-1])
        if(s > 0)
          translate([0,0, 1 + s*(Spool_height + 1)])
            cylinder(r = Spool_r, h = Spool_height, $fn=150);
      translate([0,0,0.1]) // Sink  (0.5 - 0.1) = 0.4 mm back to make extra space for torx
        torx(h=Torx_depth+spools*(Spool_height + 1) - 0.5, female=false);
    }
    for(s=[0:spools-1]){
      for(v=[0:120:359])
        rotate([0,0,v + 30*s])
          translate([0, Spool_r/2, 1+Spool_height/2 + s*(1 + Spool_height)])
            rotate([-90,00,0])
              for(i=[-2.2,2.2])
                translate([i,0,0])
                  cylinder(r=1.2, h=Spool_r);
    }
    translate([0,0,-1])
      cylinder(d=b608_outer_dia+2.5, h=3,$fn=150);
    translate([0,0,-1])
      cylinder(r=Spool_r-Spool_outer_wall_th, h=spools*(Spool_height + 1)+Torx_depth+1,$fn=150);
  }
}

//color([0.4,0.75,0.4]) import("../stl/spool.stl");
spool();
module spool(){
  spool_outer();
  spool_center();
}



bottom_th = 1;

//translate([0,0,-2])
//!spool_cover();
module spool_cover(height=1+Spool_height+bottom_th+1){
  opening_width = 60;
  difference(){
    union(){
      difference(){
        cylinder(r = Sep_disc_radius + 3, h=height, $fn=150);
        translate([0,0,1])
          cylinder(r = Sep_disc_radius + 2, h=height, $fn=150);
        rotate_extrude(angle=opening_width, $fn=150)
          translate([Sep_disc_radius - 1, 1])
            square([5,height]);
      }
      cylinder(h=4, d1=20, d2=12);
      cylinder(h=2, d=20);
      translate([0,0,4])
        rotate([180,0,0])
          b608_lips(4);
    }
    translate([0,0,-1])
      cylinder(d = 8.3, h=height, $fn=24);
    first_rot=150;
    second_rot = first_rot - opening_width;
    rotate([0,0,first_rot])
      translate([0, 0, 0.5])
        translate([0, -(Sep_disc_radius + Gap_between_sandwich_and_plate), 1+Spool_height+GT2_gear_height/2+1.2])
          spool_core();
    rotate([0,0,second_rot])
      translate([0, 0, 0.5])
        translate([0, -(Sep_disc_radius + Gap_between_sandwich_and_plate), 1+Spool_height+GT2_gear_height/2+1.2])
          spool_core();
    translate([0,0,0])
      cylinder(h=2, d=10);
  }
}

//!dleft_spool_cover();
module dleft_spool_cover(){
  spool_cover(bottom_th+Spool_height+1+Spool_height+1);
}
