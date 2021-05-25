include <parameters.scad>
use <util.scad>

// Comment out if you need to render the hook
//use <line_length_tuner_hook.scad>
// Place line length tuner out like this
//color("red")
//translate([-b623_vgroove_small_r*cos(45), 10, 18])
//  rotate([0,90,90])
//    line_length_tuner_hook();
//color("lime")
//  translate([-b623_vgroove_small_r*cos(45), 10, 18])
//    rotate([0,90,90])
//      translate([0,0,-24]){
//        nut(3);
//        cylinder(d=3, h=30);
//      }

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
tower_h = Line_roller_ABC_winch_h;

//eyelet_holder(Depth_of_roller_base);
module eyelet_holder(w, d=3.35){
  bx = Depth_of_roller_base/2;
  translate([bx/2,
      0,
      tower_h-Depth_of_roller_base/2 + b623_vgroove_small_r])
    difference(){
      translate([-bx/2, -w/2, -5])
        cube([bx, w, 9]);
      translate([-bx/2+b623_vgroove_small_r,0,-3])
        cylinder(d=d, h=10);
      translate([-bx/2,0,-5])
        scale(1.13)
        rotate([90,0,0])
        cylinder(r=b623_vgroove_big_r, h=Depth_of_roller_base+2, center=true,
                  $fn=14*4);
    }
}

//translate([0,0,tower_h-2.5])
//  eyelet();
//  for(k=[-30,0,30])
//  rotate([0,0,k])
//translate([-b623_vgroove_small_r*2,0,tower_h-2.5])
//  eyelet();

rotate([0,90,0])
translate([-b623_vgroove_small_r,0,0])
line_verticalizer(with_bearing=false);
module line_verticalizer(twod = false, with_bearing = false){
  wall_th = Line_roller_wall_th;
  if(!twod){
    difference(){
      union(){
        roller_wall_pair(space_between_walls, wall_th, tower_h);
        //preventor_edges(tower_h, space_between_walls, edge_stop=130);
        eyelet_holder(2*wall_th+space_between_walls);
        //translate([-b623_vgroove_small_r*2,0,0])
        rotate([0,0,180])
          eyelet_holder(2*wall_th+space_between_walls, 2);
      }
      bigr=27;
      // Alternative entry points for line
      for(k=[0,1])
        mirror([0,k,0])
          translate([b623_vgroove_small_r,0,0])
          rotate([0,0,30])
          translate([-b623_vgroove_small_r*2,bigr,tower_h])
          translate([0,-bigr,0])
          rotate([0,0,60])
          translate([0,bigr,0])
          rotate([0,90,0])
          rotate([0,0,220])
          rotate_extrude(angle=90, $fn=40)
          translate([bigr,0,0])
          circle(d=2);
      for(k=[0,1]) mirror([0,k,0])
        translate([-Depth_of_roller_base/2, -space_between_walls/2- wall_th, Base_th])
          rotate([0,0,180])
            corner_rounder(r1=3, r2=5, sq=[20,tower_h+5]);
      //translate([-Depth_of_roller_base/2,-space_between_walls/2-wall_th,0])
      //  inner_round_corner(r=2, h=26, $fn=5*4);
    }
  } else {
    roller_base(twod=true, space_between_walls=space_between_walls);
  }
}
