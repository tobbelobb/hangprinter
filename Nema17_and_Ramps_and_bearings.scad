include <measured_numbers.scad>
use <util.scad>

module Nema17_screw_translate(){
  for (i=[0:90:359]){
    rotate([0,0,i+45]) translate([Nema17_screw_hole_width/2,0,0]) children(0);
  }
}

module Nema17_screw_holes(d, h){
  Nema17_screw_translate() cylinder(r=d/2, h=h);
}
//Nema17_screw_holes(M3_diameter, 15);

module Nema17_schwung_screw_holes(d, h){
  // Tight/still screw
  rotate([0,0,-45])
    translate([Nema17_screw_hole_width/2,0,0]) cylinder(r=d/2, h=h);
  // Nearest screw in y-direction
    rotate([0,0,-45])
    translate([Nema17_screw_hole_width/2,0,0])
    rotate([0,0,90+45])
    cyl_wall_2(d,Nema17_screw_hole_dist+d/2, h,30);
  // Nearest screw in x-direction
    rotate([0,0,-45])
    translate([Nema17_screw_hole_width/2,0,0])
    rotate([0,0,2*90+45])
    cyl_wall_2(d,Nema17_screw_hole_dist+d/2, h,30);
  // diametral opposite screw
    rotate([0,0,-45])
    translate([Nema17_screw_hole_width/2,0,0])
    rotate([0,0,2*90])
    cyl_wall_2(d,Nema17_screw_hole_width+d/2, h,30);
  //color("green"){
  //  rotate([0,0,45])
  //  translate([Nema17_screw_hole_width/2,0,0]) cylinder(r=d/2, h=h);
  //  rotate([0,0,90+90+45])
  //  translate([Nema17_screw_hole_width/2,0,0]) cylinder(r=d/2, h=h);
  //  rotate([0,0,45+90])
  //  translate([Nema17_screw_hole_width/2,0,0]) cylinder(r=d/2, h=h);
  //}
}
//Nema17_schwung_screw_holes(M3_diameter, Big);

module Nema17(){
  cw = Nema17_cube_width;
  ch = Nema17_cube_height;
  sh = Nema17_shaft_height;
  union(){
    color("black")
    difference(){
      translate([-(cw-0.1)/2,-(cw-0.1)/2,1]) cube([cw-0.1,cw-0.1,ch-2]);
      for (i=[0:90:359]){ // Corner cuts black cube
        rotate([0,0,i+45]) translate([50.36/2,-cw/2,-1]) cube([cw,cw,ch+2]);
      }
    }
    color("silver")
    difference(){
      translate([-cw/2,-cw/2,0]) cube([cw,cw,ch]);
      for (i=[0:90:359]){ // Corner cuts silver cube
        rotate([0,0,i+45]) translate([53.36/2,-cw/2,-1]) cube([cw,cw,ch+2]);
      }
      translate([0,0,ch-5]) Nema17_screw_holes(M3_diameter, h=10);
      translate([0,0,-5]) Nema17_screw_holes(M3_diameter, h=10);
      translate([-cw,-cw,9]) cube([2*cw,2*cw,ch-18]);
    }
    color("silver")
    difference(){
      cylinder(r=22/2, h=ch+2);
      translate([0,0,1]) cylinder(r=8.76/2, h=ch+2);
    }
    color("silver")
      cylinder(r=5/2, h=sh);
  }
}
//Nema17();

module Ramps(){
  color("red")
    cube([Ramps_length, Ramps_width, Ramps_depth]);
}
//Ramps();

module Bearing_623(){
  color("blue")
  difference(){
    cylinder(r=Bearing_623_outer_diameter/2, h=Bearing_623_width);
    translate([0,0,-1])
      cylinder(r=Bearing_623_bore_diameter/2, h=Bearing_623_width+2);
  }
}
//Bearing_623();

module Bearing_607(){
  color("blue")
  difference(){
    cylinder(r=Bearing_607_outer_diameter/2, h=Bearing_607_width);
    translate([0,0,-1])
      cylinder(r=Bearing_607_bore_diameter/2, h=Bearing_607_width+2);
  }
}
//Bearing_607();

module Bearing_608(){
  color("blue")
  difference(){
    cylinder(r=Bearing_608_outer_diameter/2, h=Bearing_608_width);
    translate([0,0,-1])
      cylinder(r=Bearing_608_bore_diameter/2, h=Bearing_608_width+2);
  }
}
//Bearing_608();

module Bearing_623_vgroove(){
  bd = Bearing_623_vgroove_big_diameter;   // Big diameter
  sd = Bearing_623_vgroove_small_diameter; // Small diameter
  h1 = Bearing_623_width;                  // Totoal height
  h2 = Bearing_623_vgroove_width;
  h_edge = (h1-h2)/2;
  difference(){
    for(k = [0,1]){
      translate([0,0,h1*k]){
        mirror([0,0,k]){
          // Edge
          cylinder(r=bd/2, h=h_edge);
          // Half the groove
          translate([0,0,h_edge])
            cylinder(r1=bd/2, r2=sd/2, h=h2/2);
        }
      }
    }
    // Bore
    translate([0,0,-1])
      cylinder(r=Bearing_623_bore_diameter/2, h=Big);
  }
}
//color("purple")
//Bearing_623_vgroove();

module M3_screw(h, updown=false){
  color("grey"){
    cylinder(r=M3_diameter/2, h=h);
    if(updown){
      translate([0,0,h-M3_head_height])
        cylinder(r=M3_head_diameter/2, h=M3_head_height, $fn=6);
    }else{
      cylinder(r=M3_head_diameter/2, h=M3_head_height, $fn=6);
    }
  }
}
//M3_screw(10);
