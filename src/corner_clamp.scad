include <lib/parameters.scad>
use <lib/util.scad>

//translate([50,0,0])
//import("../stl/lineroller_anchor.stl");

bw = 1;
d = Depth_of_roller_base;
lower_bearing_z = 10;
higher_bearing_z = lower_bearing_z + Corner_clamp_bearings_center_to_center;
tower_h = higher_bearing_z + b623_vgroove_big_r + 4.6;
w = b623_vgroove_big_r+bw+1.4;
bearing_1_x = b623_vgroove_small_r+w/6-0.8;
s = b623_width + 0.8;

wth = Wall_th;
edg_h = 1.5;
lwth = 2.3;

x_len = d-4; // For the two "wings" with tracks for screws
l = d + 2*b623_vgroove_big_r + 2*bw;

foot_shape_r = 1.0;

box_x = b623_vgroove_big_r*2+5.9;
box_y = 6;
bea_z = b623_vgroove_big_r+wth+b623_vgroove_room_to_grow_r+edg_h;
box_z = bea_z + b623_vgroove_big_r + 3.4;
small_r = 5;
xwards = -3.5;


//!small_wall();
module small_wall(){
  thinnest_z = (2*box_z + bea_z)/3;
  wth_at_thinnest = 2.5;
  big_r = 40;

  difference(){
    translate([xwards,0,0])
    union(){
      translate([-box_x/2,0.5,0])
        top_rounded_cube2([box_x, box_y, box_z], small_r, $fn=4*12);
      translate([-xwards+Move_d_bearings_inwards,0, bea_z])
        rotate([-90,0,0])
        cylinder(d=6, h=1);
      translate([-box_x/2, 0.5, -big_r + box_z - small_r])
        rotate([90,0,180])
		difference(){
          inner_round_corner(r=big_r, h=box_x, $fn=300);
		  translate([0,-21.7,0])
		  cube(100, center=true);
		}
    }
    translate([0,big_r+wth_at_thinnest+0.5, thinnest_z])
      rotate([0,90,0])
      cylinder(r=big_r, h=box_x+big_r, center=true, $fn=200);
    translate([Move_d_bearings_inwards,-1, bea_z])
      rotate([-90,0,0])
      M3_screw();
    translate([0,0,-2*big_r])
      cube(4*big_r, center=true);
  }
  translate([Move_d_bearings_inwards,1, bea_z])
    rotate([-90,0,0])
    rotate([0,0,30])
    hexagon_for_nut(h=wth_at_thinnest-1+2.5);
}

//!small_walls();
module small_walls(){
  for(k=[0,1])
    mirror([0,k,0])
      translate([0,1+b623_width, 0])
        small_wall();

  difference(){
    union(){
      translate([Move_d_bearings_inwards,0,bea_z])
        rotate([90,0,0])
          cylinder(d=6, h=2, center=true);
      translate([-box_x/2+xwards,-0.5,0])
        top_rounded_cube2([box_x, 1.0, box_z], small_r, $fn=4*12);
    }
    translate([Move_d_bearings_inwards,0,bea_z])
      rotate([90,0,0])
        cylinder(d=3.3, h=2.2, $fn=10,  center=true);
  }

  //for(k=[0,1]) mirror([0,k,0])
  //  translate([0, b623_width/2+1.8/2,0])
  //    preventor_edges(bea_z+Depth_of_roller_base/2, s, false, 180+90, 360);
  translate([1,-s-1,box_z-2])
    difference(){
      cube([3, 2*(s+2), 2]);
      rotate([0,45,0])
        translate([-3,-1,-3])
        cube([5, 2*s+4, 4]);
      rotate([-90,90,0])
        translate([-2,-small_r+0.55,-4])
          inner_round_corner(r=small_r, h=4*s,$fn=4*12);
  }
}

module action_point_holes(){
  for(k=[0,1]) mirror([k,0,0])
    translate([2/2+b623_width/2,Move_d_bearings_inwards,0]) {
      translate([0,Cc_action_point_from_mid - 0*b623_vgroove_small_r + Eyelet_extra_dist,-1])
        eyelet(h=wth+5);
      translate([0,Cc_action_point_from_mid - 2*b623_vgroove_small_r - Eyelet_extra_dist,-1])
        eyelet(h=wth+5);
    }
}

ears_y = 21.5;

//!corner_clamp_tower();
module corner_clamp_tower(base_th       = wth,
                          bearing_width = b623_width,
                          shoulder      = 0.5,
                          with_base     = false,
                          big_y_r1      = 190,
                          big_y_r2      = 140,
                          big_z_r       = 80){

  move_tower_x = 2.0;
  top_off_r = b623_vgroove_small_r;
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
    backit = 8.143;

    translate([move_tower_x, -lwth-shoulder-bearing_width/2, 0]){
      rotate([-90,-90,0]){
        difference(){
          union(){
            // Foot with a swing
            translate([tower_h-b623_vgroove_big_r,w/2,lwth])
              difference(){
                  translate([-tower_h+b623_vgroove_big_r, -x_len+4.5, -b_th])
                    if(big_y_r2_local)
                      cube([tower_h-foot_shape_r, l, b_th]);
                    else
                      cube([tower_h-foot_shape_r, l-backit, b_th]);
                if(big_y_r2_local)
                  translate([0,big_y_r2+w_local,-15])
                    cylinder(r=big_y_r2, h=30, $fn=250);
                translate([top_off_r, l-backit-x_len+4.5, -15])
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
    }
    // Edge to prevent line from falling of...
    a = 1.5;
    b = b623_vgroove_room_to_grow_r;
    rot_r = b623_vgroove_big_r+b;
    translate([move_tower_x,0,0]) {
      b_pos=[bearing_1_x, -bearing_width/2-0.8, higher_bearing_z];
      difference() {
        translate(b_pos)
          rotate([-90,270,0])
            rotate_extrude(angle=90,convexity=10, $fn=60)
              translate([rot_r,0])
              polygon(points = [[0,0], [0,-0.5], [b+a, -0.5], [b+a,0], [b, a], [0, a]]);
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
              }
            }
          }
        }
      }
    }
  } // end module wall

  intersection() {
    translate([d/2,20,0])
      rotate([0,0,-90])
        difference(){
          union(){
            wall(w + 6, big_y_r2_local = false);
            mirror([0,1,0])
              wall();
            translate([bearing_1_x+2, -(b623_width+2)/2,tower_h-2])
              cube([2, b623_width+2, 1]);
            cube_h = tower_h - higher_bearing_z-1;
            difference(){
              union(){
                translate([20-ears_y,-w/2, lower_bearing_z-cube_h])
                  cube([2.5, w, cube_h]);
                translate([20-ears_y,-w/2, higher_bearing_z])
                  cube([2.5, w, cube_h]);
              }
              translate([bearing_1_x+move_tower_x, 0, higher_bearing_z])
                rotate([90,0,0])
                  cylinder(r=b623_vgroove_big_r + b623_vgroove_room_to_grow_r, h=b623_width+1, center=true);
              translate([bearing_1_x+move_tower_x, 0, lower_bearing_z])
                rotate([90,0,0])
                  cylinder(r=b623_vgroove_big_r + b623_vgroove_room_to_grow_r, h=b623_width+1, center=true);
            }
          }
          // vertical action point holes
          // these measurements will be needed when cadding anchor lineroller (foot block)
          translate([0,0, lower_bearing_z - b623_vgroove_small_r - Eyelet_extra_dist])
            rotate([0,90,0])
              eyelet(h=5, center=true);
          translate([0,0, higher_bearing_z + b623_vgroove_small_r + Eyelet_extra_dist])
            rotate([0,90,0])
              eyelet(h=5, center=true);
          // Just a tiny tiny detail
          translate([move_tower_x, -(bearing_width + 2*wth)/2, 0])
            rotate([-90,-90,0])
              translate([top_off_r+tower_h-b623_vgroove_big_r, w+0.1+w/2, lwth + 1])
                rotate([0,0,180])
                  inner_round_corner(r=top_off_r, h=30, back=5, $fn=50);

        }
    translate([0,-1,0])
      three_rounded_cube2([d, ears_y+1,tower_h+10], 5, $fn=4*8);
  }
}

//translate([60,0,0])
//import("../stl/corner_clamp.stl");
corner_clamp();
module corner_clamp(){
  a = 13;
  b = Fat_beam_width+wth+2-a/2;
  l0 = 40;
  d_hole_l = l0/2+2;

  // Channel to guide D-line and stiffen up corner
  channel_l = Cc_action_point_from_mid-10;
  channel_r1 = 1;
  channel_r2 = 5;

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
        fillet_r = 2.5;
        translate([0,(wth-fillet_r)*2,0]){
          rotate([0,0,-90-45])
            translate([-fillet_r, -fillet_r,wth])
            translate([fillet_r*(1-cos(15)),fillet_r*(1-cos(15)),0])
            inner_round_corner(fillet_r,30,120,2, $fn=4*8);
        }
      } // end diff
      // slanting
      difference(){
        translate([-channel_r2/2, 0.3, 0])
          rounded_cube2([channel_r2, channel_l-4.2, Fat_beam_width+wth+1.5], 2, $fn=20);
        translate([-(channel_r2+6)/2,channel_l,wth+3])
          rotate([90-atan((Fat_beam_width+0.5)/channel_l),0,0])
          cube([channel_r2+6,16,sqrt(channel_l*channel_l + Min_beam_width*Min_beam_width)]);
        translate([0.5,Cc_action_point_from_mid+Move_d_bearings_inwards-b623_vgroove_small_r, bea_z])
          rotate([0,90,0])
            cylinder(r=b623_vgroove_big_r+b623_vgroove_room_to_grow_r, h=b623_width+1);
      }

      translate([0,Cc_action_point_from_mid-b623_vgroove_small_r,0.1])
        rotate([0,0,90])
          small_walls();

      edg_w = 19.0;
      rh = 2.8;
      for(k=[0,1])
        mirror([k,0,0])
          rotate([0,0,60]){
            rounded_cube2([edg_w, Fat_beam_width+2*wth, wth+edg_h], 0.5, $fn=20);
          }
    } // end union
    action_point_holes();

  } // end diff

  difference(){
    union(){
      for(k=[0,1])
        mirror([k,0,0])
          translate([0,Cc_action_point_from_mid,0])
          rotate([0,0,-60])
          translate([-d/2,2,0]){
		    difference(){
              rounded_cube2([d, ears_y,wth], 5, $fn=4*8);
              translate([d/2,20,0])
                rotate([0,0,-90])
                translate([0,0, lower_bearing_z - b623_vgroove_small_r - Eyelet_extra_dist])
                rotate([0,90,0])
                eyelet(h=6, center=true);
			}
            corner_clamp_tower();
            translate([d,5.5,0])
              inner_round_corner(8, wth+1.5, 90, 2, $fn=80);
          }
      translate([0,Cc_action_point_from_mid,higher_bearing_z])
        rotate([-110,0,0])
          translate([0,0,7.4])
            cylinder(d=7, h=3.5, center=true, $fn=12);
    }

    action_point_holes();
    translate([0,Cc_action_point_from_mid,higher_bearing_z])
      rotate([-110,0,0])
        M3_screw(h=100, center=true);
    // Just to check that lower bearing has some room to grow...
    //for(k=[0,1])
    //  mirror([k,0,0])
    //    translate([0,Cc_action_point_from_mid,0])
    //      rotate([0,0,-60])
    //        translate([-d/2,2,0])
    //          translate([d/2,20,0])
    //            rotate([0,0,-90])
    //              translate([bearing_1_x+2, 0, lower_bearing_z])
    //                rotate([90,0,0])
    //                  cylinder(r=b623_vgroove_big_r+1.5, h=b623_width, center=true);

  }
  translate([0,Cc_action_point_from_mid+9.32,0])
    rotate([0,0,45])
    inner_round_corner(5, wth+1.5, 60, 2, $fn=40);
}
