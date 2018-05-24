include <parameters.scad>
use <util.scad>

motor_bracket();
module motor_bracket(){
  cw = Motor_bracket_cw;
  cd = cw;
  wall_th = Wall_th + 0.5;
  bd = Motor_bracket_depth;
  flerp = Motor_bracket_flerp;
  flerp_h = cw;
  flerp_r = Motor_bracket_flerp_r;
  max_m3_screw_head_d = 7.0;

  difference(){
    union(){
      difference(){
        translate([-cd/2, -bd,-cw/2])
          cube([cd, bd, cw]);
        for(k=[0,1])
          mirror([k,0,0])
            translate([cw/2,0, -cw])
            rotate([0,0,2*90])
            inner_round_corner(r=3, h=2*cw, $fn=8*4);
        translate([0,0,1.5])
          rotate([90,0,0]){
            translate([0,0,-1])
              Nema17_screw_holes(3.5, bd+2, $fs=1);
            translate([0,0,wall_th])
              Nema17_screw_holes(max_m3_screw_head_d, bd+2, teardrop=true, $fs=1);
          }
      }

      for(k=[[1,0,0], [0,0,0]])
        mirror(k){
          translate([cd/2-wall_th,-bd+wall_th,-cw/2])
            rotate([90,0,0])
            difference(){
              linear_extrude(height=wall_th)
                rounded_2corner([flerp, flerp_h], flerp_r, $fn=4*6);
              translate([flerp-flerp/2+1,flerp/2,-1])
                rotate([0,0,90]){
                  translate([flerp_h-2*flerp/2,0,0])
                    cylinder(d=Mounting_screw_d+0.5, h=wall_th+2);
                }
            }
        }

      for(k=[0,1])
        mirror([k,0,0])
        translate([cw/2,-bd+wall_th,-cw/2])
        inner_round_corner(r=1, h=cw, $fn=4*8);
    }

    // Allow at least a 10 mm screw in for Nema17 fastening
    setscrew_opening_h = max(max_m3_screw_head_d+4, 10);
    setscrew_opening_d = Nema17_screw_hole_width;
    translate([0,0,1.5])
      rotate([90,0,0]){
        translate([0,0,-1])
          cylinder(d=Nema17_ring_diameter+5, h=bd+2);
        translate([0,0,wall_th])
          cylinder(d=setscrew_opening_d, h = setscrew_opening_h, $fn = 50);
      }

    rotate([0,Motor_bracket_att_ang,0])
      translate([-(Spool_pitch+Motor_pitch),0,0])
      rotate([-90,0,0]){
        cylinder(r=Spool_outer_radius+1.5, h = 200, center=true, $fn = 50);
      }

    // Cut overhanging tip
    translate([-20+7,-bd-1,0])
      cube([20,bd+2,20]);

    screw_head_extra_h = 12;
    screw_head_extra_r = 2;
    for(k=[0,1])
      mirror([k,0,0]){
        translate([cd/2-wall_th,-bd+wall_th,-cw/2])
          rotate([90,0,0])
          translate([flerp-flerp/2+1,flerp/2,-1])
          rotate([0,0,90]){
            translate([0,0,-screw_head_extra_h+1])
              cylinder(d1=Mounting_screw_head_d-4, d2=Mounting_screw_head_d, h=screw_head_extra_h);
            translate([flerp_h-2*flerp/2,0,-screw_head_extra_h+1])
              cylinder(d1=Mounting_screw_head_d-4, d2=Mounting_screw_head_d, h=screw_head_extra_h);
            cylinder(d=Mounting_screw_d+0.5, h=wall_th+2);
          }
      }
  }
}
