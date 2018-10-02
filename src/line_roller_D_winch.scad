include <parameters.scad>
use <util.scad>
use <line_roller_single.scad>

//!eyelet();
module eyelet(){
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


space_between_walls = b623_width + 0.8;
wall_th_0 = (Depth_of_roller_base - space_between_walls)/2;
wall_th_1 = 3;
tower_h = Line_roller_ABC_winch_h;
bearing_z = tower_h - Depth_of_roller_base/2;

//line_roller_D_winch();
module line_roller_D_winch(twod = false, with_bearing = false){
  y0 = 0;
  y1 = Spool_height + GT2_gear_height;
  y2 = 2*Spool_height + 1 + GT2_gear_height;
  base_xlen = Depth_of_roller_base+10;
  base_ylen = y2+space_between_walls+2*wall_th_0+Roller_l-Depth_of_roller_base;
  base_screw_offset = 6;
  for(y = [y1, y2])
    translate([0,y,0])
      preventor_edges(Line_roller_ABC_winch_h,
                      space_between_walls,
                      with_bearing=true);
  translate([b623_vgroove_small_r,
             y1,
             tower_h-Depth_of_roller_base/2 + b623_vgroove_small_r]){
    //eyelet();
    bx = 5;
    difference(){
      translate([-bx/2, -(space_between_walls+4)/2, 0])
        cube([bx, space_between_walls+4, 3]);
      translate([0,0,-1])
        cylinder(d=3.35, h=5);
      translate([-5,0,-5])
        scale(1.05)
        rotate([90,0,0])
        cylinder(r=b623_vgroove_big_r, h=b623_width+2, center=true);
    }
  }
  translate([0,y1,0])
    mirror([0,1,0])
    roller_wall(space_between_walls, wall_th_0, tower_h);
  translate([0,y1,0])
    roller_wall(space_between_walls, wall_th_1, tower_h);
  translate([0,y2,0])
    mirror([0,1,0])
    roller_wall(space_between_walls, wall_th_1, tower_h);
  translate([0,y2,0])
    roller_wall(space_between_walls, wall_th_0, tower_h);
  translate([-(Depth_of_roller_base+10)/2,
             -space_between_walls/2-wall_th_0 - (Roller_l-Depth_of_roller_base)/2,
             0])
    difference(){
      rounded_cube2([base_xlen,
          base_ylen,
          Base_th], Roller_base_r);
      translate([base_screw_offset, base_screw_offset, 2.3])
        Mounting_screw_countersink();
      translate([base_xlen-base_screw_offset, base_screw_offset, 2.3])
        Mounting_screw_countersink();
      translate([base_xlen-base_screw_offset, base_ylen-base_screw_offset, 2.3])
        Mounting_screw_countersink();
      translate([base_screw_offset, base_ylen-base_screw_offset, 2.3])
        Mounting_screw_countersink();
    }

}


line_deflector();
module line_deflector(){
  bz = Gap_between_sandwich_and_plate + Sep_disc_radius - Spool_r;
  module bit(){
    rotate([0,0,90])
      translate([-Bit_width/2, -Bit_width/2, 0])
      difference(){
        left_rounded_cube2([Bit_width+4,Bit_width,Base_th], 5.5, $fn=28);
        translate([Bit_width/2, Bit_width/2, -1])
          cylinder(d=Mounting_screw_d, h=Base_th+2, $fn=20);
        translate([Bit_width/2, Bit_width/2, 2.3])
          Mounting_screw_countersink();
      }
  }

  // something to aim for
  //translate([0,-b623_vgroove_small_r,bz-b623_vgroove_small_r])
  //  b623_vgroove();
  cx = b623_vgroove_big_r*2 + 7;
  difference(){
    translate([-cx/2, -20+5, 0])
      ymdir_rounded_cube2([cx, 20, bz+5], 3);
    translate([0,-b623_vgroove_small_r,bz-b623_vgroove_small_r]){
      cylinder(r=b623_vgroove_big_r+2, h=b623_width+2, center=true);
      translate([-b623_vgroove_big_r-2, 0, -b623_width/2-1])
        cube([2*(b623_vgroove_big_r+2),100, b623_width+2]);
    }
    translate([0,-b623_vgroove_small_r,bz/3]){
      cylinder(d=3.3, h=100, center=true);
      translate([0,-3.4,0])
        rotate([-90,0,0])
        translate([-5.6/2,-2.5,0])
        point_cube([5.6,2.5,14],120);
    }

    translate([-50,-b623_vgroove_small_r-4,bz-b623_vgroove_small_r-0.5])
      cube([100,b623_vgroove_big_r*2, 1]);

    //translate([(cx-4)/2, ])
    //cube([cx-4, b623_vgroove_big_r*2 + 2, b623_width+2]);
  }
  pl = 5.5;
  ybit = -Bit_width/2+5;
  for(k=[0,1])
    mirror([k,0,0]){
      difference(){
        translate([cx/2,5-Bit_width,Base_th])
          rotate([0,-90,-90])
          inner_round_corner(r=2, h=Bit_width, $fn=4*5);
        translate([cx/2+pl,ybit,2.3])
          Mounting_screw_countersink();
      }
      translate([cx/2+pl,ybit,0])
        rotate([0,0,90])
        bit();
    }
}
