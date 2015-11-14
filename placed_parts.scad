include <measured_numbers.scad>
include <util.scad>
include <design_numbers.scad>
use <Gears.scad>
use <parts.scad>
use <render_parts.scad>
use <Nema17_and_Ramps_and_bearings.scad>

// All modules in here can be rendered through the
// full_render module in Hangprinter.scad

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
            Line_contact_d_xy, 0.8);
    }
  }
  // Outer pair of a-lines
  pline(Wall_action_point_a + [-Abc_xy_split/2,0,0], Line_contact_abc_xy + [0,0,Line_contacts_abcd_z[A]]);
  pline(Wall_action_point_a + [ Abc_xy_split/2,0,0], Mirrored_line_contact_abc_xy + [0,0,Line_contacts_abcd_z[A]]);
  // Outer pair of b-lines
  pline(Wall_action_point_b + rotate_point_around_z(240, [-Abc_xy_split/2,0,0]),
        rotate_point_around_z(240, Line_contact_abc_xy) + [0,0,Line_contacts_abcd_z[B]]);
  pline(Wall_action_point_b + rotate_point_around_z(240, [ Abc_xy_split/2,0,0]),
        rotate_point_around_z(240, Mirrored_line_contact_abc_xy + [0,0,Line_contacts_abcd_z[B]]));
  // Outer pair of c-lines
  pline(Wall_action_point_c + rotate_point_around_z(120, [-Abc_xy_split/2,0,0]),
        rotate_point_around_z(120, Line_contact_abc_xy) + [0,0,Line_contacts_abcd_z[C]]);
  pline(Wall_action_point_c + rotate_point_around_z(120, [ Abc_xy_split/2,0,0]),
        rotate_point_around_z(120, Mirrored_line_contact_abc_xy + [0,0,Line_contacts_abcd_z[C]]));
  // Outer triple of d-lines
  for(i=[0,1,2])
    rotate([0,0,i*120])
      eline(Line_contact_d_xy + [0,0,Line_contacts_abcd_z[D]], Line_contact_d_xy + Ceiling_action_point);
}
//placed_lines();


module placed_sandwich(){
 translate([0,0,Line_contacts_abcd_z[A] - Snelle_height/2]) sandwich();
 translate([0,0,Line_contacts_abcd_z[B] - Snelle_height/2]) sandwich();
 translate([0,0,Line_contacts_abcd_z[C] - Snelle_height/2]) sandwich();
 translate([0,0,Line_contacts_abcd_z[D] - Snelle_height/2]) sandwich();
}
//placed_sandwich();
//placed_fish_rings();

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
module hobbed_insert(){
  color("grey")
    cylinder(r=Hobbed_insert_diameter/2, h=Hobbed_insert_height);
}
//hobbed_insert();

// Only for rendering
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
module assembled_drive(){
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
          -cos(Big_extruder_gear_rotation)*Pitch_difference_extruder
              - Hobb_from_edge,
             // Big extruder gear placed below this structure, z-dim
            Big_extruder_gear_height + 0.2])//Big gear|.2mm|support
      drive_support();
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
//assembled_drive(rotation=103);

module placed_abc_motors(){
    four_point_translate()
      translate([0,0,-Nema17_cube_height - 2])
        Nema17();
    rotate([0,0,3*72])
      translate([0,Four_point_five_point_radius, Bottom_plate_thickness + 1.4])
          motor_gear_d();
    rotate([0,0,2*72])
      translate([0,Four_point_five_point_radius, Bottom_plate_thickness + 1.4 + 5])
      motor_gear_c();
    rotate([0,0,1*72])
      translate([0,Four_point_five_point_radius, Bottom_plate_thickness + 1.4])
      motor_gear_b();
    rotate([0,0,4*72])
      translate([0,Four_point_five_point_radius, Bottom_plate_thickness + 1.4])
      motor_gear_a();
}
//placed_abc_motors();
//placed_sandwich();
//placed_lines();

module placed_extruder(){
  extruder_motor_translate(Extruder_motor_twist){
    Nema17();
    // Move drive up extruder motor shaft
    translate([0,0,Nema17_shaft_height - Small_extruder_gear_height+0])
      assembled_drive(Big_extruder_gear_rotation);
  }
}
//placed_extruder();

module placed_hotend(){
    // Manually placed.
    // For exact placement look in the difference
    // that creates groove in drive_support
    translate([-2.5,0.5,-80])
      rotate([0,0,56]){
        e3d_v6_volcano_hotend();
        // filament following placed hotend
        //cylinder(r=1.75/2,h=82);
      }
}
//placed_hotend();

module placed_ramps(){
  rotate([0,0,2*90+Extruder_motor_twist])
    translate([-60,-18,-Nema17_cube_height - Ramps_width - 2])
    rotate([90,0,0])
    Ramps();
}
//placed_ramps();

module placed_plates(){
  translate(Ceiling_action_point)
    top_plate();
  translate(Wall_action_point_a)
    side_plate2();
  translate(Wall_action_point_b)
    mirror([1,0,0])
    rotate([0,0,-120])
    side_plate1();
  translate(Wall_action_point_c)
    rotate([0,0,240])
    side_plate1();
}
//placed_plates();


//color("green")
//placed_lines();
//placed_sandwich();
//bottom_plate();
//placed_abc_motors();
