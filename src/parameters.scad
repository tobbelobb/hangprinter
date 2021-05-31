// Parameters shared between modules
Base_th = 2;
Beam_width = 15;
Wiggle = 0.25;
Fat_beam_width = Beam_width + Wiggle;
Beam_length = 400;
Wall_th = 2.5;
Min_beam_width = 12.5;
Max_beam_width = 17.5;
Zip_th = 2;
Zip_h = Zip_th + Max_beam_width - Min_beam_width;
Zip_w = 5.0;
Nema17_cube_width          = 42.43;
Nema17_screw_hole_width    = 43.74; // Opposite corner screws
Nema17_ring_diameter       = 22;
Nema17_cube_height         = 39.36;
Nema17_shaft_height        = 63.65;
Nema17_ring_height         = 2;
Nema17_shaft_radius        = 5/2;
b608_outer_dia = 22.2;
b608_width = 7.05;
b608_bore_r = 4;
Gap_between_sandwich_and_plate = 1.5 + Base_th; // 1.5 mm for wiggle
Motor_bracket_flerp_r = 6;
Motor_bracket_flerp = 14;
Motor_bracket_cw = Nema17_cube_width + 6;
Motor_bracket_att_ang = 50;
Mounting_screw_d = 3.5;
Mounting_screw_head_d = 14;
Spool_outer_wall_th = 4;

// Corner clamp parameters
Cc_l1 = (Fat_beam_width+2*Wall_th)*2*sqrt(3);
Cc_rad_b = 4;
Cc_action_point_from_mid = Cc_l1/sqrt(3)-2*Cc_rad_b-7;  // 5 chosen arbitrarily
Cc_plastic_length = sqrt(Cc_action_point_from_mid*Cc_action_point_from_mid
                       - (Cc_action_point_from_mid/2)*(Cc_action_point_from_mid/2));

// The distance between the two action points on the mover
Sidelength = Beam_length + 2*Cc_plastic_length;

/////// Gear parameters ////////////
Circular_pitch = 262;
Motor_teeth = 10;
Gear_height = 21.4-3;
Motor_pitch                      = (Motor_teeth*Circular_pitch/360);
Motor_pitch_diametrial           = Motor_teeth/(2*Motor_pitch);
Motor_outer_radius               = Motor_pitch + 1/Motor_pitch_diametrial;
Spool_teeth = 100;
Spool_r = 75;
Spool_height = 8;
Spool_pitch                      = (Spool_teeth*Circular_pitch/360);
Spool_pitch_diametrial           = Spool_teeth/(2*Spool_pitch);
Spool_outer_radius               = Spool_pitch + 1/Spool_pitch_diametrial;
Sep_disc_radius = 161.83/2; // Made to match 255 teeth gt2 pulley
Motor_bracket_depth = Gear_height+1+7+Nema17_ring_height+1+Gap_between_sandwich_and_plate;
Spool_core_flerp0 = 16+3;

/////// Lineroller parameters ////////////
b623_width  = 4;
b623_bore_r = 3/2;
b623_vgroove_big_r = 12/2;
b623_vgroove_small_r = 10/2;
b623_outer_dia = 10;

Depth_of_roller_base = 18;
Roller_flerp = 6;
Roller_l = 42;
Roller_fl = (Roller_l - Depth_of_roller_base)/2;

Line_roller_wall_th = 5;

Line_roller_ABC_winch_h =  Gap_between_sandwich_and_plate
                           + Sep_disc_radius
                           - Spool_r
                           + Depth_of_roller_base/2
                           + b623_vgroove_small_r;


Ptfe_r = 2.1;
Roller_base_r = 8;
Screw_h = 2;
Screw_head_h = 2;
M3_screw_head_d = 5.8;
Spool_center_bearing_wall_th = 5;
Corner_clamp_bearings_center_to_center = 15;
Anchor_bearings_center_to_center = Corner_clamp_bearings_center_to_center + b623_outer_dia;

//// Lineroller anchor parameters /////

Back_bearing_x = b623_vgroove_big_r + 1.5;
Front_bearing_x = -b623_vgroove_big_r - 5;
Move_tower = -12.2;
Lower_bearing_z = 13;
Higher_bearing_z = Lower_bearing_z + Corner_clamp_bearings_center_to_center;

//// Cable Clamp parameters /////
Bit_width = 12;
Cable_r=2.5;


//// Donkey and encoder parameters /////

Donkey_shaft_d = 6;
Donkey_h = 65.12;
Donkey_body_d = 50;
Donkey_feet_th = 3.5;

Encoder_LDP3806_shaft_d = 6;
Encoder_LDP3806_d = 38;

// Belt drive parameters
GT2_belt_width = 6.5;
GT2_gear_height = GT2_belt_width + 2;
GT2_motor_gear_height = 16;
GT2_motor_gear_outer_dia = 16;
GT2_spool_gear_teeth = 255;
GT2_motor_gear_teeth = 20;
Torx_depth = GT2_gear_height/2;
Belt_roller_h = 56;
Belt_thickness = 1.4;

// Spacer parameters
Sandwich_ABC_width = 2*(1+Spool_height) + GT2_gear_height;
Sandwich_D_width = 3*(1+Spool_height) + GT2_gear_height;

Spacer_ABC_width = Sandwich_ABC_width - 2*b608_width;
Spacer_D_width = Sandwich_D_width -2*b608_width;


spd = Spool_height+GT2_gear_height;
// Horizontal_deflector_cube_y_size must be exact this number
// because we want to deflect AB-lines
// 60 degrees on the ceiling unit, and we want to put two
// deflectors in a row and get a distance between bearings
// that maintain the distance d when deflecting 60 degrees
Horizontal_deflector_cube_y_size = (2/sqrt(3))*spd;


// Top plate parameters needed for layout slicer
Yshift_top_plate = -297.8;
