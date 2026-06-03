include <../lib/BOSL2/std.scad>
include <../lib/BOSL2/screws.scad>

leg_dist = 90;
rod_th = 40;
THREAD_RADIAL_GAP = 0.50;
male_d   = rod_th;
female_d = rod_th + 2*THREAD_RADIAL_GAP;
leg_th = 5;
leg_depth = rod_th + 15;

// Should probably not be printed in this orientation?
// I don't know how threads behave if printed upright
legs();
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
      pitch = 2,
      thread_depth = 1.5,
      thread_angle = 60,
      $fn = 128
    );
  }
}

spool();
module spool(){
  up(leg_depth/2 + leg_th)
    rotate([0,90,0])
      trapezoidal_threaded_rod(
        d = male_d,
        l = 2*leg_dist,
        pitch = 2,
        thread_depth = 1.5,
        thread_angle = 60,
        $fn = 128
      );
}

!motor_drive_capstan_0();
module motor_drive_capstan_0(){
  //rotate_extrude()
    polygon([[10,3], [1,1], [0,1], [0,0]]);
}
