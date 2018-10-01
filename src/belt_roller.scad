include <parameters.scad>
use <util.scad>


belt_roller();
module belt_roller(twod = false){
  space_between_walls = 2*b623_width + 0.8;
  wall_th = (Depth_of_roller_base - space_between_walls)/2;
  flerp = Roller_flerp;
  l = Roller_l;

  if(!twod)
    roller_wall_pair(space_between_walls, wall_th, Belt_roller_h);
}
