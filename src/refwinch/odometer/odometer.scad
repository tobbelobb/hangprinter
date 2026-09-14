// RefWinch odometer and its MA600A encoder-board placement model.
//
// The board model is deliberately an envelope model for mechanical planning,
// not a replacement for the KiCad source in ma600a_encoder_breakout/kicad/.
// Board coordinates follow the release drawing: 28 x 12 mm, with the sensor
// center 4 mm from the short tip and 6 mm from the lower edge.

include <../../lib/parameters.scad>
include <../../lib/util.scad>

/* [Odometer] */

odometer_magnet_diameter = 6;
odometer_magnet_height = 2.5;
odometer_magnet_gap = 2; // Magnet face to package face; validate field on hardware.
odometer_part = "Assembly"; // [Assembly, Frame, Magnet carrier, Board cap, Drive hub, Encoder section]
odometer_shaft_clearance = 0.08;
odometer_magnet_clearance = 0.10;

// Shared datums for frame, hardware, standalone exports and the winch import.
function odometer_frame_outer_x() = 2.5 + 0.1 + b623_width + 1;
function odometer_axis_z() = (25+2)/2 - 19 + 50 - (b608_outer_dia+6)/2;
function odometer_lower_y() = sqrt(26*26-pow(odometer_axis_z()-13.5,2));
function odometer_carrier_entry_x() = -odometer_frame_outer_x()-1;
function odometer_shaft_end_x() = odometer_carrier_entry_x()-7.5;
function odometer_magnet_face_x() = odometer_shaft_end_x()-1.2-odometer_magnet_height;
function odometer_board_x() = odometer_magnet_face_x()-odometer_magnet_gap-0.8-0.5;
function odometer_shaft_length() = odometer_frame_outer_x()+0.9-odometer_shaft_end_x();

// Print shaft opening down. The 3 mm bore roof is the only small bridge.
// A concentric blind socket sets insertion depth; the slit ends before the
// magnet seat so tightening cannot directly squeeze the magnet pocket.
module odometer_magnet_carrier() {
  seat_z = 7.5+1.2;
  h = seat_z+odometer_magnet_height-0.3;
  assert(odometer_shaft_clearance >= 0 && odometer_shaft_clearance <= 0.2);
  assert(odometer_magnet_clearance >= 0 && odometer_magnet_clearance <= 0.2);
  difference() {
    union() {
      cylinder(d=10.6,h=h,$fn=80);
      translate([3,-3,0]) cube([7,6,6]);
    }
    translate([0,0,-0.1]) cylinder(d=3+odometer_shaft_clearance,h=7.6,$fn=64);
    translate([0,0,-0.01]) cylinder(d1=3.8,d2=3+odometer_shaft_clearance,h=0.5,$fn=64);
    translate([0,0,seat_z])
      cylinder(d=odometer_magnet_diameter+odometer_magnet_clearance,h=odometer_magnet_height+1,$fn=80);
    // Adhesive reservoir below the cylindrical locating land.
    translate([0,0,seat_z+0.25])
      cylinder(d=odometer_magnet_diameter+0.6,h=0.5,$fn=80);
    translate([0,-0.35,-0.1]) cube([11,0.7,7.1]);
    translate([6.5,-4,3]) rotate([-90,0,0]) cylinder(d=2.2,h=8,$fn=32);
    // Side-loading captive M2 nut; use brass hardware near the encoder.
    translate([6.5,-3.01,3]) rotate([-90,0,0]) cylinder(d=4.2/cos(30),h=1.6,$fn=6);
  }
}

// Bond this sleeve into the existing 10.5 mm roller bore, and bond its
// close-fitting 3 mm bore to the shaft. Bearing outer races remain in frame.
module odometer_drive_hub() {
  difference() {
    cylinder(d=10.4,h=5,$fn=80);
    translate([0,0,-0.1]) cylinder(d=3+odometer_shaft_clearance,h=5.2,$fn=64);
    for(z=[1,3.5]) translate([0,0,z]) difference() {
      cylinder(d=10.6,h=0.5,$fn=80);
      cylinder(d=10,h=0.5,$fn=80);
    }
  }
}

// Board inserts downwards with components facing +X. Rails contact only
// the outer 0.5 mm of the long edges; connector and test pads stay accessible.
module odometer_board_cradle() {
  bx=odometer_board_x();
  bottom=odometer_axis_z()-24;
  top=odometer_axis_z()+4;
  translate([bx-2.5,-8,0]) cube([2,16,top]);
  for(side=[-1,1]) {
    translate([bx-0.6,side < 0 ? -8 : 6.15,0]) cube([2.5,1.85,top]);
    translate([bx+0.65,side < 0 ? -6.2 : 5.5,bottom]) cube([1.25,0.8,28]);
    difference() {
      translate([bx-2.5,side*9-2,0]) cube([4.4,4,top]);
      translate([bx-0.3,side*9,top-8]) cylinder(d=1.7,h=9,$fn=32);
    }
  }
  translate([bx-0.6,-6.2,bottom-1.5]) cube([2.5,12.4,1.5]);
}

// Two M2 x 6 brass screws into 1.7 mm pilot holes. Cap has 0.15 mm
// clearance above PCB; the lower seat determines the sensing-center height.
module odometer_board_cap() {
  difference() {
    translate([-2.5,-11,0]) cube([4.4,22,2]);
    for(side=[-1,1]) translate([-0.3,side*9,-0.1]) cylinder(d=2.2,h=2.2,$fn=32);
    translate([-0.65,-6.2,-0.01]) cube([1.3,12.4,0.16]);
  }
}

module odometer_encoder_hardware(show_board=true, show_magnet=true, show_cap=true) {
  assert(odometer_magnet_gap >= 1, "Keep a positive magnet-to-package clearance");
  assert(odometer_carrier_entry_x() < -odometer_frame_outer_x()-0.5);
  if(show_cap) {
    color("orange") translate([odometer_board_x(),0,odometer_axis_z()+4]) odometer_board_cap();
    for(side=[-1,1]) color("goldenrod")
      translate([odometer_board_x()-0.3,side*9,odometer_axis_z()+6]) {
        translate([0,0,-6]) cylinder(d=2,h=6,$fn=24);
        cylinder(d=3.8,h=1.5,$fn=32);
      }
  }
  if(show_board)
    translate([odometer_board_x(),0,odometer_axis_z()-10])
      rotate([0,90,0]) ma600a_encoder_breakout_board();
  if(show_magnet) {
    color("orange") translate([odometer_carrier_entry_x(),0,odometer_axis_z()])
      rotate([0,-90,0]) odometer_magnet_carrier();
    color("goldenrod") translate([odometer_carrier_entry_x(),0,odometer_axis_z()])
      rotate([0,-90,0]) {
        translate([6.5,-5,3]) rotate([-90,0,0]) cylinder(d=2,h=8,$fn=24);
        translate([6.5,3,3]) rotate([-90,0,0]) cylinder(d=3.8,h=1.5,$fn=32);
        translate([6.5,-3,3]) rotate([-90,0,0]) difference() {
          cylinder(d=4/cos(30),h=1.6,$fn=6);
          cylinder(d=2,h=1.7,$fn=24);
        }
      }
    translate([odometer_magnet_face_x()+odometer_magnet_height/2,0,odometer_axis_z()])
      odometer_magnet(diameter=odometer_magnet_diameter,height=odometer_magnet_height);
    translate([(odometer_frame_outer_x()+0.9+odometer_shaft_end_x())/2,0,odometer_axis_z()])
      odometer_shaft_stub(length=odometer_shaft_length());
    color("orange") translate([-2.5,0,odometer_axis_z()]) rotate([0,90,0]) odometer_drive_hub();
  }
}

module odometer_encoder_section() {
  // Cut each material separately so the mating interfaces remain visible.
  module lower_half() {
    render(convexity=10) difference() {
      children();
      translate([-40,-40,odometer_axis_z()]) cube([80,80,40]);
    }
  }
  color("orange") lower_half()
    translate([odometer_carrier_entry_x(),0,odometer_axis_z()])
      rotate([0,-90,0]) odometer_magnet_carrier();
  color("silver") lower_half()
    translate([odometer_magnet_face_x()+odometer_magnet_height/2,0,odometer_axis_z()])
      odometer_magnet(diameter=odometer_magnet_diameter,height=odometer_magnet_height);
  color("dimgray") lower_half()
    translate([(odometer_frame_outer_x()+0.9+odometer_shaft_end_x())/2,0,odometer_axis_z()])
      odometer_shaft_stub(length=odometer_shaft_length());
  color("orange") lower_half()
    translate([-2.5,0,odometer_axis_z()]) rotate([0,90,0]) odometer_drive_hub();
  translate([odometer_board_x(),0,odometer_axis_z()-10]) rotate([0,90,0]) ma600a_encoder_breakout_board();
}

module ma600a_board_component(position, size, height, component_color="dimgray", board_thickness=1) {
  translate([position[0], position[1], board_thickness/2 + height/2])
    color(component_color)
    cube([size[0], size[1], height], center=true);
}

// Compact visual model of the released MA600A v0.3 board. The local origin
// is the board center, the top face is +Z, and the sensor is at [-10, 0].
// Rotate [0, 90, 0] to put the sensor face towards a wheel on +X.
module ma600a_encoder_breakout_board(show_components=true, show_keepout=false,
                                     board_length=28, board_width=12,
                                     board_thickness=1, sensor_x=4, sensor_y=6,
                                     sensor_keepout_radius=5) {

  color([0.03, 0.20, 0.10])
    cube([board_length, board_width, board_thickness], center=true);

  if (show_keepout)
    translate([sensor_x-board_length/2,
               sensor_y-board_width/2,
               board_thickness/2 + 0.02])
      color([1, 0.65, 0, 0.25])
      cylinder(r=sensor_keepout_radius, h=0.05, $fn=64);

  if (show_components) {
    // Sensor and regulator envelopes.
    ma600a_board_component(
      [sensor_x-board_length/2, sensor_y-board_width/2],
      [3, 3], 0.8, "dimgray", board_thickness);
    ma600a_board_component([0, 0], [3, 3], 1.0, "black", board_thickness);

    // C1/C2 are 0603; C3/C4 are 0402. Positions come from the released
    // top-side pick-and-place file.
    ma600a_board_component([0, 3.3], [1.6, 0.8], 0.8, "tan", board_thickness);
    ma600a_board_component([0, -3.2], [1.6, 0.8], 0.8, "tan", board_thickness);
    ma600a_board_component([-3.5, 3.0], [1.0, 0.5], 0.5, "tan", board_thickness);
    ma600a_board_component([-3.5, 0.5], [1.0, 0.5], 0.5, "tan", board_thickness);

    // Right-angle JST-GH connector at the non-magnetic end of the board.
    translate([10.5, 0, board_thickness/2 + 2.2])
      color("ivory")
      cube([5.5, 8.5, 4.4], center=true);

    // Seven bare test pads, shown as gold discs. They are not components.
    for (position = [[4, 4], [4, 2], [4, 0], [4, -2], [4, -4], [6, -4.5], [6, 4.5]])
      translate([position[0], position[1], board_thickness/2 + 0.04])
        color("gold")
        cylinder(d=1, h=0.08, $fn=24);
  }
}

module odometer_roller() {
  outer_diameter = 25;
  inner_diameter = 10.5;
  thickness = 5;

  rotate([0, 90, 0]) {
    color("darkgray")
      difference() {
        cylinder(d=outer_diameter, h=thickness, center=true);
        cylinder(d=inner_diameter, h=thickness+2, center=true);
      }
    for (side = [0, 1])
      mirror([0, 0, side])
        translate([0, 0, thickness/2 + 0.2])
          b623(center=false);
  }
}

// Diametrically magnetized target cylinder; its face points towards -X.
module odometer_magnet(diameter=6, height=2.5) {
  color("lightgray")
    rotate([0,90,0])
      cylinder(d=diameter, h=height, center=true, $fn=48);
}

module odometer_shaft_stub(diameter=3, length=5) {
  color("dimgray")
    rotate([0,90,0])
      cylinder(d=diameter, h=length, center=true, $fn=32);
}

// Current two-roller odometer. The output is normalized to its own origin:
// roller axes run along X, the upper roller is at Y=0, and Z=0 is the bottom
// of the tower. The board is placed on the -X side with its sensor aligned
// to the upper roller center.
module odometer(show_encoder_board=true, show_magnet=true, show_rollers=true, show_frame=true, show_cap=true){
  $fn = 64; // Round bearing seats must match the purchased races.
  outer_diameter = 25;
  roller_thickness = 5;
  line_diameter = 2;
  roller_gap = 1;
  line_entry_z = 19;
  low_roller_z = outer_diameter/2 + 1;
  hypot_dist = outer_diameter + roller_gap;
  roller_tower_height = line_entry_z + outer_diameter;
  roller_tower_thickness = 5;
  roller_tower_thickness2 = b623_width + 1;
  bearing_tower_corner_radius = 3;
  shift_entry_corner = [0,-9];
  shift_exit_corner = [0,-6];
  // The old in-assembly model used the main bearing tower datum. Preserve
  // that datum after normalizing the standalone frame to z=0 at its base.
  winch_bearing_tower_height = 50;
  winch_bearing_tower_wall_thickness = 3;
  roller_datum_z = winch_bearing_tower_height
                 - (b608_outer_dia + 2*winch_bearing_tower_wall_thickness)/2;
  high_roller_z = (outer_diameter+line_diameter)/2 - line_entry_z + roller_datum_z;
  a_diff = high_roller_z - low_roller_z;
  lower_roller_y = sqrt(hypot_dist^2 - a_diff^2);
  low_roller_y = lower_roller_y;
  roller_tower_depth = outer_diameter+lower_roller_y;

  if (show_rollers) {
    translate([0, 0, high_roller_z]){
      odometer_roller();
    }
    translate([0,low_roller_y, low_roller_z])
      odometer_roller();
  }
  if(show_frame) union() {
  // Coplanar with winch bottom. Open center keeps the lower roller (whose
  // bottom is z=1) clear of this 1.6 mm floor.
  difference() {
    translate([odometer_board_x()-2.5,-outer_diameter/2,0])
      cube([odometer_frame_outer_x()-odometer_board_x()+2.5,roller_tower_depth,1.6]);
    translate([-2.6,low_roller_y-13,-0.1]) cube([5.2,26,2]);
  }
  odometer_board_cradle();
  for(k=[0,1]) mirror([k,0,0])
    translate([roller_thickness/2+0.1, 0, 0]) {
      difference() {
        rotate([90,0,90])
        linear_extrude(height=roller_tower_thickness2)
          difference(){
            translate([-outer_diameter/2,0])
              hull(){
                square([roller_tower_depth, 1]);
                translate([roller_tower_depth-bearing_tower_corner_radius+shift_entry_corner[0],roller_tower_height-bearing_tower_corner_radius+shift_entry_corner[1]])
                  circle(r=bearing_tower_corner_radius);
                translate([bearing_tower_corner_radius+shift_exit_corner[0],roller_tower_height-bearing_tower_corner_radius+shift_exit_corner[1]])
                  circle(r=bearing_tower_corner_radius);
              }
            difference(){
              translate([2.5-outer_diameter/2, 2.5]){
                hull(){
                  translate([2.5,2.5]) circle(r=2.5);
                  translate([roller_tower_depth-5-2.5,2.5]) circle(r=2.5);
                  translate([roller_tower_depth-5-2.5+shift_entry_corner[0],roller_tower_height-5-2.5+shift_entry_corner[1]]) circle(r=2.5);
                  translate([2.5+shift_exit_corner[0],roller_tower_height-5-2.5+shift_exit_corner[1]]) circle(r=2.5);
                }
              }
              translate([0,high_roller_z])
                difference(){
                  hull(){
                    circle(d=b623_outer_dia + 3);
                    translate([-14,-18-high_roller_z])
                      circle(d=4);
                  }
                  circle(d=3.2);
                }
              translate([low_roller_y, low_roller_z]){
                difference(){
                  hull(){
                    circle(d=b623_outer_dia + 3);
                    translate([0,-18-low_roller_z])
                      circle(d=1);
                  }
                  circle(d=3.2);
                }
                difference(){
                  hull(){
                    circle(d=b623_outer_dia + 3);
                    rotate([0,0,-26])
                      translate([0,18+low_roller_z])
                      circle(d=1);
                  }
                  circle(d=3.2);
                }
                difference(){
                  hull(){
                    circle(d=b623_outer_dia + 3);
                    translate([-low_roller_y,-low_roller_z+high_roller_z])
                      circle(d=b623_outer_dia+3);
                  }
                  circle(d=3.2);
                  translate([-low_roller_y,-low_roller_z+high_roller_z])
                    circle(d=3.2);
                }
              }
            }
          }

      for(pos = [[b623_width+0.1, 0,high_roller_z], [b623_width+0.1, low_roller_y, low_roller_z]]) translate(pos)
        rotate([0,-90,0])
        cylinder(d=b623_outer_dia+0.1, h=roller_tower_thickness2);
    }

  }
  // Line entry
  difference() {
    translate([0,low_roller_y,low_roller_z + outer_diameter/2 + line_diameter/2])
      translate([-(roller_thickness + 2)/2, outer_diameter/2-2.5, -(Eyelet_diameter + 5)/2])
      cube([roller_thickness + 2, 2.5, Eyelet_diameter + 5]);
    translate([0,low_roller_y, low_roller_z + outer_diameter/2 + line_diameter/2])
      rotate([-90,0,0])
      cylinder(d=Eyelet_diameter, h=20);
    translate([0,low_roller_y, low_roller_z])
      scale((outer_diameter + 4)/outer_diameter)
      odometer_roller();
  }
  // Line exit
  difference() {
    translate([0, 0, high_roller_z - (outer_diameter/2 + line_diameter/2)])
      translate([-(roller_thickness + 2)/2, -outer_diameter/2, -(Eyelet_diameter + 5)/2])
      cube([roller_thickness + 2, 2.5, Eyelet_diameter + 5]);
    translate([0, 0, high_roller_z - outer_diameter/2 - line_diameter/2])
      rotate([90,0,0])
      cylinder(d=Eyelet_diameter, h=20);
    translate([0,0, high_roller_z])
      scale((outer_diameter + 4)/outer_diameter)
      odometer_roller();
  }
  } // Printable frame, foot and cradle.
  odometer_encoder_hardware(show_encoder_board,show_magnet,show_cap);
}

// Importable production outputs exclude all purchased and moving parts.
module odometer_frame() {
  odometer(show_encoder_board=false,show_magnet=false,show_rollers=false,show_cap=false);
}

if(odometer_part == "Assembly") odometer();
else if(odometer_part == "Frame") odometer_frame();
else if(odometer_part == "Magnet carrier") odometer_magnet_carrier();
else if(odometer_part == "Board cap") odometer_board_cap();
else if(odometer_part == "Drive hub") odometer_drive_hub();
else if(odometer_part == "Encoder section") odometer_encoder_section();
