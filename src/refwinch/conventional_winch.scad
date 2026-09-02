include <conventional_guide/self_reversing_thread_bosl2.scad>
include <../lib/parameters.scad>
include <../lib/util.scad>
include <../lib/gears.scad>
include <../lib/gear_util.scad>

// Open the Customizer panel to select an output part and adjust these controls.
/* [Output] */

part = "Assembly"; // [Assembly, Base, Base side, Top shell, Drum, Drum shaft, Separator disc, Traverse shaft, Follower pawl, Pawl socket, Large gear, Small gear]

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
motor_belt_direction_angle = 8;
motor_clocking_angle = -58;
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
motor_axis_y = -drum_axis_spacing
               - motor_pulley_center_distance*cos(motor_belt_direction_angle);
motor_axis_z = -motor_pulley_center_distance*sin(motor_belt_direction_angle);

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

module base(){
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
  odometer_drive_motor_assembly();
}

if (part == "Assembly") {
  drive_train_assembly();
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

urethane_roller_outer_diameter = 25;
urethane_roller_inner_diameter = 10.5;
urethane_roller_thickness = 5;
module urethane_roller(){
  rotate([0,90,0]) {
    color("darkgray")
    difference(){
      cylinder(d=urethane_roller_outer_diameter, h=urethane_roller_thickness, center=true);
      cylinder(d=urethane_roller_inner_diameter, h=urethane_roller_thickness+2, center=true);
    }
    b623(center=true);
  }
}

module urethane_roller2(){
  rotate([0,90,0]) {
    color("darkgray")
    difference(){
      cylinder(d=urethane_roller_outer_diameter, h=urethane_roller_thickness, center=true);
      cylinder(d=urethane_roller_inner_diameter, h=urethane_roller_thickness+2, center=true);
    }
    for(k=[0,1]) mirror([0,0,k])
      translate([0,0,urethane_roller_thickness/2 + 0.2])
      b623(center=false);
  }
}

line_diameter = 2;
roller_gap = 1;

high_roller_z = (urethane_roller_outer_diameter+line_diameter)/2 - line_entry_z + drum_z;
low_roller_z = urethane_roller_outer_diameter/2 + 1;
a_diff = high_roller_z - low_roller_z;
hypot_dist = urethane_roller_outer_diameter + roller_gap;
ydiff = sqrt(hypot_dist^2 - a_diff^2);

roller_tower_height = line_entry_z + urethane_roller_outer_diameter;
roller_tower_depth = urethane_roller_outer_diameter+ydiff;
roller_tower_thickness = 5;
roller_tower_thickness2 = b623_width + 1; // b623_width  = 4;

y_offset = 40;
// high_roller_y = 0;
low_roller_y = ydiff; // + high_roller_y

shift_entry_corner = [0,-9];
shift_exit_corner = [0,-6];

// CLN17 V3 mechanical model.
// The V3 KiCad files are not published yet. The 38 mm PCB outline, 31 mm
// NEMA17 mounting pattern, 3.2 mm screw clearance and 1 mm board thickness
// come from the released CLN17 KiCad designs. Connector/component locations
// and envelopes follow the official orthographic V3 product render.
module cln17_v3_board_profile(){
  mount_offset = cln17_v3_mount_spacing/2;
  edge_slot_end = cln17_v3_board_size/2 + 1;
  center_edge_relief_width = 12;
  center_edge_relief_depth = 1.5;

  difference(){
    square(cln17_v3_board_size, center=true);

    // The motor-screw holes open towards the side edges so the assembled
    // driver can slide behind existing NEMA17 screw heads.
    for(xsign=[-1,1], ysign=[-1,1])
      hull(){
        translate([xsign*mount_offset, ysign*mount_offset])
          circle(d=cln17_v3_mount_hole_diameter, $fn=32);
        translate([xsign*edge_slot_end, ysign*mount_offset])
          circle(d=cln17_v3_mount_hole_diameter, $fn=32);
      }

    // Shallow edge reliefs visible above the motor pads and connectors.
    for(ysign=[-1,1])
      translate([
        0,
        ysign*(cln17_v3_board_size/2-center_edge_relief_depth/2)
      ])
        square([center_edge_relief_width, center_edge_relief_depth], center=true);
  }
}

module cln17_v3_chip(position, size, rotation=0, side=1, chip_color="dimgray"){
  translate([
    position[0],
    position[1],
    side*(cln17_v3_pcb_thickness/2 + size[2]/2)
  ])
    rotate([0,0,rotation])
    color(chip_color)
    cube(size, center=true);
}

module cln17_v3_side_connector(position, rotation=0, width=8.5){
  body_depth = 8;
  body_height = 6.5;
  opening_width = width - 3;
  opening_height = 3.4;

  translate([position[0], position[1], cln17_v3_pcb_thickness/2])
    rotate([0,0,rotation])
    color("ivory")
    difference(){
      translate([0,0,body_height/2])
        cube([width, body_depth, body_height], center=true);
      translate([0,-body_depth/2-0.1,body_height/2])
        cube([opening_width, body_depth/2+0.2, opening_height], center=true);
    }
}

module cln17_v3_usb_c(){
  connector_width = 9.2;
  connector_depth = 7.4;
  connector_height = 3.2;

  color("silver")
  difference(){
    translate([0,0,-connector_height/2])
      cube([connector_width, connector_depth, connector_height], center=true);
    translate([0,-connector_depth/2-0.1,-connector_height/2])
      cube([6.6,connector_depth/2+0.2,1.5], center=true);
  }
}


module gt2_drive_belt(){
  drum_pulley_outer_radius =
    tooth_spacing(gt2_tooth_pitch, 0.254, drum_pulley_tooth_count)/2;
  motor_pulley_outer_radius =
    tooth_spacing(gt2_tooth_pitch, 0.254, motor_pulley_tooth_count)/2;

  assert(
    gt2_belt_loop_length > 2*PI*drum_pulley_pitch_radius,
    "GT2 belt is too short for the selected pulleys"
  );

  color([0.12,0.12,0.12])
  translate([gt2_belt_center_x,0,0])
  rotate([0,-90,0])
  linear_extrude(height=GT2_belt_width, center=true, convexity=4)
  difference(){
    hull(){
      translate([0,-drum_axis_spacing])
        circle(r=drum_pulley_outer_radius+Belt_thickness, $fn=round_fn);
      translate([motor_axis_z,motor_axis_y])
        circle(r=motor_pulley_outer_radius+Belt_thickness, $fn=round_fn);
    }
    hull(){
      translate([0,-drum_axis_spacing])
        circle(r=drum_pulley_outer_radius, $fn=round_fn);
      translate([motor_axis_z,motor_axis_y])
        circle(r=motor_pulley_outer_radius, $fn=round_fn);
    }
  }
}

module odometer_drive_motor_assembly(){
  echo("GT2 belt loop length", gt2_belt_loop_length);
  echo("GT2 pulley center distance", motor_pulley_center_distance);

  gt2_drive_belt();

  // Nema17() points its shaft along +Z. Turn it towards the drum (-X),
  // retaining the clocking angle from the tentative CLN17 placement.
  translate([motor_rear_face_x,motor_axis_y,motor_axis_z])
    rotate([motor_clocking_angle,0,0])
    rotate([0,-90,0])
    Nema17();

  color([0.75,0.75,0.75])
  translate([motor_pulley_base_x,motor_axis_y,motor_axis_z])
    rotate([motor_clocking_angle,0,0])
    rotate([0,-90,0])
    GT2_flanged_motor_gear(
      motor_pulley_tooth_count,
      2*Nema17_shaft_radius
    );

  // The magnet sits on the rear shaft and the CLN17 encoder faces it.
  translate([magnet_base_x,motor_axis_y,motor_axis_z])
    rotate([0,90,0])
    magnet();
  translate([cln17_v3_board_center_x,motor_axis_y,motor_axis_z])
    rotate([motor_clocking_angle,0,0])
    rotate([0,90,0])
    cln17_v3_board();
}

module cln17_v3_board(show_components=true){
  mount_offset = cln17_v3_mount_spacing/2;
  copper_ring_outer_diameter = 6;
  copper_layer_thickness = 0.04;

  color([0.03,0.12,0.20])
    linear_extrude(height=cln17_v3_pcb_thickness, center=true)
      cln17_v3_board_profile();

  // Exposed copper around the four NEMA17 mounting slots.
  for(side=[-1,1], xsign=[-1,1], ysign=[-1,1])
    translate([
      xsign*mount_offset,
      ysign*mount_offset,
      side*(cln17_v3_pcb_thickness/2 + copper_layer_thickness/2)
    ])
      color("gold")
      linear_extrude(height=copper_layer_thickness, center=true)
      intersection(){
        difference(){
          circle(d=copper_ring_outer_diameter, $fn=32);
          circle(d=cln17_v3_mount_hole_diameter+0.2, $fn=32);
        }
        translate([-xsign*mount_offset,-ysign*mount_offset])
          cln17_v3_board_profile();
      }

  if(show_components){
    // Connector/label face (+Z).
    cln17_v3_chip([0,5.2], [7,7,1], 45);
    cln17_v3_chip([0,-7.5], [4,4,1]);

    for(x=[-1,1]){
      cln17_v3_side_connector([x*18,4], rotation=x*90, width=8.5);
      cln17_v3_side_connector([x*18,-8.5], rotation=x*90, width=8.5);
      cln17_v3_chip([x*10.8,15.5], [3.2,2.5,2.2], chip_color="sienna");
      cln17_v3_chip([x*10.8,12.3], [3.2,2.5,2.2], chip_color="sienna");
      cln17_v3_chip([x*10.8,9.1], [3.2,2.5,2.2], chip_color="sienna");
      cln17_v3_chip([x*10.7,-16.2], [4.2,3.2,2], chip_color="silver");
    }

    // Optional motor-output pads along the upper edge.
    for(x=[-3.75,-1.25,1.25,3.75])
      translate([x,16,cln17_v3_pcb_thickness/2+0.05])
        color("gold")
        cube([1.5,4.2,0.1], center=true);

    cln17_v3_side_connector([0,-18.5], rotation=0, width=14.5);

    // Power-stage face (-Z): encoder at the shaft center, MCU, MOSFETs,
    // inductor and the bottom-edge USB-C connector.
    cln17_v3_chip([0,0], [3,3,cln17_v3_encoder_height], side=-1);
    cln17_v3_chip([0,-7], [7,7,1], side=-1);
    cln17_v3_chip([-13,-8], [5.8,5.8,3], side=-1, chip_color="black");
    cln17_v3_chip([12,-9], [5,6,1.2], side=-1);

    for(x=[-12.5,-7.5,-2.5,2.5,7.5,12.5])
      cln17_v3_chip([x,10], [4.2,5,1], side=-1);

    translate([0,-cln17_v3_board_size/2-1.2,-cln17_v3_pcb_thickness/2])
      cln17_v3_usb_c();
  }
}


//translate([-8,80+y_offset,-drum_z])
translate([0,80+y_offset,-drum_z])
odometer2();
module odometer2(){
  translate([0, 0, high_roller_z]){
    urethane_roller2();
  }
  translate([0,low_roller_y, low_roller_z])
    urethane_roller2();
  for(k=[0,1]) mirror([k,0,0])
    translate([urethane_roller_thickness/2+0.1, 0, 0]) {
      difference() {
        rotate([90,0,90])
        linear_extrude(height=roller_tower_thickness2)
          difference(){
            translate([-urethane_roller_outer_diameter/2,0])
              hull(){
                square([roller_tower_depth, 1]);
                translate([roller_tower_depth-bearing_tower_corner_radius+shift_entry_corner[0],roller_tower_height-bearing_tower_corner_radius+shift_entry_corner[1]])
                  circle(r=bearing_tower_corner_radius);
                translate([bearing_tower_corner_radius+shift_exit_corner[0],roller_tower_height-bearing_tower_corner_radius+shift_exit_corner[1]])
                  circle(r=bearing_tower_corner_radius);
              }
            difference(){
              translate([2.5-urethane_roller_outer_diameter/2, 2.5]){
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
    translate([0,low_roller_y,low_roller_z + urethane_roller_outer_diameter/2 + line_diameter/2])
      translate([-(urethane_roller_thickness + 2)/2, urethane_roller_outer_diameter/2-2.5, -(Eyelet_diameter + 5)/2])
      cube([urethane_roller_thickness + 2, 2.5, Eyelet_diameter + 5]);
    translate([0,low_roller_y, low_roller_z + urethane_roller_outer_diameter/2 + line_diameter/2])
      rotate([-90,0,0])
      cylinder(d=Eyelet_diameter, h=20);
    translate([0,low_roller_y, low_roller_z])
      scale((urethane_roller_outer_diameter + 4)/urethane_roller_outer_diameter)
      urethane_roller();
  }
  // Line exit
  difference() {
    translate([0, 0, high_roller_z - (urethane_roller_outer_diameter/2 + line_diameter/2)])
      translate([-(urethane_roller_thickness + 2)/2, -urethane_roller_outer_diameter/2, -(Eyelet_diameter + 5)/2])
      cube([urethane_roller_thickness + 2, 2.5, Eyelet_diameter + 5]);
    translate([0, 0, high_roller_z - urethane_roller_outer_diameter/2 - line_diameter/2])
      rotate([90,0,0])
      cylinder(d=Eyelet_diameter, h=20);
    translate([0,0, high_roller_z])
      scale((urethane_roller_outer_diameter + 4)/urethane_roller_outer_diameter)
      urethane_roller();
  }
}

module hub_and_spokes() {
  difference() {
    cylinder(d = urethane_roller_outer_diameter+5, h=urethane_roller_thickness*10, center=true);
    difference() {
      cylinder(d = urethane_roller_outer_diameter-5, h=urethane_roller_thickness*10, center=true);
      difference() {
        for(ang = [-45,45]) rotate([0,0, ang])
          cube([urethane_roller_outer_diameter, 5, urethane_roller_thickness*10], center=true);
        cylinder(d=3.1, h=urethane_roller_thickness*11, center=true);
      }
    }
  }
}

module magnet(){
  // From https://www.fysetc.com/products/creapunk-cln17-v3#images-3
  color("lightgray")
    cylinder(d=cln17_magnet_diameter, h=cln17_magnet_height);
}


//translate([8,80,-drum_z])
//odometer1();
module odometer1(){
  translate([0,y_offset, high_roller_z]){
    urethane_roller();
    translate([-2-urethane_roller_thickness/2,(3+5)/2 + 0.1,0])
    rotate([0,90,0])
      magnet();
    //rotate([0,90,0])
    //  %cylinder(d=3, h=urethane_roller_thickness + roller_tower_thickness + 0.5 +5, center=true);
  }
  translate([0,y_offset + ydiff, low_roller_z])
    urethane_roller();
  difference() {
    //for(k=[0,1]) mirror([k,0,0])
    union(){
      translate([urethane_roller_thickness/2+0.1, -urethane_roller_outer_diameter/2 + y_offset, 0])
        top2_rounded_cube2(
          [roller_tower_thickness, roller_tower_depth, roller_tower_height],
          bearing_tower_corner_radius
        );
      translate([-(urethane_roller_thickness/2+0.1+roller_tower_thickness-3.1+1), -urethane_roller_outer_diameter/2 + y_offset, 0])
        top2_rounded_cube2(
          [roller_tower_thickness-3.1+1, roller_tower_depth, roller_tower_height],
          bearing_tower_corner_radius
        );
    }
    translate([-4.5,y_offset, high_roller_z])
      rotate([0,90,0])
      cylinder(r = 1.5+5+0.2, h=5, center=false);
    difference() {
      hull() {
        translate([0,y_offset-b623_outer_dia/2-5/2,roller_tower_height - 5/2 - 2.5])
          rotate([0,90,0])
          cylinder(d = 5, h=urethane_roller_thickness*10, center=true);
        translate([0,y_offset-b623_outer_dia/2-5/2,5/2+2.5])
          rotate([0,90,0])
          cylinder(d = 5, h=urethane_roller_thickness*10, center=true);
        translate([0,y_offset-urethane_roller_outer_diameter/2 + roller_tower_depth - 5/2 - 2.5,5/2+2.5])
          rotate([0,90,0])
          cylinder(d = 5, h=urethane_roller_thickness*10, center=true);
        translate([0,y_offset-urethane_roller_outer_diameter/2 + roller_tower_depth - 5/2 - 2.5, roller_tower_height - 5/2 - 2.5])
          rotate([0,90,0])
          cylinder(d = 5, h=urethane_roller_thickness*10, center=true);
      }
      translate([0,y_offset, high_roller_z])
        rotate([0,90,0])
        hub_and_spokes();
      translate([0,y_offset+ydiff, low_roller_z])
        rotate([0,90,0])
        hub_and_spokes();
      translate([-urethane_roller_outer_diameter/2,y_offset-5/2, 0])
        for(ang = [-8.5,8.5]) rotate([ang,0, 0])
        cube([urethane_roller_outer_diameter, 5, roller_tower_height-urethane_roller_outer_diameter]);
    }
  }
  difference() {
    translate([0,y_offset+ydiff,low_roller_z + urethane_roller_outer_diameter/2 + line_diameter/2])
      translate([-(urethane_roller_thickness + 2)/2, urethane_roller_outer_diameter/2-2.5, -(Eyelet_diameter + 5)/2])
      cube([urethane_roller_thickness + 2, 2.5, Eyelet_diameter + 5]);
    translate([0,y_offset+ydiff, low_roller_z + urethane_roller_outer_diameter/2 + line_diameter/2])
      rotate([-90,0,0])
      cylinder(d=Eyelet_diameter, h=20);
    translate([0,y_offset + ydiff, low_roller_z])
      scale((urethane_roller_outer_diameter + 4)/urethane_roller_outer_diameter)
      urethane_roller();
  }
  difference() {
    translate([0, y_offset, high_roller_z - (urethane_roller_outer_diameter/2 + line_diameter/2)])
      translate([-(urethane_roller_thickness + 2)/2, -urethane_roller_outer_diameter/2, -(Eyelet_diameter + 5)/2])
      cube([urethane_roller_thickness + 2, 2.5, Eyelet_diameter + 5]);
    translate([0, y_offset, high_roller_z - urethane_roller_outer_diameter/2 - line_diameter/2])
      rotate([90,0,0])
      cylinder(d=Eyelet_diameter, h=20);
    translate([0,y_offset, high_roller_z])
      scale((urethane_roller_outer_diameter + 4)/urethane_roller_outer_diameter)
      urethane_roller();
  }
}
