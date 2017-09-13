include <measured_numbers.scad>
include <util.scad>
include <design_numbers.scad>
use <Nema17_and_Ramps_and_bearings.scad>
use <Gears.scad>
use <render_parts.scad>
use <parts.scad>

// This file does all the little rotations and sets all the flags appropriate for generating printable stls for the Hangprinter v2

the_part = "";

if(the_part == "Bottom_plate_qty_1"){
  rotate([0,0,15])
    bottom_plate();
}

if(the_part == "Fancy_Ramps_holder_qty_1"){
  Fancy_Ramps_holder();
}

if(the_part == "Mirrored_worm_disc_w_torx_qty_1"){
  rotate([180,0,0])
    sandwich_gear(worm=true);
}

if(the_part == "Mirrored_worm_qty_1"){
  worm(step=0.07);
}

if(the_part == "Motor_gear_A_qty_1"){
  rotate([180,0,0])
    motor_gear_a();
}

if(the_part == "Motor_gear_B_qty_1"){
  rotate([180,0,0])
    motor_gear_b();
}

if(the_part == "Motor_gear_C_qty_1"){
  rotate([180,0,0])
    motor_gear_c();
}

if(the_part == "Sandwich_gear_w_torx_qty_3"){
  rotate([180,0,0])
    sandwich_gear(worm=false);
}

if(the_part == "Sandwich_spacer_qty_4"){
  sandwich_spacer(Sandwich_spacer_radius_1, Sandwich_spacer_radius_2, Sandwich_spacer_height);
}

if(the_part == "Side_plate_left_qty_1"){
  side_plate3();
}

if(the_part == "Side_plate_right_qty_1"){
  mirror([1,0,0])
    side_plate3();
}

if(the_part == "Side_plate_straight_qty_1"){
  side_plate2();
}

if(the_part == "Snelle_w_torx_qty_4"){
  snelle();
}

if(the_part == "Top_plate_qty_1"){
  rotate([180,0,15])
    top_plate();
}

if(the_part == "Sstruder_v2_adjustment_cylinder_qty_1"){
  sstruder_plate(only_pressblock_cyl=true);
}

if(the_part == "Sstruder_v2_lever_qty_1"){
  rotate([-90,0,0])
    sstruder_lever(false);
}

if(the_part == "Sstruder_v2_plate_qty_1"){
  sstruder_plate(false);
}

if(the_part == "Sstruder_v2_pressblock_handle_qty_1"){
  sstruder_plate(only_pressblock_handle=true);
}
