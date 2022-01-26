include <lib/parameters.scad>
use <lib/util.scad>

// Investigate layers
//difference(){
//  horizontal_line_deflector();
//  translate([0,0,72.0])
//  cube(100,center=true);
//}

rotate([90,0,0])
horizontal_line_deflector();
module horizontal_line_deflector(twod=false){
  cx = b623_big_ugroove_big_r*2 + 7;
  cy = Horizontal_deflector_cube_y_size;
  bz = Gap_between_sandwich_and_plate + Sep_disc_radius - Spool_r;
  bit_y = cy;

  pl = 5.5;
  ybit = -cy+5+bit_y/2;
  ybit_hole = ybit + 4;
  module bit(){
    rotate([0,0,90])
      translate([-Bit_width/2, -bit_y/2, 0])
      difference(){
        one_rounded_cube2([Bit_width+4,bit_y,Base_th], 6.5, $fn=28);
        translate([-2,8,-1])
          rotate([0,0,45])
            cube([20, 20, Base_th+2]);
      }
  }

  mirror([1,0,0]) {
    if(!twod){
      extra_b_height = 0.8; // half of this above, half below
      extra_b_width = 3*b623_ugroove_room_to_grow_r; // half of this to the left of bearing
      full_h = bz+8;
      take_away_angle = 90;

      // something to aim for
      a = b623_big_ugroove_small_r-3;
      %translate([ 0, 0, bz ])
        translate([0,-a, 0]){
          color("yellow")
            b623_big_ugroove();
          }
      difference(){
        union(){
          translate([-cx/2, -cy+5, 0])
            ydir_rounded_cube2([cx, cy, full_h], 3, $fn=4*6);
          for(k=[0,1])
            mirror([k,0,0]){
              difference(){
                union(){
                  translate([6,3,0])
                    cube([2, 2, Base_th*2]);
                  translate([cx/2,-cy+5,Base_th])
                    rotate([0,-90,-90])
                    inner_round_corner(r=2, h=cy, $fn=4*5, back=Base_th-0.1);
                  translate([cx/2+pl,ybit,0])
                    rotate([0,0,90])
                    bit();
                }
                translate([cx/2,5,Base_th])
                  corner_rounder();
                translate([cx/2+pl,ybit_hole,0.5])
                  Mounting_screw();
              }
            }
        }
        translate([0,0,bz]){
          translate([0,-a, 0])
            rotate([0,0,0])
              scale([(b623_big_ugroove_big_r+extra_b_width/2)/b623_big_ugroove_big_r,
                  (b623_big_ugroove_big_r+extra_b_width/2)/b623_big_ugroove_big_r,
                  1]){
                elong_b623_big_ugroove(20, extra_b_height);
              }
        }
        translate([0,0,bz])
          translate([0,-a, 0])
            translate([0, 0,-1-bz]){
              M3_screw(h=100, center=true);
              translate([0,0,-10])
                nut(h=bz+1-b623_width/2-extra_b_height/2 + 8);
              translate([0,0,full_h - 1.5])
                nut(h=10);
            }
        // The screw head of the one standing behind
        translate([0,-cy,bz])
          translate([0,-a, 0])
            translate([0, 0,-1-bz])
              translate([0,0,full_h-9])
                hull(){
                  cylinder(d=M3_screw_head_d, h=10, $fn=24);
                  translate([0,-4,0])
                    cylinder(d=M3_screw_head_d, h=10);
                }

        sly = 40;
        q = a-1;
        for(k=[0,1]) mirror([k,0,0])
          translate([q,0,bz])
            translate([0,-sly+1,-2.5/2])
              cube([100,sly, 2.5]);
      }

      shoulder_height = extra_b_height/2;
      for(hl=[-(b623_width+extra_b_height)/2-2+shoulder_height,
          (b623_width+extra_b_height)/2 - shoulder_height])
        translate([0, 0, bz])
          translate([0,-a, 0])
            translate([0, 0,hl])
              difference(){
                cylinder(d=5, h=2, $fn=12);
                  translate([0,0,-1])
                    cylinder(d=3.3, h=4, $fn=12); // The ring to rest b623 bore on
              }

    } else { //twod
      difference(){
        translate([-cx/2-Bit_width+0.5, -cy+5])
          ydir_rounded_cube2_2d([cx+2*Bit_width-1, cy], 6.5, $fn=28);
        for(k=[0,1])
          mirror([k,0]){
            translate([cx/2+pl,ybit_hole])
              Mounting_screw(twod=true);
            translate([-cx/2-Bit_width+0.5, -cy+5])
              translate([-2,-17.23])
                rotate([0,0,45])
                  square([20, 20]);
          }
      }
    }
  }
}

