include <lib/parameters.scad>
use <lib/util.scad>


//translate([0,0,-8])
rotate([0,90,0])
belt_roller_insert(with_bearings = false);
module belt_roller_insert(with_bearings){
  if(with_bearings){
    translate([0,0,Belt_roller_h-Depth_of_roller_base/2]){
      rotate([90,0,0])
        b623();
      rotate([-90,0,0])
        b623();
    }
  }

  difference(){
    union(){
      intersection(){
        roller_wall_pair(Belt_roller_space_between_walls, Belt_roller_wall_th, Belt_roller_h);
        union(){
          scale([1,(Belt_roller_containing_cube_ywidth-0.1)/Belt_roller_containing_cube_ywidth, 1])
          belt_roller_containing_cube();
          for(k=[0,1])
            mirror([0,k,0]){
              translate([-Belt_roller_containing_cube_xwidth/2, -(Belt_roller_containing_cube_ywidth-0.1)/2, Belt_roller_h - Belt_roller_insert_h])
                rotate([0,0,40])
                  cube([4, 6, Belt_roller_h]);
            }

        }
      }
      translate([-Depth_of_roller_base/2, -Belt_roller_space_between_walls/2, Belt_roller_h - Belt_roller_insert_h])
        cube([Depth_of_roller_base-2.5, Belt_roller_space_between_walls, 2]);
      for(k=[0,1]) {
        mirror([0,k,0]) {
          intersection(){
            translate([Belt_roller_top_adj_screw_x, Belt_roller_top_adj_screw_y,Belt_roller_h-Belt_roller_insert_h])
              cylinder(d=M3_screw_head_d-0.2, h=Belt_roller_insert_h, $fn=24);
            translate([-7, -(Belt_roller_space_between_walls+10)/2, Belt_roller_h - Belt_roller_insert_h])
              cube([14.5, Belt_roller_space_between_walls+10, Belt_roller_h]);
          }
        }
      }
    }

    translate([Belt_roller_top_adj_screw_x,Belt_roller_top_adj_screw_y,5])
      M3_screw(h=Belt_roller_h);
    translate([Belt_roller_top_adj_screw_x,-(Belt_roller_top_adj_screw_y),5])
      M3_screw(h=Belt_roller_h);
  }
}

