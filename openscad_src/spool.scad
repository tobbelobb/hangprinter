include <parameters.scad>
use <util.scad>
use <gear_util.scad>
use <gears.scad>

// Make the actual hole a bit wider than the disc for easier mounting
sep_disc_th = Sep_disc_th + 0.1;

// Separate Spool_heigt into Num_sep_holes+1 sections, with Sep_disc_th wide separators.
// How wide will each section be?
lh = (Spool_height - Num_sep_holes*Sep_disc_th)/(Num_sep_holes+1);

// The position of the middle of the n'th separator along a Spool_height distance
function dh(n) = n*lh + Sep_disc_th/2 + (n-1)*Sep_disc_th;

//spool_outer();
module spool_outer(){
  difference(){
    union(){
      // Edge to keep line in place
      cylinder(r = Spool_outer_radius-7, h = 1, $fn=100);
      cylinder(r = Spool_r, h = Spool_height+1, $fn=150);
      translate([0,0,Spool_height+1-0.4]) // Sink 0.4 mm back to make extra space for torx
        torx(h=Torx_depth, female=false);
    }
    translate([0,0,-1])
      cylinder(r=Spool_r-Spool_outer_wall_th, h=Spool_height+Torx_depth+2,$fn=150);
    for(n=[1:1:Num_sep_holes+1])
      rotate([0, 0, 60*n])
        for(i=[-2.2, 2.2])
          translate([i, 0, 1 + dh(n)-Sep_disc_th/2-lh/2])
            rotate([-90, 0, 0])
            translate([0, 0, Spool_r/2])
            cylinder(r=1.5, h=Spool_r, $fn=100);
  }
}

spool(30); // Rotate just to match previous version
module spool(rot){
  rotate([0,0,rot]){
    difference(){
      union(){
        spool_outer();
        spool_center();
      }
      for(n=[1:1:Num_sep_holes])
        rotate([0, 0, 30*Num_sep_holes+(20*(Num_sep_holes-1))*n])
          for(v=[0:60:359]){
            rotate([0,0, v])
              translate([0, Spool_r-2, -sep_disc_th/2 + 1 +dh(n)])
                cube([4, Spool_r, sep_disc_th]);
            // grooves for separation discs
            rotate([0, 0, v])
              translate([0, Spool_r, -sep_disc_th/2 + 1 + dh(n)])
              rotate([0, 0, 0])
              cylinder(r=1.5, h=Spool_r-1, $fn=20);
          }
    }
  }
}
