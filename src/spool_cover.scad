include <lib/parameters.scad>
use <lib/util.scad>
use <lib/gear_util.scad>
use <lib/spool_core.scad>

//translate([0,0,2*Spool_cover_tot_height+GT2_gear_height])
//  mirror([0,0,1])
//    spool_cover();
spool_cover();
module spool_cover(tot_height=Spool_cover_tot_height+0.2, bottom_th=Spool_cover_bottom_th){
  opening_width = 42;
  rot = 150 - opening_width;
  outer_r = Spool_cover_outer_r;
  space_for_belt_roller = 12;
  ears = [90+45, 180+45, -50, 50];
  difference(){
    union(){
      difference(){
        union(){
          cylinder(r = outer_r, h=tot_height, $fn=150);
          for(ang=ears)
            rotate([0,0,ang])
              translate([outer_r+(M3_screw_head_d+3)/2, 0, 0]){
                cylinder(d=M3_screw_head_d+3, h=tot_height, $fn=4*6);
                translate([-(M3_screw_head_d+4)/2,-(M3_screw_head_d+3)/2,0])
                  cube([(M3_screw_head_d+4)/2, M3_screw_head_d+3, tot_height]);
              }
          translate([0,-Spool_core_tot_length/2+space_for_belt_roller/2, 0])
            right_rounded_cube2([Sep_disc_radius + Gap_between_sandwich_and_plate, Spool_core_tot_length - space_for_belt_roller, tot_height], 3, $fn=24);
          rotate([0,0,-80])
            translate([0,0,tot_height+0.2])
            rotate_extrude(angle=80, $fn=150)
            translate([outer_r-1, 0])
            circle(d=1.0);

          difference(){
            translate([Sep_disc_radius+Gap_between_sandwich_and_plate-30,0,0])
              one_rounded_cube2_2([30, (Spool_core_tot_length - space_for_belt_roller)/2, tot_height+GT2_gear_height/2-0.2], 3, $fn=24);
            translate([Sep_disc_radius+Gap_between_sandwich_and_plate-30,0,0])
              translate([0,-1,tot_height+GT2_gear_height/2])
              translate([27,0,0])
              rotate([0,-9,0])
              translate([-28,0,0])
              cube([40, 70, 20]);
          }
          translate([Sep_disc_radius+0.5,-Spool_core_tot_length/2+space_for_belt_roller/2, 0])
            cube([Gap_between_sandwich_and_plate-0.5, (Spool_core_tot_length - space_for_belt_roller)/2, tot_height+GT2_gear_height/2-0.2]);
        }
        for(ang=ears)
          rotate([0,0,ang])
            translate([outer_r+(M3_screw_head_d+3)/2, 0, 0]){
              translate([0,0,-2])
                M3_screw(h=tot_height+4);
            }
        translate([0,0,bottom_th])
          cylinder(r = Sep_disc_radius + Gap_between_sep_disc_and_spool_cover, h=tot_height, $fn=150);
        //rotate([0,0,opening_width])
        //#rotate_extrude(angle=opening_width, $fn=150)
        //  translate([outer_r-3, bottom_th])
        //    square([50,tot_height]);
        translate([72.5,0,bottom_th+Spool_cover_shoulder+1])
          cube([outer_r-74,100,Spool_height]);
        translate([69.5,0,bottom_th+Spool_cover_shoulder+1])
          cube([outer_r-71,39,tot_height*2]);
        translate([Sep_disc_radius+Gap_between_sandwich_and_plate, -Spool_core_tot_length/2+space_for_belt_roller/2, -1])
          rotate([0,0,90])
            inner_round_corner(r=3, h=tot_height+GT2_gear_height/2+2, $fn=24);
      }
      cylinder(h=bottom_th+Spool_cover_shoulder, d1=12+(bottom_th+1)*2, d2=12);
    }
    translate([0,0,-1])
      cylinder(d = 8.3, h=tot_height, $fn=24);

    translate([0,0,tot_height])
      cylinder(r=Sep_disc_radius+0.5, h=7, $fn=150);

    //for(a=[30:360/6:359])
    //  rotate([0,0,a])
    //for(a=[0:360/6:359])
    //  rotate([0,0,a]){
    //    for(i=[0:6])
    //      rotate([0,0,30*(i%2)])
    //      translate([18+8*i+i, 0, -1])
    //      cylinder(d=11+i, h=4);
    //  }

  }
//%translate([0,0,tot_height])
//import("../stl/GT2_spool_gear.stl");
}
