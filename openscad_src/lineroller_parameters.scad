include <gear_parameters.scad>

Bearing_width  = 7;
Bearing_r      = 6.5;
Bearing_small_r = 4.6;
Bearing_bore_r = 2;

Lineroller_wall_th = 2.3;
Extra = 0.7;
// 0.7 Allows gap between sandwich and plate
Tower_flerp = Gear_height + Spool_height/2 + Extra + Bearing_small_r;
Tower_h = Bearing_r + Tower_flerp;
Bearing_wall = 1;
d = Bearing_width + 2*Wall_th; // depth of lineroller base

Ptfe_r = 2.1;
