// Saltiga 0.55 mm / TCS230-family bench optical fixture. Units: mm.
// CAD-derived prototype, not a measured optical optimum.
// Assembly axes: line along X; Z up; detector and LEDs face down.
// Export parts individually. Carrier and lid already lie on their print faces;
// hood is inverted for support-free printing, arms flat on the bed.
part = "exploded"; // assembly, exploded, base, carrier, hood, lid, layout
pcb_x = 30.9;
pcb_y = 24;
pcb_t = 1.25;
pcb_clearance = 0.30; // per side
pcb_to_line = 18; // underside/solder face -> line CENTRE; try 14,18,22
sensor_window_depth = 3.0; // assumed underside -> top of clear package
sensor_x = 0; // measure package optical window relative to PCB centre
sensor_y = 0;
line_d = 0.55;
eyelet_hole_d = 4; // ceramic barrel seating bore, along X
eyelet_depth = 4.5; // through socket length; at least 4 mm
eyelet_socket_d = 6; // rounded holder envelope; 1 mm radial wall
// Inner faces, not socket centres. Clearance checked for finite 5 mm LEDs,
// full upper line circumference and X=-1.4..1.4 mm optical region.
// Matching bases are required when changing pcb_to_line.
eyelet_half_span = pcb_to_line <= 18 ?
  5.7 - (pcb_to_line-14)*0.275 : 4.6 - (pcb_to_line-18)*0.2;
slit_x = 1.2; // ALONG line / travel
slit_y = 0.8; // ACROSS line
membrane = 0.6;
hood_wall = 0.6; // minimum tip wall; nozzle 0.4 with thin-wall support
// Increase tip gap for tall heads so diagonal LED rays clear the hood lip.
// Override with -D aperture_gap=... after checking illumination.
aperture_gap = max(1.2,1.2*(slit_y/2+hood_wall)*
                       (pcb_to_line-10-line_d/2)/7.75);
window_clearance = 0.5;
board_foam_gap = 2.0; // lid underside -> PCB solder face
$fn = 48;
eps = 0.02;
W = 58; D = 42;
base_top = 14;
line_z = 16;
solder_z = line_z + pcb_to_line;
component_z = solder_z - pcb_t;
carrier_h = solder_z + board_foam_gap - base_top;
lid_z = base_top + carrier_h;
hood_bottom = line_z + line_d/2 + aperture_gap;
hood_top = solder_z - sensor_window_depth - window_clearance;
arm_t = 1.2;
arm_bottom = hood_top - arm_t;
arm_width = 5.0;
arm_end = 24;
hood_outer_top = 8;
hood_inner_top = 4;
assert(pcb_to_line >= 14 && pcb_to_line <= 22,
       "Validated carrier/taper range is pcb_to_line 14..22");
assert(abs(sensor_x)<1 && abs(sensor_y)<1,
       "Offsets >=1 mm need clearance/illumination review");
assert(hood_top > hood_bottom+4);
assert(slit_x>=0.8 && slit_x<=2 && slit_y>=0.8 && slit_y<=1);
assert(eyelet_depth >= 4);
assert(eyelet_hole_d == 4 && eyelet_socket_d == 6,
       "Eyelet illumination clearance validated for 4 mm bore / 6 mm holder");

module box_xy(x,y,z,h) { translate([-x/2,-y/2,z]) cube([x,y,h]); }
module screws(z,h,d=3.4) {
  for(x=[-23,23],y=[-16,16]) translate([x,y,z]) cylinder(d=d,h=h);
}
module taper(x0,y0,z0,x1,y1,z1) {
  hull() {box_xy(x0,y0,z0,eps);box_xy(x1,y1,z1-eps,eps);}
}
module base() {
  difference() {
    union() {
      difference() {
        box_xy(W,D,0,base_top);
        // Deep sloped background, retained between the close eyelet pedestals.
        translate([-20,0,0]) rotate([90,0,90]) linear_extrude(height=40)
          polygon([[-14,2],[14,6],[14,base_top+1],[-14,base_top+1]]);
      }
      for(s=[-1,1]) {
        // Pedestal terminates at line centre; light rays are above it.
        translate([s*(eyelet_half_span+eyelet_depth/2),0,0])
          box_xy(eyelet_depth,eyelet_socket_d,2,line_z-2);
        // Round top avoids the shadow of a rectangular socket tower.
        translate([s*(eyelet_half_span+eyelet_depth/2)-eyelet_depth/2,0,line_z])
          rotate([0,90,0]) cylinder(d=eyelet_socket_d,h=eyelet_depth);
      }
    }
    // Axial seating bores open through both faces; thread line through ceramics.
    for(s=[-1,1])
      translate([s*(eyelet_half_span+eyelet_depth/2)-eyelet_depth/2-eps,0,line_z])
        rotate([0,90,0]) cylinder(d=eyelet_hole_d,h=eyelet_depth+2*eps);
    screws(-eps,base_top+2*eps);
    for(x=[-23,23],y=[-16,16]) translate([x,y,-eps])
      rotate([0,0,30]) cylinder(d=5.7/cos(30),h=2.8,$fn=6);
  }
}

module carrier() {
  difference() {
    box_xy(W,D,0,carrier_h);
    // Taper gives a printable PCB ledge while clearing four LED bodies.
    taper(40,28,-eps,pcb_x-2,pcb_y-2,component_z-base_top);
    box_xy(pcb_x-2,pcb_y-2,component_z-base_top-eps,pcb_t+5);
    box_xy(pcb_x+2*pcb_clearance,pcb_y+2*pcb_clearance,
           component_z-base_top,pcb_t+board_foam_gap+eps);
    // Header/jumper exits at BOTH short PCB ends, away from screw columns.
    for(s=[-1,1]) translate([s*(W/2-6),0,component_z-base_top+4])
      cube([28,18,8],center=true);
    // Line-entry clearance at both ends. Seal excess gaps with black tape.
    for(s=[-1,1]) translate([s*24,0,2.5]) cube([12,6.4,5+eps],center=true);
    // Drop-in hood arms: 0.2 mm side clearance, floor sets optical height.
    for(s=[-1,1]) translate([s*14.5,sensor_y,arm_bottom-base_top])
      translate([-10.5,-arm_width/2-0.2,0])
      cube([21,arm_width+0.4,carrier_h]);
    // M2 self-tapping screw pilots into arm support floors.
    for(x=[-22,22]) translate([x,sensor_y,arm_bottom-base_top-5])
      cylinder(d=1.7,h=5+eps);
    screws(-eps,carrier_h+2*eps);
  }
}

module hood_assembled() {
  difference() {
    union() {
      hull() {
        box_xy(slit_x+2*hood_wall,slit_y+2*hood_wall,hood_bottom,eps);
        translate([sensor_x,sensor_y,0])
          box_xy(hood_outer_top,hood_outer_top,hood_top-eps,eps);
      }
      // Arms are above LED tips; no broad flange shading the line.
      translate([0,sensor_y,0]) box_xy(2*arm_end,arm_width,arm_bottom,arm_t);
    }
    box_xy(slit_x,slit_y,hood_bottom-eps,membrane+2*eps);
    hull() {
      box_xy(slit_x,slit_y,hood_bottom+membrane,eps);
      translate([sensor_x,sensor_y,0])
        box_xy(hood_inner_top,hood_inner_top,hood_top,eps);
    }
    for(x=[-22,22]) translate([x,sensor_y,arm_bottom-eps])
      cylinder(d=2.3,h=arm_t+2*eps);
  }
}
module hood_print() {
  translate([0,0,hood_top]) rotate([180,0,0]) hood_assembled();
}
module lid() {
  difference() {
    box_xy(W,D,0,2.5);
    screws(-eps,2.5+2*eps);
    // Continue the wire exits through cover edge, central board area covered.
    for(s=[-1,1]) translate([s*24,0,1.25]) cube([26,18,3],center=true);
  }
}
module board_preview() {
  color("darkgreen") box_xy(pcb_x,pcb_y,component_z,pcb_t);
  color([0.6,0.65,0.7,0.8]) translate([sensor_x,sensor_y,0])
    box_xy(5.3,6.2,solder_z-sensor_window_depth,sensor_window_depth-pcb_t);
  // 5 mm LED diameter assumed; centre rectangle supplied by user.
  color([1,1,0.75,0.8]) for(x=[-8.5,8.5],y=[-7.75,7.75])
    translate([x,y,solder_z-10]) cylinder(d=5,h=10-pcb_t);
}
module assembly(explode=0) {
  color([0.18,0.18,0.20]) base();
  color([0.3,0.3,0.33,0.60]) translate([0,0,base_top+explode]) carrier();
  color([0.1,0.1,0.12]) translate([0,0,explode]) hood_assembled();
  translate([0,0,explode]) board_preview();
  color([0.25,0.25,0.28,0.6]) translate([0,0,lid_z+2*explode]) lid();
  color("gold") translate([-38,0,line_z]) rotate([0,90,0])
    cylinder(d=line_d,h=76);
}
if(part=="base") base();
else if(part=="carrier") carrier();
else if(part=="hood") hood_print();
else if(part=="lid") lid();
else if(part=="exploded") assembly(14);
else if(part=="layout") {
  base(); translate([65,0,0]) carrier();
  translate([0,49,0]) lid(); translate([65,49,0]) hood_print();
} else assembly();
