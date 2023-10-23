// Viewing STLs is faster when just looking at the model
// Non-stls are faster for previews when changing design
stls = true;
//stls = false;

// Viewing 2d
twod = true;
//twod = false;

//mounted_in_ceiling = true;
mounted_in_ceiling = false;

// Render the mover
//mover = true;
mover = false;

bottom_triangle = false;
//bottom_triangle = true;

ram_1000_3dpotter = true;
//ram_1000_3dpotter = false;

A = 0;
B = 1;
C = 2;
D = 3;
I = 4;
X = 0;
Y = 1;
Z = 2;

beam_length = 400;

ram_1000_3dpotter_height_diff = 350;

anchors = [[16.83, -1384.86, -113.17-ram_1000_3dpotter_height_diff],
           [1390.18, 129.19, -157.45-ram_1000_3dpotter_height_diff],
           [-149.88, 1242.61, -151.80-ram_1000_3dpotter_height_diff],
           [-1290.18, 19.19, -157.45-ram_1000_3dpotter_height_diff],
           [21.85, -0.16, 2343.67-ram_1000_3dpotter_height_diff]];

between_action_points_z = anchors[I][Z]-Higher_bearing_z -3 - 175;
length_of_toolhead = 77;
//length_of_toolhead = anchors[I][Z]-300;


aspool_y = 42;
bcspool_y = -23;
dspool_y = 19;
aspool_lineroller_y = -110;
move_BC_deflectors = -113;

lxm1 = -spd/2 - 1 - Spool_height;
lx0 = -spd/2;
lx2 = spd/2 + 1 + 32;
lx3 = -spd/2 + 106;
ly2 = 126;

hz = Gap_between_sandwich_and_plate+Sep_disc_radius-Spool_r;

bc_x_pos = 200;

Move_i_bearings_inwards = -2;
cx = 500+Move_i_bearings_inwards/2;
cy = 500+Move_i_bearings_inwards/2;
// Top plate parameters needed for layout slicer
Yshift_top_plate = -cy/2;
