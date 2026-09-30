// One-channel optical test fixture. Three copies can test three line channels.
// X = line travel, Z = optical axis; PCB components face +Z.
include <../../lib/parameters.scad>

/* [Output] */
rig_part = "Open assembly"; // [Assembly, Open assembly, Section, Print layout, Base, Guide pair, Baffle, Hood]
show_hardware = true; // Review only; ignored by printable outputs.

/* [Optical experiment] */
// Change guides AND baffle together. The same hood covers all three settings.
led_to_line = 8; // [4,8,12]
aperture_width = 2.0; // [0.8,1.2,2.0]
aperture_length = 4;
line_diameter = 0.55;
// Fraction of LED-tip gap: mouth must stay below the oblique illumination
// rays. A slit right against the line would shadow all four board LEDs.
aperture_gap_fraction = 0.45;

/* [Measured module] */
pcb_length = 30.9;
pcb_width = 24;
pcb_thickness = 1.25;
led_rectangle = [17,15.5];
led_top_from_pcb_bottom = 10;
// Unmeasured: used only for clearance and hardware illustration.
led_diameter = 5;
sensor_package_top_from_pcb_bottom = 3.0;
// TAOS package die datum is nominally 0.88 above package seating plane.
// Die height is NOT the clear plastic package top.
sensor_die_from_pcb_bottom = pcb_thickness + 0.88;

/* [Fits] */
pcb_edge_clearance = 0.3;
eyelet_socket_clearance = 0.15; // Diametral; test a fit before pressing ceramic.
eyelet_flange_recess_depth = 0.8; // Unmeasured flange thickness.
hood_clearance = 0.3;

/* [Hidden] */
$fn = 64;
eps = 0.02;
base_thickness = 4;
pcb_bottom = 20; // 16 mm below-PCB space for downward headers and female jumpers.
base_size = [80,60];
guide_x = 28;
guide_thickness = 4;
guide_foot = [11,24,3];
line_z = pcb_bottom + led_top_from_pcb_bottom + led_to_line;
aperture_to_line = led_to_line*aperture_gap_fraction;
guide_axis_z = line_z - base_thickness;
baffle_bottom = pcb_bottom + sensor_package_top_from_pcb_bottom + 0.2;
baffle_plate_thickness = 1.2;
aperture_top = line_z-aperture_to_line;
aperture_lip = 0.6;
tube_lower_outer = [10.8,9.8];
tube_lower_inner = [8,7];
tube_upper_outer = [aperture_length+3.2,aperture_width+3.2];
hood_inside = [69,43];
hood_wall = 2;
hood_top = 54;
hood_roof = 2.5;
// Lowest background rib is 49.5 above the bed (7.5 above the highest line).
background_bottom = hood_top-hood_roof-2;
socket_d = Eyelet_diameter+eyelet_socket_clearance;
flange_d = Eyelet_flange_diameter+0.2;
die_to_line = line_z-pcb_bottom-sensor_die_from_pcb_bottom;
die_to_aperture = die_to_line-aperture_to_line;
// Geometric envelope only, not a focused image or calibrated response area.
function footprint(size) = size*die_to_line/die_to_aperture
                          + 1.15*aperture_to_line/die_to_aperture;

assert(led_to_line>=4 && led_to_line<=12,"Use a 4 to 12 mm LED-tip gap");
assert(aperture_width>=0.8 && aperture_width<=2,"Unsupported slit width");
assert(aperture_to_line>line_diameter/2+0.5,"Line can touch aperture");
assert(aperture_top>baffle_bottom+baffle_plate_thickness+2);
assert(led_rectangle[0]/2*aperture_gap_fraction>tube_upper_outer[0]/2+0.1
       || led_rectangle[1]/2*aperture_gap_fraction>tube_upper_outer[1]/2+0.1,
       "Baffle shadows the centre rays from the LEDs to the line");
assert(background_bottom-line_z>=7,"Background too close to line");
assert(socket_d<flange_d && flange_d<10-2,"Eyelet post has insufficient wall");
assert(guide_x+guide_foot[0]/2<hood_inside[0]/2-hood_clearance);
assert(pcb_length/2+pcb_edge_clearance+1.2<18,"PCB hits baffle pedestals");
// Nearest corner of the central tube stays clear of the LED holes.
assert(norm([led_rectangle[0]/2-tube_lower_outer[0]/2,
             led_rectangle[1]/2-tube_lower_outer[1]/2])>3.5+0.3);
echo("LED tip to line / die to line / aperture",led_to_line,die_to_line,
     [aperture_length,aperture_width]);
echo("Approximate line-plane geometric view envelope",footprint(aperture_length),
     footprint(aperture_width));

module rectangle_at(size,z,th=eps) {
  translate([-size[0]/2,-size[1]/2,z]) cube([size[0],size[1],th]);
}

module base() {
  difference() {
    union() {
      rectangle_at(base_size,0,base_thickness);
      // Four board edge pads; no assumptions about PCB mounting holes.
      for (x=[-1,1],y=[-1,1]) {
        translate([x*(pcb_length/2-1.5)-1.5,y*8-2,base_thickness])
          cube([3,4,pcb_bottom-base_thickness]);
        translate([x*(pcb_length/2+pcb_edge_clearance+0.6)-0.6,
                   y*8-2,base_thickness])
          cube([1.2,4,pcb_bottom+pcb_thickness+0.4-base_thickness]);
      }
      // Baffle rests on these pedestals, not on the PCB or LEDs.
      for (x=[-20,20],y=[-9,9])
        translate([x-2,y-2,base_thickness])
          cube([4,4,baffle_bottom-base_thickness]);
      // Short outer stops locate the removable hood without trapping it.
      for (x=[-1,1],y=[-1,1])
        translate([x*(hood_inside[0]/2+hood_wall+hood_clearance+0.6)-0.6,
                   y*17-3,base_thickness]) cube([1.2,6,2]);
    }
    for (x=[-36,36],y=[-26,26])
      translate([x,y,-eps]) cylinder(d=4.2,h=base_thickness+2*eps);
    for (x=[-guide_x,guide_x],y=[-8,8]) {
      translate([x,y,-eps]) cylinder(d=3.3,h=base_thickness+2*eps);
      // Captured M3 nut entered from below; guides bolt down from above.
      translate([x,y,-eps]) cylinder(d=6.6,h=2.6+eps,$fn=6);
    }
    for (x=[-20,20],y=[-9,9])
      translate([x,y,baffle_bottom-8]) cylinder(d=2.1,h=8+eps);
  }
}

// Local X points toward the outside of the rig. Print upright, clean the
// short horizontal socket bridge, and verify ceramic fit before pressing.
module guide() {
  difference() {
    union() {
      rectangle_at([guide_foot[0],guide_foot[1]],0,guide_foot[2]);
      rectangle_at([guide_thickness,10],0,guide_axis_z+5);
      // Buttresses on both sides leave screw access at Y=+/-8.
      for (s=[-1,1]) hull() {
        translate([s*3.2-1,-4,0]) cube([2,8,3]);
        translate([s*1.2-0.6,-4,guide_axis_z-5]) cube([1.2,8,1]);
      }
    }
    translate([-guide_thickness/2-eps,0,guide_axis_z]) rotate([0,90,0])
      cylinder(d=socket_d,h=guide_thickness+2*eps);
    translate([guide_thickness/2-eyelet_flange_recess_depth,0,guide_axis_z])
      rotate([0,90,0]) cylinder(d=flange_d,h=eyelet_flange_recess_depth+eps);
    for (y=[-8,8]) translate([0,y,-eps]) cylinder(d=3.3,h=3+2*eps);
    // Setting is engraved on the foot, outside the line path.
    translate([-4.5,10,2.6]) linear_extrude(height=0.5)
      text(str(led_to_line),size=2,halign="center",valign="center");
  }
}

module guides() {
  for (s=[-1,1]) translate([s*guide_x,0,base_thickness])
    scale([s,1,1]) guide();
}

// A broad opening around the entire interleaved die tapers toward a slit
// just below the line. The LEDs illuminate outside this black chimney.
module baffle() {
  difference() {
    union() {
      rectangle_at([44,32],baffle_bottom,baffle_plate_thickness);
      hull() {
        rectangle_at(tube_lower_outer,baffle_bottom,baffle_plate_thickness);
        rectangle_at(tube_upper_outer,aperture_top-aperture_lip,aperture_lip);
      }
    }
    hull() {
      rectangle_at(tube_lower_inner,baffle_bottom-eps);
      rectangle_at([aperture_length,aperture_width],aperture_top-aperture_lip);
    }
    rectangle_at([aperture_length,aperture_width],aperture_top-aperture_lip-eps,
                 aperture_lip+2*eps);
    for (x=[-1,1],y=[-1,1])
      translate([x*led_rectangle[0]/2,y*led_rectangle[1]/2,baffle_bottom-eps])
        cylinder(d=7,h=baffle_plate_thickness+2*eps);
    // Photo: four-pin headers are at the short ends, along Y, near X=+/-13.5.
    // Downward jumpers live below the PCB; these openings also admit top pins.
    for (x=[-13.5,13.5]) translate([x-2.5,-6,baffle_bottom-eps])
      cube([5,12,baffle_plate_thickness+2*eps]);
    for (x=[-20,20],y=[-9,9])
      translate([x,y,baffle_bottom-eps]) cylinder(d=2.7,h=baffle_plate_thickness+2*eps);
    translate([0,14.8,baffle_bottom+0.8]) linear_extrude(height=0.5)
      text(str(led_to_line," / ",aperture_width),size=1.8,
           halign="center",valign="center");
  }
}

module hood() {
  difference() {
    union() {
      difference() {
        rectangle_at(hood_inside+[2*hood_wall,2*hood_wall],base_thickness,
                     hood_top-base_thickness);
        rectangle_at(hood_inside,base_thickness-eps,
                     hood_top-hood_roof-base_thickness+eps);
      }
      // Triangular matte-black background ribs across X. They remove a
      // flat, directly reflecting surface from behind the line.
      for (y=[-9:3:9]) translate([-12,y,background_bottom]) rotate([0,90,0])
        linear_extrude(height=24)
          polygon([[0,0],[-2.02,-1.5],[-2.02,1.5]]);
    }
    // Common hood serves all guide heights. Tape/foam-mask unused height
    // around the line after threading; otherwise ambient leaks in here.
    for (s=[-1,1]) translate([s*(hood_inside[0]/2+hood_wall/2)-2,-1.5,
                            pcb_bottom+led_top_from_pcb_bottom+3])
      cube([4,3,10]);
    // Jumpers leave below the light path. An outer cover makes a dogleg.
    translate([-9,-hood_inside[1]/2-hood_wall-eps,base_thickness-eps])
      cube([18,hood_wall+2*eps,6]);
  }
  // Cable port cover: wires descend to the base before exiting sideways.
  difference() {
    translate([-12,-hood_inside[1]/2-hood_wall-5,base_thickness]) cube([24,5.2,9]);
    translate([-10,-hood_inside[1]/2-hood_wall-3,base_thickness-eps]) cube([20,3.3,7]);
    for (x=[-1,1]) translate([x*11-1.5,-hood_inside[1]/2-hood_wall-4,
                              base_thickness-eps]) cube([3,4,3.5]);
  }
}

module hardware() {
  color("seagreen") rectangle_at([pcb_length,pcb_width],pcb_bottom,pcb_thickness);
  color("gray") rectangle_at([6.2,5],pcb_bottom+pcb_thickness,
                              sensor_package_top_from_pcb_bottom-pcb_thickness);
  color("lightblue") rectangle_at([1.15,1.15],pcb_bottom+sensor_die_from_pcb_bottom,0.03);
  for (x=[-1,1],y=[-1,1]) color("ivory")
    translate([x*led_rectangle[0]/2,y*led_rectangle[1]/2,pcb_bottom+pcb_thickness])
      cylinder(d=led_diameter,h=led_top_from_pcb_bottom-pcb_thickness);
  // Header pitch is standard 2.54; end offsets are approximate from photo.
  for (x=[-13.5,13.5]) {
    color("dimgray") translate([x-1.3,-5.1,pcb_bottom-2.5]) cube([2.6,10.2,2.5]);
    for (y=[-1.5,-0.5,0.5,1.5]) color("silver")
      translate([x-0.32,y*2.54-0.32,pcb_bottom-8.5]) cube([0.64,0.64,6]);
    // Approximate female-jumper envelope; review only, omitted from print parts.
    color([0.55,0.15,0.65,0.2])
      translate([x-2,-6,pcb_bottom-15]) cube([4,12,15]);
  }
  // Ceramic guides are deliberately omitted; their sockets are the datum.
  color("orange") translate([-42,0,line_z]) rotate([0,90,0])
    cylinder(d=line_diameter,h=84);
}

module assembly(covered=true) {
  color([0.22,0.22,0.24]) base();
  color([0.3,0.3,0.32]) guides();
  color([0.42,0.42,0.44]) baffle();
  if (covered) color([0.18,0.18,0.2]) hood();
  if (show_hardware) hardware();
}

module print_layout() {
  base();
  translate([0,61,hood_top]) rotate([180,0,0]) hood();
  translate([65,-15,-baffle_bottom]) baffle();
  for (y=[18,47]) translate([65,y,0]) guide();
}

if (rig_part=="Assembly") assembly();
else if (rig_part=="Open assembly") assembly(false);
else if (rig_part=="Section") difference() {
  assembly();
  translate([-60,-60,-1]) cube([120,60,65]);
}
else if (rig_part=="Print layout") print_layout();
else if (rig_part=="Base") base();
else if (rig_part=="Guide pair") for (y=[-15,15]) translate([0,y,0]) guide();
else if (rig_part=="Baffle") translate([0,0,-baffle_bottom]) baffle();
else if (rig_part=="Hood") translate([0,0,hood_top]) rotate([180,0,0]) hood();
else assert(false,"Unknown rig_part");
