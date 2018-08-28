include <parameters.scad>
use <util.scad>

motor_bracket_2d();
module motor_bracket_2d(){
  x_l = Nema17_cube_width+2*Motor_bracket_flerp;
  y_l = Motor_bracket_cw;
  difference(){
    translate([-x_l/2, -y_l/2,0])
      rounded_cube2([x_l,y_l], Motor_bracket_flerp_r);
    for(mirr=[[0,0], [1,0], [0,1]])
      mirror(mirr)
        translate([x_l/2-Motor_bracket_flerp/2+1,y_l/2-Motor_bracket_flerp/2])
          circle(d=Mounting_screw_d+0.5);
    rotate([0,0,Motor_bracket_att_ang])
      translate([-(Spool_pitch+Motor_pitch),0])
        circle(r=Spool_outer_radius+1.5, center=true, $fn = 50);
    translate([4,13])
    text("-+", 12);
  }
}
