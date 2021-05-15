difference(){
  union(){
    cylinder(d=6.3, h=28.5, $fn=6);
    translate([0,0,28.5-1])
      cylinder(d=2.45, h=6+1,$fn=10);
  }
  translate([0,0,-1])
    cylinder(d=2.9, h=8+1,$fn=10);
}
