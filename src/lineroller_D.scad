include <parameters.scad>
use <util.scad>
use <lineroller_ABC_winch.scad>

height = Tower_h+6;
foot_shape_r = 1.0;
base_th = Base_th;
shoulder=0.4;
extra_bearing_width = shoulder+0.3;
bearing_width = b623_width + extra_bearing_width; // Give extra space for bearing in this part

module topping(){
  difference(){
    tx = Depth_of_lineroller_base/2+2.25; // Nothing magic about 2.25. Just for looks
    ty = b623_width+extra_bearing_width+2*Lineroller_wall_th + extra_bearing_width;
    translate([b623_vgroove_big_r+Bearing_wall+1,0,0])
      linear_extrude(height = height, slices=1, scale=[0.8646,1]) // Nothing magic about 0.8646
        translate([-tx,-ty/2])
        rounded_square([tx, ty], foot_shape_r,$fn=4*6);

    bearing_bore_z = Tower_h-b623_vgroove_big_r;
    translate([-0.001,-(bearing_width+extra_bearing_width)/2,-1])
      cube([100, bearing_width+extra_bearing_width, bearing_bore_z+1]);
    translate([Bearing_wall+b623_vgroove_big_r,0, bearing_bore_z]){
      rounded_cube([30,3,3], center=true, 0.6);
      rotate([90,0,0]){
        cylinder(r=b623_vgroove_big_r+2, h=bearing_width+extra_bearing_width, center=true);
        cylinder(d=4.5, h=20, center=true);
      }
    }
    translate([Bearing_wall + b623_vgroove_big_r - b623_vgroove_small_r,0,Tower_h-b623_vgroove_big_r-Bearing_wall])
    cylinder(r=Ptfe_r, h=100, $fs=0.2);

  }
  slide_r = 2*Tower_h/5;
  difference(){
    translate([-0.001,-(bearing_width+extra_bearing_width)/2,0])
      cube([slide_r, bearing_width+extra_bearing_width, base_th+slide_r]);
    translate([slide_r, 0, base_th+slide_r])
      rotate([90,0,0])
        cylinder(r=slide_r, h=bearing_width+extra_bearing_width+2, center=true);
  }
}

lineroller_D();
module lineroller_D(twod=false){
  if(!twod){
    difference(){
      union(){
        topping();
        lineroller_ABC_winch(edge_start=90, edge_stop=180-40,
                             bearing_width=bearing_width+extra_bearing_width-shoulder,
                             shoulder=shoulder);
      }
      screws_space();
    }
  }
  base(twod=twod,openings=[true,false,false,false]);
}
