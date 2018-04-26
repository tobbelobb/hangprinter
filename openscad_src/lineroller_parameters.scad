include <gear_parameters.scad>

Bearing_width  = 4;
Bearing_r      = 12/2;
Bearing_small_r = 10/2;
Bearing_bore_r = 3/2;

Lineroller_wall_th = 2.3;
// The height that lineroller_ABC_winch will have if we include the bearing
Tower_h = Gap_between_sandwich_and_plate+Gear_height + Spool_height/2 + Bearing_small_r + Bearing_r;

Bearing_wall = 1;
Depth_of_lineroller_tower = Bearing_width + 2*Wall_th; // 9
Depth_of_lineroller_base = Depth_of_lineroller_tower + 9; // 18
Ptfe_r = 2.1;

Lineroller_base_r = Depth_of_lineroller_base/2-1*(Ptfe_r+2);

Screw_h = 2;
Screw_head_h = 2;
