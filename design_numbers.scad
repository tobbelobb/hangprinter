include <measured_numbers.scad>

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
Circular_pitch_extruder_gears = 180;
Big_extruder_gear_teeth = 50;
Small_extruder_gear_teeth = 14;
Motor_gear_height = 17;

//Big_extruder_gear_height = 8;
Big_extruder_gear_height = 4;
Small_extruder_gear_height = 6;

Snelle_radius = 34.25;
Shaft_flat = 2; // Determines D-shape of motor shaft

//** Extruder numbers **//
//Bearing_support_wall = 1.5;
Big_extruder_gear_rotation = 62; // Rotate around z-axis
Extruder_motor_twist = -35; // Manually adjusted to center hobb
Hobbed_insert_height = 6;
Extruder_filament_opening = 1.3;
Big_extruder_gear_screw_head_depth = Big_extruder_gear_height/2;
// Allow bearing to protrude on both sides
Drive_support_thickness = Bearing_623_width - 0.4;
Hobb_from_edge = 12;
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
Pitch_difference_extruder = Big_extruder_gear_pitch + Small_extruder_gear_pitch;
Four_point_five_point_radius=Sandwich_gear_pitch+Motor_gear_pitch+0.1;

Drive_support_height = Nema17_cube_width/3 +
           Pitch_difference_extruder*cos(Big_extruder_gear_rotation)
           + 7
           + 2;
