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

module fan(width=30, height=10){
  linear_extrude(height=height, twist=-40)
  for(i=[0:6]){
    rotate([0,0,(360/7)*i])
      translate([0,-0.5])
        square([width/2 - 2, 1]);
  }
  cylinder(h=height, r=width/4.5);
  
  difference(){
    translate([-width/2, -width/2,0])
      cube([width,width,height]);
    translate([0,0,-1]) cylinder(r=width/2 - 1, h=height+2);
    for(i=[1,-1]){
      for(k=[1,-1]){
        translate([i*width/2-i*2.5,k*width/2-k*2.5,-1])
          cylinder(r=1, h=height+2);
      }
    }
  }
}

module Volcano_block(){
  small_height = 18.5;
  large_height = 20;
  color("silver"){
  translate([-15.0,-11/2,0])
    difference(){
      cube([20,11,large_height]);
      translate([7,0,small_height+3])
        rotate([90,0,0])
        cylinder(h=23, r=3, center=true,$fn=20);
      translate([-(20-7+1.5),-1,small_height]) cube([22,13,2]);
    }
    }
  color("gold"){
    translate([0,0,-3]) cylinder(h=3.1,r=8/2,$fn=6);
    translate([0,0,-3-2]) cylinder(h=2.01, r2=6/2, r1=2.8/2);
  }
}
//Volcano_block();

//cylinder(h=42.7, r=22.3/2);
module e3d_v6_volcano_hotend(fan=1){
  lpl = 2.1;
  if(fan){
  color("blue") rotate([90,0,0]) import("stl/V6_Duct.stl");
  color("black")
    translate([-15,0,15])
      rotate([0,-90,0])
        fan(width=30, height=10);
  }
  color("LightSteelBlue"){
    cylinder(h=26, r1=13/2, r2=8/2);
    for(i = [0:10]){
      translate([0,0,i*2.5]) cylinder(h=1, r=22.3/2);
    }
    translate([0,0,42.7-3.7]) cylinder(h=3.7, r=16/2);
    translate([0,0,42.7-3.7-6.1]) cylinder(h=6.2, r=12/2);
    translate([0,0,42.7-3.7-6-3]) cylinder(h=3, r=16/2);
    translate([0,0,26-0.1]) cylinder(h=42.7-(12.7+26)+0.2, r=8/2);
    translate([0,0,26+1.5]) cylinder(h=1, r=16/2);
    echo(42.7-(12.7+26));
    translate([0,0,-lpl-0.1]) cylinder(h=lpl+0.2,r=2.8/2);
  }
  translate([0,0,-20-lpl]) Volcano_block();
}
e3d_v6_volcano_hotend();
