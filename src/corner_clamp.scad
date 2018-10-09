include <parameters.scad>
use <util.scad>

//translate([50,0,0])
//import("../stl/lineroller_anchor.stl");

bw = 1;
d = Depth_of_roller_base;
lower_bearing_z = 10;
higher_bearing_z = lower_bearing_z + Corner_clamp_bearings_center_to_center;
tower_h = higher_bearing_z + b623_vgroove_big_r + 4.6;
w = b623_vgroove_big_r+bw+1.4;
bearing_1_x = b623_vgroove_small_r+w/6-0.8;

wth = Wall_th;
lwth = 2.3;

x_len = d-4; // For the two "wings" with tracks for screws
l = d + 2*b623_vgroove_big_r + 2*bw;

foot_shape_r = 1.0;

//corner_clamp_tower();
module corner_clamp_tower(base_th       = wth,
                          bearing_width = b623_width+0.2,
                          shoulder      = 0.3,
                          with_base     = false,
                          big_y_r1      = 190,
                          big_y_r2      = 43,
                          big_z_r       = 80){

  move_tower_x = 2.0;
  module wall(w_local        = w,
              big_y_r2_local = true){
    // Foot parameters
    c = 10;
    e = 5.52;
    //f = 2.5; // extra x-length for swung wall
    round_part = 0.65;
    // Main block
    r2 = b623_bore_r+1.3;
    f = d-w-2*foot_shape_r; // extra x-length for swung wall

    b_th = lwth+e;
    top_off_r = b623_vgroove_small_r;

  translate([move_tower_x, -(bearing_width + 2*wth)/2, 0])
      rotate([-90,-90,0]){
        difference(){
          union(){
            // Foot with a swing
            translate([0,0,lwth])
              translate([tower_h-b623_vgroove_big_r,w/2,0])
                difference(){
                  translate([-tower_h+b623_vgroove_big_r, -x_len+4.5, -b_th])
                    if(big_y_r2_local)
                      cube([tower_h-foot_shape_r, l, b_th]);
                    else
                      cube([tower_h-foot_shape_r, l-8.03, b_th]);
                  translate([0,-big_y_r1-w/2,-15])
                    cylinder(r=big_y_r1, h=30, $fn=250);
                  if(big_y_r2_local)
                    translate([0,big_y_r2+w_local,-15])
                      cylinder(r=big_y_r2, h=30, $fn=250);
                  translate([top_off_r, -w/2-0.1, -15])
                    rotate([0,0,90])
                      inner_round_corner(r=top_off_r, h=30, back=5, $fn=50);
                  translate([top_off_r, w_local+0.1, -15])
                    rotate([0,0,180])
                      inner_round_corner(r=top_off_r, h=30, back=5, $fn=50);
                  translate([0,0,-big_z_r-wth])
                    rotate([90,0,0])
                      cylinder(r=big_z_r, h=50, center=true, $fn=250);
                  translate([-0.1-tower_h+b623_vgroove_big_r, -(w+f+2*foot_shape_r+20)/2, -15])
                    cube([base_th, w+f+2*foot_shape_r+32, 29]);
                }
              translate([lower_bearing_z, bearing_1_x, 0]){
                cylinder(r=r2, h=lwth+shoulder, $fs=1);
                dpth=4;
                translate([0,0,-dpth])
                  hexagon_for_nut(h=dpth);
              }
              translate([higher_bearing_z, bearing_1_x, 0]){
                cylinder(r=r2, h=lwth+shoulder, $fs=1);
                dpth=1.5;
                translate([0,0,-dpth])
                  hexagon_for_nut(h=dpth);
              }
          }
          translate([lower_bearing_z,bearing_1_x,-7])
            cylinder(d=b623_bore_r*2+0.3, h=lwth+12, $fs=1);
          translate([higher_bearing_z,bearing_1_x,-1])
            cylinder(d=b623_bore_r*2+0.3, h=lwth+0.5+2, $fs=1);
        }
      }
  // Edge to prevent line from falling of...
  a = 1.5;
  b = 0.8;
  rot_r = b623_vgroove_big_r+b;
  translate([move_tower_x,0,0])
    for(b_pos=[[[bearing_1_x, -bearing_width/2-0.8, higher_bearing_z], 270],
        [[bearing_1_x, -bearing_width/2-0.8, lower_bearing_z], 0]])
      difference(){
        translate(b_pos[0])
          rotate([-90,b_pos[1],0])
          difference(){
            rotate_extrude(angle=90,convexity=10, $fn=60)
              translate([rot_r,0])
              polygon(points = [[0,0], [0,-0.5], [b+a, -0.5], [b+a,0], [b, a], [0, a]]);
            translate([0,0,-1])
              linear_extrude(height=b+a+1)
              polygon(points=circle_sector(360-(b_pos[1][1]-b_pos[1][0]), 1, rot_r+b+a+1));
          }
        translate([0, -(bearing_width + 2*wth)/2, 0]){
          rotate([-90,-90,0]){
            translate([0,0,lwth]){
              translate([tower_h-b623_vgroove_big_r,w/2,0]){
                if(big_y_r2_local)
                  translate([0,+big_y_r2+w,-15])
                    cylinder(r=big_y_r2, h=30, $fn=250);
                translate([0,-big_y_r1-w/2,-15])
                  cylinder(r=big_y_r1, h=30, $fn=250);
                translate([top_off_r, -w/2-0.1, -15])
                  rotate([0,0,90])
                  inner_round_corner(r=top_off_r, h=30, back=5, $fn=50);
                translate([top_off_r, w+0.1, -15])
                  rotate([0,0,180])
                  inner_round_corner(r=top_off_r, h=30, back=5, $fn=50);
              }
          }
        }
      }
    }
  }
  intersection(){
    translate([d/2,20,0])
      rotate([0,0,-90])
        difference(){
          union(){
            wall(w+6, big_y_r2_local=false);
            mirror([0,1,0])
              wall();
            translate([bearing_1_x+1, -(b623_width+2)/2,tower_h-3])
            cube([2, b623_width+2, 2]);
          }
        }
   translate([0,-6,0])
     three_rounded_cube2([d, 26,tower_h+10], 5);
  }
}

//translate([60,0,0])
//import("../stl_old/corner_clamp.stl");
corner_clamp();
module corner_clamp(){
  a = 13;
  b = Fat_beam_width+wth+2-a/2;
  l0 = 40;
  d_hole_l = l0/2+2;

  // Channel to guide D-line and stiffen up corner
  channel_l = Cc_action_point_from_mid-2.5/2;
  channel_r1 = 1;
  channel_r2 = 3;

  difference(){
    union(){
      difference(){
        union(){
          translate([-Cc_l1/2,-Cc_l1/sqrt(12),0])
            linear_extrude(height=wth)
            polygon(points = my_rounded_eqtri(Cc_l1,Cc_rad_b,5));
          for(k=[0,1])
            mirror([k,0,0])
              rotate([0,0,-30]){
                translate([-(Fat_beam_width+wth)+1, -l0+wth*sqrt(3), 0]){
                  one_rounded_cube4([Fat_beam_width+wth-1, l0+a, Fat_beam_width+2*wth],
                      2, $fn=4*4);
                  translate([-wth-1,0,0])
                    rounded_cube2([2*wth+1, l0+a, wth],2,$fn=4*4);
                }
              }
          translate([0,-sqrt(2)/sqrt(5),wth])
            rotate([0,0,-90-45])
            inner_round_corner(1,Fat_beam_width+wth,120,1.0, $fn=4*8);
        } // end union
        zip_fr_edg = 8;
        for(k=[0,1])
          mirror([k,0,0])
            rotate([0,0,-30]){
              translate([-Fat_beam_width-wth, -l0+4, wth]){
                cube([Fat_beam_width, l0+a+2, Fat_beam_width+20]);
                translate([-wth,0,-wth]){
                  opening_top(exclude_left = true, wall_th=wth, edges=0, l=l0+2, extra_h=0);
                }

              }
              zip_l = 15+wth+Zip_h;
              for(k=[0,1]){
                translate([-Zip_h-wth-Min_beam_width-1,
                    k*(-l0+wth*sqrt(3)+2*zip_fr_edg)-zip_fr_edg-2-1.0,
                    -0.10])
                  translate([-0,-Zip_w/2,0])
                  translate([(Zip_h+2)/2,(Zip_w+2)/2,0])
                  chamfer45([Zip_h+2, Zip_w+2], h=1);
                translate([-(zip_l-Zip_h),
                    k*(-l0+wth*sqrt(3)+2*zip_fr_edg)-zip_fr_edg-2,
                    wth+Min_beam_width]){
                  translate([zip_l-Zip_h,0,0])
                    rotate([0,90,0])
                    translate([0,-Zip_w/2,0])
                    cube([zip_l, Zip_w, Zip_th]);
                  rotate([0,0,0])
                    translate([0,-Zip_w/2,0])
                    cube([zip_l, Zip_w, Zip_h]);
                }
                translate([(Zip_th+1)/2-1/2,-zip_fr_edg-2,-0.1])
                  chamfer45([Zip_th+2, Zip_w+2], h=1);
                translate([-Zip_h-wth-Min_beam_width,
                    k*(-l0+wth*sqrt(3)+2*zip_fr_edg)-zip_fr_edg-2,
                    -1])
                  translate([0,-Zip_w/2,0])
                  cube([Zip_h, Zip_w, zip_l]);
              }

            }
        translate([0,Cc_action_point_from_mid,-1])
          cylinder(d=2.5, h=wth+2, $fn=10);
        fillet_r = 2.5;
        translate([0,(wth-fillet_r)*2,0]){
          rotate([0,0,-90-45])
            translate([-fillet_r, -fillet_r,wth])
            translate([fillet_r*(1-cos(15)),fillet_r*(1-cos(15)),0])
            inner_round_corner(fillet_r,30,120,2, $fn=4*8);
        }
      } // end diff
      // Slanting beam towards action point
      difference(){
        translate([-channel_r2/2,0,0])
          rounded_cube2([channel_r2, channel_l-1, Min_beam_width+wth], 1, $fn=20);
        translate([-(channel_r2+2)/2,channel_l,wth+3])
          rotate([90-atan((Min_beam_width-3)/channel_l),0,0])
          cube([channel_r2+2,16,sqrt(channel_l*channel_l + Min_beam_width*Min_beam_width)]);
      }
      edg_h = 1.5;
      edg_w = 15.5;
      rh = 2.8;
      for(k=[0,1])
        mirror([k,0,0])
          rotate([0,0,60]){
            rounded_cube2([edg_w, Fat_beam_width+2*wth, wth+edg_h], 0.5, $fn=20);
          }
    } // end union
    translate([0,channel_l,wth+3])
      rotate([90-atan((Min_beam_width-4.3)/(channel_l)),0,0])
      translate([0,1.3,0])
      cylinder(r=1.3, h=sqrt(channel_l*channel_l + Min_beam_width*Min_beam_width)+2, $fn=10);
  } // end diff

  for(k=[0,1])
    mirror([k,0,0])
      translate([0,Cc_action_point_from_mid,0])
      rotate([0,0,-60])
      translate([-d/2,2,0]){
        rounded_cube2([d, 20,wth], 5);
        corner_clamp_tower();
        translate([d,5.5,0])
          inner_round_corner(8, wth+1.5, 90, 2, $fn=80);
      }
  translate([0,Cc_action_point_from_mid+9.32,0])
    rotate([0,0,45])
    inner_round_corner(5, wth+1.5, 60, 2, $fn=40);
}
