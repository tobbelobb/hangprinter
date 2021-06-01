include <lib/parameters.scad>

use <tilted_line_deflector.scad>


// Investigate layers
//difference(){
//  horizontal_line_deflector();
//  translate([0,0,72.0])
//  cube(100,center=true);
//}

rotate([90,0,0])
horizontal_line_deflector();
module horizontal_line_deflector(twod=false){
  tilted_line_deflector(rotx=0, rotz=0, bullet_shootout=false, twod=twod);
}

