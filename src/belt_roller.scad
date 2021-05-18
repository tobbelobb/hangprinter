include <parameters.scad>
use <util.scad>

space_between_walls = 2*b623_width + 0.8;
wall_th = (Depth_of_roller_base - space_between_walls)/2+1;

//belt_roller_insert();
module belt_roller_insert(){
  intersection(){
    roller_wall_pair(space_between_walls, wall_th, Belt_roller_h);
    translate([-7, -(space_between_walls+6)/2, 15])
      cube([14, space_between_walls+6, Belt_roller_h]);
  }
  translate([-14/2, -space_between_walls/2, 15])
    cube([14, space_between_walls, 2]);
}


//rotate([0,90,0])
belt_roller(with_bearings = true);
module belt_roller(twod = false,
                   with_bearings = false){

  if(with_bearings){
    translate([0,0,Belt_roller_h-Depth_of_roller_base/2]){
      rotate([90,0,0])
        b623();
      rotate([-90,0,0])
        b623();
    }
  }

  if(!twod){
    difference(){
      union(){
        roller_wall_pair(space_between_walls, wall_th, Belt_roller_h);
        translate([-Depth_of_roller_base/2, -space_between_walls/2, 15])
          cube([Depth_of_roller_base, space_between_walls, 2]);
      }
      translate([-7, -(space_between_walls+6)/2, 15+2])
        cube([14, space_between_walls+6, Belt_roller_h]);
      for(k=[0,1])
        mirror([0,k,0])
          translate([-7, -(space_between_walls+6)/2, 15+2])
            rotate([0,0,40])
              cube([4, 6, Belt_roller_h]);
    }
    //translate([0,20,0])
    //belt_roller_insert();
  } else {
    roller_base(twod=true,
        wall_th=wall_th,
        space_between_walls=space_between_walls,
        openings=[false, false, false, false]);
  }
}
