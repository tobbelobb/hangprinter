include <lib/parameters.scad>
use <lib/util.scad>

pen_holder_moving_part();
module pen_holder_moving_part(){
  w = Pen_holder_w;
  rail_w = Pen_holder_rail_w;
  m_bottom_th = 2;
  d = 23.9;
  arm_th = 6;
  lin_bearing_grip_th = 2.045;
  lin_bearing_d = 14.91;
  grip_cube_w = lin_bearing_d + 2*lin_bearing_grip_th;
  module grip_arm(cut_h=5.5){
    translate([-rail_w/2, -d/2+arm_th, m_bottom_th+15/2])
      rotate([90,0,0])
        difference(){
          translate([-grip_cube_w/2,-lin_bearing_d/2-m_bottom_th,0]){
            cube([grip_cube_w, lin_bearing_d/2+m_bottom_th, arm_th]);
            translate([grip_cube_w/2,lin_bearing_d/2+m_bottom_th,0])
              cylinder(d=grip_cube_w, h=arm_th);
          }
          difference(){
            cylinder(d=lin_bearing_d, h=w+2, center=true, $fn=2*24);
            translate([0,0,arm_th-3.2])
              ring(d1 = lin_bearing_d+0.1, d2 = lin_bearing_d - 0.1, h=0.6);
          }
          translate([-grip_cube_w/2,cut_h,-1])
            cube([grip_cube_w, lin_bearing_d, arm_th+2]);
        }
  }


  translate([-w/2, -d/2, 0])
    cube([w, d, m_bottom_th]);

  for(l=[0,1]) mirror([0,l,0])
    for(k=[0,1]) mirror([k,0,0])
      grip_arm();
  mid_x = 13.5;
  mid_z = 32.75;
  spring_x = 4;
  holder_d = d;
  difference(){
    union(){
      translate([-mid_x/2,-holder_d/2,0])
        cube([mid_x, holder_d, mid_z]);
      translate([0,0,17])
        rotate([90,0,0])
          cylinder(d=mid_x+6, h=holder_d, center=true, $fn=48);
    }
    translate([-spring_x/2, -holder_d/2-1, m_bottom_th])
      cube([spring_x, holder_d+2, mid_z]);
    translate([0,0,17])
      rotate([90,0,0]){
        cylinder(d=mid_x-4, h=holder_d+2, center=true, $fn=48);
        cylinder(d=mid_x-3, h=holder_d-6, center=true, $fn=48);
      }
    for(l=[0,1]) mirror([0,l,0])
      for(k=[0,1]) mirror([k,0,0])
        translate([-rail_w/2,-d+2*arm_th,0])
          scale(1.184)
            translate([rail_w/2,d-2*arm_th,0])
              grip_arm(cut_h=8);
    for(k=[0,1]) mirror([0,k,0])
      translate([0,7,0]) {
        hull(){
          for(z = [mid_z - 4.25, mid_z - 3.15])
            translate([0,0,z])
              rotate([0,90,0])
                cylinder(d=3.3, h=mid_x+2, center=true, $fn=12);
        }
        translate([2.5/2+spring_x/2+(mid_x/2-spring_x/2)/2,0,mid_z-7])
          rotate([0,0,90])
            translate([-5.6/2,0,0])
              point_cube([5.6,2.5,11],120);
      }
  }
}
