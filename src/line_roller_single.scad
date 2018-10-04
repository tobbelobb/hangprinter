include <parameters.scad>
use <util.scad>

space_between_walls = b623_width + 0.8;
wall_th = (Depth_of_roller_base - space_between_walls)/2;
l = Roller_l;

line_roller_single();
module line_roller_single(twod=false, tower_h = Line_roller_ABC_winch_h, edge_stop=180, with_bearing=false){
  if(with_bearing){
    translate([0,0,tower_h-Depth_of_roller_base/2])
      rotate([90,0,0])
      difference(){
        b623_vgroove();
        cylinder(r=1.6, h=40, center=true); // Screw hole in vgroove bearing
      }
  }
  wall_w = Roller_wall_w;
  difference(){
    union(){
      roller_wall(space_between_walls, wall_w, tower_h);
      mirror([0,1,0])
        roller_wall(space_between_walls, wall_w, tower_h);
      preventor_edges(tower_h, space_between_walls, edge_stop=edge_stop);
      //roller_base();
      // Custom base
      translate([-Depth_of_roller_base/2, -Roller_l/2, 0])
        left_rounded_cube2([Depth_of_roller_base, Roller_l, Base_th], r=8,
                           $fn=13*4);
      translate([-Depth_of_roller_base/2-Roller_fl,-Depth_of_roller_base/2,0])
        left_rounded_cube2([Depth_of_roller_base+Roller_fl, Depth_of_roller_base, Base_th], r=8,
                         $fn=13*4);

      for(k=[0,1])
        mirror([0,k,0])
          translate([-Depth_of_roller_base/2,-Depth_of_roller_base/2, 0])
          rotate([0,0,180])
          inner_round_corner(r=2, h=Base_th, $fn=6*4); // Fillet
      for(k=[0,1])
        mirror([0,k,0])
          translate([0,space_between_walls/2 + wall_w, Base_th])
          rotate([90,0,90])
          translate([0,0,-(Depth_of_roller_base+10)/2])
          inner_round_corner(h=Depth_of_roller_base+10, r=5, back=0.1, $fn=4*5);
    }
    translate([Depth_of_roller_base/2, -50/2])
      cube([10,50,50]);
    for(ang=[0:90:359])
      rotate([0,0,ang]){
        translate([14,0,2.3])
        Mounting_screw_countersink();
      translate([Depth_of_roller_base/2+5,0,5+Base_th])
        rotate([90,0,0])
        cylinder(r=5, h=50, center=true,$fn=4*5);
      translate([Depth_of_roller_base/2+2, Depth_of_roller_base/2+2,-1]){
        cylinder(r=2, h=Base_th+5, $fn=4*6);
        translate([0,-2,0])
          cube([10, 4, Base_th+5]);
        translate([-2,0,0])
          cube([4, 10, Base_th+5]);
      }
    }
    for(k=[0,1])
      mirror([0,k,0])
      translate([-Roller_l/2,-Depth_of_roller_base/2,-1])
      rotate([0,0,0])
      inner_round_corner(r=8, h=Base_th+3,$fn=4*13);
    //translate([Depth_of_roller_base/2+2, Depth_of_roller_base/2+2,-1])

    //translate([Depth_of_roller_base/2,space_between_walls/2+wall_w,Base_th])
    //  corner_rounder(0, 5, [20,20]);
  }

  //if(!twod){
  //  roller_wall_pair(space_between_walls, 5, tower_h);
  //  preventor_edges(tower_h, space_between_walls);
  //}
}
