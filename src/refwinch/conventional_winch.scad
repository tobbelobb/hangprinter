include <conventional_guide/self_reversing_thread_bosl2.scad>
include <../lib/parameters.scad>
include <../lib/util.scad>
include <../lib/gears.scad>
include <../lib/gear_util.scad>
use <odometer/odometer.scad>

// Open the Customizer panel to select an output part and adjust these controls.
/* [Output] */

part = "Assembly"; // [Assembly, Base, Base side, Top shell, Drum, Drum shaft, Separator disc, Traverse shaft, Follower pawl, Pawl socket, Large gear, Small gear, Motor plate, Motor plate profile, Motor mount review]

/* [Traverse screw] */

traverse_stroke = 42; // [20:1:100]
traverse_rod_diameter = 11; // [8:0.1:16]
groove_turns_per_stroke = 4; // [1:0.25:10]
groove_diameter = 1.8; // [0.5:0.1:4]
groove_depth = 1.75; // [0.5:0.05:4]
groove_reversal_fraction = 0.250; // [0:0.01:0.49]
groove_samples_per_turn = 120; // [24:12:240]

/* [Drum] */

drum_core_radius = 20; // [10:0.5:35]
drum_envelope_diameter = 60; // [40:1:90]
drum_body_end_margin = 5.5; // [2:0.5:12]
drum_housing_end_margin = 6; // [2:0.5:12]
separator_disc_depth = 1.5; // [0.5:0.1:3]
separator_tooth_width_angle = 10; // [2:0.5:20]

/* [Gear train] */

gear_module = 1; // [0.5:0.1:2]
large_gear_tooth_count = 63; // [24:1:100]
small_gear_tooth_count = 12; // [8:1:40]
gear_width = 8; // [4:0.5:16]
gear_pressure_angle = 20; // [14.5, 20, 25]
gear_helix_angle = 45; // [0:1:60]
gear_backlash_tolerance = 0.2; // [0:0.05:1]

/* [Belt drive] */

gt2_belt_loop_length = 200; // [150:1:300]

/* [Motor mount] */

motor_mount_material = "Metal"; // [Metal, Printed]
metal_motor_plate_thickness = 3;
printed_motor_plate_thickness = 5;
// Rotation about the upper outer M3 screw; zero matches the nominal belt.
motor_adjustment_angle = 0; // [-6:0.5:6]
motor_adjustment_limit = 6; // [1:0.5:6]
show_odometer = false;

/* [Fit and fabrication] */

bearing_hole_diametral_clearance = 0.2; // [0:0.05:0.8]
drum_shell_diametral_clearance = 0.5; // [0:0.1:2]
torx_fit_diametral_clearance = 0.2; // [0:0.05:0.8]

/* [Hidden] */

// Axial allowances on each end of the traverse screw.
traverse_rod_end_length = 7;
grooved_section_extra_length = 5;
traverse_rod_length = traverse_stroke + 2*traverse_rod_end_length + 2*b608_width;

// The pitch-circle distance is shared by every drum-axis placement.
gear_pitch_center_distance = gear_module*(large_gear_tooth_count + small_gear_tooth_count)/2;
drum_axis_spacing = gear_pitch_center_distance + gear_backlash_tolerance;

drum_width = traverse_stroke + 2*drum_housing_end_margin;
separator_disc_end_margin = 5;
separator_disc_axial_offset = traverse_stroke/2 + separator_disc_end_margin;

gt2_tooth_pitch = 2;
drum_pulley_tooth_count = 62;
motor_pulley_tooth_count = 20;
motor_belt_direction_angle = 6;
motor_clocking_angle = -90; // Square to the base for body clearance during adjustment.
drum_end_disc_thickness = 1.3;
drum_pulley_width_allowance = 2;
drum_pulley_flange_height = 1.25;
drum_pulley_flange_outer_diameter = 40;
drum_pulley_flange_inner_diameter = 39;
drum_pulley_tooth_width = 6;
motor_pulley_hub_height = 7.4;
motor_pulley_top_flange_height = 1.5;
motor_pulley_to_motor_gap = 1;
motor_rear_magnet_gap = 0.2;
magnet_to_encoder_gap = 0.2;
cln17_magnet_diameter = 6;
cln17_magnet_height = 2.5;
cln17_v3_board_size = 38;
cln17_v3_mount_spacing = 31;
cln17_v3_mount_hole_diameter = 3.2;
cln17_v3_pcb_thickness = 1;
cln17_v3_encoder_height = 0.8;

function gt2_pitch_radius(tooth_count) =
  tooth_count*gt2_tooth_pitch/(2*PI);

function open_belt_length(center_distance, large_radius, small_radius) =
  let(
    radius_difference = large_radius-small_radius,
    tangent_angle = asin(radius_difference/center_distance),
    straight_length = sqrt(center_distance^2-radius_difference^2)
  )
  2*straight_length
  + PI*(large_radius+small_radius)
  + 2*tangent_angle*PI/180*radius_difference;

function solve_open_belt_center_distance(
  belt_length,
  large_radius,
  small_radius,
  lower_bound=undef,
  upper_bound=undef,
  iterations=40
) =
  let(
    low = is_undef(lower_bound) ? large_radius-small_radius+0.001 : lower_bound,
    high = is_undef(upper_bound) ? belt_length/2 : upper_bound,
    midpoint = (low+high)/2,
    midpoint_length = open_belt_length(midpoint, large_radius, small_radius)
  )
  iterations <= 0 ? midpoint :
  midpoint_length < belt_length ?
    solve_open_belt_center_distance(
      belt_length,
      large_radius,
      small_radius,
      midpoint,
      high,
      iterations-1
    ) :
    solve_open_belt_center_distance(
      belt_length,
      large_radius,
      small_radius,
      low,
      midpoint,
      iterations-1
    );

drum_pulley_pitch_radius = gt2_pitch_radius(drum_pulley_tooth_count);
motor_pulley_pitch_radius = gt2_pitch_radius(motor_pulley_tooth_count);
motor_pulley_center_distance = solve_open_belt_center_distance(
  gt2_belt_loop_length,
  drum_pulley_pitch_radius,
  motor_pulley_pitch_radius
);
motor_nominal_y = -drum_axis_spacing
               - motor_pulley_center_distance*cos(motor_belt_direction_angle);
motor_nominal_z = -motor_pulley_center_distance*sin(motor_belt_direction_angle);
// Coordinates on the plate are [world Y, world Z], relative to nominal shaft.
motor_hole_pitch = 31;
motor_pivot = [-motor_hole_pitch/2, motor_hole_pitch/2];
function motor_rotate(p, a) = [p[0]*cos(a)-p[1]*sin(a), p[0]*sin(a)+p[1]*cos(a)];
function motor_sweep(p, a) = motor_pivot + motor_rotate(p-motor_pivot, a);
motor_center_offset = motor_sweep([0,0], motor_adjustment_angle);
motor_axis_y = motor_nominal_y + motor_center_offset[0];
motor_axis_z = motor_nominal_z + motor_center_offset[1];

drum_pulley_axial_start =
  (traverse_stroke+2*drum_body_end_margin)/2 + drum_end_disc_thickness;
gt2_belt_center_x = drum_pulley_axial_start
                    + drum_pulley_flange_height
                    + GT2_belt_width/2;
motor_pulley_belt_center_from_base =
  (motor_pulley_hub_height
   + GT2_motor_gear_height-motor_pulley_top_flange_height)/2;
motor_pulley_base_x = gt2_belt_center_x + motor_pulley_belt_center_from_base;
motor_front_face_x = motor_pulley_base_x
                     + Nema17_ring_height
                     + motor_pulley_to_motor_gap;
motor_rear_face_x = motor_front_face_x + Nema17_cube_height;
magnet_base_x = motor_rear_face_x + motor_rear_magnet_gap;
cln17_v3_board_center_x = magnet_base_x
                          + cln17_magnet_height
                          + magnet_to_encoder_gap
                          + cln17_v3_pcb_thickness/2
                          + cln17_v3_encoder_height;

base_thickness = 3;
bearing_tower_wall_thickness = 3;
bearing_tower_depth = b608_outer_dia + 2*bearing_tower_wall_thickness;
bearing_tower_height = 50;
bearing_hole_diameter = b608_outer_dia + bearing_hole_diametral_clearance;
bearing_tower_corner_radius = 3;
bearing_tower_axial_clearance = 0.51;
bearing_cut_length_allowance = 10;
bearing_teardrop_tip_diameter = 4;

drum_z = bearing_tower_height - bearing_tower_depth/2;

base_plate_x_length = 76;
base_front_edge_y = 15.6;
base_rear_inset = 3.4;
base_rear_edge_y = -drum_envelope_diameter + 2*base_rear_inset;
base_y_length = base_front_edge_y - base_rear_edge_y;
base_extension_overlap = 0.1;
base_extension_x_length = 97.1;
base_extension_y_length = 31.2;
base_rib_thickness = 2;
base_rib_height = 4;
drum_right_bearing_tower_x = 50;
left_bearing_tower_x = -traverse_rod_length/2-bearing_tower_axial_clearance;
drum_shaft_right_end_clearance = 0.05;
drum_shaft_left_end_clearance = 0.06;
drum_shaft_right_end_x = drum_right_bearing_tower_x + b608_width + drum_shaft_right_end_clearance;
drum_shaft_left_end_x = left_bearing_tower_x + drum_shaft_left_end_clearance;
drum_shaft_length = drum_shaft_right_end_x - drum_shaft_left_end_x;

lower_shell_radial_wall = 2;
top_shell_radial_wall = 2.5;
shell_screw_row_radial_offset = 4.5;
shell_screw_x_fraction = 1/5;
shell_screw_nut_offset = 3;
shell_screw_support_diameter_allowance = 15;
shell_screw_boss_x = -1;
shell_screw_boss_thickness = 3;
shell_screw_boss_length = 7;
shell_axial_boolean_clearance = 2;
shell_radial_boolean_allowance = 20;

separator_disc_phase = 12;
separator_disc_height = 1;
separator_disc_cut_height = 1.2;

pawl_tilt_angle = 20;
pawl_radial_offset = 6;
drum_right_side_cover_shift = 21;

pawl_cylinder_diameter = 9;
pawl_cylinder_height = 20;
pawl_contact_angle = 26.5;
pawl_angular_span = 125;
pawl_path_center = 0.5;
pawl_axis_x = 21.1;
pawl_socket_end_offset = 9;
pawl_socket_floor_thickness = 2;
pawl_socket_wall_thickness = 2.5;

guide_rod_diameter = 3.2;
upper_guide_rod_z = -14;
guide_rod_spacing = 10;
guide_rod_length_allowance = 3;
line_entry_z = 19;
line_entry_length = 30;
pawl_guide_sweep_clearance = 0.5;
socket_guide_rod_clearance = 0.25;
pawl_socket_bore_clearance = 0.5;

torx_drive_diameter = 6.4;
large_gear_axial_gap = 4;
large_gear_center_z = -traverse_rod_length/2 - large_gear_axial_gap - gear_width/2;
torx_outer_overlap = 2;
torx_inner_overlap = 2.5;
boolean_cut_length = 100;
round_fn = 64;
shell_round_fn = 128;
separator_inner_fn = 100;

motor_plate_thickness = motor_mount_material == "Printed"
  ? printed_motor_plate_thickness : metal_motor_plate_thickness;
motor_plate_width = 80;
motor_plate_height = 60;
motor_actual_center_distance = norm([motor_axis_y+drum_axis_spacing,motor_axis_z]);
motor_plate_bottom = -drum_z + base_thickness;
motor_plate_front_x = motor_front_face_x - motor_plate_thickness;
motor_support_depth = 16;
motor_support_width = 10;
motor_support_y = 34;
motor_mount_bolt_z = [motor_plate_bottom+10, motor_plate_bottom+45];
assert(abs(motor_adjustment_angle) <= motor_adjustment_limit, "Motor angle exceeds slots");
assert(motor_mount_material == "Metal" || motor_mount_material == "Printed", "Unknown mount material");
assert(motor_plate_thickness >= 3, "Motor plate must be at least 3 mm thick");
assert(motor_adjustment_limit > 0 && motor_adjustment_limit <= 6, "Validated slot range is up to +/-6 degrees");

// Check the whole permitted sweep, not only the currently displayed position.
for(a=[-motor_adjustment_limit:0.5:motor_adjustment_limit]) {
  offset = motor_sweep([0,0],a);
  body_half_extent = Nema17_cube_width/2*(cos(a)+abs(sin(a)));
  assert(motor_nominal_z+offset[1]-body_half_extent >= motor_plate_bottom+2,
    "Motor sweep needs at least 1 mm clearance above the base ribs; shorten the belt or raise the motor");
  assert(abs(offset[0])+body_half_extent+1 < motor_support_y-motor_support_width/2,
    "Motor sweep intersects support rails");
}

echo("traverse_rod_length", traverse_rod_length);

module grooved_rod(){
  self_reversing_grooved_rod(
    rod_d=traverse_rod_diameter,
    rod_l=traverse_stroke + grooved_section_extra_length,
    stroke=traverse_stroke,
    turns_per_stroke=groove_turns_per_stroke,
    cycles=1,
    groove_d=groove_diameter,
    groove_depth=groove_depth,
    samples_per_turn=groove_samples_per_turn,
    reversal_frac=groove_reversal_fraction
  );
}

module raw_follower_pawl(){
  intersection(){
    color("orange")
      self_reversing_follower_pawl(
        rod_d=traverse_rod_diameter,
        stroke=traverse_stroke,
        turns_per_stroke=groove_turns_per_stroke,
        groove_d=groove_diameter,
        groove_depth=groove_depth,
        half_index=0,
        q_center=pawl_path_center,
        angular_span=pawl_angular_span,
        samples_per_turn=groove_samples_per_turn,
        reversal_frac=groove_reversal_fraction
      );
    rotate([2*pawl_contact_angle,0,0])
      self_reversing_follower_pawl(
        rod_d=traverse_rod_diameter,
        stroke=traverse_stroke,
        turns_per_stroke=groove_turns_per_stroke,
        groove_d=groove_diameter,
        groove_depth=groove_depth,
        half_index=1,
        q_center=pawl_path_center,
        angular_span=pawl_angular_span,
        samples_per_turn=groove_samples_per_turn,
        reversal_frac=groove_reversal_fraction
      );
  }
}

module torx_drive_profile(length=gear_width){
  lobe_count = 6;
  lobe_center_radius = 3;
  lobe_diameter = 3.2;
  lobe_envelope_diameter = 8;

  intersection(){
    for(ang=[0:360/lobe_count:359])
      rotate([0,0,ang])
        translate([lobe_center_radius,0,0])
        cylinder(d=lobe_diameter, h=length);
      cylinder(d=lobe_envelope_diameter, h=length);
  }
  cylinder(d=torx_drive_diameter, h=length);
}

module traverse_shaft(){
  bearing_seat_diameter = 2*b608_bore_r;
  bearing_seat_end_extension = 1;
  shaft_boolean_overlap = 0.5;

  union(){
    grooved_rod();
    for(k=[0,1]) mirror([0,0,k]) {
      translate([0,0,-traverse_rod_length/2-bearing_seat_end_extension-shaft_boolean_overlap])
        cylinder(
          d=bearing_seat_diameter,
          h=b608_width + bearing_seat_end_extension + shaft_boolean_overlap
        );
      translate([0,0,-traverse_rod_length/2 + b608_width-shaft_boolean_overlap])
        cylinder(
          d1=bearing_seat_diameter,
          d2=traverse_rod_diameter,
          h=traverse_rod_length/2 - b608_width - (traverse_stroke + grooved_section_extra_length)/2 + shaft_boolean_overlap
        );
    }
    translate([0,0,large_gear_center_z - gear_width/2 - torx_outer_overlap])
      torx_drive_profile(gear_width + torx_outer_overlap + torx_inner_overlap);
  }
}

module large_herringbone_gear(
  modul=gear_module,
  tooth_number=large_gear_tooth_count, // (2/10.5)*63. 2 is max line width. 10.5 is diamond groove pitch. 63 is the number of teeth needed to match the small gears' 12 teeth.
  width=gear_width,
  bore=12,
  pressure_angle=gear_pressure_angle,
  helix_angle=gear_helix_angle
){
  lightening_hole_count = 6;
  lightening_hole_radius = 18.17;
  lightening_hole_diameter = 12.2;
  gear_hub_diameter = 13;
  torx_scale = (torx_drive_diameter + torx_fit_diametral_clearance)/torx_drive_diameter;

  mirror([1,0,0])
  difference(){
    for(k=[0,1]) mirror([0,0,k])
      spur_gear(
        modul=modul,
        tooth_number=tooth_number,
        width=width/2,
        bore=bore,
        pressure_angle=pressure_angle,
        helix_angle=helix_angle,
        optimized= k == 0
      );
    for(ang=[0:360/lightening_hole_count:359]) rotate([0,0,ang])
      translate([lightening_hole_radius,0,0])
      cylinder(d=lightening_hole_diameter, h=width+2, center=true);
  }
  difference() {
    cylinder(d=gear_hub_diameter, h=width, center=true);
    translate([0,0,-(width+2)/2])
    scale([torx_scale,torx_scale,1])
    torx_drive_profile(width+2);
  }
}

module small_herringbone_gear(
  modul=gear_module,
  tooth_number=small_gear_tooth_count,
  width=gear_width+1,
  bore=0,
  pressure_angle=gear_pressure_angle,
  helix_angle=gear_helix_angle
){
  for(k=[0,1]) mirror([0,0,k])
  spur_gear(
    modul=modul,
    tooth_number=tooth_number,
    width=width/2,
    bore=bore,
    pressure_angle=pressure_angle,
    helix_angle=helix_angle,
    optimized=false
  );
}

module guide_rods(tol=0.1){
  for (dist=[0,guide_rod_spacing])
    translate([0,0,upper_guide_rod_z-dist])
    rotate([0,90,0])
    color("gray") {
    cylinder(d=guide_rod_diameter+tol, h=traverse_rod_length+guide_rod_length_allowance, center=true);
  }
}

module line_entry(){
  translate([0,0,-line_entry_z])
    rotate([90,0,0])
    cylinder(d=Eyelet_diameter, h=line_entry_length, center=true);
}

module follower_pawl(){
  pawl_clip_z = -5;
  pawl_clip_height = 12;
  pawl_clip_cube_size = 13;
  pawl_clip_cube_z = -4;
  clearance_sweep_step = 3;
  clearance_sweep_z = 6;

  intersection(){
    translate([0,0,traverse_rod_diameter/2])
    rotate([0,90,pawl_contact_angle])
      raw_follower_pawl();
    translate([0,0,pawl_clip_z])
      cylinder(d=traverse_rod_diameter, h=pawl_clip_height);
    translate([0,0,pawl_clip_cube_z])
      cube(pawl_clip_cube_size, center=true);
  }
  difference() {
    translate([0,0,-pawl_cylinder_height-1])
      cylinder(d=pawl_cylinder_diameter, h=pawl_cylinder_height);
    for(ang=[-pawl_contact_angle:clearance_sweep_step:pawl_contact_angle]) rotate([0,0,ang]) {
      translate([0,0,clearance_sweep_z]){
        line_entry();
        guide_rods(tol=pawl_guide_sweep_clearance);
      }
    }
  }
}


module bearing_tower(){
  difference(){
    translate([0,0,base_thickness])
      top2_rounded_cube2(
        [b608_width, bearing_tower_depth, bearing_tower_height],
        bearing_tower_corner_radius
      );
    translate([
      b608_width/2,
      bearing_tower_depth/2,
      drum_z
    ])
      rotate([0,90,0])
      hull(){
        cylinder(
          d=bearing_hole_diameter,
          h=b608_width+bearing_cut_length_allowance,
          center=true
        );
        translate([-bearing_hole_diameter/2,0,0])
          cylinder(
            d=bearing_teardrop_tip_diameter,
            h=b608_width+bearing_cut_length_allowance,
            center=true
          );
      }
  }
}

module shell_fastener_holes(){
  for(screw_x = [drum_width*shell_screw_x_fraction, -drum_width*shell_screw_x_fraction])
    translate([shell_screw_boss_x, -drum_envelope_diameter/2-shell_screw_row_radial_offset, screw_x])
      rotate([0,90,0]) {
        M3_screw(h=boolean_cut_length);
        translate([0,0,shell_screw_nut_offset])
          M3_nut(h=boolean_cut_length);
      }
}

// Flat metal blank: 80 x 60 x 3 mm, cut from standard 80 x 3 flat bar.
// Export Motor plate profile as DXF for machining; the slots are custom.
// Four M4x25 through bolts, washers and rear nuts attach it to the printed rails.
// Fit M3 washers on all four motor screws. Select screw length for the plate
// thickness + washer + the motor manufacturer's permitted thread engagement.
// Loosen the three slotted screws and ease the pivot screw enough to rotate,
// tension gently, then clamp all four. Negative angle tightens; positive loosens.
// +/-6 degrees is assembly travel, not an instruction to stretch a fitted belt
// to the end stop. The belt preview follows the geometry and does not model slack.
// Metal stock example: https://www.aluminiumexperte.de/alu-flachstange-80-x-3-mm.html
// For a one-piece prototype: motor_mount_material="Printed", part="Base".
module motor_plate_frame(x=motor_plate_front_x){
  translate([x,motor_nominal_y,motor_nominal_z])
    multmatrix([[0,0,1,0],[1,0,0,0],[0,1,0,0],[0,0,0,1]]) children();
}

module motor_arc_cut(p, diameter){
  for(i=[0:23]) hull(){
    for(a=[-motor_adjustment_limit + 2*motor_adjustment_limit*i/24,
           -motor_adjustment_limit + 2*motor_adjustment_limit*(i+1)/24])
      translate(motor_sweep(p,a)) circle(d=diameter, $fn=32);
  }
}

module motor_plate_profile(){
  difference(){
    translate([-motor_plate_width/2,motor_plate_bottom-motor_nominal_z])
      square([motor_plate_width,motor_plate_height]);
    // Boss must move with the shaft, otherwise it would lock the adjustment.
    motor_arc_cut([0,0], Nema17_ring_diameter+0.8);
    translate(motor_pivot) circle(d=3.4, $fn=32);
    for(y=[-1,1], z=[-1,1])
      if(!(y == -1 && z == 1))
        motor_arc_cut([y*motor_hole_pitch/2,z*motor_hole_pitch/2], 3.4);
    if(motor_mount_material == "Metal")
      for(y=[-motor_support_y,motor_support_y], z=motor_mount_bolt_z)
        translate([y,z-motor_nominal_z]) circle(d=4.5, $fn=32);
  }
}

module motor_plate(){
  linear_extrude(height=motor_plate_thickness, convexity=6) motor_plate_profile();
}

module motor_mount_base(){
  // Continuous foot overlaps the existing bottom plate and both support rails.
  translate([26,motor_nominal_y-motor_plate_width/2,-drum_z])
    cube([motor_front_face_x+motor_support_depth-26,
          base_rear_edge_y-motor_nominal_y+motor_plate_width/2+4,base_thickness]);
  // Low edge ribs carry the rail loads back into the original bottom plate.
  for(x=[26,motor_front_face_x+motor_support_depth-3])
    translate([x,motor_nominal_y-motor_plate_width/2,-drum_z])
      cube([3,base_rear_edge_y-motor_nominal_y+motor_plate_width/2+4,4]);
  difference(){
    union(){
      if(motor_mount_material == "Metal")
        for(y=[-motor_support_y,motor_support_y], z=motor_mount_bolt_z)
          translate([motor_front_face_x,motor_nominal_y+y,z])
            rotate([0,90,0]) cylinder(d=10,h=motor_support_depth,$fn=32);
      for(y=[-motor_support_y,motor_support_y]){
        translate([motor_front_face_x,motor_nominal_y+y-motor_support_width/2,motor_plate_bottom-0.1])
          cube([8,motor_support_width,motor_plate_height+0.1]);
        // Rear gussets stay outside the rotating motor body and screw heads.
        hull(){
          translate([motor_front_face_x,motor_nominal_y+y-motor_support_width/2,motor_plate_bottom-0.1])
            cube([motor_support_depth,motor_support_width,2]);
          translate([motor_front_face_x,motor_nominal_y+y-motor_support_width/2,motor_plate_bottom+motor_plate_height-2])
            cube([2,motor_support_width,2]);
        }
      }
    }
    if(motor_mount_material == "Metal")
      for(y=[-motor_support_y,motor_support_y], z=motor_mount_bolt_z)
        translate([motor_front_face_x-1,motor_nominal_y+y,z])
          rotate([0,90,0]) cylinder(d=4.5,h=motor_support_depth+2,$fn=32);
  }
  if(motor_mount_material == "Printed")
    motor_plate_frame() motor_plate();
}

module motor_mount_review(){
  base();
  if(motor_mount_material == "Metal") color("silver") motor_plate_frame() motor_plate();
  odometer_drive_motor_assembly();
}

module base(){
  motor_mount_base();
  tower_base_z = -drum_z;
  first_rib_x = 15;
  rib_interval_count = 4;
  last_rib_end_clearance = 1;
  shell_support_tangent_offset = 16.4;
  shell_support_radial_offset = 1.4;
  shell_support_clearance = 2.5;
  lower_shell_cut_y = 10;

  difference(){
    for(k=[0,1]) mirror([k,0,0])
      translate([left_bearing_tower_x,-bearing_tower_depth/2,tower_base_z])
        bearing_tower();
    guide_rods();
  }
  translate([-base_plate_x_length/2,base_rear_edge_y,tower_base_z]){
    rounded_cube2([base_plate_x_length, base_y_length, base_thickness], 0); // Biggest flat bottom part
    // Bend strength bars
    for(xs=[
      first_rib_x:
      (base_plate_x_length-base_rib_thickness-first_rib_x)/rib_interval_count:
      base_plate_x_length-base_rib_thickness-last_rib_end_clearance
    ])
      translate([xs,0,0])
        cube([base_rib_thickness, base_y_length, base_rib_height]);
    translate([base_plate_x_length-base_rib_thickness,0,0])
      cube([
        base_rib_thickness,
        base_y_length-bearing_tower_depth-2*base_rib_thickness,
        base_rib_height
      ]);
  }
  translate([0,-drum_axis_spacing,0])
    rotate([0,90,0])
    color("yellow")
    difference(){
      hull() {
        cylinder(d=drum_envelope_diameter+2*lower_shell_radial_wall, h=drum_width, center=true);
        rotate([0,0,90])
          translate([
            -(drum_envelope_diameter+2*lower_shell_radial_wall)/2+shell_support_tangent_offset,
            -(drum_envelope_diameter+2*lower_shell_radial_wall)/2-shell_support_radial_offset-shell_support_clearance,
            -drum_width/2
          ])
            cube([drum_envelope_diameter/2, 1, drum_width]);
        translate([
          shell_screw_boss_x,
          -(drum_envelope_diameter+shell_screw_support_diameter_allowance)/2,
          -drum_width/2
        ])
          cube([shell_screw_boss_thickness, shell_screw_boss_length, drum_width]);
      }
      cylinder(
        d=drum_envelope_diameter+drum_shell_diametral_clearance,
        h=drum_width+shell_axial_boolean_clearance,
        center=true,
        $fn=shell_round_fn
      );
      translate([0,lower_shell_cut_y,-boolean_cut_length/2])
        cube([drum_width+shell_axial_boolean_clearance, drum_width+shell_axial_boolean_clearance, boolean_cut_length]);
      translate([
        -(drum_width+shell_axial_boolean_clearance),
        -(drum_envelope_diameter+shell_radial_boolean_allowance)/2,
        -boolean_cut_length/2
      ])
        cube([
          drum_width+shell_axial_boolean_clearance,
          drum_envelope_diameter+shell_radial_boolean_allowance,
          boolean_cut_length
        ]);
      shell_fastener_holes();
    }
  translate([
    -base_plate_x_length/2,
    base_rear_edge_y-base_extension_overlap,
    tower_base_z
  ])
    rounded_cube2([base_extension_x_length, base_extension_y_length, base_thickness], 0);

  for(xs=[left_bearing_tower_x, drum_right_bearing_tower_x])
    translate([xs,-bearing_tower_depth/2-drum_axis_spacing,tower_base_z])
      bearing_tower();

}

module top_shell() {
  top_shell_cut_y = 34;
  side_cut_axial_allowance = 16;

  rotate([0,270,0])
  color("silver")
  difference(){
    hull() {
      cylinder(d=drum_envelope_diameter+2*top_shell_radial_wall, h=drum_width, center=true);
      translate([
        shell_screw_boss_x,
        -(drum_envelope_diameter+shell_screw_support_diameter_allowance)/2,
        -drum_width/2
      ])
        cube([shell_screw_boss_thickness, shell_screw_boss_length, drum_width]);
    }
    cylinder(
      d=drum_envelope_diameter+drum_shell_diametral_clearance,
      h=drum_width+shell_axial_boolean_clearance,
      center=true,
      $fn=shell_round_fn
    );
    translate([0,top_shell_cut_y,-boolean_cut_length/2])
      cube([drum_width+shell_axial_boolean_clearance, drum_width+shell_axial_boolean_clearance, boolean_cut_length]);
    translate([
      -(drum_width+shell_axial_boolean_clearance),
      -(drum_envelope_diameter+shell_radial_boolean_allowance),
      -boolean_cut_length/2
    ])
      cube([
        drum_width+shell_axial_boolean_clearance,
        drum_envelope_diameter+shell_radial_boolean_allowance,
        boolean_cut_length
      ]);
    translate([-(drum_width+side_cut_axial_allowance),0,-boolean_cut_length/2])
      cube([
        drum_width+shell_axial_boolean_clearance,
        drum_envelope_diameter+shell_radial_boolean_allowance,
        boolean_cut_length
      ]);
    shell_fastener_holes();
  }
}

module bearing_tower_cover(){
  skirt = 0;
  cover_axial_inset = 8;
  cover_x = traverse_rod_length/2-cover_axial_inset;
  cover_outer_width_allowance = 4;
  cover_outer_depth_allowance = 3;
  shaft_relief_diameter = 13;
  shaft_relief_length = 50;
  print_relief_offset = 7;
  print_relief_tip_diameter = 2;
  cover_fit_clearance = 0.5;
  cover_boolean_height_allowance = 10;
  corner_relief_size = 3;
  corner_relief_overlap = 0.25;

  difference(){
    translate([
      cover_x,
      -bearing_tower_depth/2,
      -drum_z + 2
    ])
      translate([0,0,base_thickness])
        difference(){
          translate([0,-1.5,-2 + skirt])
            top2_rounded_cube2([
              b608_width+cover_outer_width_allowance,
              bearing_tower_depth+cover_outer_depth_allowance,
              bearing_tower_height-skirt
            ], bearing_tower_corner_radius);
          translate([2-cover_fit_clearance,0,-2 - 1])
            top2_rounded_cube2([
              b608_width+cover_fit_clearance,
              bearing_tower_depth,
              bearing_tower_height+5
            ], bearing_tower_corner_radius);
          translate([2-5,1,-2-1])
            top2_rounded_cube2([
              b608_width+5,
              bearing_tower_depth-2,
              bearing_tower_height+5
            ], bearing_tower_corner_radius);
        }
    rotate([0,90,0])
      hull() {
        cylinder(d=shaft_relief_diameter, h=shaft_relief_length);
        translate([-print_relief_offset,0,0])
          cylinder(d=print_relief_tip_diameter, h=shaft_relief_length);
      }
    for(k=[0,1]) mirror([0,k,0])
      translate([
        cover_x,
        -bearing_tower_depth/2-corner_relief_overlap,
        base_thickness- drum_z - 1
      ])
      rotate([0,0,45])
      cube([corner_relief_size,corner_relief_size,bearing_tower_height+cover_boolean_height_allowance]);
  }
}

module pawl_socket(){
  socket_z = -pawl_cylinder_height-pawl_socket_end_offset;

  difference(){
    translate([0,0,socket_z])
      cylinder(
        d=pawl_cylinder_diameter + 2*pawl_socket_wall_thickness,
        h=pawl_cylinder_height
      );
    translate([0,0,socket_z+pawl_socket_floor_thickness])
      cylinder(d=pawl_cylinder_diameter+pawl_socket_bore_clearance, h=pawl_cylinder_height);
    guide_rods(tol=socket_guide_rod_clearance);
    line_entry();
  }
}

module separator_disc(
  diameter=drum_envelope_diameter,
  drum_radius=drum_core_radius,
  depth=separator_disc_depth,
  tooth_width_angle=separator_tooth_width_angle,
  height=separator_disc_height,
  center=false
){
  tooth_pitch_angle = 30;
  half_tooth_pitch_angle = tooth_pitch_angle/2;
  cutter_height = 3;
  cutter_z = -1;
  tooth_radial_clearance = 0.2;
  slit_width = 0.5;

  difference(){
    cylinder(d=diameter, h=height, $fn=round_fn, center=center);
    translate([0,0,cutter_z]){
      cylinder(r=drum_radius-depth, h=cutter_height, $fn=separator_inner_fn);
      for(v=[0:tooth_pitch_angle:359])
        rotate([0,0,v]) {
          p = circle_sector(
            r0=1,
            r1=drum_radius+tooth_radial_clearance,
            max_ang=tooth_pitch_angle-tooth_width_angle
          );
          rotate([0,0,tooth_width_angle/2+half_tooth_pitch_angle])
            linear_extrude(height=cutter_height) polygon(points=p);
          for(a=[tooth_width_angle/2,-tooth_width_angle/2])
            rotate([0,0,half_tooth_pitch_angle+a])
            translate([-slit_width/2,0,0])
              cube([slit_width,(drum_radius+diameter/2)/2,cutter_height]);
        }
    }
  }
}


// 22.7 gives four layers of 2 mm thick line on a 42 mm drum fits 12000 mm of line.
//drum_core_radius = 22.7;
// However to get an effective radius of 22.7 over this range of wind in we need a smaller base radius.
// 30.315 gives three layers of 2 mm thick line on a 42 mm drum fits 12000 mm of line.
//drum_core_radius = 30.315;
module drum(){
  small_gear_axial_position = 43;
  small_gear_phase = 7;
  hub_diameter = 14;
  hub_length = 38.5;
  shaft_bore_diameter = 8;
  shaft_bore_length = 75;
  shaft_bore_center_z = 11;
  inner_wall_thickness = 2;
  cavity_start_margin = 3;
  cavity_length = 50;
  cavity_taper_length = 10;

  difference(){
  difference(){
    rotate([0,90,0]) {
      union(){
        translate([0,0,drum_end_disc_thickness/2])
        cylinder(
          r=drum_core_radius,
          h=traverse_stroke + 2*drum_body_end_margin+drum_end_disc_thickness,
          center=true,
          $fn=round_fn
        );
        // GT2 pulley, mounted immediately outboard of the small helical gear.
        translate([0,0,drum_pulley_axial_start]){
          GT2_2mm_pulley_extrusion(
            GT2_belt_width+drum_pulley_width_allowance,
            drum_pulley_tooth_count
          );
          cylinder(
            d1=drum_pulley_flange_outer_diameter,
            d2=drum_pulley_flange_inner_diameter,
            h=drum_pulley_flange_height
          );
          translate([0,0,drum_pulley_flange_height+drum_pulley_tooth_width])
            cylinder(
              d1=drum_pulley_flange_inner_diameter,
              d2=drum_pulley_flange_outer_diameter,
              h=drum_pulley_flange_height
            );
          translate([0,0,2*drum_pulley_flange_height+drum_pulley_tooth_width])
            cylinder(
              d=drum_pulley_flange_outer_diameter,
              h=drum_end_disc_thickness
            );
        }
      }
      translate([0,0,small_gear_axial_position])
        rotate([0,0,small_gear_phase])
        small_herringbone_gear();
      cylinder(d=hub_diameter, h=hub_length, $fn=round_fn);
      translate([0,0,-separator_disc_axial_offset])
        cylinder(d=drum_envelope_diameter, h=separator_disc_height, center=true, $fn=round_fn);
    }
    rotate([0,90,0])
    translate([0,0,shaft_bore_center_z])
      cylinder(d=shaft_bore_diameter, h=shaft_bore_length, $fn=round_fn, center=true);
    rotate([0,90,0])
    translate([0,0,-traverse_stroke/2-cavity_start_margin])
      cylinder(
        r=drum_core_radius-inner_wall_thickness,
        h=cavity_length,
        $fn=round_fn,
        center=false
      );
    rotate([0,90,0])
    translate([0,0,-traverse_stroke/2-cavity_start_margin+cavity_length])
      cylinder(
        r2=shaft_bore_diameter/2,
        r1=drum_core_radius-inner_wall_thickness,
        h=cavity_taper_length,
        $fn=round_fn,
        center=false
      );
    rotate([0,90,0])
      translate([0,0,separator_disc_axial_offset])
      rotate([0,0,separator_disc_phase])
      separator_disc(height=separator_disc_cut_height, center=true, $fn=round_fn);
  }
  }
}

module drum_shaft(){
  shaft_diameter = 7.9;
  flat_cutter_x = -50;
  flat_cutter_y = 3.3;

  rotate([-90,0,0])
  rotate([0,-90,0])
    difference(){
      cylinder(d=shaft_diameter, h=drum_shaft_length);
      translate([flat_cutter_x,flat_cutter_y,0])
        cube(boolean_cut_length);
    }
}

module drive_train_assembly(){
  rotate([0,-90,0]) {
    rotate([0,0,180]){
      translate([0,0,-pawl_axis_x])
        rotate([-pawl_tilt_angle,0,0])
        translate([pawl_radial_offset,0,0])
        rotate([0,-90,0])
          follower_pawl();
      traverse_shaft();
    }
    translate([0,0,large_gear_center_z])
      rotate([180,0,0])
      large_herringbone_gear();
  }
  translate([pawl_axis_x,0,0])
    pawl_socket();
  base();
  for(k=[0,1]) mirror([k,0,0])
    bearing_tower_cover();
  translate([drum_right_side_cover_shift,-drum_axis_spacing])
    bearing_tower_cover();
  mirror([1,0,0])
    translate([0,-drum_axis_spacing])
    bearing_tower_cover();
  translate([0,-drum_axis_spacing,0])
    drum();
  translate([drum_shaft_right_end_x,0,0])
    translate([0,-drum_axis_spacing,0])
    drum_shaft();
  translate([0,-drum_axis_spacing,0])
    rotate([0,90,0])
    translate([0,0,separator_disc_axial_offset])
    rotate([0,0,separator_disc_phase])
    separator_disc(center=true, $fn=round_fn);
  translate([0,-drum_axis_spacing])
    top_shell();
  if(motor_mount_material == "Metal") color("silver") motor_plate_frame() motor_plate();
  odometer_drive_motor_assembly();
}

if (part == "Assembly") {
  drive_train_assembly();
} else if (part == "Motor plate") {
  motor_plate();
} else if (part == "Motor plate profile") {
  motor_plate_profile();
} else if (part == "Motor mount review") {
  motor_mount_review();
} else if (part == "Base") {
  base();
} else if (part == "Base side") {
  bearing_tower_cover();
} else if (part == "Top shell") {
  rotate([0,90,0]) top_shell();
} else if (part == "Drum") {
  rotate([0,-90,0]) drum();
} else if (part == "Drum shaft") {
  drum_shaft();
} else if (part == "Separator disc") {
  separator_disc();
} else if (part == "Traverse shaft") {
  rotate([180,0,0]) traverse_shaft();
} else if (part == "Follower pawl") {
  follower_pawl();
} else if (part == "Pawl socket") {
  pawl_socket();
} else if (part == "Large gear") {
  large_herringbone_gear();
} else if (part == "Small gear") {
  small_herringbone_gear();
}

if (part == "Assembly" && show_odometer)
  translate([0, 120, -drum_z])
    odometer(show_encoder_board=true);
