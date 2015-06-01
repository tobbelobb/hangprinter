include <placed_parts.scad>

// TODO:
//  - Place gatts reliably with screw holes or similar
//  - Place hot end reliably
// Style:
//  - Spaces separate arguments and long words only
//  - Global parameters starts with capital letter, others don't
//  - Modules that are meant as anti-materia starts with capital letter

// Rendering control
render_bottom_plate = true;
render_sandwich     = true;
render_xy_motors    = true;
render_gatts        = true;
render_lines        = true;
render_extruder     = true;
render_hotend       = true;
render_ramps        = true;
render_plates       = true;

// Modules not in contact with any printed parts
// Just explanatory
module filament(){
  color("white") translate([0,0,-50]) cylinder(r=1.75/2, h = 300);
}

module line(length=70, angle_1=0, angle_2=0, second_line_length=225){
  snellekant = 0.8;
  radius = 0.8;
  dia = Bearing_623_vgroove_small_diameter;
  color("green"){
    translate([radius + Snelle_radius,0,0])
      rotate([90,0,0])
        cylinder(r=radius, h=length);
    translate([radius + Snelle_radius,
               -length+(dia/2)*(cos(angle_1)-1)*(1-sin(angle_2)),
               0])
    rotate([angle_1,angle_2,0])
      translate([0,-dia/2,0])
        rotate([90,0,0])
          cylinder(r=radius, h=second_line_length);
    }
}
//line(angle_1=-45, angle_2=-60);

module placed_lines(){
  th  = Bottom_plate_thickness; 
  gap = 0.2;
  lh  = Lock_height;
  bw  = Bearing_608_width;
  bt  = 1.9; // line radius, edge of snelle and some space
  i = 0;
  for(i=[0,120,240])
    rotate([0,0,i]){
      translate([0,0, bt+th+lh/4+gap/2 + (1 + i/120)*(gap + lh + bw)]){
        // Left line as seen from above
        rotate([0, 0, Splitrot_1]) line(87,36,32);
        // Right line as seen from above
        rotate([0, 0, Splitrot_2]) line(84,71,-58);
      }
      translate([0, 0, bt+th+lh/4+gap/2])
        rotate([0, 0, Middlerot-0.3])
          line(114-Z_gatt_back,-90,0);
    }
}


module cooler_rib(){
  th = 1.8;
  cube([2,40,40]);
  for(i=[0:(40-th)/6:40-th]){
    translate([0,0,i])
      cube([12,40,th]);
  }
}
//cooler_rib();

module fan(){
  difference(){
    cube([40,40,11]);
    translate([20,20,-1])
      cylinder(r=18,h=Big);
  }
}
//fan();

module reprappro_hotend(){
  // Pen
  color("FireBrick"){
  cylinder(r1=0.7, r2=2.7, h=2);
  translate([0,0,2])
    cylinder(r=2.7, h = 30);
  }
  // Heater block
  color("red")
  translate([-8, -13, 4])
    cube([17, 21, 7.5]);
  // Cooler block
  color("RoyalBlue")
  translate([-20, -4, 21])
    cube([40, 8, 8]);
  color("lightblue")
  // Cooler rib
  rotate([0,0,-90]) translate([4,-40/2,21]) cooler_rib();
  color("black")
  // Fan
  translate([-20,-16,21]) rotate([90,0,0]) fan();
}
//reprappro_hotend();

module e3d_hotend(){
  cylinder(h=42.7, r=22.3/2);
}
//e3d_hotend();

module full_render(){
  if(render_bottom_plate){
    bottom_plate();
  }
  if(render_sandwich){
    placed_sandwich();
  }
  if(render_xy_motors){
    placed_xy_motors();
  }
  if(render_gatts){
    placed_gatts();
  }
  if(render_lines){
    placed_lines();
  }
  if(render_extruder){
    placed_extruder();
  }
  if(render_hotend){
    placed_hotend();
  }
  if(render_ramps){
    placed_ramps();
  }
  if(render_plates){
    placed_plates();
  }
}
full_render();
