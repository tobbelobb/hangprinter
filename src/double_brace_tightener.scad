use <lib/util.scad>
use <brace_tightener.scad>

rotate([90,0,0])
double_brace_tightener(7.2);
module double_brace_tightener(b){
  shorten = 7;
  difference(){
    union(){
      brace_tightener(b);
      translate([23.1-shorten-b, 0, 8])
        cube([b, b, 24-8]);
    }
    translate([0,b/2,24-b/2])
      rotate([0,90,0])
        teardrop(r=3.4/2, h=30, $fn=20);
  }
}



