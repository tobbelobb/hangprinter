include <measured_numbers.scad>
include <design_numbers.scad>
use <parts.scad>
use <placed_parts.scad>
use <render_parts.scad>
use <Nema17_and_Ramps_and_bearings.scad>

// Style:
//  - Global parameters starts with capital letter, others don't

// TODO:
//  - Improve extruder drive and hotend mount.
//    Complete rewrite of those
//    (assembling along z-direction from the beginning)
//    might be worth it...

// Rendering control
// TODO: move _all_ rendering control back up here
render_bottom_plate  = true;
render_sandwich      = false;
render_abc_motors    = false;
render_fish_rings    = false;
render_lines         = false;
render_extruder      = false;
render_hotend        = false;
render_ramps         = false;
render_plates        = false;
render_filament      = false;
render_d_motor       = false;

// Measure distance to hot end tip
//mirror([0,0,1])
//  %cylinder(r=10, h=105.3);

module full_render(){
  if(render_bottom_plate){
    color(Printed_color_1)
    bottom_plate();
    // For better rendering performance, precompile bottom_plate
    //precompiled("stl/Bottom_plate_qty_1.stl");
    //precompiled("stl/Complete_printer_24_nov_2016/Sparser_bottom_plate_qty_1.stl");
  }
  if(render_sandwich){
    // For better rendering performance, precompile placed sandwich
    //placed_sandwich(false, false, false, true);
    placed_sandwich(true, true, true, true);
    //color(Printed_color_2)
    //precompiled("stl/Sandwich_25_Nov_2016.stl");
  }
  if(render_abc_motors){
    placed_abc_motors(motor_gear_render=true);
  }
  if(render_d_motor){
    placed_d_motor();
  }
  if(render_fish_rings){
    placed_fish_rings();
  }
  if(render_lines){
    color("yellow")
    placed_lines();
  }
  if(render_extruder){
    placed_extruder(true, true);
  }
  if(render_hotend){
    placed_hotend();
  }
  if(render_ramps){
    placed_ramps();
  }
  if(render_plates){
    color(Printed_color_1)
    placed_plates();
  }
  if(render_filament){
    filament();
  }
}
//scale([150/200,150/200,1])
rotate([0,0,15])
full_render();
//rotate([0,0,-15])
//  %cube([150,150,30], center=true);

module check_if_bottom_plate_fits_print_bed(){
  translate([-Full_tri_side/2 - 4,-Full_tri_side*sqrt(3)/6 - 4,0])
    rotate([0,0,-15])
    %cube([200,200,10]);
}
//check_if_bottom_plate_fits_print_bed();

module demonstrate_line_length_calibration(){
  // Demonstrate calibration difficulty of point C
  c_split = [Abc_xy_split/2*cos(60), Abc_xy_split/2*sin(60), 0];
  // Where one C line hits fish eye when printer at home position
  printer_c = [-Full_tri_side/(2*Sqrt3)*sin(120),
            -Full_tri_side/(2*Sqrt3)*cos(120),
            Line_contacts_abcd_z[C]]
              + c_split;
  // Where one C line is anchored
  wall_c = Wall_action_point_c + c_split;
  x_length = abs(wall_c[X] - printer_c[X]);
  y_length = abs(wall_c[Y] - printer_c[Y]);
  z_length = abs(wall_c[Z] - printer_c[Z]);

  translate(printer_c){
    translate([0,0,-z_length]){
      rotate([0,0,120])
      translate([0,-7,0])
        // Z-measurment
        text_cube([2,14,z_length], "C_Z");
      translate([-5, 0, -2])
        text_cube([10,y_length,2], "ANCHOR_C_Y"); // text_cube() defined in util.scad
      translate([0,y_length+5,-2]){
        rotate([0,0,180])
          text_cube([x_length,10,2], "ANCHOR_C_X");
      }
    }
  }

  // Render C line action point --> anchor point
  color("yellow")
    pline(printer_c, wall_c);
}
//demonstrate_line_length_calibration();

//%cube([900,900,2],center=true);

module demonstrate_origo_finding(){
  color("yellow")
  cylinder(r1=0, r2=20, h=40);
  color("yellow")
  translate([0,0,39])
    cylinder(r=2, h=Ceiling_action_point[Z] - 39);
  translate([0,0,-2.5])
  %cube([900,900,5], center=true);
  color("red")
  sphere(5);
}
//demonstrate_origo_finding();

//translate(Ceiling_action_point)
//  color("red")
//  sphere(1, $fn=100);

module measurments(){
  color("red") sphere(5);
  translate(Ceiling_action_point)
  color("red") sphere(5);
  translate(Wall_action_point_a)
  color("red") sphere(5);
  translate(Wall_action_point_b)
  color("red") sphere(5);
  translate(Wall_action_point_c)
  color("red") sphere(5);
  color("yellow") pline([0,0,0], Wall_action_point_a);
  color("yellow") pline([0,0,0], Wall_action_point_b);
  color("yellow") pline([0,0,0], Wall_action_point_c);
  color("yellow") cylinder(r=0.7, h=Ceiling_action_point[Z]);
  color("yellow") pline(Wall_action_point_a, Wall_action_point_b);
  color("yellow") pline(Wall_action_point_a, Wall_action_point_c);
//  color("yellow") pline(Wall_action_point_b, Wall_action_point_c);
  module textbox(letter){
    sides = 50;
    rotate([42,0,20])
    translate([-sides/2,-sides/2,0]){
      cube([sides,sides,2]);
      translate([sides/2, sides/2,0])
      color("black")
        linear_extrude(height=3)
        text(size=sides*0.9, letter, valign="center", halign="center");
    }
  }
  translate(Wall_action_point_a/2)
    textbox("a");
  translate(Wall_action_point_b/2)
    textbox("b");
  translate(Wall_action_point_c/2)
    textbox("c");
  translate(Ceiling_action_point/2)
    textbox("d");
  translate((Wall_action_point_a+Wall_action_point_b)/2)
    textbox("s");
  translate((Wall_action_point_a+Wall_action_point_c)/2)
    textbox("f");
//  translate((Wall_action_point_b+Wall_action_point_c)/2)
//    textbox("f");

}
//measurments();

module cross_hair_average_c_action_point(){
  c_split = [Abc_xy_split/2*cos(60), Abc_xy_split/2*sin(60), 0];
  printer_c = [-Full_tri_side/(2*Sqrt3)*sin(120),
               -Full_tri_side/(2*Sqrt3)*cos(120),
               Line_contacts_abcd_z[C]]
             + c_split;
  pline(printer_c, printer_c - 2*c_split);
  translate([-59.8*sqrt(3)/2, 59.8/2,0])
    cylinder(r=2, h=50);
}

module echo_calibration_numbers(){
  echo("a = ", norm(Wall_action_point_a));
  echo("b = ", norm(Wall_action_point_b));
  echo("c = ", norm(Wall_action_point_c));
  echo("d = ", norm(Ceiling_action_point));
  echo("s = ", norm(Wall_action_point_a-Wall_action_point_b));
  echo("f = ", norm(Wall_action_point_a-Wall_action_point_c));
  echo("B_x = ", Wall_action_point_b[X]);
  echo("B_y = ", Wall_action_point_b[Y]);
  echo("C_x = ", Wall_action_point_c[X]);
  echo("C_y = ", Wall_action_point_c[Y]);
  echo("Line_action_point_abc_xy = ", Line_action_point_abc_xy);
  // Compute action points above print surface:
  echo("Line_contacts_abcd_z[A] = ", Line_contacts_abcd_z[A]);
  echo("ANCHOR_A_Z = ", Line_contacts_abcd_z[A] + 105.35);
  echo("ANCHOR_B_Z = ", Line_contacts_abcd_z[B] + 105.35);
  echo("ANCHOR_C_Z = ", Line_contacts_abcd_z[C] + 105.35);
  echo("ANCHOR_D_Z = ", Line_contacts_abcd_z[D] + 105.35);
  echo("z_diff = ", Line_contacts_abcd_z[A] - Line_contacts_abcd_z[B]);
}


// To render/show how d line length adjustment is done...
//for(i=[0,120,240]){
//  rotate([0,0,i]){
//    translate(Line_contact_d_xy){
//      translate([0,0,Line_contacts_abcd_z[D]]){
//        translate([0,Bearing_623_outer_diameter/2,0])
//          rotate([0,0,-20])
//          translate([0,0,1])
//          rotate([0,-45,0])
//          // Channel for d line
//          translate([0,0,-11])
//          color("yellow")
//cylinder(r=0.7, h=11);
//          translate([0,0,-1.5]){
//            rotate([0,-90,0])
//              // Hole for d line length adjusting screw
//              color("grey")
//translate([0,0,-9])
//M3_screw(20,true);
//          }}}}}
