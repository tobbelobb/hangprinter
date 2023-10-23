include <../../lib/parameters.scad>
include <layout_params.scad>

use <../../lib/util.scad>
use <../../new_tilted_line_deflector.scad>
use <../../motor_bracket_A.scad>
use <../../motor_bracket_B.scad>
use <../../motor_bracket_C.scad>
use <../../motor_bracket_D.scad>
use <../../motor_bracket_I.scad>

//tilted_line_deflector_for_layout();
module tilted_line_deflector_for_layout(ang){
  translate([-10, 0,0])
    if(stls && !twod){
      rotate([0,0,-90])
        import("../../stl/new_tilted_line_deflector.stl");
    } else {
      rotate([0,0,-90])
        new_tilted_line_deflector(twod=twod, for_render=true, ang=ang);
    }
}


//!union() {
//  belt();
//
//  translate([ -13.5, -33, 35 ]) rotate([ 180, 0, 0 ])
//      import("../../stl/for_render/whitelabel_motor.stl");
//
//   translate([-GT2_motor_gear_height+1.5+(GT2_motor_gear_height-7.4-1.5)/2,0,0])
//     color([0.75,0.75,0.75])
//       translate([0,-33,35]) // Up to motor shaft center
//         rotate([0,90,0])
//           import("../../stl/for_render/GT2_motor_gear.stl");
//}
module belt(){
  module motor_belt_shape(){
    motor_gear_to_belt_idler = 35.5;
    rotate([0,90,0])
      difference(){
        cylinder(d=GT2_motor_gear_outer_dia + 2*Belt_thickness, h=GT2_belt_width);
        translate([0,0,-1])
          cylinder(d=GT2_motor_gear_outer_dia, h=GT2_belt_width + 2);
        translate([-8,0,-GT2_belt_width])
          rotate([0,0,-4])
            cube([15,15,2*GT2_belt_width+2]);
        translate([-7.0,0.8,-GT2_belt_width])
          rotate([0,0,-11.1])
            cube([15,15,2*GT2_belt_width+2]);
      }
    rotate([-11.1,0,0])
      translate([0,0,-GT2_motor_gear_outer_dia/2 - Belt_thickness])
        cube([GT2_belt_width, 120, Belt_thickness]);
    rotate([-3,0,0])
      translate([0,0,GT2_motor_gear_outer_dia/2])
        cube([GT2_belt_width, 35, Belt_thickness]);
    translate([0,motor_gear_to_belt_idler+b623_outer_dia+Belt_thickness,b623_outer_dia])
      rotate([88,0,0])
        translate([0,0,GT2_motor_gear_outer_dia/2])
          cube([GT2_belt_width, 45, Belt_thickness]);
  }

    color([0.30,0.30,0.30], 0.8){
      translate([Belt_roller_bearing_xpos,0,0])
        rotate([0,0,90])
          translate([-GT2_belt_width/2,0,0])
            color([0.75,0.75,0.75])
              translate([0,-33,35]) // Up to motor shaft center
                 motor_belt_shape();

        spool_gear_outer_dia = 161.83;
        translate([0,0,Gap_between_sandwich_and_plate + Sep_disc_radius])
          rotate([0,90,90])
            difference(){
              cylinder(d=spool_gear_outer_dia + 2*Belt_thickness, h=GT2_belt_width, center=true, $fn=12*5);
              cylinder(d=spool_gear_outer_dia, h=GT2_belt_width + 2, center=true, $fn=12*5);
              rotate([0,0,-11.1])
                translate([0,-spool_gear_outer_dia/2+10,-GT2_belt_width])
                  cube([spool_gear_outer_dia/2,spool_gear_outer_dia/2-10,2*GT2_belt_width]);
              rotate([0,0,-1])
                translate([-4,-spool_gear_outer_dia/2+0.1,-GT2_belt_width])
                  cube([spool_gear_outer_dia/3,spool_gear_outer_dia/2,2*GT2_belt_width]);
            }
      }
}

//!belt_roller_bearings();
module belt_roller_bearings(){
  belt_roller_bearing_center_z = Belt_roller_h - Depth_of_roller_base/2;
  if (!twod)
    for(rot=[90,-90])
      translate([0,0,belt_roller_bearing_center_z])
        rotate([rot,0,0])
          translate([0,0,-b623_width-0.1])
            b623_flanged();
}


//!render_motor_and_bracket();
module render_motor_and_bracket(leftHanded=false, A=false, B=false, C=false, D=false, I=false){
  if (stls && !twod) {
    if(A)
      import("../../stl/motor_bracket_A.stl");
    else if (B)
      import("../../stl/motor_bracket_B.stl");
    else if (C)
      import("../../stl/motor_bracket_C.stl");
    else if (D)
      import("../../stl/motor_bracket_D.stl");
    else // use I as default...
      import("../../stl/motor_bracket_I.stl");
  } else {
    if(A)
      motor_bracket_A(twod=twod);
    else if (B)
      motor_bracket_B(twod=twod);
    else if (C)
      motor_bracket_C(twod=twod);
    else if (D)
      motor_bracket_D(twod=twod);
    else // use I as default...
      motor_bracket_I(twod=twod);
  }

  module motor(ang=0) {
    if (!twod)
      translate([-13.5,-33,35])
        rotate([ang,0,0])
          import("../../stl/for_render/whitelabel_motor.stl");
          //whitelabel_motor_render();
  }

  module gear(){
    if(!twod)
      translate([-GT2_motor_gear_height+1.5+(GT2_motor_gear_height-7.4-1.5)/2,0,0]){
        color([0.75,0.75,0.75])
          translate([0,-33,35]) // Up to motor shaft center
            rotate([0,90,0])
              //GT2_motor_gear(5.02);
              import("../../stl/for_render/GT2_motor_gear.stl");
      }
  }

  color([0.5,0.4,0.9])
    if(A)
      mirror([1,0,0])
        motor();
    else if(B)
      mirror([1,0,0])
        motor();
    else if(C)
      motor();
    else if(D)
      motor();

  if (A || B)
    mirror([1,0,0])
      gear();
  else
    gear();

}


//translate([0,0,Gap_between_sandwich_and_plate])
//!sandwich_ABCD();
module sandwich_ABCD(){
  translate([0,0, 1 + Spool_height]){
    color(Color2, Color2_alpha)
      if(stls) import("../../stl/GT2_spool_gear.stl");
      else GT2_spool_gear();
    translate([0,0,Torx_depth + 1 + Spool_height + GT2_gear_height/2])
      rotate([0,180,0]){
        color(Color1, Color1_alpha)
          if(stls) import("../../stl/spool_mirrored.stl");
          else spool_mirrored();
        color(Color1, Spool_cover_alpha)
          translate([0,0,-Spool_cover_bottom_th-Spool_cover_shoulder])
            rotate([0,0,-90])
              if (stls) import("../../stl/spool_cover.stl");
              else spool_cover();
      }
  }
  color(Color1, Color1_alpha)
    if(stls) import("../../stl/spool.stl");
    else spool();
  color(Color1, Spool_cover_alpha)
    translate([0,0,-Spool_cover_bottom_th-Spool_cover_shoulder])
      rotate([0,0,90])
        if (stls) import("../../stl/spool_cover_mirrored.stl");
        else spool_cover_mirrored();
}

//!sandwich_and_motor_ABCD();
module sandwich_and_motor_ABCD(leftHanded=false, A=false, B=false, C=false, D=false){
  cover_adj=Spool_core_cover_adj;
  if(!twod)
    translate([0,
        Sandwich_ABCD_width/2,
        Sep_disc_radius+Gap_between_sandwich_and_plate])
      rotate([90,0,0])
        sandwich_ABCD();
  translate([Belt_roller_bearing_xpos,0,0])
    rotate([0,0,90])
      render_motor_and_bracket(leftHanded, A=A, B=B, C=C, D=D, I=false);
  translate([Belt_roller_bearing_xpos,0,0])
    belt_roller_bearings();

  if(!twod) {
    // Smooth rod
    color("grey")
      translate([0,-Smooth_rod_length_ABCD,Sep_disc_radius + Gap_between_sandwich_and_plate])
        rotate([90,0,0])
          cylinder(d=8, h=Smooth_rod_length_ABCD, center=true);
    color("grey")
      translate([0,Smooth_rod_length_ABCD,Sep_disc_radius + Gap_between_sandwich_and_plate])
        rotate([90,0,0])
          cylinder(d=8, h=Smooth_rod_length_ABCD, center=true);
    // Belt
    belt();
  }
}

//!line_guides_BC();
module line_guides_BC(){
  translate([move_BC_deflectors+spd/sqrt(3)+1,spd/2,0])
    rotate([0,0,180])
      tilted_line_deflector_for_layout(-55);
}


