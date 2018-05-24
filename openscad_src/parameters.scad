// Parameters shared between modules
Base_th = 2.8;
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
Gap_between_sandwich_and_plate = 1.5 + Base_th; // 1.5 mm for wiggle
Motor_bracket_flerp_r = 6;
Motor_bracket_flerp = 14;
Motor_bracket_cw = Nema17_cube_width + 6;
Motor_bracket_att_ang = 50;
Mounting_screw_d = 4.5;
Mounting_screw_head_d = 14;
Spool_outer_wall_th = 4;

// Corner clamp parameters
Cc_l1 = (Fat_beam_width+2*Wall_th)*2*sqrt(3);
Cc_rad_b = 4;
Cc_action_point_from_mid = Cc_l1/sqrt(3)-2*Cc_rad_b-1.3;  // 1.3 chosen arbitrarily
Cc_plastic_length = sqrt(Cc_action_point_from_mid*Cc_action_point_from_mid
                       - (Cc_action_point_from_mid/2)*(Cc_action_point_from_mid/2));

// The distance between the two action points on the mover
Sidelength = Beam_length + 2*Cc_plastic_length;

/////// Layout parameters ////////////
Ext_sidelength = Sidelength+77;
Additional_added_plate_side_length = 10;
Yshift_top_plate = -25;

/////// Gear parameters ////////////
Circular_pitch = 262;
Motor_teeth = 10;
Gear_height = 21.4-3;
Motor_pitch                      = (Motor_teeth*Circular_pitch/360);
Motor_pitch_diametrial           = Motor_teeth/(2*Motor_pitch);
Motor_outer_radius               = Motor_pitch + 1/Motor_pitch_diametrial;
Spool_teeth = 100;
Spool_r = 55;
Spool_height = 8;
Spool_pitch                      = (Spool_teeth*Circular_pitch/360);
Spool_pitch_diametrial           = Spool_teeth/(2*Spool_pitch);
Spool_outer_radius               = Spool_pitch + 1/Spool_pitch_diametrial;
Torx_depth = 5;
Motor_bracket_depth = Gear_height+1+7+Nema17_ring_height+1+Gap_between_sandwich_and_plate;
Spool_core_flerp0 = 16+3;

/////// Lineroller parameters ////////////
b623_width  = 4;
b623_bore_r = 3/2;
b623_vgroove_big_r = 12/2;
b623_vgroove_small_r = 10/2;
Lineroller_wall_th = 2.3;
// The height that lineroller_ABC_winch will have if we include the bearing
Tower_h = Gap_between_sandwich_and_plate+Gear_height
         + Spool_height/2
         + b623_vgroove_small_r
         + b623_vgroove_big_r;
Bearing_wall = 1;
Depth_of_lineroller_tower = b623_width + 2*Wall_th; // 9
Depth_of_lineroller_base = Depth_of_lineroller_tower + 9; // 18
Ptfe_r = 2.1;
Lineroller_base_r = Depth_of_lineroller_base/2-1*(Ptfe_r+2);
Screw_h = 2;
Screw_head_h = 2;
Spool_center_bearing_wall_th = 5;
