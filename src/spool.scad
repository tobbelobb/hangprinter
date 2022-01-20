include <lib/parameters.scad>
use <lib/util.scad>
use <lib/gear_util.scad>

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
        rotate([0,0,v + 30*s + 30])
          translate([0, Spool_r/2, 1+Spool_height/2 + s*(1 + Spool_height)])
            rotate([-90,00,0])
              for(i=[-2.2,2.2])
                translate([i,0,0])
                  cylinder(r=1.2, h=Spool_r);
    }
    translate([0,0,-1])
      cylinder(r=Spool_r-Spool_outer_wall_th, h=spools*(Spool_height + 1)+Torx_depth+1,$fn=150);
    translate([0,0,spools*(Spool_height+1)+Torx_depth+4.5])
      rotate_extrude($fn=150) {
        translate([Spool_r+1,0])
          rotate([0,0,45])
            square(10, center=true);
      }
  }
}

//color([0.4,0.75,0.4]) import("../stl/spool.stl");
spool();
module spool(){
  spool_outer();
  spool_center();
}
