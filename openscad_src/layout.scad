include <parameters.scad>
include <gear_parameters.scad>
use <motor_bracket.scad>
use <motor_bracket_2d.scad>
use <motor_gear.scad>
use <spool.scad>
use <spool_gear.scad>
use <spool_core.scad>
use <lineroller_D.scad>
use <lineroller_ABC_winch.scad>
use <corner_clamp.scad>
use <beam_slider_ABC.scad>
use <beam_slider_D.scad>
use <util.scad>

// Viewing STLs is faster when just looking at the model
// Non-stls are faster for previews when changing design
stls = true;
//stls = false;

// Viewing 2d
//twod = true;
twod = false;

//mounted_in_ceiling = true;
mounted_in_ceiling = false;

// Render the mover
//mover = true;
mover = false;

ANCHOR_D_Z = 1000;

sidelength = 452; // The distance between the two action points on the mover
ext_sidelength = sidelength+77;
yshift_top_plate = -25;
additional_added_plate_side_length = 10;

color0 = "sandybrown";
color0_alpha = 0.55;
color1 = [0.14,0.16,0.90];
color1_alpha = 0.9;
color2 = [0.99,0.99,0.99];
color2_alpha = 0.8;

//top_plate();
module top_plate(){
  if(!twod){
    translate([-(ext_sidelength + additional_added_plate_side_length)/2,
               -(ext_sidelength + additional_added_plate_side_length)/2+yshift_top_plate,
               -12])
      cube([ext_sidelength + additional_added_plate_side_length,
            ext_sidelength + additional_added_plate_side_length, 12]);
  }
}

//placed_lineroller_D();
module placed_lineroller_D(angs=[-63,60,3.5]){
  center_it = -2.5;
  three = [0,120,240];
  for(k=[0:2])
    rotate([0,0,-30+three[k]])
      translate([-sidelength/sqrt(3),0,0])
        rotate([0,0,angs[k]])
          translate([center_it,0,0])
            if(stls && !twod){
              import("../openscad_stl/lineroller_D.stl");
            } else {
              lineroller_D(twod=twod);
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

//winch_unit(motor_a=0);
module winch_unit(l=[100,100,100], motor_a=0, with_motor=true, lines=1, angs=[0,120,240], clockwise = 1){
  if(!twod)
    translate([0,0,Gap_between_sandwich_and_plate])
      sandwich();
  rotate([0,0,motor_a]){
    translate([0,Motor_pitch+Spool_pitch+0.5,0]){
      if(!twod)
        rotate([0,0,18])
          translate([0,0,Gap_between_sandwich_and_plate-0.5]) // 0.5 since motor gear is 1 mm higher than spool gear
            color(color1, color1_alpha+0.1)
              if(stls){
                import("../openscad_stl/motor_gear.stl");
              } else {
                motor_gear();
              }
      if(twod)
        rotate([0,0,90-Motor_bracket_att_ang])
          translate([0,(Wall_th+0.5)/2])
            motor_bracket_2d();
      else {
        translate([0,0,Motor_bracket_depth]){
          if(with_motor){
            translate([0,0,Nema17_cube_height]){
              rotate([0,180,40]){
                Nema17();
              }
            }
          }
          rotate([90,0,90-Motor_bracket_att_ang]){
            color(color2, color2_alpha-0.2){
              translate([0,0,-(Wall_th+0.5)/2])
                if(stls){
                  import("../openscad_stl/motor_bracket.stl");
                } else {
                  motor_bracket();
                }
            }
          }
        }
      }
    }
  }
  if(!twod)
    translate([0,0,Gear_height+Spool_height/2+Gap_between_sandwich_and_plate])
      for(i=[1:lines])
        rotate([0,0,angs[i-1]])
          translate([clockwise*Spool_r,0,0])
          rotate([90,0,0])
          color("yellow")
          cylinder(r=0.9, h=l[i-1]);

  color(color2)
    if(stls && !twod)
      import("../openscad_stl/spool_core.stl");
    else
      spool_core(twod=twod);
}

//abc_winch();
module abc_winch(with_motor=true,dist=160, motor_a = 280, clockwise=1){
  translate([dist,clockwise*Spool_r,0])
    color(color2, color2_alpha)
    if(stls && !twod){
      import("../openscad_stl/lineroller_ABC_winch.stl");
    } else {
      lineroller_ABC_winch(the_wall=false, with_base=true, twod=twod);
    }
  winch_unit(with_motor=with_motor,l=[dist+12],motor_a=motor_a, angs=[90,0,0], clockwise=clockwise);
}

if(mounted_in_ceiling && !twod){
  translate([0,0,43+ANCHOR_D_Z])
    rotate([180,0,0])
      full_winch();
} else {
  full_winch();
}
module full_winch(){
  // D
  edg = 10;
  //translate([-ext_sidelength/2+edg,-ext_sidelength/2+55,0])
  translate([-ext_sidelength/2+Spool_outer_radius,
             -ext_sidelength/2+yshift_top_plate+Spool_outer_radius,0])
    winch_unit(l=[185,339,534], motor_a=-110, a=-6.6, lines=3, angs=[60,176.75,123.85]);
  // A
  translate([-136,-7,0])
    rotate([0,0,90])
      abc_winch();

  // B
  translate([-17,-140,0])
    rotate([0,0,-30])
      abc_winch(clockwise=-1);

  // C
  translate([98,151,0])
    rotate([0,0,180+30])
      abc_winch();

  color(color1, color1_alpha)
    placed_lineroller_D();

  color(color0, color0_alpha)
    top_plate();
}

if(mover && !twod)
  mover();
module mover(){
  beam_length = 400;
  for(k=[0,120,240])
    rotate([180,0,k+180]){
      translate([-beam_length/2,-sidelength/sqrt(12)-sqrt(3), 0]){
        cube([beam_length, Beam_width, Beam_width]);
        translate([0.3*beam_length, Beam_width/2+Wall_th,Beam_width/2-Wall_th])
          rotate([0,90,0])
            rotate([0,0,180])
              color(color1, color1_alpha)
                if(stls){
                  import("../openscad_stl/beam_slider_ABC.stl");
                } else {
                  beam_slider_ABC();
                }
        translate([0.69*beam_length, Beam_width/2+7,Beam_width/2-5])
              color(color1, color1_alpha)
                if(stls){
                  import("../openscad_stl/beam_slider_D.stl");
                } else {
                  beam_slider_D();
                }

      }
      translate([0,-40+2*4 + sidelength/sqrt(3),-Wall_th])
        color(color1, color1_alpha)
          if(stls){
            import("../openscad_stl/corner_clamp.stl");
          } else {
            corner_clamp();
          }

    }
    sidelength_frac = 1.5;
    shorter_beam = sidelength/sidelength_frac;
    offcenter_frac = 25;
          //translate([0,-sidelength/sqrt(12)-sqrt(3) - Wall_th+0.1, +0.35])
            translate([-shorter_beam/2,sidelength/offcenter_frac,0]){
              cube([shorter_beam,Beam_width, Beam_width]);
              rotate([90,0,90])
                translate([-2*Wall_th,
                           0,
                           shorter_beam/2-(Nema17_cube_width+0.54*2+2*Wall_th)/2])
                  color(color1, color1_alpha)
                    if(stls){
                      import("../openscad_stl/extruder_holder.stl");
                    } else {
                      extruder_holder();
                    }
            }
}

if(mover && !twod)
  d_lines();
module d_lines(){
  color("yellow")
  for(k=[0,120,240])
    rotate([0,0,k])
      translate([0,sidelength/sqrt(3),0])
        cylinder(r=0.9, h=ANCHOR_D_Z);
}
