include <parameters.scad>
use <util.scad>

height_from_platform = Line_roller_ABC_winch_h + 200;

module beam(){
  translate([-100,-Beam_width/2, height_from_platform])
	cube([200, Beam_width, Beam_width]);
}

//rotate([90,0,0])
//landing_bracket();
module landing_bracket(){
  th = 20;
  th2 = 60;
  translate([-th/2, -th/2, 0])
    cube([th, th,  Line_roller_ABC_winch_h + 175]);
  difference(){
	  translate([-th2/2, -th/2,0])
		  ydir_rounded_cube2([th2, th, 5], r=8, $fn=13*4);
	  for(k=[0,1])
	    mirror([k,0])
			translate([th2/2-7,3,0])
			Mounting_screw_countersink();
  }

  for(x=[0, 1])
	  for(y=[0, 0])
		  mirror([x, 0])
			  mirror([0, y])
			  translate([0,-th/2,5])
			  standing_triangle([th2/2, 5, 144],bottom=1);
  //%beam();
}

landing_bracket_a();
module landing_bracket_a(){
  th = 20;
  th2 = 60;
  difference(){
    union(){
    translate([-th/2, -th/2, 0])
      cube([th, th,  Line_roller_ABC_winch_h + 175]);
  difference(){
	  translate([-th2/2, -th/2,0])
		  ydir_rounded_cube2([th2, th, 5], r=8, $fn=13*4);
	  for(k=[0,1])
	    mirror([k,0])
			translate([th2/2-7,3,0])
			Mounting_screw_countersink();
  }

  for(x=[0, 1])
	  for(y=[0, 0])
		  mirror([x, 0])
			  mirror([0, y])
			  translate([0,-th/2,5])
			  standing_triangle([th2/2, 5, 144],bottom=1);
  }
    cube([4,50,53], center=true);
  }
  //%beam();
}


//standing_triangle([35, 5, 144]);
module standing_triangle(v, bottom=0){
  x = v[0];
  y = v[1];
  z = v[2];

  translate([0,y,0])
	  rotate([90,0,0])
	  linear_extrude(height=y)
	  polygon([[0,-bottom],[x,-bottom],[x,0],[0,z]]);
}
