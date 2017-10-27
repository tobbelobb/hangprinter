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

  difference(){
    union(){
      translate([-l1/2,-l1/sqrt(12),0])
      linear_extrude(height=wall_th)
        polygon(points = my_rounded_eqtri(l1,rad_b,5));
      //translate([0,-(l0-10)/2,0])
      //  rotate([0,0,-30])
      //    linear_extrude(height=wall_th)
      //      circle(d=l0-10, $fn=3);
      difference(){
        for(k=[0,1])
          mirror([k,0,0])
            rotate([0,0,-30])
              translate([-(Fat_beam_width+2*wall_th), -l0+(wall_th+edges)*sqrt(3), 0])
                three_rounded_cube3([Fat_beam_width+2*wall_th, l0+a, Fat_beam_width+2*wall_th+2],
                    2, $fn=4*4);

        for(k=[0,1])
          mirror([k,0,0])
        rotate([0,-90,30])
          translate([wall_th+a/2,(wall_th+edges)*sqrt(3)+a,-Fat_beam_width-2*wall_th-1]){
            cylinder(r=a/2, h=wall_th+edges+2, $fn=4*10);
            rotate([0,0,2*90])
            translate([-Fat_beam_width-wall_th-2+a/2,+a/2,0]){
              inner_round_corner(r=a/2, h=wall_th+edges+2,back=10, $fn=4*10);
              translate([0,-b,0])
                cube([b,b, wall_th+edges+2]);
            }
          }
      }

    }
    scrw_fr_edg = 6;
    for(k=[0,1])
      mirror([k,0,0])
        rotate([0,0,-30]){
          translate([-Fat_beam_width-wall_th, -l0+4, wall_th])
            cube([Fat_beam_width, l0+a+2, Fat_beam_width]);
          translate([-opening_width-wall_th-edges, -l0+4, wall_th])
            cube([opening_width, l0+a+2, Fat_beam_width+20]);
          for(y=[-scrw_fr_edg-5.5, -l0+(wall_th+edges)*sqrt(3)+scrw_fr_edg])
          translate([0,0,Fat_beam_width+2*wall_th+2-2.5])
            rotate([0,-90,0])
              translate([0,y,-1])
                cylinder(d=3.3, h=Fat_beam_width+2*wall_th+2, $fn=10);
        }
    translate([0,l0-2*rad_b,-1])
      cylinder(d=2, h=wall_th+2, $fn=10);


    translate([0,0,-0.5])
    linear_extrude(height=1)
      scale(0.15)
      mirror([1,0])
      translate([-150.3,-114])
      import("logo.dxf");

  }
}
