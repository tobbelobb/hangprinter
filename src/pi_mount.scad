height = 28.5; // High enough to let USB-C power enter easily.

difference(){
  union(){
    cylinder(d=6.3, h=height, $fn=6);
    translate([0,0,height-1])
      linear_extrude(height=7, twist=7*2*360, slices=100)
        translate([0.2,0])
          circle(d=2.65, $fn=10);
  }
  translate([0,0,-1])
    cylinder(d=2.9, h=8+1,$fn=10);
}

