include <../lib/parameters.scad>
include <lib/layout_lib.scad>
include <lib/layout_params.scad>

//translate([0,0,Gap_between_sandwich_and_plate])
//!sandwich_I();
module sandwich_I(){
  translate([0,0, (1 + Spool_height)]){
    color(color2, color2_alpha)
      if(stls) import("../../stl/GT2_spool_gear.stl");
      else GT2_spool_gear();
    translate([0,0,Torx_depth + 2*(1 + Spool_height) + GT2_gear_height/2])
      rotate([0,180,0]){
        color(color1, color1_alpha)
          if(stls){
            import("../../stl/dleft_spool.stl");
            translate([0,0,1+Spool_height])
              import("../../stl/sep_disc.stl");
          } else {
            dleft_spool();
            translate([0,0,1+Spool_height])
              sep_disc();
          }
        color(color1, spool_cover_alpha)
          translate([0,0,-Spool_cover_bottom_th-Spool_cover_shoulder])
            rotate([0,0,90])
              if (stls) import("../../stl/dleft_spool_cover.stl");
              else dleft_spool_cover();
      }
  }
  color(color1, color1_alpha){
    if(stls) import("../../stl/dright_spool_top.stl");
    else dright_spool_top();
    translate([0,0,-Spool_height-1])
    if(stls) import("../../stl/dright_spool_bottom.stl");
    else dright_spool_bottom();
    translate([0,0,-Spool_cover_bottom_th-Spool_cover_shoulder - Spool_height - 1])
      rotate([0,0,-90])
        if (stls) import("../../stl/dright_spool_cover.stl");
        else dright_spool_cover();
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
          render_motor_and_bracket(D=true);
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
