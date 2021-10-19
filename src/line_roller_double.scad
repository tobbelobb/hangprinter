include <lib/parameters.scad>
use <lib/util.scad>


bearing_lift = b608_vgroove_small_r+Gap_between_sandwich_and_plate + Sep_disc_radius - Spool_r;

//walls(b608_width+0.8, Line_roller_wall_th, Line_roller_ABC_winch_h, tilt=5, with_bearing=false);
module walls(space_between_walls, wall_th, height, tilt, rot_nut=0, bearing_screw=true, with_bearing=true){
  d = 2*b608_vgroove_big_r;

  translate([0,-space_between_walls/2 - wall_th + 0.1, Base_th-0.05])
    rotate([90,0,-90])
    translate([0,0,-d/2])
    inner_round_corner(h=d, r=5, ang=90+tilt, back=1.5, $fn=5*5);
  translate([0,space_between_walls/2 + wall_th - 0.4, Base_th-0.05])
    rotate([90,0,90])
    translate([0,0,-d/2])
    inner_round_corner(h=d, r=5, ang=90-2*tilt, back=1.5, $fn=5*5);

  translate([0,0,bearing_lift]){
    translate([0,0,-(b608_vgroove_small_r+Eyelet_extra_dist)])
      rotate([tilt,0,0])
        translate([0,0,(b608_vgroove_small_r+Eyelet_extra_dist)]){
          if (with_bearing) {
            %rotate([90,0,0])
              difference(){
                b608_vgroove();
                M8_screw(h=40, center=true);
              }
          }
          for (k = [0,1]) mirror([0,k,0])
            difference(){
              union(){
                translate([-d/2, space_between_walls/2,-height+d/2-10])
                  cube([d, wall_th, height+10]);
                translate([0, b608_width/2-0.1, 0])
                  rotate([-90,0,0])
                    cylinder(r=8.1/2 + 1.5, h=wall_th, $fn=24);
              }
              translate([0,0,0])
                rotate([-90,0,0])
                inner_round_corner(r=d/2, h=d, center=true, $fn=4*7);
              if(bearing_screw){
                translate([0,space_between_walls/2 - 1, 0])
                  rotate([-90,0,0]){
                    M8_screw(h=wall_th+2);
                    translate([0,0,1+wall_th - min(wall_th/2, 2)])
                      rotate([0,0,rot_nut])
                        M8_nut(h=8);
                  }
              }
            }
      //rotate([0,30,0])
      //  translate([0,0,-b608_vgroove_big_r-b608_vgroove_room_to_grow_r])
      //  preventor_edges_608(height, space_between_walls+0.75, edge_stop=120);
    }
  }
}

module base_2d(){
  difference(){
    translate([-23,-14-3])
      rounded_cube2_2d([46, 45+6], r=3, $fn=4*8);
    translate([8,-12])
      Mounting_screw(twod=true);
    translate([18,-1])
      Mounting_screw(twod=true);
    translate([-19,18])
      Mounting_screw(twod=true);
    translate([-8,29])
      Mounting_screw(twod=true);
  }
}

module base(){
  linear_extrude(height=Base_th)
    base_2d();
}

line_roller_double(with_bearings=true, twod=false);
module line_roller_double(twod=false,
                          tower_h = Line_roller_ABC_winch_h,
                          with_bearings=false){

  s = b608_width + 0.8;
  wall_th = Line_roller_wall_th;
  shear_them = Shear_line_roller_double_bearings;
  bearing_rot = 5;

  %if(with_bearings){
    for(tr=[0,spd])
      translate([(tr/spd - 0.5)*shear_them,tr,0]){
        translate([0,0,bearing_lift])
          rotate([90,0,0])
            mirror([0,0,tr])
              translate([0,-(b608_vgroove_small_r+Eyelet_extra_dist),0])
                rotate([bearing_rot,0,0])
                  translate([0,(b608_vgroove_small_r+Eyelet_extra_dist),0])
                    difference(){
                      b608_vgroove();
                      M3_screw(h=40, center=true);
                    }
      }
  }

  if(!twod){
    difference() {
      union() {
        translate([-shear_them/2,0,0])
          walls(s, wall_th, tower_h, tilt=bearing_rot);
        translate([shear_them/2,spd,0])
          mirror([0,1,0])
            walls(s, wall_th, tower_h, tilt=bearing_rot);
      }
      translate([0,0,-50])
        cube(100, center=true);
    }
    base();

  } else {
    base_2d();
  }
}

