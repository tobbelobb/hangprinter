include <../lib/parameters.scad>
include <lib/layout_lib.scad>
include <lib/layout_params.scad>

use <../sep_disc.scad>
use <../iright_spool_top.scad>
use <../iright_spool_cover.scad>
use <../iright_spool_bottom.scad>
use <../ileft_spool.scad>
use <../ileft_spool_cover.scad>
use <../GT2_spool_gear.scad>
use <../horizontal_line_deflector.scad>

//translate([0,0,Gap_between_sandwich_and_plate])
//!sandwich_I();
module sandwich_I(){
  translate([0,0, (1 + Spool_height)]){
    color(Color2, Color2_alpha)
      if(stls) import("../../stl/GT2_spool_gear.stl");
      else GT2_spool_gear();
    translate([0,0,Torx_depth + 2*(1 + Spool_height) + GT2_gear_height/2])
      rotate([0,180,0]){
        color(Color1, Color1_alpha)
          if(stls){
            import("../../stl/ileft_spool.stl");
            translate([0,0,1+Spool_height])
              import("../../stl/sep_disc.stl");
          } else {
            ileft_spool();
            translate([0,0,1+Spool_height])
              sep_disc();
          }
        color(Color1, Spool_cover_alpha)
          translate([0,0,-Spool_cover_bottom_th-Spool_cover_shoulder])
            rotate([0,0,90])
              if (stls) import("../../stl/ileft_spool_cover.stl");
              else ileft_spool_cover();
      }
  }
  color(Color1, Color1_alpha){
    translate([0,0,-(Spool_height + 1)])
    if(stls) {
      import("../../stl/iright_spool_top.stl");
      translate([0,0,Spool_height + 1])
        import("../../stl/sep_disc.stl");
    }
    else {
      iright_spool_top();
      translate([0,0,Spool_height + 1])
        sep_disc();
    }
    translate([0,0,-2*(Spool_height + 1)])
    if(stls) import("../../stl/iright_spool_bottom.stl");
    else iright_spool_bottom();
    translate([0,0,-Spool_cover_bottom_th-Spool_cover_shoulder - 2*(Spool_height + 1)])
      rotate([0,0,-90])
        if (stls) import("../../stl/iright_spool_cover.stl");
        else iright_spool_cover();
  }
}


//!placed_sandwich_I();
module placed_sandwich_I(){
    translate([0,
        -1-Spool_height - GT2_gear_height/2,
        Sep_disc_radius+Gap_between_sandwich_and_plate])
      rotate([90,0,180])
      sandwich_I();
}


module render_motor_and_bracket_I(){
  if (stls && !twod)
    import("../../stl/motor_bracket_I.stl");
  else
    motor_bracket_I(twod=twod);
  motor();
  gear();
}


//line_deflector(9,false);
module line_deflector(rot_around_center=0, center=false){
  module line_deflector_always_center(){
      rotate([0,0,rot_around_center]) // Rotate around bearing center
      translate([0,b623_big_ugroove_small_r-3,0])
      if(stls && !twod){
        rotate([-90,0,0])
          import("../../stl/horizontal_line_deflector.stl");
      } else {
        horizontal_line_deflector(twod=twod);
      }
  }
  if(center){
    line_deflector_always_center();
  } else {
    translate([0,-b623_big_ugroove_small_r,0])
      line_deflector_always_center();
  }
}



//placed_line_verticalizer();
module placed_line_verticalizer(angs=[45,-45,45,-45]){
  center_it = 0;
  four = [0,90,180,270];

  color(Color1, Color1_alpha)
  translate([0,0,0])
  for(k=[0:3])
    rotate([0,0,-45+four[k]])
      translate([-Sidelength/sqrt(2)-Move_i_bearings_inwards,0,0])
        rotate([0,0,angs[k]])
          translate([center_it,0,0])
            if(stls && !twod){
              rotate([0,-90,0])
              import("../../stl/line_verticalizer.stl");
            } else {
              translate([-b623_big_ugroove_small_r,0,0])
                line_verticalizer(twod=twod);
            }
  translate([lx0-b623_big_ugroove_small_r,
             Sidelength/sqrt(6)+Move_i_bearings_inwards/2-b623_big_ugroove_small_r-b623_width/2-1,
             0])
    line_deflector(-67, center=true);
  translate([lxm1, 233, 0])
    rotate([0,0,90])
      if(stls && !twod){
        import("../../stl/line_roller_wire_rewinder.stl");
      } else {
        line_roller_wire_rewinder(twod=twod);
      }
  translate([lx1+b623_big_ugroove_small_r,
             Sidelength/sqrt(6)+Move_i_bearings_inwards/2-b623_big_ugroove_small_r-b623_width/2-1,
             0])
    line_deflector(67, center=true);
  translate([lx2+b623_big_ugroove_small_r, ly2-b623_big_ugroove_small_r,0])
    line_deflector(63, center=true);
  translate([-b623_big_ugroove_small_r+b623_width/2+1+3*Spool_height,ly2-b623_big_ugroove_small_r,0])
    line_deflector(-90-90-90, center=true);
}



placed_winch_unit_I();
module placed_winch_unit_I(){
  translate([0,ispool_y,0])
    rotate([0,0,-90]) {
      if(!twod){
        placed_sandwich_I();
      }
      translate([Belt_roller_bearing_xpos,0,0]){
        rotate([0,0,90])
          render_motor_and_bracket_I();
        belt_roller_bearings();
      }
      if(!twod) {
        // Smooth rod
        color("grey")
          translate([0,Smooth_rod_length_I-7, Sep_disc_radius + Gap_between_sandwich_and_plate])
            rotate([90,0,0])
              translate([0,0,(Sandwich_ABCD_width - Sandwich_I_width)/2])
                cylinder(d=8, h=Smooth_rod_length_I, center=true);
        belt();
      }

  }
  // TODO: Fix these lines...
  line_from_to([lx1, bcspool_y, hz],
               [lx1, Sidelength/sqrt(6)+Move_i_bearings_inwards/2-b623_width/2-1, hz]);
  line_from_to([lx1, Sidelength/sqrt(6)+Move_i_bearings_inwards/2-b623_width/2-1, hz],
               [Sidelength/2, Sidelength/sqrt(6)+Move_i_bearings_inwards/2-b623_width/2-1, hz]);
  line_from_to([spd + lx2, bcspool_y, hz],
               [spd + lx2, ly2, hz]);
  line_from_to([spd + lx2, ly2, hz],
               [spd , ly2, hz]);
  line_from_to([spd , 0, hz],
               [spd , -Sidelength/sqrt(3)-Move_i_bearings_inwards, hz]);



  placed_line_verticalizer();

}



