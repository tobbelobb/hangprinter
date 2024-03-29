include <lib/parameters.scad>
use <lib/gear_util.scad>

use <spool.scad>

sep_disc();
module sep_disc(){
  difference(){
    cylinder(r = Sep_disc_radius, h = 1, $fn=100);
    translate([0,0,-1]){
      torx(h=3, r=Spool_r+0.2, r2 = Spool_r/4.2+0.1, female=false);
      cylinder(r = Spool_r - 1.3, h = 3, $fn=100);
      for(v=[0:30:359])
        rotate([0,0,v])
          for(a=[1,-1])
            rotate([0,0,15+a*3])
            translate([-0.5/2,0,0])
              cube([0.5,Spool_r+3,3]);
    }
  }
}

