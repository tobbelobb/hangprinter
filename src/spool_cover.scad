include <parameters.scad>
use <util.scad>
use <gear_util.scad>
use <spool_core.scad>

//translate([0,0,-2])
!spool_cover();
module spool_cover(height=1+Spool_height+1, bottom_th=1.5){
  opening_width = 60;
  tot_height = height+bottom_th;
  difference(){
    union(){
      difference(){
        cylinder(r = Sep_disc_radius + 2, h=tot_height, $fn=150);
        translate([0,0,bottom_th])
          cylinder(r = Sep_disc_radius + 1, h=tot_height, $fn=150);
        rotate_extrude(angle=opening_width, $fn=150)
          translate([Sep_disc_radius - 1, bottom_th])
            square([5,tot_height]);
      }
      cylinder(h=bottom_th+1, d1=12+(bottom_th+1)*2, d2=12);
    }
    translate([0,0,-1])
      cylinder(d = 8.3, h=tot_height, $fn=24);
    first_rot=150;
    second_rot = first_rot - opening_width;
    rotate([0,0,first_rot])
      translate([0, 0, 0.75])
        translate([0, 0, -15.5+1.2])
          rotate([0,180,0])
            translate([0, -(Sep_disc_radius + Gap_between_sandwich_and_plate), 1+Spool_height+GT2_gear_height/2+1.2])
              spool_core();
    rotate([0,0,second_rot])
      translate([0, 0, 0.75])
        translate([0, 0, -15.5+1.2])
          rotate([0,180,0])
            translate([0, -(Sep_disc_radius + Gap_between_sandwich_and_plate), 1+Spool_height+GT2_gear_height/2+1.2])
              spool_core();
  }
  translate([0,0,0.75])
    cylinder(h=0.3, d=9);
}
