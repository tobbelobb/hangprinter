include <parameters.scad>
use <util.scad>
use <lineroller_ABC_winch.scad>

base_th = 6;
l = Depth_of_lineroller_base + 2*b623_vgroove_big_r + 2*Bearing_wall;
track_l = l;
head_r = 3.5;
screw_r = 1.5;

x_len = Depth_of_lineroller_base-4; // For the two "wings" with tracks for screws
y_extra = -2.0; // For the two "wings" with tracks for screws

tower_h = Higher_bearing_z + b623_vgroove_big_r;

//lineroller_tower(with_base=true);
module lineroller_tower(bearing_width = b623_width+0.2,
                        shoulder      = 0.3,
                        with_base     = false,
                        big_y_r1      = 190,
                        big_y_r2      = 36,
                        big_z_r       = 83){
  module wall(){
    // Foot parameters
    c = 10;
    e = 5.52;
    //f = 2.5; // extra x-length for swung wall
    w = b623_vgroove_big_r*2+2*Bearing_wall+1.4;
    round_part = 0.65;
    // Main block
    r2 = b623_bore_r+1.3;
    foot_shape_r = 1.0;
    f = Depth_of_lineroller_base-w-2*foot_shape_r; // extra x-length for swung wall

    b_th = Lineroller_wall_th+e;
    top_off_r = b623_vgroove_small_r;

  translate([Move_tower, -(bearing_width + 2*Wall_th)/2, 0])
      rotate([-90,-90,0]){
        difference(){
          union(){
            // Foot with a swing
            translate([0,0,Lineroller_wall_th])
              translate([tower_h-b623_vgroove_big_r,w/2,0])
                difference(){
                  translate([-tower_h+b623_vgroove_big_r, -x_len+4.5, -b_th])
                    cube([tower_h-foot_shape_r, l, b_th]);
                  translate([0,-big_y_r1-w/2,-15])
                    cylinder(r=big_y_r1, h=30, $fn=250);
                  translate([0,+big_y_r2+w,-15])
                    cylinder(r=big_y_r2, h=30, $fn=250);
                  translate([top_off_r, -w/2-0.1, -15])
                    rotate([0,0,90])
                      inner_round_corner(r=top_off_r, h=30, back=5, $fn=50);
                  translate([top_off_r, w+0.1, -15])
                    rotate([0,0,180])
                      inner_round_corner(r=top_off_r, h=30, back=5, $fn=50);
                  translate([0,0,-big_z_r-Wall_th])
                    rotate([90,0,0])
                      cylinder(r=big_z_r, h=50, center=true, $fn=250);
                  translate([-0.1-tower_h+b623_vgroove_big_r, -(w+f+2*foot_shape_r+20)/2, -15])
                    cube([base_th, w+f+2*foot_shape_r+20, 30]);
                }
              // Check if bearing fits
              //#translate([Lower_bearing_z ,Bearing_1_x, Lineroller_wall_th])
              //  cylinder(r1  = b623_vgroove_big_r,
              //           r2  = b623_vgroove_small_r,
              //           h   = b623_width/2+0.3,
              //           $fn = 5*10);
              translate([Lower_bearing_z, Bearing_1_x, 0]){
                cylinder(r=r2, h=Lineroller_wall_th+shoulder, $fs=1);
                dpth=3;
                translate([0,0,-dpth])
                  hexagon_for_nut(h=dpth);
              }
              translate([Higher_bearing_z, Bearing_0_x, 0]){
                cylinder(r=r2, h=Lineroller_wall_th+shoulder, $fs=1);
                dpth=1.5;
                translate([0,0,-dpth])
                  hexagon_for_nut(h=dpth);
              }
              // Check if bering fits
              //#translate([Higher_bearing_z ,Bearing_0_x, Lineroller_wall_th])
              //  cylinder(r1  = b623_vgroove_big_r,
              //           r2  = b623_vgroove_small_r,
              //           h   = b623_width/2+0.3,
              //           $fn = 5*10);
              translate([Higher_bearing_z ,Bearing_1_x, Lineroller_wall_th])
                cylinder(r1  = b623_vgroove_big_r,
                         r2  = b623_vgroove_small_r,
                         h   = b623_width/2+0.3,
                         $fn = 5*10);
          }
          translate([Lower_bearing_z,Bearing_1_x,-7])
            cylinder(d=b623_bore_r*2+0.3, h=Lineroller_wall_th+12, $fs=1);
          translate([Higher_bearing_z,Bearing_0_x,-1])
            cylinder(d=b623_bore_r*2+0.3, h=Lineroller_wall_th+0.5+2, $fs=1);
        }
      }
    // Edge to prevent line from falling of...
    a = 1.65;
    b= 0.8;
    rot_r = b623_vgroove_big_r+b;
    translate([Move_tower,0,0])
    for(b_pos=[[[Bearing_0_x, -bearing_width/2-0.8, Higher_bearing_z],[0,120]],
               [[Bearing_1_x, -bearing_width/2-0.8, Lower_bearing_z], [0,60]]])
    difference(){
      translate(b_pos[0])
        rotate([-90,0,0])
          difference(){
            rotate_extrude(angle=180, convexity=10, $fn=60)
              translate([rot_r,0])
                polygon(points = [[0,0], [0,-0.5], [b+a, -0.5], [b+a,0], [b, a], [0, a]]);
            rotate([0,0,b_pos[1][1]])
              translate([0,0,-1])
                linear_extrude(height=b+a+1)
                  polygon(points=circle_sector(360-(b_pos[1][1]-b_pos[1][0]), 1, rot_r+b+a+1));
            rotate([0,0,b_pos[1][0]])
              translate([rot_r-1,0,0])
                rotate([45,0,0])
                  cube(b+a+1);
            rotate([0,0,b_pos[1][1]])
              translate([rot_r-1,0,0])
                rotate([45,0,0])
                  cube(b+a+1);
          }
      translate([-10,-10,0])
        cube([10,10,tower_h]);
      translate([0, -(bearing_width + 2*Wall_th)/2, 0])
        rotate([-90,-90,0])
        translate([0,0,Lineroller_wall_th])
        translate([Higher_bearing_z,w/2,0])
        translate([0,+big_y_r2+w,-15])
        cylinder(r=big_y_r2, h=30, $fn=250);
    }
  }
  difference(){
    union(){
      wall();
      mirror([0,1,0])
        wall();
    }
    translate([Move_tower+Bearing_1_x-3.7,0,Higher_bearing_z+1])
      difference(){
        cylinder(r=3.7, h=8, $fn=40);
        cylinder(r=2.0, h=10, $fn=40);
      }
  }
}

//translate([0,-Depth_of_lineroller_base-5,0])
//  mirror([0,1,0])
//    lineroller_anchor();
lineroller_anchor();
module lineroller_anchor(){
  // Module lineroller_ABC_winch() defined in lineroller_ABC_winch.scad
  difference(){
    lineroller_tower(base_th = base_th);
    for(k=[0,1])
      mirror([0,k,0])
        translate([-x_len,-Depth_of_lineroller_base/2,-1])
          inner_round_corner(r=Lineroller_base_r, h=30, back=5, $fn=4*10);

    translate([l-x_len,-Depth_of_lineroller_base/2,0])
    rotate([0,0,90])
      translate([0,0,-1])
        inner_round_corner(r=Lineroller_base_r, h=30, back=5, $fn=4*10);
  }

  module slot_for_countersunk_screw(len){
    translate([-x_len, -Depth_of_lineroller_base/2, 0]){
      translate([len-Depth_of_lineroller_base/2, Depth_of_lineroller_base/2, -0.1]){
        rotate([0,0,180]){
          translate([0,0,Screw_h+Screw_head_h-0.01])
            linear_extrude(height=1)
            scale(1+(head_r-screw_r)/screw_r)
            translate([0,-screw_r])
            union(){
              square([track_l-screw_r, 2*screw_r]);
              translate([0,screw_r])
                circle(r=screw_r,$fn=4*10);
            }
          linear_extrude(height=Screw_h+1)
            translate([0,-screw_r])
            union(){
              square([track_l-screw_r, 2*screw_r]);
              translate([0,screw_r])
                circle(r=screw_r,$fn=4*10);
            }
          translate([0,0,Screw_h])
            linear_extrude(height=Screw_head_h, scale=1+(head_r-screw_r)/screw_r)
            translate([0,-screw_r])
            union(){
              square([track_l-screw_r, 2*screw_r]);
              translate([0,screw_r])
                circle(r=screw_r,$fn=4*10);
            }
        }
      }
    }
  }

  base_mid(base_th = base_th);
  module base_mid(base_th, l = l){
    difference(){
      translate([-x_len, -Depth_of_lineroller_base/2, 0])
        translate([l, Depth_of_lineroller_base,0])
        rotate([0,0,180])
        three_rounded_cube2([l, Depth_of_lineroller_base, base_th], Lineroller_base_r, $fn=10*4);
      slot_for_countersunk_screw(l);
    }
  }

  translate([l-x_len,Depth_of_lineroller_base+y_extra-0.01,0]){
    base_wing(base_th = base_th, x_len = x_len, y_extra = y_extra);
    translate([-x_len,-Depth_of_lineroller_base/2-y_extra,0])
    rotate([0,0,90])
    inner_round_corner(r=2, h=base_th, $fn=4*7);
  }
  module base_wing(base_th, x_len, y_extra = y_extra){
    difference(){
      translate([-x_len, -Depth_of_lineroller_base/2, 0])
        translate([x_len/2, Depth_of_lineroller_base/2, 0])
        rotate([0,0,90])
        translate([-Depth_of_lineroller_base/2-y_extra, -x_len/2, 0])
        right_rounded_cube2([Depth_of_lineroller_base+y_extra, x_len, base_th], Lineroller_base_r, $fn=10*4);
      slot_for_countersunk_screw(x_len);
    }
  }
}
