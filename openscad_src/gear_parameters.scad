Circular_pitch = 262;

Motor_teeth = 10;
Gear_height = 21.4;
Motor_pitch                      = (Motor_teeth*Circular_pitch/360);
Motor_pitch_diametrial           = Motor_teeth/(2*Motor_pitch);
Motor_outer_radius               = Motor_pitch + 1/Motor_pitch_diametrial;

Spool_teeth = 80;
Spool_r = 40;
Spool_height = 8;
Spool_pitch                      = (Spool_teeth*Circular_pitch/360);
Spool_pitch_diametrial           = Spool_teeth/(2*Spool_pitch);
Spool_outer_radius               = Spool_pitch + 1/Spool_pitch_diametrial;

Torx_depth = 5;
Motor_bracket_depth = Gear_height+1+7+Nema17_ring_height+2;

