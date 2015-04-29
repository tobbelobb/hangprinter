// TODO:
//  - Place motor gears and see that sizes fit
//  - Place extruder motor
//  - Place gat ears
//  - Place Ramps

//////////// Measured numbers //////////////
Nema17_cube_width          = 42.43;
Nema17_cube_height         = 39.36;
Nema17_shaft_height        = 63.65;
Nema17_screw_hole_width    = 43.74;
Nema17_screw_hole_diameter = 5.92;
Nema17_screw_hole_depth    = 2.25;
M3_diameter                = 3;
M3_head_diameter           = 6.3;
M3_head_height             = 2.5;
Ramps_length               = 101.7;
Ramps_width                = 16.8;
Ramps_depth                = 60;
Bearing_607_width          = 6;
Bearing_607_bore_diameter  = 7;
Bearing_607_outer_diameter = 19;

//////////// Design decision numbers //////////////
Lock_height            = 2;
Bottom_plate_thickness = 4.5;
Sandwich_height        = Bearing_607_width + Lock_height;

//////////// Utility numbers //////////////
Big   = 300;
Sqrt3 = sqrt(3);
pi    = 3.1415926535897932384626433832795;

//////////// Utility Functions /////////////
function mirror_point(coord) = 
[
	coord[0], 
	-coord[1]
];

function rotate_point(rotate, coord) =
[
	cos(rotate)*coord[0] + sin(rotate)*coord[1],
	cos(rotate)*coord[1] - sin(rotate)*coord[0]
];

function involute(base_radius, involute_angle) = 
[
	base_radius*(cos(involute_angle) + involute_angle*pi/180*sin(involute_angle)),
	base_radius*(sin(involute_angle) - involute_angle*pi/180*cos(involute_angle)),
];

function rotated_involute(rotate, base_radius, involute_angle) = 
[
	cos(rotate)*involute(base_radius, involute_angle)[0] + sin(rotate)*involute(base_radius, involute_angle)[1],
	cos(rotate)*involute(base_radius, involute_angle)[1] - sin(rotate)*involute(base_radius, involute_angle)[0]
];

function involute_intersect_angle(base_radius, radius) = sqrt(pow(radius/base_radius, 2) - 1)*180/pi;


//////////// Utility modules //////////////
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

module Nema17_screw_translate(){
  for (i=[0:90:359]){
    rotate([0,0,i+45]) translate([Nema17_screw_hole_width/2,0,0]) child(0);
  }
}

module Nema17_screw_holes(d, h){
  Nema17_screw_translate() cylinder(r=d/2, h=h);
}
//Nema17_screw_holes(M3_diameter, 15);

module Nema17 (){
  cw = Nema17_cube_width;
  ch = Nema17_cube_height;
  sh = Nema17_shaft_height;
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
      translate([0,0,-5]) Nema17_screw_holes(M3_diameter, h=10);
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

module Ramps(){
  cube([Ramps_length, Ramps_width, Ramps_depth]);
}
//Ramps();

//////////// Gear modules /////////////
// Thanks to GregFrost for these: http://www.thingiverse.com/thing:3575
module involute_gear_tooth(pitch_radius,
	                         root_radius,
	                         base_radius,
	                         outer_radius,
	                         half_thick_angle,
	                         involute_facets){
	min_radius   = max(base_radius,root_radius);
	pitch_point  = involute(base_radius, involute_intersect_angle(base_radius, pitch_radius));
	pitch_angle  = atan2(pitch_point[1], pitch_point[0]);
	centre_angle = pitch_angle + half_thick_angle;
	start_angle = involute_intersect_angle(base_radius, min_radius);
	stop_angle = involute_intersect_angle(base_radius, outer_radius);
	res=(involute_facets!=0)?involute_facets:($fn==0)?5:$fn/4;
	union(){
		for(i=[1:res])
		assign(point1=involute(base_radius,start_angle+(stop_angle - start_angle)*(i-1)/res),
			     point2=involute(base_radius,start_angle+(stop_angle - start_angle)*i/res)){
			assign(side1_point1=rotate_point(centre_angle, point1),
				     side1_point2=rotate_point(centre_angle, point2),
				     side2_point1=mirror_point(rotate_point(centre_angle, point1)),
				     side2_point2=mirror_point(rotate_point(centre_angle, point2))){
				       polygon(points=[[0,0],side1_point1,side1_point2,side2_point2,side2_point1],
					             paths=[[0,1,2,3,4,0]]);
			}
		}
	}
}

module gear_shape(number_of_teeth,
	                pitch_radius,
	                root_radius,
	                base_radius,
	                outer_radius,
	                half_thick_angle,
	                involute_facets){
	union(){
		rotate(half_thick_angle) circle($fn=number_of_teeth*2, r=root_radius);
		for(i = [1:number_of_teeth]){
			rotate([0,0,i*360/number_of_teeth]){
				involute_gear_tooth(pitch_radius     = pitch_radius,
					                  root_radius      = root_radius,
					                  base_radius      = base_radius,
					                  outer_radius     = outer_radius,
					                  half_thick_angle = half_thick_angle,
					                  involute_facets  = involute_facets);
			}
		}
	}
}

module gear(number_of_teeth = 15,
	          circular_pitch  = false,
            diametral_pitch = false,
	          pressure_angle  = 28,
	          clearance       = 0.2,
	          gear_thickness  = 5,
	          rim_thickness   = 8,
	          rim_width       = 5,
	          hub_thickness   = 10,
	          hub_diameter    = 15,
	          bore_diameter   = 5,
	          circles         = 0,
	          backlash        = 0,
	          twist           = 0,
	          involute_facets = 0){
	if(circular_pitch==false && diametral_pitch==false) 
		echo("MCAD ERROR: gear module needs either a diametral_pitch or circular_pitch");

	// Convert diametrial pitch to our native circular pitch
	circular_pitch             = (circular_pitch!=false?circular_pitch:180/diametral_pitch);

	// Pitch diameter: Diameter of pitch circle.
	pitch_diameter             = number_of_teeth*circular_pitch/180;
	pitch_radius               = pitch_diameter/2;
	echo("Teeth:", number_of_teeth, " Pitch radius:", pitch_radius);

	// Base Circle
	base_radius                = pitch_radius*cos(pressure_angle);

	// Diametrial pitch: Number of teeth per unit length.
	pitch_diametrial           = number_of_teeth/pitch_diameter;

	// Addendum: Radial distance from pitch circle to outside circle.
	addendum                   = 1/pitch_diametrial;

	//Outer Circle
	outer_radius               = pitch_radius + addendum;

	// Dedendum: Radial distance from pitch circle to root diameter
	dedendum                   = addendum + clearance;

	// Root diameter: Diameter of bottom of tooth spaces.
	root_radius                = pitch_radius - dedendum;
	backlash_angle             = backlash/pitch_radius*180/pi;
	half_thick_angle           = (360/number_of_teeth - backlash_angle)/4;

	// Variables controlling the rim.
	rim_radius                 = root_radius - rim_width;

	// Variables controlling the circular holes in the gear.
	circle_orbit_diameter      = hub_diameter/2 + rim_radius;
	circle_orbit_curcumference = pi*circle_orbit_diameter;

	// Limit the circle size to 90% of the gear face.
	circle_diameter            = min(0.70*circle_orbit_curcumference/circles,
			                             (rim_radius-hub_diameter/2)*0.9);

	difference(){
		union(){
			difference(){
				linear_extrude(height = rim_thickness, convexity = 10, twist = twist)
				gear_shape(number_of_teeth,
					         pitch_radius     = pitch_radius,
					         root_radius      = root_radius,
					         base_radius      = base_radius,
					         outer_radius     = outer_radius,
					         half_thick_angle = half_thick_angle,
					         involute_facets  = involute_facets);
				if(gear_thickness < rim_thickness)
					translate([0,0,gear_thickness])
					  cylinder(r = rim_radius, h = rim_thickness-gear_thickness + 1);
			}
			if(gear_thickness > rim_thickness)
				cylinder(r = rim_radius, h = gear_thickness);
			if(hub_thickness > gear_thickness)
				translate([0,0,gear_thickness])
				cylinder(r = hub_diameter/2, h = hub_thickness - gear_thickness);
		}
		translate([0,0,-1])
		cylinder(r = bore_diameter/2,
			       h = 2 + max(rim_thickness, hub_thickness, gear_thickness));
		if(circles>0){
			for(i=[0:circles-1])	
				rotate([0,0,i*360/circles])
				  translate([circle_orbit_diameter/2, 0, -1])
				    cylinder(r = circle_diameter/2, h = max(gear_thickness, rim_thickness) + 3);
		}
	}
}


//////////// Design specific modules //////////////
module snelle(r1, r2, h){
  cylinder(r1 = r1, r2 = r2, h = 0.8);
  cylinder(r = r2, h = h);
}
//snelle(r1 = 10, r2 = 5, h = 3);

module my_gear(teeth, height){
	gear(number_of_teeth = teeth,
			 circular_pitch  = 400,
			 pressure_angle  = 30,
			 clearance       = 0.2,
			 gear_thickness  = height,
			 rim_thickness   = height,
			 rim_width       = 5,
			 hub_thickness   = height,
			 hub_diameter    = 15);
}

// Sandwich height follows exactly 607 bearing thickness
module sandwich(teeth = 33){
  od              = Bearing_607_outer_diameter;
  bw              = Bearing_607_width;
  meltlength      = 0.1;
	gear_height     = Sandwich_height*4/7;
  cylinder_height = Sandwich_height*3/7;
  radius          = 34.25; // Adapt snelle raduis to gear circ-pitch and teeth

  difference(){
    union(){
      // Gear
      translate([0, 0, cylinder_height - meltlength])
        my_gear(teeth, gear_height);
      // Snelle
      //color("green")
      snelle(r1 = radius + 0.8, r2 = radius, h = cylinder_height, $fn = 150);
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
module motor_gear(height = 16){
  swh  = Sandwich_height;
  melt = 0.1;
  teeth = 13;
  difference(){
    union(){
      translate([0,0,height - swh - melt]) my_gear(13, swh + melt);
      cylinder(r = 10, h = height - swh); 
    }
    translate([0, 0, -1])
      cylinder(r = 5/2, h = height + 2);
  }
}
//motor_gear();

// Visualization only
module gear_friends(){
  translate([76,59,-8]) motor_gear(16); // 13 teeth
  sandwich(35);
}
//gear_friends();

//Nema17();
//translate([0, 0, 46]) motor_gear();

module lock(r, height){
  cylinder(r=r, h=height);
}

module bottom_plate(){
  /////// Global variables renamed short //////
  cw  = Nema17_cube_width;
  th  = Bottom_plate_thickness; 
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
      cylinder(r=86, h = th);
    }
    // Dig out filament hole in sandwich stick and base.
    // When physical build is done, fill this hole for stiffness
    translate([0, 0, -1]) cylinder(r = 2.4, h = Big);
  }
}
//bottom_plate();

module bottom_plate_and_sandwich(){
  th  = Bottom_plate_thickness; 
  gap = 0.2;
  lh  = Lock_height;
  bw  = Bearing_607_width;

  bottom_plate();
  // Place sandwich slices
  translate([0, 0, th + lh/4 + gap/2]) sandwich();
  translate([0, 0, th + lh/4 + gap/2 + gap + lh + bw]) sandwich();
  translate([0, 0, th + lh/4 + gap/2 + 2*(gap + lh + bw)]) sandwich();
  translate([0, 0, th + lh/4 + gap/2 + 3*(gap + lh + bw)]) sandwich();
}
//bottom_plate_and_sandwich();

// Assumes child(0) is centered in xy-plane
module five_point_translate(){
  radius = 60;
  base_rotation = 90;
  for(i=[72:72:359]){
    rotate([0,0,base_rotation + i]) translate([radius,0,0]) child(0);
  }
  //rotate([0,0,base_rotation])
  //  translate([radius, 0, 0]) rotate([0,0,0]) child(0);
  //rotate([0,0,base_rotation + 72])
  //  translate([radius, 0, 0]) rotate([0,0,29]) child(0);
}

module bottom_plate_and_sandwich_and_nema17(){
  difference(){
    bottom_plate_and_sandwich();
    translate([0, 0, -1])
      five_point_translate()
        Nema17_screw_holes(M3_diameter, Big);
    translate([0, 0, -1])
      five_point_translate()
        cylinder(r = 8, h = Big);
  }
  five_point_translate()
    translate([0,0,-Nema17_cube_height - 2])
    Nema17();
}
bottom_plate_and_sandwich_and_nema17();
