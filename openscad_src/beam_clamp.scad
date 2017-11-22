include <parameters.scad>
use <sweep.scad>
use <util.scad>


translate([-10,0,0]) mirror([1,0,0]) beam_clamp();
beam_clamp();
module beam_clamp(){
  wall_th = Wall_th;
  l0 = 46;
  l1 = 35;
  edges = 0.625;
  opening_width = Fat_beam_width - 2*edges;


  module opening_top(exclude_left=false, exclude_right=false){
    if(!exclude_left){
      translate([wall_th+edges, 0, 2*wall_th+Fat_beam_width+2])
        rotate([0,90,90])
        translate([0,0,-1])
        inner_round_corner(r=2, h=l0+2, $fn=4*5);
    }
    if(!exclude_right){
      mirror([1,0,0])
        translate([-wall_th-Fat_beam_width+edges, 0, 2*wall_th+Fat_beam_width+2])
        rotate([0,90,90])
        translate([0,0,-1])
        inner_round_corner(r=2, h=l0+2, $fn=4*5);
    }
  }

  module opening_corners(left_one_height=Fat_beam_width,
                         right_one_height=Fat_beam_width){
    translate([wall_th+Fat_beam_width,0,wall_th])
      inner_round_corner(r=2, h=right_one_height, back=2, $fn=4*5);
    translate([wall_th,0,wall_th])
      rotate([0,0,90])
      inner_round_corner(r=2, h=left_one_height, back=2, $fn=4*5);

    translate([wall_th+Fat_beam_width-edges,0,wall_th])
      inner_round_corner(r=2, h=Fat_beam_width+2*wall_th+1, back=2, $fn=4*5);
    translate([wall_th+edges,0,wall_th])
      rotate([0,0,90])
      inner_round_corner(r=2, h=Fat_beam_width+2*wall_th+2, back=2, $fn=4*5);
  }

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
    translate([Fat_beam_width+wall_th, -extralen, wall_th])
      rotate([0,0,90])
        fat_beam(l0+2*extralen);
  }

  difference(){
    union(){
      r0 = 2; // inner round corner radius
      a0 = 60;
      sink0 = r0*sin(15)*2/sqrt(6);
      r1 = 1;
      a1 = 120;
      sink1 = r1*2/sqrt(30);
      translate([wall_th+0.9,0,0])
      rounded_cube2([Fat_beam_width+wall_th-0.9, l0, Fat_beam_width+2*wall_th+2], 2);
      cube([wall_th+3,l0,wall_th]);

      translate([Fat_beam_width/2+wall_th, 0, Fat_beam_width/2+wall_th])
        rotate([0,-90,-90])
        clamp_wall(l0, lift_tri=1.0, edge=edges);

      rot_move(){
        translate([Fat_beam_width+2*wall_th,0,0])
          rotate([0,0,90]){
            difference(){
              one_rounded_cube3([l1, Fat_beam_width+2*wall_th, Fat_beam_width+2*wall_th+2],2,$fn=16);
              // Make space for clamp wall
              translate([Fat_beam_width/sqrt(6)+2-0.01,-1,wall_th])
                cube([l1, 2*wall_th, Fat_beam_width+2*wall_th+2]);
            }
        }
        translate([Fat_beam_width/2+Wall_th, Fat_beam_width/sqrt(6)+2, Fat_beam_width/2+wall_th])
          mirror([1,0,0])
          rotate([0,-90,-90])
          clamp_wall(l1-Fat_beam_width/sqrt(6)-2, lift_tri=1.0, edge=edges);
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
      translate([-2, y, Fat_beam_width+2*wall_th+2-2])
        rotate([0,90,0])
          cylinder(d=3.3, h=Fat_beam_width+2*wall_th+4, $fn=10);
    rot_move()
      translate([-2, l1 - scrw_fr_edg, Fat_beam_width+2*wall_th+2-2])
        rotate([0,90,0])
          cylinder(d=3.3, h=Fat_beam_width+2*wall_th+4, $fn=10);
    rot_move()
      translate([Fat_beam_width/2, (Fat_beam_width)*(1/sqrt(6)), wall_th*2])
      cube([Fat_beam_width+2*wall_th+2, 2, 100]);

    opening_corners(left_one_height=2*Fat_beam_width);
    mirror([0,1,0])
      translate([0,-l0,0])
      opening_corners(left_one_height=2*Fat_beam_width);
    rot_move()
      mirror([0,1,0])
      translate([0,-l1,0])
      opening_corners(right_one_height=2*Fat_beam_width);
    opening_top(exclude_left = true);
    rot_move()
      translate([0,-2,0])
      opening_top(exclude_right=true);

  }
}

