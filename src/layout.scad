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
use <new_tilted_line_deflector.scad>
use <ziptie_tensioner_wedge.scad>


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

A = 0;
B = 1;
C = 2;
D = 3;
X = 0;
Y = 1;
Z = 2;

anchors = [[16.83, -1584.86, -113.17],
           [1290.18, 1229.19, -157.45],
           [-1409.88, 742.61, -151.80],
           [21.85, -0.16, 2343.67]];

between_action_points_z = anchors[D][Z]-Higher_bearing_z -3 - 175;
length_of_toolhead = 77;
//length_of_toolhead = anchors[D][Z]-300;

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

//tilted_line_deflector_for_layout();
module tilted_line_deflector_for_layout(){
  translate([-10, 0,0])
    if(stls && !twod){
      rotate([0,0,-90])
        import("../stl/new_tilted_line_deflector.stl");
    } else {
      rotate([0,0,-90])
        new_tilted_line_deflector(twod=twod);
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

    belt();
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

//!union() {
//  belt();
//
//  translate([ -13.5, -33, 35 ]) rotate([ 180, 0, 0 ])
//      import("../stl/for_render/whitelabel_motor.stl");
//
//   translate([-GT2_motor_gear_height+1.5+(GT2_motor_gear_height-7.4-1.5)/2,0,0])
//     color([0.75,0.75,0.75])
//       translate([0,-33,35]) // Up to motor shaft center
//         rotate([0,90,0])
//           import("../stl/for_render/GT2_motor_gear.stl");
//}
module belt(){
  module motor_belt_shape(){
    motor_gear_to_belt_idler = 35.5;
    rotate([0,90,0])
      difference(){
        cylinder(d=GT2_motor_gear_outer_dia + 2*Belt_thickness, h=GT2_belt_width);
        translate([0,0,-1])
          cylinder(d=GT2_motor_gear_outer_dia, h=GT2_belt_width + 2);
        translate([-8,0,-GT2_belt_width])
          rotate([0,0,-4])
            cube([15,15,2*GT2_belt_width+2]);
        translate([-7.0,0.8,-GT2_belt_width])
          rotate([0,0,-11.1])
            cube([15,15,2*GT2_belt_width+2]);
      }
    rotate([-11.1,0,0])
      translate([0,0,-GT2_motor_gear_outer_dia/2 - Belt_thickness])
        cube([GT2_belt_width, 120, Belt_thickness]);
    rotate([-3,0,0])
      translate([0,0,GT2_motor_gear_outer_dia/2])
        cube([GT2_belt_width, 35, Belt_thickness]);
    translate([0,motor_gear_to_belt_idler+b623_outer_dia+Belt_thickness,b623_outer_dia])
      rotate([88,0,0])
        translate([0,0,GT2_motor_gear_outer_dia/2])
          cube([GT2_belt_width, 45, Belt_thickness]);
  }

    color([0.30,0.30,0.30], 0.8){
      translate([Belt_roller_bearing_xpos,0,0])
        rotate([0,0,90])
          translate([-GT2_belt_width/2,0,0])
            color([0.75,0.75,0.75])
              translate([0,-33,35]) // Up to motor shaft center
                 motor_belt_shape();

        spool_gear_outer_dia = 161.83;
        translate([0,0,Gap_between_sandwich_and_plate + Sep_disc_radius])
          rotate([0,90,90])
            difference(){
              cylinder(d=spool_gear_outer_dia + 2*Belt_thickness, h=GT2_belt_width, center=true, $fn=12*5);
              cylinder(d=spool_gear_outer_dia, h=GT2_belt_width + 2, center=true, $fn=12*5);
              rotate([0,0,-11.1])
                translate([0,-spool_gear_outer_dia/2+10,-GT2_belt_width])
                  cube([spool_gear_outer_dia/2,spool_gear_outer_dia/2-10,2*GT2_belt_width]);
              rotate([0,0,-1])
                translate([-4,-spool_gear_outer_dia/2+0.1,-GT2_belt_width])
                  cube([spool_gear_outer_dia/3,spool_gear_outer_dia/2,2*GT2_belt_width]);
            }
      }
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
    // Belt
    belt();
  }
}

//!sandwich_and_motor_A();
module sandwich_and_motor_A(){
  sandwich_and_motor_ABC(A=true);
  translate([move_BC_deflectors+spd/sqrt(3)+1, GT2_gear_height/2 + Spool_height/2,0])
    rotate([0,0,180])
      tilted_line_deflector_for_layout();
}

//!line_guides_BC();
module line_guides_BC(){
  translate([move_BC_deflectors+spd/sqrt(3)+1,spd/2,0])
    rotate([0,0,180])
      tilted_line_deflector_for_layout();
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

module odrive_2d(){
  difference(){
    square([140, 50]);
    translate([140-2.5, 50-2.5])
      circle(d=3);
    translate([2.5, 50-2.5])
      circle(d=3);
    translate([140-2.5, 4])
      circle(d=3);
    translate([2.5, 4])
      circle(d=3);
    translate([47,18])
      text("ODrive");
  }
}

module odrive(){
  if (!twod) {
    color([0.1,0.1,0.1])
      linear_extrude(height=2) odrive_2d();
  } else {
    odrive_2d();
  }
}


if(mounted_in_ceiling && !twod && !mover){
  translate(anchors[D]  + [0,0,33])
    rotate([180,0,0])
      full_winch();
}
//full_winch();
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

  translate([188, -208.4, 0])
    rotate([0,0,180])
      odrive();
  translate([-48, -208.4, 0])
    rotate([0,0,180])
      odrive();
}


//mover();
module mover(pos = [0,0,0]){
  //translate([0,0,7])
  //color("white")
  //difference() {
  //   cylinder(d=beam_length,h=1,$fn=200);
  //   translate([0,0,-1])
  //     cylinder(d=beam_length-Beam_width*2,h=5,$fn=200);
  //}
  translate(pos + [0,0,length_of_toolhead]){
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
      color("red")
        translate([0,0,-length_of_toolhead+10]){
          cylinder(d=10, h=length_of_toolhead);
          translate([0,0,-10])
            cylinder(d1=1, d2=10, h=10);
        }
      color([0.1,0.1,0.1])
        translate([-20, -15, -40])
          cube([40,25,40]);
  }
}

//d_lines();
module d_lines(pos=[0,0,0]){
  color("pink"){
    line_from_to(pos + [0,Sidelength/sqrt(3), length_of_toolhead], anchors[D] + [0,Sidelength/sqrt(3),0]);
    line_from_to(pos + [cos(30)*Sidelength/sqrt(3),-sin(30)*Sidelength/sqrt(3), length_of_toolhead], anchors[D] + [cos(30)*Sidelength/sqrt(3),-sin(30)*Sidelength/sqrt(3),0]);
    line_from_to(pos + [-cos(30)*Sidelength/sqrt(3),-sin(30)*Sidelength/sqrt(3), length_of_toolhead], anchors[D] + [-cos(30)*Sidelength/sqrt(3),-sin(30)*Sidelength/sqrt(3),0]);
  }
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

//ABC_anchor();
module ABC_anchor(){
  Ext_sidelength = 500;
  translate([0, -Ext_sidelength/2, -8])
    cube([50,Ext_sidelength, 8]);
  color(color1,0.6)
    for(k=[0,1]) mirror([0,k,0])
      translate([26,Ext_sidelength/2-27.91,0])
        if(stls){
          rotate([0,0,-90])
          import("../stl/line_roller_anchor.stl");
        } else {
          line_roller_anchor();
        }

}

function rotation(v, ang) = [v[0]*cos(ang)-v[1]*sin(ang), v[0]*sin(ang)+v[1]*cos(ang), v[2]];

module ABC_anchors(pos = [0,0,0]){
  a_high_left = [-Sidelength/2, -Sidelength/sqrt(8)+5, length_of_toolhead-3];
  a_low_left = a_high_left - [0,0,Corner_clamp_bearings_center_to_center + 2*b623_big_ugroove_big_r];
  a_high_right = a_high_left + [Sidelength,0,0];
  a_low_right = a_low_left + [Sidelength,0,0];
  for(i = [A, B, C]){
    translate(anchors[i])
      rotate([0,0,i*120])
        translate([0,-Sidelength/sqrt(8)+5,length_of_toolhead-46])
          rotate([0,0,-90])
            ABC_anchor();
    action_high_left = rotation(a_high_left, i*120);
    action_low_left = rotation(a_low_left, i*120);
    action_high_right = rotation(a_high_right, i*120);
    action_low_right = rotation(a_low_right, i*120);
    color("pink"){
      line_from_to(pos + action_high_left, action_high_left + anchors[i]);
      line_from_to(pos + action_low_left, action_low_left + anchors[i]);
      line_from_to(pos + action_high_right, action_high_right + anchors[i]);
      line_from_to(pos + action_low_right, action_low_right + anchors[i]);
    }
  }
}


color(color_line){
  if(mounted_in_ceiling && !twod){
    translate([0,0,43+anchors[D][Z]])
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
        translate([spd,0,0])
          one_b_line();
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
      ydiff = 0;
      line_from_to([lx3+k, aspool_y, hz],
                   [lx3+k, ydiff+aspool_y-aspool_lineroller_y+7, hz]);
      line_from_to([lx3+k, ydiff+aspool_y-aspool_lineroller_y+7, hz],
                   [lx3+k+(k-spd/2), ydiff+aspool_y+190, 100+hz]);
    }
  }


}

data_collection_positions_standard = [[  -0.527094,   -0.634946,    0.      ],
                                      [-266.144   , -284.39    ,    0.      ],
                                      [ 240.691   , -273.008   ,    0.      ],
                                      [ 283.932   ,    7.41853 ,    0.      ],
                                      [ 304.608   ,  435.201   ,    0.      ],
                                      [-177.608   ,  438.733   ,    0.      ],
                                      [-369.145   ,   45.972   ,    0.      ],
                                      [-198.326   ,   25.0843  ,    0.      ],
                                      [  62.8474  ,  -55.7797  , 1388.51    ]];
                                      //[-465.720402,  -47.402828,  144.462088],
                                      //[-632.793181,  331.407685,  122.435335],
                                      //[-703.172374,  411.749689,   50.923223],
                                      //[-278.128747,  523.583008,   39.482521],
                                      //[ 441.360892,  672.851237,  123.346511],
                                      //[ 467.518466,  132.214308,  198.583508],
                                      //[  39.373078, -623.440677,  128.088103],
                                      //[-344.024592, -330.341518,  169.432092],
                                      //[-421.991046,   27.298237,  237.089385],
                                      //[-677.856009,  394.575547,  195.634237],
                                      //[-290.097311,  588.750296,  297.186251],
                                      //[ 473.710129,  653.111136,  207.072464],
                                      //[ 307.115412,  278.143918,  232.68222 ],
                                      //[  45.919828, -414.746019,  316.203898],
                                      //[ -28.007028, -776.782475,  232.726695],
                                      //[-338.464034, -217.561424,  269.973839],
                                      //[-644.658706,  365.415558,  318.17921 ],
                                      //[-343.384771,  391.053272,  412.917205],
                                      //[  70.982196,  550.599654,  509.60238 ],
                                      //[ 508.298514,  644.358488,  516.594187],
                                      //[ 238.492781,  -34.479055,  529.969725],
                                      //[  -7.909342, -660.701143,  520.943697],
                                      //[-312.373073, -177.474784,  578.96939 ],
                                      //[-510.821387,  300.767972,  600.966488],
                                      //[ -64.220889,   36.870639,  609.332198],
                                      //[  23.381683,  458.95078 ,  667.581437],
                                      //[ 306.075462,  473.876435,  817.046954],
                                      //[ 189.72739 ,  -72.936578,  805.059794],
                                      //[ -22.17987 , -518.797106,  882.381174],
                                      //[-277.601788,  -29.334304,  955.430122],
                                      //[ -65.297082,  279.999283,  954.259647],
                                      //[ -30.786666,  152.851294, 1153.945947]];//,
                                      //[  67.137601, -860.083044,  605.952846],
                                      //[ 284.655962, -102.262586,  867.814654],
                                      //[-560.690875,  -25.340757,  271.465517]];

hp_marks_measurements = [[-0.527094, -0.634946, -0.370821],
                         [-266.144, -284.39, 5.48368],
                         [240.691, -273.008, 1.84387],
                         [283.932, 7.41853, -0.878299],
                         [304.608, 435.201, 0.00422374],
                         [-177.608, 438.733, -1.03731],
                         [-369.145, 45.972, 3.83473],
                         [-198.326, 25.0843, 1.23042],
                         [-465.56, -47.6696, 148.958],
                         [-632.978, 330.731, 123.941],
                         [-703.697, 410.585, 53.9513],
                         [-277.863, 522.619, 36.4518],
                         [443.706, 670.927, 121.135],
                         [465.545, 131.309, 197.025],
                         [38.9178, -623.777, 137.685],
                         [-343.296, -331.299, 175.893],
                         [-419.43, 25.5785, 243.119],
                         [-684.896, 395.692, 186.824],
                         [-287.429, 587.691, 297.107],
                         [476.717, 650.558, 205.9],
                         [307.146, 275.748, 231.131],
                         [43.8489, -415.35, 318.255],
                         [-28.077, -777.228, 241.797],
                         [-339.945, -219.036, 269.015],
                         [-642.961, 364.091, 321.117],
                         [-340.953, 389.898, 413.864],
                         [75.86, 545.978, 511.986],
                         [510.734, 641.667, 514.656],
                         [238.593, -33.943, 528.039],
                         [-8.68617, -660.259, 526.475],
                         [-307.971, -177.118, 588.672],
                         [-506.395, 298.312, 602.812],
                         [-59.6972, 35.2041, 611.094],
                         [28.0547, 457.294, 667.879],
                         [308.339, 471.581, 815.545],
                         [189.286, -72.3184, 806.111],
                         [-23.5655, -517.217, 886.333],
                         [-275.386, -30.794, 959.031],
                         [-62.4441, 278.419, 954.677],
                         [-29.8298, 147.913, 1155.45],
                         [62.8474, -55.7797, 1388.51]];


translate([-14,91,-2.5])
  cube([800,800,5], center=true);

if(mounted_in_ceiling && mover && !twod){
  partial_way = min(1.3*($t*(len(data_collection_positions_standard)-1) - floor($t*(len(data_collection_positions_standard)-1))), 1);
  echo(partial_way);
  render_pos = (1-partial_way)*data_collection_positions_standard[$t*(len(data_collection_positions_standard)-1)]//*(1-mod($t,1/len(data_collection_positions_standard)))
               + partial_way*data_collection_positions_standard[$t*(len(data_collection_positions_standard)-1)+1];
              //+ data_collection_positions_standard[$t*(len(data_collection_positions_standard)-2) + 1]*mod($t,1/len(data_collection_positions_standard));
  render_full_position(render_pos);
}
module render_full_position(pos = [100,0,0]) {
  mover(pos);
  d_lines(pos);
  translate(anchors[D]  + [0,0,33])
    rotate([180,0,0])
      full_winch();
  ABC_anchors(pos);
}



//data_collection_points(hp_marks_measurements, 9, "cyan", "cyan");
data_collection_points(data_collection_positions_standard, 9);
module data_collection_points(points, knowns = 0, color0 = "green", color1 = "blue") {
  for(i = [0:len(points)-1])
    translate(points[i])
      if(i < knowns)
        color(color0)
          sphere(d=25);
      else
        color(color1)
          sphere(d=25);

}
