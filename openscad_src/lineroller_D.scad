include <parameters.scad>
include <lineroller_parameters.scad>
use <sweep.scad>
use <util.scad>
use <lineroller_ABC_winch.scad>

//%prev_art();
module prev_art(){
  import("../stl/lineroller_D.stl");
}

lineroller_D();
module lineroller_D(){
  flerp0 = 6;
  flerp1 = 4;
  base_th = 2;
  lineroller_ABC_winch(edge_start=90, the_wall=false)
    translate([0,0,-0.01])
      base(flerp0=flerp0);
  swing_r = 2;

  cr = (Bearing_r + Bearing_wall+Lineroller_wall_th)/2-0.30;


  translate([0, -d/2, 0])
    rotate([0,-90,0]){
  difference(){
    union(){
      translate([0,0,-0.005])
        cube([Tower_h+swing_r, d, Lineroller_wall_th]);
      translate([Tower_h+swing_r-Lineroller_wall_th,0,-Bearing_r-Bearing_wall]){
        cube([Lineroller_wall_th, d, Bearing_r + Bearing_wall + Lineroller_wall_th]);
        translate([-Bearing_r-Bearing_wall,0,-swing_r])
          cube([Bearing_r+Bearing_wall+Lineroller_wall_th, Lineroller_wall_th, Bearing_r + Bearing_wall+Lineroller_wall_th + swing_r]);
        translate([-Bearing_r-Bearing_wall,d-Lineroller_wall_th,-swing_r])
          cube([Bearing_r+Bearing_wall+Lineroller_wall_th, Lineroller_wall_th, Bearing_r + Bearing_wall+Lineroller_wall_th + swing_r]);
      }
      translate([Tower_h,d/2,-(cr+0.3/2)+Lineroller_wall_th])
        rotate([0,90,0])
        cylinder(r=cr, h=2+swing_r, $fs=1);
      }
      translate([Tower_h+swing_r-Lineroller_wall_th-Bearing_r-Bearing_wall,0,-Bearing_r-Bearing_wall])
        rotate([-90,0,0])
        translate([0,0,-1])
        cylinder(d=6, h=d+2);
      // The swing_r cylinder
      translate([Tower_h+swing_r,0,-Bearing_r-Bearing_wall-swing_r])
        rotate([-90,0,0])
        translate([0,0,-1])
        cylinder(r=swing_r+0.3, h=d+2, $fs=0.1);
      // PTFE Tube opening
      translate([Tower_h,d/2,-Bearing_r-Bearing_wall + Bearing_small_r+0.25])
        rotate([0,90,0])
        cylinder(r=Ptfe_r, h=15, center=true, $fs=0.1);
    }

    }
}
