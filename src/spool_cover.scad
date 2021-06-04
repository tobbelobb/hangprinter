include <lib/parameters.scad>
use <lib/util.scad>
use <lib/gear_util.scad>
use <spool_core.scad>

spool_cover();
module spool_cover(tot_height=Spool_cover_tot_height, bottom_th=Spool_cover_bottom_th){
  opening_width = 60;
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
      cylinder(h=bottom_th+Spool_cover_shoulder, d1=12+(bottom_th+1)*2, d2=12);
    }
    translate([0,0,-1])
      cylinder(d = 8.3, h=tot_height, $fn=24);
    first_rot=150;
    second_rot = first_rot - opening_width;
    rotate([0,0,first_rot])
      translate([0, 0, Spool_core_impression_in_spool_cover])
        translate([0, 0, -Spool_core_halve_width])
          rotate([0,180,0])
            translate([0, -(Sep_disc_radius + Gap_between_sandwich_and_plate), 1+Spool_height+GT2_gear_height/2])
              spool_core(cut_teeth=false);
    rotate([0,0,second_rot])
      translate([0, 0, Spool_core_impression_in_spool_cover])
        translate([0, 0, -Spool_core_halve_width])
          rotate([0,180,0])
            translate([0, -(Sep_disc_radius + Gap_between_sandwich_and_plate), 1+Spool_height+GT2_gear_height/2])
              spool_core(cut_teeth=false);
    translate([0,0,-1])
      cylinder(h=1 + Spool_core_impression_in_spool_cover, d=12);
  }
  translate([0,0,Spool_core_impression_in_spool_cover])
    cylinder(h=0.25, d=9);
}
