include <measured_numbers.scad>
include <util.scad>
include <design_numbers.scad>
use <Gears.scad>
use <parts.scad>
use <render_parts.scad>
use <Nema17_and_Ramps_and_bearings.scad>

// All modules in here can be rendered through the
// full_render module in Hangprinter.scad

// TODO: it is the lines that are wrong, not top_plate and bottom_plate
module placed_lines(){
  th  = Bottom_plate_thickness;
  // Lines from sandwich out to gatts
  for(i=[0,1,2]){
    rotate([0,0,i*120]){
      // Pairs of inner abc-lines (onboard printer)
      translate([0,0, Line_contacts_abcd_z[i]]){
        pline(tangent_point(Snelle_radius, Line_contact_abc_xy),
            Line_contact_abc_xy, 0.8);
        pline(tangent_point_2(Snelle_radius,
              Mirrored_line_contact_abc_xy),
            Mirrored_line_contact_abc_xy, 0.8);
      }
      // inner d-lines (onboard printer)
      translate([0,0, Line_contacts_abcd_z[3]])
        pline(tangent_point_3(Snelle_radius, Line_contact_d_xy),
            Line_contact_d_xy
            + [0,-Bearing_623_outer_diameter/2,0] , 0.8);
    }
  }
      // Outer pair of a-lines
      pline(Wall_action_point_a + [0,0,0.4*Bearing_623_outer_diameter] + [-Abc_xy_split/2,0,0],
            Line_contact_abc_xy + [0,0,Line_contacts_abcd_z[A]]);
      pline(Wall_action_point_a + [0,0,0.4*Bearing_623_outer_diameter] + [ Abc_xy_split/2,0,0],
            Mirrored_line_contact_abc_xy + [0,0,Line_contacts_abcd_z[A]]);
      pline(Wall_action_point_a + [0,0,0.4*Bearing_623_outer_diameter] + [-Abc_xy_split/2,0,0],
            Wall_action_point_a + [0,0,0.4*Bearing_623_outer_diameter] + [ Abc_xy_split/2,0,0]);
      // Outer pair of b-lines
      pline(Wall_action_point_b + [0,0,0.4*Bearing_623_outer_diameter] + rotate_point_around_z(240, [-Abc_xy_split/2,0,0]),
            rotate_point_around_z(240, Line_contact_abc_xy) + [0,0,Line_contacts_abcd_z[B]]);
      pline(Wall_action_point_b + [0,0,0.4*Bearing_623_outer_diameter] + rotate_point_around_z(240, [ Abc_xy_split/2,0,0]),
            rotate_point_around_z(240, Mirrored_line_contact_abc_xy + [0,0,Line_contacts_abcd_z[B]]));
      pline(Wall_action_point_b + [0,0,0.4*Bearing_623_outer_diameter] + rotate_point_around_z(240, [ Abc_xy_split/2,0,0]), Wall_action_point_b + [0,0,0.4*Bearing_623_outer_diameter] + rotate_point_around_z(240, [-Abc_xy_split/2,0,0]));
      // Outer pair of c-lines
      pline(Wall_action_point_c + [0,0,0.4*Bearing_623_outer_diameter] + rotate_point_around_z(120, [-Abc_xy_split/2,0,0]),
            rotate_point_around_z(120, Line_contact_abc_xy) + [0,0,Line_contacts_abcd_z[C]]);
      pline(Wall_action_point_c + [0,0,0.4*Bearing_623_outer_diameter] + rotate_point_around_z(120, [ Abc_xy_split/2,0,0]),
            rotate_point_around_z(120, Mirrored_line_contact_abc_xy + [0,0,Line_contacts_abcd_z[C]]));
      pline(Wall_action_point_c + [0,0,0.4*Bearing_623_outer_diameter] + rotate_point_around_z(120, [-Abc_xy_split/2,0,0]), Wall_action_point_c + [0,0,0.4*Bearing_623_outer_diameter] + rotate_point_around_z(120, [ Abc_xy_split/2,0,0]));
  // d-lines
  for(i=[0,1,2])
    rotate([0,0,i*120]){
      eline(Line_contact_d_xy + [0,-0.4*Bearing_623_outer_diameter,Line_contacts_abcd_z[D]], Line_contact_d_xy + [0,-Bearing_623_outer_diameter/2,0] + Ceiling_action_point);
      eline(Line_contact_d_xy + [0,0.5*Bearing_623_outer_diameter,Line_contacts_abcd_z[D]], Line_contact_d_xy+ [0,-Bearing_623_outer_diameter/2,0] + [0,1.0*Bearing_623_outer_diameter,0] + Ceiling_action_point);
    }
}
//placed_lines();

module bearing_filled_sandwich(worm=false){
  if(worm){
    //color(Printed_color_2)
      translate([0,0,Sandwich_height])
      rotate([180,0,0])
      sandwich(worm=true); // Have worm gear as far down as possible
  } else {
    //color(Printed_color_2)
      sandwich();
  }
  Bearing_608();
  translate([0,0,Bearing_608_width])
  color("gold") lock(Lock_radius_1, Lock_radius_2, Lock_height);
}

module placed_sandwich(a_render=true, b_render=true, c_render=true, d_render=true){
  if(a_render){
    translate([0,0,Line_contacts_abcd_z[A] - Snelle_height/2])
      bearing_filled_sandwich();
  }
  if(b_render){
    translate([0,0,Line_contacts_abcd_z[B] - Snelle_height/2])
      bearing_filled_sandwich();
  }
  if(c_render){
    translate([0,0,Line_contacts_abcd_z[C] - Snelle_height/2])
      // Brim must not collide with d motor
      bearing_filled_sandwich();
  }
  if(d_render){
    translate([0,0,Bottom_plate_thickness + Bottom_plate_sandwich_gap])
      // Brim must not collide with d motor
      bearing_filled_sandwich(worm=true);
  }
}
//placed_sandwich();

module sandwich_marks(){
  intersection(){ // Intersection made to mark part of sandwich
    placed_sandwich();
    translate([34,-5,-5])
      cube([20,10,103]);
  }
}

// Used by support bearing in drive, only rendering
module support_bearing_translate(rotation){
  translate([Hobbed_insert_diameter/2
             + Bearing_623_outer_diameter/2
             + Extruder_filament_opening
             + sin(rotation)*Pitch_difference_extruder,
             - cos(rotation)*Pitch_difference_extruder,9]) children(0);
}

// For rendering
module support_bearing(rotation){
  support_bearing_translate(rotation)
    Bearing_623();
}
//support_bearing(0);

// Only for rendering
// TODO: Remove part of Tble-struder
module translated_hobb_tower(){
  bearing_base_translation = Big_extruder_gear_height+1.2;
  hobbed_insert_placement = bearing_base_translation +
                            Bearing_623_width + 0.2;
    translate([0,-Pitch_difference_extruder,1]){
      translate([0,0,bearing_base_translation])
        Bearing_623();
      translate([0,0,-2.1])
        M3_screw(27, $fn=6);
      translate([0,0,hobbed_insert_placement])
        hobbed_insert();
      translate([0,0, hobbed_insert_placement + Hobbed_insert_height
                      + 0.2])
        Bearing_623();
  }
}
//translated_hobb_tower();

// Support and big extruder gear are translated to fit around
// a non-translated small extruder gear.
// rotation is around the small gear
// TODO: Remove part of Tble-struder
module tble_struder(){
  // Height adapted so support always get high enough
  // no matter the Big_extruder_gear_rotation
  rotate([0,0,Big_extruder_gear_rotation]){
    translate([0,0,-2])
    small_extruder_gear(Small_extruder_gear_height);
    translate([0,-Pitch_difference_extruder,0])
      big_extruder_gear(Big_extruder_gear_height);
    // Hobb (only for rendering, goes through big gear and support)
    translated_hobb_tower();
  } // end rotate

  difference(){
      // Hobb, support bearing and big gear are placed first,
      // drive supports translated to fit them here.
    translate([ // Center 623 in x-dim
          -Bearing_623_outer_diameter/2 - 5//match 5 in drive_support
              // Take rotation into account x-dim
          + sin(Big_extruder_gear_rotation)*Pitch_difference_extruder,
            // Take rotation into account y-dim (place hobb on edge)
          - cos(Big_extruder_gear_rotation)*Pitch_difference_extruder
              - Hobb_from_edge,
             // Big extruder gear placed below this structure, z-dim
            Big_extruder_gear_height + 0.2])//Big gear|.2mm|support
      drive_support(2);
  }
  support_bearing(Big_extruder_gear_rotation);
  // M3 through support bearing (just rendering)
  translate([0,0,-5.0])
  support_bearing_translate(Big_extruder_gear_rotation)
    M3_screw(19);
}
//translate([33,-70,12]) rotate([-90,0,0]){
//  e3d_v6_volcano_hotend();
//  color("purple") cylinder(r=1.75/2, h=60);
//}
//tble_struder(rotation=103);

// Motors and gears are placed out separately... Not optimal.
module placed_abc_motors(motor_gear_render=true){
  four_point_translate(d_object=false) // don't place out a d-motor
    translate([0,0,-Nema17_cube_height])
    rotate([0,0,45])
    Nema17();
  if(motor_gear_render){
    color(Printed_color_2){
      rotate([0,0,C_placement_angle])
        translate([0,Four_point_five_point_radius, Bottom_plate_thickness + 5])
        motor_gear_c();
      rotate([0,0,B_placement_angle])
        translate([0,Four_point_five_point_radius, Bottom_plate_thickness])
        motor_gear_b();
      rotate([0,0,A_placement_angle])
        translate([0,Four_point_five_point_radius, Bottom_plate_thickness])
        motor_gear_a();
    }
  }
}
//placed_abc_motors();
//placed_sandwich();
//placed_lines();

module placed_d_motor(with_worm=true){
  d_motor_move(){
    Nema17();
    if(with_worm){
      //color(Printed_color_2)
      color("lightGrey")
        translate([0,0,Pushdown_d_motor])
        worm(); // Keep worm in center to more easily adjust radius to worm_plate later
    }
  }
}
//placed_d_motor();

module placed_extruder(plastic_parts=true){
  extruder_motor_translate(){
    Nema17();
    if(plastic_parts){
      translate([0,0,Nema17_cube_height])
        sstruder(true);
    }
    // Move drive up extruder motor shaft
    // TODO: Remove part of Tble-extruder
    //translate([0,0,Nema17_shaft_height - Small_extruder_gear_height+0])
    //  tble_struder(Big_extruder_gear_rotation);
  }
}
//placed_extruder();

module placed_hotend(){
    // Manually placed.
    // For exact placement look in the difference
    // that creates groove in drive_support
    translate([0,0,-E3d_heatsink_height + Sstruder_hot_end_bore_z])
      rotate([0,0,17]){
        e3d_v6_volcano_hotend(fan=0);
        // filament following placed hotend
        //cylinder(r=1.75/2,h=82);
      }
}
//placed_hotend();

module placed_ramps(){
  rotate([0,0,2*90])
    translate([-60,-18,-Nema17_cube_height - Ramps_width - 7])
    rotate([90,0,0])
    Ramps();
  color(Printed_color_1)
    Fancy_Ramps_holder();
}
//placed_ramps();

module placed_plates(){
  translate(Ceiling_action_point)
    top_plate();
  translate(Wall_action_point_a)
    side_plate2();
  translate(Wall_action_point_b)
    rotate([0,0,-90+30])
      mirror([1,0,0])
        side_plate3();
  translate(Wall_action_point_c)
    rotate([0,0,90-30])
      side_plate3();
}
//placed_plates();


//color("green")
//placed_lines();
//placed_sandwich();
//bottom_plate();
//placed_abc_motors();
