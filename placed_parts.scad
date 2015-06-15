include <measured_numbers.scad>
include <util.scad>
include <design_numbers.scad>
use <parts.scad>
use <render_parts.scad>

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
color("green")
placed_lines();
placed_sandwich();
bottom_plate();
//One point is exactly
//Line_contact_d_xy
//The other point satisfies
// sqrt(x*x + y*y) = Snelle_radius
// and
// dot(Line_contact_d_xy - (x, y), (x, y)) = 0
// so
// (a - x)x = (y - b)y
// where a and b are known
// ax - x*x = y*y - by
// ax + by = x*x + y*y = Snelle_radius*Snelle_radius


module xy_gatt_translate_1(back = 0, sidestep = 3){
  translate([sidestep,Full_tri_side/Sqrt3 - back,0])
    children(0);
}

module xy_gatt_translate_2(back = 0, sidestep = 3){
  rotate([0,0,-120])
  translate([-sidestep,Full_tri_side/Sqrt3 - back,0])
    children(0);
}

module placed_sandwich(){
  translate([0,0, Line_contacts_abcd_z[0] - Snelle_height/2]) sandwich();
  translate([0,0, Line_contacts_abcd_z[1] - Snelle_height/2]) sandwich();
  translate([0,0, Line_contacts_abcd_z[2] - Snelle_height/2]) sandwich();
  translate([0,0, Line_contacts_abcd_z[3] - Snelle_height/2]) sandwich();
}
//placed_sandwich();

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
  bearing_base_translation = Big_extruder_gear_height;
  hobbed_insert_placement = bearing_base_translation +
                            Bearing_623_width + 0.2;
    translate([0,-Pitch_difference_extruder,0]){
      translate([0,0,bearing_base_translation])
        Bearing_623();
      translate([0,0,-0.1])
        M3_screw(25, $fn=6);
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
module assembled_drive(rotation){
  // Height adapted so support always get high enough
  // no matter the rotation
  rotate([0,0,rotation]){
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
               -Bearing_623_outer_diameter/2 - 5 // match 5 in drive_support
                 // Take rotation into account x-dim
                 + sin(rotation)*Pitch_difference_extruder,
               // Take rotation into account y-dim (place hobb on edge)
               -cos(rotation)*Pitch_difference_extruder
                 - Hobb_from_edge,
                // Big extruder gear placed below this structure, z-dim
               Big_extruder_gear_height + 0.2]) // Big gear |.2mm| support
      for(k = [0,Drive_support_thickness // Bring supports to same z
                 + Bearing_623_width
                 + 0.2 // 623 |.2mm| Hobb |.2mm| 623
                 + Hobbed_insert_height
                 + 0.2])
        translate([0,0, k])
          mirror([0,0,k])
          drive_support(k);
  }
  support_bearing(rotation);
  // M3 through support bearing (just rendering)
  translate([0,0,-5.0])
  support_bearing_translate(rotation)
    M3_screw(19);
}
//assembled_drive(rotation=Big_extruder_gear_rotation);
//assembled_drive(rotation=103);

// Further assembly of parts...
module Nema17_with_drive(rotation=0){
  Nema17();
  // Move drive up extruder motor shaft
  translate([0,0,Nema17_shaft_height - Small_extruder_gear_height+1])
    assembled_drive(rotation);
}
//Nema17_with_drive(42);

module translated_extruder_motor_and_drive(extruder_motor_twist = 27,
                                            big_gear_rotation = 8){
  extruder_motor_translate(extruder_motor_twist)
    Nema17_with_drive(big_gear_rotation);
}
//translated_extruder_motor_and_drive(19, -47);

module placed_xy_motors(){
    four_point_translate()
      translate([0,0,-Nema17_cube_height - 2])
        Nema17();
    rotate([0,0,72])
      translate([0,Four_point_five_point_radius, 6+Motor_gear_height])
        mirror([0,0,1])
          motor_gear();
    rotate([0,0,4*72])
    translate([0,Four_point_five_point_radius, 11]) motor_gear();
    rotate([0,0,3*72])
    translate([0,Four_point_five_point_radius, 5]) motor_gear();
    rotate([0,0,2*72])
    translate([0,Four_point_five_point_radius, 9]) motor_gear();
}
//placed_xy_motors();

// These are adjusted by visually comparing to lines().
// All hard coded numbers should be parameterized
module placed_gatts(){
  th  = Bottom_plate_thickness; 
  gap = 0.2;
  lh  = Lock_height;
  bw  = Bearing_608_width;
  z_back = d_gatt_back;
  z_rotate = 19;
  z_height = th+lh/4+gap/2+2;
  xy_height_1 = z_height + gap+lh+bw;
  xy_height_2 = xy_height_1 + gap+lh+bw;
  xy_height_3 = xy_height_2 + gap+lh+bw;
  // xy_back and xy_sidestep is adjusted manually to fit
  // Splitrot_1 and Splitrot_2
  xy_back = 31;
  xy_sidestep = 25;
  gatt_1_rotate = 0;
  gatt_2_rotate = 0;

  // Z-gatts
  z_gatt_translate(z_back)
      gatt(z_height, 180);
  // Lowest xy-gatts
  xy_gatt_translate_1(xy_back, xy_sidestep)
    rotate([0,0,gatt_1_rotate]) gatt(xy_height_1,-30);
  xy_gatt_translate_2(xy_back, xy_sidestep)
    rotate([0,0,gatt_2_rotate]) gatt(xy_height_1,46);
  // Middle xy-gatts
  rotate([0,0,120]){
    xy_gatt_translate_1(xy_back, xy_sidestep)
      rotate([0,0,gatt_1_rotate]) gatt(xy_height_2,-30);
    xy_gatt_translate_2(xy_back, xy_sidestep)
      rotate([0,0,gatt_2_rotate]) gatt(xy_height_2,46);
  }
  // Highest gatts 
  rotate([0,0,240]){
    xy_gatt_translate_1(xy_back, xy_sidestep)
      rotate([0,0,gatt_1_rotate]) gatt(xy_height_3,-30);
    xy_gatt_translate_2(xy_back, xy_sidestep)
      rotate([0,0,gatt_2_rotate]) gatt(xy_height_3,46);
  }
}
//placed_gatts();

// TODO: Have hobb centered
module placed_extruder(){
  translated_extruder_motor_and_drive(
      extruder_motor_twist = Extruder_motor_twist,
      big_gear_rotation  = Big_extruder_gear_rotation);
}
//placed_extruder();

module placed_hotend(){
  translate([0,0,-81])
    rotate([0,0,Extruder_motor_twist])
    reprappro_hotend();
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
  translate([0,0,250])
    mirror([0,0,1])
    top_plate();
  for(k=[0,1]){
    translate([0,0,-k*(Lock_height+Bearing_608_width)-97])
      mirror([k,0,0])
      rotate([0,0,-120])
      translate([0,-270,0])
      side_plate1();
  }
  translate([0,-270,(Lock_height+Bearing_608_width)-97])
    side_plate2();
}
//placed_plates();
