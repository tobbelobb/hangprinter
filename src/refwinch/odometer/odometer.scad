// RefWinch odometer and its MA600A encoder-board placement model.
//
// The board model is deliberately an envelope model for mechanical planning,
// not a replacement for the KiCad source in ma600a_encoder_breakout/kicad/.
// Board coordinates follow the release drawing: 28 x 12 mm, with the sensor
// center 4 mm from the short tip and 6 mm from the lower edge.

include <../../lib/parameters.scad>
include <../../lib/util.scad>
use <../../lib/encoder_LPD3806.scad>

LPD3806_collet_h = 5;
LPD3806_collet_d = 20;

/* [Odometer] */

odometer_part = "Frame"; // [Assembly, Frame, Coupler]

// Roller width along the shaft (X).
odometer_roller_width = 15;
// Clearance from the roller end face to the inner face of the wall.
odometer_roller_wall_margin = 1;

/* [Hidden] */

// Shared world datums: encoder on +X, toward the winch CLN17 board.
// Rollers and eyelet bores share X=0; the wall is half a roller width + margin away.
odometer_wall_inner_x = odometer_roller_width/2 + odometer_roller_wall_margin;
odometer_frame_outer_x = odometer_wall_inner_x + b623_width + 1;
odometer_encoder_shift_x = odometer_wall_inner_x - (5/2 + 0.1);
odometer_axis_z = (25+2)/2 - 19 + 50 - (b608_outer_dia+6)/2;

module encoder_roller_coupler(){
  $fn=64;
  inner_tol = 0.1;
  outer_tol = 0.2;
  difference() {
    cylinder(d=10.5+outer_tol, h=11);
    translate([0,0,-1])
      difference() {
        cylinder(d=6+inner_tol, h=13);
        translate([-3, 2.5+inner_tol, 1+2.5])
          cube([6, 6, 14]);
      }
  }
}


module odometer_encoder_hardware() {
  translate([46.6 - LPD3806_collet_h + odometer_encoder_shift_x,0,odometer_axis_z])
    rotate([0,-90,0])
    rotate([0,0,75])
    encoder_LPD3806();
}

module odometer_roller(od, id, th) {
  rotate([0, 90, 0]) {
    color("darkgray")
      difference() {
        cylinder(d=od, h=th, center=true);
        cylinder(d=id, h=th+2, center=true);
      }
  }
}

// Current two-roller odometer. The output is normalized to its own origin:
// roller axes run along X, the upper roller is at Y=0, and Z=0 is the bottom
// of the tower. The board is placed on the +X side with its sensor aligned
// to the upper roller center.
module odometer(show_rollers=false,
                show_frame=true,
                show_lpd3806=false){
  $fn = 64;
  outer_diameter = 25;
  inner_diameter = 10.5;
  roller_thickness = odometer_roller_width;
  roller_wall_margin = odometer_roller_wall_margin;
  eyelet_support_width = roller_thickness + 2*roller_wall_margin + 2;
  assert(roller_thickness > 0, "Roller width must be positive");
  assert(roller_wall_margin >= 0, "Roller wall margin must be nonnegative");
  line_diameter = 2;
  roller_gap = 1;
  line_entry_z = 19;
  low_roller_z = outer_diameter/2 + 1;
  hypot_dist = outer_diameter + roller_gap;
  roller_tower_height = line_entry_z + outer_diameter;
  roller_tower_thickness2 = b623_width + 1;
  bearing_tower_corner_radius = 2;
  shift_entry_corner = [0,-10];
  shift_exit_corner = [0,-14];
  winch_bearing_tower_height = 50;
  winch_bearing_tower_wall_thickness = 3;
  roller_datum_z = winch_bearing_tower_height
                 - (b608_outer_dia + 2*winch_bearing_tower_wall_thickness)/2;
  high_roller_z = (outer_diameter+line_diameter)/2 - line_entry_z + roller_datum_z;
  a_diff = high_roller_z - low_roller_z;
  lower_roller_y = sqrt(hypot_dist^2 - a_diff^2);
  low_roller_y = lower_roller_y;
  roller_tower_depth = outer_diameter+lower_roller_y;
  extra_rot = -90+60;
  roller_clearance_radius = (outer_diameter + 1.5)/2;
  entry_support_wall = 2;
  entry_support_y = low_roller_y + roller_clearance_radius;
  entry_support_back_y = entry_support_y + entry_support_wall;

  if (show_rollers) {
    translate([0, 0, high_roller_z]){
      odometer_roller(outer_diameter, inner_diameter, roller_thickness);
    }
    translate([0,low_roller_y, low_roller_z])
      odometer_roller(outer_diameter, inner_diameter, roller_thickness);
  }
  if(show_frame) union() {
  // Coplanar with winch bottom. Open center keeps the lower roller (whose
  // bottom is z=1) clear of this 1.6 mm floor.
  difference() {
    translate([-odometer_frame_outer_x,-outer_diameter/2+2,0])
      cube([odometer_frame_outer_x+odometer_wall_inner_x,
            entry_support_back_y-(-outer_diameter/2+2),1.6]);
    translate([-odometer_wall_inner_x-0.4,low_roller_y-13,-0.1])
      cube([2*odometer_wall_inner_x+0.5,26,2]);
  }

  //for(k=[0,1]) mirror([k,0,0])
    translate([odometer_wall_inner_x, 0, 0]) {
      difference() {
        rotate([90,0,90])
        linear_extrude(height=roller_tower_thickness2)
          difference(){
            hull(){
              translate([-outer_diameter/2,0])
              square([roller_tower_depth, 1]);
              translate([-outer_diameter/2+roller_tower_depth-bearing_tower_corner_radius+shift_entry_corner[0],roller_tower_height-bearing_tower_corner_radius+shift_entry_corner[1]])
                circle(r=bearing_tower_corner_radius);
              translate([0,high_roller_z]){
                rotate([0,0,extra_rot]) translate([15+4,0,0])
                  circle(r=bearing_tower_corner_radius);
                rotate([0,0,120+extra_rot]) translate([15+4,1,0])
                  circle(r=bearing_tower_corner_radius);
                rotate([0,0,240+extra_rot]) translate([15+4,-2.5,0])
                  circle(r=bearing_tower_corner_radius);
              }
              translate([0,high_roller_z+(LPD3806_collet_d+1)/2*sqrt(2)+1.85])
                circle(r=bearing_tower_corner_radius);
            }
            translate([0,high_roller_z])
              for(ang=[0,120,240]) rotate([0,0,ang+extra_rot]) translate([15,0,0])
              circle(d=3.2);
          }
          translate([0,-10.5,high_roller_z - outer_diameter/2 - 1])
          rotate([90,0,0])
          translate([-odometer_wall_inner_x,0,0])
          cylinder(d=Eyelet_flange_diameter+1, h=30);

      translate([-0.5,0,0])
      rotate([90,0,90])
        linear_extrude(height=3+1)
          translate([0,high_roller_z])
            for(ang=[0,120,240]) rotate([0,0,ang+extra_rot]) translate([15,0,0])
            circle(d=5.6);

      translate([-1, low_roller_y, low_roller_z])
        rotate([0,90,0])
        cylinder(d=3.1, h=roller_tower_thickness2+2);
      translate([roller_tower_thickness2+1, 0,high_roller_z])
        rotate([0,-90,0])
        rotate([0,0,-90])
        teardrop(r=(LPD3806_collet_d+1)/2, h=roller_tower_thickness2+2);
    }

  }
  // Line entry
  entry_exit_tube_length_entry = 8;
  entry_exit_tube_length_exit = 13;
  entry_y = low_roller_y + outer_diameter/2-entry_exit_tube_length_entry;
  entry_z = low_roller_z + outer_diameter/2 + line_diameter/2;
  exit_z = high_roller_z - (outer_diameter/2 + line_diameter/2);
  holder_height = Eyelet_diameter + 5;
  exit_support_drop = min(eyelet_support_width, exit_z-holder_height/2);
  difference() {
    // Print upright (Z=0 on the bed). The underside is a 45-degree tangent
    // above the roller clearance circle, rooted in a vertical rear wall.
    // Extrude the Y/Z profile along X to support the full holder width.
    translate([-eyelet_support_width/2,0,0])
      rotate([90,0,90])
      linear_extrude(height=eyelet_support_width)
      polygon([
        [entry_y, low_roller_z + sqrt(2)*roller_clearance_radius - (entry_y-low_roller_y)],
        [entry_support_y, low_roller_z + (sqrt(2)-1)*roller_clearance_radius],
        [entry_support_y, 0],
        [entry_support_back_y, 0],
        [entry_support_back_y, entry_z + holder_height/2],
        [entry_y, entry_z + holder_height/2]
      ]);
    translate([0,entry_y-1,entry_z])
      rotate([-90,0,0])
      rotate([0,0,180])
      teardrop(r=Eyelet_diameter/2, h=entry_support_back_y-entry_y+2);
  }
  // Line exit
  difference() {
    // A continuous 45-degree gusset reaches the floor instead of ending
    // in mid-air. Clip its toe to Z=0 for wider rollers or larger margins.
    translate([0,2-outer_diameter/2+entry_exit_tube_length_exit,0])
      rotate([90,0,0])
      linear_extrude(height=entry_exit_tube_length_exit)
      polygon([
        [-eyelet_support_width/2, exit_z-holder_height/2],
        [-eyelet_support_width/2, 0],
        [eyelet_support_width/2, 0],
        [eyelet_support_width/2, exit_z+holder_height/2],
        [-eyelet_support_width/2, exit_z+holder_height/2]
      ]);
    translate([0, 0, high_roller_z - outer_diameter/2 - line_diameter/2])
      rotate([90,0,0])
      translate([0,0,-15])
      teardrop(r=Eyelet_diameter/2, h=30);
    translate([0,0, high_roller_z])
      scale((outer_diameter + 1.5)/outer_diameter)
      rotate([0,90,0])
      cylinder(d=outer_diameter, h=eyelet_support_width, center=true);
  }
  difference(){
    translate([7+odometer_encoder_shift_x,-entry_exit_tube_length_exit,0])
      cube([34.6,21,13.8]);
   translate([50+7.59+odometer_encoder_shift_x,0,odometer_axis_z])
     rotate([0,-90,0])
     cylinder(d=38.2+0.7,h=50);
  }
  difference(){
    translate([odometer_wall_inner_x-1,low_roller_y,low_roller_z])
    rotate([0,90,0])
    difference() {
      cylinder(d1=5.7, d2=7.5, h=3);
      translate([0,0,-1])
        cylinder(d=3.1, h=5);
    }
  }
  }
  if (show_lpd3806)
    odometer_encoder_hardware();
}

// Importable production outputs exclude all purchased and moving parts.
module odometer_frame() {
  odometer(show_rollers=false,
           show_lpd3806=false);
}

if(odometer_part == "Assembly") odometer();
else if(odometer_part == "Frame") odometer_frame();
else if(odometer_part == "Coupler") encoder_roller_coupler();
