include <measured_numbers.scad>
include <design_numbers.scad>
include <extruder_drive.scad>
include <Nema17_and_Ramps_and_bearings.scad>
include <Gears.scad>

// TODO:
//  - Place gatts reliably with screw holes or similar
//  - Place hot end reliably
//  - Protect lines from motor gears with disks
// Style:
//  - Spaces separate arguments and long words only
//  - Global parameters starts with capital letter, others don't


//////////// Utility numbers //////////////
Big   = 300;
Sqrt3 = sqrt(3);
pi    = 3.1415926535897932384626433832795;
render_sandwich = false;
//render_sandwich = true;
render_xy_motors = false;
//render_xy_motors = true;
//render_extruder = false;
render_extruder = true;

//////////// Utility modules //////////////
module filament(){
  color("white") translate([0,0,-50]) cylinder(r=1.75/2, h = Big);
}

module eq_tri(s, h){
  linear_extrude(height=h, slices=1)
    polygon(points = [[s/2,-s/(2*Sqrt3)],[0,s/Sqrt3],[-s/2,-s/(2*Sqrt3)]],
    paths=[[0,1,2]]);
}
//eq_tri(10,10);

// For making nutlocks
module point_cube(v, ang){
  translate([v[0]/2,0,0])
  difference(){
    translate([-v[0]/2,0,0])
      cube(v);
    rotate([0,-ang/2,0])
      translate([-2*v[0],1.5-v[1],-v[2]])
        cube([2*v[0],2*v[1],3*v[2]]);
    mirror([1,0,0])
      rotate([0,-ang/2,0])
        translate([-2*v[0],1.5-v[1],-v[2]])
          cube([2*v[0],2*v[1],3*v[2]]);
  }
}
//point_cube([10,11,12],120);

module Flerpar_screw_holes(d, h){
  cw = Nema17_cube_width;
  ch = Nema17_cube_height;
  translate([cw/2-11, 0, -3])
    rotate([90, 0, 0])
      cylinder(r=d/2, h=h);
  translate([-cw/2+11, 0, -3])
    rotate([90, 0, 0])
      cylinder(r=d/2, h=h);
  translate([cw/2-11, 0, ch+3])
    rotate([90, 0, 0])
      cylinder(r=d/2, h=h);
  translate([-cw/2+11, 0, ch+3])
    rotate([90, 0, 0])
      cylinder(r=d/2, h=h);
}

//////////// Design specific modules //////////////
module snelle(r1, r2, h){
  cylinder(r1=r1, r2=r2, h=0.8);
  cylinder(r=r2, h=h);
}
//snelle(r1 = 10, r2 = 5, h = 3);

// Sandwich height follows exactly 608 bearing thickness
module sandwich(teeth = Sandwich_gear_teeth){
  od              = Bearing_608_outer_diameter;
  bw              = Bearing_608_width;
  meltlength      = 0.1;
  sandwich_height = Bearing_608_width + Lock_height;
	gear_height     = sandwich_height*4/7;
  cylinder_height = sandwich_height*3/7;

  difference(){
    union(){
      // my_gear defined in Gear.scad
      translate([0, 0, cylinder_height - meltlength])
        my_gear(teeth, gear_height);
      // Snelle
      //color("green")
      snelle(r1 = Snelle_radius + 0.8, r2 = Snelle_radius, h = cylinder_height, $fn = 150);
    }
    // Dig out the right holes
    translate([0, 0, -1.2])
      cylinder(r = od/2, h = gear_height + cylinder_height);
    cylinder(r = od/2-2, h = Big);
    translate([0, 0, -8.7])
      cylinder(r = 20, h = 10);
  }
  Bearing_608();
}
//sandwich();

// 17.79 will be the protruding shaftlength up from bottom plate
// Making the motor gear a little shorter might let us use same on all
// TODO: put gears within disks that protects lines.
module motor_gear(height = Motor_gear_height){
  swh  = Bearing_608_width + Lock_height;
  r_swh = swh - 1; // reduced sandwich height
  e_swh = swh + 1; // extended sandwich height
  melt = 0.1;
  teeth = Motor_gear_teeth;
  difference(){
    union(){
      translate([0,0,height - e_swh - melt]) my_gear(teeth, r_swh + melt);
      cylinder(r = 10, h = height - e_swh); 
    }
    translate([0, 0, -1])
      cylinder(r = 5/2, h = height + 2);
  }
}
//motor_gear();

// Visualization only
module gear_friends(){
  translate([Four_point_five_point_radius,0,-8]) motor_gear();
  sandwich();
}
//gear_friends();

//Nema17();
//translate([0, 0, 46]) motor_gear();

module lock(r, height){
  cylinder(r=r, h=height);
}

module extruder_screw_holes(rotation=Extruder_motor_twist){
  ry = Hobbed_insert_height+5;
  rx = Bearing_623_outer_diameter-3.5;
  z_down = 6;
  rotate([0,0,rotation])
    // Adjust manually to get right, should be close to zero
  translate([-1.7,-1,0]) 
  for(v=[[rx,ry,-z_down],[rx,-ry,-z_down],[-rx,ry,-z_down],[-rx,-ry,-z_down]])
    translate(v)
      M3_screw(z_down + Bottom_plate_thickness + 4, updown=true);
}
//extruder_screw_holes();

module bottom_plate(){
  /////// Global variables renamed short //////
  cw  = Nema17_cube_width;
  th  = Bottom_plate_thickness; 
  bpr = Bottom_plate_radius;
  bd  = Bearing_608_bore_diameter; 
  bw  = Bearing_608_width;
  swh = Bearing_608_width + Lock_height;
  lh  = Lock_height;
  /////// Local variables                //////
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
    translate([0,0,Big/2])
      extruder_motor_translate(Extruder_motor_twist)
        translate([0,0,-Nema17_cube_height - 2])
          Flerpar_screw_holes(M3_diameter, Big);
    // Screw holes for XY Nema
    translate([0, 0, -1])
      four_point_translate()
        translate([0,0,-Big/2]) Nema17_screw_holes(M3_diameter, Big);

    // Middle hole for Nema
    translate([0, 0, -1])
      four_point_translate()
        cylinder(r = 8, h = Big);
    
    extruder_screw_holes(); // For support around middle
  }
}
//bottom_plate();

module line(length=70, angle_1=0, angle_2=0){
  snellekant = 0.8;
  radius = 0.8;
  dia = Bearing_623_vgroove_small_diameter;
  color("green"){
    translate([radius + Snelle_radius,0,0])
      rotate([90,0,0])
        cylinder(r=radius, h=length);
    translate([radius + Snelle_radius,
               -length+(dia/2)*(cos(angle_1)-1)*(1-sin(angle_2)),
               0])
    rotate([angle_1,angle_2,0])
      translate([0,-dia/2,0])
        rotate([90,0,0])
          cylinder(r=radius, h=Big);
    }
}
//line(angle_1=-45, angle_2=-60);

module lines(){
  th  = Bottom_plate_thickness; 
  gap = 0.2;
  lh  = Lock_height;
  bw  = Bearing_608_width;
  bt  = 1.9; // line radius, edge of snelle and some space
  i = 0;
  for(i=[0,120,240])
    rotate([0,0,i]){
      translate([0,0, bt+th+lh/4+gap/2 + (1 + i/120)*(gap + lh + bw)]){
        rotate([0, 0, Splitrot_1]) line(87,45,30);
        rotate([0, 0, Splitrot_2]) line(84,59,-46);
      }
      translate([0, 0, bt+th+lh/4+gap/2])
        rotate([0, 0, Middlerot])
          line(105,-90,0);
    }
}
//lines();

module z_gatt_translate(back = 0){
  for(i=[0,120,240])
    rotate([0,0,i])
      translate([0,Full_tri_side/Sqrt3 - back,0])
        child(0);
}

module xy_gatt_translate_1(back = 0, sidestep = 3){
  translate([sidestep,Full_tri_side/Sqrt3 - back,0])
    child(0);
}

module xy_gatt_translate_2(back = 0, sidestep = 3){
  rotate([0,0,-120])
  translate([-sidestep,Full_tri_side/Sqrt3 - back,0])
    child(0);
}

module bottom_plate_and_sandwich(){
  th  = Bottom_plate_thickness; 
  gap = 0.2;
  lh  = Lock_height;
  bw  = Bearing_608_width;

  bottom_plate();
  // Place sandwich slices
  if(render_sandwich){
    translate([0,0, th + lh/4 + gap/2]) sandwich();
    translate([0,0, th + lh/4 + gap/2 + gap + lh + bw]) sandwich();
    translate([0,0, th + lh/4 + gap/2 + 2*(gap + lh + bw)]) sandwich();
    translate([0,0, th + lh/4 + gap/2 + 3*(gap + lh + bw)]) sandwich();
    lines();
  }
}
//bottom_plate_and_sandwich();

// Assumes child(0) is centered in xy-plane

// A little odd that reference translation is along y...
// Used for XY and Z motors
module four_point_translate(){
  radius = Four_point_five_point_radius;
  for(i=[72:72:359]){
    rotate([0,0,i]) translate([0,radius,0]) child(0);
  }
}

module extruder_motor_translate(extruder_twist = 12){
  radius = Four_point_five_point_radius;
  translate([0, radius, -Nema17_cube_width/2 - 1])
    rotate([0, 0, extruder_twist])
      translate([0, -Nema17_cube_height, 0])
        rotate([90,0,0])
          translate([0, 0, -Nema17_cube_height/2]) child(0);
}

module flerpar(){
  melt = 1.2;
  flerp_th = 6;
  flerp_h = 10;
  difference(){
    translate([-Nema17_cube_width/2,
                Nema17_cube_width/2-flerp_h,
                Nema17_cube_height]){
      // Uppflärp
      cube([Nema17_cube_width, flerp_h + melt, flerp_th]);
      translate([0,0,-flerp_th-Nema17_cube_height])
      // Nerflärp
        cube([Nema17_cube_width, flerp_h + melt, flerp_th]);
    }
    translate([0,0,-Big/2]) Nema17_screw_holes(M3_diameter, Big);
  }
}
//flerpar()

// Skriv ut flerpar før sig...
module flerpad_Nema17(){
  flerpar();
  Nema17();
}
//flerpad_Nema17();


module bottom_plate_and_sandwich_and_nema17(){
  melt = 0.2;
  flerp_th = 3;
  flerp_h = 10;
  bottom_plate_and_sandwich();
  if(render_xy_motors){
    four_point_translate()
      translate([0,0,-Nema17_cube_height - 2])
        Nema17();
    rotate([0,0,72])
      translate([0,Four_point_five_point_radius, 6+Motor_gear_height])
        mirror([0,0,1])
          motor_gear();
    rotate([0,0,4*72])
    translate([0,Four_point_five_point_radius, 27]) motor_gear();
    rotate([0,0,3*72])
    translate([0,Four_point_five_point_radius, 17]) motor_gear();
    rotate([0,0,2*72])
    translate([0,Four_point_five_point_radius, 9]) motor_gear();
  }
  filament();
}
//bottom_plate_and_sandwich_and_nema17();

module hobbed_insert(){
  color("grey")
    cylinder(r=Hobbed_insert_diameter/2, h=Hobbed_insert_height);
}
//hobbed_insert()

module translated_insert_tower(){
  bearing_base_translation = 8.3;
  hobbed_insert_placement = bearing_base_translation +
                            Bearing_623_width + 0.2;
    translate([0,-Pitch_difference_extruder,1.5]){
      translate([0,0,bearing_base_translation])
        Bearing_623();
      translate([0,0,2])
        M3_screw(25, $fn=6);
      translate([0,0,hobbed_insert_placement])
        hobbed_insert();
      translate([0,0, hobbed_insert_placement + Hobbed_insert_height
                      + 0.2])
        Bearing_623();
  }
}

module support_bearing_translate(rotation){
  translate([(Hobbed_insert_diameter + 
              Bearing_623_outer_diameter)/2 + 1.5
              + sin(rotation)*Pitch_difference_extruder,
              - cos(rotation)*Pitch_difference_extruder,15]) child(0);
}

module support_bearing(rotation){
  support_bearing_translate(rotation)
    Bearing_623();
}

module drive(rotation=0){
  // Height adapted so support always get high enough
  // no matter the rotation
  height = Nema17_cube_width/2 +
           Pitch_difference_extruder*cos(rotation)
           + 7
           + 1;

  rotate([0,0,rotation]){
    small_gear();
    translate([0,-Pitch_difference_extruder,1.5])
      large_gear(); // default large_gear height is Large_gear_height
    translated_insert_tower();
  } // end rotate

  difference(){
    translate([-(Bearing_623_outer_diameter + 6)/2
                 + sin(rotation)*Pitch_difference_extruder,
               -cos(rotation)*Pitch_difference_extruder - 10,
               Large_gear_height + 1.5 + 0.7]){
      // Bearing support
        union(){
        for(k = [0,Hobbed_insert_height + 1.1*Bearing_623_width])
          translate([0,0, k])
            cube([Bearing_623_outer_diameter + 14,
                  height,
                  Bearing_623_width]);
        // Flerps to screw onto bottom_plate. Make screw holes there
        //color("green")
        for(k = [-Hobbed_insert_height - 1*Bearing_623_width,
                  Hobbed_insert_height + 1.1*Bearing_623_width])
          translate([0,height,k])
            cube([Bearing_623_outer_diameter + 14,
                  3,
                  Hobbed_insert_height + 2*Bearing_623_width]);
        }
      }
    // Space for tower in bearing supports
    rotate([0,0,rotation])
      translated_insert_tower();
    // Hole through support bearing (antimateria)
    translate([0,0,-5.5])
    support_bearing_translate(rotation)
      M3_screw(Big);
  }
  support_bearing(rotation);
  // M3 through support bearing (materia)
  translate([0,0,-5.5])
  support_bearing_translate(rotation)
    M3_screw(19);
}
//drive(rotation=336);

module flerpad_Nema17_with_drive(rotation=0){
  flerpar();
  Nema17();
  translate([0,0,Nema17_shaft_height - 6])
    drive(rotation);
}
//flerpad_Nema17_with_drive();

module translated_extruder_motor_and_drive(extruder_motor_twist = 12,
                                            large_gear_rotation = 0){
  difference(){
    extruder_motor_translate(extruder_motor_twist)
      translate([0,0,-Nema17_cube_height - 2])
        flerpad_Nema17_with_drive(large_gear_rotation);
    // Screw holes for extruder motor
    translate([0,0,Big/2])
      extruder_motor_translate(Extruder_motor_twist)
        translate([0,0,-Nema17_cube_height - 2])
          Flerpar_screw_holes(M3_diameter, Big);

    extruder_screw_holes();
  }
}
//translated_extruder_motor_and_drive(44, -26);

module bottom_plate_and_sandwich_and_nema17_and_extruder(){
  bottom_plate_and_sandwich_and_nema17();
  translated_extruder_motor_and_drive(
    extruder_motor_twist = Extruder_motor_twist,
    large_gear_rotation  = Large_gear_rotation);
}
//bottom_plate_and_sandwich_and_nema17_and_extruder();

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

// height is the height of the line
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
//gatt(13, 45);


// These are adjusted by visually comparing to lines().
// All hard coded numbers should be parameterized
module gatts(){
  th  = Bottom_plate_thickness; 
  gap = 0.2;
  lh  = Lock_height;
  bw  = Bearing_608_width;
  z_back = Z_gatt_back;
  z_rotate = 19;
  z_height = th+lh/4+gap/2+2;
  xy_height_1 = z_height + gap+lh+bw;
  xy_height_2 = xy_height_1 + gap+lh+bw;
  xy_height_3 = xy_height_2 + gap+lh+bw;
  // xy_back and xy_sidestep is adjusted manually to fit
  // Splitrot_1 and Splitrot_2
  xy_back = 31;
  xy_sidestep = 25;
  gatt_1_rotate = -90+Splitrot_1;
  gatt_2_rotate = -90+Splitrot_2 + 120;

  // Z-gatts
  z_gatt_translate(z_back)
    rotate([0,0,-90+Middlerot+120])
      gatt(z_height, 180);
  // Lowest xy-gatts
  xy_gatt_translate_1(xy_back, xy_sidestep)
    rotate([0,0,gatt_1_rotate]) gatt(xy_height_1,-30);
  xy_gatt_translate_2(xy_back, xy_sidestep)
    rotate([0,0,gatt_2_rotate]) gatt(xy_height_1,46);
  // Middle xy-gatts
  rotate([0,0,120]){
    xy_gatt_translate_1(xy_back, xy_sidestep)
      rotate([0,0,gatt_1_rotate]) gatt(xy_height_2,-30);
    xy_gatt_translate_2(xy_back, xy_sidestep)
      rotate([0,0,gatt_2_rotate]) gatt(xy_height_2,46);
  }
  // Highest gatts 
  rotate([0,0,240]){
    xy_gatt_translate_1(xy_back, xy_sidestep)
      rotate([0,0,gatt_1_rotate]) gatt(xy_height_3,-30);
    xy_gatt_translate_2(xy_back, xy_sidestep)
      rotate([0,0,gatt_2_rotate]) gatt(xy_height_3,46);
  }
}
//gatts();

module bottom_plate_and_sandwich_and_nema17_and_extruder_and_gatts(){
  bottom_plate_and_sandwich_and_nema17();
  if(render_extruder){
  translated_extruder_motor_and_drive(
    extruder_motor_twist = Extruder_motor_twist,
    large_gear_rotation  = Large_gear_rotation);
  }
  gatts();
}
//bottom_plate_and_sandwich_and_nema17_and_extruder_and_gatts();

module cooler_rib(){
  th = 1.8;
  cube([2,40,40]);
  for(i=[0:(40-th)/6:40-th]){
    translate([0,0,i])
      cube([12,40,th]);
  }
}
//cooler_rib();

module fan(){
  difference(){
    cube([40,40,11]);
    translate([20,20,-1])
      cylinder(r=18,h=Big);
  }
}
//fan();

module reprappro_hotend(){
  // Pen
  color("FireBrick"){
  cylinder(r1=0.7, r2=2.7, h=2);
  translate([0,0,2])
    cylinder(r=2.7, h = 30);
  }
  // Heater block
  color("red")
  translate([-8, -13, 4])
    cube([17, 21, 7.5]);
  // Cooler block
  color("RoyalBlue")
  translate([-20, -4, 21])
    cube([40, 8, 8]);
  color("lightblue")
  // Cooler rib
  rotate([0,0,-90]) translate([4,-40/2,21]) cooler_rib();
  color("black")
  // Fan
  translate([-20,-16,21]) rotate([90,0,0]) fan();
}
//reprappro_hotend();

module placed_hotend(){
  translate([0,0,-81])
    rotate([0,0,Extruder_motor_twist])
      reprappro_hotend();
}

module placed_ramps(){
  rotate([0,0,2*90+Extruder_motor_twist])
  translate([-60,-18,-Nema17_cube_height - Ramps_width - 2])
    rotate([90,0,0])
      %Ramps();
}

module full_render(){
  bottom_plate_and_sandwich_and_nema17_and_extruder_and_gatts();
  lines();
  placed_hotend();
  placed_ramps();
}
full_render();

module hook(){
  
}

module top_plate(){
  th = Top_plate_thickness;
  // Base plate
  eq_tri(Full_tri_side, th);
  // Place hooks precisely where gatts lets lines out (in xy-plane)
  // That is gatts entry points + radius
  //gatts();
  // This movement is synced with movement in module gatts
  z_gatt_translate(Z_gatt_back)
    rotate([0,0,-90+Middlerot+120])
      translate([Bearing_623_vgroove_small_diameter/2,0,0])
        // We want out hooks to be exactly here
        cylinder(r=0.8,h=40);
}
//top_plate();
