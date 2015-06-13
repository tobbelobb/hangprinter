include <measured_numbers.scad>
include <util.scad>
include <design_numbers.scad>

// Modules not in contact with any printed parts
// Just explanatory
module filament(){
  color("white") translate([0,0,-50]) cylinder(r=1.75/2, h = 300);
}
//filament();

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
