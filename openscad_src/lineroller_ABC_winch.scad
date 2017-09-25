include <parameters.scad>
use <sweep.scad>
use <util.scad>

//%prev_art();
module prev_art(){
  import("../stl/lineroller.stl");
}

lineroller_ABC_winch();
module lineroller_ABC_winch(){
  //base();
  base_th = 2;
  bearing_wall = 1;
  flerp = 4;
  d = Bearing_width + 2*Wall_th;
  l = d + 2*Bearing_r + 2*bearing_wall + 2*flerp;

  module base(){
    translate([-d/2-flerp, -d/2, 0])
      difference(){
        rounded_cube2([l, d, base_th], d/2);
        for(x=[d/2-1, l - (d/2-1)])
          translate([x, d/2, -1])
            cylinder(d=4, h=base_th+2, $fs=1);
      }
  }

  wall_th = 2;
  foot_h = 1.5;
  foot_l = 2*Bearing_r + 2*bearing_wall + 2*foot_h;
  foot_d = wall_th + foot_h;

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
    tower_flerp = 14.4;
    tower_h = Bearing_r*2 + tower_flerp;
    r2=2+1.3;
    translate([0, -d/2, 0])
      rotate([-90,-90,0]){
        difference(){
          union(){
            round_end([tower_h, Bearing_r*2+2*bearing_wall, wall_th],$fn=8*6);
            translate([tower_h-Bearing_r-bearing_wall,+Bearing_r+bearing_wall,0])
              cylinder(r=r2, h=wall_th+0.5, $fs=1);
          }
          translate([tower_h-Bearing_r-bearing_wall,+Bearing_r+bearing_wall,-1])
            cylinder(d=4.3, h=wall_th+0.5+2, $fs=1);
        }
      }
    // Edge to prevent line from falling of...
    a = 1.5;
    b= 0.5;
    rot_r = Bearing_r+b;
    difference(){
      translate([Bearing_r+bearing_wall, -4, tower_flerp + Bearing_r - bearing_wall])
        sweep([[0,0], [0,-0.5], [b+a, -0.5], [b+a,0], [b, a], [0, a]],
            [for (ang=[0.01:(180-0.03)/100:180-0.01])
            rotation([0,ang,0])
            * translation([rot_r,0,0])
            * scaling([
              1,
              (ang < a*rot_r) ?       sqrt(1-pow(a*rot_r-ang,2)/pow(a*rot_r,2)) :
              (ang > 180 - a*rot_r) ? sqrt(1-pow(ang-(180 - a*rot_r),2)/pow(a*rot_r,2)) : 1,
              1])
            ]);
      translate([-10,-10,0])
        cube([10,10,tower_h]);
      translate([2*Bearing_r+2*bearing_wall,-10,0])
        cube([10,10,tower_h]);
    }
  }
  wall();
  mirror([0,1,0])
    wall();
  base();
}


