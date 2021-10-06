include <lib/parameters.scad>

$fn=32;

inner_d = b608_vgroove_small_r*2;
small_d = inner_d + 1;;
big_d = b608_vgroove_big_r*2;
U_r = 3.7;
scl = [1.2, 1.4];


bearing_u_608();
module bearing_u_608(core=false){
  rotate_extrude(){
    difference(){
      translate([inner_d/2,-(b608_width-0.1)/2])
        square([(big_d-inner_d)/2, b608_width-0.1]);
      translate([U_r + small_d/2, 0])
        scale(scl)
          circle(d=6);
    }
  }
  if(core)
    cylinder(d=inner_d+0.2, h=b608_width-0.1, center=true);
}

//elong_b608_ugroove(elong=12, extra_height=0.8);
module elong_b608_ugroove(elong=10, extra_height=0){
  color("purple"){
    bearing_u_608(core=true);
    translate([0,elong,0])
      bearing_u_608(core=true);
    difference(){
      translate([-big_d/2, 0, -(b608_width-0.1)/2])
        cube([big_d, elong, b608_width-0.1]);
      for(k=[0,1]) mirror([k,0,0])
        rotate([-90,0,0])
          translate([U_r + small_d/2, 0, 0])
            scale(scl)
              translate([0,0,-1])
                cylinder(d=6, h=elong+2);
    }
    if(extra_height != 0) {
      for(k=[0,1]) mirror([0,0,k])
        hull(){
          translate([0,0,b608_width/2-0.1]){
            cylinder(d=big_d, h=extra_height/2+0.1);
            translate([0,elong,0])
              cylinder(d=big_d, h=extra_height/2+0.1);
          }
        }
    }
  }
}
