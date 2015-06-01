include <util.scad>
include <measured_numbers.scad>
include <design_numbers.scad>
include <Nema17_and_Ramps_and_bearings.scad>
include <Gears.scad>

//** bottom_plate start **//

// Assumes children(0) is centered in xy-plane
// A little odd that reference translation is along y...
// Used for XY and Z motors
// Needed here to get screw holes right
module four_point_translate(){
  radius = Four_point_five_point_radius;
  for(i=[72:72:359]){
    rotate([0,0,i]) translate([0,radius,0]) children(0);
  }
}

// Needed here to get screw holes right
module extruder_motor_translate(extruder_twist = 12){
  radius = Four_point_five_point_radius;
  translate([0, radius, -Nema17_cube_width/2 - 1])
    rotate([0, 0, extruder_twist])
      translate([0, -Nema17_cube_height, 0])
        rotate([90,0,0])
          translate([0, 0, -Nema17_cube_height/2]) children(0);
}


// The thing separating bearings on center axis of bottom plate
module lock(r, height){
  cylinder(r=r, h=height);
}

// TODO: make hole for extruder motor
module bottom_plate(){
  // Global variables renamed short
  cw  = Nema17_cube_width;
  th  = Bottom_plate_thickness; 
  bpr = Bottom_plate_radius;
  bd  = Bearing_608_bore_diameter; 
  bw  = Bearing_608_width;
  swh = Bearing_608_width + Lock_height;
  lh  = Lock_height;
  // Local variables
  lock_radius = bd/2 + 0.35;
  gap = 0.2;

  difference(){
    union(){
      // Largest possible triangular plate
      eq_tri(Full_tri_side, th);
      // Flexible sandwich stick
      difference(){
        union(){
          // Sandwich stick base
          cylinder(r = bd/2, h = 4*swh + lh/4 + th + 4*gap);
          // The four locks
          translate([0, 0, th])
            lock(lock_radius, lh/4);
          translate([0, 0, th + lh/4 + bw + gap])
            lock(lock_radius, lh);
          translate([0, 0, th + lh/4 + bw + gap + lh + bw + gap])
            lock(lock_radius, lh);
          translate([0, 0, th + lh/4 + bw + gap + 2*(lh + bw + gap)])
            lock(lock_radius, lh);
          translate([0, 0, th + lh/4 + bw + gap + 3*(lh + bw + gap)])
            lock(lock_radius, lh);
        }
        cube([1.3, Big, Big], center = true);
        rotate([0, 0, 90])
          cube([1.3, Big, Big], center = true);
      }
      // Circular bottom plate
      cylinder(r=bpr, h = th);
    }
    // Dig out filament hole in sandwich stick and base.
    // When physical build is done, fill this hole for stiffness
    translate([0, 0, -1]) cylinder(r = 2.4, h = Big);
    // Screw holes for extruder motor
    // ...
    // Screw holes for XY Nema
    // TODO: Make Nemas turnable
    translate([0, 0, -1])
      four_point_translate()
        translate([0,0,-Big/2]) Nema17_screw_holes(M3_diameter, Big);

    // Middle hole for Nema
    translate([0, 0, -1])
      four_point_translate()
        cylinder(r = 8, h = Big);
    
    // Place holes exaclty like punched_cube is placed when rendering
    // From placed_extruder
    rotation = Big_extruder_gear_rotation;
    extruder_motor_twist = Extruder_motor_twist;
    // From translated_extruder_motor_and_drive
    extruder_motor_translate(extruder_motor_twist)
      translate([0,0,-Nema17_cube_height - 2]){
        // From Nema17_with_drive
        translate([0,0,Nema17_shaft_height - 6]){
          // drive_support is called by assembled_drive only
          //from assembled_drive
          translate([-(Bearing_623_outer_diameter + 6)/2
              + sin(rotation)*Pitch_difference_extruder,
              - cos(rotation)*Pitch_difference_extruder - 10,
              Big_extruder_gear_height + 1.5 + 0.7]){
            for(k = [0,Hobbed_insert_height + 1.1*Bearing_623_width + 
                Drive_support_thickness])
              translate([0,0, k])
                mirror([0,0,k])
                // Found in drive_support()
                translate([0,
                    Drive_support_height,
                    -Hobbed_insert_height - 1*Bearing_623_width])
                Drive_support_holes(Drive_support_v);
          }
        }
      }
  }
}
//bottom_plate();

//** bottom_plate end **//

// Sandwich is defined in Gears.scad
// Motors are defined in Nema17_and_Ramps_and_bearings.scad

//** gatt start **//

module arm(r, xsz, ysz, th, xdiff, ydiff){
  difference(){
    hull(){
      translate([-xsz - xdiff, ydiff, 0])
        cube([xsz,ysz,th]);
      cylinder(r=r, h=th);
    }
    translate([0,0,-1]) cylinder(r=M3_diameter/2, h=Big);
  }
}
//arm(3, 4, 1.8, 2, 2);

// height is the height of the snelle
module gatt(height=25, arm_rotation=0){
  bd = Bearing_623_vgroove_big_diameter;   // Big diameter
  sd = Bearing_623_vgroove_small_diameter; // Small diameter
  h1 = Bearing_623_width;
  h2 = Bearing_623_vgroove_width;

  bod = Bearing_608_outer_diameter;   // Big outer diameter
  bid = Bearing_608_bore_diameter;    // Big inner diemater
  h12 = Bearing_608_width + 2;        // Thikness of support

  // Support walls
  difference(){
    translate([-h12/2 - bd/2 - 1, -(bod+4)/2, 0]){
      translate([0.2,0,0])
      cube([h12/2-0.2, bod+4, height + (bod+4)/2]);
      translate([-h12/2, 0, 0])
        cube([h12/2-0.2, bod+4, height + (bod+4)/2]);
    }
    // Hole for arm-cylinder
    translate([0,0,height])
      rotate([0,-90,0])
        cylinder(r=bid/2+2.2, h=30);
    // Hole for 608 bearing itself
    translate([-bd/2 - 2,0,height])
      rotate([0,-90,0])
        cylinder(r=bod/2, h=h12-2);

    // Screw holes in support walls
    for(k=[0,1]){
      mirror([0,k,0]){
        translate([0,bod/2-2,4])
          rotate([0,-90,0])
            cylinder(r=M3_diameter/2, h=Big);
        translate([0,bod/2-2,height + (bod+4)/2 - 4])
          rotate([0,-90,0])
            cylinder(r=M3_diameter/2, h=Big);
      }
    }
  }
  // Arm
  difference(){
    union(){
      // Cylinder through 608 center
      translate([-bd/2,0,height])
        rotate([0,-90,0])
          cylinder(r=Bearing_608_bore_diameter/2, h=h12+2);
      translate([0,0,height])
        rotate([arm_rotation,0,0])
          translate([0,0,-height]){
            // Plate, tightly pushed to 608 bore
            translate([-2 - bd/2, -(h1+4)/2, height - (h1+4)/2])
              cube([2,h1+4,h1+4]);
            // Actual arms connecting 608 and 623
            for(k=[0,1]){
              mirror([0,k,0]){
                translate([0,-(h1/2) - 0.2,height - sd/2])
                  rotate([90,0,0])
                    arm(3,h1-1,h1+4,1.8,(bd/2+0.01)-(h1-1),1.2);
              }
            }
          }
    }
    // Hole for line
    translate([0,0,height])
      rotate([0,-90,0])
        cylinder(r=0.7, h=30);
  }
  // The bearings
  translate([0,0,height])
    rotate([arm_rotation,0,0])
      translate([0,0,-height])
        rotate([90,0,0])
          translate([0,height - sd/2,-h1/2])
            color("purple")
              Bearing_623_vgroove();
  translate([-bd/2 - 1.5,0,height])
    rotate([0,-90,0])
      Bearing_608();

}
//gatt(17, 26);

//** gatt end **//


//** extruder start **//

module Drive_support_holes(v=Drive_support_v){
    rotate([-90,0,0]){
      for(k=[1,-1])
        translate([k*Support_rx+v[0]/2,
            -v[2]/2 + Drive_support_thickness/2,
            -Big/2])
          M3_screw(h=Big);
    }
}

module punched_cube(v){
  difference(){
    cube(v);
    Drive_support_holes(v);
  }
}
//punched_cube(Drive_support_v);

// height of the tower depends on big extruder gear rotation
module drive_support(flag){
  Hobb_from_edge=12;
  th = Bearing_623_width+0.5;
  difference(){
    cube([Bearing_623_outer_diameter + 14,
        Drive_support_height,
        th]);
    // Hole for bearings supporting hobbed insert screw
    translate([Bearing_623_outer_diameter-1.5,Hobb_from_edge,-Big/2])
      M3_screw(Big);
    translate([Bearing_623_outer_diameter-1.5,Hobb_from_edge,-1.5])
      Bearing_623();
    // Hole for support bearing M3
    translate([Hobbed_insert_diameter+Bearing_623_outer_diameter,
        Hobb_from_edge,-1])
      M3_screw(Big);
    // Tightening mechanism
    translate([1.7 + (Bearing_623_outer_diameter + 14)/2,
        -Big + 30, // Depth of skåra
        -1])
      cube([2,Big,th+2]);
    translate([17.6,0,-1])
    rotate([0,0,15+90]) 
      special_tri(13,13);
    if(flag == 0){
      translate([-10,3,th/2])
      rotate([0,90,0])
      M3_screw(h=Big);
    }
  }
  if(flag != 0){
    difference(){
      translate([-3 + 1.7 + (Bearing_623_outer_diameter + 14)/2,
          0,
          -7]){
        cube([3,7,th+7]);
        translate([5,0,0])
          cube([2.7,7,th+7]);
      }
      translate([9.5,3.5,-3.2])
        rotate([0,90,0])
        M3_screw(h=Big);
    }
  }

  // Foot to screw on to bottom_plate
  difference(){
    translate([0,Drive_support_height,
                 -Drive_support_v[2]+th])
      punched_cube(Drive_support_v);
  }
}
//translate([-(Bearing_623_outer_diameter + 6)/2
// + sin(Big_extruder_gear_rotation)*Pitch_difference_extruder,
// -cos(Big_extruder_gear_rotation)*Pitch_difference_extruder - 10,
// Big_extruder_gear_height + 1.5 + 0.7])
drive_support(0);

//** Plates start **//

// An upside down hook that can be printed without support structure
module hook(height=10){
  line_radius = 0.75;
  big=30;
  difference(){
    // Main cube
    translate([-2,-1.5,0])
      cube([4,6.5,height]);
    // Hole
    translate([0,-line_radius/2,height])
      rotate([30,0,0])
        cylinder(r=line_radius, h=15.5, center=true);
    // Spår
    translate([0,5,height-2])
      rotate([-56,0,0])
        rotate_extrude(convexity=4)
          translate([2.70,0,0])
            circle(r=line_radius-0.2); 
    translate([0,4.57,4])
    // Bent end of channel
    difference(){
      rotate([0,90,0])
        rotate_extrude(convexity=4)
          translate([1.3,0,0])
            circle(r=line_radius); 
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
    translate([0,1,0]) cylinder(r=M3_diameter/2,h=Big,center=true);
  }
}

module top_plate(){
  th = Top_plate_thickness;
  flerp_side=18;
  // Base plate
  union(){
    difference(){
      eq_tri(Full_tri_side, th);
      translate([0,0,-1])
        eq_tri(Full_tri_side-15, th+2);
    }
    // Flerpar att skruva i
    for(i=[0,120,240])
      rotate([0,0,i])
        translate([0,Full_tri_side/Sqrt3-8-flerp_side/Sqrt3,0])
          top_flerp(flerp_side);

  }
  // Place hooks precisely where gatts lets lines out (in xy-plane)
  // That is gatts entry points + radius
  //gatts();
  // This movement is synced with movement in module gatts
  z_gatt_translate(Z_gatt_back)
    rotate([0,0,-90+Middlerot+120])
      translate([Bearing_623_vgroove_small_diameter/2,0,th-0.1]){
        // We want our hooks to be exactly here
        hook();
        //color("black") cylinder(r=0.5,h=20);
      }
}
//top_plate();


module XY_hook(height){
  //color("green")
  //cylinder(r=0.7,h=10);
  line_radius = 0.75;
  width = 3;
  difference(){
    translate([-width/2,0,0])   cube([width,5,height]);
    translate([-width/2-1,2,height-1.5]) cube([width+2,1.0*line_radius,height]);
    translate([0,5.2,height-1.4])
      rotate_extrude(convexity=4, $fn=40)
        translate([3,0,0])
          circle(r=line_radius,$fn=40); 
  }
}
//XY_hook(5);

module side_plate1(height=15){
  s = Full_tri_side;
  th = Bottom_plate_thickness;
  // Frame
  translate([-s/4,-s*Sqrt3/4,0])
  rotate([0,0,30])
  difference(){
    special_tri(s,height);
    translate([6,6,-1]) special_tri(s-34,height+2);
    translate([24,10,height/2])
      rotate([90,0,0])
        cylinder(r=M3_diameter/2, h=20);
    translate([s*Sqrt3/2-24,20,height/2])
      rotate([90,0,0]){
        cylinder(r=M3_diameter/2, h=30);
        translate([0,0,-8])
        cylinder(r=M3_head_diameter/2, h=19);
      }
  }
  // Where to put hooks?
  // Manually adjusted!
  translate([-67,0.2,0])
    XY_hook(height/2+1);
  translate([67,0.2,0])
    XY_hook(height/2+1);
}
//side_plate1();

module side_plate2(height=15,th=7){
  s = Full_tri_side-30;
  difference(){
    translate([-s/2,-th,0])
      cube([s,th,height]);
    for(k=[1,0])
      mirror([k,0,0])
        translate([75,-th-1,height/2])
          rotate([-90,0,0])
            cylinder(r=M3_diameter/2, h=Big);
  }
  translate([-67,0.2,0])
    XY_hook(height/2+1);
  translate([67,0.2,0])
    XY_hook(height/2+1);
}
//side_plate2();
