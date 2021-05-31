include <parameters.scad>
use <util.scad>

module v_roller_wall(space_between_walls, wall_th, height, rot_nut=0, bearing_screw=true){
  d = Depth_of_roller_base;
  difference(){
    union(){
      translate([-d/2, space_between_walls/2,0])
        cube([d, wall_th, height]);
      translate([0, space_between_walls/2-0.4, height - d/2])
        rotate([-90,0,0])
          cylinder(r=3.1/2 + 1, h=wall_th, $fn=12);
    }
    translate([0,0,height - d/2])
      rotate([-90,0,0])
      inner_round_corner(r=d/2, h=d, center=true, $fn=4*7);
    if(bearing_screw){
      translate([0,space_between_walls/2 - 1, height - d/2])
        rotate([-90,0,0]){
          cylinder(d=3.1, h=wall_th + 2, $fn=12);
        }
    }
  }
}

module v_roller_wall_pair(space_between_walls, wall_th, height, rot_nut=0, base_extra_w=0, wing=0, bearing_screw=true){
      roller_base(wall_th = wall_th,
                  space_between_walls=space_between_walls,
                  yextra=0,
                  wing=wing,
                  base_extra_w=base_extra_w);
      v_roller_wall(space_between_walls, wall_th, height, rot_nut, bearing_screw);
      mirror([0,1,0])
        v_roller_wall(space_between_walls, wall_th, height, rot_nut, bearing_screw);
}


//!eyelet();
module eyelet(){
  $fn=24;
  hi = 3.45;
  color("sandybrown")
  difference(){
    union(){
      cylinder(d=3.42,h=hi);
      translate([0,0,hi-1])
        cylinder(d=4.66, h=1);
    }
    translate([0,0,-1])
      cylinder(d=1.75,h=hi+2);
  }
}

space_between_walls = 2*b623_width + 0.8 + 2;
tower_h = Line_roller_ABC_winch_h;

//eyelet_holder(Depth_of_roller_base);
module eyelet_holder(w, d=3.35, d2=true){
  bx = Depth_of_roller_base/2;
  translate([bx/2,
      0,
      tower_h-Depth_of_roller_base/2 + b623_vgroove_small_r])
    difference(){
      translate([-bx/2, -w/2, -5])
        cube([bx, w, 9]);
      if (d2)
        translate([-bx/2+b623_vgroove_small_r,b623_width/2+2,-3])
          cylinder(d=d, h=10);
      translate([-bx/2+b623_vgroove_small_r,-b623_width/2,-3])
        cylinder(d=d, h=10);
      translate([-bx/2,0,-5])
        scale(1.13)
        rotate([90,0,0])
        cylinder(r=b623_vgroove_big_r, h=100, center=true,
                  $fn=14*4);
    }
}

//translate([b623_vgroove_small_r,-1-b623_width/2,0]){
//translate([0, b623_width + 2, tower_h-2.5])
//  eyelet();
//translate([-b623_vgroove_small_r*2, 0, tower_h-2.5])
//  eyelet();
//translate([0, 0, tower_h-2.5])
//  eyelet();
//}

//import("../stl/line_verticalizer.stl");
rotate([0,90,0])
translate([-b623_vgroove_small_r,0,0])
line_verticalizer(with_bearing=false);
module line_verticalizer(twod = false, with_bearing = false){
  wall_th = Line_roller_wall_th;
  base_extra_w = b623_width+2;
  if(!twod){
    difference(){
      union(){
        v_roller_wall_pair(space_between_walls, wall_th, tower_h, base_extra_w=base_extra_w);
        difference(){
          translate([-Depth_of_roller_base/2, -space_between_walls/2-wall_th, tower_h-9])
            cube([Depth_of_roller_base, space_between_walls+2*wall_th, 9]);
          translate([0,0,tower_h-Depth_of_roller_base/2])
            rotate([90,0,0])
            cylinder(r=b623_vgroove_big_r*1.13, h=100, center=true,
                      $fn=14*4);
        }
      }
      // Line in/out-lets
      for(k=[0,1]) mirror([0,k,0]){
        translate([b623_vgroove_small_r, -1-b623_width/2, tower_h-9-1])
          cylinder(d=3.37, h=11);
        translate([-b623_vgroove_small_r, -1-b623_width/2, tower_h-9-1])
          cylinder(d=3.37, h=11);
        translate([-b623_vgroove_small_r, -1-b623_width/2-b623_width-1, tower_h-3.7])
          cylinder(d=3.37, h=11);
        bigr=22;
        translate([-b623_vgroove_small_r, -1-b623_width-1-b623_width/2,tower_h-3.5])
          rotate([0,0,90])
            translate([0,bigr,0])
              rotate([0,90,0])
                rotate([0,0,220])
                  rotate_extrude(angle=90, $fn=20)
                    translate([bigr,0,0])
                      circle(d=2);

      }
      for(k=[0,1]) mirror([0,k,0])
        translate([-Depth_of_roller_base/2, -space_between_walls/2- wall_th, Base_th])
          rotate([0,0,180])
            corner_rounder(r1=3, r2=5, sq=[20,tower_h+5]);
    }
    difference(){
      union(){
        translate([-Depth_of_roller_base/2, -0.5, 0])
          cube([Depth_of_roller_base, 1, tower_h]);
        translate([0,0,tower_h-Depth_of_roller_base/2])
          rotate([90,0,0])
          cylinder(r=3.1/2+1, h=2, center=true, $fn=12);
      }
      translate([0,0,tower_h-Depth_of_roller_base/2])
        rotate([90,0,0])
        cylinder(d=3.1, h=4, center=true,
                  $fn=14*4);
    }
  } else {
    roller_base(twod=true, space_between_walls=space_between_walls, base_extra_w=base_extra_w);
  }
}
