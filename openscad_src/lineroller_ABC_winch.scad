include <parameters.scad>
include <lineroller_parameters.scad>
use <sweep.scad>
use <util.scad>

//%prev_art();
module prev_art(){
  import("../stl/lineroller.stl");
}

base();
module base(base_th = 2, flerp0 = 4, flerp1 = 4){
  l = d + 2*Bearing_r + 2*Bearing_wall + flerp0 + flerp1;
  translate([-d/2-flerp0, -d/2, 0])
    difference(){
      rounded_cube2([l, d, base_th], d/2, $fn=10*4);
      for(x=[d/2-1, l - (d/2-1)])
        translate([x, d/2, -1])
          cylinder(d=4, h=base_th+2, $fs=1);
    }
}

lineroller_ABC_winch() base();
module lineroller_ABC_winch(base_th = 2, edge_start=0, edge_stop=180){
  foot_h = 1.5;
  foot_l = 2*Bearing_r + 2*Bearing_wall + 2*foot_h;
  foot_d = Lineroller_wall_th + foot_h;

  module wall(){
    // Foot
    difference(){
      translate([-foot_h,-d/2,base_th-0.1])
        cube([foot_l, foot_d, foot_h+0.1]);
      for(i=[0,1])
        translate([-foot_h+i*foot_l,-d/2,base_th])
          mirror([i,0,0])
          rotate([0,45,0])
          translate([-foot_h*2,-1,-2*foot_h])
          cube([foot_h*2,foot_d+2,2*foot_h + sqrt(2)*foot_h]);
      translate([-foot_h, -d/2 + foot_d, base_th])
      rotate([45,0,0])
      translate([-1,0,-1])
        cube([foot_l+2, 2*foot_h, sqrt(2)*foot_h+1]);
    }
    // Main block
    r2=2+1.3;
    translate([0, -d/2, 0])
      rotate([-90,-90,0]){
        difference(){
          union(){
            round_end([Tower_h, Bearing_r*2+2*Bearing_wall, Lineroller_wall_th],$fn=8*6);
            translate([Tower_h-Bearing_r-Bearing_wall,Bearing_r+Bearing_wall,0])
              cylinder(r=r2, h=Lineroller_wall_th+0.5, $fs=1);
          }
          translate([Tower_h-Bearing_r-Bearing_wall,Bearing_r+Bearing_wall,-1])
            cylinder(d=4.3, h=Lineroller_wall_th+0.5+2, $fs=1);
        }
      }
    // Edge to prevent line from falling of...
    a = 1.5;
    b= 0.5;
    rot_r = Bearing_r+b;
    difference(){
      translate([Bearing_r+Bearing_wall, -4, Tower_flerp + Bearing_r - Bearing_wall])
        sweep([[0,0], [0,-0.5], [b+a, -0.5], [b+a,0], [b, a], [0, a]],
            [for (ang=[edge_start+0.01:((edge_stop-edge_start)-0.03)/100:edge_stop-0.01])
            rotation([0,ang,0])
            * translation([rot_r,0,0])
            * scaling([
              1,
              (ang<edge_start+a*rot_r) ? sqrt(1-pow(a*rot_r-(ang-edge_start),2)/pow(a*rot_r,2)) :
              (ang>edge_stop-a*rot_r) ? sqrt(1-pow(ang-(edge_stop - a*rot_r),2)/pow(a*rot_r,2)) : 1,
              1])
            ]);
      translate([-10,-10,0])
        cube([10,10,Tower_h]);
      translate([2*Bearing_r+2*Bearing_wall,-10,0])
        cube([10,10,Tower_h]);
    }
  }
  wall();
  mirror([0,1,0])
    wall();
  children(0);
}
