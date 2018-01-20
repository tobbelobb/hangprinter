include <parameters.scad>
use <sweep.scad>
use <util.scad>

corner_clamp();
module corner_clamp(){
  wall_th = Wall_th+0.2; // A tad thicker since flex is very unwanted in this piece
  rad_b = 4;
  a = 13;
  b = Fat_beam_width+wall_th+2-a/2;
  l0 = 40;
  l1 = (Fat_beam_width+2*wall_th)*2*sqrt(3);
  edges = 0.625;
  opening_width = Fat_beam_width - 2*edges;
  d_hole_l = l0/2+2;

  difference(){
    union(){
      translate([-l1/2,-l1/sqrt(12),0])
      linear_extrude(height=wall_th)
        polygon(points = my_rounded_eqtri(l1,rad_b,5));
      difference(){
        for(k=[0,1])
          mirror([k,0,0])
            rotate([0,0,-30]){
              translate([-(Fat_beam_width+wall_th)+1, -l0+(wall_th+edges)*sqrt(3), 0]){
                one_rounded_cube4([Fat_beam_width+wall_th-1, l0+a, Fat_beam_width+2*wall_th+2],
                    2, $fn=4*4);
                translate([-wall_th-1,0,0])
                  cube([2*wall_th, l0+a, wall_th]);

               translate([Fat_beam_width/2-1, 0, Fat_beam_width/2+wall_th])
                 rotate([0,-90,-90])
                 clamp_wall(l0+a, lift_tri=1.0, w=Fat_beam_width+2*wall_th, wall_th=wall_th, edge=edges);

                }
              }

        extra_height_to_diff_of_clamp_wall = 2.30;
        for(k=[0,1])
          mirror([k,0,0])
        rotate([0,-90,30])
          translate([wall_th+a/2,(wall_th+edges)*sqrt(3)+a,-Fat_beam_width-2*wall_th-1]){
            cylinder(r=a/2, h=wall_th+edges+2, $fn=4*10);
            rotate([0,0,2*90])
            translate([-Fat_beam_width-wall_th-2-extra_height_to_diff_of_clamp_wall+a/2,+a/2,-1]){
              inner_round_corner(r=a/2, h=wall_th+edges+2,back=10, $fn=4*10);
              translate([extra_height_to_diff_of_clamp_wall,-b,0])
                cube([b,b, wall_th+edges+2+Clamp_wall_extra_length]);
            }
          }
      }
      translate([0,-sqrt(2)/sqrt(5),wall_th])
        rotate([0,0,-90-45])
        inner_round_corner(1,Fat_beam_width+wall_th+2,120,1.0, $fn=4*8);
    }
    scrw_fr_edg = 6;
    for(k=[0,1])
      mirror([k,0,0])
        rotate([0,0,-30]){
          translate([-Fat_beam_width-wall_th, -l0+4, wall_th]){
            cube([Fat_beam_width, l0+a+2, Fat_beam_width]);
          }
          translate([-opening_width-wall_th-edges, -l0+4, wall_th]){
            cube([opening_width, l0+a+2, Fat_beam_width+20]);
            translate([-wall_th-edges,0,-wall_th]){
              opening_top(exclude_left = true, wall_th=wall_th, edges=edges, l=l0+2);
              translate([-0.0,wall_th-1,0])
              opening_corners(left_one_height=2*Fat_beam_width, wall_th=wall_th, edges=edges);
            }

          }
          translate([0,0,Fat_beam_width+2*wall_th+2-2])
            rotate([0,-90,0])
              translate([0,-l0+(wall_th+edges)*sqrt(3)+scrw_fr_edg,-2])
                cylinder(d=3.3, h=Fat_beam_width+2*wall_th+4, $fn=10);

        }
    translate([0,l0-2*rad_b,-1])
      cylinder(d=2.5, h=wall_th+2, $fn=10);


    translate([0,0,-0.5])
    linear_extrude(height=1)
      scale(0.15)
      mirror([1,0])
      translate([-150.3,-114])
      import("logo.dxf");

    d_hole_r = 1.5;
    translate([0,-6,2+wall_th/2])
      rotate([-90,0,0]){
        translate([0,0,d_hole_l-0.01])
            rotate([0,0,45])
          cylinder(r1=d_hole_r+0.01, r2=0.5, h=2,$fn=40);
            rotate([0,0,45])
        cylinder(r=d_hole_r, h=d_hole_l,$fn=40);
        translate([0,0,-2+0.01])
            rotate([0,0,45])
          cylinder(r2=d_hole_r+0.01, r1=0.5, h=2,$fn=40);
      }
    fillet_r = 2.5;
    translate([0,(wall_th+edges-fillet_r)*2,0]){
      rotate([0,0,-90-45])
        translate([-fillet_r, -fillet_r,wall_th])
          translate([fillet_r*(1-cos(15)),fillet_r*(1-cos(15)),0])
            inner_round_corner(fillet_r,30,120,2, $fn=4*8);
    }


  }

  // Channel to guide D-line and stiffen up corner
  channel_l = ((l0-2*rad_b)+(d_hole_l-6))/4;
  channel_r1 = 1;
  channel_r2 = 2.5;
  translate([0,((l0-2*rad_b)+(d_hole_l-6))/2,wall_th])
    rotate([90,0,0])
        difference(){
          rotate([90,0,0])
            translate([-channel_r2, -channel_l/2, -channel_r2])
              rounded_cube2([2*channel_r2, channel_l, channel_r2+0.1], 1, $fn=4*4);
          rotate([90,0,0])
            translate([-channel_r1, -channel_l/2-1, -channel_r1-0.5])
             cube([2*channel_r1, channel_l+2, 2*channel_r1]);
        }
}
