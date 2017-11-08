include <parameters.scad>
include <lineroller_parameters.scad>
use <sweep.scad>
use <util.scad>
use <lineroller_ABC_winch.scad>

//%prev_art();
module prev_art(){
  import("../stl/lineroller_D.stl");
}


height = Tower_h+6;
foot_shape_r = 1.0;
base_th = Base_th;
bearing_width = Bearing_width+0.1; // Give extra space for bearing in this part

module topping(){
  stop_h_fac = 0.5011;
  extra_bearing_width = 0.4; // Only used for antimateria of PTFE-tower
  bw = bearing_width + extra_bearing_width;
  difference(){
    tx = Depth_of_lineroller_base/2+2.25; // Nothing magic about 2.25. Just for looks
    ty = Bearing_width+extra_bearing_width+2*Lineroller_wall_th+0.1;
    translate([Bearing_r+Bearing_wall+1,0,0])
      linear_extrude(height = height, slices=1, scale=[0.8646,1]) // Nothing magic about 0.8646
        translate([-tx,-ty/2])
        rounded_square([tx, ty], foot_shape_r,$fn=4*6);

    bearing_bore_z = Tower_h-Bearing_r;
    translate([-0.001,-(bw)/2,0])
      cube([100, bw, bearing_bore_z]);
    translate([Bearing_wall+Bearing_r,0, bearing_bore_z]){
      rounded_cube([30,3,3], center=true, 0.6);
      rotate([90,0,0]){
        cylinder(r=Bearing_r+2, h=bw, center=true);
        cylinder(d=4.5, h=20, center=true);
      }
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

lineroller_ABC_winch(edge_start=90, edge_stop=180-40, bearing_width=bearing_width);
base();
