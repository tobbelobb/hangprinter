include <lib/parameters.scad>
use <lib/gear_util.scad>
use <lib/util.scad>
use <lib/whitelabel_motor.scad>
use <lib/spool_core.scad>

use <GT2_spool_gear.scad>
use <corner_clamp.scad>
use <dleft_spool.scad>
use <dleft_spool_cover.scad>
use <dright_spool_top.scad>
use <dright_spool_bottom.scad>
use <dright_spool_cover.scad>
use <horizontal_line_deflector.scad>
use <landing_brackets.scad>
use <line_roller_anchor.scad>
use <line_roller_double.scad>
use <line_roller_wire_rewinder.scad>
use <line_verticalizer.scad>
use <motor_bracket_A.scad>
use <motor_bracket_B.scad>
use <motor_bracket_C.scad>
use <motor_bracket_D.scad>
use <sep_disc.scad>
use <spool.scad>
use <spool_mirrored.scad>
use <spool_cover.scad>
use <spool_cover_mirrored.scad>
use <tilted_line_deflector.scad>
use <ziptie_tensioner_wedge.scad>


beam_length = 400;

// Viewing STLs is faster when just looking at the model
// Non-stls are faster for previews when changing design
stls = true;
//stls = false;

// Viewing 2d
//twod = true;
twod = false;

//mounted_in_ceiling = true;
mounted_in_ceiling = false;

// Render the mover
//mover = true;
mover = false;

bottom_triangle = false;
//bottom_triangle = true;

ANCHOR_D_Z = 2300;
ANCHOR_A_Y = 2000;
between_action_points_z = ANCHOR_D_Z-Higher_bearing_z -3 - 175;
lift_mover_z = 200;
//lift_mover_z = ANCHOR_D_Z-300;

dspool_y = -50+30;
bcspool_y = -40;
aspool_y = -20;
aspool_lineroller_y = -110;
abc_sep = 105+18;
move_BC_deflectors = -113;

extra_space_in_middle = -10;

lxm1 = -abc_sep/2-extra_space_in_middle-spd/2 - 1 - Spool_height;
lx0 = -abc_sep/2-extra_space_in_middle-spd/2;
lx1 = -abc_sep/2-extra_space_in_middle+spd/2;
lx2 = -abc_sep/2-extra_space_in_middle+spd/2 + 1 + Spool_height;
lx3 = abc_sep/2+extra_space_in_middle-spd/2;
ly2 = Sidelength/sqrt(12) - 50;

color0 = "sandybrown";
color0_alpha = 0.55;
color1 = [0.81,0.73,0.05];
color1_alpha = 0.9;
color2 = [0.99,0.99,0.99];
color2_alpha = 0.8;
spool_cover_alpha = 0.8;

color_carbon = [0.2,0.2,0.2];
//color_line = [0.9,0.35,0.35];
color_line="green";

// Sometimes, Nema17_cube_width will have another value,
// so that a different motor can fit
_motor_ang = ((Nema17_cube_width-42.43)/(sqrt(2)*Spool_outer_radius))*(180/PI);

//top_plate();
module top_plate(cx, cy, mvy){
  if(!twod){
    color(color0, color0_alpha)
      translate([-cx/2,mvy,-12])
      cube([cx, cy, 12]); // Top plate
  //} else {
  //  translate([-cx/2,mvy])
  //    %square([cx, cy]);
  }
}

//tilted_line_deflector_for_layout(9,false);
module tilted_line_deflector_for_layout(rot_around_center=0, center=false){
  module tilted_line_deflector_always_center(){
      rotate([0,0,rot_around_center]) // Rotate around bearing center
      translate([0,b623_big_ugroove_small_r,0])
      if(stls && !twod){
        import("../stl/tilted_line_deflector.stl");
      } else {
        tilted_line_deflector(rotx=-atan(sqrt(2)), rotz=-30, twod=twod);
      }
  }
  if(center){
    tilted_line_deflector_always_center();
  } else {
    translate([0,-b623_big_ugroove_small_r,0])
      tilted_line_deflector_always_center();
  }
}


//line_deflector(9,false);
module line_deflector(rot_around_center=0, center=false){
  module line_deflector_always_center(){
      rotate([0,0,rot_around_center]) // Rotate around bearing center
      translate([0,b623_big_ugroove_small_r-3,0])
      if(stls && !twod){
        rotate([-90,0,0])
          import("../stl/horizontal_line_deflector.stl");
      } else {
        horizontal_line_deflector(twod=twod);
      }
  }
  if(center){
    line_deflector_always_center();
  } else {
    translate([0,-b623_big_ugroove_small_r,0])
      line_deflector_always_center();
  }
}

module placed_landing_brackets(){
  translate([0, 128-b623_big_ugroove_small_r/2, 0])
    rotate([0,0,180+90])
      landing_bracket_a(twod=twod);
  push_bc_brackets=23;
  translate([-push_bc_brackets*cos(60),-71+push_bc_brackets*sin(60),0])
    rotate([0,0,180])
      translate([104, 0, 0])
        rotate([0,0,180])
          landing_bracket_b(twod=twod);
  translate([104+push_bc_brackets*cos(60), -71+push_bc_brackets*sin(60), 0])
    landing_bracket_c(twod=twod);
}

//placed_line_verticalizer();
module placed_line_verticalizer(angs=[180+30,180,180-30]){
  center_it = 0;
  three = [0,120,240];

  color(color1, color1_alpha)
  for(k=[0:2])
    rotate([0,0,-30+three[k]])
      translate([-Sidelength/sqrt(3)-Move_d_bearings_inwards,0,0])
        rotate([0,0,angs[k]])
          translate([center_it,0,0])
            if(stls && !twod){
              rotate([0,-90,0])
              import("../stl/line_verticalizer.stl");
            } else {
              translate([-b623_big_ugroove_small_r,0,0])
                line_verticalizer(twod=twod);
            }
    translate([lx0-b623_big_ugroove_small_r,
               Sidelength/sqrt(12)+Move_d_bearings_inwards/2-b623_big_ugroove_small_r-b623_width/2-1,
               0])
      line_deflector(-67, center=true);
    translate([lxm1, 79, 0])
      rotate([0,0,90])
      if(stls && !twod){
        import("../stl/line_roller_wire_rewinder.stl");
      } else {
        line_roller_wire_rewinder(twod=twod);
      }
    translate([lx1+b623_big_ugroove_small_r,
               Sidelength/sqrt(12)+Move_d_bearings_inwards/2-b623_big_ugroove_small_r-b623_width/2-1,
               0])
      line_deflector(67, center=true);
    translate([lx2+b623_big_ugroove_small_r, ly2-b623_big_ugroove_small_r,0])
      line_deflector(63, center=true);
    translate([-b623_big_ugroove_small_r+b623_width/2+1,ly2-b623_big_ugroove_small_r,0])
      line_deflector(-90-90-90, center=true);
}

//translate([0,0,Gap_between_sandwich_and_plate])
//!sandwich_D();
module sandwich_D(){
  translate([0,0, (1 + Spool_height)]){
    color(color2, color2_alpha)
      if(stls) import("../stl/GT2_spool_gear.stl");
      else GT2_spool_gear();
    translate([0,0,Torx_depth + 2*(1 + Spool_height) + GT2_gear_height/2])
      rotate([0,180,0]){
        color(color1, color1_alpha)
          if(stls){
            import("../stl/dleft_spool.stl");
            translate([0,0,1+Spool_height])
              import("../stl/sep_disc.stl");
          } else {
            dleft_spool();
            translate([0,0,1+Spool_height])
              sep_disc();
          }
        color(color1, spool_cover_alpha)
          translate([0,0,-Spool_cover_bottom_th-Spool_cover_shoulder])
            rotate([0,0,90])
              if (stls) import("../stl/dleft_spool_cover.stl");
              else dleft_spool_cover();
      }
  }
  color(color1, color1_alpha){
    if(stls) import("../stl/dright_spool_top.stl");
    else dright_spool_top();
    translate([0,0,-Spool_height-1])
    if(stls) import("../stl/dright_spool_bottom.stl");
    else dright_spool_bottom();
    translate([0,0,-Spool_cover_bottom_th-Spool_cover_shoulder - Spool_height - 1])
      rotate([0,0,-90])
        if (false) import("../stl/dright_spool_cover.stl");
        else dright_spool_cover();
  }
}

//!placed_sandwich_D();
module placed_sandwich_D(){
    translate([0,
        -1-Spool_height - GT2_gear_height/2,
        Sep_disc_radius+Gap_between_sandwich_and_plate])
      rotate([90,0,180])
      sandwich_D();
}

//translate([0,0,Gap_between_sandwich_and_plate])
//!sandwich_ABC();
module sandwich_ABC(){
  translate([0,0, 1 + Spool_height]){
    color(color2, color2_alpha)
      if(stls) import("../stl/GT2_spool_gear.stl");
      else GT2_spool_gear();
    translate([0,0,Torx_depth + 1 + Spool_height + GT2_gear_height/2])
      rotate([0,180,0]){
        color(color1, color1_alpha)
          if(stls) import("../stl/spool_mirrored.stl");
          else spool_mirrored();
        color(color1, spool_cover_alpha)
          translate([0,0,-Spool_cover_bottom_th-Spool_cover_shoulder])
            rotate([0,0,-90])
              if (stls) import("../stl/spool_cover.stl");
              else spool_cover();
      }
  }
  color(color1, color1_alpha)
    if(stls) import("../stl/spool.stl");
    else spool();
  color(color1, spool_cover_alpha)
    translate([0,0,-Spool_cover_bottom_th-Spool_cover_shoulder])
      rotate([0,0,90])
        if (stls) import("../stl/spool_cover_mirrored.stl");
        else spool_cover_mirrored();
}

//!belt_roller_bearings();
module belt_roller_bearings(){
  belt_roller_bearing_center_z = Belt_roller_h - Depth_of_roller_base/2;
  if (!twod)
    for(rot=[90,-90])
      translate([0,0,belt_roller_bearing_center_z])
        rotate([rot,0,0])
          translate([0,0,-b623_width-0.1])
            b623_flanged();
}

//!line_roller_double_with_bearings();
module line_roller_double_with_bearings(){
  bearing_center_z = Line_roller_ABC_winch_h - Depth_of_roller_base/2;
  if(stls && !twod){
    //import("../stl/line_roller_double.stl");
    translate([0,-spd,0])
      import("../stl/line_roller_double.stl");
  } else {
    translate([0,-spd])
      line_roller_double(twod=twod);
  }
  if(!twod){
    for(y=[0,Spool_height + GT2_gear_height])
      translate([Shear_line_roller_double_bearings*(0.5-y/(Spool_height + GT2_gear_height)),-y,bearing_center_z])
		    mirror([0,y,0])
        rotate([90,0,0])
        translate([0,0,0.1])
        rotate([-90,0,0])
        translate([0,0,-(b623_big_ugroove_small_r+Eyelet_extra_dist)])
        rotate([-5,0,0])
        translate([0,0.7,(b623_big_ugroove_small_r+Eyelet_extra_dist)])
        rotate([90,0,0])
        b608_vgroove();
  }
}

//!sandwich_and_motor_D();
module sandwich_and_motor_D(){
  if(!twod){
    placed_sandwich_D();
  }
  translate([Belt_roller_bearing_xpos,0,0]){
    rotate([0,0,90])
      render_motor_and_bracket(D=true);
    belt_roller_bearings();
  }

  if(!twod) {
    // Smooth rod
    color("grey")
      translate([0,-Smooth_rod_length_D,Sep_disc_radius + Gap_between_sandwich_and_plate])
        rotate([90,0,0])
          translate([0,0,(Sandwich_ABC_width - Sandwich_D_width)/2])
            cylinder(d=8, h=Smooth_rod_length_D, center=true);
  }

}

//!render_motor_and_bracket();
module render_motor_and_bracket(leftHanded=false, A=false, B=false, C=false, D=false){
  if (stls && !twod) {
    if(A)
      import("../stl/motor_bracket_A.stl");
    else if (B)
      import("../stl/motor_bracket_B.stl");
    else if (C)
      import("../stl/motor_bracket_C.stl");
    else // use D as default...
      import("../stl/motor_bracket_D.stl");
  } else {
    if(A)
      motor_bracket_A(twod=twod);
    else if (B)
      motor_bracket_B(twod=twod);
    else if (C)
      motor_bracket_C(twod=twod);
    else // use D as default...
      motor_bracket_D(twod=twod);
  }

  module motor(ang=0) {
    if (!twod)
      translate([-13.5,-33,35])
        rotate([ang,0,0])
          import("../stl/for_render/whitelabel_motor.stl");
  }

  module gear(){
    if(!twod)
      translate([-GT2_motor_gear_height+1.5+(GT2_motor_gear_height-7.4-1.5)/2,0,0]){
        color([0.75,0.75,0.75])
          translate([0,-33,35]) // Up to motor shaft center
            rotate([0,90,0])
              //GT2_motor_gear(5.02);
              import("../stl/for_render/GT2_motor_gear.stl");
      }
  }

  color([0.5,0.4,0.9])
    if(A)
      mirror([1,0,0])
        motor();
    else if(B)
      mirror([1,0,0])
        motor(180);
    else if(C)
      motor(180);
    else if(D)
      motor();

  if (A || B)
    mirror([1,0,0])
      gear();
  else
    gear();

}


//!sandwich_and_motor_ABC();
module sandwich_and_motor_ABC(leftHanded=false, A=false, B=false, C=false){
  cover_adj=Spool_core_cover_adj;
  if(!twod)
    translate([0,
        Sandwich_ABC_width/2,
        Sep_disc_radius+Gap_between_sandwich_and_plate])
      rotate([90,0,0])
        sandwich_ABC();
  translate([Belt_roller_bearing_xpos,0,0])
    rotate([0,0,90])
      render_motor_and_bracket(leftHanded, A=A, B=B, C=C, D=false);
  translate([Belt_roller_bearing_xpos,0,0])
    belt_roller_bearings();

  if(!twod) {
    // Smooth rod
    color("grey")
      translate([0,0,Sep_disc_radius + Gap_between_sandwich_and_plate])
        rotate([90,0,0])
          cylinder(d=8, h=Smooth_rod_length_ABC, center=true);
  }
}

//!sandwich_and_motor_A();
module sandwich_and_motor_A(){
  sandwich_and_motor_ABC(A=true);
  translate([aspool_lineroller_y,-1-Spool_height/2 + Sandwich_ABC_width/2,0])
    line_roller_double_with_bearings();
}

//!line_guides_BC();
module line_guides_BC(){
  line_guide_rot=-30;
  translate([move_BC_deflectors+spd/sqrt(3)+1,spd/2,0])
    rotate([0,0,180])
    tilted_line_deflector_for_layout(line_guide_rot);
}

//!sandwich_and_motor_B();
module sandwich_and_motor_B(){
  sandwich_and_motor_ABC(B=true);
  mirror([0,1,0])
    line_guides_BC();
}


//!sandwich_and_motor_C();
module sandwich_and_motor_C(){
  sandwich_and_motor_ABC(C=true);
 line_guides_BC();
}


cx = 452.17+sqrt(12)*Move_d_bearings_inwards/2;
cy = 450.02+Move_d_bearings_inwards/2;
bc_x_pos = cx/2-GT2_gear_height/2-Spool_cover_tot_height-Spool_core_halve_width-2;

module odrive(){
  color([0.1,0.1,0.1])
    cube([140, 50, 2]);
  translate([47,18,2])
    color([0.9,0.9,0.9])
      text("ODrive");
}


if(mounted_in_ceiling && !twod){
  translate([0,0,43+ANCHOR_D_Z])
    rotate([180,0,0])
      full_winch();
} else {
  full_winch();
}
module full_winch(){
  sep = abc_sep;
  y = bcspool_y;

  translate([lx3+spd/2,aspool_y,0])
    rotate([0,0,-90])
    sandwich_and_motor_A();

  translate([-bc_x_pos,y,0])
    rotate([0,0,90])
    sandwich_and_motor_C();

  translate([bc_x_pos,y,0])
    rotate([0,0,90])
    sandwich_and_motor_B();

  translate([-sep/2-extra_space_in_middle,dspool_y,0])
    rotate([0,0,-90])
    sandwich_and_motor_D();

  placed_line_verticalizer();
  placed_landing_brackets();

  echo("Top plate width: ", cx);
  echo(cy);
  mvy = Yshift_top_plate;
  top_plate(cx, cy, mvy);

  translate([188, -200, 0])
    rotate([0,0,180])
      odrive();
  translate([-48, -200, 0])
    rotate([0,0,180])
      odrive();
}

if(mover && !twod)
  translate([0,0,lift_mover_z])
  mover();
module mover(){
  //translate([0,0,7])
  //color("white")
  //difference() {
  //   cylinder(d=beam_length,h=1,$fn=200);
  //   translate([0,0,-1])
  //     cylinder(d=beam_length-Beam_width*2,h=5,$fn=200);
  //}
  for(k=[0,120,240])
    rotate([180,0,k+180]){
      translate([-beam_length/2,-(Sidelength+10.5)/sqrt(12)-sqrt(3), 0]){
        color(color_carbon)
          cube([beam_length, Beam_width, Beam_width]);
        marker_shift = beam_length/3;
        marker_d = 32;
        for(l=[0,1])
          translate([marker_shift + l*(-marker_shift*2 + beam_length), Beam_width/2,2]){
            color([0.9,0.9,0.9])
              translate([0,0,-marker_d/2+7]) {
                if (k==0)
                  translate([26*l,0,0]){
                    cylinder(d=90);
                    color(color_carbon, color1_alpha){
                      translate([-5,-10,4])
                        cube([10,20,20]);
                      translate([0,0,1])
                        cylinder(d=3, h=8, center=true);
                    }
                  }
                if (k==120)
                  translate([-21+78*l,0,0]){
                    cylinder(d=90);
                    color(color_carbon, color1_alpha){
                      translate([-5,-10,4])
                        cube([10,20,20]);
                      translate([0,0,1])
                        cylinder(d=3, h=8, center=true);
                    }
                  }
                if (k==240)
                  translate([76*l-50,0,0]){
                    cylinder(d=90);
                    color(color_carbon, color1_alpha){
                      translate([-5,-10,4])
                        cube([10,20,20]);
                      translate([0,0,1])
                        cylinder(d=3, h=8, center=true);
                    }
                  }
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
            translate([-shorter_beam/2,Sidelength/offcenter_frac,0]){
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
}

if(mover && !twod)
  d_lines();
module d_lines(){
  color("pink")
    for(k=[0,120,240])
      rotate([0,0,k])
        translate([0,Sidelength/sqrt(3),lift_mover_z])
          cylinder(r=1.9, h=ANCHOR_D_Z-lift_mover_z+15);
}

if(bottom_triangle)
  bottom_triangle();
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

//!lr();
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
      translate([Back_bearing_x+Move_tower+b623_big_ugroove_small_r/sqrt(2),
                 0,
                 Higher_bearing_z + b623_big_ugroove_small_r/sqrt(2)])
      rotate([0,-90+atan(ANCHOR_D_Z/ay),0])
      cylinder(r = 0.75, h = 0.5*sqrt(ay*ay + ANCHOR_D_Z*ANCHOR_D_Z));


    between_bearings_x = Back_bearing_x - Front_bearing_x;
    echo(between_bearings_x);
    between_bearings_z = Higher_bearing_z - Lower_bearing_z;
    echo(between_bearings_z);
    ang_b0_b1 = atan(between_bearings_z/between_bearings_x);
    echo(ang_b0_b1);
    between_action_points_x = ANCHOR_A_Y-Sidelength/sqrt(9);
    ang_action = atan(between_action_points_z/between_action_points_x);
    echo(ang_action);

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
            cylinder(r=b623_big_ugroove_small_r, h=1.5, center=true);
        color("yellow")
          rotate([0,tr[1][2],tr[1][0]])
          rotate_extrude(angle=tr[1][1])
          translate([b623_big_ugroove_small_r+tr[1][2]*0.04,0,0])
          circle(r=0.75);
      }
    color("yellow")
      translate([Front_bearing_x+Move_tower-2, 0, Higher_bearing_z-b623_big_ugroove_small_r+0.8])
      rotate([0,-90,0])
      rotate([0,0,235])
      rotate_extrude(angle=194, $fn=20)
        translate([2.1,0])
          circle(r=0.75);
    translate([Front_bearing_x+Move_tower-1.5, 0, Higher_bearing_z-b623_big_ugroove_small_r+1.9])
      color("yellow")
      rotate([-90,0,0])
      cylinder(r=0.75, h=Sidelength/2);
    translate([Front_bearing_x+Move_tower-2, -2.3, Higher_bearing_z-b623_big_ugroove_small_r-0.1])
      color("yellow")
      rotate([-90,0,0])
      cylinder(r=0.75, h=3);
    // Within lineroller_anchor
    line_from_to([Front_bearing_x+Move_tower + sin(ang_b0_b1)*b623_big_ugroove_small_r, 0,
                    Lower_bearing_z - cos(ang_b0_b1)*b623_big_ugroove_small_r],
                 [Back_bearing_x+Move_tower + sin(ang_b0_b1)*b623_big_ugroove_small_r, 0,
                    Higher_bearing_z - cos(ang_b0_b1)*b623_big_ugroove_small_r], r=0.75, $fn=6);
    // From lower bearing to effector
    line_from_to([Front_bearing_x+Move_tower-sin(ang_action)*b623_big_ugroove_small_r, 0,
                    Lower_bearing_z-cos(ang_action)*b623_big_ugroove_small_r],
                 [Front_bearing_x+Move_tower-sin(ang_action)*b623_big_ugroove_small_r
                   -between_action_points_x, 0,
                   Lower_bearing_z-cos(ang_action)*b623_big_ugroove_small_r
                   +between_action_points_z], r=0.75, $fn=6);
    // From effector to higher bearing
    line_from_to([Front_bearing_x+Move_tower+sin(ang_action)*b623_big_ugroove_small_r, 0,
                    Higher_bearing_z + cos(ang_action)*b623_big_ugroove_small_r],
                 [Front_bearing_x+Move_tower+sin(ang_action)*b623_big_ugroove_small_r
                   -between_action_points_x, 0,
                    Higher_bearing_z + cos(ang_action)*b623_big_ugroove_small_r
                   +between_action_points_z],  r=0.75,$fn=6);
}

if(mounted_in_ceiling)
  for(i=[0:120:359])
    rotate([0,0,-90+i])
      translate([ANCHOR_A_Y,0,0])
        ABC_anchor();
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

color(color_line){
  if(mounted_in_ceiling && !twod){
    translate([0,0,43+ANCHOR_D_Z])
      rotate([180,0,0])
      ceiling_unit_internal_lines_v4p1();
  } else {
    ceiling_unit_internal_lines_v4p1();
  }
}
module ceiling_unit_internal_lines_v4p1(){
  hz = Gap_between_sandwich_and_plate+Sep_disc_radius-Spool_r;

  module one_b_line(e=0, e2=30){
    bbc = e2+5;
    a = -bc_x_pos-spd/2;
    b = bcspool_y+move_BC_deflectors+e;
    c = cos(60)*b623_big_ugroove_small_r;
    d = sin(60)*b623_big_ugroove_small_r;
    line_from_to([a, bcspool_y, hz],
                 [a-0.5, b+10, hz]);
    line_from_to([a-c+0.5, b+d-0.7, hz+2],
                 [a-c-cos(30)*100, b+d-sin(30)*100, hz+150]);
  }

  if(!twod){
    for(k=[0,1])
      mirror([k,0,0]){
        one_b_line();
        translate([spd,-11,0])
          one_b_line(e=-spd/sqrt(3), e2=30+spd/2);
      }

    line_from_to([lx0, bcspool_y, hz],
                 [lx0, Sidelength/sqrt(12)+Move_d_bearings_inwards/2-b623_width/2-1, hz]);
    line_from_to([lx0, Sidelength/sqrt(12)+Move_d_bearings_inwards/2-b623_width/2-1, hz],
                 [-Sidelength/2, Sidelength/sqrt(12)+Move_d_bearings_inwards/2-b623_width/2-1, hz]);

    line_from_to([lx1, bcspool_y, hz],
                 [lx1, Sidelength/sqrt(12)+Move_d_bearings_inwards/2-b623_width/2-1, hz]);
    line_from_to([lx1, Sidelength/sqrt(12)+Move_d_bearings_inwards/2-b623_width/2-1, hz],
                 [Sidelength/2, Sidelength/sqrt(12)+Move_d_bearings_inwards/2-b623_width/2-1, hz]);

    line_from_to([lx2, bcspool_y, hz],
                 [lx2, ly2, hz]);
    line_from_to([lx2, ly2, hz],
                 [b623_width/2+1, ly2, hz]);
    line_from_to([b623_width/2+1, ly2, hz],
                 [b623_width/2+1, -Sidelength/sqrt(3)-Move_d_bearings_inwards, hz]);

    for(k=[0,spd]){
      ydiff = Shear_line_roller_double_bearings*(0.5-k/spd);
      line_from_to([lx3+k, aspool_y, hz],
                   [lx3+k, ydiff+aspool_y-aspool_lineroller_y+7, hz]);
      line_from_to([lx3+k, ydiff+aspool_y-aspool_lineroller_y+7, hz],
                   [lx3+k+(k-spd/2), ydiff+aspool_y+190, 100+hz]);
    }
  }


}
// Mover action point overlay for aiming
//%translate([0,Sidelength/sqrt(12)+Move_d_bearings_inwards/2, 0])
//  rotate([0,0,180])
//  eqtri(Sidelength+sqrt(12)*Move_d_bearings_inwards/2,4);
