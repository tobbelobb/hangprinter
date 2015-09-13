include <measured_numbers.scad>
include <util.scad>

LEFT = 0;
RIGHT = 1;
MIDDLE = 2;
A = 0;
B = 1;
C = 2;
D = 3;
X = 0;
Y = 1;
Z = 2;

//////////// Design decision numbers //////////////

//** The bottom plate parameters **//
Full_tri_side             = 200*1.035; // Rotate eq_tri relative to 200 mm printbed, gain 3.5 % side length
Sandwich_gap              = 0.8;
Sandwich_height           = Bearing_608_width + 2;
Lock_height               = Sandwich_height-Bearing_608_width+Sandwich_gap;
Lock_radius_1 = Bearing_608_bore_diameter/2 + 0.25;
Lock_radius_2 = Lock_radius_1 + 2;
Bottom_plate_sandwich_gap = 1.5;
Bottom_plate_thickness    = 5.5;
Top_plate_thickness       = Bottom_plate_thickness;
Bottom_plate_radius       = 82;


// For rotating lines and gatts in place
d_gatt_back = 13;

Sandwich_gear_height = Sandwich_height*4/7-1;
Snelle_height        = Sandwich_height*3/7+1;

// Distance between parallell contact points on one side of printer
Abc_xy_split = Full_tri_side - 2*30;

// This is the xy coordinate of one wall/printer contact point
Line_action_point_abc_xy = [0, -Full_tri_side/(2*Sqrt3), 0];
Line_contact_abc_xy      = Line_action_point_abc_xy - [Abc_xy_split/2, 0, 0];
// For left-right symmetry for pairs of wall/printer contact points
Mirrored_line_contact_abc_xy = mirror_point_x(Line_contact_abc_xy);

Wall_action_point_a  = [0, -400, -25];
Wall_action_point_b  = [300, 100, -22];
Wall_action_point_c  = [-350, 100, -12];
Ceiling_action_point = [0, 0, 500];

// This is the xy coordinate of one point where a D-line enters the
// printer. Preferrably near a corner.
Line_contact_d_xy = [0, Full_tri_side/Sqrt3 - d_gatt_back, 0];
// This is the three different z-heights of the three spools (snelles)
Line_contacts_abcd_z = [Bottom_plate_thickness + Bottom_plate_sandwich_gap + Snelle_height/2 + 3*(Sandwich_height + Sandwich_gap), 
                        Bottom_plate_thickness + Bottom_plate_sandwich_gap + Snelle_height/2 + 2*(Sandwich_height + Sandwich_gap),
                        Bottom_plate_thickness + Bottom_plate_sandwich_gap + Snelle_height/2 +    Sandwich_height + Sandwich_gap,
                        Bottom_plate_thickness + Bottom_plate_sandwich_gap + Snelle_height/2];    // D-lines have lowest contact point, maximizes build volume

fish_ring_abc_rotation = -20;
fish_ring_d_rotation   = 125;


//** Gear parameters **//
Circular_pitch_top_gears = 400;
Motor_gear_teeth = 12;
Sandwich_gear_teeth = 37;
Circular_pitch_extruder_gears = 180;
Big_extruder_gear_teeth = 50;
Small_extruder_gear_teeth = 14;
Motor_protruding_shaft_length = 17;
Motor_gear_a_height = Line_contacts_abcd_z[A] + 1; // A and B has the longest, most important shafts
Motor_gear_b_height = Line_contacts_abcd_z[B] + 1;
Motor_gear_c_height = Line_contacts_abcd_z[C];
Motor_gear_d_height = Line_contacts_abcd_z[D];
//Big_extruder_gear_height = 8;
Big_extruder_gear_height = 4;
Small_extruder_gear_height = 6;

Snelle_radius = 34.25; // This is the radius the line will wind around. TODO: Make Snelle_radius smaller so that Sandwich doesn't touch extruder motor
Shaft_flat = 2; // Determines D-shape of motor shaft

//** Extruder numbers **//
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
