// Minor modifications of code by GregFrost for this: http://www.thingiverse.com/thing:3575
// and Reprappro: https://github.com/reprappro/Extruder-drive
include <measured_numbers.scad>
include <design_numbers.scad>
include <util.scad>
use <Nema17_and_Ramps_and_bearings.scad>

// Sweep.scad contains code from
// https://github.com/openscad/scad-utils
// and
// https://github.com/openscad/list-comprehension-demos
use <sweep.scad>

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
       // Increasing circular_pitch this makes gears larger
       // Should possibly be parameter in design_numbers.scad...
			 circular_pitch  = Circular_pitch_top_gears,
			 pressure_angle  = 30,
			 clearance       = 0.2,
			 gear_thickness  = height,
			 rim_thickness   = height,
			 rim_width       = 5,
			 hub_thickness   = height,
			 hub_diameter    = 15);
}
//my_gear(40,10);

module decoration_holes(){
  for(i = [1:60:360]){
    rotate([0,0,i])
      translate([2*Snelle_radius/3,0,-1])
      cylinder(r=8.5,h=Big);
  }
}

module line_holes(){
  rotate([90,0,33])
    translate([0,Snelle_height/2,Snelle_radius/2])
    cylinder(r = 0.95, h = 40);
  rotate([90,0,27])
    translate([0,Snelle_height/2,Snelle_radius/2])
    cylinder(r = 0.95, h = 40);
}

// Sandwich is a sandwich gear on top of a snelle.
// These are modelled together, then split up before printing to make a cleaner edge.

// Sandwich height follows exactly 608 bearing thickness
module sandwich(worm=false, brim=Snelle_brim){
  od              = Bearing_608_outer_diameter;
  bw              = Bearing_608_width;
  meltlength      = 0.1;
  difference(){
    union(){
      // sandwich gear
      color(Printed_color_2)
      if(worm){
        translate([0, 0, Snelle_height])
          worm_gear();
      }else{
        translate([0, 0, Snelle_height])
          my_gear(Sandwich_gear_teeth, Sandwich_gear_height);
      }
      color(Printed_color_1){
      // Snelle
      cylinder(r = Snelle_radius,   h = Snelle_height + meltlength, $fn=150);
      cylinder(r = brim, h = Sandwich_edge_thickness, $fn=150);
      }
    }
    // Dig out the right holes
    // Bearing hole
    translate([0, 0, -1.2])
      cylinder(r = od/2 + 0.15, h = Sandwich_height); // 0.15 added to raduis during print...
    cylinder(r = od/2-2, h = Big);
    // Decoration/material saving holes
    decoration_holes();
    line_holes();
  }
  //Bearing_608();
}
//sandwich(brim=Snelle_radius+7);
//sandwich(worm=true);
//sandwich(worm=false);

module inverse_torx(h = Snelle_height + 2, r = Snelle_radius, female=false){
  circs = 12;
  difference(){
    intersection(){
      if(female){
        cylinder(r=r+0.1, h=h, $fn=150);
      } else {
        cylinder(r=r, h=h, $fn=150);
      }
      for(i=[0:1:circs])
        rotate([0,0,i*360/circs]){
          translate([r-5,0,-1])
          cylinder(r=r/4.2, h=h+2, $fn=50);
        if(female){
          rotate([0,0,360/(2*circs)])
            translate([r-7,0,-1])
            cylinder(r2=1, r1=r/1.9, h=h+2, $fn=50);
          }
        }
    }
    decoration_holes();
    line_holes();
  }
}
//inverse_torx();

// May not render correctly in preview...
module sandwich_gear(worm=false){
    difference(){
      sandwich(worm=worm);
      translate([0,0,-1])
        color(Printed_color_2)
        cylinder(r=Big, h=Snelle_height + 1);
      color("blue")
      inverse_torx(female=true);
    }
}
// Give space to worm so it doesn't lock up
//scale(0.99)
rotate([180,0,0])
sandwich_gear(false);
//sandwich_gear(true);

// May not render correctly in preview...
module snelle(){
  color(Printed_color_2)
  difference(){
    sandwich();
    translate([0,0,Snelle_height-0.01])
      cylinder(r=Big, h=Big);
  }
  color("red")
  inverse_torx();
}
//snelle();

module snelle_line_buildup_visualization(){
  module snelle(){
    difference(){
      color(Printed_color_2)
      rotate([0,0,-103])
      snelle();
      translate([0,0,-1])
        cylinder(r=Big, h=1.7);
    }
  }
  module rectangular_torus(){
    color("gold")
    difference(){
      cylinder(r=Snelle_radius+3, h=Snelle_height-1,$fn=300);
      translate([0,0,-1])
        cylinder(r=Snelle_radius, h=Snelle_height+2,$fn=300);
    }
  }
  module line(){
    translate([Snelle_radius+3,0,Snelle_height/2])
      rotate([90,0,0])
      cylinder(r=0.7, h=150);
  }
  module letters(){
    translate([0,0,Snelle_height]){
      color("white")
        translate([0,-2.5,0])
        cube([Snelle_radius+3, 5, 0.2]);
      color("black")
      translate([Snelle_radius/2,-2,0])
      text("R", font="Times New Roman:style=Italic", size=4);

      rotate([0,0,45]){
      color("white")
        translate([0,-2.5,0])
        cube([Snelle_radius, 5, 0.2]);
      color("black")
      translate([Snelle_radius/2,-2,0])
      text("r", font="Times New Roman:style=Italic", size=4);
      }
    }
  }
  rectangular_torus();
  letters();
}
//snelle_line_buildup_visualization();

module motor_gear(height = Motor_protruding_shaft_length, shaft_radius = Motor_gear_shaft_radius_BC){
  swgh  = Sandwich_gear_height  - 0.4;  // allow some space for easier printing
  melt = 0.1;
  teeth = Motor_gear_teeth;

  module the_bore(){
    difference(){
      translate([0, 0, -1])
        cylinder(r = Nema17_motor_shaft/2 + 0.21, h = height + 2);
      // D-wall in bore
      translate([-6/2, Nema17_motor_shaft/2 - Shaft_flat, 0])
        cube([6,3,height]);
    }
    // Phase in
    translate([0,0,-0.1])
      cylinder(r1=Nema17_motor_shaft/2+0.8, r2=1.6, h=3.0);
    translate([0,0,height - 2.9])
     cylinder(r2=Nema17_motor_shaft/2+0.8, r1=1.6, h=3.0);
  }

  difference(){
    union(){
      translate([0,0,height - swgh])
        my_gear(teeth, swgh);
      // Shaft cylinder
      cylinder(r = shaft_radius, h = height - swgh + melt, $fn=40);
    }
    the_bore();
  }
}
//motor_gear();

module motor_gear_a(){
  motor_gear(Motor_gear_a_height, Motor_gear_shaft_radius_A);
}
//rotate([180,0,0])
//motor_gear_a();

module motor_gear_b(){
  motor_gear(Motor_gear_b_height, Motor_gear_shaft_radius_BC);
}
//rotate([180,0,0])
//motor_gear_b();

module motor_gear_c(){
  motor_gear(Motor_gear_c_height, Motor_gear_shaft_radius_BC);
}
//rotate([180,0,0])
//motor_gear_c();

// Visualization only
module gear_friends(){
  translate([Four_point_five_point_radius,0,-5]) motor_gear();
  sandwich();
}
//gear_friends();

// A gear with 90 degree valleys and a twist
module worm_gear(angle=Worm_largest_angle){
  // phi_length = twist*(PI/180)*Worm_disc_radius
  // angle = atan(phi_length/Sandwich_gear_height)
  // tan(angle) = phi_length/Sandwich_gear_height
  //            = twist*(PI/180)*(Worm_disc_radius/Sandwich_gear_height)
  // twist      = tan(angle)*(180/PI)*(Sandwich_gear_height/Worm_disc_radius)

  // twist = tan(angle)*Sandwich_gear_height
  //echo(Worm_disc_radius);
  //echo((PI/180));
  //echo((PI/180)*Worm_disc_radius);
  linear_extrude(height    = Sandwich_gear_height,
                 convexity = 10,
                 twist     = -tan(angle)*(180/PI)*(Sandwich_gear_height/Worm_disc_radius))
    difference(){
      // There is a radius and a virtual radius for worm gears in design_numbers.scad
      // Cutting off the outermost virtual band has the same effect as if
      // it was never there in the first place
      circle(r=Worm_disc_radius, $fn=Sandwich_gear_teeth);
      for(i=[0:Degrees_per_worm_gear_tooth:359.9]){
        rotate([0,0,i])
          // Worm_disc_virtual_radius affects Worm_disc_tooth_valley_r
          translate([Worm_disc_tooth_valley_r,0])
          rotate([0,0,-45])
          square([30,30]);
      }
    }
}
//worm_gear(61);
//translate([0,Worm_disc_radius,0])
//rotate([0,61,0]) cylinder(r=2, h=10, center=true);

// Creates throated worm gear.
// No need as long as worm disc is thin
module worm_gear_by_diff(){
  module toothed_out_cylinder(){
    difference(){
      cylinder(h=Sandwich_gear_height,
          r=Worm_disc_radius,
          $fn=Sandwich_gear_teeth);
      for(i=[0:60:360]){
        rotate([0,0,(i/360)*Degrees_per_worm_gear_tooth])
          translate([Worm_disc_tooth_valley_r+Worm_radius,
              0,
              Sandwich_gear_height/2])
          rotate([90,0,0])
          rotate([0,0,i])
            worm(0.06, false);
      }
    }
  }
  module tooth(){
    difference(){
      toothed_out_cylinder();
      rotate([0,0,2.51*Degrees_per_worm_gear_tooth])
        translate([-Sandwich_radius*1.5,
            0,
            -Sandwich_height*1.5])
        cube([Sandwich_radius*3,
            Sandwich_radius*3,
            Sandwich_height*3]);
      rotate([0,0,1.49*Degrees_per_worm_gear_tooth])
        translate([-Sandwich_radius*1.5,
            -Sandwich_radius*3,
            -Sandwich_height*1.5])
        cube([Sandwich_radius*3,
            Sandwich_radius*3,
            Sandwich_height*3]);
    }
  }
  for(i=[0:Sandwich_gear_teeth])
    rotate([0,0,i*Degrees_per_worm_gear_tooth])
    tooth();
}
//worm_gear_by_diff();

module placed_worm_gear(ang=0){
  rotate([90,0,0])
    translate([Worm_disc_tooth_valley_r+Worm_radius,0,-Sandwich_gear_height/2])
    rotate([0,0,ang])
    worm_gear();
}
//%placed_worm_gear();

// This is the worm for the worm drive
module worm(step=0.2, with_details=true){
  // XY-Translations of top (phase in), main (touch gear) and bottom (phase out) spirals
  function translate_top_xy(v)    = Worm_radius
                  - virtual_side*v/Degrees_per_worm_gear_tooth;
  function translate_main_xy(v)   = Worm_radius + Worm_disc_tooth_valley_r*(1 - cos(v));
  function translate_bottom_xy(v) = Worm_radius
                  + Worm_disc_tooth_valley_r*(1 - cos(v))
                  - 6*(v - stop_angle)/(Degrees_per_worm_gear_tooth);

  module fill_interior(){
    function my_circle(r) = [for (i=[0:Worm_spiral_turns*step*360/stop_angle:359.9])
      r * [cos(i), sin(i)]];
    // Scale profile to fill interior
    towerpath1 = [for (v=[-Degrees_per_worm_gear_tooth : step : stop_angle + Degrees_per_worm_gear_tooth])
      // Move downwards
      translation([0, // x
          0,
          -Worm_disc_tooth_valley_r*sin(v)]) *
      // Scale in xy to fill interior
      scaling([(translate_main_xy(v)+virtual_side*(1 - cos(v)))/translate_main_xy(0),
          (translate_main_xy(v)+virtual_side*(1 - cos(v)))/translate_main_xy(0),
          0])
      ];
    sweep(my_circle(Worm_smallest_radius), // Smallest radius at z=0
        towerpath1);
  }

  // Worm gear tooth side including tip
  virtual_side = sqrt(2)*(Worm_disc_virtual_radius - Worm_disc_tooth_valley_r);
 // Extra sidelength needed to connect spiral with itself vertically
  reduced_side = virtual_side-Worm_edge_cut; // might need hand tuning to compile
  thread_profile = [
                  //[-reduced_side*sqrt(2),0,0], // With this corner, it's essentially a square
                  [-reduced_side/Sqrt2,0,-reduced_side/Sqrt2],
                  [-Worm_edge_cut,0,-Worm_edge_cut], // Round off outer edge
                  [-Worm_edge_cut,0,+Worm_edge_cut], // Virtual valley-hitting point in origo
                  [-reduced_side/Sqrt2,0,reduced_side/Sqrt2]
                  ];
  //p = [translation([0,0,0]),translation([0,1,0])];
  //sweep(thread_profile,p);
  stop_angle = Worm_spiral_turns*Degrees_per_worm_gear_tooth; // where main path stops

  // Top spiral
  path0 = [for (v=[Degrees_per_worm_gear_tooth : -step : step])
    rotation([0,0,-v*360/Degrees_per_worm_gear_tooth]) * // Rotate around z axis
    translation([translate_top_xy(v), // x
                 0,
                 +Worm_disc_tooth_valley_r*sin(v)]) * // z
    rotation([0,-v,0]) // Rotate shape around valley-hitting point
    ];

  // Main path touching gear
  path1 = [for (v=[0 : step : stop_angle + step])
    rotation([0,0,v*360/Degrees_per_worm_gear_tooth]) *
    translation([translate_main_xy(v), // x
                 0,
                 -Worm_disc_tooth_valley_r*sin(v)]) * // z
    rotation([0,-v,0])
    ];

  // Bottom spiral
  path2 = [for (v=[stop_angle + 2*step : step : stop_angle
                                              + Degrees_per_worm_gear_tooth])
    rotation([0,0,v*360/Degrees_per_worm_gear_tooth]) *
    translation([translate_bottom_xy(v), // x
                 0,
                 -Worm_disc_tooth_valley_r*sin(v)]) * // z
    rotation([0,-v,0])
    ];

  height_downwards = Worm_disc_tooth_valley_r*sin(stop_angle) + virtual_side;
  height_upwards = 5;


  //translate([0,0,height_downwards]) // Put bottom plane on z=0
  difference(){
    union(){
      // Axle
      translate([0,0,-height_downwards-Worm_axle_length])
        cylinder(h=Worm_axle_length, r1=Worm_axle_radius, r2=Worm_axle_radius + Worm_axle_length);

      // Spiral
      if(with_details){
        mirror([1,0,0]) // Right-handed threading to push with greatest force _down_ into bottom_plate
          sweep(thread_profile, concat(path0, path1, path2));
        fill_interior();
      }else{
        mirror([1,0,0]) // Right-handed threading to push with greatest force _down_ into bottom_plate
          sweep(thread_profile, path1);
      }
    }
    // Cut in half, see interior
    //translate([0,-25,-40])
    //cube([30,50,50]);

    if(with_details){
      // Motor shaft D-shaped bore
      h = height_downwards + height_upwards + 2;
      rotate([0,0,45])
      translate([0,0,-height_downwards - Worm_axle_length - 1])
      difference(){
        cylinder(r = 5.4/2, h = h+2, $fn=40);
        translate([2.2,-(h+4),-2])
          cube(2*(h+4));
      }
      // Phase in the D-shape
      translate([0,0,-height_downwards - Worm_axle_length - 1]){
        cylinder(d1=8, d2=5, h=3);
      }

      // Cut bottom (except Worm_axle)
      translate([0,0,-Worm_axle_length - height_downwards])
        difference() {
          cylinder(h=Worm_axle_length,r=50);
          translate([0,0,-1])
            cylinder(h=Worm_axle_length+2,r1=Worm_axle_radius,r2=Worm_axle_radius+Worm_axle_length);
        }
      // Cut top
      translate([-50,-50,height_upwards])
        cube(100);
      // Screw hole and nut lock
      for(i=[0,120,240]){
        rotate([0,0,i]){
          translate([0,0,-height_downwards+6.3-Worm_axle_length]){
            rotate([0,90,45]){
              scale([1.06,1.06,3])
                M3_screw(6,true);
              rotate([0,0,90])
                translate([0,4,5])
                rotate([90,0,0])
                translate([-5.6/2,0,1]){
                  point_cube([5.6,2.5,9],120);
                  // Phase in nutlock
                  translate([5.6/2,2.5/2, 7.1])
                    linear_extrude(height=3,convexity=3,scale=[2.4, 2.7])
                    translate([-(5.6/1.5)/2,-(2.5/1.5)/2])
                    square([5.6/1.5,2.5/1.5]);
                }
            }
          }
        }
      }
    }
  }
}
// Mirror to make it turn counterclockwise when it retracts line
// This will be the direction of heaviest load,
// and we want to push gear _down_ towards bottom plate
// to avoid pushing disc up onto the other sandwich snelles and gears
//mirror([1,0,0])
//worm(step=0.01);

module animate_roating_worm(){
  rotate([0,0,360*$t])
  rotate([0,5,0])
  translate([0,0,10])
  color(Printed_color_2)
  worm(step=0.062);
}
//animate_roating_worm();

// ang is angle of worm plate, not worm itself
module placed_worm(ang = 0){
  rotate([0,0,-ang*Sandwich_gear_teeth])
  worm();
  %placed_worm_gear(ang);
}
//placed_worm(ang=-12);

module sstruder_gear(){
	difference(){
		union(){
			gear(
				number_of_teeth = Sstruder_gear_teeth,
				circular_pitch  = Sstruder_gear_circular_pitch,
        diametral_pitch = false,
				pressure_angle  = 30,
				clearance       = 0.2,
				gear_thickness  = Sstruder_gear_thickness,
        rim_thickness   = Sstruder_gear_thickness,
				rim_width       = 5,
				hub_thickness   = Sstruder_gear_thickness,
				hub_diameter    = 15,
				bore_diameter   = Nema17_motor_shaft,
				circles         = 0,
				backlash        = 0,
				twist           = 0,
				involute_facets = 0
			);

			translate([Nema17_motor_shaft/2 - Shaft_flat,-5/2,0])
				cube([1.5,5,Sstruder_gear_thickness]);
			//base
			//difference(){
			//	cylinder(r=6.3,h=1.0,$fn=64);
			//	cylinder(r=Nema17_motor_shaft/2,h=1.001,$fn=64);
			//}
		}
		//lead in
		translate([0,0,-0.01])
			cylinder(r1=Nema17_motor_shaft/2+0.25,
               r2=Nema17_motor_shaft/2-1,h=2,$fn=64);
	}
}
//sstruder_gear();
