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
          belt_roller_containing_cube();
          for(k=[0,1])
            mirror([0,k,0])
              translate([-7, -Belt_roller_containing_cube_ywidth/2, Belt_roller_h - Belt_roller_insert_h])
                rotate([0,0,40])
                  cube([4, 6, Belt_roller_h]);
        }
      }
      translate([-Depth_of_roller_base/2, -Belt_roller_space_between_walls/2, Belt_roller_h - Belt_roller_insert_h])
        cube([Depth_of_roller_base-2, Belt_roller_space_between_walls, 2]);
      for(k=[0,1]) {
        mirror([0,k,0]) {
          intersection(){
            translate([Belt_roller_top_adj_screw_x, Belt_roller_top_adj_screw_y,Belt_roller_h-5])
              cylinder(d1=3, d2=M3_screw_head_d, h=5, $fn=24);
            translate([-7, -(Belt_roller_space_between_walls+10)/2, Belt_roller_h - Belt_roller_insert_h])
              cube([14, Belt_roller_space_between_walls+10, Belt_roller_h]);
          }
        }
      }
    }

    translate([Belt_roller_top_adj_screw_x,Belt_roller_top_adj_screw_y,5])
      cylinder(d=3.0, h=Belt_roller_h, $fn=12);
    translate([Belt_roller_top_adj_screw_x,-(Belt_roller_top_adj_screw_y),5])
      cylinder(d=3.0, h=Belt_roller_h, $fn=12);
  }
}

