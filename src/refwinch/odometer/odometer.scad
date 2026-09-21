// RefWinch two-roller odometer and LPD3806 encoder placement model.

include <../../lib/parameters.scad>
include <../../lib/util.scad>
use <../../lib/encoder_LPD3806.scad>

LPD3806_collet_h = 5;
LPD3806_collet_d = 20;

/* [Odometer] */

odometer_part = "Assembly"; // [Assembly, Frame, Lower slider, Lower bearing spacer, Coupler, Spacer]

// Roller width along the shaft (X).
odometer_roller_width = 15;
// Clearance from the roller end face to the inner face of the wall.
odometer_roller_wall_margin = 1;

// Preview the lower shaft position. The frame and sliders do not change shape.
odometer_roller_gap = 0.5; // [0:0.1:5]
// Sliding fit per side in Y; adjust after a small fit print.
odometer_slide_clearance = 0.2;
// Compression spring outside diameter; match the purchased springs.
odometer_spring_diameter = 5;
odometer_spring_radial_clearance = 0.2;
odometer_show_springs = true;
odometer_show_spring_envelopes = false;

// Passage through the printed guide noses; eyelet sockets remain at the ends.
odometer_guide_bore = 2.4;
odometer_guide_wall = 0.8;
odometer_guide_roller_clearance = 0.35;
// Overhang measured from vertical, with the frame printed upright.
odometer_guide_overhang = 45; // [45:1:55]

/* [Hidden] */

// Shared world datums: encoder on +X, toward the winch CLN17 board.
// Rollers and eyelet bores share X=0; the wall is half a roller width + margin away.
odometer_wall_thickness = max(b623_width+1,
                             odometer_spring_diameter+2*odometer_spring_radial_clearance+1.6);
odometer_wall_inner_x = odometer_roller_width/2 + odometer_roller_wall_margin;
odometer_frame_outer_x = odometer_wall_inner_x + odometer_wall_thickness;
odometer_encoder_shift_x = odometer_wall_inner_x - (5/2 + 0.1)
                           + odometer_wall_thickness-(b623_width+1);
odometer_roller_diameter = 25;
odometer_gap_max = 5;
// At the widest gap the roller still clears Z=0 by 1 mm.
odometer_low_axis_min_z = odometer_roller_diameter/2 + 1;
odometer_low_axis_max_z = odometer_low_axis_min_z + odometer_gap_max;
odometer_axis_z = odometer_low_axis_max_z + odometer_roller_diameter;
odometer_low_axis_z = odometer_low_axis_max_z - odometer_roller_gap;
// Preserve the Y position and the existing winch/base interface.
odometer_axis_y = sqrt(25.5^2 - 17^2);
odometer_slider_flange_inner = 0.25;
odometer_slider_flange_outer = odometer_slider_flange_inner + 2.4;
odometer_spring_free_length = 15;
odometer_spring_preload = 1;
odometer_slider_bottom_z = -3;
odometer_spring_axis_x = odometer_wall_inner_x + odometer_wall_thickness/2;
odometer_spring_seat_z = odometer_low_axis_max_z + odometer_slider_bottom_z
                         - (odometer_spring_free_length-odometer_spring_preload);
odometer_spring_well_top_z = odometer_low_axis_min_z + odometer_slider_bottom_z;
function odometer_spring_length(gap) = odometer_spring_free_length-odometer_spring_preload-gap;
odometer_support_inner_y = odometer_roller_diameter/2 + 0.75;
odometer_support_outer_y = odometer_support_inner_y + 2;
// Export the footprint datum for the conventional winch's connecting web.
function odometer_base_front_y() = odometer_axis_y - odometer_support_outer_y;

// Exact three-hole pattern from encoder_LPD3806()
function odometer_encoder_holes() = [for (a=[0,120,240])
  [15*sin(a), 15*cos(a)]];

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

// A pointed roof makes the guide slot printable upright. Matching slider
// shoulders stop at gap=0; its flat bottom stops at gap=5. Y alone has play.
module odometer_slider_profile(clearance=0) {
  polygon([[-4-clearance,-3], [4+clearance,-3],
           [4+clearance,1-clearance], [0,5], [-4-clearance,1-clearance]]);
}

// Local X=0 is the outside face of either wall, with +X pointing outward.
// The axle nut/washer retains the flange; the neck and bearing boss stand
// proud of the wall so tightening the axle does not clamp the moving frame.
module odometer_lower_slider() {
  $fn=64;
  wall_thickness = odometer_wall_thickness;
  difference() {
    union() {
      translate([-wall_thickness-0.25,0,0]) rotate([90,0,90])
        linear_extrude(height=wall_thickness+0.25+odometer_slider_flange_inner+0.1)
          odometer_slider_profile();
      translate([odometer_slider_flange_inner,0,0]) rotate([90,0,90])
        linear_extrude(height=odometer_slider_flange_outer-odometer_slider_flange_inner)
          polygon([[-6,-3],[6,-3],[6,1],[0,7],[-6,1]]);
      // Contacts the lower bearing's inner race, inside the roller bore.
      translate([-wall_thickness-odometer_roller_wall_margin,0,0])
        rotate([0,90,0]) cylinder(d=5.7,h=odometer_roller_wall_margin+0.1);
    }
    translate([-wall_thickness-odometer_roller_wall_margin-1,0,0])
      rotate([0,90,0]) cylinder(d=3.2,h=wall_thickness+odometer_roller_wall_margin+6);

  }
}

module odometer_lower_slider_print() {
  // Outer flat flange on the bed; the neck and inner-race boss point upward.
  rotate([0,90,0]) translate([-odometer_slider_flange_outer,0,0])
    odometer_lower_slider();
}

module odometer_lower_bearing_spacer() {
  $fn=64;
  assert(odometer_roller_width > 2*b623_width, "Lower bearings need room for the spacer");
  difference() {
    cylinder(d=5.7,h=odometer_roller_width-2*b623_width);
    translate([0,0,-0.1]) cylinder(d=3.2,h=odometer_roller_width-2*b623_width+0.2);
  }
}

// Illustrative coil only: wire size and turn count are not a spring rating.
// Mechanical clearance is checked using the full outside-diameter envelope.
module odometer_compression_spring(length) {
  wire = 0.4;
  turns = 7;
  radius = (odometer_spring_diameter-wire)/2;
  steps = 112;
  function point(i) = [radius*cos(360*turns*i/steps),
                       radius*sin(360*turns*i/steps),
                       wire/2+(length-wire)*i/steps];
  for (i=[0:steps-1]) hull() {
    translate(point(i)) sphere(d=wire,$fn=8);
    translate(point(i+1)) sphere(d=wire,$fn=8);
  }
}

module odometer_lower_hardware(gap=odometer_roller_gap) {
  low_z = odometer_low_axis_max_z-gap;
  for (side=[-1,1]) {
    color("steelblue")
      translate([side*odometer_frame_outer_x,odometer_axis_y,low_z])
        scale([side,1,1]) odometer_lower_slider();
    // Purchased 623 bearings at the ends of the lower roller.
    color("silver") translate([side*(odometer_roller_width/2-b623_width/2),odometer_axis_y,low_z])
      rotate([0,90,0]) difference() {
        cylinder(d=b623_outer_dia,h=b623_width,center=true,$fn=64);
        cylinder(d=3,h=b623_width+1,center=true,$fn=32);
      }
    color("silver")
      translate([side*(odometer_frame_outer_x+odometer_slider_flange_outer),odometer_axis_y,low_z])
        scale([side,1,1]) rotate([0,90,0]) {
          difference() {
            cylinder(d=7,h=0.5,$fn=48);
            translate([0,0,-0.1]) cylinder(d=3.2,h=0.7,$fn=32);
          }
          translate([0,0,0.5]) difference() {
            cylinder(d=6.35,h=2.4,$fn=6);
            translate([0,0,-0.1]) cylinder(d=3,h=2.6,$fn=32);
          }
        }
  }
  color("steelblue")
    translate([-(odometer_roller_width-2*b623_width)/2,odometer_axis_y,low_z])
      rotate([0,90,0]) odometer_lower_bearing_spacer();
  // 45 mm M3 axle/rod preview; the roller rotates on its bearings.
  color("silver") translate([0,odometer_axis_y,low_z]) rotate([0,90,0])
    cylinder(d=3,h=45,center=true,$fn=32);
  for (side=[-1,1])
    translate([side*odometer_spring_axis_x,odometer_axis_y,odometer_spring_seat_z]) {
      if (odometer_show_springs)
        color("silver") odometer_compression_spring(odometer_spring_length(gap));
      if (odometer_show_spring_envelopes)
        color([0.9,0.5,0.1,0.35])
          cylinder(d=odometer_spring_diameter,h=odometer_spring_length(gap),$fn=48);
    }

}

// Both roller axes run along X at the same Y. Z=0 remains the winch floor.
module odometer(show_rollers=true,
                show_frame=true,
                show_lpd3806=true,
                show_lower_hardware=true,
                gap=odometer_roller_gap){
  $fn = 96;
  outer_diameter = odometer_roller_diameter;
  roller_thickness = odometer_roller_width;
  eyelet_support_width = roller_thickness + 2*odometer_roller_wall_margin + 2;
  low_z = odometer_low_axis_max_z-gap;
  high_z = odometer_axis_z;
  // Fixed guide height follows the nominal 0.5 mm working gap, independent
  // of the preview position. Supports clear the highest lower-roller position.
  line_z = high_z-outer_diameter/2-0.25;
  wall_thickness = odometer_wall_thickness;
  clearance_r = outer_diameter/2 + odometer_guide_roller_clearance;
  inner_y = odometer_support_inner_y;
  outer_y = odometer_support_outer_y;
  holder_height = Eyelet_diameter + 5;
  guide_outer_d = odometer_guide_bore + 2*odometer_guide_wall;
  // The underside is tangent to the lower roller's clearance circle. At 45°
  // it rises 1 mm for every 1 mm toward the nip, continuously from each post.
  slope = 1/tan(odometer_guide_overhang);
  tangent_intercept = odometer_low_axis_max_z + clearance_r*sqrt(1+slope*slope);
  function underside(y) = tangent_intercept - slope*y;
  guide_tip_y = 6.5;
  tip_top = high_z - sqrt(clearance_r*clearance_r-guide_tip_y*guide_tip_y);
  assert(gap >= 0 && gap <= odometer_gap_max, "Roller gap must be within 0-5 mm");
  assert(odometer_slide_clearance > 0 && odometer_slide_clearance <= 0.4,
         "Slider clearance must be positive and at most 0.4 mm per side");
  assert(odometer_spring_seat_z >= 1.2, "Spring seat needs at least 1.2 mm of floor");
  assert(odometer_spring_diameter > 0, "Spring diameter must be positive");
  assert(odometer_wall_thickness >= odometer_spring_diameter+2*odometer_spring_radial_clearance+1.6,
         "Spring pockets need at least 0.8 mm cheek wall per side");
  assert(odometer_spring_radial_clearance > 0, "Spring well needs running clearance");
  assert(odometer_spring_length(0) == 14 && odometer_spring_length(5) == 9,
         "Spring seats must provide 1 mm preload and 5 mm travel");
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

  module lower_shaft_slots() {
    for (side=[-1,1])
      translate([side*odometer_wall_inner_x,odometer_axis_y,0]) scale([side,1,1])
        translate([-1,0,0]) rotate([90,0,90]) linear_extrude(height=wall_thickness+2)
          hull() {
            for (z=[odometer_low_axis_min_z,odometer_low_axis_max_z])
              translate([0,z]) odometer_slider_profile(odometer_slide_clearance);
          }
  }

  module spring_wells(cut=false) {
    bore = odometer_spring_diameter+2*odometer_spring_radial_clearance;
    for (side=[-1,1])
      translate([side*odometer_spring_axis_x,odometer_axis_y,0])
        if (cut) {
          // Flat floor is the lower seat datum. The bore opens into the slider
          // slot, so the spring can be inserted before installing the slider.
          translate([0,0,odometer_spring_seat_z])
            cylinder(d=bore,h=odometer_spring_well_top_z-odometer_spring_seat_z+0.1);
        } else {
          // Vertical cup walls print directly from the bed, without overhangs.
          cylinder(d=bore+2,h=odometer_spring_well_top_z);
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
          cube([2*odometer_frame_outer_x,2*outer_y,1.6]);
        translate([-odometer_wall_inner_x-0.4,odometer_axis_y-13,-0.1])
          cube([2*odometer_wall_inner_x+0.5,26,2]);
      }
      translate([odometer_wall_inner_x,odometer_axis_y,0])
        rotate([90,0,90]) linear_extrude(height=wall_thickness)
          hull() {
            translate([-outer_y,0]) square([2*outer_y,1]);
            translate([0,high_z]) circle(r=20);
          }
      // Opposite cheek supports the other end of the same sliding axle.
      translate([-odometer_frame_outer_x,odometer_axis_y-outer_y,0])
        cube([wall_thickness,2*outer_y,odometer_low_axis_max_z+8]);
      for (side=[-1,1]) line_guide(side);
      spring_wells();
      // Move the cradle rearward to leave the right slider, nut and springs
      // accessible. A bed-level web keeps the cradle part of the printed frame.
      cradle_start_x = odometer_frame_outer_x+11;
      cradle_end_x = 7+odometer_encoder_shift_x+34.6;
      translate([odometer_frame_outer_x-0.5,odometer_axis_y-10.5,0])
        cube([cradle_end_x-odometer_frame_outer_x+0.5,21,1.6]);
      difference() {
        translate([cradle_start_x,odometer_axis_y-10.5,0])
          cube([cradle_end_x-cradle_start_x,21,high_z-16.7]);
        translate([50+7.59+odometer_encoder_shift_x,odometer_axis_y,high_z])
          rotate([0,-90,0]) cylinder(d=38.2+0.7,h=50);
      }
    }
    screw_access();
    lower_shaft_slots();
    spring_wells(cut=true);
    translate([odometer_wall_inner_x-1,odometer_axis_y,high_z])
      rotate([90,0,90]) teardrop(r=(LPD3806_collet_d+1)/2,h=wall_thickness+2);
  }
  if (show_lpd3806) odometer_encoder_hardware();
  if (show_lower_hardware) odometer_lower_hardware(gap);
}

// Importable production outputs exclude all purchased and moving parts.
module odometer_frame() {
  odometer(show_rollers=false,
           show_lpd3806=false,
           show_lower_hardware=false);
}

if(odometer_part == "Assembly") odometer();
else if(odometer_part == "Frame") odometer_frame();
else if(odometer_part == "Lower slider") odometer_lower_slider_print();
else if(odometer_part == "Lower bearing spacer") odometer_lower_bearing_spacer();
else if(odometer_part == "Coupler") encoder_roller_coupler();
else if(odometer_part == "Spacer") spacer_inside_roller();
