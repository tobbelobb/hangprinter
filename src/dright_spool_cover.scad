include <lib/parameters.scad>
use <lib/util.scad>
use <lib/gear_util.scad>

use <spool_cover.scad>


//intersection(){
//  dright_spool_cover();
//  translate([64,15,6])
//    cube([23, 62, 20]);
//}
dright_spool_cover();
module dright_spool_cover(){
    difference(){
      spool_cover(tot_height=Spool_cover_D_left_tot_height, second_hole=false);
      translate([72.5,0,Spool_cover_bottom_th+Spool_cover_shoulder+1+Spool_height+1])
        cube([Spool_cover_outer_r-74,100,Spool_height]);

      hull()
        for(ang=[-37, -12])
          rotate([0,0,ang])
            translate([Spool_r/4 + 2, 0, Spool_cover_bottom_th + Spool_cover_shoulder + 1 + Spool_height/2])
              rotate([-90,0,0])
                cylinder(d=Spool_height, h=200, $fn=2*12);
      //#line_from_to([Spool_r/4, 0, Spool_cover_bottom_th + Spool_cover_shoulder + 1 + Spool_height/2], [Spool_r, Spool_r+34, Spool_cover_bottom_th + Spool_cover_shoulder + 1 + Spool_height/2], r=2);
    }
    for(ang=[48,57])
      rotate([0,0,ang])
        translate([Sep_disc_radius + Gap_between_sep_disc_and_spool_cover+0.05,0,1])
          cube([(Spool_cover_outer_r - Sep_disc_radius - Gap_between_sep_disc_and_spool_cover)-0.1, 1, 15]);
    rotate([0,0,43])
      translate([Sep_disc_radius + Gap_between_sep_disc_and_spool_cover+0.05,0,1]){
        cube([2, 1, 15]);
        translate([6.2,0,0])
          cube([2, 1, 15]);
      }
}
