include <lib/parameters.scad>
use <lib/util.scad>


//walls(b623_width+0.8, Line_roller_wall_th, Line_roller_ABC_winch_h);
module walls(space_between_walls, wall_th, height, rot_nut=0, bearing_screw=true, tilt=10, with_bearing=false){
  d = Depth_of_roller_base;

  difference() {
    translate([0,-space_between_walls/2 - wall_th + 0.1, Base_th-0.05])
      rotate([90,0,-90])
      translate([0,0,-d/2])
      inner_round_corner(h=d, r=5, ang=90+tilt, back=1.5, $fn=5*5);
    translate([0,-14,0])
      Mounting_screw();
  }



  translate([0,0,height-d/2]){
    translate([0,0,-(b623_vgroove_small_r+Eyelet_extra_dist)])
      rotate([tilt,0,0])
        translate([0,0,(b623_vgroove_small_r+Eyelet_extra_dist)]){
          if (with_bearing) {
            rotate([90,0,0])
              difference(){
                b623_vgroove();
                M3_screw(h=40, center=true);
              }
          }
          for (k = [0,1]) mirror([0,k,0])
            difference(){
              union(){
                translate([-d/2, space_between_walls/2,-height+d/2])
                  cube([d, wall_th, height]);
                translate([0, space_between_walls/2-0.4, 0])
                  rotate([-90,0,0])
                    cylinder(r=3.1/2 + 1, h=wall_th, $fn=12);
              }
              translate([0,0,0])
                rotate([-90,0,0])
                inner_round_corner(r=d/2, h=d, center=true, $fn=4*7);
              if(bearing_screw){
                translate([0,space_between_walls/2 - 1, 0])
                  rotate([-90,0,0]){
                    M3_screw(h=wall_th+2);
                    translate([0,0,1+wall_th - min(wall_th/2, 2)])
                      rotate([0,0,rot_nut])
                        nut(h=8);
                  }
              }
            }
    }
  }
}

rotate([0,90,0])
line_roller_double(with_bearings=false);
module line_roller_double(twod=false,
                          tower_h = Line_roller_ABC_winch_h,
                          edge_stop=180,
                          with_bearings=false){

  s = b623_width + 0.8;
  wall_th = Line_roller_wall_th;
  d = Depth_of_roller_base;
  bearing_rot = 10;

  if(with_bearings){
    for(tr=[0,spd])
      translate([0,tr,0]){
        translate([0,0,tower_h-d/2])
          rotate([90,0,0])
            mirror([0,0,tr])
              translate([0,-(b623_vgroove_small_r+Eyelet_extra_dist),0])
                rotate([bearing_rot,0,0])
                  translate([0,(b623_vgroove_small_r+Eyelet_extra_dist),0])
                    difference(){
                      b623_vgroove();
                      M3_screw(h=40, center=true);
                    }
      }
  }

  if(!twod){
    roller_base(twod=false,
        yextra=spd,
        mv_edg=spd,
        wall_th=wall_th,
        space_between_walls=s,
        with_fillets=false);

    difference() {
      union() {
        walls(s, wall_th, tower_h, tilt=bearing_rot);
        translate([0,spd,0])
          mirror([0,1,0])
            walls(s, wall_th, tower_h, tilt=bearing_rot);
      }
      translate([0,0,-50])
        cube(100, center=true);
    }

    // center fillet
    translate([0,spd/2,9.06])
      rotate([0,90,0])
      translate([0,0,-Depth_of_roller_base/2])
      rotate([0,0,90+45])
      inner_round_corner(h=Depth_of_roller_base, r=1, ang=180-2*bearing_rot, back=5.5, $fn=5*5);
  } else {
    roller_base(twod=true,
        yextra=spd,
        mv_edg=spd,
        wall_th=wall_th,
        space_between_walls=s);
  }
}

