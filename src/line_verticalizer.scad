include <lib/parameters.scad>
use <lib/util.scad>

module u_roller_wall(space_between_walls, wall_th, height, rot_nut=0, bearing_screw=true){
  d = Depth_of_roller_base+3;
  difference(){
    union(){
      translate([-d/2, space_between_walls/2,0])
        cube([d, wall_th, height]);
      translate([0, space_between_walls/2-0.4, height - d/2])
        rotate([-90,0,0])
          cylinder(r=3.1/2 + 1, h=wall_th, $fn=12);
    }
    if(bearing_screw){
      translate([0,space_between_walls/2 - 1, height - d/2])
        rotate([-90,0,0]){
          M3_screw(h=wall_th+2);
          translate([0,0,4])
            nut(h=8);
        }
    }
  }
}

module u_roller_wall_pair(space_between_walls, wall_th, height, rot_nut=0, base_extra_w=0, wing=0, bearing_screw=true){
      roller_base(wall_th = wall_th,
                  space_between_walls=space_between_walls,
                  yextra=0,
                  wing=wing,
                  base_extra_w=base_extra_w,
                  d = Depth_of_roller_base+3);
      u_roller_wall(space_between_walls, wall_th, height, rot_nut, bearing_screw);
      mirror([0,1,0])
        u_roller_wall(space_between_walls, wall_th, height, rot_nut, bearing_screw);
}


space_between_walls = 2*b623_width + 0.8 + 2;
tower_h = Line_roller_ABCD_winch_h - b608_vgroove_small_r + b623_big_ugroove_small_r - 0.5 + 3;

//rotate([0,-90,0])
//%import("../stl/line_verticalizer.stl");
rotate([0,90,0])
translate([-b623_big_ugroove_small_r,0,0])
line_verticalizer();
module line_verticalizer(twod = false){
  wall_th = Line_roller_wall_th+1.6;
  base_extra_w = b623_width+2;
  eyelet_holder_h = min(9, tower_h-Base_th-2*(b623_big_ugroove_big_r+b623_ugroove_room_to_grow_r));
  if(!twod){
    difference(){
      union(){
        u_roller_wall_pair(space_between_walls, wall_th, tower_h, base_extra_w=base_extra_w);
        difference(){
          translate([-(Depth_of_roller_base+3)/2, -space_between_walls/2-wall_th, tower_h-eyelet_holder_h])
            cube([Depth_of_roller_base+3, space_between_walls+2*wall_th, eyelet_holder_h]);
          translate([0,0,tower_h-(Depth_of_roller_base+3)/2])
            rotate([90,0,0])
            cylinder(r=b623_big_ugroove_big_r + b623_ugroove_room_to_grow_r, h=100, center=true,
                      $fn=14*4);
        }
      }
      // Line in/out-lets
      for(k=[0,1]) mirror([0,k,0]){
        translate([b623_big_ugroove_small_r + Eyelet_extra_dist, -1-b623_width/2, tower_h-9-1])
          eyelet(h=11);
        translate([b623_big_ugroove_small_r + Eyelet_extra_dist, -1-b623_width/2, tower_h-eyelet_holder_h-0.01])
          cylinder(d1=Eyelet_diameter*1.4, d2=Eyelet_diameter*0.9, h=2);
        translate([-b623_big_ugroove_small_r - Eyelet_extra_dist, -1-b623_width/2, tower_h-9-1])
          eyelet(h=11);
        translate([-b623_big_ugroove_small_r - Eyelet_extra_dist, -1-b623_width/2, tower_h-eyelet_holder_h-0.01])
          cylinder(d1=Eyelet_diameter*1.4, d2=Eyelet_diameter*0.9, h=2);
        translate([-b623_big_ugroove_small_r - Eyelet_extra_dist, -1-b623_width/2-b623_width-2.1, tower_h-3.7])
          eyelet(h=11);
        bigr=23;
        translate([-b623_big_ugroove_small_r - Eyelet_extra_dist + 0.1, -1-b623_width-2.1-b623_width/2,tower_h-3.5])
          rotate([0,0,90])
            translate([0,bigr,0])
              rotate([0,90,0])
                rotate([0,0,220])
                  rotate_extrude(angle=90, $fn=20)
                    translate([bigr,0,0])
                      circle(d=3);

      }
      for(k=[0,1]) mirror([0,k,0])
        translate([-(Depth_of_roller_base+3)/2, -space_between_walls/2- wall_th, Base_th])
          rotate([0,0,180])
            corner_rounder(r1=3, r2=5, sq=[20,tower_h+5]);
    }
    difference(){
      union(){
        translate([-(Depth_of_roller_base+3)/2, -0.5, 0])
          cube([Depth_of_roller_base+3, 1, tower_h]);
        translate([0,0,tower_h-(Depth_of_roller_base+3)/2])
          rotate([90,0,0])
            cylinder(r=3.1/2+1, h=2, center=true, $fn=12);
      }
      translate([0,0,tower_h-(Depth_of_roller_base+3)/2])
        rotate([90,0,0])
          M3_screw(h=4, center=true);
    }

    //translate([0,b623_width/2+0.95,17.4])
    //  rotate([90,0,0])
    //    scale([1,1,1.20])
    //      difference(){
    //        b623_big_ugroove();
    //        cylinder(d=3,h=5,center=true, $fn=4*5);
    //      }
  } else {
    roller_base(twod=true, space_between_walls=space_between_walls, base_extra_w=base_extra_w, d = Depth_of_roller_base + 3);
  }
}
