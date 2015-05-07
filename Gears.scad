// Thanks to GregFrost for this: http://www.thingiverse.com/thing:3575
// Thanks also to Reprappro: https://github.com/reprappro/Extruder-drive
include <measured_numbers.scad>
include <design_numbers.scad>

//////////// Utility numbers //////////////
// When numbers get larger than Big, models start to look funny
// (parametrization breaks down).
Big   = 300; 
Sqrt3 = sqrt(3);
pi    = 3.1415926535897932384626433832795;

//////////// Functions /////////////
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


//////////// Modules /////////////
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

module large_gear(height=Large_gear_height){
  difference(){
    cylinder(r=28,h=height,$fn=128);
    translate([0,0,-0.1]) gear(
        number_of_teeth=61,
        circular_pitch=150, diametral_pitch=false,  // Changed from 150 - AB
        pressure_angle=28,
        clearance = 0.2,
        gear_thickness=0.01,
        rim_thickness=height-3,
        rim_width=3,
        hub_thickness=0,
        hub_diameter=4,
        bore_diameter=1,
        circles=0,
        backlash=0,
        twist=0,
        involute_facets=0);

    difference(){
      cylinder(r=22.5,h=Big,center=true,$fn=128); 
      for(i=[0:5])
        rotate([0,0,i*360/5])
          translate([0,15,height - 1.5])
            cube([6,30,3],center=true);
      difference(){
        translate([0,0,height - 5.5]) cylinder(r=5.5,h=4.5,$fn=64);
        translate([0,0,0]) cylinder(h=height-3, r=5.4/sqrt(3),$fn=6);
      }
    }
    cylinder(r=2.95/sqrt(3),h=Big,center=true,$fn=6);
  }
}
//large_gear(12);

module small_gear(height=Small_gear_height){
	difference(){
		union(){
      translate([0,0,0.1])
			gear(
				number_of_teeth=13,
				circular_pitch=150,
        diametral_pitch=false, // Changed from 150 - AB
				pressure_angle=28,
				clearance = 0.2,
				gear_thickness=5,
				rim_thickness=height - 0.1,
				rim_width=6,
				hub_thickness=4,
				hub_diameter=13,
				bore_diameter=Nema17_motor_shaft,
				circles=0,
				backlash=0,
				twist=0,
				involute_facets=0
			);
			
			translate([Shaft_flat + 0.75,0,height/2])
				cube([1.5,5,height],center=true);
			//base
			difference(){
				cylinder(r=6.3,h=1.0,$fn=64);			
				cylinder(r=Nema17_motor_shaft/2,h=1.001,$fn=64);
			}
		}
		//lead in
		translate([0,0,-0.01])
			cylinder(r1=Nema17_motor_shaft/2+0.25,
               r2=Nema17_motor_shaft/2-2,h=4,$fn=64);
	}
}
//small_gear(6);
