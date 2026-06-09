include <../lib/BOSL2/std.scad>
include <../lib/BOSL2/screws.scad>
include <../lib/parameters.scad>

include <../lib/util.scad>;

leg_dist = 0;
rod_th = 40;
THREAD_RADIAL_GAP = 0.50;
male_d   = rod_th;
female_d = rod_th + 2*THREAD_RADIAL_GAP;
leg_th = 5;
leg_depth = rod_th + 15;
threaded_rod_length = 120;
// Gives approximately ((120-8*3)/3)*pi*40 = 4021 mm of capacity, probably a bit less
// Usable rod length = l = full length - capstan part.
// Number of turns = l / pitch
// Length per turn ~ rod thickness * pi
// ((threaded_rod_length - (motor_drive_capstan_tracks+1)*motor_drive_capstan_track_height)/motor_drive_capstan_track_height) * pi * rod_th

motor_drive_capstan_r = 12;
motor_drive_capstan_track_depth = 1.75;
motor_drive_capstan_track_height = 3;
motor_drive_capstan_tracks = 7;

eyelet_holder_turn = 43;

module eyelet_holder(){
  difference() {
    cube([Eyelet_diameter+20, Eyelet_diameter + 2, 4]);
    translate([Eyelet_diameter/2 + 1, Eyelet_diameter/2 + 1, -1])
      cylinder(d=Eyelet_diameter, h=6);
  }
}

module shaft_rotated_eyelet_holder(turn=eyelet_holder_turn){
  shaft_y = Nema17_cube_width + separation/2;
  shaft_z = leg_depth/2 + leg_th;
  holder_x = -(Eyelet_diameter+2 + leg_dist/2 + leg_th);
  holder_y = shaft_y - (Eyelet_diameter + 2)/2
             - (motor_drive_capstan_r - motor_drive_capstan_track_depth);
  holder_z = shaft_z + motor_drive_capstan_r + 14;

  translate([0, shaft_y, shaft_z])
    rotate([turn, 0, 0])
      translate([holder_x, holder_y - shaft_y, holder_z - shaft_z])
        eyelet_holder();
}

//rotate([0,-90,0])
//legs();
module legs(){
  translate([-3,53,0])
    rounded_cube2([58,15,3],2);
  translate([0,-27,0])
    rounded_cube2([55,15,3],2);
  translate([-5,0,0])
    rounded_cube2([15,85,3],2);
  translate([-5,-50,0])
    rounded_cube2([15,50,3],2);
  translate([0,68,3])
    rotate([90,0,0])
    inner_round_corner(r=5, h=47);
  translate([10,-12,3])
    rotate([90,0,0])
    inner_round_corner(r=5, h=15);
  translate([-5,-27.5,3])
    rotate([90,-90,90])
    inner_round_corner(r=5, h=15);
  translate([5,68,3])
    rotate([90,-90,-90])
    difference(){
      inner_round_corner(r=5, h=10);
      translate([5,6,0])
      rotate([90,0,0])
      cylinder(r=5, h=10);
    }
  difference() {
    union() {
      mirror([1,0,0])
        left(leg_dist/2)
          rotate([0,-90,0])
            linear_extrude(height = 2*leg_th)
              difference() {
                hull() {
                  right(leg_depth/2 + leg_th)
                    circle(d=leg_depth);
                  fwd(leg_depth/2)
                    square([leg_th, leg_depth]);
                }
                right(leg_depth/2 + leg_th - (Nema17_cube_width+17)/2)
                  back((Nema17_cube_width)/2)
                  square(Nema17_cube_width+5);
                back(Nema17_cube_width + separation/2) {
                  right(leg_depth/2 + leg_th) {
                    Nema17_screw_translate() circle(d=3.3);
                      circle(max(motor_drive_capstan_r+1,Nema17_ring_diameter/2+2));
                  }
                }
              }
      left(leg_dist/2)
        rotate([0,-90,0])
          linear_extrude(height = leg_th)
            difference(){
              hull() {
                right(leg_depth/2 + leg_th)
                  circle(d=leg_depth);
                fwd(leg_depth/2)
                  square([leg_th, leg_depth]);
                // Something to mount motor on
                back(63)
                  rounded_cube2_2d([leg_depth+leg_th, leg_th], 2);
              }
              back(Nema17_cube_width + separation/2)
                right(leg_depth/2 + leg_th) {
                  Nema17_screw_translate() circle(d=3.3);
                    circle(max(motor_drive_capstan_r+1,Nema17_ring_diameter/2+2));
                }
            }

    }
    for(ang=[17:10:37])
      shaft_rotated_eyelet_holder(ang);
    up(leg_depth/2 + leg_th)
    rotate([0,90,0])
    trapezoidal_threaded_rod(
      d = female_d,
      l = max(2*leg_dist, threaded_rod_length+2),
      pitch = motor_drive_capstan_track_height,
      thread_depth = 1.5,
      thread_angle = 60,
      $fn = 128
    );
  }
}

//rotate([0,-90,0])
//spool();
module spool(l=threaded_rod_length){
    rotate([0,90,0]) {
      difference() {
        trapezoidal_threaded_rod(
          d = male_d,
          l = l,
          pitch = motor_drive_capstan_track_height,
          thread_depth = 1.5,
          thread_angle = 60,
          $fn = 128
        );
        rotate([0,0,230])
          right(male_d/2-11)
          down(l/2+2.5)
          rotate([0,60,0])
          cylinder(d=3, h=20);
      }
    }
}

motor_drive_capstan_0();
module motor_drive_capstan_0(){
  r = motor_drive_capstan_r;
  h = 28;
  track_depth = motor_drive_capstan_track_depth;
  track_height = motor_drive_capstan_track_height;
  shaft_dia_tol = 0.5;
  shaft_dia = Nema17_shaft_radius*2 + shaft_dia_tol;
  difference() {
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
    translate([0,0,-1])
      cylinder(d1=shaft_dia + 2, d2 = shaft_dia-2, h = 6);
  }
}


separation = 2;
d = motor_drive_capstan_r + 3;
offset = asin((motor_drive_capstan_r-motor_drive_capstan_track_depth) / d);

//assembly();
module assembly() {
  translate([Nema17_cube_height - leg_dist/2, Nema17_cube_width/2 + separation/2,0])
    rotate([0,-90,0]) {
      Nema17();
      up(Nema17_cube_height + Nema17_ring_height + 3.2)
        motor_drive_capstan_0();
      //rotate([0,0,90+90-offset])
      //  up(Nema17_cube_height + Nema17_ring_height + 3.2 + motor_drive_capstan_track_height*1)
      //    left(d)
      //      rotate([0,-90,offset])
      //        eyelet();
    }

  fwd(male_d/2 + separation/2) {
    spool();
    down(leg_depth/2 + leg_th)
      legs();
  }
}
