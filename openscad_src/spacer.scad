include <parameters.scad>
include <gear_parameters.scad>

sandwich_height = Spool_height+0.7+Gear_height;

module import_the_sandiwch(){
  translate([0,0,0.1])
  import("../openscad_stl/spool_gear.stl");
  translate([0,0,sandwich_height])
    rotate([0,180,0])
      import("../openscad_stl/spool.stl");
}

spacer();
module spacer(){
  difference(){
    translate([0,0,b608_width])
      cylinder(d=15, h=sandwich_height-2*b608_width);
    cylinder(d=8.5, h=sandwich_height);
  }
}
