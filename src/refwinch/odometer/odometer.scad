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
odometer_magnet_gap = 2; // From MPS's example in MA600A docs

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

// Placeholder target magnet. It is shown at the upper roller shaft end so
// the final shaft attachment can be designed around the real part later.
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
module odometer(show_encoder_board=true, show_magnet=true, show_rollers=true){
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
  magnet_diameter = odometer_magnet_diameter;
  magnet_height = odometer_magnet_height;
  magnet_gap = odometer_magnet_gap;
  encoder_sensor_height = 0.8;
  frame_outer_x = roller_thickness/2 + 0.1 + roller_tower_thickness2;
  magnet_overlap = 0.2;
  magnet_center_x = -(frame_outer_x + magnet_height/2 - magnet_overlap);
  shaft_stub_length = frame_outer_x + magnet_height/2
                    - roller_thickness/2 - magnet_overlap;
  encoder_board_length = 28;
  encoder_board_thickness = 1;
  encoder_sensor_x = 4;

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

      for(pos = [[b623_width, 0,high_roller_z], [b623_width, low_roller_y, low_roller_z]]) translate(pos)
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
  // The MA600A sensing center is aligned with the upper roller. The board
  // face is normal to X and its connector points down, away from the magnet.
  if (show_encoder_board)
    translate([
      -(frame_outer_x + magnet_height + magnet_gap
        + encoder_board_thickness/2 + encoder_sensor_height - magnet_overlap),
      0,
      high_roller_z - (encoder_board_length/2 - encoder_sensor_x)
    ])
      rotate([0, 90, 0])
        ma600a_encoder_breakout_board(show_components=true);

  // The magnet is attached to the upper roller shaft end. Its outer face is
  // separated from the sensor by magnet_gap; the attachment detail is left
  // as a later mechanical design task.
  if (show_magnet)
    union() {
      translate([-(roller_thickness/2 + shaft_stub_length/2), 0, high_roller_z])
        odometer_shaft_stub(length=shaft_stub_length);
      translate([magnet_center_x, 0, high_roller_z])
        odometer_magnet(diameter=magnet_diameter, height=magnet_height);
    }

}

// Opening this file directly displays the odometer with the reviewed board
// envelope in its proposed sensor-facing position. conventional_winch.scad
// imports only the modules with `use`, so this preview does not duplicate in
// the larger winch assembly.
odometer(
  show_encoder_board=false,
  show_magnet=false,
  show_rollers=false
);
