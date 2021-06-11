include <lib/parameters.scad>
use <lib/util.scad>
use <lib/gear_util.scad>
use <spool_core.scad>

//translate([0,0,2*Spool_cover_tot_height+GT2_gear_height])
//  mirror([0,0,1])
//    spool_cover();
spool_cover();
module spool_cover(tot_height=Spool_cover_tot_height, bottom_th=Spool_cover_bottom_th){
  opening_width = 60;
  rot = 150 - opening_width;
  outer_r = Sep_disc_radius + 2;
  space_for_belt_roller = 12;
  difference(){
    union(){
      difference(){
        union(){
          cylinder(r = outer_r, h=tot_height, $fn=150);
          for(ang=[90+45, 180+45])
            rotate([0,0,ang])
              translate([outer_r+(M3_screw_head_d+3)/2, 0, 0]){
                cylinder(d=M3_screw_head_d+3, h=tot_height, $fn=4*6);
                translate([-(M3_screw_head_d+4)/2,-(M3_screw_head_d+3)/2,0])
                  cube([(M3_screw_head_d+4)/2, M3_screw_head_d+3, tot_height]);
              }
          translate([0,-Spool_core_tot_length/2+space_for_belt_roller/2, 0])
            right_rounded_cube2([Sep_disc_radius + Gap_between_sandwich_and_plate, Spool_core_tot_length - space_for_belt_roller, tot_height], 3, $fn=24);
          translate([Sep_disc_radius+1,-Spool_core_tot_length/2+space_for_belt_roller/2, 0])
            cube([Gap_between_sandwich_and_plate-1, (Spool_core_tot_length - space_for_belt_roller)/2, tot_height+GT2_gear_height/2]);
        }
        for(ang=[90+45, 180+45])
          rotate([0,0,ang])
            translate([outer_r+(M3_screw_head_d+3)/2, 0, 0]){
              translate([0,0,-tot_height/2-1])
                nut(h=tot_height);
              translate([0,0,tot_height-tot_height/2+1])
                nut(h=tot_height);
              translate([0,0,2])
                M3_screw(h=tot_height);
            }
        translate([0,0,bottom_th])
          cylinder(r = outer_r - 1, h=tot_height, $fn=150);
        rotate_extrude(angle=opening_width, $fn=150)
          translate([outer_r-3, bottom_th])
            square([50,tot_height]);
        translate([Sep_disc_radius+Gap_between_sandwich_and_plate, -Spool_core_tot_length/2+space_for_belt_roller/2, -1])
          rotate([0,0,90])
            inner_round_corner(r=3, h=tot_height+GT2_gear_height/2+2, $fn=24);
      }
      cylinder(h=bottom_th+Spool_cover_shoulder, d1=12+(bottom_th+1)*2, d2=12);
    }
    translate([0,0,-1])
      cylinder(d = 8.3, h=tot_height, $fn=24);
  }
}
