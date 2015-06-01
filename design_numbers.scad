//////////// Design decision numbers //////////////

//** The bottom plate parameters **//
Full_tri_side          = 200*1.035; // Rotate eq_tri relative to 200
                                    // printbed, gain 3.5 % side length
Lock_height            = 2;
Bottom_plate_thickness = 4.5;
Top_plate_thickness    = Bottom_plate_thickness;
Bottom_plate_radius    = 82;

//** Gear parameters **//
Circular_pitch_top_gears = 400;
Motor_gear_teeth = 12;
Sandwich_gear_teeth = 37;
Circular_pitch_extruder_gears = 150;
Big_extruder_gear_teeth = 61;
Small_extruder_gear_teeth = 13;
Motor_gear_height = 17;

Big_extruder_gear_rotation = 16; // Rotate around z-axis
Big_extruder_gear_height = 8;
Small_extruder_gear_height = 6;

Snelle_radius = 34.25;
Shaft_flat = 2; // Determines D-shape of motor shaft

//** Extruder numbers **//
Extruder_motor_twist = -11;
Hobbed_insert_height = 7;
Drive_support_thickness = Bearing_623_width;
Support_rx = Bearing_623_outer_diameter-3.5;
Support_ry = Hobbed_insert_height+5;
Drive_support_v = [Bearing_623_outer_diameter + 14,
                   Drive_support_thickness,
                   Hobbed_insert_height + 2*Bearing_623_width];



// For rotating lines and gatts in place
Middlerot = 41.3;
Splitrot_1 = 142;
Splitrot_2 = 53.2;
Z_gatt_back = 13;

//** Derived parameters **//
Motor_gear_pitch = Motor_gear_teeth*Circular_pitch_top_gears/360;
Sandwich_gear_pitch = Sandwich_gear_teeth*Circular_pitch_top_gears/360;
Big_extruder_gear_pitch = Big_extruder_gear_teeth*Circular_pitch_extruder_gears/360;
Small_extruder_gear_pitch = Small_extruder_gear_teeth*Circular_pitch_extruder_gears/360;
Pitch_difference_extruder = Big_extruder_gear_pitch - Small_extruder_gear_pitch;
Four_point_five_point_radius=Sandwich_gear_pitch+Motor_gear_pitch+0.1;

Drive_support_height = Nema17_cube_width/2 +
           Pitch_difference_extruder*cos(Big_extruder_gear_rotation)
           + 7
           + 1;
