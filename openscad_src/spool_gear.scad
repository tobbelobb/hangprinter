include <parameters.scad>
use <util.scad>
use <gear_util.scad>
use <gears.scad>
use <lineroller_ABC_winch.scad>

//spool_gear_outer();
module spool_gear_outer(){
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
    translate([0,0,-1])
      cylinder(r=Spool_r-Spool_outer_wall_th, h=Gear_height+2,$fn=150);
    translate([0,0,Gear_height+Spool_height+2-Torx_depth])
      rotate([180,0,0])
      torx(h = Spool_height+2, female=true);
    // Cut bottom to avoid problems with elephant foot
    for(k=[0,1])
      translate([0,0,k*Gear_height])
        mirror([0,0,k])
          translate([0,0,0])
            rotate_extrude(angle=360, convexity=5)
              translate([Spool_pitch-3.5,-1])
                rotate([0,0,-60])
                  square([4,7]);
  }
}

//spool_gear_center();
module spool_gear_center(){
  difference(){
    spool_center();
    screw_head_dist_from_origin = b608_outer_dia/2
                                 + Spool_center_bearing_wall_th
                                 + Mounting_screw_head_d/2
                                 - 1.6;
    screw_head_h = 2.5;
    translate([0,0,(screw_head_h+1)/2-1])
      rotate_extrude()
        translate([screw_head_dist_from_origin,0])
          difference(){
            square([Mounting_screw_head_d,(screw_head_h+1)], center=true);
            for(m=[0,1])
              mirror([m,0,0])
                translate([Mounting_screw_head_d/2,-(screw_head_h+1)/2])
                  rotate([0,0,45])
                    square(20);
          }
    for(i=[0:60:359])
      rotate([0,0,i])
        translate([0,screw_head_dist_from_origin,-1])
          cylinder(d2=Mounting_screw_head_d-4, d1=Mounting_screw_head_d, h=12, $fs=1);
  }
}

spool_gear(30); // Rotate just to match previous version
module spool_gear(rot){
  rotate([0,0,rot]){
    spool_gear_outer();
    spool_gear_center();
  }
}

echo("Spool gear outer radius",  Spool_outer_radius);
echo("Spool gear pitch", Spool_pitch);
