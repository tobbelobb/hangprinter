include <parameters.scad>
use <util.scad>
use <line_roller_single.scad>

rotate([0,90,0])
line_roller_double();
module line_roller_double(twod=false,
                          tower_h = Line_roller_ABC_winch_h,
                          edge_stop=180,
                          with_bearing=false){

  s = b623_width + 0.8;
  wall_th = (Depth_of_roller_base - s)/2;
  d = Depth_of_roller_base;
  if(with_bearing){
    translate([0,0,tower_h-d/2])
      rotate([90,0,0])
      difference(){
        b623_vgroove();
        cylinder(r=1.6, h=40, center=true); // Screw hole in vgroove bearing
      }
  }

  if(!twod){
    roller_base(twod=false,
        yextra=spd,
        mv_edg=spd,
        wall_th=wall_th,
        space_between_walls=s);
    for(tr=[0,spd])
      translate([0,tr,0]){
        mirror([0,(spd-tr),0])
          roller_wall(s, wall_th, tower_h);
        preventor_edges(tower_h, s, edge_stop=edge_stop);
    }
    // custom middle wall
    custm_th = spd-s;
    difference(){
      union(){
        translate([-d/2, s/2,0])
          cube([d, custm_th, tower_h]);
        translate([0, s/2-0.4, tower_h - d/2])
          rotate([-90,0,0])
          cylinder(r=3.4/2 + 1, h=custm_th+0.8, $fn=12);
      }
      translate([0,0,tower_h - d/2])
        rotate([-90,0,0])
        inner_round_corner(r=d/2, h=d, center=true, $fn=4*7);
      translate([0,s/2 - 1, tower_h - d/2])
        rotate([-90,0,0])
          cylinder(d=3.4, h=custm_th + 2, $fn=12);
    }
  }
}

