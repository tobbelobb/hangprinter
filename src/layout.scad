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
between_action_points_z = 400;
lift_mover_z = between_action_points_z + Higher_bearing_z+8;

dspool_y = -169;
abcspool_y = 169;
abc_sep = 100;
move_BC_deflectors = -100;

color0 = "sandybrown";
color0_alpha = 0.55;
color1 = [0.14,0.16,0.90];
color1_alpha = 0.9;
color2 = [0.99,0.99,0.99];
color2_alpha = 0.8;

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

module ldef(rot_around_center=0){
  translate([0,-b623_vgroove_small_r,0])
    rotate([0,0,rot_around_center]) // Rotate around bearing center
    translate([0,b623_vgroove_small_r,0])
    if(stls && !twod){
      rotate([-90,0,0])
        import("../stl/horizontal_line_deflector.stl");
    } else {
      horizontal_line_deflector(twod=twod);
    }
}


//placed_lineroller_D();
module placed_lineroller_D(angs=[180-30-2,180,180+30+2]){
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
    translate([b623_vgroove_small_r+2*Spool_height+1+GT2_gear_height,
               -Sidelength/sqrt(3)-24, 0])
      rotate([0,0,180])
      ldef(-10);
    translate([-b623_vgroove_small_r+Spool_height+GT2_gear_height,
               -Sidelength/sqrt(3)-49, 0])
      rotate([0,0,180])
      ldef(10);

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
        import("../stl/spool_gear_GT2.stl");
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
        1 + Spool_height + GT2_gear_height/2,
        Sep_disc_radius+Gap_between_sandwich_and_plate])
      rotate([90,0,0])
      sandwich_D();
  }
  // -3.5 gotten from visual inspection. 130 random.
  translate([130,-3.5 + Sandwich_ABC_width/2,0])
    render_donkey_and_bracket();
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

  translate([83,-12.1 + Sandwich_ABC_width/2,0])
    belt_roller_with_bearings();

}


module render_donkey_and_bracket(){
  rotate([0,0,90]){
    if(stls && !twod){
      color([0.15,0.15,0.15],0.8)
        to_be_mounted();
    }
    color(color2, color2_alpha)
      if(stls && !twod){
        import("../stl/donkey_bracket.stl");
      } else if(twod) {
        donkey_bracket(twod=true);
      } else {
        donkey_bracket();
      }
  }
}

//sandwich_and_donkey_ABC();
module sandwich_and_donkey_ABC(){
  if(!twod)
    translate([0,
        Sandwich_ABC_width/2,
        Sep_disc_radius+Gap_between_sandwich_and_plate])
      rotate([90,0,0])
      sandwich_ABC();
  // -3.5 gotten from visual inspection. 130 random.
  translate([130,-3.5 + Sandwich_ABC_width/2,0])
    render_donkey_and_bracket();
  translate([83,-12.1 + Sandwich_ABC_width/2,0])
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
  sandwich_and_donkey_ABC();
  translate([-90,-1-Spool_height/2 + Sandwich_ABC_width/2,0])
    line_roller_double_with_bearings();
}

//sandwich_and_donkey_B();
module sandwich_and_donkey_B(){
  sandwich_and_donkey_ABC();
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

if(mounted_in_ceiling && !twod){
  translate([0,0,43+ANCHOR_D_Z])
    rotate([180,0,0])
      full_winch();
} else {
  full_winch();
}
module full_winch(){
  sep = abc_sep;
  y = abcspool_y;

  translate([0,y,0])
    rotate([0,0,-90])
    sandwich_and_donkey_A();

  translate([-sep,y,0])
    rotate([0,0,90])
    sandwich_and_donkey_B();

  translate([sep,y,0])
    rotate([0,0,90])
    sandwich_and_donkey_C();

  translate([GT2_gear_height/2+Spool_height/2,dspool_y,0])
    rotate([0,0,90])
    sandwich_and_donkey_D();

  placed_lineroller_D();

  cx = 500;
  cy = 660;
  mvy = Yshift_top_plate;
  top_plate(cx, cy, mvy);
}

if(mover && !twod)
  translate([0,0,lift_mover_z])
  mover();
module mover(){
  beam_length = 400;
  for(k=[0,120,240])
    rotate([180,0,k+180]){
      translate([-beam_length/2,-Sidelength/sqrt(12)-sqrt(3), 0]){
        cube([beam_length, Beam_width, Beam_width]);
        translate([0.69*beam_length, Beam_width/2+7,Beam_width/2-5])
          color(color1, color1_alpha)
            if(stls){
              import("../stl/beam_slider_D.stl");
            } else {
              beam_slider_D();
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
              cube([shorter_beam,Beam_width, Beam_width]);
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
  color("yellow")
  for(k=[0,120,240])
    rotate([0,0,k])
      translate([0,Sidelength/sqrt(3),lift_mover_z])
        cylinder(r=1.9, h=ANCHOR_D_Z-lift_mover_z);
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

//lr();
module lr(){
  ay = ANCHOR_A_Y - 10;
  color(color1, color1_alpha)
    //difference(){
      if(stls){
        rotate([0,-90,0])
        import("../stl/line_roller_anchor.stl");
      } else {
        line_roller_anchor();
      }
    //  translate([-25,-50,-1])
    //    cube(50);
    //}
    color("yellow")
      translate([Bearing_0_x+Move_tower+b623_vgroove_small_r/sqrt(2),
                 0,
                 Higher_bearing_z + b623_vgroove_small_r/sqrt(2)])
      rotate([0,-90+atan(ANCHOR_D_Z/ay),0])
      cylinder(r = 0.75, h = sqrt(ay*ay + ANCHOR_D_Z*ANCHOR_D_Z));


    between_bearings_x = Bearing_0_x - Bearing_1_x;
    echo(between_bearings_x);
    between_bearings_z = Higher_bearing_z - Lower_bearing_z;
    echo(between_bearings_z);
    ang_b0_b1 = atan(between_bearings_z/between_bearings_x);
    echo(ang_b0_b1);
    between_action_points_x = ANCHOR_A_Y-Sidelength/sqrt(9);
    ang_action = atan(between_action_points_z/between_action_points_x);
    echo(ang_action);

    for(tr = [[[Bearing_0_x+Move_tower, 0, Higher_bearing_z], [-ang_b0_b1+2, 90, 0], true],
              [[Bearing_1_x+Move_tower, 0, Lower_bearing_z], [-103, 60, 0], true],
              [[Bearing_1_x+Move_tower, 0, Higher_bearing_z], [180-18, 276, 0], false]])
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
      translate([Bearing_1_x+Move_tower-4, 0, Higher_bearing_z+2])
      rotate([0,0,180])
      rotate_extrude(angle=297)
        translate([3.1,0])
          circle(r=0.75);
    translate([Bearing_1_x+Move_tower-4-3.1, 0, Higher_bearing_z+2])
    color("yellow")
    rotate([-90,0,0])
    cylinder(r=0.75, h=Sidelength/2);
    translate([Bearing_1_x+Move_tower-4-1.1, 0, Higher_bearing_z+2])
    color("yellow")
    rotate([-90,0,0])
    cylinder(r=0.75, h=3);
    // Within lineroller_anchor
    line_from_to([Bearing_1_x+Move_tower + sin(ang_b0_b1)*b623_vgroove_small_r, 0,
                    Lower_bearing_z - cos(ang_b0_b1)*b623_vgroove_small_r],
                 [Bearing_0_x+Move_tower + sin(ang_b0_b1)*b623_vgroove_small_r, 0,
                    Higher_bearing_z - cos(ang_b0_b1)*b623_vgroove_small_r], r=0.75, $fn=6);
    // From lower bearing to effector
    line_from_to([Bearing_1_x+Move_tower-sin(ang_action)*b623_vgroove_small_r, 0,
                    Lower_bearing_z-cos(ang_action)*b623_vgroove_small_r],
                 [Bearing_1_x+Move_tower-sin(ang_action)*b623_vgroove_small_r
                   -between_action_points_x, 0,
                   Lower_bearing_z-cos(ang_action)*b623_vgroove_small_r
                   +between_action_points_z], r=0.75, $fn=6);
    // From effector to higher bearing
    line_from_to([Bearing_1_x+Move_tower+sin(ang_action)*b623_vgroove_small_r, 0,
                    Higher_bearing_z + cos(ang_action)*b623_vgroove_small_r],
                 [Bearing_1_x+Move_tower+sin(ang_action)*b623_vgroove_small_r
                   -between_action_points_x, 0,
                    Higher_bearing_z + cos(ang_action)*b623_vgroove_small_r
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
  translate([-27/2, -Ext_sidelength/2, -8])
    cube([50,Ext_sidelength, 8]);
  translate([Bearing_1_x+Move_tower-4-3.1,0,Higher_bearing_z+2])
    color("red")
    sphere(r=4);
}

if(!twod)
ceiling_unit_internal_lines_v4();
module ceiling_unit_internal_lines_v4(){
  hz = Gap_between_sandwich_and_plate+Sep_disc_radius-Spool_r;
  bd0y = dspool_y-93;
  bd1x = Spool_height + GT2_gear_height;
  bd2x = 1+ 2*Spool_height + GT2_gear_height;
  bd1y = dspool_y-136;
  bd2y = dspool_y-118;
  dyl = 100;
  // Dlines
  line_from_to([0,dspool_y,hz],
               [0,bd0y,hz]);
  line_from_to([0,bd0y,hz+b623_vgroove_small_r],
               [0,bd0y-0.1,hz+b623_vgroove_small_r+dyl]);
  line_from_to([bd1x, dspool_y, hz],
               [bd1x, bd1y, hz]);
  line_from_to([bd1x-2*b623_vgroove_small_r, bd1y, hz],
               [sin(120)*bd0y, cos(120)*bd0y, hz]);
  line_from_to([sin(120)*bd0y, cos(120)*bd0y,hz+b623_vgroove_small_r],
               [sin(120)*bd0y, cos(120)*bd0y-0.1,hz+b623_vgroove_small_r+dyl]);
  line_from_to([bd2x, dspool_y, hz],
               [bd2x, bd2y, hz]);
  line_from_to([bd2x+2*b623_vgroove_small_r, bd2y, hz],
               [sin(-120)*bd0y, cos(-120)*bd0y, hz]);
  line_from_to([sin(-120)*bd0y, cos(-120)*bd0y,hz+b623_vgroove_small_r],
               [sin(-120)*bd0y, cos(-120)*bd0y-0.1,hz+b623_vgroove_small_r+dyl]);
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


