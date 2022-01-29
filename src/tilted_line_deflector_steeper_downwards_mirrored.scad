include <lib/parameters.scad>
use <tilted_line_deflector.scad>

tilted_line_deflector_steeper_downwards_mirrored();
module tilted_line_deflector_steeper_downwards_mirrored(){
  mirror([1,0,0])
    tilted_line_deflector(rotx=Tilted_line_deflector_tilt_steeper);
}
