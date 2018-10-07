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
tower_h = Line_roller_ABC_winch_h;

//eyelet_holder(Depth_of_roller_base);
module eyelet_holder(w){
  bx = Depth_of_roller_base/2;
  translate([bx/2,
      0,
      tower_h-Depth_of_roller_base/2 + b623_vgroove_small_r])
    difference(){
      translate([-bx/2, -w/2, -5])
        cube([bx, w, 9]);
      translate([-bx/2+b623_vgroove_small_r,0,-3])
        cylinder(d=3.35, h=10);
      translate([-bx/2,0,-5])
        scale(1.13)
        rotate([90,0,0])
        cylinder(r=b623_vgroove_big_r, h=Depth_of_roller_base+2, center=true,
                  $fn=14*4);
    }
}

rotate([0,90,0])
translate([-b623_vgroove_small_r,0,0])
line_verticalizer(with_bearing=false);
module line_verticalizer(twod = false, with_bearing = false){
  line_roller_single(edge_stop=130, with_bearing=with_bearing);
  wall_w = Line_roller_wall_th;
  eyelet_holder(2*wall_w+space_between_walls);
}
