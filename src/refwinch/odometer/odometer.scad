// RefWinch two-roller odometer and LPD3806 encoder placement model.

include <../../lib/parameters.scad>
include <../../lib/util.scad>
use <../../lib/encoder_LPD3806.scad>

LPD3806_collet_h = 5;
LPD3806_collet_d = 20;

/* [Odometer] */

odometer_part = "Assembly"; // [Assembly, Frame, Coupler, Spacer]

// Roller width along the shaft (X).
odometer_roller_width = 15;
// Clearance from the roller end face to the inner face of the wall.
odometer_roller_wall_margin = 1;

// Passage through the printed guide noses; eyelet sockets remain at the ends.
odometer_guide_bore = 2.4;
odometer_guide_wall = 0.8;
odometer_guide_roller_clearance = 0.35;

/* [Hidden] */

// Shared world datums: encoder on +X, toward the winch CLN17 board.
// Rollers and eyelet bores share X=0; the wall is half a roller width + margin away.
odometer_wall_inner_x = odometer_roller_width/2 + odometer_roller_wall_margin;
odometer_frame_outer_x = odometer_wall_inner_x + b623_width + 1;
odometer_encoder_shift_x = odometer_wall_inner_x - (5/2 + 0.1);
odometer_roller_diameter = 25;
odometer_roller_gap = 0.5;
odometer_low_axis_z = odometer_roller_diameter/2 + 1;
// Preserve the lower roller's position and the existing winch/base interface.
odometer_axis_y = sqrt(25.5^2 - 17^2);
odometer_axis_z = odometer_low_axis_z + odometer_roller_diameter + odometer_roller_gap;

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

module spacer_inside_roller(){
  $fn=64;
  inner_tol = 0.1;
  outer_tol = 0.2;
  difference() {
    cylinder(d=10.5+outer_tol, h=15.7 - 2*b623_width);
    translate([0,0,-1])
      difference() {
        cylinder(d=6+inner_tol, h=13);
      }
  }
}


module odometer_encoder_hardware() {
  translate([46.6 - LPD3806_collet_h + odometer_encoder_shift_x,odometer_axis_y,odometer_axis_z])
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

// Both roller axes run along X at the same Y. Z=0 remains the winch floor.
module odometer(show_rollers=true,
                show_frame=true,
                show_lpd3806=true){
  $fn = 96;
  outer_diameter = odometer_roller_diameter;
  inner_diameter = 10.5;
  roller_thickness = odometer_roller_width;
  eyelet_support_width = roller_thickness + 2*odometer_roller_wall_margin + 2;
  assert(roller_thickness > 0, "Roller width must be positive");
  assert(odometer_roller_wall_margin >= 0, "Roller wall margin must be nonnegative");
  assert(odometer_guide_bore > 2, "Guide bore must clear the nominal 2 mm line");
  assert(odometer_guide_wall >= 0.6, "Guide wall must be at least 0.6 mm");
  assert(odometer_guide_roller_clearance > 0, "Guide must clear both rollers");
  low_roller_z = odometer_low_axis_z;
  high_roller_z = odometer_axis_z;
  low_roller_y = odometer_axis_y;
  line_z = (low_roller_z + high_roller_z)/2;
  roller_tower_thickness2 = b623_width + 1;
  bearing_tower_corner_radius = 2;
  extra_rot = -30;
  roller_clearance_radius = outer_diameter/2 + odometer_guide_roller_clearance;
  support_inner_y = outer_diameter/2 + 0.75;
  support_outer_y = support_inner_y + 2;
  holder_height = Eyelet_diameter + 5;
  // Noses open toward each roller as they enter the squeeze zone. Stop where
  // 1.6 mm of height remains, avoiding fragile feather edges at the nip.
  guide_tip_half_height = 0.8;
  guide_tip_y = sqrt(roller_clearance_radius^2
                    - (line_z-low_roller_z-guide_tip_half_height)^2);
  guide_outer_d = odometer_guide_bore + 2*odometer_guide_wall;
  assert(guide_tip_y < support_inner_y, "Guide nose must reach past the support");

  module line_guide(side) {
    translate([0,odometer_axis_y,line_z])
      mirror([0,side < 0 ? 1 : 0,0])
      difference() {
        union() {
          // Full-width end post connects the guide and bearing wall to the foot.
          translate([-eyelet_support_width/2,support_inner_y,-line_z])
            cube([eyelet_support_width,support_outer_y-support_inner_y,
                  line_z+holder_height/2]);
          translate([-eyelet_support_width/2,support_inner_y-4,-holder_height/2])
            cube([eyelet_support_width,6,holder_height]);
          // A tubular nose continues from the eyelet socket toward the nip.
          translate([0,guide_tip_y,0]) rotate([-90,0,0])
            cylinder(d=guide_outer_d,h=support_inner_y-guide_tip_y+1);
        }
        translate([0,guide_tip_y-1,0]) rotate([-90,0,0])
          cylinder(d=odometer_guide_bore,h=support_outer_y-guide_tip_y+2);
        // Eyelet socket at the outer end, transitioning into the smaller bore.
        translate([0,support_inner_y-2,0]) rotate([-90,0,0])
          cylinder(d1=odometer_guide_bore,d2=Eyelet_diameter,h=1);
        translate([0,support_inner_y-1,0]) rotate([-90,0,0])
          cylinder(d=Eyelet_diameter,h=4);
        for (z=[low_roller_z, high_roller_z])
          translate([0,0,z-line_z]) rotate([0,90,0])
            cylinder(r=roller_clearance_radius,h=eyelet_support_width+2,center=true);
      }
  }

  if (show_rollers) {
    translate([0, odometer_axis_y, high_roller_z]){
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
            odometer_axis_y+support_outer_y-(-outer_diameter/2+2),1.6]);
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
                square([odometer_axis_y+support_outer_y+outer_diameter/2, 1]);
              translate([odometer_axis_y+support_outer_y-bearing_tower_corner_radius,
                         line_z+holder_height/2-bearing_tower_corner_radius])
                circle(r=bearing_tower_corner_radius);
              translate([odometer_axis_y,high_roller_z]){
                rotate([0,0,extra_rot]) translate([15+4,0,0])
                  circle(r=bearing_tower_corner_radius);
                rotate([0,0,120+extra_rot]) translate([15+4,1,0])
                  circle(r=bearing_tower_corner_radius);
                rotate([0,0,240+extra_rot]) translate([15+4,-2.5,0])
                  circle(r=bearing_tower_corner_radius);
              }
              translate([odometer_axis_y,high_roller_z+(LPD3806_collet_d+1)/2*sqrt(2)+1.85])
                circle(r=bearing_tower_corner_radius);
            }
            translate([odometer_axis_y,high_roller_z])
              for(ang=[0,120,240]) rotate([0,0,ang+extra_rot]) translate([15,0,0])
              circle(d=3.2);
          }
      translate([-0.5,0,0])
      rotate([90,0,90])
        linear_extrude(height=3+1)
          translate([odometer_axis_y,high_roller_z])
            for(ang=[0,120,240]) rotate([0,0,ang+extra_rot]) translate([15,0,0])
            circle(d=5.6);

      translate([-1, low_roller_y, low_roller_z])
        rotate([0,90,0])
        cylinder(d=3.1, h=roller_tower_thickness2+2);
      translate([roller_tower_thickness2+1, odometer_axis_y,high_roller_z])
        rotate([0,-90,0])
        rotate([0,0,-90])
        teardrop(r=(LPD3806_collet_d+1)/2, h=roller_tower_thickness2+2);
    }

  }
  for (side=[-1,1]) line_guide(side);
  difference(){
    translate([7+odometer_encoder_shift_x,odometer_axis_y-10.5,0])
      cube([34.6,21,odometer_axis_z-16.7]);
   translate([50+7.59+odometer_encoder_shift_x,odometer_axis_y,odometer_axis_z])
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
else if(odometer_part == "Spacer") spacer_inside_roller();
