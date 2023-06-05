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

Nema23_cube_width          = 56.4;
Nema23_cube_height         = 54.5;
Nema23_shaft_height        = 100;
Nema23_screw_hole_width    = 66.31; // Opposite corner screws
b608_outer_dia = 22.2;
b608_width = 7.05;
b608_bore_r = 4;
b608_vgroove_big_r = b608_outer_dia/2 + 2.5;
b608_vgroove_small_r = b608_outer_dia/2 + 0.5;
b608_ugroove_big_r = b608_vgroove_big_r;
b608_ugroove_small_r = b608_vgroove_small_r;
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
Cc_action_point_from_mid = Cc_l1/sqrt(3)-2*Cc_rad_b-7;
Cc_plastic_length = sqrt(Cc_action_point_from_mid*Cc_action_point_from_mid
                       - (Cc_action_point_from_mid/2)*(Cc_action_point_from_mid/2));
Eyelet_extra_dist = 0.75;
Eyelet_diameter = 4.30;
Move_d_bearings_inwards = -2;

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
Sep_disc_radius = (161.83+1)/2; // Made to match 255 teeth gt2 pulley + 1
Motor_bracket_depth = Gear_height+1+7+Nema17_ring_height+1+Gap_between_sandwich_and_plate;
Spool_core_flerp0 = 16+3;

/////// Lineroller parameters ////////////
b623_width  = 4;
b623_bore_r = 3/2;
b623_big_ugroove_big_r = (12+3)/2;
b623_big_ugroove_small_r = (10+3)/2;
b623_outer_dia = 10;
b623_ugroove_room_to_grow_r = 1.1;
b608_ugroove_room_to_grow_r = 1.1;
b623_flange_dia = 11.5;
b623_flange_room_to_grow_r = 0.5;

Depth_of_roller_base = 18;
Roller_flerp = 6;
Roller_l = 42;
Roller_fl = (Roller_l - Depth_of_roller_base)/2;

Line_roller_wall_th = 5;

Line_roller_ABC_winch_h =  Gap_between_sandwich_and_plate
                           + Sep_disc_radius
                           - Spool_r
                           + Depth_of_roller_base/2
                           + b608_vgroove_small_r;

Ptfe_r = 2.1;
Roller_base_r = 8;
Screw_h = 2;
Screw_head_h = 2;
M3_screw_head_d = 5.8;
Spool_center_bearing_wall_th = 5;
Corner_clamp_bearings_center_to_center = max(15, (b623_big_ugroove_big_r + b623_ugroove_room_to_grow_r)*2 + 5);

//// Lineroller anchor parameters /////

Front_bearing_x = -5 - 5;
Move_tower = -12.2;
Lower_bearing_z = 13;
Higher_bearing_z = Lower_bearing_z + Corner_clamp_bearings_center_to_center;

//// Cable Clamp parameters /////
Bit_width = 12;
Cable_r=2.5;

// Belt drive parameters
GT2_belt_width = 6.5;
GT2_gear_height = GT2_belt_width + 2;
GT2_motor_gear_height = 16;
GT2_motor_gear_outer_dia = 16;
GT2_spool_gear_outer_dia = 161.82; // Echoed from GT2_spool_gear.scad
GT2_spool_gear_teeth = 255;
GT2_motor_gear_teeth = 20;
Torx_depth = GT2_gear_height/2;
Belt_roller_h = 56;
Belt_thickness = 1.4;

Belt_roller_space_between_walls = 2*b623_width + 0.8;
Belt_roller_wall_th = (Depth_of_roller_base - Belt_roller_space_between_walls)/2+2;
Belt_roller_top_adj_screw_x = Depth_of_roller_base/2-3.7;
Belt_roller_top_adj_screw_y = Belt_roller_space_between_walls/2+2;
Belt_roller_containing_cube_ywidth = Belt_roller_space_between_walls+8.5;
Belt_roller_containing_cube_xwidth = 14;
Belt_roller_insert_h = 18;

Sandwich_ABC_width = 2*(1+Spool_height) + GT2_gear_height;
Sandwich_D_width = 4*(1+Spool_height) + GT2_gear_height;
Spool_core_halve_width = 14.3;
Spool_core_impression_in_spool_cover = 0;
Spool_cover_bottom_th = 1.5;
Spool_cover_shoulder = 2;
Spool_core_cover_adj = Spool_cover_shoulder+Spool_cover_bottom_th-Spool_core_impression_in_spool_cover;
Spool_core_tot_length = 136.458;
Spool_cover_outer_r = Sep_disc_radius + 2;
Gap_between_sep_disc_and_spool_cover = 0.55;

Smooth_rod_length_ABC = Sandwich_ABC_width + 2*(Spool_core_halve_width-Spool_core_impression_in_spool_cover + Spool_cover_bottom_th + Spool_cover_shoulder);
Smooth_rod_length_D = Sandwich_D_width + 2*(Spool_core_halve_width-Spool_core_impression_in_spool_cover + Spool_cover_bottom_th + Spool_cover_shoulder);
echo("Smooth_rod_length_ABC", Smooth_rod_length_ABC);
echo("Smooth_rod_length_D", Smooth_rod_length_D);

Spool_cover_tot_height = Spool_cover_bottom_th+Spool_cover_shoulder+1+Spool_height;
Spool_cover_D_left_tot_height = Spool_cover_shoulder+Spool_cover_bottom_th+1+Spool_height+1+Spool_height;

spd = Spool_height+GT2_gear_height;
// Horizontal_deflector_cube_y_size must be exact this number
// because we want to deflect AB-lines
// 60 degrees on the ceiling unit, and we want to put two
// deflectors in a row and get a distance between bearings
// that maintain the distance d when deflecting 60 degrees
Horizontal_deflector_cube_y_size = (2/sqrt(3))*spd;

Belt_roller_bearing_xpos = Sep_disc_radius + b623_outer_dia/2+Belt_thickness;


// Top plate parameters needed for layout slicer
Yshift_top_plate = -297.8;

Pen_holder_w = 55;
Pen_holder_rail_w = 36;
Pen_holder_bottom_th = 7;

u_width = 7;
Stick_extra = 5;
Stick_length = b623_big_ugroove_big_r*2 + 7*2 + 1*2 + Stick_extra;
Stick_d = 12.5;

Ram_1000_3dpotter_tube_inner_d = 70;
Ram_1000_3dpotter_tube_outer_d = Ram_1000_3dpotter_tube_inner_d + 2*3.3;
Ram_1000_3dpotter_top_square_width = 31.7;

Wasp_xl30_funnel_d1 = 7.2;
Wasp_xl30_funnel_d2 = 26.3;
Wasp_xl30_funnel_h = 18.59;;
