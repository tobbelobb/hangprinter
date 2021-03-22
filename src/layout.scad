include <parameters.scad>
use <spool.scad>
use <dleft_spool.scad>
use <sep_disc.scad>
use <GT2_spool_gear.scad>
use <spool_core.scad>
use <line_roller_anchor.scad>
use <line_roller_double.scad>
use <line_verticalizer.scad>
use <horizontal_line_deflector.scad>
use <corner_clamp.scad>
use <beam_slider_D.scad>
use <util.scad>
use <donkey_bracket.scad>
use <belt_roller.scad>
use <landing_bracket.scad>
use <geodesic_sphere.scad>


beam_length = 400;

// Viewing STLs is faster when just looking at the model
// Non-stls are faster for previews when changing design
stls = true;
//stls = false;

// Viewing 2d
//twod = true;
twod = false;

mounted_in_ceiling = true;
//mounted_in_ceiling = false;

// Render the mover
mover = true;
//mover = false;

bottom_triangle = false;
//bottom_triangle = true;

ANCHOR_D_Z = 2300;
ANCHOR_A_Y = 2000;
between_action_points_z = ANCHOR_D_Z-Higher_bearing_z -3 - 175;
lift_mover_z = 200;
//lift_mover_z = ANCHOR_D_Z-300;

dspool_y = -50;
abcspool_y = -50;
abc_sep = 104;
move_BC_deflectors = -100;

extra_space_in_middle = 10;

lx0 = -abc_sep/2-extra_space_in_middle-spd/2;
lx1 = -abc_sep/2-extra_space_in_middle+spd/2;
lx2 = -abc_sep/2-extra_space_in_middle+spd/2 + 1 + Spool_height;
lx3 = abc_sep/2+extra_space_in_middle-spd/2;
ly2 = Sidelength/sqrt(12) - 40;

color0 = "sandybrown";
color0_alpha = 0.55;
color1 = [0.81,0.73,0.05];
color1_alpha = 0.9;
color2 = [0.99,0.99,0.99];
color2_alpha = 0.8;

color_carbon = [0.2,0.2,0.2];

// Sometimes, Nema17_cube_width will have another value,
// so that a different motor can fit
_motor_ang = ((Nema17_cube_width-42.43)/(sqrt(2)*Spool_outer_radius))*(180/PI);

//top_plate();
module top_plate(cx, cy, mvy){
  if(!twod){
    color(color0, color0_alpha)
      translate([-cx/2,mvy,-12])
      cube([cx, cy, 12]); // Top plate
  }
}

//ldef(9,false);
module ldef(rot_around_center=0, center=false){
  module ldef_always_center(){
      rotate([0,0,rot_around_center]) // Rotate around bearing center
      translate([0,b623_vgroove_small_r,0])
      if(stls && !twod){
        rotate([-90,0,0])
          import("../stl/horizontal_line_deflector.stl");
      } else {
        horizontal_line_deflector(twod=twod);
      }
  }
  if(center){
    ldef_always_center();
  } else {
    translate([0,-b623_vgroove_small_r,0])
      ldef_always_center();
  }
}

module placed_landing_bracket(){
  translate([12, 128-b623_vgroove_small_r/2, 0])
    rotate([0,0,180+90])
      landing_bracket_a();
  translate([0,-71,0])
    rotate([0,0,180])
      translate([104, 0, 0])
        landing_bracket_b();
  translate([104, -71, 0])
    rotate([0,0,180])
      landing_bracket_c();
}

//placed_line_verticalizer();
module placed_line_verticalizer(angs=[180+30,180,180-30]){
  center_it = 0;
  three = [0,120,240];

  color(color1, color1_alpha)
  for(k=[0:2])
    rotate([0,0,-30+three[k]])
      translate([-Sidelength/sqrt(3),0,0])
        rotate([0,0,angs[k]])
          translate([center_it,0,0])
            if(stls && !twod){
              rotate([0,-90,0])
              import("../stl/line_verticalizer.stl");
            } else {
              translate([-b623_vgroove_small_r,0,0])
                line_verticalizer(twod=twod);
            }
    translate([lx0-b623_vgroove_small_r,
               Sidelength/sqrt(12)-b623_vgroove_small_r,
               0])
      ldef(-78, center=true);
    translate([lx1+b623_vgroove_small_r,
               Sidelength/sqrt(12)-b623_vgroove_small_r,
               0])
      ldef(78, center=true);
    translate([lx2+b623_vgroove_small_r,ly2-b623_vgroove_small_r,0])
      ldef(68, center=true);
    translate([-b623_vgroove_small_r,ly2-b623_vgroove_small_r,0])
      ldef(-68, center=true);
    //translate([-b623_vgroove_small_r+Spool_height+GT2_gear_height,
    //           -Sidelength/sqrt(3)-49, 0])
    //  rotate([0,0,180])
    //  ldef(10);

}

//translate([0,0,Gap_between_sandwich_and_plate])
//sandwich_D();
module sandwich_D(){
  translate([0,0, (1 + Spool_height)]){
    color(color2, color2_alpha)
      if(stls){
        import("../stl/GT2_spool_gear.stl");
      } else {
        GT2_spool_gear();
      }
    color(color1, color1_alpha)
      translate([0,0,Torx_depth + 2*(1 + Spool_height) + GT2_gear_height/2])
      rotate([0,180,0]){
        if(stls){
          import("../stl/dleft_spool.stl");
          translate([0,0,1+Spool_height])
            import("../stl/sep_disc.stl");
        } else {
          dleft_spool();
          translate([0,0,1+Spool_height])
            sep_disc();
        }
      }
  }
  color(color1, color1_alpha)
    if(stls){
      import("../stl/spool.stl");
    } else {
      spool();
    }
  translate([0,0,b608_width])
    color(color2, color2_alpha)
    if(stls){
      import("../stl/spacer_D.stl");
    } else {
      spacer(Spacer_D_width);
    }
}

//translate([0,0,Gap_between_sandwich_and_plate])
//sandwich_ABC();
module sandwich_ABC(){
  translate([0,0, 1 + Spool_height]){
    color(color2, color2_alpha)
      if(stls){
        import("../stl/GT2_spool_gear.stl");
      } else {
        GT2_spool_gear();
      }
    color(color1, color1_alpha)
      translate([0,0,Torx_depth + 1 + Spool_height + GT2_gear_height/2])
      rotate([0,180,0]){
        if(stls){
          import("../stl/spool.stl");
        } else {
          spool();
        }
      }
  }
  color(color1, color1_alpha)
    if(stls){
      import("../stl/spool.stl");
    } else {
      spool();
    }
  translate([0,0,b608_width])
    color(color2, color2_alpha)
    if(stls){
      import("../stl/spacer_ABC.stl");
    } else {
      spacer(Spacer_ABC_width);
    }
}

module belt_roller_with_bearings(){
  belt_roller_bearing_center_z = Belt_roller_h - Depth_of_roller_base/2;
  if(stls && !twod){
    rotate([0,-90,0])
      import("../stl/belt_roller.stl");
    for(rot=[90,-90])
      translate([0,0,belt_roller_bearing_center_z])
        rotate([rot,0,0])
        translate([0,0,0.1])
        b623();
  } else if(twod) {
    belt_roller(twod=true);
  } else {
    belt_roller(with_bearings=true);
  }
}

//line_roller_double_with_bearings();
module line_roller_double_with_bearings(){
  bearing_center_z = Line_roller_ABC_winch_h - Depth_of_roller_base/2;
  if(stls && !twod){
    //import("../stl/line_roller_double.stl");
    translate([0,-spd,0])
      rotate([0,-90,0])
      import("../stl/line_roller_double.stl");
  } else {
    translate([0,-spd])
      line_roller_double(twod=twod);
  }
  if(!twod){
    for(y=[0,Spool_height + GT2_gear_height])
      translate([0,-y,bearing_center_z])
        rotate([90,0,0])
        translate([0,0,0.1])
        b623_vgroove();
  }
}

//sandwich_and_donkey_D();
module sandwich_and_donkey_D(){
  if(!twod){
    translate([0,
        -1-Spool_height - GT2_gear_height/2,
        Sep_disc_radius+Gap_between_sandwich_and_plate])
      rotate([90,0,180])
      sandwich_D();
  }
  // -7.2 gotten from visual inspection. 116 random.
  translate([116,-7.2 + Sandwich_ABC_width/2,0])
    render_donkey_and_bracket();
  translate([0,Spool_height+1,0])
  if(stls && !twod){
    for(k=[0,1])
      mirror([0,k,0])
        rotate([90,0,0])
        translate([0,0,-k*(Spool_height+1)])
        import("../stl/spool_core.stl");
  } else {
    translate([0,-Sandwich_D_width/2+1+Spool_height+GT2_gear_height/2,0])
      spool_cores(twod=twod, between=Sandwich_D_width);
  }

  translate([93,0,0])
    belt_roller_with_bearings();

}

//render_donkey_and_bracket();
module render_donkey_and_bracket(){
  translate([0,2.5,0])
  rotate([0,0,90]){
    if(stls && !twod){
      color([0.15,0.15,0.15],0.8)
        to_be_mounted();
    } else if(twod) {
      donkey_bracket(twod);
    }

    // TODO: placed out donkey bracket stl
    //color(color2, color2_alpha)
    //  if(stls && !twod){
    //    //import("../stl_old/donkey_bracket.stl");
    //  } else if(twod) {
    //    donkey_bracket(twod=true);
    //  } else {
    //    donkey_bracket();
    //  }
  }
}

//sandwich_and_donkey_ABC();
module sandwich_and_donkey_ABC(rotate_donkey=0){
  if(!twod)
    translate([0,
        Sandwich_ABC_width/2,
        Sep_disc_radius+Gap_between_sandwich_and_plate])
      rotate([90,0,0])
      sandwich_ABC();
  // -7.2 gotten from visual inspection. 130 random.
  translate([116,0,0])
    rotate([0,0,rotate_donkey])
    translate([0,-7.2 + Sandwich_ABC_width/2,0])
    render_donkey_and_bracket();
  translate([93,0,0])
    belt_roller_with_bearings();
  if(stls && !twod){
    for(k=[0,1])
      mirror([0,k,0])
        rotate([90,0,0])
        import("../stl/spool_core.stl");
  } else if(twod) {
    spool_cores(twod=true, between=Sandwich_ABC_width);
  } else { // not stls, not twod
    spool_cores(false, Sandwich_ABC_width);
  }
}

module sandwich_and_donkey_A(){
  sandwich_and_donkey_ABC(180);
  translate([-90,-1-Spool_height/2 + Sandwich_ABC_width/2,0])
    line_roller_double_with_bearings();
}

//sandwich_and_donkey_B();
module sandwich_and_donkey_B(){
  sandwich_and_donkey_ABC(180);
  translate([move_BC_deflectors+12,-1-Spool_height/2 + Sandwich_ABC_width/2,0])
    rotate([0,0,-60])
    translate([-40,-b623_vgroove_small_r,0])
    line_roller_double_with_bearings();
  translate([move_BC_deflectors,-spd/2,0])
    rotate([0,0,180])
    ldef(-30);
  translate([move_BC_deflectors+spd/sqrt(3),spd/2,0])
    rotate([0,0,180])
    ldef(-30);
}

//sandwich_and_donkey_C();
module sandwich_and_donkey_C(){
  mirror([0,1,0])
    sandwich_and_donkey_B();
}

//if(mounted_in_ceiling && !twod){
//  translate([0,0,43+ANCHOR_D_Z])
//    rotate([180,0,0])
//      full_winch();
//} else {
//  full_winch();
//}
module full_winch(){
  sep = abc_sep;
  y = abcspool_y;

  translate([lx3+spd/2,y,0])
    rotate([0,0,-90])
    sandwich_and_donkey_A();

  translate([-sep*3/2,y,0])
    rotate([0,0,90])
    sandwich_and_donkey_B();

  translate([sep*3/2,y,0])
    rotate([0,0,90])
    sandwich_and_donkey_C();

  translate([-sep/2-extra_space_in_middle,dspool_y,0])
    rotate([0,0,-90])
    sandwich_and_donkey_D();

  placed_line_verticalizer();
  placed_landing_bracket();

  cx = 452;
  cy = 450;
  mvy = Yshift_top_plate;
  top_plate(cx, cy, mvy);
}

//$vpt=[0,0,0];
//$vpr=[30,0,0];
//$vpd=1500;

module camera_rel_pos(x, y, z, colr, radius) {
rotate([30,0,0])
translate([0,0,1500])
  color(colr){
    rotate([180,0,0])
      translate([x, y, z])
        sphere(r=radius);
  }
}

camera_rel_pos(-72.6305, 40.5897, 1322.48, [0.9,0.1,0.1], 3);
camera_rel_pos(72.6407, 40.5903, 1322.48, [0.1,0.9,0.1], 3);

translate([0.0288159, -0.00304277, 0.352593])
  color([0.3,0.8,0.8])
    sphere(r=1);


rotate([30,0,0])
translate([0,0,1500])
  color([0.9,0,0])
    sphere(r=40);

translate([0,0,0])
  rotate([0,0,0])
  translate([0,0,-22+150.43]) mover();
module mover(){
  marker_d = 70;
  marker_y_dist = Beam_width/2 - (Sidelength+10.5)/sqrt(12) - sqrt(3);
  marker_x_dist = marker_y_dist/sqrt(3);
  module find_marker_positions() {
    z = 7.8;
    pos_red_0 =   [ -72.4478 , -125.483, z];
    pos_red_1 =   [  72.4478, -125.483, z];
    pos_green_0 = [ 146.895,  -3.4642, z];
    pos_green_1 = [  64.446,  139.34, z];
    pos_blue_0 =  [ -68.4476,  132.411, z];
    pos_blue_1 =  [-160.895,  -27.7129, z];
    echo(pos_red_0);
    echo(pos_red_1);
    echo(pos_green_0);
    echo(pos_green_1);
    echo(pos_blue_0);
    echo(pos_blue_1);
    translate(pos_red_0)
      color([0.9,0.0,0.0]){
        cylinder(d=marker_d, h=0.2);
      }
    translate(pos_red_1)
      color([0.6,0.0,0.0])
        cylinder(d=marker_d, h=0.2);
    translate(pos_green_0)
      color([0.0,0.9,0.0])
        cylinder(d=marker_d, h=0.2);
    translate(pos_green_1)
      color([0.0,0.6,0.0])
        cylinder(d=marker_d, h=0.2);
    translate(pos_blue_0)
      color([0.0,0.0,0.9])
        cylinder(d=marker_d, h=0.2);
    translate(pos_blue_1)
      color([0.0,0.0,0.6])
        cylinder(d=marker_d, h=0.2);
  }
  //find_marker_positions();

  marker_fn = 21;

  //translate([0,0,22])
  //color(red)
  //geodesic_sphere(d=marker_d, $fn=marker_fn);

  green=[0,1,0];
  blue=[0,0,1];
  red=[1,0,0];
  white=[1,1,1];
  black=[0,0,0];
  for(k=[0, 120, 240])
    rotate([180,0,k+180]){
      translate([-beam_length/2,-(Sidelength+10.5)/sqrt(12)-sqrt(3), 0]){
        color(color_carbon)
          cube([beam_length, Beam_width, Beam_width]);
        marker_shifts = [beam_length/2 - marker_x_dist + k/30, beam_length/2 + marker_x_dist - k/7.5];
        %for(l=marker_shifts)
          translate([l, Beam_width/2,-13]){
            translate([0,0,-marker_d/2+7]) {
              if (k==0) {
                color([0.9,0.9,0.9]) {
                  translate([0,0,33])
                    cylinder(d=marker_d, h=0.2, $fn=400);
                }
              }
              if (k==120) {
                color([0.9,0.9,0.9]) {
                  translate([0,0,33])
                    cylinder(d=marker_d, h=0.2, $fn=400);
                }
              }
              if (k==240) {
                color([0.9,0.9,0.9]) {
                  translate([0,0,33])
                    cylinder(d=marker_d, h=0.2, $fn=400);
                }
              }
            }
            color(color_carbon, color1_alpha){
              translate([-5,-10,10])
                cube([10,20,20]);
              translate([0,0,4.9])
                cylinder(d=3, h=5, $fn=20);
            }
          }
      }
      translate([0,Sidelength/sqrt(3) - Cc_action_point_from_mid,-Wall_th])
        color(color1, color1_alpha)
          if(stls){
            import("../stl/corner_clamp.stl");
          } else {
            corner_clamp();
          }

    }
    sidelength_frac = 1.5;
    shorter_beam = Sidelength/sidelength_frac;
    offcenter_frac = 25;
    //translate([0,-Sidelength/sqrt(12)-sqrt(3) - Wall_th+0.1, +0.35])
    translate([-shorter_beam/2,Sidelength/offcenter_frac+4,0]){
      color(color_carbon)
        cube([shorter_beam, Beam_width, Beam_width]);
      rotate([90,0,90])
        translate([-2*Wall_th,
            0,
            shorter_beam/2-(Nema17_cube_width+0.54*2+2*Wall_th)/2])
        color(color1, color1_alpha)
        if(stls){
          import("../stl/extruder_holder.stl");
        } else {
          extruder_holder();
        }
    }
    translate([0,0,22-28-Nema17_cube_width-Beam_width-11])
      color("grey")
      cylinder(d=25, h=28);
    translate([0,0,22-28-Nema17_cube_width-Beam_width-11-4])
      color("grey")
      cylinder(d=4, h=28);
    translate([-9,-15/2,22-28-Nema17_cube_width-Beam_width-11-4-45])
      color([0.8,0.1,0.1])
      rounded_cube2([22.5, 15, 46],2,$fn=4*5);
    translate([0,0,22-28-Nema17_cube_width-Beam_width-11-4-45-3])
      color([0.7,0.7,0.1])
      cylinder(d=8, h=8,$fn=6);
    translate([0,0,22-28-Nema17_cube_width-Beam_width-11-4-45-5])
      color([0.7,0.7,0.1])
      cylinder(d2=6, d1=0, h=3);
    translate([-Nema17_cube_width/2,-33+16.5,-Nema17_cube_width-4])
      color([0.15,0.15,0.15])
      rounded_cube([Nema17_cube_width, 33, 53], 1.5);
    //echo("Nozzle is at", 22-28-Nema17_cube_width-Beam_width-11-4-45-5); // -128.43
    // The first localization of nozzle
    //translate([0,0,22-28-Nema17_cube_width-Beam_width-11-4-45-5])
    //  translate([-0.2291020096681343, 0.1397392475068955, 0.2471582598082023])
    //  sphere(r=1);
}

//if(mover && !twod)
//  d_lines();
module d_lines(){
  color("yellow")
  for(k=[0,120,240])
    rotate([0,0,k])
      translate([0,Sidelength/sqrt(3),lift_mover_z])
        cylinder(r=1.9, h=ANCHOR_D_Z-lift_mover_z);
}

//if(bottom_triangle)
//  bottom_triangle();
module bottom_triangle(){
  for(i=[0,120,240])
    rotate([0,0,i])
      translate([0,-3000*sqrt(2)/sqrt(6),0]){
        color("sandybrown")
          rotate([0,0,30])
          translate([-45/2,0,-45])
          cube([45, 3000, 45]);
        translate([0,200,0])
          cube([500, 100, 12], center=true);
      }
}

//lr();
module lr(){
  ay = ANCHOR_A_Y - 10;
  color(color1,0.6)
    //difference(){
      if(stls){
        translate([4,0,0])
        rotate([90,0,-90])
        import("../stl/line_roller_anchor.stl");
      } else {
        line_roller_anchor();
      }
    //  translate([-25,-50,-1])
    //    cube(50);
    //}
    color("yellow")
      translate([Back_bearing_x+Move_tower+b623_vgroove_small_r/sqrt(2),
                 0,
                 Higher_bearing_z + b623_vgroove_small_r/sqrt(2)])
      rotate([0,-90+atan(ANCHOR_D_Z/ay),0])
      cylinder(r = 0.75, h = 0.5*sqrt(ay*ay + ANCHOR_D_Z*ANCHOR_D_Z));


    between_bearings_x = Back_bearing_x - Front_bearing_x;
    //echo(between_bearings_x);
    between_bearings_z = Higher_bearing_z - Lower_bearing_z;
    //echo(between_bearings_z);
    ang_b0_b1 = atan(between_bearings_z/between_bearings_x);
    //echo(ang_b0_b1);
    between_action_points_x = ANCHOR_A_Y-Sidelength/sqrt(9);
    ang_action = atan(between_action_points_z/between_action_points_x);
    //echo(ang_action);

    for(tr = [[[Back_bearing_x+Move_tower, 0, Higher_bearing_z],
               [-ang_b0_b1+2, 90, 0], true],
              [[Front_bearing_x+Move_tower, 0, Lower_bearing_z],
               [-103, 60, 0], true],
              [[Front_bearing_x+Move_tower, 0, Higher_bearing_z],
               [180-18+90, 276-90, 0], false]])
      translate(tr[0])
      rotate([90,0,0]){
        if(tr[2])
          color("purple")
            cylinder(r=b623_vgroove_small_r, h=1.5, center=true);
        color("yellow")
          rotate([0,tr[1][2],tr[1][0]])
          rotate_extrude(angle=tr[1][1])
          translate([b623_vgroove_small_r+tr[1][2]*0.04,0,0])
          circle(r=0.75);
      }
    color("yellow")
      translate([Front_bearing_x+Move_tower-2, 0, Higher_bearing_z-b623_vgroove_small_r+0.8])
      rotate([0,-90,0])
      rotate([0,0,235])
      rotate_extrude(angle=194, $fn=20)
        translate([2.1,0])
          circle(r=0.75);
    translate([Front_bearing_x+Move_tower-1.5, 0, Higher_bearing_z-b623_vgroove_small_r+1.9])
      color("yellow")
      rotate([-90,0,0])
      cylinder(r=0.75, h=Sidelength/2);
    translate([Front_bearing_x+Move_tower-2, -2.3, Higher_bearing_z-b623_vgroove_small_r-0.1])
      color("yellow")
      rotate([-90,0,0])
      cylinder(r=0.75, h=3);
    // Within lineroller_anchor
    line_from_to([Front_bearing_x+Move_tower + sin(ang_b0_b1)*b623_vgroove_small_r, 0,
                    Lower_bearing_z - cos(ang_b0_b1)*b623_vgroove_small_r],
                 [Back_bearing_x+Move_tower + sin(ang_b0_b1)*b623_vgroove_small_r, 0,
                    Higher_bearing_z - cos(ang_b0_b1)*b623_vgroove_small_r], r=0.75, $fn=6);
    // From lower bearing to effector
    line_from_to([Front_bearing_x+Move_tower-sin(ang_action)*b623_vgroove_small_r, 0,
                    Lower_bearing_z-cos(ang_action)*b623_vgroove_small_r],
                 [Front_bearing_x+Move_tower-sin(ang_action)*b623_vgroove_small_r
                   -between_action_points_x, 0,
                   Lower_bearing_z-cos(ang_action)*b623_vgroove_small_r
                   +between_action_points_z], r=0.75, $fn=6);
    // From effector to higher bearing
    line_from_to([Front_bearing_x+Move_tower+sin(ang_action)*b623_vgroove_small_r, 0,
                    Higher_bearing_z + cos(ang_action)*b623_vgroove_small_r],
                 [Front_bearing_x+Move_tower+sin(ang_action)*b623_vgroove_small_r
                   -between_action_points_x, 0,
                    Higher_bearing_z + cos(ang_action)*b623_vgroove_small_r
                   +between_action_points_z],  r=0.75,$fn=6);
}

//if(mounted_in_ceiling)
//  for(i=[0:120:359])
//    rotate([0,0,-90+i])
//      translate([ANCHOR_A_Y,0,0])
//        ABC_anchor();
module ABC_anchor(){
  for(k=[0,1])
    mirror([0,k,0])
      translate([0,-Sidelength/2,0])
        lr();
  Ext_sidelength = 500;
  translate([-35, -Ext_sidelength/2, -8])
    cube([50,Ext_sidelength, 8]);
  translate([Front_bearing_x+Move_tower-1,0,Higher_bearing_z-2])
    color("red")
    sphere(r=4);
}

//if(!twod)
//ceiling_unit_internal_lines_v4();
module ceiling_unit_internal_lines_v4(){
  hz = Gap_between_sandwich_and_plate+Sep_disc_radius-Spool_r;
  bd0y = dspool_y-93;
  bd1x = Spool_height + GT2_gear_height;
  bd2x = 1+ 2*Spool_height + GT2_gear_height;
  bd1y = dspool_y-136;
  bd2y = dspool_y-118;
  dyl = 100;
  module one_b_line(e=0, e2=30){
    bbc = e2+5;
    a = -abc_sep-spd/2;
    b = abcspool_y+move_BC_deflectors+e;
    c = cos(60)*b623_vgroove_small_r;
    d = sin(60)*b623_vgroove_small_r;
    line_from_to([a, abcspool_y, hz],
        [a, b+17, hz]);
    line_from_to([a-c, b+d, hz],
        [a-c-cos(30)*e2, b+d-sin(30)*e2, hz]);
    line_from_to([a-c-cos(30)*(bbc+b623_vgroove_small_r), b+d-sin(30)*(bbc+b623_vgroove_small_r), hz],
        [a-c-cos(30)*(bbc+b623_vgroove_small_r+100),
        b+d-sin(30)*(bbc+b623_vgroove_small_r+100),
        hz+100]);
  }
  // all four bc-lines
  for(k=[0,1])
    mirror([k,0,0]){
      one_b_line();
      translate([spd,0,0])
        one_b_line(e=-spd/sqrt(3), e2=30+spd/2);
    }

  for(k=[0,1])
    mirror([k,0,0]){
      line_from_to([spd/2, abcspool_y, hz],
          [spd/2, abcspool_y+90, hz]);
      line_from_to([spd/2, abcspool_y+93, hz],
          [spd/2, abcspool_y+190, 100+hz]);
    }


}

//ceiling_unit_internal_lines_v4();
//if(mounted_in_ceiling && !twod){
//  translate([0,0,43+ANCHOR_D_Z])
//    rotate([180,0,0])
//	  ceiling_unit_internal_lines_v4p1();
//} else {
//	ceiling_unit_internal_lines_v4p1();
//}
module ceiling_unit_internal_lines_v4p1(){
  hz = Gap_between_sandwich_and_plate+Sep_disc_radius-Spool_r;

  module one_b_line(e=0, e2=30){
    bbc = e2+5;
    a = -abc_sep*3/2-spd/2;
    b = abcspool_y+move_BC_deflectors+e;
    c = cos(60)*b623_vgroove_small_r;
    d = sin(60)*b623_vgroove_small_r;
    g = a-c-cos(30)*(bbc+b623_vgroove_small_r);
    i = b+d-sin(30)*(bbc+b623_vgroove_small_r);
    line_from_to([a, abcspool_y, hz],
                 [a, b+17, hz]);
    line_from_to([a-c, b+d, hz],
                 [a-c-cos(30)*e2, b+d-sin(30)*e2, hz]);
    line_from_to([g, i, hz],
        [g-cos(30)*100, i-sin(30)*100,hz+100]);
  }

  for(k=[0,1])
    mirror([k,0,0]){
      one_b_line();
      translate([spd,0,0])
        one_b_line(e=-spd/sqrt(3), e2=30+spd/2);
    }

  line_from_to([lx0, abcspool_y, hz],
               [lx0, Sidelength/sqrt(12), hz]);
  line_from_to([lx0, Sidelength/sqrt(12), hz],
               [-Sidelength/2, Sidelength/sqrt(12), hz]);

  line_from_to([lx1, abcspool_y, hz],
               [lx1, Sidelength/sqrt(12), hz]);
  line_from_to([lx1, Sidelength/sqrt(12), hz],
               [Sidelength/2, Sidelength/sqrt(12), hz]);

  line_from_to([lx2, abcspool_y, hz],
               [lx2, ly2, hz]);
  line_from_to([lx2, ly2, hz],
               [  0, ly2, hz]);
  line_from_to([  0, ly2, hz],
               [  0, -Sidelength/sqrt(3), hz]);

  for(k=[0,spd]){
    line_from_to([lx3+k, abcspool_y, hz],
                 [lx3+k, abcspool_y+90, hz]);
    line_from_to([lx3+k, abcspool_y+93, hz],
                 [lx3+k, abcspool_y+190, 100+hz]);
  }

  // Mover action point overlay for aiming
  //translate([0,Sidelength*(1/sqrt(12)), 0])
  //  rotate([0,0,180])
  //  %eqtri(Sidelength,4);

}
