Circular_pitch = 262;

Motor_teeth = 10;
Gear_height = 23.4;
Motor_pitch                      = (Motor_teeth*Circular_pitch/360);
Motor_pitch_diametrial           = Motor_teeth/(2*Motor_pitch);
Motor_outer_radius               = Motor_pitch + 1/Motor_pitch_diametrial;
echo("Motor gear outer radius",  Motor_outer_radius);
echo("Motor gear pitch", Motor_pitch);

Spool_teeth = 84;
