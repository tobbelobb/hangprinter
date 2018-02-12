include <parameters.scad>
include <gear_parameters.scad>
include <lineroller_parameters.scad>
use <sweep.scad>
use <util.scad>
use <gear_util.scad>
use <gears.scad>
use <lineroller_ABC_winch.scad>

spool_gear();
module spool_gear(){
  module half(){
    my_gear(Spool_teeth, Gear_height/2+0.1, Circular_pitch, slices = floor(Gear_height/2));
  }
  difference(){
    union(){
      translate([0,0,Gear_height/2]){
        half();
        mirror([0,0,1])
          half();
      }
    }
    wallr_outer = Spool_outer_radius-10;
    inr_outer = 4.6;
    dd_outer = wallr_outer - inr_outer - Spool_r - 3.5;
    lou_outer = 2.5;
    // Outermost decoration
    for(i=[0:60:359])
      rotate([0,0,i])
        decoration(Gear_height,
                   wallr = wallr_outer,
                   inr = inr_outer,
                   dd = dd_outer,
                   lou = lou_outer,
                   skip_ang = 4.50,
                   push_in_center = wallr_outer-6.9);

    for(i=[0:60:359])
      rotate([0,0,i])
        spool_decoration();
    translate([0,0,Gear_height+Spool_height+2-Torx_depth])
      rotate([180,0,0])
      torx(h = Spool_height+2, female=true);
    // Space for 608 bearing
    translate([0,0,-1])
      cylinder(d=b608_outer_dia,h=Gear_height+2);
    translate([0,0,-1])
      cylinder(d1=b608_outer_dia+2.5, d2=b608_outer_dia-0.1,h=2.2);
    // Cut bottom to avoid problems with elephant foot
    for(k=[0,1])
      translate([0,0,k*Gear_height])
        mirror([0,0,k])
          translate([0,0,0])
            rotate_extrude(angle=360, convexity=5)
              translate([Spool_pitch-3.5,-1])
                rotate([0,0,-60])
                  square([4,7]);
    screw_head_dist_from_origin = Bearing_r + Bearing_wall + Spool_core_flerp0/2 + 6/2 + 2;
    screw_head_d = 16;
    screw_head_h = 6;
    translate([0,0,(screw_head_h+1)/2-1])
      rotate_extrude()
        translate([screw_head_dist_from_origin,0])
          square([screw_head_d,(screw_head_h+1)], center=true);
  }

}

echo("Spool gear outer radius",  Spool_outer_radius);
echo("Spool gear pitch", Spool_pitch);
