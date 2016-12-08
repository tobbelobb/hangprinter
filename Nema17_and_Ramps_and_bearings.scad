include <design_numbers.scad>
include <measured_numbers.scad>
use <util.scad>

module Nema17_screw_translate(corners){
  for (i=[0:90:90*corners - 1]){
    rotate([0,0,i+45]) translate([Nema17_screw_hole_width/2,0,0]) children(0);
  }
}

module Nema17_screw_holes(d, h, corners=4){
  Nema17_screw_translate(corners) cylinder(r=d/2,h=h);
}
//Nema17_screw_holes(M3_diameter, 15);

module Nema17_schwung_screw_holes(d, h, schwung_length, corners=3){
  // Tight/still screw
  rotate([0,0,-45])
    translate([Nema17_screw_hole_width/2,0,0]) cylinder(r=d/2, h=h);
  // Nearest screw in y-direction
    rotate([0,0,-45])
    translate([Nema17_screw_hole_width/2,0,0])
    rotate([0,0,90+45])
    cyl_wall_2(d,Nema17_screw_hole_dist+d/2, h,30);
  // Nearest screw in x-direction
  // Removed because it is under worm disc
  //  rotate([0,0,-45])
  //  translate([Nema17_screw_hole_width/2,0,0])
  //  rotate([0,0,2*90+45])
  //  cyl_wall_2(d,Nema17_screw_hole_dist+d/2, h,30);
  // diametral opposite screw
    rotate([0,0,-45])
    translate([Nema17_screw_hole_width/2,0,0])
    rotate([0,0,2*90])
    cyl_wall_2(d,Nema17_screw_hole_width+d/2, h,schwung_length);
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
      cylinder(r=Nema17_ring_diameter/2, h=ch+Nema17_ring_height);
      translate([0,0,1]) cylinder(r=8.76/2, h=ch+Nema17_ring_height);
    }
    color("silver")
      cylinder(r=5/2, h=sh); // Shaft...
  }
}
//Nema17();
//translate([0,0,-Nema17_cube_height]) Nema17();
//%Nema17_damping_plate();

module Nema17_damping_plate(){
  cw = Nema17_cube_width;
  rh = Nema17_ring_height+0.5;
  difference(){
    translate([-cw/2,-cw/2,0])
      cube([cw,cw,rh]);
    translate([0,0,-1])
      Nema17_screw_holes(M3_diameter+0.2, h=rh+2);
    cylinder(r=Nema17_ring_diameter/2+0.5, h=2*rh+2, center=true);
    for(i=[45:90:359])
      rotate([0,0,i])
        translate([53.36/2,-cw/2,-1])
          cube([cw,cw,rh+2]);
  }
}
//Nema17_damping_plate();

module Ramps(){
  color("tomato")
    cube([Ramps_length, Ramps_width, Ramps_depth]);
}
//Ramps();

module Ramps_holder(){
  floor_th = 1;
  edge_height = 3;
  solders_height = 5;
  extra_height = edge_height+solders_height;
  wall_th = 2;
  edge = 1;
  difference(){
    union(){
      // Main outer cube
      difference(){
        cube([Ramps_length, Ramps_depth+2*wall_th, Ramps_width+extra_height+floor_th]);
        // Fit Ramps straight in
        translate([-1,wall_th,floor_th])
          cube([Ramps_length+2, Ramps_depth, Ramps_width+floor_th+extra_height+1]);
      }
      // Add edges
      translate([0,-edge,floor_th+Ramps_width+solders_height])
        cube([Ramps_length,wall_th+2*edge,edge_height]);
      translate([0,Ramps_depth+wall_th-edge,floor_th+Ramps_width+solders_height])
        cube([Ramps_length,wall_th+2*edge,edge_height]);
    }
    // Cut away parts of wall
    translate([-1,-edge-1,floor_th])
      cube([Ramps_length/5+1, Ramps_depth+2*edge+2*wall_th+2, Ramps_width+extra_height+1]);
    translate([2*Ramps_length/5,-edge-1,floor_th])
      cube([Ramps_length/5, Ramps_depth+2*edge+2*wall_th+2, Ramps_width+extra_height+1]);
    translate([4*Ramps_length/5,-edge-1,floor_th])
      cube([Ramps_length/5+1, Ramps_depth+2*edge+2*wall_th+2, Ramps_width+extra_height+1]);
    // Straight Nema17 screw holes
    for(i=[0:9]){
      translate([0.5*Nema17_screw_hole_dist + 6
                 +i*Nema17_screw_hole_dist/5,
                 Ramps_depth/2+wall_th,
                 -1]){
        Nema17_screw_holes(M3_diameter,10);
        translate([0,10,0])
          Nema17_screw_holes(M3_diameter,10);
        translate([0,-10,0])
          Nema17_screw_holes(M3_diameter,10);
      }
    }
    //    rotate([0,0,45])
    //      Nema17_screw_holes(M3_diameter,10);
  }
}
//Ramps_holder();

// TODO: motors are rotated 45 deg compared to this
module Fancy_Ramps_holder(){
  th = 1.5;
  bones = 2;
  push_y = 16;

  // A cross used for a Nema17 mount later
  module cross(){
    rotate([0,0,0])
      polygon([for (i=[0:2:359.9])
          9*[cos(i), sin(i)]
          + 17*pow(sin(4/2*i),4)*[cos(i),sin(i)]]);
  }

  module bones_place(){
      rotate([0,0,B_placement_angle])
        translate([0,
            Four_point_five_point_radius,
            -Nema17_cube_height-bones])
        rotate([0,0,45])
          Nema17_screw_translate(3)
            children(0);
      rotate([0,0,A_placement_angle])
        translate([0,
          Four_point_five_point_radius,
          -Nema17_cube_height-bones])
        rotate([0,0,45])
          rotate([0,0,180])
            Nema17_screw_translate(3)
              children(0);
  }

  difference(){
    union(){
      bones_place()
        cylinder(d=7, h=bones+th);
      for(i=[B_placement_angle, A_placement_angle])
        rotate([0,0,i])
          translate([0,
              Four_point_five_point_radius,
              -Nema17_cube_height-bones])
          rotate([0,0,45]){
            linear_extrude(height=th, convexity=6)
              cross();
          }
      // Naming corners in this fancy polygon...
      a = -20.6;
      d = 28.75;
      e = 10.3;
      j = 6;
      translate([-Ramps_length/2,16,-Nema17_cube_height-bones])
        linear_extrude(height=th, convexity=10)
        polygon([[-a,-j],
            [-a,0],
            [Ramps_length+a,0],
            [Ramps_length+a, -j],
            [Ramps_length+d, e],
            [Ramps_length, Ramps_depth],
            [0, Ramps_depth],
            [-d, e]
            ]);
    } // end union

    bones_place()
      translate([0,0,-bones])
      cylinder(d=3.2,h=3*bones);

    translate([-Ramps_length/2,16,-Nema17_cube_height-bones])
      // Straight Nema17 screw holes
      for(i=[0:8]){
        translate([0.5*Nema17_screw_hole_dist + 6
            +i*Nema17_screw_hole_dist/4,
            Ramps_depth/2,
            -1]){
          Nema17_screw_holes(M3_diameter,10);
          translate([0,9,0])
            Nema17_screw_holes(M3_diameter,10);
          translate([0,-9,0])
            Nema17_screw_holes(M3_diameter,10);
        }
      }
  }
}
Fancy_Ramps_holder();

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
  big = 100;
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
      cylinder(r=Bearing_623_bore_diameter/2, h=big);
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
