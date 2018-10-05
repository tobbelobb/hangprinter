include <parameters.scad>
use <util.scad>

rotate([0,90,0])
line_roller_single();
module line_roller_single(twod=false,
                         tower_h = Line_roller_ABC_winch_h,
                         edge_stop=180,
                         wall_th = Line_roller_wall_th,
                         with_bearing=false){

  space_between_walls = b623_width + 0.8;

  if(with_bearing){
    translate([0,0,tower_h-Depth_of_roller_base/2])
      rotate([90,0,0])
      difference(){
        b623_vgroove();
        cylinder(r=1.6, h=40, center=true); // Screw hole in vgroove bearing
      }
  }

  if(!twod){
    roller_wall_pair(space_between_walls, wall_th, tower_h);
    preventor_edges(tower_h, space_between_walls, edge_stop=edge_stop);
  }
}
