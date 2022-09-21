include <parameters.scad>
use <util.scad>
use <spool_core.scad>

base_ywidth = 84;

module belt_adj_nut_locks(){
  hull(){
    translate([Belt_roller_top_adj_screw_x, Belt_roller_top_adj_screw_y+0.3, Belt_roller_h-33])
      rotate([0,0,30])
      nut(4);
    translate([Belt_roller_top_adj_screw_x, -Belt_roller_top_adj_screw_y-0.3, Belt_roller_h-33])
      rotate([0,0,30])
      nut(4);
  }
}

//rotate([0,90,0])
//  belt_roller(false);
module belt_roller(twod = true){
  wing=7;
  flerp=15;
  if(!twod){
    difference(){
      union(){
        // tower
        difference(){
          union(){
            for(k=[0,1]) mirror([0,k,0])
              roller_wall(Belt_roller_space_between_walls-0.7, Belt_roller_wall_th+0.4, Belt_roller_h - 2, rot_nut=30, bearing_screw=false);
            translate([-Depth_of_roller_base/2,-Belt_roller_space_between_walls/2,0])
              cube([Depth_of_roller_base, Belt_roller_space_between_walls+2, Belt_roller_h-43]);
            translate([-(Depth_of_roller_base)/2, Belt_roller_space_between_walls/2+Belt_roller_wall_th, Base_th])
              rotate([0,90,0])
                rotate([0,0,90])
                  inner_round_corner(h=Depth_of_roller_base, r=2, back=2, $fn=5*4);
            translate([-Depth_of_roller_base/2, (Belt_roller_space_between_walls+2*Belt_roller_wall_th)/2, Base_th])
              rotate([90,0,0])
                rotate([0,0,90])
                  inner_round_corner(h=Belt_roller_space_between_walls+2*Belt_roller_wall_th+7, r=2, $fn=5*4);

            for(k=[0,1]) mirror([0,k,0])
              translate([-Depth_of_roller_base/2, Belt_roller_space_between_walls/2+Belt_roller_wall_th,0])
                rotate([0,0,90])
                  inner_round_corner(h=Base_th+2*(1-k), r=2, back=2, $fn=5*4);

            for(k=[0,1]) mirror([0,k,0]) {
              hull(){
                translate([0,Belt_roller_space_between_walls/2 + 0.5, Belt_roller_h - Depth_of_roller_base/2])
                  rotate([-90,0,0]){
                    translate([0,0,1+Belt_roller_wall_th - min(Belt_roller_wall_th/2, 2)])
                      rotate([0,0,30])
                        cylinder(d=7/cos(30), 1.5, $fn=6);
                  }
                translate([0,Belt_roller_space_between_walls/2 + 0.5, Belt_roller_h - Depth_of_roller_base/2-8])
                  rotate([-90,0,0]){
                    translate([0,0,1+Belt_roller_wall_th - min(Belt_roller_wall_th/2, 2)])
                      rotate([0,0,30])
                        cylinder(d=7/cos(30), 1.5, $fn=6);
                }
              }
            }
          }
          translate([-Depth_of_roller_base/2, -(Belt_roller_space_between_walls+2*Belt_roller_wall_th)/2-5, Base_th])
            rotate([0,0,180])
              corner_rounder(r1=2, r2=2, angle=90);
          opening_ang = 12;
          opening_len = 11;
          for(k=[0,1]) mirror([0, k,0])
            translate([-Depth_of_roller_base/2, -(Belt_roller_space_between_walls-0.7)/2-opening_len*sin(opening_ang), Belt_roller_h-43])
              rotate([0,0,opening_ang])
                cube([opening_len, 3, Belt_roller_h]);

          mirror([1,0,0])
            translate([Depth_of_roller_base/2, -(Belt_roller_space_between_walls/2+Belt_roller_wall_th)-0.05,Base_th+2+25])
              rotate([0,0,90])
                inner_round_corner(r=2, h=Belt_roller_h+2,$fn=4*4);
          mirror([0,1,0])
            translate([Depth_of_roller_base/2, -(Belt_roller_space_between_walls/2+Belt_roller_wall_th)-0.05,Base_th+2])
              rotate([0,0,90])
                inner_round_corner(r=2, h=Belt_roller_h+2,$fn=4*4);
          translate([0,0,-9])
            scale([1,(Belt_roller_containing_cube_ywidth+0.1)/Belt_roller_containing_cube_ywidth, 1])
              belt_roller_containing_cube();

          belt_adj_nut_locks();

          for(k=[0,1]) {
            mirror([0,k,0]) {
              translate([-7, -Belt_roller_containing_cube_ywidth/2, Belt_roller_h-27])
                rotate([0,0,40])
                  cube([4, 6, Belt_roller_h]);
            }
          }

          for(k=[0,1]) mirror([0,k,0]) {
            hull(){
              translate([0,Belt_roller_space_between_walls/2 + 0.5, Belt_roller_h - Depth_of_roller_base/2])
                rotate([-90,0,0]){
                  translate([0,0,1+Belt_roller_wall_th - min(Belt_roller_wall_th/2, 2)])
                    rotate([0,0,30])
                      nut(h=8);
                }
              translate([0,Belt_roller_space_between_walls/2 + 0.5, Belt_roller_h - Depth_of_roller_base/2-8])
                rotate([-90,0,0]){
                  translate([0,0,1+Belt_roller_wall_th - min(Belt_roller_wall_th/2, 2)])
                    rotate([0,0,30])
                      nut(h=8);
              }
            }
            hull() {
              translate([0,Belt_roller_space_between_walls/2 - 1, Belt_roller_h - Depth_of_roller_base/2])
                rotate([-90,0,0])
                  cylinder(d=3.4, h=Belt_roller_wall_th + 2, $fn=12);
              translate([0,Belt_roller_space_between_walls/2 - 1, Belt_roller_h - Depth_of_roller_base/2-8])
                rotate([-90,0,0])
                  cylinder(d=3.4, h=Belt_roller_wall_th + 2, $fn=12);
            }
          }
        }
      }
      translate([Belt_roller_top_adj_screw_x, Belt_roller_top_adj_screw_y, Belt_roller_h-27])
        cylinder(d=M3_screw_head_d+0.1, h=Belt_roller_h, $fn=13);
      translate([Belt_roller_top_adj_screw_x, -Belt_roller_top_adj_screw_y, Belt_roller_h-27])
        cylinder(d=M3_screw_head_d+0.1, h=Belt_roller_h, $fn=13);
      translate([Belt_roller_top_adj_screw_x, Belt_roller_top_adj_screw_y,-5])
        M3_screw(h=Belt_roller_h);
      translate([Belt_roller_top_adj_screw_x, -Belt_roller_top_adj_screw_y,-5])
        M3_screw(h=Belt_roller_h);

      translate([-Depth_of_roller_base/2, Belt_roller_space_between_walls/2+Belt_roller_wall_th, Base_th])
        rotate([0,0,89.9])
          corner_rounder(r1=2, r2=2, sq=[10,Belt_roller_h], angle=90.2);
      mirror([1,0,0])
        translate([-Depth_of_roller_base/2+2, Belt_roller_space_between_walls/2+Belt_roller_wall_th-2, Base_th+2])
          rotate([0,0,89])
            rotate_extrude(angle=92, $fn=4*4)
              translate([4,0])
                circle(r=2, $fn=4*5);
    }
  } else {
    difference(){
      union(){
        translate([-Depth_of_roller_base/2, 0,0])
          ydir_rounded_cube2_2d([Depth_of_roller_base, Belt_roller_space_between_walls/2+Belt_roller_wall_th+flerp], r=3, $fn=4*5);
        translate([-(Depth_of_roller_base/2+flerp), -(Belt_roller_space_between_walls+2*Belt_roller_wall_th)/2,0])
          left_rounded_cube2_2d([Depth_of_roller_base+flerp, Belt_roller_space_between_walls+2*Belt_roller_wall_th], r=3, $fn=4*5);
      }
      translate([0,Belt_roller_space_between_walls/2+Belt_roller_wall_th+flerp/2])
        Mounting_screw(twod=twod);
      translate([-Depth_of_roller_base/2-flerp/2,0])
        Mounting_screw(twod=twod);
    }
  }
}



module screw_placeout(){
  for(ang=[0:90:359])
    rotate([0,0,ang+45])
      translate([29.8/2,0,0])
        children();
}

//stationary_part();
module stationary_part(){
  difference(){
    cylinder(d=63, h=7, $fn=12*4);
    screw_placeout()
      translate([0,0,-1])
        cylinder(d=3, h=10);

  }
}

module shaft(){
  translate([0,0,-20.2])
    cylinder(d=5, h=20.2 + 42);
}

module rotating_part(){
  difference() {
    translate([0,0,7.1])
      cylinder(d=60.8, h=28.7-7.1, $fn=100);
    translate([0,0,32]){
      rotate_extrude() {
        translate([22,0])
          rotate([0,0,-12])
            square([20, 10], center=true);
      }
    }
  }
}

//whitelabel_motor();
module whitelabel_motor(){
  color([0.4,0.4,1.0]) stationary_part();
  color("grey") shaft();
  color([0.6,0.6,1.0]) rotating_part();
}

//encoder();
module encoder(){
  difference(){
    union(){
      translate([-(33.8-27.6),-28.5/2,0])
      cube([34, 28.5, 8.9]);
      intersection(){
        cylinder(r=43.13-27.6, h=8.9,$fn=100);
        translate([-50,-28.5/2,-1])
          cube([100, 28.5, 10]);
      }
    }
  translate([0,0,-1])
    cylinder(d=13, h=10);
  }

  for(k=[0,1]){
    mirror([0,k,0]){
      difference(){
        hull(){
          translate([0,-52.4/2+3,0])
            cylinder(d=6, h=2.4, $fn=20);
          translate([-(33.8-27.6), -28.5/2, 0])
            cube([2*(33.8-27.6), 1, 2.4]);
        }
        translate([0,-45.5/2,-1])
          cylinder(d=3, h=5, $fn=10);
        translate([0,-32.5/2,-1])
          cylinder(d=3, h=5, $fn=10);
        translate([0,-32.5/2,0.5])
          cylinder(d=5, h=5, $fn=12);
      }
    }
  }
}


module erasor_cubes(cubesize_x, yextra) {
  translate([-51,-20,-1])
    cube([30,40,50]);
  translate([-15-Belt_roller_h+41.5, -cubesize_x-5.5,-1])
    rotate([0,0,61])
      cube([50,50,50]);

  mirror([0,1,0]){
    translate([-15-Belt_roller_h+4.630, -cubesize_x-1,-1])
      rotate([0,0,0])
        cube([50,50,50]);
    translate([-15-Belt_roller_h+21, -cubesize_x-1,-47.5])
      rotate([0,0,0])
        cube([50,50,50]);
  }
  for(k=[0,1]) mirror([0,k,0]) {
    translate([-15-Belt_roller_h+27, -cubesize_x-11.5,-1])
      cube([50,50,50]);
    translate([4,-cubesize_x/2-k*yextra,0])
      rotate([0,90,0])
        rotate([0,0,90])
          inner_round_corner(r=2, h=27, $fn=24);
    translate([31,-cubesize_x/2-k*yextra+2,2])
      rotate([0,90,0])
        rotate([0,0,-90])
          rotate_extrude(angle=90, $fn=24) translate([4,0]) circle(r=2, $fn=24);
  }
  translate([5,-cubesize_x/2,8])
    rotate([0,90,0])
      rotate([0,0,0])
        inner_round_corner(r=2, h=26, $fn=24);
  translate([31,-cubesize_x/2+2,6])
    rotate([0,90,0])
      rotate([0,0,180])
        rotate_extrude(angle=90, $fn=24) translate([4,0]) circle(r=2, $fn=24);

}

//!whitelabel_motor_render();
module whitelabel_motor_render(){
  rotate([0,-90,0])
    whitelabel_motor();
  translate([-33.7,0,0])
    rotate([90,0,-90])
      encoder();
}


//translate([-2.5,0,0])
//rotate([0,90,0])
//!motor_bracket(true);
module motor_bracket(leftHanded=false){
  cubesize_x = 60.8+6;
  yextra=8.6;
  cubesize_y = cubesize_x+yextra;

  translate([-16.4,24,8])
    rotate([0,90,0])
      rotate([0,0,2*90])
        inner_round_corner(r=3, h=51.4, $fn=4*5);
  difference(){
    difference(){
      translate([-cubesize_x/2,-cubesize_x/2,0])
        cube([cubesize_x, cubesize_y,8]);
      difference(){
        translate([0,0,-1])
          cylinder(d=60.8-3,h=50, $fn=100);
        difference(){
          union(){
            translate([7,-30,0])
              cube(60);
            for(k=[0,1]) {
              mirror([0,k,0]) {
                translate([-13,-4-29.6/(2*sqrt(2)),0])
                  cube([cubesize_x-2, 8, 20]);
              }
            }

            mirror([0,1,0])
              translate([-8.0,19.5,2.5])
                rotate([0,0,-56.5])
                  translate([0.2,-7,0])
                    cube([18,29,5.5]);
            translate([-8.0,19.5,2.5])
              translate([-8.37,-9,0])
                cube([28,18,5.5]);
            screw_placeout()
              translate([0,0,2.5])
                cylinder(d=M3_screw_head_d+6, h=11,$fn=20);
          }
          cylinder(d=GT2_motor_gear_outer_dia+2.5, h=52, $fn=100);
        }
      }
      if (leftHanded) {
        rotate([0,0,180])
          mirror([1,0,0])
            translate([0,0,-7+2.5])
              stationary_part();
      } else {
        mirror([1,0,0])
          translate([0,0,-7+2.5])
            stationary_part();
      }
      translate([0,0,-7+2.5])
        cylinder(d=55, h=7);


      erasor_cubes(cubesize_x, yextra);

      // Remove overhang for ease of printing upright
      if (leftHanded) {
        translate([7.075,-29.720,-0.5])
          rotate([0,0,38])
            cube(3);
        translate([8.555,29.285,-0.5])
          rotate([0,0,-19])
            translate([-3, -3, 0])
              cube(3);
      } else {
        translate([8.555,29.285,-0.5])
          rotate([0,0,38])
            translate([-3, -3, 0])
              cube(3);
      }


      // Screw holes
      screw_placeout() {
        translate([0,0,-1])
          cylinder(d=3.44, h=10, $fn=8);
        translate([0,0,2.5+3])
          cylinder(d=M3_screw_head_d, h=10,$fn=20);
      }
    }
    translate([-37,27.7,9.6])
      rotate([0,90,0])
        cylinder(d=7, h=150, $fn=4*3);
  }
  difference(){
    union(){
      difference(){
        translate([33,0,0])
          rotate([0,180,0])
            rotate([90,0,0])
              translate([0,0,-(cubesize_y+13)/2])
                inner_round_corner(r=2, h=cubesize_y+10, $fn=10*4);
        mirror([0,1,0])
          translate([0,24.4,9])
            rotate([45,0,0])
              translate([0,0,-50])
                cube(50);
        translate([0,42,9])
          translate([0,0,-50])
            cube(50);
      }

      mirror([0,1,0])
        intersection() {
        translate([ 33, cubesize_x / 2, -3 ])
          rotate([ 0, 0, 90 ])
           inner_round_corner(r=2, h=11, ang=90, $fn=10*4);
        translate([0,24.4,9])
          rotate([45,0,0])
            translate([0,0,-50])
              cube(50);
        }
    }
    for(k=[0,1]) mirror([0,k,0])
      translate([31,-cubesize_x/2-k*yextra+2,2])
        rotate([0,90,0])
          rotate([0,0,-90])
            rotate_extrude(angle=90, $fn=24) translate([4,0]) circle(r=2, $fn=24);

    translate([31,-cubesize_x/2+2,6])
      rotate([0,90,0])
        rotate([0,0,180])
          rotate_extrude(angle=90, $fn=24) translate([4,0]) circle(r=2, $fn=24);
  }
}


// encoder_stabilizer();
module encoder_stabilizer() {
  xdim = 10;
  ydim = 8.9+4.5*2;
  zdim = 60;
  translate([0,16,-34])
  translate([ydim, 0, 0])
    rotate([0,0,90]){
      union(){
        difference(){
          top_rounded_cube2([xdim,ydim,zdim], 3, $fn=5*4);
          translate([-15+xdim/2,4.5,11])
            rounded_cube([30, 8.90, 57], 3, $fn=5*4);
        }
        translate([xdim/2, ydim/2, 1]){
          for(k=[0, 1]) mirror([0,k,0])
            difference(){
              translate([-xdim/2-8/2,ydim/2-0.01,0])
                rotate([90,0,90])
                  inner_round_corner(r=2, h=xdim+8, $fn=10*4, ang=90, center=false);
              for(l=[0,1]) mirror([l,0,0])
                rotate([0,0,45])
                  translate([-25,2.80,-1])
                    mirror([0,1,0])
                      cube(50);
            }
          for(k=[0, 1]) mirror([k,0,0])
            difference(){
              translate([xdim/2,ydim/2+8/2,0])
                rotate([90,0,0])
                  inner_round_corner(r=2, h=ydim+8, $fn=10*4, ang=90, center=false);
              for(l=[0,1]) mirror([0,l,0])
                rotate([0,0,45])
                  translate([-25,2.80,-1])
                    cube(50);
            }
        }
      }
  }
  //translate([4.5,0,0])
  //  rotate([90,0,90])
  //    encoder();

}

// encoder_bracket();
module encoder_bracket() {
  difference() {
    rotate([0,90,0]) {
      difference(){
        union(){
          translate([16,-20/2,-2.5])
            difference(){
              left_rounded_cube2([18, 20, 7+4], 3, $fn=5*4);
              translate([-1,-1,4])
                rotate([0,11,0])
                  translate([0,0,-50])
                    cube(50);
              translate([-1,-1,4.8])
                rotate([0,-11,0])
                  translate([0,0,2])
                    cube(50);
              translate([-0.1,3,7])
              hull(){
                cube([0.1, 20-2*3, 4]);
                translate([13, (20-2*3)/2, 0])
                  cylinder(d=4.5, h=4, $fn=5*4);
              }

            }
          intersection(){
            translate([33,0,0])
              rotate([90,-180,0])
                translate([0,1.66,-25/2])
                  inner_round_corner(r=2, h=25, $fn=10*4, ang=90-11, center=false);
            translate([0,0,-50*sqrt(2)+8.4])
              rotate([45,0,0])
                cube(50);
          }
          intersection(){
            translate([33,0,0])
              rotate([-90,180,0])
                translate([0,7.5,-25/2])
                  inner_round_corner(r=2, h=25, $fn=10*4, ang=90-11, center=false);
            translate([0,0,-2.5])
              rotate([45,0,0])
                cube(50);
          }

          difference(){
            for(k=[0,1])
              mirror([0,k,0])
                translate([33,20/2,0])
                    rotate([0,0,90])
                    translate([0,0,-6.5])
                      inner_round_corner(r=2, h=9+7, $fn=10*4, center=false);
            translate([0,0,-50*sqrt(2)+8.4])
              rotate([45,0,0])
                cube(50);
            translate([0,0,-2.5])
              rotate([45,0,0])
                cube(50);
          }
        }
      }
    }
    translate([0.1,0,0])
      rotate([90,0,-90]) {
        translate([0,-45.5/2,-5])
          hull(){
            translate([0,3,0])
              M3_screw(h=16);
            translate([0,-1,0])
              M3_screw(h=16);
          }
        translate([0,-45.5/2,-0.4-2])
          hull(){
            translate([0,3,0])
              rotate([0,0,30])
                M3_nut(h=5);
            translate([0,-1,0])
              rotate([0,0,30])
                M3_nut(h=5);
          }
    }
  }
}


motor_bracket_xpos = -46.5;
motor_bracket_ypos = -33;

// Four different brackets are needed
// All combinations of the two options
// |      leftHanded |     mirrored | C
// |      leftHanded | not mirrored | B
// |  not leftHanded |     mirrored | A
// |  not leftHanded | not mirrored | D
// It's recommended to use the named files
// motor_bracket_A.scad
// motor_bracket_B.scad
// motor_bracket_C.scad
// motor_bracket_D.scad
// or some kind of build system when compiling
// those stls. Doing it by hand easily leads to mistakes.

module base_hull_2d(isD = false){
  $fn=4*6;
  pos0 = [73.5,53,0];
  pos0D = [73.5 + (Sandwich_D_width - Sandwich_ABC_width) - (Spool_height+1),53,0];
  pos1 = [32-1.5-15+3,53,0];
  pos1D = pos1 - [Spool_height+1, 0, 0];
  pos2 = [-16,0,0];
  pos2p5 = [-16,-32,0];
  pos3 = [36-1.5,53,0];
  pos4 = [36-1.5,-38,0];
  pos5 = [36-1.5-15+3,-38,0];
  pos6 = [68.5,40,0];
  pos7 = [36,40,0];
  pos8 = [69.5,27,0];
  pos9 = [36,28,0];
  pos10 = [36,40,0];
  hull(){
    translate(pos6)
      circle(r=4);
    translate(pos8)
      circle(r=3);
    translate(pos9)
      circle(r=4);
    translate(pos10)
      circle(r=4);
  }
  hull(){
    if (isD)
      translate(pos0D)
        circle(r=4, $fn=40);
    else
      translate(pos0)
        circle(r=4);
    translate(pos6)
      circle(r=4);
    translate(pos7)
      circle(r=4);
    if (isD)
      translate(pos1D)
        circle(r=4, $fn=40);
    else
      translate(pos1)
        circle(r=4);
  }
  hull(){
    translate(pos2)
      circle(r=4);
    translate(pos2p5)
      circle(r=4);
    translate(pos3)
      circle(r=4);
    if (isD)
      translate(pos1D)
        circle(r=4, $fn=40);
    else
      translate(pos1)
        circle(r=4);
    translate(pos4)
      circle(r=4);
    translate(pos5)
      circle(r=4);
  }
}

//spool_legs();
module spool_legs(isD = false, twod=false){
  translate([0,Belt_roller_bearing_xpos,0])
    rotate([0,0,90])
      if (isD) {
        translate([0,-(Sandwich_D_width - Sandwich_ABC_width)/2+Spool_height+1, 0])
          spool_cores(twod=twod, between=Sandwich_D_width + 2*Spool_core_cover_adj);
      } else {
        spool_cores(twod=twod, between=Sandwich_ABC_width + 2*Spool_core_cover_adj);
      }

  translate([-(Sandwich_ABC_width +2*Spool_core_cover_adj+6)/2,154.35,0])
    if (isD) {
      if (twod){
        translate([-Spool_height-1,0,0])
          square([Sandwich_D_width + 2*Spool_core_cover_adj+6, 2]);
      } else {
        translate([-Spool_height-1,0,0])
          cube([Sandwich_D_width + 2*Spool_core_cover_adj+6, 2, Base_th]);
      }
    } else {
      if (twod) {
        square([Sandwich_ABC_width + 2*Spool_core_cover_adj+6, 2]);
      } else {
        cube([Sandwich_ABC_width + 2*Spool_core_cover_adj+6, 2, Base_th]);
      }
    }
}

//mirror([1,0,0])
  motor_bracket_extreme(leftHanded=false, twod=false);
module motor_bracket_extreme(leftHanded=false, twod=false, text="A") {
  module placed_text(){
    translate([13,5,0])
      rotate([0,0,-90])
        // Poor man's stencil font
        difference(){
          text(text);
          translate([4.2,0])
            square([0.9, 20]);
        }
  }

  translate([motor_bracket_xpos, motor_bracket_ypos, 0]) {
    if(!twod) {
      difference(){
        union(){
          linear_extrude(height=Base_th) base_hull_2d(text == "D");
          translate([36-1.5, 36, 0])
            cube([6, 6, Base_th]);
          translate([0,0,35]){
            translate([-2.5+33,0,0])
              rotate([0,90,0])
                motor_bracket(leftHanded);
            %translate([33,0,0])
              if(leftHanded)
                rotate([180,0,0])
                  import("../../stl/for_render/whitelabel_motor.stl");
              else
                import("../../stl/for_render/whitelabel_motor.stl");
            translate([4.5-0.7,0,0])
              rotate([0,0,2*90]){
                translate([11.45,0,0])
                  mirror([1,0,0])
                    encoder_bracket();
                    encoder_stabilizer();
              }
          }
        }
        translate([-15,0,0.5])
          Mounting_screw();
        translate([-15,-32,0.5])
          Mounting_screw();

        flerp=15;
        translate([-motor_bracket_xpos, -motor_bracket_ypos, 0])
        rotate([0,0,-90])
        translate([0,Belt_roller_space_between_walls/2+Belt_roller_wall_th+flerp/2,0.5])
          Mounting_screw();
        translate([36-1.5-15+3,38,0.5])
          Mounting_screw();
        translate([36-1.5,-38,0.3])
          Mounting_screw();
        translate([36-1.5-15+3,-38,0.5])
          Mounting_screw();
        translate([0,0,-1])
          linear_extrude(height=Base_th+3, convexity=8)
            placed_text();
        translate([-motor_bracket_xpos, -motor_bracket_ypos, 0])
          rotate([0,0,-90])
            belt_adj_nut_locks();

      }
    } else {
      // twod below here
      difference(){
        base_hull_2d(text=="D");
        translate([-15,0,0])
          Mounting_screw(twod=twod); // use motor_bracket_extreme(..., twod=true) to see this one
        translate([-15,-32,0])
          Mounting_screw(twod=twod);

        flerp=15;
        translate([-motor_bracket_xpos, -motor_bracket_ypos, 0])
        rotate([0,0,-90])
        translate([0,Belt_roller_space_between_walls/2+Belt_roller_wall_th+flerp/2,0])
          Mounting_screw(twod=twod);
        translate([36-1.5-15+3,38,0])
          Mounting_screw(twod=twod);
        translate([36-1.5,-38,0])
          Mounting_screw(twod=twod);
        translate([36-1.5-15+3,-38,0])
          Mounting_screw(twod=twod);
        placed_text();
      }
    }
  }

  rotate([0,0,-90])
    belt_roller(twod=twod);
  spool_legs(text == "D", twod=twod);
}
