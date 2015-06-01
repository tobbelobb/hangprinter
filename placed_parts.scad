include <measured_numbers.scad>
include <design_numbers.scad>
include <parts.scad>

// All modules in here can be rendered through the
// full_render module in Hangprinter.scad

// Translation, iterating and rotating modules
module z_gatt_translate(back = 0){
  for(i=[0,120,240])
    rotate([0,0,i])
      translate([0,Full_tri_side/Sqrt3 - back,0])
        children(0);
}

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
  th  = Bottom_plate_thickness; 
  gap = 0.2;
  lh  = Lock_height;
  bw  = Bearing_608_width;
  translate([0,0, th + lh/4 + gap/2]) sandwich();
  translate([0,0, th + lh/4 + gap/2 + gap + lh + bw]) sandwich();
  translate([0,0, th + lh/4 + gap/2 + 2*(gap + lh + bw)]) sandwich();
  translate([0,0, th + lh/4 + gap/2 + 3*(gap + lh + bw)]) sandwich();
}

// Used by support bearing in drive
module support_bearing_translate(rotation){
  translate([(Hobbed_insert_diameter + 
              Bearing_623_outer_diameter)/2 + 1.5
              + sin(rotation)*Pitch_difference_extruder,
              - cos(rotation)*Pitch_difference_extruder,15]) children(0);
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
//hobbed_insert()

// Only for rendering
module translated_insert_tower(){
  bearing_base_translation = 8.3;
  hobbed_insert_placement = bearing_base_translation +
                            Bearing_623_width + 0.2;
    translate([0,-Pitch_difference_extruder,1.5]){
      translate([0,0,bearing_base_translation])
        Bearing_623();
      translate([0,0,2])
        M3_screw(25, $fn=6);
      translate([0,0,hobbed_insert_placement])
        hobbed_insert();
      translate([0,0, hobbed_insert_placement + Hobbed_insert_height
                      + 0.2])
        Bearing_623();
  }
}
//translated_insert_tower();

module assembled_drive(rotation){
  // Height adapted so support always get high enough
  // no matter the rotation
  rotate([0,0,rotation]){
    small_extruder_gear(Small_extruder_gear_height);
    translate([0,-Pitch_difference_extruder,1.5])
      large_extruder_gear(Big_extruder_gear_height);
    translated_insert_tower();
  } // end rotate

  difference(){
    translate([-(Bearing_623_outer_diameter + 6)/2
        + sin(rotation)*Pitch_difference_extruder,
        -cos(rotation)*Pitch_difference_extruder - 10,
        Big_extruder_gear_height + 1.5 + 0.7]){
      // Drive support (holds bearings in place)
      for(k = [0,Hobbed_insert_height + 1.1*Bearing_623_width + 
          Drive_support_thickness])
        translate([0,0, k])
          mirror([0,0,k])
          drive_support();
    }
    // Space for tower in bearing supports
    rotate([0,0,rotation])
      translated_insert_tower();
    // Hole through support bearing (antimateria)
    translate([0,0,-5.5])
    support_bearing_translate(rotation)
      M3_screw(Big);
  }
  support_bearing(rotation);
  // M3 through support bearing (materia)
  translate([0,0,-5.5])
  support_bearing_translate(rotation)
    M3_screw(19);
}
//assembled_drive(rotation=Big_extruder_gear_rotation);

// Further assembly of parts. For rendering.
module Nema17_with_drive(rotation=0){
  Nema17();
  translate([0,0,Nema17_shaft_height - 6])
    assembled_drive(rotation);
}
//Nema17_with_drive();

module translated_extruder_motor_and_drive(extruder_motor_twist = 12,
                                            large_gear_rotation = 0){
  difference(){
    extruder_motor_translate(extruder_motor_twist)
      translate([0,0,-Nema17_cube_height - 2])
        Nema17_with_drive(large_gear_rotation);
  }
}
//translated_extruder_motor_and_drive(44, -26);

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

// These are adjusted by visually comparing to lines().
// All hard coded numbers should be parameterized
module placed_gatts(){
  th  = Bottom_plate_thickness; 
  gap = 0.2;
  lh  = Lock_height;
  bw  = Bearing_608_width;
  z_back = Z_gatt_back;
  z_rotate = 19;
  z_height = th+lh/4+gap/2+2;
  xy_height_1 = z_height + gap+lh+bw;
  xy_height_2 = xy_height_1 + gap+lh+bw;
  xy_height_3 = xy_height_2 + gap+lh+bw;
  // xy_back and xy_sidestep is adjusted manually to fit
  // Splitrot_1 and Splitrot_2
  xy_back = 31;
  xy_sidestep = 25;
  gatt_1_rotate = -90+Splitrot_1;
  gatt_2_rotate = -90+Splitrot_2 + 120;

  // Z-gatts
  z_gatt_translate(z_back)
    rotate([0,0,-90+Middlerot+120])
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

module placed_extruder(){
  translated_extruder_motor_and_drive(
      extruder_motor_twist = Extruder_motor_twist,
      large_gear_rotation  = Big_extruder_gear_rotation);
}

module placed_hotend(){
  translate([0,0,-81])
    rotate([0,0,Extruder_motor_twist])
    reprappro_hotend();
}

module placed_ramps(){
  rotate([0,0,2*90+Extruder_motor_twist])
    translate([-60,-18,-Nema17_cube_height - Ramps_width - 2])
    rotate([90,0,0])
    Ramps();
}

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
