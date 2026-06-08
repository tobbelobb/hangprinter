include <../lib/BOSL2/std.scad>
include <../lib/BOSL2/screws.scad>
include <../lib/parameters.scad>

include <../lib/util.scad>;

leg_dist = 30;
rod_th = 40;
THREAD_RADIAL_GAP = 0.50;
male_d   = rod_th;
female_d = rod_th + 2*THREAD_RADIAL_GAP;
leg_th = 5;
leg_depth = rod_th + 15;


motor_drive_capstan_r = 12;
motor_drive_capstan_track_depth = 2;
motor_drive_capstan_track_height = 3;
motor_drive_capstan_tracks = 7;

// Should probably not be printed in this orientation?
// I don't know how threads behave if printed upright
//legs();
module legs(){
  up(5/2)
    cube([leg_dist + 2*leg_th, leg_depth, leg_th], center=true);
  difference() {
    for(k=[0,1]) mirror([k,0,0])
      left(leg_dist/2)
        rotate([0,-90,0])
          linear_extrude(height = leg_th)
            hull() {
              right(leg_depth/2 + leg_th)
                circle(d=leg_depth);
              fwd(leg_depth/2)
                square([leg_th, leg_depth]);
            }
    up(leg_depth/2 + leg_th)
    rotate([0,90,0])
    trapezoidal_threaded_rod(
      d = female_d,
      l = 2*leg_dist,
      pitch = motor_drive_capstan_track_height,
      thread_depth = 1.5,
      thread_angle = 60,
      $fn = 128
    );
  }
}

//up(leg_depth/2 + leg_th)
//spool();
module spool(){
    rotate([0,90,0])
      trapezoidal_threaded_rod(
        d = male_d,
        l = 180,
        pitch = motor_drive_capstan_track_height,
        thread_depth = 1.5,
        thread_angle = 60,
        $fn = 128
      );
}

//!motor_drive_capstan_0();
module motor_drive_capstan_0(){
  r = motor_drive_capstan_r;
  h = 28;
  track_depth = motor_drive_capstan_track_depth;
  track_height = motor_drive_capstan_track_height;
  shaft_dia_tol = 0.25;
  shaft_dia = Nema17_shaft_radius*2 + shaft_dia_tol;
  union(){
    rotate_extrude()
      difference(){
        right(shaft_dia/2) square([r-shaft_dia/2, h]);
        for(k = [1:motor_drive_capstan_tracks]) {
          l = track_height*k;
          polygon([[r,l], [r-track_depth, l+track_height/2], [r, l+track_height], [r+1,l+track_height], [r+1,l], [r,l]]);
        }
      }
    translate([shaft_dia/2 - 0.6, -shaft_dia/2, 0])
      cube([2, shaft_dia, h]);
  }
}


separation = 2;
d = motor_drive_capstan_r + 3;
offset = asin((motor_drive_capstan_r-motor_drive_capstan_track_depth) / d);
translate([Nema17_cube_height + leg_dist/2 + leg_th,Nema17_cube_width/2 + separation/2,0])
  rotate([0,-90,0]) {
    Nema17();
    up(Nema17_cube_height + Nema17_ring_height + 0.2)
      motor_drive_capstan_0();
    rotate([0,0,90+90-offset])
      up(Nema17_cube_height + Nema17_ring_height + 0.2 + motor_drive_capstan_track_height*1)
        left(d)
          rotate([0,-90,offset])
            eyelet();
  }

fwd(male_d/2 + separation/2) {
  spool();
  down(leg_depth/2 + leg_th)
    legs();
}

