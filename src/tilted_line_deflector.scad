include <lib/parameters.scad>
use <lib/util.scad>


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

tilted_line_deflector(rotx=-atan(sqrt(2)), rotz=-30); // Angle atan(sqrt(2)) works if ABCD anchors form like sided tetrahedron
//tilted_line_deflector(rotz=-30, rotx=-10, bullet_shootout=true);
module tilted_line_deflector(twod=false, rotx=0, rotz=0, bullet_shootout=true){
  cx = b608_vgroove_big_r*2 + 8;
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
        one_rounded_cube2([Bit_width+4,bit_y,Base_th], 5.5, $fn=28);
      }
  }

  mirror([1,0,0]) {
    if(!twod){
      extra_b_height = 0.8; // half of this above, half below
      extra_b_width = 3*b608_vgroove_room_to_grow_r; // half of this to the left of bearing
      full_h = bz+8-b608_vgroove_big_r*sin(rotx);
      take_away_angle = 90;

      // something to aim for
      a = b608_vgroove_small_r;
      //%translate([ 0, 0, bz ])
      //  rotate([ rotx, 0, rotz ])
      //    translate([-a*cos(rotx)*sin(rotz),-a, 0]){
      //    color("yellow")
      //      b608_vgroove();
      //    }
      difference(){
        translate([0,-4.85,0])
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
          rotate([ rotx, 0, rotz ])
            translate([-a*cos(rotx)*sin(rotz),-a-2, 0])
              rotate([0,0,-rotz*cos(rotx)])
                scale([(b608_vgroove_big_r+extra_b_width/2)/b608_vgroove_big_r,
                    (b608_vgroove_big_r+extra_b_width/2)/b608_vgroove_big_r,
                    1]){
                  elong_b608_vgroove(20, extra_b_height);
                }
        }
        translate([0,0,bz])
          rotate([ rotx, 0, rotz ])
            translate([-a*cos(rotx)*sin(rotz),-a, 0])
              translate([0, 0,-1-bz]){
                M8_screw(h=100, center=true);
                translate([0,0,-10])
                  M8_nut(h=bz+1-b608_width/2-extra_b_height/2 + 8);
                translate([0,0,full_h - 8.5 + 3*sin(rotx)]){
                  cylinder(d1=8.3, d2=14, h=4.5, $fn=12*2);
                  translate([0,0,4.49])
                    cylinder(d=14, h=10);
                }
              }
        sly = 40;
        q = a-1;
        if (!bullet_shootout){
          for(k=[0,1]) mirror([k*cos(rotz),k*sin(rotz),0])
            translate([q*cos(rotz),q*sin(rotz),bz])
              hull(){
                for(rotx_fac = [-0.05,0,0.05])
                  rotate([ rotx + rotx_fac*rotx, 0, rotz ])
                    translate([k == 0 ? -q/2*sin(rotx) : q/2*sin(rotx),-sly+1,-2.5/2])
                      cube([100,sly, 2.5]);
              }
        }
        if(bullet_shootout){
          translate([ 0, 0, bz ])
            rotate([ rotx, 0, rotz ])
              translate([-a*cos(rotx+0)*sin(rotz),-a, 0]) {
                rotate([0,0,11])
                translate([-b608_vgroove_small_r-1.5, 0,0])
                  rotate([90,0,rotz/2])
                    translate([-0.4,0,-2])
                    scale([1.0,0.8,1]){
                      cylinder(d1=0.3, d2=27.5, h=21);
                      rotate([0,8,0])
                        cylinder(d1=0.3, d2=27.5, h=21);
                    }
                translate([0, b608_vgroove_small_r,0])
                  rotate([90,0,90])
                    translate([0,0,2])
                    cylinder(d1=2, d2=Spool_height+0.5, h=17);
              }
        }
      }

      shoulder_height = 0.7;
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

    } else { //twod
      difference(){
        translate([-cx/2-Bit_width+0.5, -cy+5])
          ydir_rounded_cube2_2d([cx+2*Bit_width-1, cy], 5.5, $fn=28);
        for(k=[0,1])
          mirror([k,0])
            translate([cx/2+pl,ybit_hole])
              Mounting_screw(twod=true);
      }
    }
  }
}

