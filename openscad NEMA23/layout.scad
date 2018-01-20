include <parameters.scad>
include <gear_parameters.scad>
use <motor_bracket.scad>
use <motor_gear.scad>
use <spool.scad>
use <spool_gear.scad>
use <lineroller_D.scad>
use <lineroller_ABC_winch.scad>
use <corner_clamp.scad>
use <beam_clamp.scad>
use <util.scad>

// Viewing STLs is faster when just looking at the model
// Non-stls are faster for previews when changing design
//stls = false;
stls = true;

ANCHOR_D_Z = 1000;

sidelength = 380; // The distance between the two action points on the mover
ext_sidelength = sidelength+73;

color0 = "sandybrown";
color0_alpha = 0.55;
color1 = [0.14,0.16,0.90];
color1_alpha = 0.9;
color2 = [0.99,0.99,0.99];
color2_alpha = 0.8;

//color(color0, color0_alpha)
//top_plate();
module top_plate(){
  //translate([0,0,ANCHOR_D_Z])
    translate([-ext_sidelength/2, -ext_sidelength/2-8,-12])
      cube([ext_sidelength, ext_sidelength, 12]);
  //rotate([180,0,30])
  //  cylinder(r=sidelength/sqrt(3) + 20, h=12, $fn=3);
}

//color(color1, color1_alpha)
//placed_lineroller_D();
module placed_lineroller_D(angs=[-73,68,0]){
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

//translate([0,0,Gap_between_sandwich_and_plate])
//sandwich();
module sandwich(){
  color(color2, color2_alpha)
  if(stls){
    import("../openscad_stl/spool_gear.stl");
  } else {
    spool_gear();
  }
  color(color1, color1_alpha)
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
module winch_unit(l=[100,100,100], a=90, motor_a=0, with_motor=true, lines=1, angs=[0,120,240]){
  translate([0,0,Gap_between_sandwich_and_plate])
    sandwich();
  rotate([0,0,motor_a])
    translate([0,Motor_pitch+Spool_pitch,0]){
      rotate([0,0,18])
        translate([0,0,Gap_between_sandwich_and_plate-0.5]) // 0.5 since motor gear is 1 mm higher than spool gear
          color(color1, color1_alpha+0.1)
          if(stls){
            import("../openscad_stl/motor_gear.stl");
          } else {
            motor_gear();
          }
      translate([0,0,Motor_bracket_depth]){
        if(with_motor)
          translate([0,0,Nema17_cube_height])
            rotate([0,180,40])
              Nema17();
        rotate([90,0,90-50])
          color(color2, color2_alpha-0.2)
          if(stls){
            import("../openscad_stl/motor_bracket.stl");
          } else {
            motor_bracket();
          }
      }
    }
  translate([0,0,Gear_height+Spool_height/2+Gap_between_sandwich_and_plate])
    for(i=[1:lines])
      rotate([0,0,angs[i-1]])
        translate([Spool_r,0,0])
        rotate([90,0,0])
        color("yellow")
        cylinder(r=0.9, h=l[i-1]);
}

module abc_winch(with_motor=true,dist=190, motor_a = 0){
  translate([dist,Spool_r,0])
    color(color2, color2_alpha)
    if(stls){
      import("../openscad_stl/lineroller_ABC_winch.stl");
    } else {
      lineroller_ABC_winch(the_wall=false) base();
    }
  winch_unit(with_motor=with_motor,l=[dist+12],motor_a=motor_a, angs=[90,0,0]);
}

translate([0,0,43+ANCHOR_D_Z])
rotate([180,0,0])
full_winch();
module full_winch(){
  // D
  edg = 10;
  translate([-ext_sidelength/2+edg,-ext_sidelength/2+55,0])
    winch_unit(l=[209,275,490], motor_a=-110, a=-6.6, lines=3, angs=[64.6,164.5,118.9]);
  // A
  translate([-137,26,0])
    rotate([0,0,-90])
    mirror([1,0,0])
    abc_winch(with_motor=true,motor_a=131,dist=166);

  // B
  translate([-39,-110,0]){
    rotate([0,0,-30]){
      abc_winch(dist=235, motor_a=119);
    }
  }

  // C
  translate([118,182,0]){
    rotate([0,0,180+30]){
      abc_winch(dist=186, motor_a=-99);
    }
  }

  color(color1, color1_alpha)
    placed_lineroller_D();

  color(color0, color0_alpha)
    top_plate();
}

mover();
module mover(){
  reduced_sidelength = sidelength - 80;
  for(k=[0,120,240])
    rotate([180,0,k+180]){
      translate([-reduced_sidelength/2,-sidelength/sqrt(12)-sqrt(3), +Wall_th+0.3]){
        cube([reduced_sidelength, Beam_width, Beam_width]);
        for(p=[0.3*reduced_sidelength, 0.69*reduced_sidelength])
          translate([p, Beam_width/2,Beam_width/2])
            rotate([0,90,0])
              rotate([0,0,180])
                color(color1, color1_alpha)
                  if(stls){
                    import("../openscad_stl/beam_slider.stl");
                  } else {
                    beam_slider();
                  }

      }
      translate([0,-40+2*4 + sidelength/sqrt(3),0])
        color(color1, color1_alpha)
          if(stls){
            import("../openscad_stl/corner_clamp.stl");
          } else {
            corner_clamp();
          }

    }
    for(k=[0,1])
      mirror([k,0,0])
        rotate([180,0,-60])
          translate([35,-sidelength/sqrt(12)-sqrt(3) - Wall_th+0.1, +0.35])
            rotate([0,0,90]){
              color(color1, color1_alpha)
                if(false){ // difference of stl always renders badly
                  difference(){
                    import("../openscad_stl/beam_clamp.stl");
                    translate([-101,-1,-1])
                      cube(100);
                  }
                } else {
                  beam_clamp();
                }
                if(k==0){
                  rotate([0,0,30])
                    translate([31,Wall_th,Wall_th-0.03]){
                      cube([sidelength/2.3,Beam_width, Beam_width]);
                      rotate([-90,0,90])
                        translate([-Wall_th,
                                   -Wall_th-Beam_width,
                                   -(sidelength/2.3)/2-(Nema17_cube_width+1+2*Wall_th)/2])
                          color(color1, color1_alpha)
                            if(stls){
                              import("../openscad_stl/extruder_holder.stl");
                            } else {
                              extruder_holder();
                            }
                    }

                }
            }
}

d_lines();
module d_lines(){
  color("yellow")
  for(k=[0,120,240])
    rotate([0,0,k])
      translate([0,sidelength/sqrt(3),0])
        cylinder(r=0.9, h=ANCHOR_D_Z);
}
