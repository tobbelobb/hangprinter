include <measured_numbers.scad>
include <design_numbers.scad>
include <extruder_drive.scad>
include <Nema17_and_Ramps_and_bearings.scad>
include <Gears.scad>

// TODO:
//  - Finis fairleads
//  - Give fairleads bottom plate holes
//  - Place Ramps/Due
//  - Change 607 to 608 everywhere
//  - Place hot end
//  - All holes should be made in bottom_plate module?
// Style:
//  - Spaces separate arguments and long words only
//  - Global parameters starts with capital letter, others don't


//////////// Utility numbers //////////////
Big   = 300;
Sqrt3 = sqrt(3);
pi    = 3.1415926535897932384626433832795;
//render_sandwich = false;
render_sandwich = true;
//render_xy_motors = false;
render_xy_motors = true;

//////////// Utility modules //////////////
module filament(){
  color("white") cylinder(r=1.75/2, h = Big, center=true);
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

// Sandwich height follows exactly 607 bearing thickness
module sandwich(teeth = Sandwich_gear_teeth){
  od              = Bearing_607_outer_diameter;
  bw              = Bearing_607_width;
  meltlength      = 0.1;
	gear_height     = Sandwich_height*4/7;
  cylinder_height = Sandwich_height*3/7;

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
}
//sandwich();

// 17.79 will be the protruding shaftlength up from bottom plate
// Making the motor gear a little shorter might let us use same on all
module motor_gear(height = Motor_gear_height){
  swh  = Sandwich_height;
  melt = 0.1;
  teeth = Motor_gear_teeth;
  difference(){
    union(){
      translate([0,0,height - swh - melt]) my_gear(teeth, swh + melt);
      cylinder(r = 10, h = height - swh); 
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
  bd  = Bearing_607_bore_diameter; 
  bw  = Bearing_607_width;
  swh = Sandwich_height;
  lh  = Lock_height;
  /////// Local variables                //////
  lock_radius = bd/2 + 0.35;
  full_tri_side = 200*1.035; //Rotate eq_tri compared to heatbed, gain length
  gap = 0.2;

  difference(){
    union(){
      // Largest possible triangular plate
      eq_tri(full_tri_side, th);
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

module line(){
  snellekant = 0.8;
  radius = 0.8;
  color("green")
    translate([radius + Snelle_radius,0,radius + snellekant + 0.3])
      rotate([90,0,0])
        cylinder(r=radius, h = 250);
}
//line();

module lines(){
  th  = Bottom_plate_thickness; 
  gap = 0.2;
  lh  = Lock_height;
  bw  = Bearing_607_width;
  i = 0;
  middlerot = 35;
  splitrot = 14;
  for(i=[0,120,240])
    rotate([0,0,i]){
      translate([0,0, th+lh/4+gap/2 + (1 + i/120)*(gap + lh + bw)]){
        rotate([0, 0, middlerot - splitrot]) line();
        rotate([0, 0, middlerot + splitrot]) line();
      }
      translate([0, 0, th+lh/4+gap/2])
        rotate([0, 0, middlerot])
          line();
    }
}
//lines();

module bottom_plate_and_sandwich(){
  th  = Bottom_plate_thickness; 
  gap = 0.2;
  lh  = Lock_height;
  bw  = Bearing_607_width;

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
    translate([0,Four_point_five_point_radius, 21]) motor_gear();
    rotate([0,0,2*72])
    translate([0,Four_point_five_point_radius, 13]) motor_gear();
    rotate([0,0,3*72])
    translate([0,Four_point_five_point_radius, 7]) motor_gear();
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

module fairlead_XY(h=10, roller_width=25){
  bd = Bearing_623_outer_diameter;
  rd = Bearing_623_outer_diameter + 1; // roller diameter
  bw = Bearing_623_width;
  translate([0,0,h]) Bearing_623();
  difference(){
    cylinder(r=bd/2-1.3, h=h);
    translate([0,0,-1])
      cylinder(r=M3_diameter/2, h=Big);
  }
  // Large roller
  color("purple")
  translate([rd/2 + bd/2 - 1, roller_width/2 - bd/2, h - rd/2 + bw/2])
    rotate([90,0,0])
      cylinder(h=roller_width, r=rd/2);
  // Top lock
  translate([-2,-12,0])
    cube([4,3,h + Bearing_623_width + 1]);
  translate([-2,-12,h + Bearing_623_width])
    cube([4,15,3]);
}
//fairlead_XY();

module fairlead_XY_pair(h=10,sep=60,dist=49){
  translate([0,0,Bottom_plate_thickness])
  rotate([0,0,30]){
    translate([dist,-sep,0])
    fairlead_XY(h);
    translate([dist,sep,0])
    mirror([0,1,0])
      fairlead_XY(h);
  }
}
//fairlead_XY_pair();

module fairlead_Z(roller_width=25){
  lift = 1; // Z-fearleads pulls most wheight, so downmost sandwich
  bd = Bearing_623_outer_diameter;
  rd = Bearing_623_outer_diameter + 1;
  bw = Bearing_623_width;
  translate([bd/2+0.2,0,1+lift]) Bearing_623();
  translate([-(bd/2+0.2),0,1+lift]) Bearing_623();
  color("purple")
  rotate([0,90,0])
    translate([-rd/2-bw/2 - lift,10,-roller_width/2]) 
      cylinder(h=roller_width, r=rd/2);
}
//fairlead_Z();

module bottom_plate_and_sandwich_and_nema17_and_extruder_and_rollers(){
  bottom_plate_and_sandwich_and_nema17();
  translated_extruder_motor_and_drive(
    extruder_motor_twist = Extruder_motor_twist,
    large_gear_rotation  = Large_gear_rotation);
  for(i=[0,120,240])
    rotate([0,0,i]){
      fairlead_XY_pair(3+ (Bearing_607_width + 1)*(1 + (i/120)));
      translate([0,100,4])
        fairlead_Z();
  }
}
//bottom_plate_and_sandwich_and_nema17_and_extruder_and_rollers();

module Bearing_623_vgroove(){
  bd = Bearing_623_vgroove_big_diameter;   // Big diameter
  sd = Bearing_623_vgroove_small_diameter; // Small diameter
  h1 = Bearing_623_width;                  // Totoal height
  h2 = Bearing_623_vgroove_width;
  h_edge = (h1-h2)/2;
  difference(){
    for(k = [0,1]){
      translate([0,0,h1*k]){
        mirror([0,0,k]){
          // Edge
          cylinder(r=bd/2, h=h_edge);
          // Half the groove
          translate([0,0,h_edge])
            cylinder(r1=bd/2, r2=sd/2, h=h2/2);
        }
      }
    }
    // Bore
    translate([0,0,-1])
      cylinder(r=Bearing_623_bore_diameter/2, h=Big);
  }
}
//color("purple")
//Bearing_623_vgroove();

// height is the height of the line
module gatt(height=25){
  bd = Bearing_623_vgroove_big_diameter;   // Big diameter
  sd = Bearing_623_vgroove_small_diameter; // Small diameter
  h1 = Bearing_623_width;                  // Totoal height
  h2 = Bearing_623_vgroove_width;

  // Support
  difference(){
    translate([-h1 - bd/2 -0.5, -bd/2, 0])
      cube([h1, bd, height + bd]);
    // Hole for arm-cylinder
    translate([0,0,height])
      rotate([0,-90,0])
        cylinder(r=Bearing_623_bore_diameter/2, h=30);
  }
  translate([-h1-0.5,0,height])
    rotate([0,-90,0])
      cylinder(r=Bearing_623_bore_diameter/2, h=h1+3);
  // Arm TODO: This cube
  translate([0,0,0]) cube([h1, 3, sd]);


  // The bearings
  rotate([90,0,0])
    translate([0,height - sd/2,-h1/2])
      color("purple")
        Bearing_623_vgroove();
  translate([-bd/2,0,height])
    rotate([0,-90,0])
      Bearing_623();

}
gatt();

