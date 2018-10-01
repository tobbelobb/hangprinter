include <parameters.scad>
use <motor_bracket.scad>
use <motor_bracket_2d.scad>
use <motor_gear.scad>
use <spool.scad>
use <spool_gear.scad>
use <spool_core.scad>
use <lineroller_D.scad>
use <lineroller_anchor.scad>
use <lineroller_ABC_winch.scad>
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
module top_plate(){
  if(!twod){
    translate([-(Ext_sidelength + Additional_added_plate_side_length)/2,
               -(Ext_sidelength + Additional_added_plate_side_length)/2+Yshift_top_plate,
               -12])
      cube([Ext_sidelength + Additional_added_plate_side_length,
            Ext_sidelength + Additional_added_plate_side_length, 12]);
  }
}

//placed_lineroller_D();
module placed_lineroller_D(angs=[-63,60,3.5]){
  center_it = -2.5;
  three = [0,120,240];
  for(k=[0:2])
    rotate([0,0,-30+three[k]])
      translate([-Sidelength/sqrt(3),0,0])
        rotate([0,0,angs[k]])
          translate([center_it,0,0])
            if(stls && !twod){
              import("../stl/lineroller_D.stl");
            } else {
              lineroller_D(twod=twod);
            }
}

//translate([0,0,Gap_between_sandwich_and_plate])
//sandwich();
module sandwich(){
  translate([0,0,Spool_height + 0.1]){
    color(color2, color2_alpha)
      if(stls){
        import("../stl/spool_gear_GT2.stl");
      } else {
        spool_gear();
      }
    color(color1, color1_alpha)
      translate([0,0,GT2_gear_height+Spool_height+1+0.1])
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
}

module belt_roller_with_bearings(){
  //if(stls)
  //  import("../stl/belt_roller.stl");
  //else
    belt_roller();
  for(rot=[90,-90])
    translate([0,0,Belt_roller_bearing_center_z])
      rotate([rot,0,0])
      translate([0,0,0.1])
      b623();
}

!abc_sandwich_and_donkey();
module abc_sandwich_and_donkey(){
  if(!twod)
    translate([0,0,Sep_disc_radius+Gap_between_sandwich_and_plate])
      rotate([90,0,0])
      sandwich();
  translate([120,-3.5,0]) // -3.5 gotten from visual inspection. 120 random.
  rotate([0,0,90]){
    color([0.15,0.15,0.15],0.8)
      to_be_mounted();
    color(color2, color2_alpha)
      donkey_bracket();
  }
  translate([71,-12.1,0])
    belt_roller_with_bearings();
}

//abc_winch();
module abc_winch(with_motor=true,dist=160, motor_a = 280, clockwise=1, letter="A"){
  translate([dist,clockwise*Spool_r,0])
    color(color2, color2_alpha)
    if(stls && !twod){
      import("../stl/lineroller_ABC_winch.stl");
    } else {
      lineroller_ABC_winch(the_wall=false, with_base=true, twod=twod);
    }
  abc_sandwich_and_donkey(with_motor=with_motor,l=[dist+12],motor_a=motor_a-clockwise*_motor_ang, angs=[90,0,0], clockwise=clockwise, letter=letter);
}

if(mounted_in_ceiling && !twod){
  translate([0,0,43+ANCHOR_D_Z])
    rotate([180,0,0])
      full_winch();
} else {
  full_winch();
}
module full_winch(){
  // D
  edg = 10;
  //translate([-Ext_sidelength/2+edg,-Ext_sidelength/2+55,0])
  translate([-Ext_sidelength/2+Spool_outer_radius,
             -Ext_sidelength/2+Yshift_top_plate+Spool_outer_radius,0])
    abc_sandwich_and_donkey();
  // A
  translate([-136,-7,0])
    rotate([0,0,90])
      abc_winch(letter="A");

  // B
  translate([-17,-140,0])
    rotate([0,0,-30])
      abc_winch(clockwise=-1, motor_a=-99, letter="B");

  // C
  translate([98,151,0])
    rotate([0,0,180+30])
      abc_winch(letter="C");

  color(color1, color1_alpha)
    placed_lineroller_D();

  color(color0, color0_alpha)
    top_plate();
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
        import("../stl/lineroller_anchor.stl");
      } else {
        lineroller_anchor();
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
