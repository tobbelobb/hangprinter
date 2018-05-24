include <parameters.scad>
use <util.scad>

//spool_center();
module spool_center(){
  bearing_wall_th = Spool_center_bearing_wall_th;
  center_h = Spool_height+Torx_depth-4;
  ek_w = 8;
  eang = 12; // just for placement of inner round corners
  difference(){
    cylinder(r=b608_outer_dia/2+bearing_wall_th, h=center_h,$fn=6*8);
    translate([0,0,-1])
      cylinder(d=b608_outer_dia,h=Spool_height+Torx_depth-0.4+1+2);
    translate([0,0,-1])
      cylinder(d1=b608_outer_dia+2.5, d2=b608_outer_dia-0.1,h=2.2);
  }
  for(a=[0:360/6:359]){
    rotate([0,0,a]){
    translate([b608_outer_dia/2+bearing_wall_th-1,-ek_w/2,0])
      cube([(Spool_r-bearing_wall_th-b608_outer_dia/2), ek_w, center_h]);
    }
  }
  difference(){
    for(a=[0:360/6:359])
      rotate([0,0,a]){
        translate([Spool_r-Spool_outer_wall_th-4, -ek_w/2,0])
          cube([5,ek_w,center_h+4]);
        for(m=[0,1])
          mirror([0,m,0]){
            translate([Spool_r-Spool_outer_wall_th-0.37,ek_w/2,0])
              rotate([0,0,90])
                inner_round_corner(r=2, h=Spool_height+Torx_depth, back=0.4, $fn=4*6);
            translate([b608_outer_dia/2+bearing_wall_th-0.95, ek_w/2-0.2,0])
              rotate([0,0,eang/2])
                inner_round_corner(r=2, h=center_h, ang=90-eang, $fn=4*5);
          }
      }
    translate([0,0,Spool_height+Torx_depth])
      rotate_extrude($fn=100)
        translate([Spool_r-Spool_outer_wall_th-4,0])
          circle(r=4,$fn=40);
  }
}

//torx(female=true);
module torx(h = Spool_height + 2, r = Spool_r, female=false){
  circs = 12;
  intersection(){
    if(female){
      cylinder(r=r+0.1, h=h, $fn=150);
    } else {
      cylinder(r=r, h=h, $fn=150);
    }
    for(i=[0:1:circs])
      rotate([0,0,i*360/circs]){
        translate([r-5,0,-1])
        cylinder(r=r/4.2, h=h+2, $fn=50);
      if(female){
        rotate([0,0,360/(2*circs)]){
           translate([r/2 + 16,0,-1])
             cylinder(r2=1, r1=r/1.9, h=h+2, $fn=50);
           translate([r-10-3.5,0,-1])
             cylinder(r=10, h=h+2, $fn=50);
          }
        }
      }
  }
  cylinder(r=r-5,h=h);
}

