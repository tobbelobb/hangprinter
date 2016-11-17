include <measured_numbers.scad>
include <util.scad>
include <design_numbers.scad>
use <Nema17_and_Ramps_and_bearings.scad>
use <Gears.scad>
use <render_parts.scad>

module d_motor_move(){
  rotate([0,0,D_placement_angle+24])
    translate([0,Worm_disc_tooth_valley_r + Worm_radius,
        Bottom_plate_thickness + Bottom_plate_sandwich_gap // Now at bottom of d-sandwich
        + Sandwich_gear_height/2]) //
    rotate([0,-90,0]){
      translate([0,0,-Pushdown_d_motor])
        rotate([0,0,D_motor_twist]) // rotate d motor around itself here
        for(i=[0:$children-1]){
          children(i);
        }
    }
}

module fish_ring(){
  $fn = 15;
  // Measured numbers
  hol_h  = 1.57;
  ins_ro = 4.90/2;
  edg_r  = 6.50/2;
  lar_ri = 3.00/2;
  hol_r1 = 5.86/2;
  hol_r2 = 5.42/2;
  trdist = cdist + lar_ro;
  // Bring action point to origo
  translate([0,-ins_ri,0])
  difference(){
    union(){
      color("black")
        cylinder(r=ins_ro, h=ins_h, center=true);  // Inside ring (cheramic)
      color("grey")
        cylinder(r=edg_r, h=edg_h, center=true);
      translate([0,0,-edg_h/2])
      color("grey")
      linear_extrude(height=edg_h, slices=1)
        polygon(points = [tangent_point(edg_r, [0,-trdist]),
                          tangent_point_3(edg_r, [0,-trdist]),
                          [0,-trdist]],
                paths = [[0,1,2]]);
      translate([0,-cdist,0]){
        color("black")
          translate([0,0,lar_h/4])
          cylinder(r=lar_ro, h=lar_h, center=true);
        color("grey")
          cylinder(r=hol_r1, h=edg_h, center=true);
        color("grey")
          cylinder(r=hol_r2, h=hol_h-edg_h/2);
      }
    }
    // The two holes (ceramic and lar ring)
    cylinder(r=ins_ri, h=ins_h+2, center=true);
    translate([0,-cdist,0])
      cylinder(r=lar_ri, h=lar_h*2, center=true);
  }
}
//fish_ring();

module placed_fish_rings(){
  for(i=[0,1,2]){
    rotate([0,0,120*i]){
      for(k=[0,1])
        mirror([k,0,0])
          translate(Line_contact_abc_xy
            + [0,0, Line_contacts_abcd_z[i] + ins_ri + ins_ri/sqrt(2)])
          rotate([90,0,fish_ring_abc_rotation])
          translate([-ins_ri/sqrt(2),0,0])
          mirror([0,0,1])
          fish_ring();
    }
  }
  // D-lines' fish rings
  for(i=[0,1,2]){
    rotate([0,0,120*i])
      translate(Line_contact_d_xy + [0, 0, Line_contacts_abcd_z[D]])
      rotate([fish_ring_d_rotation,0,0])
      fish_ring();
  }
}
//placed_fish_rings();


//** bottom_plate start **//

// TODO: reason for using children(0) instead of just children() here?
// Assumes children(0) is centered in xy-plane
// A little odd that reference translation is along y...
// Used for XY and Z motors
// Needed here to get screw holes right
// a, b, c, d and e does not lie in counterclockwise order
// They are ordered to avoid obstructing line paths
module four_point_translate(a_object=true,
                            b_object=true,
                            c_object=true,
                            d_object=true,
                            e_object=false){
  radius = Four_point_five_point_radius;
  if(b_object){
    rotate([0,0,B_placement_angle]) translate([0,radius,0]) children(0);
  }
  if(c_object){
    rotate([0,0,C_placement_angle]) translate([0,radius,0]) children(0);
  }
  if(d_object){
    rotate([0,0,D_placement_angle]) translate([0,radius,0]) children(0);
  }
  if(a_object){
    rotate([0,0,A_placement_angle]) translate([0,radius,0]) children(0);
  }
  if(e_object){
    rotate([0,0,E_placement_angle]) translate([0,radius,0]) children(0);
  }
}

// Needed here to get screw holes right
// TODO: Remove part of Tble-struder
module extruder_motor_translate(){
  translate([E_motor_x_offset,
             Nema17_shaft_height/2 + Nema17_cube_height/2, // Middle of shaft (outside of cube)
             -Nema17_screw_hole_dist/2 + Bottom_plate_thickness/2 + E_motor_z_offset])
    rotate([90,0,0])
    for(i=[0:$children-1]){
      children(i);
    }
}

// The thing separating bearings on center axis of bottom plate
module lock(r1, r2, height){
  difference(){
    cylinder(r=r2, h=height);
    translate([0,0,-1])
      cylinder(r=r1, h=height+2);
  }
}
//lock(Lock_radius_1, Lock_radius_2, Lock_height);


module bottom_plate(){
  // Global variables renamed short
  cw  = Nema17_cube_width;
  th  = Bottom_plate_thickness;
  bpr = Bottom_plate_radius;
  bd  = Bearing_608_bore_diameter;
  bw  = Bearing_608_width;
  swh = Sandwich_height;
  gap = Sandwich_gap;
  sandwich_stick_height = Line_contacts_abcd_z[A]+swh-Snelle_height/2
                 + 5; // for putting some kind of top lock mechanism

  // First add and subtract everything except fish ring towers
  // Then construct fish ring towers, then add them
  // To avoid accidentically cutting them near bottom
  union(){
    difference(){
      union(){
        // Largest possible triangular plate
        eq_tri(Full_tri_side, th);
        // Circular bottom plate
        cylinder(r=bpr, h = th);

        // Sandwich stick
        cylinder(r=bd/2+0.16,
            h=sandwich_stick_height);

        // The bottom lock
        cylinder(r=Lock_radius_2, h=th + Bottom_plate_sandwich_gap);

        // Mounting tower for D motor
        d_motor_move(){
          rotate([0,0,45]) translate([Nema17_screw_hole_width/2,0,0])
            translate([-6,0,Nema17_cube_height])
            rotate([90,0,D_motor_twist/2])
            translate([0,0,-14])
            cube([12,5.5,20]);
        }
      } // End union


      //*** ANTIMATERIA STARTS HERE ***//

      // Mounting space for d fish_rings
      big=5*th;
      for(i=[0,1,2]){
        rotate([0,0,120*i]){
          translate(Line_contact_d_xy + [0, 0, Line_contacts_abcd_z[D]]){
            rotate([fish_ring_d_rotation-90,0,0])
              translate([-3.3,-10 - edg_h/2 + 0.05,-big/2])
              cube([6.6,10,big]); // Block to put fish ring in
            rotate([fish_ring_d_rotation-180,0,0])
              translate([0,ins_ri+cdist,0])
              cylinder(r=M3_diameter/2, h=big, center=true);//Hole for M3
            rotate([fish_ring_d_rotation-180,0,0])
              translate([0,ins_ri+cdist,4])
              cylinder(r=M3_head_diameter/2, h=big);//M3 screw head hole
          }
          // Straight edge towards center of the d fish ring hole
          translate(Line_contact_d_xy)
            translate([-3.3,-9.5,-big+th+1])
            cube([6.6,7,big]); // Block to put fish ring in
        }
      }

      // Middle hole for ABC-motors
      // Large enough to get motor gears through
      four_point_translate(d_object=false){
        cylinder(r = Motor_gear_radius
            + 2*(Motor_gear_radius-Motor_gear_pitch),
            h=Big, center=true);
      }

      // Screw holes for abc Nema
      translate([0, 0, -1]){
        four_point_translate(d_object=false)
          Nema17_schwung_screw_holes(M3_diameter+0.2, th+2, 18);
        four_point_translate(d_object=false)
          translate([0,0,th-3.5])
          Nema17_screw_holes(M3_head_diameter+0.1, th+2);
      }

      // Hole for extruder motor
      // TODO: Remove part of Tble-struder
      extruder_motor_translate()
        scale(1.015) // Leave 1.5% extra space, don't need tight fit
        Nema17();

      // Hole for worm driving d-motor
      // For some reason, OpenSCAD crashes if I call:
      //placed_d_motor(worm=false);

      d_motor_move(){
        translate([0,0,-1.5])
          scale(1.02) // Leave 2 percent gap for easy mounting
          Nema17();
        //scale([1.1,1.05,1.05])
        //  worm(); // Keep worm in center to more easily adjust radius to worm_plate later
        // Square hole for worm
        rotate([90,0,90-D_motor_twist])
          translate([0,-27+Pushdown_d_motor,
              -Sandwich_gear_height/2-Bottom_plate_sandwich_gap-Bottom_plate_thickness-1])
          linear_extrude(height=Bottom_plate_thickness+2)
          polygon([[-Worm_radius - 10, 0],
              [-Worm_radius -  1, 0],
              [-Worm_radius -  1, 3],
              [+Worm_radius +  3.1, 3],
              [+Worm_radius +  3.6, 11],
              [+Worm_radius +  3.3, 14],
              [+Worm_radius -  1, 34],
              [-Worm_radius - 10, 34]]);
        // Screw holes for D motor
        translate([0,0,-10])
          Nema17_screw_holes(M3_diameter,20+Nema17_cube_height);
      }// end d_motor_move

      // Screw holes for extruder motor mounting screws
      extruder_motor_translate(){
        for(i=[1,-1]){
          translate([i*Nema17_screw_hole_dist/2,Nema17_screw_hole_dist/2,0]){
            translate([0,0,-Big+Nema17_cube_height+10])
              cylinder(h=Big, d=M3_diameter+0.2);
            translate([-9/2,-(Bottom_plate_thickness+2)/2,Nema17_cube_height+7])
              // Rectangular hole to reach in with hex key
              cube([9,Bottom_plate_thickness+3,30]);
            if(i==-1){
              translate([-9/2,-(Bottom_plate_thickness+2)/2,-31-7])
                // Rectangular hole to reach in with hex key
                cube([9,Bottom_plate_thickness+3,31]);
            }
          }
        }
      }


      // Dig out filament hole in sandwich stick and base.
      // Note that bowden tube should fit in this from below
      translate([0, 0, -1]) cylinder(r = 2.3, h = Big);

      // Letters for easier identification
      translate([0,0,-1]){
        rotate([0,0,120*A+7])
          translate(Line_action_point_abc_xy + [0,-8,th])
          scale([1,1,1.5])
          linear_extrude(height=2)
          text("A",halign="center",valign="center");
        rotate([0,0,120*B+7])
          translate(Line_action_point_abc_xy + [0,-8,th])
          scale([1,1,1.5])
          linear_extrude(height=2)
          text("B",halign="center",valign="center");
        rotate([0,0,120*C+7])
          translate(Line_action_point_abc_xy + [0,-16,th])
          scale([1,1,1.5])
          linear_extrude(height=2)
          text("C",halign="center",valign="center");
      }
      // Funnel shape for easier bowden tube fit
      translate([0,0,-0.1])
        cylinder(h=3, r1=3, r2=2);

    }// end difference

    //*** Fish ring towers start here ***//

    difference(){
      // Mounting towers for abc fish rings
      for(i=[0,1,2]){
        rotate([0,0,120*i]){
          for(k = [0, 1]){
            mirror([k,0,0]){
              translate(Line_contact_abc_xy)
                rotate([0,0,fish_ring_abc_rotation])
                translate([-6-ins_ri , -edg_h/2+0.01,0])
                cube([12,5.5,Line_contacts_abcd_z[i] - ins_ri]);
            }
          }
        }
      }
      // Mounting holes for abc fish rings
      // rotations and translations synced with placed_fish_rings
      for(i=[0,1,2]){
        rotate([0,0,120*i]){
          for(k=[0,1]){
            mirror([k,0,0]){
              translate(Line_contact_abc_xy
                  +[0,0,Line_contacts_abcd_z[i] + ins_ri + ins_ri/sqrt(2)])
                rotate([90,0,fish_ring_abc_rotation]){
                  translate([-ins_ri/sqrt(2),0,0])
                    translate([0,-cdist-ins_ri,0]){
                      cylinder(r=M3_diameter/2+0.3, h = 25, center=true);
                    }
                }
            }
          }
        }
      }
      // Tracks to put fish rings in
      placed_fish_rings();
    } // End difference
  }
}
// The rotate is for easier fitting print bed when printing
// this part on 200 mm square print bed
//rotate([0,0,15])
bottom_plate();


//** bottom_plate end **//

// Sandwich is defined in Gears.scad
// Motors are defined in Nema17_and_Ramps_and_bearings.scad


//** extruder start **//

// A better way to match holes:
// make bottom_plate take two flags:
//   render_plate?
//   render_drive?
// make diff holes outside the if-statement, so
// holes always align anyway.

module fan(width=30, height=10){
  linear_extrude(height=height, twist=-40)
  for(i=[0:6]){
    rotate([0,0,(360/7)*i])
      translate([0,-0.5])
        square([width/2 - 2, 1]);
  }
  cylinder(h=height, r=width/4.5);

  difference(){
    translate([-width/2, -width/2,0])
      cube([width,width,height]);
    translate([0,0,-1]) cylinder(r=width/2 - 1, h=height+2);
    for(i=[1,-1]){
      for(k=[1,-1]){
        translate([i*width/2-i*2.5,k*width/2-k*2.5,-1])
          cylinder(r=1, h=height+2);
      }
    }
  }
}

module Volcano_block(){
  small_height = 18.5;
  large_height = 20;
  color("silver"){
  translate([-15.0,-11/2,0])
    difference(){
      cube([20,11,large_height]);
      translate([7,0,small_height+3])
        rotate([90,0,0])
        cylinder(h=23, r=3, center=true,$fn=20);
      translate([-(20-7+1.5),-1,small_height]) cube([22,13,2]);
    }
    }
  color("gold"){
    translate([0,0,-3]) cylinder(h=3.1,r=8/2,$fn=6);
    translate([0,0,-3-2]) cylinder(h=2.01, r2=6/2, r1=2.8/2);
  }
}
//Volcano_block();

// Contains a lot of unnamed measured numbers...
module e3d_v6_volcano_hotend(fan=1){
  lpl = 2.1;
  if(fan){
  color("blue") rotate([90,0,0]) import("stl/V6_Duct.stl");
  color("black")
    translate([-15,0,15])
      rotate([0,-90,0])
        fan(width=30, height=10);
  }
  color("LightSteelBlue"){
    cylinder(h=26, r1=13/2, r2=8/2);
    for(i = [0:10]){
      translate([0,0,i*2.5]) cylinder(h=1, r=22.3/2);
    }
    translate([0,0,E3d_heatsink_height-3.7]) cylinder(h=3.7, r=E3d_mount_big_r);
    translate([0,0,E3d_heatsink_height-3.7-6.1]) cylinder(h=6.2, r=E3d_mount_small_r);
    translate([0,0,E3d_heatsink_height-3.7-6-3]) cylinder(h=3, r=E3d_mount_big_r);
    translate([0,0,26-0.1]) cylinder(h=E3d_heatsink_height-(12.7+26)+0.2, r=8/2);
    translate([0,0,26+1.5]) cylinder(h=1, r=E3d_mount_big_r);
    // echo(42.7-(12.7+26));
    translate([0,0,-lpl-0.1]) cylinder(h=lpl+0.2,r=2.8/2);
  }
  translate([0,0,-20-lpl]) Volcano_block();
}
//e3d_v6_volcano_hotend();

// towermove moves materia but not antimateria of drive_support
// height of the tower depends on big extruder gear rotation
// Used in assembled_drive in placed_parts.scad
module drive_support_helper(non_motor_side,towermove=0){
  th = Drive_support_thickness;

  difference(){
    union(){
      // Cube to make hotend mounting possible
      //mount_th = 3;
      //translate([0,-14,-mount_th])
      //  cube([Drive_support_v[0],14,th+mount_th]);
      translate([towermove,-E3d_v6_support_height,0]){
        cube([Drive_support_v[0],
            Drive_support_height + E3d_v6_support_height,
            th]);
      }
    }
    // Hole for bearings supporting hobbed insert screw
    translate([Bearing_623_outer_diameter,Hobb_from_edge,-Big/2])
      M3_screw(Big);
    translate([Bearing_623_outer_diameter/2 + 5,
        Hobb_from_edge,
        +1])
      cylinder(r=Bearing_623_outer_diameter/2, h=Big);
    // Somewhat prolonged hole
    // Put something rubber-like in hole for suspension against
    // filament.
    for(i=[0:0.5:1])
    translate([Bearing_623_outer_diameter/2+5 // Center of hobb x-dir
               + Hobbed_insert_diameter/2
               + Extruder_filament_opening
               + Bearing_623_outer_diameter/2 - i,
        Hobb_from_edge,-1])
      M3_screw(Big, $fn=6);
  }

  // Foot to screw on to bottom_plate
  difference(){
    translate([towermove,Drive_support_height,
        -Drive_support_v[2]+th])
      // TODO
      // Rewrite drive stuff...
      cube([Drive_support_v[0]+8,
            Drive_support_v[1],
            Drive_support_v[2]]);
    // Screw holes...
    // This hole punching should really be done in bottom_plate module
    // Marking all hole punches with "punch" for easier removal later
    translate([Drive_support_v[0]+8-3,0,-Drive_support_v[2]+th+3])
      rotate([-90,0,0]) cylinder(r=3/2 + 0.1, h=Big); // punch
    translate([Drive_support_v[0]+8-3,0,th-3])
      rotate([-90,0,0]) cylinder(r=3/2 + 0.1, h=Big); // punch

    if(!non_motor_side){
      // Make space for big extruder gear
      // 2 inserted here to get alignment with extruder motor
      // screw holes in bottom_plate
      translate([Bearing_623_outer_diameter - 2,
                 Hobb_from_edge,
                 -Big_extruder_gear_height-4-0.02])
        cylinder(r= Drive_support_height
            -Hobb_from_edge
            +Drive_support_v[1] + 1.4,
            h=Big_extruder_gear_height+4, $fn = 50);
    // Screw hole
    translate([3+towermove,0,-Drive_support_v[2]+th+3])
      rotate([-90,0,0]) cylinder(r=3/2 + 0.1, h=Big); // punch
    }else{
      translate([Drive_support_v[0]/2,0,-Drive_support_v[2]+th+6])
        rotate([-90,0,0]) cylinder(r=3/2 + 0.1, h=Big); // punch
    }
  }
}
//rotate([0,3*90,0])
//drive_support_helper(1,Drive_support_towermove);
//rotate([0,3*90,0])
//  drive_support_helper(0,Drive_support_towermove);

// towermove moves materia but not antimateria of drive_support
module drive_support(towermove=Drive_support_towermove){
  e3d_x_center = Bearing_623_outer_diameter/2 +5 //Center of hobb x-dir
               + Hobbed_insert_diameter/2
               + Extruder_filament_opening/2
               + 0.7; // Add 0.7 because hobb pushes that way

  // This difference makes e3d mount
  difference(){
    for(k = [0,2*Drive_support_thickness // Bring supports to same z
        + 0.2 // 623 |.2mm| Hobb |.2mm| 623
        + Hobbed_insert_height
        + 0.0])
      // 2 inserted here to get alignment with extruder
      // motors screw holes in bottom_plate
      translate([0,0, k])
        mirror([0,0,k])
        drive_support_helper(k,towermove);

    //translate([14.7+1.5,-42.8,8.5]) rotate([-90,0,0]){
    translate([e3d_x_center, // Add 0.7 because hobb pushes that way
               - E3d_heatsink_height,
               Drive_support_thickness+(0.2+Hobbed_insert_height)/2])
      rotate([-90,0,0]){
        e3d_v6_volcano_hotend(fan=0);
        // Render some purple filament
        //color("purple") cylinder(r=1.75/2, h=80);
    }
    translate([e3d_x_center-1.6-E3d_mount_small_r+0.2,-7,-Big/2]) cylinder(r=1.6, h=Big);
    translate([e3d_x_center+1.6+E3d_mount_small_r-0.2,-7,-Big/2]) cylinder(r=1.6, h=Big);
  }
}
//rotate([0,-90,0])
//drive_support(2);
// Some dividing and stuff for printing
// == Extruder gear side ==
//rotate([0,90,0])
//rotate([0,180,0])
//intersection(){
//  drive_support();
//  translate([-1,-16,-23])
//  cube([50,60,30]);
//}

// == Not extruder gear side ==
//rotate([0,90,0])
//rotate([0,0,180])
//difference(){
//  drive_support();
//  translate([-1,-16,-23])
//  cube([50,60,30]);
//}


//** Plates start **//

// An upside down hook that can be printed without support structure
module hook(height=10){
  line_radius = 0.90;
  big=30;
  difference(){
    // Main cube
    translate([-3,-4,0])
      cube([6,8,height]);
    // Hole
    translate([0,-line_radius/2,height])
      rotate([30,0,0])
        cylinder(r=line_radius, h=15.5, center=true);
    translate([0,4.1,4.7])
    // Bent end of channel
    difference(){
      rotate([0,90,0])
        rotate_extrude(convexity=4, $fn=20)
          translate([1.3,0,0])
            circle(r=line_radius, $fn=25);
      rotate([30,0,0])
        translate([-big/2,-big/2,0])
          cube(big);
    }
    //translate([10,-1,height-4])
    //  rotate([0,-90,0])
    //    M3_screw(20);
  }
}
//hook();

module top_flerp(side_length){
  difference(){
    eq_tri(side_length,Top_plate_thickness);
    translate([0,0,0]) cylinder(r=M3_diameter/2,h=Big,center=true);
  }
}

// Translation, iterating and rotating modules
module z_gatt_translate(back = 0){
  for(i=[0,120,240])
    rotate([0,0,i])
      translate([0,Full_tri_side/Sqrt3 - back,0])
        children(0);
}

// Flip before printing
module top_plate(){
  th = Top_plate_thickness;
  flerp_side=23;
  height = 17;
  melt=0.1;
  translate([0,0,height])
    mirror([0,0,1]){
  // Base plate
  difference(){
    eq_tri(Full_tri_side, th);
    translate([0,0,-1])
      eq_tri(Full_tri_side-15, th+2);
  }
  for(i=[0,120,240])
    // Screw holes
    rotate([0,0,i]){
      translate(Line_contact_d_xy)
        translate([0,-7.5,0])
        top_flerp(flerp_side);
      // Hook holes for line
      translate(Line_contact_d_xy)
        translate([0,0,th-melt])
        hook(height-th+melt);
    }
  // Mark action point d
  cylinder(r=2, h=height);
  rotate([0,0,60])
    for(i=[0,120,240]) rotate([0,0,i])
      difference(){
        translate([-1.5,0,0])
          cube([3,Full_tri_side*Sqrt3/6,height]);
        translate([-2.5,0,height])
          rotate([-10,0,0])
          cube([5,Full_tri_side*Sqrt3/6+3,height]);
      }
    }
}
//rotate([180,0,15])
//top_plate();

//%cube([139,139,20]);
module parted_top_plate_piece1(){
  th = Top_plate_thickness;
  flerp_side=21;
  height = 15;
  melt=0.1;
  translate([0,Full_tri_side/(2*Sqrt3),0])
  difference(){
    eq_tri(Full_tri_side/2, th);
    translate([0,-6,-1])
      eq_tri(Full_tri_side/2-15+6*Sqrt3, th+2);
    translate([0,- Full_tri_side/(2*Sqrt3),0])
    // Cut the sharp points
    for(k=[0,-1])
      mirror([k,0,0])
        rotate([0,0,30])
        translate([(Full_tri_side-15)/(2*Sqrt3),0,-1])
        cube([15,5/2,th+2]);
  }
  translate(Line_contact_d_xy)
    translate([0,-5.5,0])
    top_flerp(flerp_side);
  // Hook holes for line
  translate(Line_contact_d_xy)
    translate([0,0,th-melt])
    hook(height-th+melt);
  // Flerp to screw together parts
  for(k=[0,-1])
    mirror([k,0,0])
      rotate([0,0,30])
      translate([(Full_tri_side-15)/(2*Sqrt3),1.5,0])
      difference(){
        cube([14,3,th]);
        translate([10,-1,th/2])
          rotate([-90,0,0])
          cylinder(r=M3_diameter/2, h=5);
      }
}
//parted_top_plate_piece1();
//translate([-139/2,-17,0])
//%cube([139,139,20]);
//parted_top_plate_piece1();
//translate([0,-25,0,])
//parted_top_plate_piece1();
//translate([0,2*-25,0,])
//parted_top_plate_piece1();

// Fits on a Huxley
module parted_top_plate_piece2(){
  th = Top_plate_thickness;
  flerp_side=22;
  height = 15;
  melt=0.1;
  cylinder(r=2, h=height);
  rotate([0,0,60])
    for(i=[0,120,240]) rotate([0,0,i])
      difference(){
        translate([-1.5,0,0])
          cube([3,Full_tri_side*Sqrt3/6,height]);
        translate([-2.5,0,height])
          rotate([-9.7,0,0])
          cube([5,Full_tri_side*Sqrt3/6+3,height]);
      }
  for(k=[[0,0,0],[-1,0,0],[1,Sqrt3,0]])
    mirror(k)
      rotate([0,0,30])
      translate([(Full_tri_side-15)/(2*Sqrt3),-1.5,0])
      difference(){
        cube([14,3,th]);
        translate([10,-1,th/2])
          rotate([-90,0,0])
          cylinder(r=M3_diameter/2, h=5);
      }
}
//parted_top_plate_piece2();

module side_plate2(height=15,th=7){
  s = Abc_xy_split + 2*6;
  translate([0,0,0]){
    difference(){
      translate([-s/2,-th,-height/2])
        cube([s,th,height]);
      // Wall screw holes
      for(k=[1,0])
        mirror([k,0,0])
          translate([Abc_xy_split/2 - 10,-th-1,0])
            rotate([-90,0,0]){
              cylinder(r=M3_diameter/2, h=Big);
              translate([0,0,th/2]) cylinder(r=M3_head_diameter/2,h=Big);
            }
      // Hook holes
      for(k=[1,0])
        mirror([k,0,0]){
          translate([Abc_xy_split/2,-th-1,0])
            rotate([-90,0,0])
              cylinder(r=0.75, h=Big);
          translate([-1 + Abc_xy_split/2, -th - th +2, -height])
            cube([2, th, 2*height]);
          // Holes for adjustment screws. Intentionally narrow
          translate([20,-th/2,-Big/2])
            cylinder(r=1.45,h=Big);
        }
      // Mark wall action point
      rotate([15,0,0]) translate([-1,0,0]) cube([2,5,height]);
      mirror([0,0,1])
        rotate([15,0,0]) translate([-1,0,0]) cube([2,5,height]);
    }
    // Pulleys to wind line around
    for(k=[1,-1])
      translate([k*(Abc_xy_split/2 - 8),0,0]){
        translate([-4.5,-3,height/2-0.1]) cylinder(r=2.5, h=7);
        translate([ 4.5,-3,height/2-0.1]) cylinder(r=2.5, h=7);
      }
  }
}
//side_plate2();

module side_plate3(height=15,th=7){
  s = Abc_xy_split + 2*6;
  d = 7;
  a = s/2 - Sqrt3*d/2;
  translate([0,th,0]){
    difference(){
      union(){
        // Main cube (the one where lines enter)
        translate([-s/2,-th,-height/2])
          cube([s,th,height]);
        // Short leg
        translate([-s/2+Sqrt3*d,-1,-height/2])
          cube([th, d+1, height]);
        // Long leg
        translate([s/2 - th - Sqrt3*d,-4,-height/2])
          rotate([0,0,30])
          cube([th, a+0, height]);
        // Foot of short leg
        translate([-s/2+Sqrt3*d+th/2,d-th*Sqrt3/2,-height/2])
          rotate([0,0,30])
          cube([15,th,height]);
        // Foot of long leg
        translate([-s/2+Sqrt3*d+th/2,d-th*Sqrt3/2,-height/2])
          rotate([0,0,30])
          translate([Sqrt3*a-2*d-14-1.5-th,0,0])
          cube([16,th,height]);
        // Pulleys to wind line around
        for(k=[1,-1])
          translate([k*(Abc_xy_split/2 - 8),0,0]){
            translate([-4.5,-3,height/2-0.1]) cylinder(r=2.5, h=7);
            translate([ 4.5,-3,height/2-0.1]) cylinder(r=2.5, h=7);
          }
      }
      // Hook holes (Where lines enter)
      for(k=[1,0])
        mirror([k,0,0]){
          translate([Abc_xy_split/2,-th-1,0])
            rotate([-90,0,0])
              cylinder(r=0.75, h=Big);
          translate([-1 + Abc_xy_split/2, -2, -height])
            cube([2, th, 2*height]);
          // Holes for adjustment screws. Intentionally narrow
          translate([20,-th/2,-Big/2])
            cylinder(r=1.45,h=Big);
        }
      translate([-s/2+27,0,0])
      rotate([-90,0,30]){
        translate([0,0,-11]) cylinder(r=7/2,h=20);
        cylinder(r=M3_diameter/2,h=42,center=true);
      }

      translate([s/2-29,0,0])
        rotate([-90,0,30]){
        translate([0,0,20]) cylinder(r=M3_diameter/2,h=54);
        translate([0,0,20]) cylinder(r=7/2,h=40);
        // A little space for a screwdriver along long leg
        rotate([-7,0,0])
        translate([0,-7,-11]) cylinder(r=7/2,h=44);
      }
      // Mark wall action point
      for(k=[0,1])
        mirror([0,0,k])
        translate([0,-th,0])
        rotate([-15,0,0]) translate([-1,-5,0]) cube([2,5,height]);
    }
  }
}
//mirror([1,0,0])
//side_plate3();



