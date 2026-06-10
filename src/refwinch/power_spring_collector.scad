include <../lib/BOSL2/std.scad>
include <../lib/parameters.scad>

capstan_r = 12;
capstan_track_depth = 1.75;
capstan_track_height = 3;
motor_capstan_tracks = 7;
free_spin_capstan_tracks = 8;

motor_capstan();
module motor_capstan(){
  r = capstan_r;
  h = 28;
  track_depth = capstan_track_depth;
  track_height = capstan_track_height;
  shaft_dia_tol = 0.25;
  shaft_dia = Nema17_shaft_radius*2 + shaft_dia_tol;
  difference() {
    union(){
      rotate_extrude()
        difference(){
          translate([shaft_dia/2,0]) square([r-shaft_dia/2, h]);
          for(k = [1:motor_capstan_tracks]) {
            l = track_height*k+2;
            polygon([[r,l], [r-track_depth, l+track_height/2], [r, l+track_height], [r+1,l+track_height], [r+1,l], [r,l]]);
          }
        }
      translate([shaft_dia/2 - 0.9, -shaft_dia/2, 7.5])
        cube([2, shaft_dia, h-7.5]);
    }
    translate([0,0,-1])
      cylinder(d1=shaft_dia + 2, d2 = shaft_dia-2, h = 6);
    translate([0,0,h-6+1])
      cylinder(d2=shaft_dia + 2, d1 = shaft_dia-2, h = 6);
    translate([0,0,7.49])
      cylinder(d1=shaft_dia, d2 = shaft_dia-2, h = 6, $fn=32);
  }
}

translate([30,0,-capstan_track_height/2])
free_spin_capstan();
module free_spin_capstan() {
  r = capstan_r;
  h = 28+capstan_track_height;
  track_depth = capstan_track_depth;
  track_height = capstan_track_height;
  shaft_dia_tol = 0.25;
  shaft_dia = Nema17_shaft_radius*2 + shaft_dia_tol;
  difference() {
    union(){
      rotate_extrude()
        difference(){
          translate([shaft_dia/2,0]) square([r-shaft_dia/2, h]);
          for(k = [1:free_spin_capstan_tracks]) {
            l = track_height*k+2;
            polygon([[r,l], [r-track_depth, l+track_height/2], [r, l+track_height], [r+1,l+track_height], [r+1,l], [r,l]]);
          }
        }
    }
    translate([0,0,-1])
      cylinder(d1=shaft_dia + 2, d2 = shaft_dia-2, h = 6);
    translate([0,0,h-6+1])
      cylinder(d2=shaft_dia + 2, d1 = shaft_dia-2, h = 6);
    translate([0,0,7.49])
      cylinder(d1=shaft_dia, d2 = shaft_dia-2, h = 6, $fn=32);
  }

}
