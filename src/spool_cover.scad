include <lib/parameters.scad>
use <lib/util.scad>
use <lib/gear_util.scad>
use <lib/spool_core.scad>

slit_rot = -15;
slit_z = 4.5;
slit_height = 2.0;
rail_height = 1.4;

module rail(l, rightside=true, leftside=true){
  difference(){
    cube([3, l, rail_height]);
    for(k = [3:3:l])
      translate([-1, k-0.5, -1])
        cube([5, 1, rail_height + 2]);
    translate([0.7,-1,-0.1])
      cube([1.6, l+2, rail_height + 0.2]);
    if (!rightside) {
      translate([0.7,-1,-0.1])
        cube([1.6+0.8, l+2, rail_height + 0.2]);
    }
    if (!leftside) {
      translate([-0.7,-1,-0.1])
        cube([1.6+0.8, l+2,  rail_height + 0.2]);
    }
  }
}


//translate([0,0,2*Spool_cover_tot_height+GT2_gear_height])
//  mirror([0,0,1])
//    spool_cover();

//intersection(){
//  spool_cover();
//  translate([71,30,3])
//    cube([16, 62, 10.5]);
//}

spool_cover();
module spool_cover(tot_height=Spool_cover_tot_height+0.2, bottom_th=Spool_cover_bottom_th, second_hole=true, shift_up=0){
  opening_width = 42;
  rot = 150 - opening_width;
  outer_r = Spool_cover_outer_r;
  space_for_belt_roller = 12;
  difference(){
    union(){
      difference(){
        union(){
          cylinder(r = outer_r, h=tot_height, $fn=150);
          translate([0,-Spool_core_tot_length/2+space_for_belt_roller/2, 0])
            right_rounded_cube2([Sep_disc_radius + Gap_between_sandwich_and_plate, Spool_core_tot_length - space_for_belt_roller, tot_height], 3, $fn=24);
          rotate([0,0,-81])
            translate([0,0,tot_height+0.2])
              rotate_extrude(angle=58, $fn=150)
                translate([outer_r-(outer_r - Sep_disc_radius - Gap_between_sep_disc_and_spool_cover), -0.5])
                  square([outer_r - Sep_disc_radius - Gap_between_sep_disc_and_spool_cover,(GT2_gear_height+0.2)/2]);

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
        // Cut away space for belt to enter
        rotate([0,0,-79])
          translate([outer_r-1.5,0,tot_height+0.1])
            rotate([0,0,-8])
              translate([0,-4,0])
                cube([3, 13, 10]);
        rotate([0,0,-24])
          translate([outer_r-1.5,0,tot_height+0.1])
            rotate([0,0,8])
              translate([0,-9,0])
                cube([2,11,4]);
        // Slit for line entry from below
        if (second_hole && shift_up!=0) {
          translate([Sep_disc_radius, (Spool_core_tot_length - space_for_belt_roller)/2, slit_z + shift_up*(Spool_height+1)])
            rotate([slit_rot,0,0])
              translate([0,-2*Sep_disc_radius,0])
                cube([5,2*Sep_disc_radius, slit_height]);
        }

        if (tot_height > 2*Spool_height && shift_up == 0)
          translate([Sep_disc_radius, (Spool_core_tot_length - space_for_belt_roller)/2, slit_z])
            rotate([slit_rot,0,0])
              translate([0,-2*Sep_disc_radius,0])
                cube([5,2*Sep_disc_radius, slit_height]);
        if (tot_height > 2*Spool_height) {
          translate([Sep_disc_radius, (Spool_core_tot_length - space_for_belt_roller)/2, slit_z + (1+shift_up) * (Spool_height + 1)])
            rotate([slit_rot,0,0])
              translate([0,-2*Sep_disc_radius,0])
                cube([5,2*Sep_disc_radius, slit_height]);
        }
        // Create a line slit for iright spool cover
        if (second_hole && shift_up != 0) {
          translate([Sep_disc_radius-10, 38.0, bottom_th+Spool_height/2+2.5])
            cube([50, 1.0, 2*Spool_height-3]);
          translate([Sep_disc_radius/2, 38.0, bottom_th+Spool_height/2+2.5])
            cube([50, 28, slit_height]);
        }
        translate([0,0,bottom_th])
          cylinder(r = Sep_disc_radius + Gap_between_sep_disc_and_spool_cover, h=tot_height, $fn=150);
        if (second_hole && shift_up==0){
          translate([72.5,0,bottom_th + Spool_cover_shoulder + 1])
            cube([outer_r-74,100,Spool_height]);
          translate([69.5,0,bottom_th + Spool_cover_shoulder + 1])
            cube([outer_r-71,39,tot_height*2]);
        } else {
          translate([69.5,0,bottom_th + Spool_cover_shoulder + 1 + Spool_height + 1])
            cube([outer_r-71,39,tot_height*2]);
        }

        translate([Sep_disc_radius+Gap_between_sandwich_and_plate, -Spool_core_tot_length/2+space_for_belt_roller/2, -1])
          rotate([0,0,90])
            inner_round_corner(r=3, h=tot_height+GT2_gear_height/2+2, $fn=24);
      }
      cylinder(h=bottom_th+Spool_cover_shoulder, d1=12+(bottom_th+1)*2, d2=12);

      // Fill up slit for line entry from below
      if (second_hole) {
        translate([Sep_disc_radius, (Spool_core_tot_length - space_for_belt_roller)/2, slit_z + shift_up*(Spool_height+1)])
          rotate([slit_rot,0,0])
            translate([0.5,-(tot_height-shift_up*(Spool_height+1))/sin(-slit_rot)+5-0.3,(slit_height-rail_height)/2])
              rail((tot_height-shift_up*(Spool_height+1))/sin(-slit_rot)-5);
      }
      if (tot_height > 2*Spool_height) {
        translate([Sep_disc_radius, (Spool_core_tot_length - space_for_belt_roller)/2, slit_z + (1+shift_up)*(Spool_height + 1)])
          rotate([slit_rot,0,0])
            translate([0.5,-(tot_height-(1+shift_up)*(Spool_height+1))/sin(-slit_rot)+5-0.3, (slit_height-rail_height)/2])
              rail((tot_height-(1+shift_up)*(Spool_height+1))/sin(-slit_rot)-5);
      }
      if (second_hole && shift_up!=0) {
          translate([Sep_disc_radius, Sep_disc_radius*sin(28.5), bottom_th+Spool_height/2+2.5+(slit_height-rail_height)/2]) {
            translate([0.5,0,0])
              rail(23, true, false);
            translate([-3.8,23,0])
              rotate([0,0,-37])
                translate([0,-18,0])
                  rail(18, false, true);
            translate([2,0.9,0])
              rotate([0,0,-90])
                translate([0,-12,0])
                  rail(12, false, true);
          }

      }
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
