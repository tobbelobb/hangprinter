include <parameters.scad>
include <gear_parameters.scad>
use <motor_bracket.scad>
use <motor_gear.scad>
use <spool.scad>
use <spool_gear.scad>
use <lineroller_D.scad>
use <lineroller_ABC_winch.scad>
use <util.scad>

// Viewing STLs is faster when just looking at the model
// Non-stls are faster for previews when changing design
//stls = false;
stls = true;

ANCHOR_D_Z = 1000;

sidelength = 380; // The distance between the two action points on the mover
ext_sidelength = sidelength+73;

sandwich_gap = 0.7;

top_plate();
module top_plate(){
  //translate([0,0,ANCHOR_D_Z])
  color("brown")
    translate([-ext_sidelength/2, -ext_sidelength/2-8,-12])
      cube([ext_sidelength, ext_sidelength, 12]);
  //rotate([180,0,30])
  //  cylinder(r=sidelength/sqrt(3) + 20, h=12, $fn=3);
}

placed_lineroller_D();
module placed_lineroller_D(angs=[-70,72,0]){
  center_it = -2.5;
  three = [0,120,240];
  for(k=[0:2])
    rotate([0,0,-30+three[k]])
      translate([-sidelength/sqrt(3),0,0])
        rotate([0,0,angs[k]])
          translate([center_it,0,0])
            if(stls){
              import("../openscad_stl/lineroller_D.stl");
            } else {
              lineroller_D();
            }
}

//translate([0,0,sandwich_gap])
//sandwich();
module sandwich(){
  if(stls){
    import("../openscad_stl/spool_gear.stl");
  } else {
    spool_gear();
  }
  translate([0,0,Gear_height+Spool_height+1+0.1])
    rotate([0,180,0]){
      if(stls){
        import("../openscad_stl/spool.stl");
      } else {
        spool();
      }
    }
}

//winch_unit(l=295, motor_a=-12, a=-6.6, lines=3);
module winch_unit(l=100, a=90, motor_a=0, with_motor=false, lines=1, angs=[0,120,240]){
  translate([0,0,sandwich_gap])
    sandwich();
  rotate([0,0,motor_a])
    translate([0,Motor_pitch+Spool_pitch,0]){
      rotate([0,0,18])
        translate([0,0,sandwich_gap-0.5]) // 0.5 since motor gear is 1 mm higher than spool gear
          if(stls){
            import("../openscad_stl/motor_gear.stl");
          } else {
            motor_gear();
          }
      translate([0,0,Motor_bracket_depth]){
        if(with_motor)
          translate([0,0,Nema17_cube_height])
            rotate([0,180,0])
              Nema17();
        rotate([90,0,0])
          if(stls){
            import("../openscad_stl/motor_bracket.stl");
          } else {
            motor_bracket();
          }
      }
    }
  translate([0,0,Gear_height+Spool_height/2])
    for(i=[1:lines])
      rotate([0,0,angs[i-1]])
        translate([Spool_r,0,0])
        rotate([90,0,0])
        color("yellow")
        cylinder(r=0.5, h=l);
}

module abc_winch(with_motor=false,dist=190, motor_a = 0){
  translate([dist,Spool_r,0])
    if(stls){
      import("../openscad_stl/lineroller_ABC_winch.stl");
    } else {
      lineroller_ABC_winch(the_wall=false) base();
    }
  winch_unit(with_motor=with_motor,l=dist+20,motor_a=motor_a, angs=[90,0,0]);
}

// D
edg = 10;
translate([-ext_sidelength/2+edg,-ext_sidelength/2+55,0])
winch_unit(l=500, motor_a=-110, a=-6.6, lines=3, angs=[71,169.5,121.8]);
// A
translate([-148,-24,0])
rotate([0,0,-92])
  mirror([1,0,0])
  abc_winch(with_motor=false,motor_a=126,dist=194);

// B
translate([-40,-116,0]){
  rotate([0,0,-30]){
    abc_winch(dist=235);
  }
}

// C
translate([169,180,0]){
  rotate([0,0,180+30]){
    abc_winch(dist=235, motor_a=-120);
  }
}


