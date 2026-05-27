include <../lib/BOSL2/std.scad>
include <../lib/BOSL2/screws.scad>
include <../lib/parameters.scad>
include <../lib/gear_util.scad>
$fn = 100;


//spool();
module spool(){
  difference() {
    cylinder(d=90, h=60);
    trapezoidal_threaded_rod(
        d = 60,             // outer diameter
        l = 2*60+10,            // axial length of threaded part
        pitch = 2,          // distance between turns
        thread_depth = 1.5, // radial tooth height/depth
        thread_angle = 60,
        $fn = 128
    );
    down(1)
    for(ang=[0,120,240]) {
      rotate([0,0,ang])
        fwd(5.5)
        cube([70/2, 11, 110]);
    }
    //up(10)
    //  cylinder(d=63, h=60);
  }
}

// rotate([0,90,0])
//center_axis();
module center_axis() {
  thread_d_tolerance = 1;

  difference() {
    union(){
      cylinder(r=10, h=130, center=false);
      hdiff = (130/2 - 130/3);
      cylinder(r1=10, r2=30-1.5, h=hdiff, center=false);
      up(130/(3*2) + hdiff)
      trapezoidal_threaded_rod(
          d = 60 - thread_d_tolerance,     // outer diameter
          l = 130/3,            // axial length of threaded part
          pitch = 2,          // distance between turns
          thread_depth = 1.5, // radial tooth height/depth
          thread_angle = 60,
          $fn = 128
      );
    }
    down(1)
    {
    cylinder(d=10, h=11);
    rotate([0,0,180])
    fwd(1)
    cube([5.5, 2, 11]);
    }
    up(130-10){
    cylinder(d=10, h=11);
    rotate([0,0,180])
    fwd(1)
    cube([5.5, 2, 11]);
    }
  }
}


//down(18)
//center_axis_legs();
module center_axis_legs() {
  //for(z=[0,130-7]) up(z)
    hull() {
      cylinder(d=20, h=7, center=false);
      translate([50,-35,0])
        cube([7, 70, 7]);
    }
    cylinder(d=9.5, h=14);
    rotate([0,0,180])
    fwd(1)
    cube([5.5, 2, 14]);
}

//rotate([180,0,0])
//static_rotor();
module static_rotor() {
  belt_width = GT2_belt_width;
  difference() {
    up(130/2+1){
      for(z=[b623_outer_dia/2,130/2-2-b623_outer_dia/2 - belt_width-3])
        up(z)
        for(k=[0,120,240])
          rotate([0,90,k])
          cylinder(d=b623_outer_dia, h=60/2 + b623_width);
      cylinder(d=60-2*1.5, h = 130/2-2);
      up(56.5)
        GT2_2mm_pulley_extrusion(belt_width, 150);
    }
    cylinder(d=21, h=300);
    up(130/2+1+5) {
      cylinder(d1=21, d2=50, h=20);
      up(20)
        cylinder(d=50, h=130/2-2-10-20);
    }
  }
}

difference(){
assembly();
translate([-200, 0, -200])
cube(400);
}
module assembly() {
  rotate([0,90,0]) {
    down(18)
      center_axis_legs();
    mirror([0,0,1])
      down(130+18)
        center_axis_legs();
    center_axis();
    static_rotor();
    up(62)
      spool();
  }
}
