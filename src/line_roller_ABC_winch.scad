include <parameters.scad>
use <util.scad>

line_roller_ABC_winch();
module line_roller_ABC_winch(twod = false){
  space_between_walls = b623_width + 0.8;
  wall_th = (Depth_of_roller_base - space_between_walls)/2;
  l = Roller_l;
  tower_h = Line_roller_ABC_winch_h;

  if(!twod){
    roller_wall_pair(space_between_walls, wall_th, tower_h);
    preventor_edges(tower_h, space_between_walls);
    translate([0,-Spool_height - GT2_gear_height, 0]){
      roller_wall_pair(space_between_walls, wall_th, tower_h);
      preventor_edges(tower_h, space_between_walls);
    }
  }
}
