include <parameters.scad>
include <lineroller_parameters.scad>
use <sweep.scad>
use <util.scad>
use <lineroller_ABC_winch.scad>

//%prev_art();
module prev_art(){
  import("../stl/lineroller_D.stl");
}


e = 5.52;
f = 2.5; // extra x-length for swung wall
w = 2*(Ptfe_r+2);
height = Tower_h+6;
q = 3.0;
foot_shape_r = 1.0;
base_th = Base_th;
total_yw = Depth_of_lineroller_base+0;

function foot_shape2(r, e, f, w) = concat([
  for(i=[90:10:181])
     [-total_yw/2+r,f+w-r+0] + r*[cos(i), sin(i)]
  ],
  [for(i=[180:10:271])
     [-total_yw/2+r,-f+r] + r*[cos(i), sin(i)]
  ],
  [for(i=[270:10:361])
     [+total_yw/2-r,-f+r] + r*[cos(i), sin(i)]
  ],
  [for(i=[0:10:91])
     [+total_yw/2-r,w+f-r] + r*[cos(i), sin(i)]
  ]);


module topping(){
  stop_h_fac = 0.5011;
  //stop_h_fac = 0.12;
  extra_bearing_width = 0.4;
  difference(){
    translate([-1,0,0])
    rotate([-90,-90,0]){
      sweep(foot_shape2(foot_shape_r, e, f, w), concat(
            [
            translation([(Tower_h-2*Bearing_r+q)*(base_th/(Tower_h-2*Bearing_r+q)-0.01),0,0])
            * translation([0,w/2,0])
            * scaling([1,
                       wall_shape((base_th/(Tower_h-2*Bearing_r+q)-0.01), w, f),
                       wall_shape(stop_h_fac, Lineroller_wall_th, e/2)])
            * translation([0,-w/2,0])
            * rotation([0,-90,0])],
            [
            translation([height,0,0])
            * translation([0,w/2,0])
            * scaling([1,wall_shape(stop_h_fac, w, f),
              wall_shape(stop_h_fac, Lineroller_wall_th, e/2)])
            * translation([0,-w/2,0])
            * rotation([0,-90,0])
            ]));
    }
    bw = Bearing_width + extra_bearing_width;
    bearing_bore_z = Tower_h-Bearing_r-Bearing_wall;
    translate([-0.001,-(bw)/2,0])
      cube([100, bw, bearing_bore_z]);
    translate([Bearing_wall+Bearing_r,0, bearing_bore_z])
      rotate([90,0,0]){
        cylinder(r=Bearing_r+1, h=bw, center=true);
        cylinder(d=4.5, h=20, center=true);
      }
    translate([Bearing_wall + Bearing_r - Bearing_small_r,0,Tower_h-Bearing_r-Bearing_wall])
    cylinder(r=Ptfe_r, h=100, $fs=0.2);

    flerp0 = 6;
    flerp1 = 6;
    le = Depth_of_lineroller_base + 2*Bearing_r + 2*Bearing_wall + flerp0 + flerp1;
    translate([-2-flerp0,0,base_th])
      cylinder(r1=flerp0+0.3, r2=4.4, h=16);
  }
}
topping();

lineroller_ABC_winch(edge_start=90);
base();
