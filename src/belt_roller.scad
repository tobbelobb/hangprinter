include <parameters.scad>
use <util.scad>


belt_roller();
module belt_roller(twod = false,
                   base_th = Base_th,
                   big_y_r = 190,
                   big_z_r=94){
  space_between_walls = 2*b623_width + 0.8;
  wall_th = (Depth_of_lineroller_base - space_between_walls)/2;
  flerp = 6;
  l = Depth_of_lineroller_base + b623_outer_dia + 2*Bearing_wall + flerp + flerp;

  //base();
  module base(base_th = Base_th,
      center=true,
      twod=false,
      openings=[false, false, false, false]){
    for(k=[0, 1])
      translate([+k*(l/2+Depth_of_lineroller_base/2),-k*(l/2-Depth_of_lineroller_base/2),0])
        translate([-l/2, -Depth_of_lineroller_base/2, 0])
        rotate([0,0,k*90])
        difference(){
          if(twod){
            rounded_cube2([l, Depth_of_lineroller_base], Lineroller_base_r, $fn=13*4);
          } else {
            rounded_cube2([l, Depth_of_lineroller_base, base_th], Lineroller_base_r, $fn=13*4);
            translate([l/2 + Depth_of_lineroller_base/2, Depth_of_lineroller_base, 0])
              inner_round_corner(r=2, h=base_th, $fn=6*4); // Fillet
            translate([l/2 - Depth_of_lineroller_base/2, 0, 0])
              rotate([0,0,180])
              inner_round_corner(r=2, h=base_th, $fn=6*4); // Fillet
          }
          for(x=[Depth_of_lineroller_base/2-2, l - (Depth_of_lineroller_base/2-2)])
            translate([x, Depth_of_lineroller_base/2, -1])
              if(twod)
                circle(d=Mounting_screw_d, $fs=1);
              else{
                cylinder(d=Mounting_screw_d, h=base_th+2, $fn=20);
              }
        }
    for(i=[0:4])
      if(twod && openings[i])
        rotate([0,0,i*90])
        translate([l/2-1,-1])
        square([6,2]);
  }

  module wall(){
    difference(){
      union(){
        translate([-Depth_of_lineroller_base/2, space_between_walls/2,0]){
          cube([Depth_of_lineroller_base,
                        wall_th,
                        GT2_tensioner_h]);
        }
        for(k=[0,1])
          mirror([k,0,0])
            translate([-Depth_of_lineroller_base/2 +0.1,Depth_of_lineroller_base/2, base_th])
              rotate([0,-90,90])
                inner_round_corner(r=5, h=wall_th, $fn=4*5);
        translate([0,space_between_walls/2-0.4, GT2_tensioner_h - Depth_of_lineroller_base/2])
          rotate([-90,0,0]){
            cylinder(r=3.4/2 + 1, h=wall_th, $fn=12);
          }
      }
      for(k=[0,1])
        mirror([k,0,0])
          translate([0,0,GT2_tensioner_h - Depth_of_lineroller_base/2])
            rotate([-90,0,0])
              inner_round_corner(r=Depth_of_lineroller_base/2,
                                 h=Depth_of_lineroller_base,
                                 center=true, $fn=4*7);
      translate([0,space_between_walls/2 - 1, GT2_tensioner_h - Depth_of_lineroller_base/2])
        rotate([-90,0,0]){
          cylinder(d=3.4, h=wall_th + 2, $fn=12);
          translate([0,0,1+wall_th - min(wall_th/2, 2)])
            nut(h=8);
        }
    }
  }

  if(!twod){
    difference(){
      union(){
        base(twod=twod, openings=[true,false,true,false]);
        wall();
        mirror([0,1,0])
          wall();
      }
      for(v=[0:90:359])
        rotate([0,0,v])
          translate([l/2-Depth_of_lineroller_base/2+2,0,2.3]){
            cylinder(d1=Mounting_screw_d,
                d2=Mounting_screw_d + 2*2.7, // 90 degree countersink
                h=2.7, $fn=20);
            translate([0,0,2.64])
              cylinder(d=Mounting_screw_d + 2*2.7, h=3, $fn=20);
          }
    }
  }
}
