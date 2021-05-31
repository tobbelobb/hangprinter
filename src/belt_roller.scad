include <parameters.scad>
use <util.scad>

space_between_walls = 2*b623_width + 0.8;
wall_th = (Depth_of_roller_base - space_between_walls)/2+2;
top_adj_screw_x = Depth_of_roller_base/2-3.7;
top_adj_screw_y = space_between_walls/2+2;
containing_cube_ywidth = space_between_walls+8.5;
insert_h = 18;

module containing_cube(){
  translate([-7, -containing_cube_ywidth/2, Belt_roller_h - insert_h])
    cube([14, containing_cube_ywidth, Belt_roller_h]);
}

//translate([0,0,-8])
//!rotate([0,90,0])
//belt_roller_insert(with_bearings = true);
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
        roller_wall_pair(space_between_walls, wall_th, Belt_roller_h);
        union(){
          containing_cube();
          for(k=[0,1])
            mirror([0,k,0])
              translate([-7, -containing_cube_ywidth/2, Belt_roller_h - insert_h])
                rotate([0,0,40])
                  cube([4, 6, Belt_roller_h]);
        }
      }
      translate([-Depth_of_roller_base/2, -space_between_walls/2, Belt_roller_h - insert_h])
        cube([Depth_of_roller_base-2, space_between_walls, 2]);
      for(k=[0,1]) {
        mirror([0,k,0]) {
          intersection(){
            translate([top_adj_screw_x, top_adj_screw_y,Belt_roller_h-5])
              cylinder(d1=3, d2=M3_screw_head_d, h=5, $fn=24);
            translate([-7, -(space_between_walls+10)/2, Belt_roller_h - insert_h])
              cube([14, space_between_walls+10, Belt_roller_h]);
          }
        }
      }
    }

    translate([top_adj_screw_x,top_adj_screw_y,5])
      cylinder(d=3.0, h=Belt_roller_h, $fn=12);
    translate([top_adj_screw_x,-(top_adj_screw_y),5])
      cylinder(d=3.0, h=Belt_roller_h, $fn=12);
  }
}

//rotate([0,90,0])
belt_roller();
module belt_roller(twod = true){
  wing=7;
  flerp=15;
  if(!twod){
    difference(){
      union(){
        // base
        translate([-Depth_of_roller_base/2, 0,0])
          ydir_rounded_cube2([Depth_of_roller_base, space_between_walls/2+wall_th+flerp, Base_th], r=3, $fn=4*5);
        translate([-(Depth_of_roller_base/2+flerp), -(space_between_walls+2*wall_th)/2,0])
          left_rounded_cube2([Depth_of_roller_base+flerp, space_between_walls+2*wall_th, Base_th], r=3, $fn=4*5);
        difference(){
          union(){
            for(k=[0,1]) mirror([0,k,0])
              roller_wall(space_between_walls-0.8, wall_th+0.4, Belt_roller_h, rot_nut=30, bearing_screw=false);
            translate([-Depth_of_roller_base/2,-space_between_walls/2,0])
              cube([Depth_of_roller_base, space_between_walls+2, Belt_roller_h-43]);
            translate([-(Depth_of_roller_base)/2, space_between_walls/2+wall_th, Base_th])
              rotate([0,90,0])
                rotate([0,0,90])
                  inner_round_corner(h=Depth_of_roller_base, r=2, back=2, $fn=5*4);
            translate([-Depth_of_roller_base/2, (space_between_walls+2*wall_th)/2, Base_th])
              rotate([90,0,0])
                rotate([0,0,90])
                  inner_round_corner(h=space_between_walls+2*wall_th+2, r=2, $fn=5*4);

            for(k=[0,1]) mirror([0,k,0])
              translate([-Depth_of_roller_base/2, space_between_walls/2+wall_th,0])
                rotate([0,0,90])
                  inner_round_corner(h=Base_th+2*(1-k), r=2, back=2, $fn=5*4);

            for(k=[0,1]) mirror([0,k,0]) {
              hull(){
                translate([0,space_between_walls/2 + 0.5, Belt_roller_h - Depth_of_roller_base/2])
                  rotate([-90,0,0]){
                    translate([0,0,1+wall_th - min(wall_th/2, 2)])
                      rotate([0,0,30])
                        cylinder(d=7/cos(30), 1.5, $fn=6);
                  }
                translate([0,space_between_walls/2 + 0.5, Belt_roller_h - Depth_of_roller_base/2-8])
                  rotate([-90,0,0]){
                    translate([0,0,1+wall_th - min(wall_th/2, 2)])
                      rotate([0,0,30])
                        cylinder(d=7/cos(30), 1.5, $fn=6);
                }
              }
            }
          }
          translate([-Depth_of_roller_base/2-10, -(space_between_walls+2*wall_th)/2, Base_th])
            rotate([0,90,0])
              rotate([0,0,181])
                corner_rounder(r1=0, r2=2, angle=88);
          translate([-Depth_of_roller_base/2-2, -(space_between_walls+2*wall_th)/2-2, 0])
            cylinder(r=2, h=Base_th+2, $fn=4*5);

          mirror([1,0,0])
            translate([Depth_of_roller_base/2, -(space_between_walls/2+wall_th),Base_th+2+25])
              rotate([0,0,90])
                inner_round_corner(r=2, h=Belt_roller_h+2,$fn=4*4);
          mirror([0,1,0])
            translate([Depth_of_roller_base/2, -(space_between_walls/2+wall_th),Base_th+2])
              rotate([0,0,90])
                inner_round_corner(r=2, h=Belt_roller_h+2,$fn=4*4);


          translate([0,0,-9])
            containing_cube();
          hull(){
            translate([top_adj_screw_x, top_adj_screw_y+0.3, Belt_roller_h-33])
              rotate([0,0,30])
              nut(4);
            translate([top_adj_screw_x, -top_adj_screw_y-0.3, Belt_roller_h-33])
              rotate([0,0,30])
              nut(4);
          }
          for(k=[0,1]) {
            mirror([0,k,0]) {
              translate([-7, -containing_cube_ywidth/2, Belt_roller_h-27])
                rotate([0,0,40])
                  cube([4, 6, Belt_roller_h]);
            }
          }

          for(k=[0,1]) mirror([0,k,0]) {
            hull(){
              translate([0,space_between_walls/2 + 0.5, Belt_roller_h - Depth_of_roller_base/2])
                rotate([-90,0,0]){
                  translate([0,0,1+wall_th - min(wall_th/2, 2)])
                    rotate([0,0,30])
                      nut(h=8);
                }
              translate([0,space_between_walls/2 + 0.5, Belt_roller_h - Depth_of_roller_base/2-8])
                rotate([-90,0,0]){
                  translate([0,0,1+wall_th - min(wall_th/2, 2)])
                    rotate([0,0,30])
                      nut(h=8);
              }
            }
            hull() {
              translate([0,space_between_walls/2 - 1, Belt_roller_h - Depth_of_roller_base/2])
                rotate([-90,0,0])
                  cylinder(d=3.4, h=wall_th + 2, $fn=12);
              translate([0,space_between_walls/2 - 1, Belt_roller_h - Depth_of_roller_base/2-8])
                rotate([-90,0,0])
                  cylinder(d=3.4, h=wall_th + 2, $fn=12);
            }
          }
        }
      }
      translate([top_adj_screw_x, top_adj_screw_y,Belt_roller_h-27])
        cylinder(d=M3_screw_head_d, h=Belt_roller_h, $fn=13);
      translate([top_adj_screw_x, -top_adj_screw_y,Belt_roller_h-27])
        cylinder(d=M3_screw_head_d, h=Belt_roller_h, $fn=13);
      translate([top_adj_screw_x, top_adj_screw_y,-5])
        cylinder(d=3.2, h=Belt_roller_h, $fn=13);
      translate([top_adj_screw_x, -top_adj_screw_y,-5])
        cylinder(d=3.2, h=Belt_roller_h, $fn=13);

      translate([0,space_between_walls/2+wall_th+flerp/2,0.5])
        Mounting_screw_countersink();
      translate([-Depth_of_roller_base/2-flerp/2,0,0.5])
        Mounting_screw_countersink();
      translate([-Depth_of_roller_base/2, space_between_walls/2+wall_th, Base_th])
        rotate([0,0,89.9])
          corner_rounder(r1=2, r2=2, sq=[10,Belt_roller_h], angle=90.2);
      mirror([1,0,0])
        translate([-Depth_of_roller_base/2+2, space_between_walls/2+wall_th-2, Base_th+2])
          rotate([0,0,89])
            rotate_extrude(angle=92, $fn=4*4)
              translate([4,0])
                circle(r=2, $fn=4*5);
    }
  } else {
    difference(){
      union(){
        translate([-Depth_of_roller_base/2, 0,0])
          ydir_rounded_cube2_2d([Depth_of_roller_base, space_between_walls/2+wall_th+flerp], r=3, $fn=4*5);
        translate([-(Depth_of_roller_base/2+flerp), -(space_between_walls+2*wall_th)/2,0])
          left_rounded_cube2_2d([Depth_of_roller_base+flerp, space_between_walls+2*wall_th], r=3, $fn=4*5);
      }
      translate([0,space_between_walls/2+wall_th+flerp/2])
        Mounting_screw_countersink(twod=twod);
      translate([-Depth_of_roller_base/2-flerp/2,0])
        Mounting_screw_countersink(twod=twod);
    }
  }
}
