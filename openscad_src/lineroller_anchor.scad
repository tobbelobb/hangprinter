include <parameters.scad>
include <lineroller_parameters.scad>
use <sweep.scad>
use <util.scad>
use <lineroller_ABC_winch.scad>

//#prev_art();
module prev_art(){
  import("../stl/lineroller_ptfe.stl");
}

//  translate([-track_l/2, -head_r])
//  rounded_2corner([track_l,2*head_r], head_r);
lineroller_anchor();
module lineroller_anchor(){
  base_th = 6;
  module base_al(){
    l = d + 2*Bearing_r + 2*Bearing_wall + flerp0 + flerp1;
    translate([-d/2-flerp0, -d/2, 0])
      difference(){
        rounded_cube2([l, d, base_th], d/2, $fn=10*4);
        track_l = l;
        head_r = 3.5;
        screw_r = 1.5;
        screw_head_h = 2;
        screw_h = 2;
        translate([l-d/2, d/2, -0.1]){
          rotate([0,0,180]){
            translate([0,0,screw_h+screw_head_h-0.01])
            linear_extrude(height=1)
              scale(1+(head_r-screw_r)/screw_r)
              translate([0,-screw_r])
              union(){
                square([track_l-screw_r, 2*screw_r]);
                translate([0,screw_r])
                  circle(r=screw_r,$fn=4*10);
              }
            linear_extrude(height=screw_h+1)
              translate([0,-screw_r])
              union(){
                square([track_l-screw_r, 2*screw_r]);
                translate([0,screw_r])
                  circle(r=screw_r,$fn=4*10);
              }
            translate([0,0,screw_h])
            linear_extrude(height=screw_head_h, scale=1+(head_r-screw_r)/screw_r)
              translate([0,-screw_r])
              union(){
                square([track_l-screw_r, 2*screw_r]);
                translate([0,screw_r])
                  circle(r=screw_r,$fn=4*10);
              }
          }
        }
      }
  }

  lineroller_ABC_winch(edge_start=0, edge_stop=90) base_al(flerp0=6, flerp1=4);
  line_entrance = Tower_flerp+Bearing_r-Bearing_wall-Bearing_small_r-0.25;
  difference(){
    union(){
      translate([-Lineroller_wall_th,-d/2,base_th-0.1])
        quarterround_wall([Lineroller_wall_th+0.01,
            d,
            Tower_flerp+Bearing_r-Bearing_wall-base_th+0.1],$fn=10*4);
      translate([0,0,line_entrance])
        rotate([0,-90,0])
        cylinder(r=4, h=Lineroller_wall_th + 3, $fs=1);
    }
    translate([0,0,line_entrance])
      rotate([0,-90,0])
      translate([0,0,-1])
      cylinder(r=Ptfe_r, h=Lineroller_wall_th+3+2, $fs=1);
  }
}
