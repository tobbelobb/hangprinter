include <parameters.scad>
use <sweep.scad>
use <util.scad>

//%prev_art();
module prev_art(){
  translate([0,15+2*2.5,0])
    rotate([180,0,0])
    import("../stl/beam_clamp.stl");
}

beam_clamp();
module beam_clamp(){
  wall_th = Wall_th;
  l0 = 43;
  l1 = 35;
  edges = 0.625;
  opening_width = Fat_beam_width - 2*edges;
  module rot_move(){
    translate([Fat_beam_width+2*wall_th,(l0 - (2/sqrt(3))*(Fat_beam_width+2*wall_th))/2,0])
      rotate([0,0,-60])
        translate([-Fat_beam_width-2*wall_th,0,0])
          children();
  }

  module antibalk(){
    extralen = 2;
    translate([wall_th+edges, -extralen, wall_th])
      cube([opening_width, l0+2*extralen, 100]);
    translate([Beam_width+wall_th, -extralen, wall_th])
      rotate([0,0,90])
        beam(l0+2*extralen);
  }

  difference(){
    union(){
      r0 = 2; // inner round corner radius
      a0 = 60;
      sink0 = r0*sin(15)*2/sqrt(6);
      r1 = 1;
      a1 = 120;
      sink1 = r1*2/sqrt(30);
      rounded_cube2([Fat_beam_width+2*wall_th, l0, Fat_beam_width+2*wall_th+2], 2);
      rot_move(){
        translate([Fat_beam_width+2*wall_th,0,0])
          rotate([0,0,90])
            right_rounded_cube2([l1, Fat_beam_width+2*wall_th, Fat_beam_width+2*wall_th+2],2);
        translate([Fat_beam_width+2*wall_th,0,0])
          rotate([0,0,-15])
            translate([-sink0,-sink0,0])
              inner_round_corner(r0/(1-cos(a0/2+45)-(1-sin(a0/2+45))),
                                 Fat_beam_width+2*wall_th+2, a0, $fn=100);
        translate([0,(1/sqrt(3))*(Fat_beam_width+2*wall_th) + (0)*r1,0])
          rotate([0,0,-15])
            translate([-sink1,sink1,0])
              rotate([0,0,90])
                inner_round_corner(r1/(1-cos(a1/2+45)-(1-sin(a1/2+45))),
                                   Fat_beam_width+2*wall_th+2, a1, 0.4, $fn=100);
      }
    }
    scrw_fr_edg = 5;
    antibalk();
    rot_move()
      antibalk();
    for(y=[scrw_fr_edg, l0-scrw_fr_edg])
      translate([-1, y, Fat_beam_width+2*wall_th+2-2.5])
        rotate([0,90,0])
          cylinder(d=3.3, h=Fat_beam_width+2*wall_th+2);
    for(y=[l1 - scrw_fr_edg, (Fat_beam_width+2*wall_th)/2 + scrw_fr_edg])
      rot_move()
        translate([-1, y, Fat_beam_width+2*wall_th+2-2.5])
          rotate([0,90,0])
            cylinder(d=3.3, h=Fat_beam_width+2*wall_th+2);
    rot_move()
      translate([Fat_beam_width/2, (Fat_beam_width)*(1/sqrt(6)), wall_th*2])
      cube([Fat_beam_width+2*wall_th+2, 2, 100]);
  }
}

