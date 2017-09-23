include <parameters.scad>
use <sweep.scad>
use <util.scad>

//%prev_art();
module prev_art(){
  import("../stl/extruder_holder.stl");
}

cw = Nema17_cube_width; // For brevity...
flerp = 7.2;
wiggle = 0.54;
r_little = 3;
block_height = Beam_width+2*Wall_th;
block_depth = cw + 2*wiggle + 2*Wall_th;
cable_clamp_o = 4;
cable_clamp_ex_l = 20;

extruder_holder();
module extruder_holder(){

  edges = 0.625;
  opening_width = Fat_beam_width - 2*edges;
  //main_block();
  module main_block(){
    translate([0,-cw,0])
      rotate([90,0,90])
      linear_extrude(height=block_height, slices=1)
      rounded_2corner([cw + wiggle + 2*Wall_th + Fat_beam_width + flerp,
          block_depth],
          r_little);
    rotate([90,0,90])
      linear_extrude(height=Wall_th+edges, slices=1)
      rounded_2corner([wiggle + 2*Wall_th + Fat_beam_width + flerp + cable_clamp_ex_l,
          block_depth],
          r_little);
  }
  ex_l = cw*2/sqrt(3);


  difference(){
    main_block();
    translate([Wall_th,-cw-1,Wall_th+wiggle])
      cube([cw,cw+1,cw]);
    translate([Beam_width+2*Wall_th,0,0])
      rotate([0,0,-atan((Beam_width+Wall_th-wiggle)/(cw))])
      translate([0,-ex_l,-1])
      cube([cw,ex_l,cw+2*(wiggle+Wall_th+1)]);
    translate([0,0,Wall_th+wiggle])
      rotate([0,90,0])
      translate([-cw/2, -cw/2, -1]){
        Nema17_screw_holes(3.5, Wall_th+2, $fs=1);
        cylinder(d=Nema17_ring_diameter+2, h=Wall_th+2, $fs=1);
      }
    translate([Wall_th-Wiggle/2, Wall_th-Wiggle/2, -1])
      fat_beam(block_depth+2, standing=true);
    translate([(Wall_th-Wiggle/2)+opening_width/2+edges, Fat_beam_width/2+Wall_th+flerp+1, -1])
      cube([opening_width, Fat_beam_width+2*flerp, 2*block_depth+3], center=true);
    // Holes for clamping screws
    for(i=[8,block_depth-8])
      translate([0,Fat_beam_width+2*Wall_th+wiggle+flerp - 4,i])
        rotate([0,90,0]){
          translate([0,0,-1])
            cylinder(d=3.1, h=block_height+2, $fs=1);
        }
    // For cable holder screws
    for(i=[cable_clamp_o,block_depth-cable_clamp_o])
      translate([0,Fat_beam_width+2*Wall_th+wiggle+flerp+cable_clamp_ex_l - 4,i])
        rotate([0,90,0])
        cylinder(d=3.1, h=block_height+2, $fs=1, center=true);
  }
}

// Use this part to screw tight
translate([-20,-10,0])
Flat_cable_clamper();
module Flat_cable_clamper(){
  difference(){
    linear_extrude(height=Wall_th, slices=1)
      rounded_2corner([flerp,
          block_depth],
          r_little);
    for(i=[cable_clamp_o,block_depth-cable_clamp_o])
      translate([flerp-4,i,0])
        cylinder(d=3.1, h=block_height+2, $fs=1, center=true);
  }
}

module Placed_cable_clamper(){
  translate([-6,wiggle + 2*Wall_th + Fat_beam_width + cable_clamp_ex_l,0])
    rotate([90,0,90])
    Flat_cable_clamper();
}
