include <parameters.scad>

// See spool_core.scad or layout.scad for inspecting visually that this fits in

spacer(10);
module spacer(width){
  difference(){
    cylinder(d=15, h=width);
    translate([0,0,-1])
      cylinder(d=8.5, h=width + 2);
    // Phase in/out
    p = 6.7;
    for(k=[0,1]){
      translate([0,0,k*width])
        rotate_extrude(angle=360, convexity=5)
          translate([Motor_pitch-1.3,0])
            rotate([0,0,-45])
              square([4,5]);
    }
  }
}
