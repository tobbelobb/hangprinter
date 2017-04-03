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
Sandwich_edge_thickness   = 0.6;
Lock_height               = Sandwich_height-Bearing_608_width+Sandwich_gap;
Lock_radius_1 = Bearing_608_bore_diameter/2 + 0.30;
Lock_radius_2 = Lock_radius_1 + 2;
Bottom_plate_sandwich_gap = 1.5;
Bottom_plate_thickness    = 8.0;
Top_plate_thickness       = Bottom_plate_thickness;
Bottom_plate_radius       = Full_tri_side/sqrt(6); // Fit bed precisely: Full_tri_side/sqrt(6)


// For rotating lines and gatts in place
d_action_to_extrema = 15;

Sandwich_gear_height = Sandwich_height*3/8;
Snelle_height        = Sandwich_height*5/8;

// Distance between parallell contact points on one side of printer
Abc_xy_split = Full_tri_side - 2*35;

// This is the xy coordinate of one wall/printer contact point
Line_action_point_abc_xy = [0, -Full_tri_side/(2*Sqrt3), 0];
Line_contact_abc_xy      = Line_action_point_abc_xy - [Abc_xy_split/2, 0, 0];
// For left-right symmetry for pairs of wall/printer contact points
Mirrored_line_contact_abc_xy = mirror_point_x(Line_contact_abc_xy);

// These should be called anchor points...
Wall_action_point_a  = [0, -400, 0];
Wall_action_point_b  = [ 440*sin(60), 390*cos(60), 0];
Wall_action_point_c  = [-420*sin(60), 410*cos(60), 0];
//Wall_action_point_b  = [300, 100, -22];
//Wall_action_point_c  = [-350, 100, -12];
Ceiling_action_point = [0, 0, 500];

// TODO: rename Line_contact_d_xy to something?
// ... since that axis is geared down

// This is the xy coordinate of one point where a D-line enters the
// printer. Preferrably near a corner.
Line_contact_d_xy = [0, Full_tri_side/Sqrt3 - d_action_to_extrema, 0];
// This is the three different z-heights of the three spools (snelles)
Line_contacts_abcd_z = [Bottom_plate_thickness + Bottom_plate_sandwich_gap + Snelle_height/2 + 3*(Sandwich_height + Sandwich_gap),
                        Bottom_plate_thickness + Bottom_plate_sandwich_gap + Snelle_height/2 + 2*(Sandwich_height + Sandwich_gap),
                        Bottom_plate_thickness + Bottom_plate_sandwich_gap + Snelle_height/2 +    Sandwich_height + Sandwich_gap,
                        Bottom_plate_thickness + Bottom_plate_sandwich_gap + Snelle_height/2 + Sandwich_gear_height];    // D-lines have lowest contact point, maximizes build volume

fish_ring_abc_rotation = -20;
fish_ring_d_rotation   = 107;


//** Gear parameters **//
Circular_pitch_top_gears = 400;
//Motor_gear_teeth = 11;
Motor_gear_teeth = 9;
//Sandwich_gear_teeth = 38;
Sandwich_gear_teeth = 43;
Circular_pitch_extruder_gears = 180;
Small_extruder_gear_teeth = 15;
// 1/3 is sweetspot ratio
Big_extruder_gear_teeth = Small_extruder_gear_teeth*3;
Motor_protruding_shaft_length = 17;
Motor_gear_a_height = Line_contacts_abcd_z[A]; // A and B has the longest shafts
Motor_gear_b_height = Line_contacts_abcd_z[B];
Motor_gear_c_height = Line_contacts_abcd_z[C] - 5;
Motor_gear_d_height = Line_contacts_abcd_z[D];
//Big_extruder_gear_height = 8;
Big_extruder_gear_height = 4;
Small_extruder_gear_height = 6;

Motor_gear_shaft_radius_A = 7.5; // A motor gear shaft is most likely to break. Thicken it.
Motor_gear_shaft_radius_BC = 7;
Snelle_radius = 33; // This is the radius the line will wind around.
Snelle_brim   = Snelle_radius + 12;
// TODO: worm should use this
// How much motor shaft is flattened away (in radial direction)?
Shaft_flat = 0.5; // Determines D-shape of motor shaft

//** Extruder numbers **//
Big_extruder_gear_rotation = 69; // Rotate around z-axis
// TODO: Remove part of Tble-struder
//Extruder_motor_twist = 0; // Manually adjusted to center hobb
E_motor_z_offset = -1; // Added to get E-motor below sandwich
Extruder_filament_opening = 1.3;
// Place E-motor away from D-motor to make spring loaded hobb accessible
// Sstruder construction depends on this variable
E_motor_x_offset = -(Hobbed_insert_diameter/2 + Extruder_filament_opening/2);

// TODO: Remove part of Tble-struder
E3d_v6_support_height = 15;
// TODO: Remove part of Tble-struder
Drive_support_towermove = 2;
// TODO: Remove part of Tble-struder
Big_extruder_gear_screw_head_depth = Big_extruder_gear_height/2;
// Allow bearing to protrude on both sides
// TODO: Remove part of Tble-struder
Drive_support_thickness = Bearing_623_width+1.4;
// TODO: Remove part of Tble-struder
Hobb_from_edge = 12;
// TODO: Remove part of Tble-struder
Support_rx = Bearing_623_outer_diameter-3.5;
// TODO: Remove part of Tble-struder
Support_ry = Hobbed_insert_height+5;
// TODO: Remove part of Tble-struder
Drive_support_v = [Bearing_623_outer_diameter + 16,
                   Drive_support_thickness,
                   Hobbed_insert_height + 2*(Bearing_623_width+1)];


//** Derived parameters **//
Motor_gear_pitch             = Motor_gear_teeth*Circular_pitch_top_gears/360;
echo(Motor_gear_pitch);
Motor_gear_radius            = Motor_gear_pitch + Motor_gear_pitch*2/Motor_gear_teeth;
Sandwich_gear_pitch          = Sandwich_gear_teeth*Circular_pitch_top_gears/360;
echo(Sandwich_gear_pitch);
Sandwich_radius              = Sandwich_gear_pitch + Sandwich_gear_pitch*2/Sandwich_gear_teeth;
Big_extruder_gear_pitch      = Big_extruder_gear_teeth*Circular_pitch_extruder_gears/360;
Small_extruder_gear_pitch    = Small_extruder_gear_teeth*Circular_pitch_extruder_gears/360;
Pitch_difference_extruder    = Big_extruder_gear_pitch + Small_extruder_gear_pitch;
Four_point_five_point_radius = Sandwich_gear_pitch+Motor_gear_pitch+0.1;

// TODO: Remove part of Tble-struder
Drive_support_height = Nema17_cube_width/3 +
           Pitch_difference_extruder*cos(Big_extruder_gear_rotation)
           + 5.3;

// Worm parameters
Degrees_per_worm_gear_tooth  = 360/Sandwich_gear_teeth;
Worm_disc_tooth_cutoff      = 0.37;
Worm_disc_radius            = Sandwich_radius; // Worm plate will be cut to this radius
Worm_disc_virtual_radius    = Worm_disc_radius + Worm_disc_tooth_cutoff; // Also affects worm
Worm_disc_tooth_valley_r    = Worm_disc_virtual_radius*(1 // Shift inwards for 45 deg valleys
                                                  - sqrt((1-cos(Degrees_per_worm_gear_tooth))/2)
                                                  - (1-cos(Degrees_per_worm_gear_tooth/2)));
Worm_edge_cut                = 0.3;
Worm_spiral_turns            = 2.5; // Shortened to make space for screw...
Worm_radius                  = 15.5; // Distance from origo to virtual worm edge in xy-plane
Worm_smallest_radius         = Worm_radius - (Worm_disc_virtual_radius - Worm_disc_tooth_valley_r)
                               + Worm_disc_tooth_cutoff; // fill_interior inside this
Worm_largest_angle           = atan(2*(Worm_disc_virtual_radius - Worm_disc_tooth_valley_r)/(2*PI*Worm_smallest_radius));
Worm_axle_radius             = 6.5;
Worm_axle_length             = 10;


Printed_color_1 = "deepskyblue";
//Printed_color_1 = [0.05,0.05,0.05,1];
Printed_color_2 = "sandybrown";
//Printed_color_2 = "lime";

// Here it is decided in which order the motors are sorted
// counterclockwise starting from y-axis
A_placement_angle = 72*4;
B_placement_angle = 72*1;
C_placement_angle = 72*2;
D_placement_angle = 72*3;
E_placement_angle = 0;    // 0 here places E motor on y-axis

Pushdown_d_motor = 75;
D_motor_twist = 29;

Sstruder_thickness = 3;
Sstruder_lever_thickness = 3.5;
Sstruder_height = 55;
Sstruder_handle_height = 0.2; // Length of shaft outside Bearing_623. TODO: rename...
Sstruder_filament_meets_shaft = (Nema17_shaft_height-Nema17_cube_height)/2 + Sstruder_handle_height;
Sstruder_gear_thickness = 3;
Sstruder_gear_diameter = 5;
Sstruder_fork_length = Hobbed_insert_diameter/2 + Extruder_filament_opening + 5;
Sstruder_fork_width = 2*Bearing_623_width
                      + Hobbed_insert_height
                      + Sstruder_gear_thickness
                      + 2*Sstruder_handle_height;
Sstruder_edge_around_bearing = 2;
Sstruder_press_angle = 90; // TODO: only used in sstruder() for rendering. Use in sstruder_plate as well
Sstruder_hinge_length = Nema17_cube_width/2 + M3_head_diameter; // As short as possible
//Sstruder_hinge_length = Sstruder_height
//                        - Nema17_cube_height/2
//                        - M3_diameter
//                        - Sstruder_edge_around_bearing; // As long as possible
Sstruder_pressblock_thickness = 4.5;
Sstruder_pressblock_height = Bearing_623_outer_diameter + 2*Sstruder_edge_around_bearing;
Sstruder_hot_end_bore_z = -Sstruder_height + Nema17_cube_width/2 + 2.5; // Move hot end up and down
Sstruder_gear_teeth = 10;
Sstruder_gear_pitch = Hobbed_insert_diameter/2 + Extruder_filament_opening/2;
Sstruder_gear_circular_pitch = Sstruder_gear_pitch*360/Sstruder_gear_teeth;
