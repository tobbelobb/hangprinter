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
// Overhang measured from vertical, with the frame printed upright.
odometer_guide_overhang = 45; // [45:1:55]

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
odometer_support_inner_y = odometer_roller_diameter/2 + 0.75;
odometer_support_outer_y = odometer_support_inner_y + 2;
// Export the footprint datum for the conventional winch's connecting web.
function odometer_base_front_y() = odometer_axis_y - odometer_support_outer_y;

// Exact six-hole pattern from encoder_LPD3806(), oriented with a pair at the top.
function odometer_encoder_holes() = [for (a=[0,120,240], k=[-1,1])
  [14*sin(a) + k*3.75*cos(a), 14*cos(a) - k*3.75*sin(a)]];

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
  roller_thickness = odometer_roller_width;
  eyelet_support_width = roller_thickness + 2*odometer_roller_wall_margin + 2;
  low_z = odometer_low_axis_z;
  high_z = odometer_axis_z;
  line_z = (low_z + high_z)/2;
  wall_thickness = b623_width + 1;
  clearance_r = outer_diameter/2 + odometer_guide_roller_clearance;
  inner_y = odometer_support_inner_y;
  outer_y = odometer_support_outer_y;
  holder_height = Eyelet_diameter + 5;
  guide_outer_d = odometer_guide_bore + 2*odometer_guide_wall;
  // The underside is tangent to the lower roller's clearance circle. At 45°
  // it rises 1 mm for every 1 mm toward the nip, continuously from each post.
  slope = 1/tan(odometer_guide_overhang);
  tangent_intercept = low_z + clearance_r*sqrt(1+slope*slope);
  function underside(y) = tangent_intercept - slope*y;
  guide_tip_y = 6;
  tip_top = high_z - sqrt(clearance_r*clearance_r-guide_tip_y*guide_tip_y);
  assert(roller_thickness > 0, "Roller width must be positive");
  assert(odometer_roller_wall_margin >= 0, "Roller wall margin must be nonnegative");
  assert(odometer_guide_bore > 2, "Guide bore must clear the nominal 2 mm line");
  assert(odometer_guide_wall >= 0.6, "Guide wall must be at least 0.6 mm");
  assert(odometer_guide_roller_clearance > 0, "Guide must clear both rollers");
  assert(odometer_guide_overhang >= 45 && odometer_guide_overhang <= 55,
         "Guide overhang must be between 45 and 55 degrees from vertical");
  assert(tip_top - underside(guide_tip_y) >= 1.6, "Guide tip is too thin");
  assert(inner_y > clearance_r, "Guide posts must clear the lower roller");

  module yz_profile(width) {
    translate([-width/2,0,0]) rotate([90,0,90])
      linear_extrude(height=width) children();
  }

  module line_guide(side) {
    translate([0,odometer_axis_y,0]) scale([1,side,1])
      difference() {
        union() {
          // Full-width post and 45° shoulder support the eyelet socket.
          yz_profile(eyelet_support_width)
            polygon([[inner_y-4,underside(inner_y-4)],
                     [inner_y,underside(inner_y)], [inner_y,0], [outer_y,0],
                     [outer_y,line_z+holder_height/2],
                     [inner_y-4,line_z+holder_height/2]]);
          // Narrow guide nose shares the shoulder's sloping underside.
          yz_profile(guide_outer_d)
            polygon([[guide_tip_y,underside(guide_tip_y)],
                     [inner_y+1,underside(inner_y+1)],
                     [inner_y+1,line_z+guide_outer_d/2],
                     [guide_tip_y,line_z+guide_outer_d/2]]);
        }
        // Teardrop roofs keep the horizontal passage ceilings at 45° too.
        translate([0,outer_y+1,line_z]) rotate([90,0,0])
          teardrop(r=odometer_guide_bore/2,h=outer_y-guide_tip_y+2);
        translate([0,outer_y+1,line_z]) rotate([90,0,0])
          teardrop(r=Eyelet_diameter/2,h=outer_y-inner_y+2);
        translate([0,inner_y-1,line_z]) rotate([90,0,0])
          linear_extrude(height=1,scale=odometer_guide_bore/Eyelet_diameter)
            teardrop_2d(r=Eyelet_diameter/2);
        // Only the upper surface is scalloped. Cutting the lower surface with
        // a circle would reintroduce steep, unsupported overhangs near the nip.
        translate([0,0,high_z]) rotate([0,90,0])
          cylinder(r=clearance_r,h=eyelet_support_width+2,center=true);
      }
  }

  module screw_access() {
    for (p=odometer_encoder_holes()) {
      // Apply these cuts after all supports are united, so none can block a
      // screw head or the straight driver approach from the roller side.
      translate([-eyelet_support_width/2-1,odometer_axis_y+p[0],high_z+p[1]])
        rotate([90,0,90])
          teardrop(r=5.6/2,h=eyelet_support_width/2+1+odometer_wall_inner_x+3.5);
      translate([odometer_wall_inner_x-1,odometer_axis_y+p[0],high_z+p[1]])
        rotate([90,0,90]) teardrop(r=3.2/2,h=wall_thickness+2);
    }
  }

  if (show_rollers)
    for (z=[low_z,high_z]) translate([0,odometer_axis_y,z])
      odometer_roller(outer_diameter,10.5,roller_thickness);

  if (show_frame) difference() {
    union() {
      // Symmetric foot, with running clearance beneath the lower roller.
      difference() {
        translate([-odometer_frame_outer_x,odometer_base_front_y(),0])
          cube([odometer_frame_outer_x+odometer_wall_inner_x,2*outer_y,1.6]);
        translate([-odometer_wall_inner_x-0.4,odometer_axis_y-13,-0.1])
          cube([2*odometer_wall_inner_x+0.5,26,2]);
      }
      translate([odometer_wall_inner_x,odometer_axis_y,0])
        rotate([90,0,90]) linear_extrude(height=wall_thickness)
          hull() {
            translate([-outer_y,0]) square([2*outer_y,1]);
            translate([0,high_z]) circle(r=20);
          }
      for (side=[-1,1]) line_guide(side);
      // Encoder cradle follows the same centerline as the symmetric wall.
      difference() {
        translate([7+odometer_encoder_shift_x,odometer_axis_y-10.5,0])
          cube([34.6,21,high_z-16.7]);
        translate([50+7.59+odometer_encoder_shift_x,odometer_axis_y,high_z])
          rotate([0,-90,0]) cylinder(d=38.2+0.7,h=50);
      }
      translate([odometer_wall_inner_x-1,odometer_axis_y,low_z])
        rotate([0,90,0]) cylinder(d1=5.7,d2=7.5,h=3);
    }
    screw_access();
    translate([odometer_wall_inner_x-2,odometer_axis_y,low_z])
      rotate([90,0,90]) teardrop(r=3.1/2,h=wall_thickness+4);
    translate([odometer_wall_inner_x-1,odometer_axis_y,high_z])
      rotate([90,0,90]) teardrop(r=(LPD3806_collet_d+1)/2,h=wall_thickness+2);
  }
  if (show_lpd3806) odometer_encoder_hardware();
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
