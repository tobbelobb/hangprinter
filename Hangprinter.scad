union(){
  cylinder(h=1200, r = 1.5);
  for (i=[0:120:359]) {
    rotate([90,0,i]) cylinder(h=700, r=1.5);
  }
  intersection(){
    cylinder(h=120,r1=2,r2=60, center=true);
    cylinder(h=130,r=15, center=true);
  }
}
