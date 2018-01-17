include <parameters.scad>
use <sweep.scad>
use <util.scad>

wall_th = Wall_th + 0; // Beef up part...
cw = Nema17_cube_width; // For brevity...
wiggle = 0.54;
r_little = 3;
block_height = Beam_width+2*wall_th;
z_depth = cw + 2*wiggle + 2*wall_th;
cable_clamp_o = 4;
x_depth = 20; // Max width for beam to fit in
cable_clamp_ex_l = 20;
flange_l = x_depth+cable_clamp_ex_l;


extruder_holder();
module extruder_holder(){
  //main_block();
  module main_block(){
    translate([x_depth+wall_th,0,0])
      rotate([90,0,-90])
      linear_extrude(height=x_depth+wall_th, slices=1)
      rounded_2corner([cw+wall_th+Zip_th,  z_depth],
          r_little);
    translate([x_depth,-0.01,0])
      rotate([90,0,90])
      linear_extrude(height=wall_th, slices=1)
      rounded_2corner([flange_l,
          z_depth],
          r_little, $fn=30);
    // A stronger back where it risks to bend
    extra_back=3;
    translate([0,-(wall_th-extra_back),0])
    for(k=[0,1])
      translate([x_depth+wall_th,k*(Min_beam_width-2*extra_back+wall_th),0])
        difference(){
          cylinder(r=extra_back, h=z_depth, $fn=20);
          translate([-2*extra_back,-2*extra_back,-1])
            cube([2*extra_back,12,z_depth+2]);
        }
     translate([x_depth+wall_th-0.1,-(wall_th-extra_back),0])
       cube([extra_back+0.1,Min_beam_width-2*extra_back+wall_th,z_depth]);
  }
  ex_l = sqrt((cw+wall_th+Zip_th)*(cw+wall_th+Zip_th) + x_depth*x_depth) + wall_th;

  difference(){
    main_block();
    translate([wall_th,-cw-1-wall_th,wall_th])
      cube([cw,cw+1,cw+2*wiggle]);
    translate([x_depth+wall_th,-wall_th,0])
      rotate([0,0,-atan(x_depth/(cw+Zip_th-0.5))])
      translate([0,-ex_l+0,-1])
      cube([cw,ex_l,cw+2*(wiggle+wall_th+1)]);
    translate([0,-wall_th-Zip_th,wall_th+wiggle])
      rotate([0,90,0])
      translate([-cw/2, -cw/2, -1]){
        Nema17_screw_holes(3.5, wall_th+2, $fs=1);
        rotate([0,0,90])
          teardrop(r=(Nema17_ring_diameter+2)/2, h=wall_th+2);
      }
    // Holes for zip_ties
    for(k=[0,1])
      translate([k*x_depth,-k*(wall_th+Zip_th),0])
      rotate([0,0,k*90])
      for(i=[5,z_depth-5-Zip_w])
        translate([0,Min_beam_width,i])
          cube([x_depth+10, Zip_h+k*10, Zip_w]);
    // For cable holder screws
    for(i=[cable_clamp_o,z_depth-cable_clamp_o])
      translate([0,flange_l-Zip_w-3,i-Zip_th/2])
        cube([x_depth+10, Zip_w, Zip_th]);
  }

  // Pillar to support cornered ziptie openings
  rotate([0,0,-45])
    translate([0.5,-0.5,0])
    cube([sqrt(2)*wall_th-1,1,z_depth]);

  // Rounded support for cable clamp ziptie
  Placed_cable_clamper();
}

// Use this part to screw tight
translate([0,4,0])
//rotate([0,-90,0])
Flat_cable_clamper();
module Flat_cable_clamper(){
  x_l = 6+Zip_w;
  difference(){
    intersection(){
      rounded_cube2([x_l,
          z_depth,20], r_little, $fn=30);
      scale([1,1,0.20])
        translate([0,z_depth/2,0])
        rotate([0,90,0])
        translate([0,0,-1])
        cylinder(d=z_depth, h=x_l+2);
    }
    for(i=[cable_clamp_o-Zip_th/2,z_depth-cable_clamp_o-Zip_th/2])
      translate([x_l-Zip_w-3,i,-1])
        cube([Zip_w, Zip_th, x_depth+10]);
  }
}

module Placed_cable_clamper(){
  translate([x_depth+wall_th,flange_l,0])
    rotate([90,0,-90])
    Flat_cable_clamper();
}
