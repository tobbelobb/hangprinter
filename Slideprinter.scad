// Everything with units mm gets a name here
// (Exeptions are stuff that won't be printed)
nema17_cube_width=42.43;
nema17_cube_height=39.36;
nema17_shaft_height=63.65;
nema17_screw_hole_width = 43.74;

M3_diameter = 3;
M3_head_diameter = 5.4;

bottom_plate_thickness = 7;
radius_needed_to_fit_pen = 15;
mid_cylinder_diameter = 53; // Rest of mode bottom_plate adjusts according to this
Ramps_screw_z=7.4;
Ramps_screw_from_right_edge=15;

// util...
module eq_tri(s, h){
  sqrt3=sqrt(3);
  sqrt3s=sqrt3*s;
  c = sqrt3s/2;
  a = s/2;
  linear_extrude(height=h, slices=1)
    polygon(points = [[s/2,-a/sqrt3],[0,s/sqrt3],[-s/2,-a/sqrt3]], paths=[[0,1,2]]);
}
//eq_tri(10,10);

module Nema17_screw_holes(d, h){
  for (i=[0:90:359]){
    rotate([0,0,i+45]) translate([nema17_screw_hole_width/2,0,0]) cylinder(r=d/2, h=h);
  }
}
//Nema17_screw_holes(M3_diameter, 15);

module Nema17 (){
  cw = nema17_cube_width;
  ch = nema17_cube_height;
  sh = nema17_shaft_height;
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
      translate([0,0,-5]) Nema17_screw_holes(M3_diamater, h=10);
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

module motor_base(th=5){
  cw = nema17_cube_width;
  h=2*th;
  translate([cw/2,cw/2,0])
    difference(){
      union(){
        translate([-cw/2,-cw/2,0]) cube([cw,cw,th]);
        Nema17_screw_holes(d=5.94,h=th+2);
      }
      translate([0,0,-1]) Nema17_screw_holes(d=M3_diameter, h=h);
      translate([0,0,-h+th+2-0.6]) Nema17_screw_holes(d=M3_head_diameter+0.25, h=h);
  }
}
//motor_base(7);

module motor_base_frame(th=5,width=8){
  difference(){
    motor_base(th=th);
    translate([width,width,-1])cube(nema17_cube_width-2*width);
  }
}
//motor_base_frame(7,8);

module point_cube(v, ang){
  translate([v[0]/2,0,0])
  difference(){
    translate([-v[0]/2,0,0]) cube(v);
    rotate([0,-ang/2,0]) translate([-2*v[0],1.5-v[1],-v[2]]) cube([2*v[0],2*v[1],3*v[2]]);
    mirror([1,0,0]) rotate([0,-ang/2,0]) translate([-2*v[0],1.5-v[1],-v[2]])
      cube([2*v[0],2*v[1],3*v[2]]);
  }
}
//point_cube([10,11,12],60);

module bottom_plate(thickness=7){
  sqrt3=sqrt(3);
  cw = nema17_cube_width;
  th = thickness; 
  mho = mid_cylinder_diameter;  // Adjust compactness, perserve overall shape
  mhi = radius_needed_to_fit_pen;
  full_tri_side=(sqrt3+1.5)*cw+sqrt3*mho/2;
  tri_side=full_tri_side-2*cw;
  big=300;
  difference(){
    union(){
      for (i=[0:120:359]){
        rotate([0,0,i]) translate([-cw/2,mho/2,0]){ 
            motor_base_frame(th=th);
            translate([cw/2,cw/2,th]) Nema17();
          }
      }
      // Material around pen-lock mechanism
      cylinder(r=mho/2+4,h=th);
      difference(){
        eq_tri(s=full_tri_side, h=th);
        for (i=[0:120:359]){
          rotate([0,0,i]) translate([-(cw+2)/2,mho/2+cw,-1]) cube([cw+2,cw,th+2]);
          rotate([0,0,i]) translate([-(cw-1)/2,mho/2,-1]) cube([cw-1,cw-1,th+2]);
        }
        translate([0,0,-1]) 
          cylinder(h=th+2,r=full_tri_side/(2*sqrt3)-5);
      }
      // Ramps claw
      rotate([0,0,120]) 
        translate([-tri_side/2,-16.8-full_tri_side/(2*sqrt3),0]){
          cube([tri_side,16.8+2,th-1.5]);
          translate([0,-2,0]){
            cube([tri_side, 2,th-1.5+6.5]);
            translate([0,0.7,th-1.5+6.5-2]) 
            difference(){
              cube([tri_side, 2.5,2]);
              translate([0,0,-1]) rotate([45,0,0]) translate([-1,0,-2])cube([tri_side+2, 4.5,2]);

            }
          }
        }
      // Insert a ramps-plate here
      rotate([0,0,120]) color("red") translate([-50.5,-16.8-176.107/(2*sqrt(3)),5]) 
        Ramps();
    }
    // Place for pen
    translate([0,0,-1]) cylinder(r=mhi/2,h=th+2);
    // Place for pen-lock screw
    translate([0,0,M3_diameter/2+(th-M3_diameter)/2]) rotate([-90,0,180]) 
      cylinder(h=cw+mho,r=M3_diameter/2);
    translate([0,-mhi-3,M3_diameter/2+(th-M3_diameter)/2]) rotate([-90,0,180]) 
      cylinder(h=cw+mhi,r=M3_head_diameter/2);
    // Nut trap for pen-lock screw
    translate([-5.5/2,-mhi,M3_diameter/2+(th-M3_diameter)/2-3.1]) 
      point_cube([5.5,2.4,th],120);
    // Screw hole for securing Ramps
    translate([0,0,Ramps_screw_z])rotate([0,90,30])
      translate([0,tri_side/2-Ramps_screw_from_right_edge,full_tri_side/(2*sqrt3)])
        cylinder(r=M3_diameter/2,h=big);

  }
}
bottom_plate(bottom_plate_thickness);

module Ramps(){
  cube([101.7,16.8,60]);
}
//Ramps();
