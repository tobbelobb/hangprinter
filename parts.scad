include <measured_numbers.scad>
include <util.scad>
include <design_numbers.scad>
use <Nema17_and_Ramps_and_bearings.scad>
use <Gears.scad>
use <render_parts.scad>

module d_motor_move(){
  rotate([0,0,D_placement_angle+24]) // TODO: parametrize 24 here
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
  trdist = Fish_ring_holes_distance + Fish_ring_outer_radius_high_part;
  // Bring action point to origo
  translate([0,-Fish_ring_inner_radius,0])
  difference(){
    union(){
      color("black")
        cylinder(r=ins_ro, h=Fish_ring_height, center=true);  // Inside ring (cheramic)
      color("grey")
        cylinder(r=edg_r, h=Fish_ring_thinnest_outer_edge, center=true);
      translate([0,0,-Fish_ring_thinnest_outer_edge/2])
      color("grey")
      linear_extrude(height=Fish_ring_thinnest_outer_edge, slices=1)
        polygon(points = [tangent_point(edg_r, [0,-trdist]),
                          tangent_point_3(edg_r, [0,-trdist]),
                          [0,-trdist]],
                paths = [[0,1,2]]);
      translate([0,-Fish_ring_holes_distance,0]){
        color("black")
          translate([0,0,Fish_ring_largest_height/4])
          cylinder(r=Fish_ring_outer_radius_high_part, h=Fish_ring_largest_height, center=true);
        color("grey")
          cylinder(r=hol_r1, h=Fish_ring_thinnest_outer_edge, center=true);
        color("grey")
          cylinder(r=hol_r2, h=hol_h-Fish_ring_thinnest_outer_edge/2);
      }
    }
    // The two holes (ceramic and lar ring)
    cylinder(r=Fish_ring_inner_radius, h=Fish_ring_height+2, center=true);
    translate([0,-Fish_ring_holes_distance,0])
      cylinder(r=lar_ri, h=Fish_ring_largest_height*2, center=true);
  }
}
//fish_ring();

module d_fish_ring_move(){
  for(i=[0,1,2]){
    rotate([0,0,120*i])
      translate(Line_contact_d_xy
         + [0,-Bearing_623_outer_diameter/2,Line_contacts_abcd_z[D]])
      rotate([fish_ring_d_rotation,0,0])
      children();
  }
}

// D-lines' fish rings
// Mirror([0,0,1]) here??
module placed_d_rings(){
  d_fish_ring_move()
      fish_ring();
}

module placed_fish_rings(){
  for(i=[0,1,2]){
    rotate([0,0,120*i]){
      for(k=[0,1])
        mirror([k,0,0])
          translate(Line_contact_abc_xy
            + [0,0, Line_contacts_abcd_z[i]
            + Fish_ring_inner_radius
            + Fish_ring_inner_radius/sqrt(2)])
          rotate([90,0,fish_ring_abc_rotation])
          translate([-Fish_ring_inner_radius/sqrt(2),0,0])
          mirror([0,0,1])
          fish_ring();
    }
  }
  placed_d_rings();
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
             Sstruder_filament_meets_shaft + Nema17_cube_height,
             -Nema17_screw_hole_dist/2 + Bottom_plate_thickness/2 + E_motor_z_offset])
    rotate([90,0,0])
    for(i=[0:$children-1]){
      children(i);
    }
}

// The thing separating bearings on center axis of bottom plate
// TODO: Rename to sandwich_spacer
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
  bpr = Bottom_plate_radius+6.5;
  bd  = Bearing_608_bore_diameter;
  bw  = Bearing_608_width;
  swh = Sandwich_height;
  gap = Sandwich_gap;
  sandwich_stick_height = Line_contacts_abcd_z[A]+swh-Snelle_height/2
                 + 5; // for putting some kind of top lock mechanism
  big=5*th;

  // A star with 5 round arms
  module enclose_motors_2d(){
    r_save = 10;
    polygon([for (i=[0:2:359.9])
     (bpr-r_save)*[cos(i), sin(i)] + r_save*sin(5*i)*[cos(i),sin(i)]]);
  }

  module material_saving_triangle(){
    r_save = Full_tri_side/sqrt(12);
    polygon([for (i=[0:2:359.9])
     (Full_tri_side/Sqrt3-r_save)*[cos(i), sin(i)]
                + (sin(3*i)>0 ?
       r_save*sin(3*i)*sin(3*i)*sin(3*i)*sin(3*i)*[cos(i),sin(i)] :
       [cos(i),sin(i)])]);
  }

  // Every non-planar part of bottom_plate()
  module towers(){
    difference(){
      union(){
        // Sandwich stick, center cylinder
        cylinder(r=bd/2+0.16,
            h=sandwich_stick_height);
        // Bluetooth mount (and autocooling while printing tower)
        rotate([0,0,150])
          translate(Line_action_point_abc_xy)
          cube([4.2,4.2,sandwich_stick_height]);
        // The bottom lock
        cylinder(r=Lock_radius_2, h=th + Bottom_plate_sandwich_gap);
        // Mounting towers for D fish rings
        for(i=[0,120,240]){
          rotate([0,0,i]){
            translate(Line_contact_d_xy){
              cube_x1 = 10;
              cube_y1 = 6;
              translate([-cube_x1/2,0,0])
                cube([cube_x1,cube_y1,Line_contacts_abcd_z[D]]);
              // Block to put d fish ring in
              translate([-cube_x1/2,-0.5,0])
                rotate([fish_ring_d_rotation-90,0,0])
                cube([cube_x1,cube_y1,Line_contacts_abcd_z[D]-1]);
            }
          }
        }
        // Mounting towers for abc fish rings
        for(i=[0,1,2]){ // i used for rotation and indexing
          rotate([0,0,i*120]){
            for(k = [0, 1]){
              mirror([k,0,0]){
                translate(Line_contact_abc_xy)
                  rotate([0,0,fish_ring_abc_rotation])
                  translate([-6-Fish_ring_inner_radius , -Fish_ring_thinnest_outer_edge/2+0.01,0])
                  cube([12,5.5,Line_contacts_abcd_z[i] - Fish_ring_inner_radius]);
              }
            }
          }
        }
      }// end union
      // Holes in d line towers
      for(i=[0,120,240]){
        rotate([0,0,i]){
          cube_x2 = 6.6;
          cube_y2 = 6;
          channel_length = 9;
          translate(Line_contact_d_xy){
              translate([0,0,Line_contacts_abcd_z[D]-3.0]){
                rotate([0,-90,0])
                  // Hole for d line length adjusting screw
                  cylinder(d=M3_diameter, h=15,center=true);
                translate([-1,-2.5,-1.7])
                  cube([2,5,10]);

            } // end translate
          } // end translate Line_contact_d_xy
        }
      }
      // Mounting space for d fish_rings
      // Holes for M3 fastening d_fish_rings
      d_fish_ring_move(){
        translate([0,
            -Fish_ring_inner_radius - Fish_ring_holes_distance,0]){
          translate([0,0,-big+5])
            cylinder(d=M3_diameter, h=big);
          //M3 screw headhole
          translate([0,0,-big - 3])
            cylinder(r=M3_head_diameter/2,h=big);
        }
      }
      // Dig out filament hole in sandwich stick
      // Note that bowden tube should fit in this from below
      translate([0, 0, -1]) cylinder(r = 2.3, h = Big);
      // Mounting holes for abc fish rings
      // rotations and translations synced with placed_fish_rings
      for(i=[0,1,2]){ // Used both for rotation and indexing
        rotate([0,0,i*120]){
          for(k=[0,1]){
            mirror([k,0,0]){
              translate(Line_contact_abc_xy
                  +[0,0,Line_contacts_abcd_z[i] + Fish_ring_inner_radius + Fish_ring_inner_radius/Sqrt2])
                rotate([90,0,fish_ring_abc_rotation]){
                  translate([-Fish_ring_inner_radius/Sqrt2,0,0])
                    translate([0,-Fish_ring_holes_distance-Fish_ring_inner_radius,0]){
                      cylinder(r=M3_diameter/2+0.3, h = 25, center=true);
                    }
                }
            }
          }
        }
      }
      // Tracks to put fish rings in
      placed_fish_rings();
    }// end difference
  }// end module towers

  union(){
    difference(){
      union(){
        // Largest possible triangular plate
        //eq_tri(Full_tri_side, th);
        //... swapped out with a material saving variant:
        rotate([0,0,60])
        linear_extrude(height=th, convexity=10)
          material_saving_triangle();
        // Circular bottom plate
        //cylinder(r=bpr, h = th);
        //... swapped out with a more fitting shape:
        linear_extrude(height=th, convexity=10)
          enclose_motors_2d();
        // Get behind d motors back
        translate([7,-bpr/2+1,0])
          rotate([0,0,D_placement_angle+24]) // TODO: 24.parametrize
          cube([Nema17_cube_height+10, 20, th]);
        // Mounting tower for D motor and connectorblock
        // Really a tower but put here because
        // Screw hole need to be synced with d motor screw holes
        // in bottom plate
        d_motor_move(){
          rotate([0,0,45]) translate([Nema17_screw_hole_width/2,0,0])
            translate([-6,0,Nema17_cube_height])
            rotate([90,0,45-D_motor_twist])
            translate([-1,0,
                M3_diameter+1.08
                -sin(45-D_motor_twist)*Nema17_screw_hole_width/2
                -Snelle_height/2
                -Lock_height
                -Bottom_plate_thickness]){
              // Mounting tower
              cube([13,5.5,21]);
              // Connectorblock
              cube([13,25,th]);
            }
        }

      } // End union

      //*** ANTIMATERIA STARTS HERE ***//

      for(i=[0,120,240]){
        rotate([0,0,i]){
          cube_x2 = 6.6;
          cube_y2 = 7;
          channel_length = 9;
          translate(Line_contact_d_xy){
            // Cut bottom plate triangle tip
            translate([-10, Bearing_623_outer_diameter/2 + 1.05, -1])
              cube([20,20,Line_contacts_abcd_z[D]-2]);
            // Mounting space for d fish_rings
            translate([0, 0, 1]){
            //  translate([-cube_x2/2,-cube_y2,0])
            //    rotate([fish_ring_d_rotation-90,0,0])
            //    translate([0,1,1.5])
            //    cube([cube_x2,cube_y2,Line_contacts_abcd_z[D]-1]);
            // Straight edge towards center of the d fish ring hole
            // Cut some room for d ring tower
            translate([-cube_x2/2,-15,-big+th+1])
              cube([cube_x2,25,big]); // Block to put fish ring in
            }
          }// end translate Line_contact_d_xy
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
          rotate([0,0,45])
          Nema17_schwung_screw_holes(M3_diameter+0.2, th+2, 18);
        four_point_translate(d_object=false)
          translate([0,0,th-3.5])
          rotate([0,0,270+45])
          Nema17_screw_holes(M3_head_diameter+0.1, th+2, 3);
      }
      // Hole for worm driving d-motor
      d_motor_move(){
        translate([0,0,-1.5])
          scale(1.02){ // Leave 2 percent gap for easy mounting
            translate(([-Nema17_cube_width/2, -Nema17_cube_width/2, 0]))
              cube([Nema17_cube_width, Nema17_cube_width, Nema17_cube_height]);
            cylinder(d=Nema17_ring_diameter, h=Nema17_cube_height+Nema17_ring_height);
            translate([0,0,Nema17_cube_height+4.2])
            cylinder(h=Worm_axle_length,
                     r1=Worm_axle_radius+2.5,
                     r2=Worm_axle_radius+2.5+Worm_axle_length);
            //Nema17();
          }
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
        // Hole for extruder motor
        scale(1.015){ // Leave 1.5% extra space, don't need tight fit
          translate(([-Nema17_cube_width/2, -Nema17_cube_width/2, 0]))
            cube([Nema17_cube_width, Nema17_cube_width, Nema17_cube_height
             + Sstruder_thickness]); // Make space for sstruder_plate
          //Nema17();
        }
        // Diff'ing sstruder directly here gives unwanted artifacts and details
        //translate([0,0,Nema17_cube_height])
        //  translate([-Nema17_cube_width/2,
        //      -Sstruder_height+Nema17_cube_width/2,
        //      0])
        //  cube([Nema17_cube_width,Sstruder_height,Sstruder_thickness+0.2]);
          //sstruder_plate();
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
      }// end extruder_motor_translate()

      // Funnel shape for easier bowden tube fit
      translate([0,0,-0.1])
        cylinder(h=3, r1=3, r2=2);
      // Filament hole up to sandwich stick
      translate([0, 0, -1]) cylinder(r = 2.3, h = Big);
    }// end difference
    towers();
    translate([64,-22.5,Bottom_plate_thickness/2])
      rotate([0,90,90-D_motor_twist])
      scale([1,3,1])
      difference(){
        cylinder(r=Bottom_plate_thickness/2+Sandwich_gear_height, h=10, center=true);
        translate([0,-25,-25])
        cube(50);
      }
  }// end union
}
// The rotate is for easier fitting print bed when printing
// this part on 200 mm square print bed
//rotate([0,0,15])
//bottom_plate();

//** bottom_plate end **//

// Sandwich is defined in Gears.scad
// Motors are defined in Nema17_and_Ramps_and_bearings.scad


//** extruder start **//

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
    translate([0,0,E3d_heatsink_height-3.7])     cylinder(h=3.7, r=E3d_mount_big_r);
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

module e3d_v6_mount_bore(d = 5){
  // Bowden tube
  cylinder(d=Bowden_tube_diameter+0.4,h=31);
  // Extra space for bowden fastener
  cylinder(d=Bowden_tube_diameter+2.6,h=14);
  translate([-(Bowden_tube_diameter+2.6)/2,0,0])
    cube([Bowden_tube_diameter+2.6,d,14]);
  // Downmost
  translate([0,0,-1-3])
    cylinder(h=3.1, r=E3d_mount_big_r+0.25);
  translate([-E3d_mount_big_r-0.25,0,-4])
    cube([2*E3d_mount_big_r+0.5,d,3.1]);
  // Next Downmost
  cylinder(h=3, r=E3d_mount_big_r);
  translate([-E3d_mount_big_r,0,-0.0]) // Stop Z-fighting and give some more space
    cube([2*E3d_mount_big_r,d,3+0.0]);
  // Middle
  translate([0,0,2.9]) cylinder(h=6.2, r=E3d_mount_small_r); // 0.1 melt zone...
  translate([-E3d_mount_small_r,0,2.9]) cube([2*E3d_mount_small_r,d,6.2]);
  // Uppermost
  translate([0,0,3+6]){
    cylinder(h=3.7+0.05, r=E3d_mount_big_r);
    translate([-E3d_mount_big_r,0,0]) cube([2*E3d_mount_big_r,d,3.7+0.05]);
  }
  // Hot end continues downwards
  translate([0,0,-9.9]){
    cylinder(r=4.2, h=10.1);
    translate([-4.2,0,0]) cube([4.2*2,d,10]);
  }
}
//e3d_v6_mount_bore(10);

//e3d_v6_volcano_hotend();

//** Plates start **//


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
  flerp_side=24;
  height = 20;
  melt=0.1;
  line_radius = 0.90;

  // An upside down hook, printable without support structure
  module hook(height=10){
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
    }
  }
  //hook();

  module top_flerp(side_length){
    difference(){
      eq_tri(side_length,Top_plate_thickness);
      cylinder(d=M3_diameter,h=Big,center=true);
      translate([0,0,3])
        cylinder(d=M3_head_diameter,h=Top_plate_thickness);
    }
  }

  translate([0,0,height])
    mirror([0,0,1]){
      // Base plate
      difference(){
        eq_tri(Full_tri_side, th);
        translate([0,0,-1]){
          eq_tri(Full_tri_side-15, th+2);
          // Cut tip so printing gets easier
          for(i = [0,120,240])
            rotate([0,0,i])
              translate([-10,Full_tri_side/sqrt(3) - 8,0])
              cube([20,20,th+2]);
        }

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
      difference(){
        union(){
          // Radial walls
          for(i=[0,120,240])
            rotate([0,0,i+60])
              translate([-1.5,0,0])
              cube([3,Full_tri_side*Sqrt3/6,height]);
          // Middle cylinder
          cylinder(r=4, h=height);
        }
        // Hole for line in middle
        translate([0,0,-1])
          cylinder(r=line_radius, h=height+2);
        // Opening between ceiling and center hole
        translate([0,0,-1])
          cylinder(r1=10, r2=0, h=12);
          // Make radial walls slant
          for(i=[0,120,240])
            rotate([0,0,i+60])
              translate([-2.5,0,height])
              //rotate([-11,0,0])
              rotate([-90+atan((Full_tri_side/sqrt(12))/(height-Top_plate_thickness)),0,0])
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
          translate([20,-th/2,0]){
            translate([0,0,-Big/2])
              cylinder(d=M3_diameter, h=Big);
            // Nut traps for adjustment screws
            translate([0,-0.1,2.5])
              rotate([90,0,0])
              rotate([0,0,90])
              M3_nyloc_trap();
          }

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
          // Holes for adjustment screws.
          translate([20,-th/2,0]){
            translate([0,0,-Big/2])
              cylinder(d=M3_diameter,h=Big);
            // Nut traps for adjustment screws
            mirror([0,1,0])
              translate([0,-0.1,2.5])
              rotate([90,0,0])
              rotate([0,0,90])
              #M3_nyloc_trap();
          }
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


// Only for rendering
module hobbed_insert(){
  color("grey")
    cylinder(r=Hobbed_insert_diameter/2, h=Hobbed_insert_height);
}
//hobbed_insert();

// We want to use small 623 bearings
// but we also want to use two hobbs, bores equal to motor shaft diameter
// Cut in half and lay down to print
module hobbed_insert_shaft(){
  // Inside lower bearing and arm
  cylinder(d=Bearing_623_bore_diameter, h=Bearing_623_width+Sstruder_handle_height+0.1);
  translate([0,0,Sstruder_handle_height + Bearing_623_width]){
    // Inside hobb
    cylinder(d=Nema17_motor_shaft, h=Hobbed_insert_height);
    translate([0,0,Hobbed_insert_height]){
      // Inside Sstruder gear
      cylinder(d=Sstruder_gear_diameter, h=Sstruder_gear_thickness);
      translate([0,0,Sstruder_gear_thickness]){
        // Inside upper bearing and arm
        cylinder(d=Bearing_623_bore_diameter, h=Bearing_623_width+Sstruder_handle_height+0.1);
      }
    }
  }
}
//hobbed_insert_shaft();


module hobb_towers(v=[0,0,0], bearings_and_shaft=false){
  translate([0,0,Bearing_623_width+Sstruder_handle_height+0.1])
  // The hobbed insert itself
  translate(v){
    hobbed_insert();
    // Only place insert shaft and bearings if not at center
    if(bearings_and_shaft){
      // The insert shaft
      translate([0, 0, - Sstruder_handle_height - Bearing_623_width - 0.1])
        hobbed_insert_shaft();
      // Lower bearing
      translate([0, 0, - Bearing_623_width - 0.1])
        Bearing_623();
      // Higher bearing
      translate([0, 0, 0.1 + Hobbed_insert_height + Sstruder_gear_thickness])
        Bearing_623();
    }
  }
}
//hobb_towers(0,true);

module sstruder_lever_move(){
  translate([Hobbed_insert_diameter + Extruder_filament_opening,
      0,
      Sstruder_filament_meets_shaft // Involved but safe way to say Sstruder_thickness
      - Hobbed_insert_height/2
      - Sstruder_handle_height
      - Bearing_623_width])
    rotate([0,0,-Sstruder_press_angle]) // rotate around hobb
    translate([Sstruder_hinge_length,Sstruder_fork_length,0])
    rotate([0,0,0]) // rotate around hinge
    translate([-Sstruder_hinge_length,-Sstruder_fork_length,0])
      children(0);
}

module sstruder_lever(hobb=true){
  thickness = 3; // Of material. Leave enough for stiffness
  width = Bearing_623_outer_diameter; // Of rectangular part of arms...
  height = Sstruder_fork_width;

  module bearing_holder(l,th=Sstruder_lever_thickness){
    difference(){
      union(){
        translate([-width/2-Sstruder_edge_around_bearing, 0, 0])
          cube([width+2*Sstruder_edge_around_bearing, l, th]);
        rotate([0,0,180])
        teardrop(r=Bearing_623_outer_diameter/2+Sstruder_edge_around_bearing, h = th);
      }
      if(th==Sstruder_lever_thickness){
        translate([0,0,-1]){
          rotate([0,0,180])
          teardrop(r=Bearing_623_outer_diameter/2, h = Sstruder_lever_thickness+2);
        }
      } else {
        translate([0,0,-2]){
          rotate([0,0,180])
          teardrop(r=Bearing_623_outer_diameter/2, h = Sstruder_lever_thickness+2);
        }
      }
      translate([0,0,-th]){
        rotate([0,0,180])
        teardrop(r=Bearing_623_outer_diameter/2-1, h = 2.1*th);
      }
      // Cut tip of teardrops to avoid interfering with motor shaft
      translate([-5,-10-Bearing_623_outer_diameter/2,-1])
        cube([10,10,th+2]);
    }
  }

  // The two bearing holding arms
  color(Printed_color_1)
    bearing_holder(Sstruder_fork_length + Sstruder_lever_thickness);
  color(Printed_color_1)
    translate([0,0, // long line for z...
        Bearing_623_width
        + Hobbed_insert_height
        + Sstruder_gear_thickness
        + 2*Sstruder_handle_height
        + (Bearing_623_width-Sstruder_lever_thickness)])
    bearing_holder(Sstruder_fork_length+Sstruder_lever_thickness, Sstruder_lever_thickness+1);

  // Block connecting hinge and bearing holder arms
  color(Printed_color_1)
  difference(){
    union(){
      translate([-width/2-Sstruder_edge_around_bearing,Sstruder_fork_length,0])
        cube([Bearing_623_outer_diameter/2
            + Sstruder_edge_around_bearing
            + Sstruder_hinge_length
            + Sstruder_edge_around_bearing,
            Sstruder_lever_thickness,
            height]);
      // Wall around hinge screw
      translate([Sstruder_hinge_length,Sstruder_fork_length,0]){
        cylinder(d=M3_diameter+2*Sstruder_edge_around_bearing, h=height,$fn=30);
      }
    }
    // Hole for hinge screw
    translate([Sstruder_hinge_length,Sstruder_fork_length,-1])
      cylinder(d=M3_diameter+0.3, h=height+2);
  }
  if(hobb){
    hobb_towers([0,0,0],true);
  }
}
//rotate([-90,0,0])
//sstruder_lever(false);

module sstruder_plate(hobb=true){
  hot_end_fastening_h = 16;
  ring_hole_d = (Nema17_ring_diameter+4);
  extra_width_for_lever = 7;
  // Interface between sstruder block and lever
  pressblock_edge = Nema17_cube_width/2 + extra_width_for_lever - Sstruder_pressblock_thickness;
  lever_edge = Hobbed_insert_diameter
               + Extruder_filament_opening
               + Sstruder_fork_length
               + Sstruder_lever_thickness;

  module hinge_digger(){
    // Make space for the hinge
    height = 2*Bearing_623_width
      + Hobbed_insert_height
      + Sstruder_gear_thickness
      + 2*Sstruder_handle_height;
    sstruder_lever_move()
      translate([Sstruder_hinge_length,Sstruder_fork_length,0.3]){
        cylinder(d=M3_diameter+2*Sstruder_edge_around_bearing+1, h=height);
        translate([-M3_diameter/2-Sstruder_edge_around_bearing,0,0])
          cube([M3_diameter+2*Sstruder_edge_around_bearing,
              (M3_diameter+2*Sstruder_edge_around_bearing)/2,
              height]);
      }

  }

  module channel_for_hotend_tube(){
    color(Printed_color_2)
    difference(){
      // Block for channel for tube
      translate([-(Bowden_tube_diameter+4)/2 - E_motor_x_offset,
          -(Sstruder_height-Nema17_cube_width/2 - hot_end_fastening_h-2),
          0])
        cube([Bowden_tube_diameter+4, // 2mm walls on each side of tube
            Sstruder_height - Nema17_cube_width/2 - hot_end_fastening_h - 3, // Tube cavety length
            Sstruder_filament_meets_shaft  + 2.5]);
      // Make channel_cube lean towards filament
      translate([0,-ring_hole_d/2,0])
        rotate([45,0,0])
        translate([-10,0,-30])
        cube(30);
      // But cut it before it reaches the hobb
      translate([-15,-1,0.1])
        cube(30);
      // Cut around hobb 1
      cylinder(d = Hobbed_insert_diameter + 0.6, h = 30, $fn=60);
      // Cut around hobb 2
      translate([Hobbed_insert_diameter + Extruder_filament_opening, 0, 0])
        cylinder(d = Hobbed_insert_diameter + 0.6, h = 30, $fn=60);
      // tube channel
      translate([-E_motor_x_offset,1,Sstruder_filament_meets_shaft])
        rotate([90,0,0])
        teardrop(Bowden_tube_diameter/2, Sstruder_height);
    }
  }

  module flat_block(){
    // Main flat block
    translate([-Nema17_cube_width/2,
        -Sstruder_height+Nema17_cube_width/2, 0])
      cube([Nema17_cube_width,Sstruder_height,Sstruder_thickness]);
    // support for hinge screw
    translate([0,
        -Sstruder_height + Nema17_cube_width/2,
        0])
      cube([Nema17_cube_width/2+2,
          Sstruder_pressblock_height,
          Sstruder_thickness]);
  }

  pressblock_cyl_radius = 3.1;
  module pressblock_cyl(){
    difference(){
      cylinder(r=pressblock_cyl_radius, h=Sstruder_fork_width+4, $fn=40);
      translate([0.5,0,-1])
        M3_screw(Sstruder_fork_width+10,true);
    }
  }
  //!pressblock_cyl();

  pressblock_handlecyl_radius = 4.4;
  scaling_factor = 1.5;
  module pressblock_handle(){
    difference(){
      union(){
        scale([scaling_factor,1,1])
          cylinder(r=pressblock_handlecyl_radius, h=Sstruder_fork_width, $fn=45);
        // Handle
        difference(){
          translate([-Sstruder_thickness + pressblock_handlecyl_radius*scaling_factor,
                     -Sstruder_hinge_length,
                     Sstruder_fork_width*0.66]){
            cube([Sstruder_thickness, Sstruder_hinge_length, Sstruder_fork_width*0.34]);
            rotate([0,0,21])
            cube([Sstruder_thickness, Sstruder_hinge_length, Sstruder_fork_width*0.34]);
            rotate([-45,0,21])
            translate([0,10,10])
            difference(){
              cube([Sstruder_thickness, Sstruder_hinge_length, Sstruder_fork_width*0.43]);
              translate([-1,Sstruder_hinge_length/sqrt(2),-1])
              rotate([45,0,0])
              translate([0,0,-Big/2])
              cube(Big);
            }
          }
          translate([-10,-Sstruder_hinge_length,Sstruder_fork_width])
            rotate([-45,0,0])
            translate([0,0,-Sstruder_fork_width])
            cube([20,60,Sstruder_fork_width]);
        }
      }
      translate([pressblock_handlecyl_radius*(scaling_factor-1)/2,0,0])
      translate([0,0,-1])
      cylinder(r=pressblock_cyl_radius+0.1, h=Sstruder_fork_width+4,$fn=20);
      translate([-10-pressblock_handlecyl_radius*scaling_factor+0.7, -pressblock_handlecyl_radius,-1])
      cube([10,pressblock_handlecyl_radius*2,Sstruder_fork_width+2]);
    }
  }
  //!rotate([180,0,0]) pressblock_handle();
  //!pressblock_handle();

  extra_width_for_pressblock = 12;
  module pressblock(){
    difference(){
    // Flat area for pressblock
    translate([-Nema17_cube_width/2,
        - Sstruder_pressblock_height
        + Bearing_623_outer_diameter/2
        + Sstruder_edge_around_bearing,
        0])
        cube([Nema17_cube_width + extra_width_for_pressblock,
            Sstruder_pressblock_height,
            Sstruder_thickness]);
      // For pressblock cyl
    translate([Nema17_cube_width/2 + extra_width_for_pressblock/1.5,
               0,
               -1])
      M3_screw(Sstruder_fork_width+Sstruder_thickness+2,true);
    }
  }

  module e3d_mount(){
    color(Printed_color_2)
    difference(){
      translate([-(E3d_mount_big_r*2+6)/2-E_motor_x_offset,
        -Sstruder_height+Nema17_cube_width/2,
        0]){
      cube([E3d_mount_big_r*2+6,hot_end_fastening_h,Sstruder_filament_meets_shaft  + 7]);
      }
      translate([-E_motor_x_offset,
          Sstruder_hot_end_bore_z,
          Sstruder_filament_meets_shaft])
        rotate([-90,0,0])
        rotate([0,0,180])
        e3d_v6_mount_bore(10);
        //hinge_digger();
    }
  }

  difference(){
    union(){
      color(Printed_color_2){
        flat_block();
        pressblock();
      }
    }
    // Screw holes for motor
    translate([0,0,-1])
      Nema17_screw_holes(M3_diameter, Sstruder_thickness+2);
    // Nema17 ring
    translate([0,0,-1])
      cylinder(d=ring_hole_d, h=Sstruder_thickness+2);
    // Hole for hinge screw. This must only be moved in perfect sync with lever hinge module...
    translate([lever_edge - Sstruder_lever_thickness,-Sstruder_hinge_length,-1])
      cylinder(d=M3_diameter+0.5, h = 38);
    //hinge_digger();
  }
  channel_for_hotend_tube();
  e3d_mount();

  if(hobb){
    translate([0,0,-Bearing_623_width])
    hobb_towers([0,0,Sstruder_filament_meets_shaft - Hobbed_insert_height/2]);

    translate([Nema17_cube_width/2 + extra_width_for_pressblock/1.5 -0.5,
               0,
               Sstruder_thickness]){
      pressblock_cyl();
      translate([-pressblock_handlecyl_radius*(scaling_factor-1)/2,0,0])
      color("blue") pressblock_handle();
    }
  }
}
//sstruder_plate(false);
//sstruder_plate();
//translate([0,0,-Nema17_cube_height])
// %Nema17();

module sstruder(hobb=false){
  sstruder_lever_move()
    sstruder_lever(hobb);
  sstruder_plate(hobb);
  //translate([0,0,-Nema17_cube_height])
  //  Nema17();
}
//sstruder();
//sstruder(true);
//rotate([-90,0,0])
//sstruder_lever(false);

module bearing_housing(){
  walls = 1.5;
  axis_gap = 0.3;
  diametral_gap = 1;
  depth = Bearing_623_vgroove_big_diameter + 1;
  hole = depth - walls - diametral_gap
               - Bearing_623_vgroove_big_diameter/2;


  // Shape occuring twice
  module housing_starter(d, h, th){
    difference(){
      translate([0,0,h-d/2])
        rotate([90,0,0])
        cylinder(d=d, h=th, center=true);
      translate([0,0,-d])
        cube(2*d, center=true);
    }
    translate([-d/2, -th/2, 0])
      cube([d, th, h-d/2]);
  }
  module standing_housing(){
    difference(){
      difference(){
        // Main subject
        housing_starter(Bearing_623_vgroove_big_diameter + 2*diametral_gap + 2*walls,
            depth,
            Bearing_623_width + 2*walls + 2*axis_gap, $fn=40);
      }
      difference(){
        // Diggin out space for bearing
        translate([0,0,-walls-diametral_gap])
          housing_starter(Bearing_623_vgroove_big_diameter + 2*diametral_gap,
              depth + diametral_gap,
              Bearing_623_width + 2*axis_gap, $fn=40);
        //Cylinders touching bearing
        for(i=[0,1])
          mirror([0,i,0])
            translate([0, -Bearing_623_width/2, hole])
            rotate([90,0,0])
            cylinder(d=5, h=walls + axis_gap);
      }
      // Hole for M3 screw
      translate([0,0,hole])
        rotate([90,0,0])
        cylinder(d=3.2, h=Bearing_623_width+2*walls+2, center=true);
    }
    hookring_gap = 2.001;
    hookring_diameter = 4;
    hookring_to_edge = (Bearing_623_width
                     + 2*walls + 2*axis_gap + hookring_gap)/2;
    difference(){
      for(i=[0,1])
        mirror([0,i,0])
          translate([0,
              -hookring_to_edge/2,
              depth - walls])
          housing_starter(hookring_diameter, 5,
              hookring_to_edge - hookring_gap, $fn=10);
      translate([0,0,
          depth - walls + 5 -hookring_diameter/2])
        rotate([90,0,0])
        cylinder(d=1.5,
                 h=hookring_to_edge + hookring_gap + 2,
                 center=true);
    }
  }
  module differencer(extra=0){
    default_arm_thickness = 6;
    translate([-25,1,-1])
      cube(50);
    for(i=[15:-210/2:-210])
      translate([0,0,hole])
      rotate([0,i,0])
        translate([0,
               -1,
               -default_arm_thickness/2-extra/2])
        cube([20,5,default_arm_thickness+extra]);
  }

  module bearing_for_standing_housing(){
    translate([0,0,hole])
      rotate([90,0,0])
      translate([0,0,-Bearing_623_width/2])
      Bearing_623_vgroove($fn=40);
  }

  module print(){
    translate([0,-1,0])
    rotate([90,0,0])
    difference(){
      standing_housing();
      differencer(0.2);
    }
    translate([0,1,0])
    rotate([-90,0,0])
    intersection(){
      standing_housing();
      differencer(-0.2);
    }
  }
  //color("purple") bearing_for_standing_housing();
  //%standing_housing();
  print();
}
//bearing_housing();
