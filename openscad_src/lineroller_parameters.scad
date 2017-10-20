include <gear_parameters.scad>

Bearing_width  = 4;
Bearing_r      = 12/2;
Bearing_small_r = 10/2;
Bearing_bore_r = 3/2;

Lineroller_wall_th = 2.3;
Extra = 0.7; // 0.7 Allows gap between sandwich and plate
Tower_flerp = Gear_height + Spool_height/2 + Extra + Bearing_small_r;
Tower_h = Bearing_r + Tower_flerp;
Bearing_wall = 1;
Base_th = 2.8;
Depth_of_lineroller_tower = Bearing_width + 2*Wall_th; // 9
Depth_of_lineroller_base = Depth_of_lineroller_tower + 9; // 18
Line_entrance = Tower_flerp-Bearing_wall-Bearing_small_r-0.25;
Ptfe_r = 2.1;

Lineroller_base_r = Depth_of_lineroller_base/2-1*(Ptfe_r+2);

