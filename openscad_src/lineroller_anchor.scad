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
  flerp0=6;
  flerp1=4;
  l = d + 2*Bearing_r + 2*Bearing_wall + flerp0 + flerp1;
  track_l = l;
  head_r = 3.5;
  screw_r = 1.5;
  screw_head_h = 2;
  screw_h = 2;

  module base_al(){
    translate([-d/2-flerp0, -d/2, 0])
      rounded_cube2([l, d, base_th], d/2, $fn=10*4);
  }

  module slot_for_countersunk_screw(){
    translate([-d/2-flerp0, -d/2, 0]){
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

  difference(){
    lineroller_ABC_winch(edge_start=0, edge_stop=90) base_al();
    slot_for_countersunk_screw();
  }
}
