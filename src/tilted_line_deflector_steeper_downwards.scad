include <lib/parameters.scad>
use <tilted_line_deflector.scad>

tilted_line_deflector_steeper_downwards();
module tilted_line_deflector_steeper_downwards(){
  tilted_line_deflector(rotx=Tilted_line_deflector_tilt_steeper);
}
