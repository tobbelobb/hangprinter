include <parameters.scad>
use <util.scad>


rotate([0,90,0])
belt_roller(with_bearing=true);
module belt_roller(twod = false,
                   with_bearings = false){
  space_between_walls = 2*b623_width + 0.8;
  wall_th = (Depth_of_roller_base - space_between_walls)/2;

  if(with_bearings){
    translate([0,0,Belt_roller_h-Depth_of_roller_base/2]){
      rotate([90,0,0])
        b623();
      rotate([-90,0,0])
        b623();
    }
  }

  if(!twod)
    roller_wall_pair(space_between_walls, wall_th, Belt_roller_h);
}
