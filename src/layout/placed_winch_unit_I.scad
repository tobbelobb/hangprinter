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
use <../line_verticalizer.scad>
use <../line_roller_wire_rewinder.scad>

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
  //color([0.9,0.9,0.9], 0.2)
    if(center){
      line_deflector_always_center();
    } else {
      translate([0,-b623_big_ugroove_small_r,0])
        line_deflector_always_center();
    }
}


//placed_I_line_deflectors();
module placed_I_line_deflectors(angs=[45,-45,45,-45]){
  r = b623_big_ugroove_small_r;
  half_pivot_w = Sidelength/2 - Move_i_bearings_inwards/2;

  l0_x = GT2_gear_height/2 + Spool_height + 1 + Spool_height/2;
  l0_y = 100;
  diff0_x = 21.5;
  offs0_y = -15;

  l1_x = Spool_height/2 + GT2_gear_height/2;
  l1_y = 140;
  diff1_x = 40.6;

  squeeze = 0.75;

  l2_x = -l1_x;

  l3_x = -l0_x;

  l4_x = l3_x - (Spool_height + 1);

  color(Color1, Color1_alpha)
    for(k=[0:3])
      rotate([0,0,-45+k*90])
        translate([-Sidelength/sqrt(2)-Move_i_bearings_inwards,0,0])
          rotate([0,0,angs[k]])
            if(stls && !twod){
              rotate([0,-90,0])
              import("../../stl/line_verticalizer.stl");
            } else {
              translate([-r,0,0])
                line_verticalizer(twod=twod);
            }
  translate([l4_x, l0_y, 0])
    rotate([0,0,90])
      if(stls && !twod){
        import("../../stl/line_roller_wire_rewinder.stl");
      } else {
        line_roller_wire_rewinder(twod=twod);
      }

  // Line 0
  translate([0,0,0]){
  line_from_to([l0_x , ispool_y, hz],
               [l0_x , l0_y, hz], twod=twod);
  line_from_to([l0_x + r, l0_y + r, hz],
               [l0_x + diff0_x , l0_y + r, hz], twod=twod);
  line_from_to([l0_x + diff0_x + r, l0_y + offs0_y, hz],
               [l0_x + diff0_x + r, -half_pivot_w + r, hz], twod=twod);
  line_from_to([l0_x + diff0_x, -half_pivot_w, hz],
               [-half_pivot_w, -half_pivot_w, hz], twod=twod);
  }
  translate([l0_x + r, l0_y, 0])
    line_deflector(45, center=true);
  translate([l0_x + diff0_x, l0_y+offs0_y, 0])
    line_deflector(-90-45, center=true);
  translate([l0_x + Spool_height/2 + 2 + diff0_x - r + squeeze,
    -half_pivot_w + r,0])
    line_deflector(2*45, center=true);

  // Line 1
  translate([0,0,0]){
  line_from_to([l1_x, ispool_y, hz],
               [l1_x, l1_y, hz], twod=twod);
  line_from_to([l1_x + r, l1_y + r, hz],
               [l1_x + diff1_x, l1_y + r, hz], twod=twod);
  line_from_to([l1_x + diff1_x + r, l1_y, hz],
               [l1_x + diff1_x + r, -half_pivot_w + r, hz], twod=twod);
  line_from_to([l1_x + diff1_x + 2*r, -half_pivot_w, hz],
               [half_pivot_w, -half_pivot_w, hz], twod=twod);
  }
  translate([l1_x + r, l1_y, 0])
    line_deflector(45, center=true);
  translate([l1_x + diff1_x, l1_y, 0])
    line_deflector(-45, center=true);
  translate([l1_x + Spool_height/2 + 2 + diff1_x + r - squeeze,
    -half_pivot_w + r,0])
    line_deflector(-2*45, center=true);

  // Line 2
  translate([0,0,0]){
  line_from_to([l2_x , ispool_y, hz],
               [l2_x , half_pivot_w-r, hz], twod=twod);
  line_from_to([l2_x + r, half_pivot_w, hz],
               [half_pivot_w, half_pivot_w, hz], twod=twod);
  }
  translate([l2_x + r,
             half_pivot_w - r,
             0])
    line_deflector(-90, center=true);

  // Line 3
  translate([0,0,0]){
  line_from_to([l3_x , ispool_y, hz],
               [l3_x , half_pivot_w-r, hz], twod=twod);
  line_from_to([l3_x - r, half_pivot_w, hz],
               [-half_pivot_w, half_pivot_w, hz], twod=twod);
  }
  translate([l3_x - r,
             half_pivot_w - r,
             0])
    line_deflector(90, center=true);
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
        color("grey"){
          translate([0,-4.5 + Smooth_rod_length_I, Sep_disc_radius + Gap_between_sandwich_and_plate])
            rotate([90,0,0])
              cylinder(d=8, h=Smooth_rod_length_I, center=true);
          translate([0,-4.5 - Smooth_rod_length_I, Sep_disc_radius + Gap_between_sandwich_and_plate])
            rotate([90,0,0])
              cylinder(d=8, h=Smooth_rod_length_I, center=true);
        }
        belt();
      }

  }
  placed_I_line_deflectors();
}



