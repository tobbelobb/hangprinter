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
