include <parameters.scad>
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
	base_radius*(cos(involute_angle) + involute_angle*PI/180*sin(involute_angle)),
	base_radius*(sin(involute_angle) - involute_angle*PI/180*cos(involute_angle)),
];

function rotated_involute(rotate, base_radius, involute_angle) =
[
	cos(rotate)*involute(base_radius, involute_angle)[0] + sin(rotate)*involute(base_radius, involute_angle)[1],
	cos(rotate)*involute(base_radius, involute_angle)[1] - sin(rotate)*involute(base_radius, involute_angle)[0]
];

function involute_intersect_angle(base_radius, radius) = sqrt(pow(radius/base_radius, 2) - 1)*180/PI;


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
  for(i=[1:res]){
    polygon(points=[[0,0], rotate_point(centre_angle, involute(base_radius,start_angle+(stop_angle - start_angle)*(i-1)/res)),
                           rotate_point(centre_angle, involute(base_radius,start_angle+(stop_angle - start_angle)*i/res)),
                           mirror_point(rotate_point(centre_angle, involute(base_radius,start_angle+(stop_angle - start_angle)*i/res))),
                           mirror_point(rotate_point(centre_angle, involute(base_radius,start_angle+(stop_angle - start_angle)*(i-1)/res)))],
        paths=[[0,1,2,3,4,0]]);
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
	          involute_facets = 0,
            slices          = 1){
	if(circular_pitch==false && diametral_pitch==false)
		echo("ERROR: gear module needs either a diametral_pitch or circular_pitch");

	// Convert diametrial pitch to our native circular pitch
	circular_pitch             = (circular_pitch!=false?circular_pitch:180/diametral_pitch);

	// Pitch diameter: Diameter of pitch circle.
	pitch_diameter             = number_of_teeth*circular_pitch/180;
	pitch_radius               = pitch_diameter/2;

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
	backlash_angle             = backlash/pitch_radius*180/PI;
	half_thick_angle           = (360/number_of_teeth - backlash_angle)/4;

	// Variables controlling the rim.
	rim_radius                 = root_radius - rim_width;

	// Variables controlling the circular holes in the gear.
	circle_orbit_diameter      = hub_diameter/2 + rim_radius;
	circle_orbit_curcumference = PI*circle_orbit_diameter;

	// Limit the circle size to 90% of the gear face.
	circle_diameter            = min(0.70*circle_orbit_curcumference/circles,
			                             (rim_radius-hub_diameter/2)*0.9);

	difference(){
		union(){
			difference(){
				linear_extrude(height = rim_thickness, convexity = 10, twist = twist, slices=slices)
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
		if(circles>0){
			for(i=[0:circles-1])
				rotate([0,0,i*360/circles])
				  translate([circle_orbit_diameter/2, 0, -1])
				    cylinder(r = circle_diameter/2, h = max(gear_thickness, rim_thickness) + 3);
		}
	}
}

module my_gear(teeth, height, circular_pitch, fac=1, slices=1){
  pitch = (teeth*circular_pitch/360);
	gear(number_of_teeth = teeth,
       // Increasing circular_pitch this makes gears larger
       // Should possibly be parameter in design_numbers.scad...
			 circular_pitch  = circular_pitch,
			 pressure_angle  = 30,
			 clearance       = 0.2,
			 gear_thickness  = height,
			 rim_thickness   = height,
			 rim_width       = 5,
			 hub_thickness   = height,
			 hub_diameter    = 15,
       twist = fac*(180/3.14)*height*1/pitch,
       slices = slices);
}
//my_gear(40,10);
