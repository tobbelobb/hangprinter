include <lib/parameters.scad>
use <lib/util.scad>
use <bearing_u_608.scad>


// Investigate layers
//difference(){
//  horizontal_line_deflector();
//  translate([0,0,72.0])
//  cube(100,center=true);
//}

//mirror([1,0,0])
//rotate([0,0,-30])
//slanted_lines_for_aiming();
module slanted_lines_for_aiming(liney=0){
  $fn=20;
  line_from_to([103, liney, 9.5], [0, liney, 9.5], r=1.1);
  line_from_to([-b608_vgroove_small_r*sin(30), -(liney+b608_vgroove_small_r*(1-cos(30))), 9.5],
               [0, -liney, 9.5] + [cos(120)*100, -sin(120)*100, 130],
               r=1.1);
}

tilted_line_deflector(twod=false,rotx=-atan(sqrt(2)), rotz=-30); // Angle atan(sqrt(2)) works if ABCD anchors form like sided tetrahedron
//tilted_line_deflector(rotz=-30, rotx=-10, bullet_shootout=true);
module tilted_line_deflector(twod=false, rotx=0, rotz=0, bullet_shootout=true, behind=false){
  cx = b608_vgroove_big_r*2 + 8;
  cy = Horizontal_deflector_cube_y_size*(2+sin(-rotz));
  move_along_line = -11.5;
  thicken_along_line = move_along_line-5;
  bz = Gap_between_sandwich_and_plate + Sep_disc_radius - Spool_r;
  bit_y = cy;
  a = b608_vgroove_small_r;

  pl = 5.5;
  ybit = -cy+5+bit_y/2;
  ybit_hole = ybit + 21;
  module bit(){
    rotate([0,0,90])
      translate([-Bit_width/2, -bit_y/2, 0])
      difference(){
        one_rounded_cube2([Bit_width+4,bit_y,Base_th], 5.5, $fn=28);
      }
  }

  module the_bearing(bigger=false){
    translate([ 0, 0, bz ])
      rotate([ rotx, 0, rotz ])
        translate([-a*cos(rotx)*sin(rotz),-a, 0]){
        color("yellow")
          if(bigger){
            scale(1.02)
            b608_vgroove();
          }else{
            b608_vgroove();
          }
        }
  }

  mirror([1,0,0]) {
    if(!twod){
      extra_b_height = 0.9; // half of this above, half below
      extra_b_width = 3*b608_vgroove_room_to_grow_r; // half of this to the left of bearing
      full_h = bz+8-b608_vgroove_big_r*sin(rotx);
      take_away_angle = 90;

      // something to aim for
      //%the_bearing();
      //translate([move_along_line*cos(-rotz),Horizontal_deflector_cube_y_size-move_along_line*sin(-rotz),0])
      //%the_bearing();
      difference(){
        translate([0,-4.85,0])
        union(){
          translate([-cx/2+thicken_along_line*cos(-rotz), (-cy+8)+Horizontal_deflector_cube_y_size-thicken_along_line*sin(-rotz), 0])
            ydir_rounded_cube2([cx-thicken_along_line*cos(-rotz), cy, full_h], r=3, $fn=12*2);
          for(k=[0,1])
            mirror([k,0,0]){
              difference(){
                union(){
                  translate([cx/2-k*thicken_along_line*cos(-rotz),(-cy+8)+Horizontal_deflector_cube_y_size-thicken_along_line*sin(-rotz),Base_th])
                    rotate([0,-90,-90])
                    inner_round_corner(r=2, h=cy, $fn=4*5, back=Base_th-0.1);
                  translate([cx/2+pl-k*thicken_along_line*cos(-rotz),ybit+3+Horizontal_deflector_cube_y_size-thicken_along_line*sin(-rotz),0])
                    rotate([0,0,90])
                    bit();
                }
                translate([cx/2-k*thicken_along_line*cos(-rotz),8+Horizontal_deflector_cube_y_size-thicken_along_line*sin(-rotz),Base_th])
                  corner_rounder();
                translate([cx/2+pl-k*thicken_along_line*cos(-rotz),ybit_hole,0.6])
                  Mounting_screw();
                translate([cx/2+pl-k*thicken_along_line*cos(-rotz),ybit_hole+Horizontal_deflector_cube_y_size-thicken_along_line*sin(-rotz),0.6])
                  Mounting_screw();
              }
            }
        }

        for (tr = [[0, 0], [move_along_line*cos(-rotz), Horizontal_deflector_cube_y_size-move_along_line*sin(-rotz)]]){
          translate(tr) {
            translate([0,0,bz]){
              rotate([ rotx, 0, rotz ]){
                translate([-a*cos(rotx)*sin(rotz),-a, 0]){
                  translate([0,-2, 0])
                    rotate([0,0,-rotz*cos(rotx)])
                      scale([(b608_vgroove_big_r+extra_b_width/2)/b608_vgroove_big_r,
                          (b608_vgroove_big_r+extra_b_width/2)/b608_vgroove_big_r,
                          1]){
                        elong_b608_ugroove(20, extra_b_height);
                      }
                  translate([0, 0,-1-bz]){
                    M8_screw(h=100, center=true);
                    translate([0,0,-32])
                      scale([1.01,1.01,1])
                      if (tr[0] != 0) {
                        M8_nut(h=bz+1-b608_width/2-extra_b_height/2 + 23);
                      } else {
                        M8_nut(h=bz+1-b608_width/2-extra_b_height/2 + 30);
                      }
                    translate([0,0,full_h - 9.9 + 3*sin(rotx)]){
                      cylinder(d1=8.3, d2=14.2, h=4.5, $fn=12*2);
                      translate([0,0,4.49])
                        cylinder(d=14.2, h=21, $fn=12*2);
                    }
                  }
                  rotate([0,0,11])
                  translate([-b608_vgroove_small_r-1.5, 0,0])
                    rotate([90,0,rotz/2])
                      translate([-2.6,0,-8]){
                        translate([0,0,-4])
                        cylinder(d=8, h=26);
                        difference(){
                          scale([1.0,0.8,1]){
                            cylinder(d1=4.8, d2=31.5, h=26);
                          }
                          translate([14,10.98,7])
                            rotate([90,0,0])
                              cylinder(d=b608_vgroove_big_r*4, h=7);
                          translate([14,-3,7])
                            rotate([90,0,0])
                              cylinder(d=b608_vgroove_big_r*2, h=7);
                        }
                      }
                  translate([0, b608_vgroove_small_r,0])
                    rotate([90,0,90])
                      translate([0,0,2])
                      difference(){
                        cylinder(d1=2, d2=2.1*(Spool_height+0.5), h=2*16);
                        rotate([0,0,-rotx-90])
                        translate([7.8, -25, 0])
                          cube(50);
                      }
                }
              }
            }
          }
        }
        translate([0,-4.85,0])
          rotate([0,0,180-30])
            translate([-6, 20, -1])
              cube([50, 50, 50]);
      }

      for (tr = [[0, 0], [move_along_line*cos(-rotz), Horizontal_deflector_cube_y_size-move_along_line*sin(-rotz)]]){
        translate(tr) {
          shoulder_height = 0.5;
          for(hl=[-(b608_width+extra_b_height)/2-1+shoulder_height,
              (b608_width+extra_b_height)/2 - shoulder_height])
            translate([0, 0, bz])
              rotate([ rotx, 0, rotz ])
                translate([-a*cos(rotx)*sin(rotz),-a, 0])
                  translate([0, 0,hl])
                    difference(){
                      cylinder(d=8+3, h=1, $fn=2*12);
                        translate([0,0,-1])
                          cylinder(d=8.3, h=4, $fn=2*12); // The ring to rest b608_vgroove bore on
                    }
        }
      }

    } else { //twod
      translate([0,-4.85])
        difference(){
          translate([-cx/2+thicken_along_line*cos(-rotz)-Bit_width+0.5, (-cy+8)+Horizontal_deflector_cube_y_size-thicken_along_line*sin(-rotz)])
            ydir_rounded_cube2_2d([cx-thicken_along_line*cos(-rotz)+2*Bit_width-1, cy], r=5.5, $fn=12*2);
          for(k=[0,1])
            mirror([k,0]){
              translate([cx/2+pl-k*thicken_along_line*cos(-rotz),ybit_hole])
                Mounting_screw(twod=true);
              translate([cx/2+pl-k*thicken_along_line*cos(-rotz),ybit_hole+Horizontal_deflector_cube_y_size-thicken_along_line*sin(-rotz)])
                Mounting_screw(twod=true);
            }
          rotate([0,0,180-30])
            translate([-6, 20])
            square([50, 50]);
        }
    }
  }
}
//%import("../stl/tilted_line_deflector.stl");
