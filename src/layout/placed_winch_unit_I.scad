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


placed_winch_unit_I();
module placed_winch_unit_I(){
  translate([0,ispool_y,0])
    rotate([0,0,-90]) {
      if(!twod){
        placed_sandwich_I();
      }
      translate([Belt_roller_bearing_xpos,0,0]){
        rotate([0,0,90])
          render_motor_and_bracket(I=true);
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
}
