include <parameters.scad>
include <gear_parameters.scad>
use <sweep.scad>
use <util.scad>

motor_bracket();
module motor_bracket(){
  cw = Nema23_cube_width+6;
  cd = cw;
  wall_th = Wall_th + 0.5;
  bd = Motor_bracket_depth;
  flerp = 14;
  flerp_h = cw;
  flerp_r = 6;

  //windowed_cube([cd, bd-1, wall_th]);
  module windowed_cube(v){
      difference(){
        cube(v);
        // Hole to reach set screw
        window_w = 15;
        window_h = 15;
        translate([-window_w/2 + v[0]/2,v[1]-window_h-wall_th-1,-1])
          rounded_cube([window_w, window_h, v[2]+2], 1);
      }
  }

  difference(){
    union(){
      difference(){
        translate([-cd/2, -wall_th, -cw/2])
          cube([cd, wall_th, cw+2]);
        for(k=[0,1])
          mirror([k,0,0])
            translate([cw/2,0, -cw])
            rotate([0,0,2*90])
            inner_round_corner(r=3, h=2*cw, $fn=8*4);
        translate([0,0,1.5])
          rotate([90,0,0]){
            translate([0,0,-1]){
              cylinder(d=Nema23_ring_diameter+2, h=wall_th+2);
              Nema23_screw_holes(6.5, wall_th+2, $fs=1);
            }
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
                    cylinder(r=2.5, h=wall_th+2);
                }
              translate([0,flerp_h,-1])
                mirror([0,1,0])
                inner_round_corner(r=1, h=wall_th+2, $fn=4*8);
            }
          translate([-(-cd/2),-bd,-cw/2+0.3])
            rotate([0,-90,0])
            windowed_cube([cd-0.3, bd-3, wall_th]);
        }

      translate([-cd/2, -bd, -cw/2])
        windowed_cube([cd, bd-3, wall_th]);


      for(k=[0,1])
        mirror([k,0,0])
        translate([cw/2,-bd+wall_th,-cw/2])
        inner_round_corner(r=1, h=cw, $fn=4*8);

      // Round corners
      translate([0,0,-cw/2])
        linear_extrude(height=wall_th)
        translate([0,-2])
        rotate([0,0,90])
        translate([0,-cd/2])
        rounded_2corner([2, cd], 3, $fn=4*8);


      for(k=[0,1]){
        mirror([k,0,0]){

      translate([-cw/2+wall_th,-wall_th,-cw/2])
      rotate([0,0,-90])
      inner_round_corner(r=1, h=cw, $fn=8*4);

          translate([-cd/2+wall_th,-bd,-cw/2+wall_th])
            rotate([-90,0,0])
            rotate([0,0,-90])
            inner_round_corner(r=1, h=bd-1.1, $fn=8*4);
        }
      }

      translate([0,-wall_th,-cw/2+wall_th])
        rotate([0,90,0])
        rotate([0,0,180])
        translate([0,0,-(cd-1)/2])
        inner_round_corner(r=1, h=cd-1, $fn=8*4);
    }

    rotate([0,50,0])
      translate([-(Spool_pitch+Motor_pitch),0,0])
      rotate([-90,0,0])
      cylinder(r=Spool_outer_radius+1.5, h = 200, center=true, $fn = 50);
    translate([-20+7,-wall_th-1,0])
      cube(20);

    translate([0,0,50+cw/2])
      cube(100, center=true);

    screw_head_extra_h = 12;
    screw_head_extra_r = 2;
    for(k=[0,1])
      mirror([k,0,0]){
        translate([cd/2-wall_th,-bd+wall_th,-cw/2])
          rotate([90,0,0])
          translate([flerp-flerp/2+1,flerp/2,-1])
          rotate([0,0,90]){
            translate([0,0,-screw_head_extra_h+1])
              cylinder(r1=5.0, r2=5+screw_head_extra_r, h=screw_head_extra_h);
            translate([flerp_h-2*flerp/2,0,-screw_head_extra_h+1])
              cylinder(r1=5.0, r2=5+screw_head_extra_r, h=screw_head_extra_h);
            cylinder(r=2.5, h=wall_th+2);
          }
      }
  }
}
