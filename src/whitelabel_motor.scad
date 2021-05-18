include <parameters.scad>
use <donkey_bracket.scad>
use <util.scad>

//stationary_part();
module stationary_part(){
  difference(){
    scale([61.1/60.8,61.1/60.8,1])
      linear_extrude(height=7, convexity=6)
        scale(0.1550)
          for(i=[-1,0,1]){
        extra_wiggle_room = 0.2;
        wiggle_degs = i*extra_wiggle_room/(60.8/2)*(180/PI);
            rotate([0,0,-32-180+wiggle_degs])
              translate([-102,-151.5])
                import("./whitelabel_motor.svg");
      }
  for(ang=[0:90:359])
    rotate([0,0,ang+45])
      translate([29.6/2,0,-1])
        cylinder(d=3, h=10);
  }
}

module shaft(){
  translate([0,0,-20.2])
    cylinder(d=5, h=20.2 + 42);
}

module rotating_part(){
  difference() {
    translate([0,0,7.1])
      cylinder(d=60.8, h=28.7-7.1, $fn=100);
    translate([0,0,32]){
      rotate_extrude() {
        translate([22,0])
          rotate([0,0,-12])
            square([20, 10], center=true);
      }
    }
  }
}

//whitelabel_motor();
module whitelabel_motor(){
  color([0.4,0.4,1.0]) stationary_part();
  color("grey") shaft();
  color([0.6,0.6,1.0]) rotating_part();
}

//encoder();
module encoder(){
  difference(){
    union(){
      translate([-(33.8-27.6),-28.5/2,0])
      cube([34, 28.5, 8.9]);
      intersection(){
        cylinder(r=43.13-27.6, h=8.9,$fn=100);
        translate([-50,-28.5/2,-1])
          cube([100, 28.5, 10]);
      }
    }
  translate([0,0,-1])
    cylinder(d=13, h=10);
  }

  for(k=[0,1]){
    mirror([0,k,0]){
      difference(){
        hull(){
          translate([0,-52.4/2+3,0])
            cylinder(d=6, h=2.4, $fn=20);
          translate([-(33.8-27.6), -28.5/2, 0])
            cube([2*(33.8-27.6), 1, 2.4]);
        }
        translate([0,-45.5/2,-1])
          cylinder(d=3, h=5, $fn=10);
        translate([0,-32.5/2,-1])
          cylinder(d=3, h=5, $fn=10);
        translate([0,-32.5/2,0.5])
          cylinder(d=5, h=5, $fn=12);
      }
  }
  }
}


module erasor_cubes(cubesize) {
  // Erasor cubes
  translate([-50+7, -cubesize-1,-1])
    cube([50,50,50]);
  translate([-41,17,-1])
    cube([30,39,50]);
  translate([-51,-20,-1])
    cube([30,40,50]);
  translate([7,-cubesize/2,-1])
    inner_round_corner(r=2, h=12, $fn=24);
  translate([7,-cubesize/2+6,-1])
      rotate([0,0,-90])
      inner_round_corner(r=2, h=11, $fn=24);
  translate([-11,cubesize/2,-1])
      rotate([0,0,-90])
      inner_round_corner(r=2, h=11, $fn=24);
  translate([-10.8,cubesize/2-6.4,-1])
      rotate([0,0,10])
      inner_round_corner(r=1, h=11, ang=110, back=1, $fn=24);
}

//rotate([180,0,0])
//rotate([0,-90,0])
//%stationary_part();
//rotate([0,-90,0])
//  whitelabel_motor();
//translate([-33,0,0])
//rotate([90,0,-90])
//  encoder();
//rotate([180,0,0])


//translate([-2.5,0,0])
//rotate([0,90,0])
//motor_bracket();
module motor_bracket(leftHanded=false){
  cubesize = 60.8+6;

  difference(){
  //%translate([-32,0,0])
    //  rotate([0,90,0])
    //    donkey_face();
  translate([-cubesize/2,-cubesize/2,0])
    cube([cubesize, cubesize,9]);
  difference(){
    translate([0,0,-1])
      cylinder(d=60.8-3,h=50, $fn=100);
    difference(){
      union(){
        for(k=[0,1]) {
          mirror([0,k,0]) {
            translate([-15,-4-29.6/(2*sqrt(2)),0])
              rounded_cube2([cubesize, 8, 20],2,$fn=6*4);
            translate([23.6,-29.6/(sqrt(8))-4.6,-1])
                rotate([0,0,166])
                inner_round_corner(r=2, h=10, ang=131, back=2, $fn=10*4);
            translate([28.49,-29.6/(sqrt(8))+3.95,-1])
                rotate([0,0,90])
                inner_round_corner(r=2, h=10, ang=74, back=2, $fn=10*4);
            rotate([0,0,57])
              rotate_extrude(angle=68, $fn=100)
                translate([GT2_motor_gear_outer_dia/2+1,0])
                  square([8,9]);
          }
        }
        for(k=[0,1])
          for(l=[0,1])
            mirror([k,0,0])
              mirror([0,l,0])
                rotate([0,0,58])
                  translate([GT2_motor_gear_outer_dia/2+1+8,0,0])
                    rotate([0,0,-51/2])
                      translate([-0.235,-0.235,0])
                        inner_round_corner(r=2, h=10, ang=28, $fn=20*4);
      }
      cylinder(d=GT2_motor_gear_outer_dia+2, h=52, $fn=100);
      for(k=[0,1])
        for(l=[0,1])
          mirror([k,0,0])
            mirror([0,l,0])
              rotate([0,0,46])
                translate([GT2_motor_gear_outer_dia/2+1,0,0])
                  rotate([0,0,-44/2])
                    translate([-0.34,-0.34,0])
                      inner_round_corner(r=2, h=10, ang=45, $fn=10*4);
    }
  }
  if (leftHanded) {
    rotate([0,0,180])
      mirror([1,0,0])
        translate([0,0,-7+2.5])
          stationary_part();
  } else {
    mirror([1,0,0])
      translate([0,0,-7+2.5])
        stationary_part();
  }
  translate([0,0,-7+2.5])
    cylinder(d=55, h=7);


  if (leftHanded) {
    mirror([0,1,0])
    erasor_cubes(cubesize);
  } else {
    erasor_cubes(cubesize);
  }

  // Remove overhang for ease of printing upright
  if (leftHanded) {
    translate([7.075,-29.720,-0.5])
      rotate([0,0,45])
          cube(3);
  } else {
    translate([8.555,29.285,-0.5])
      rotate([0,0,45])
        translate([-3, -3, 0])
          cube(3);
  }


  // Screw holes
  for(ang=[0:90:359])
    rotate([0,0,ang+45]) {
      translate([29.6/2,0,-1])
        cylinder(d=3.24, h=10, $fn=8);
      translate([29.6/2,0,2.5+4])
        cylinder(d=5.8, h=10,$fn=20);
      }
  }
  difference(){
    translate([33, -90/2, -6])
      rotate([90,0,90])
        ydir_rounded_cube2([90, 15, 2], 3, $fn=5*4);
    for(k=[0,1]) {
      mirror([0,k,0]){
        translate([32.2,90/2-3.5,15-3.5-6]){
          rotate([0,90,0]){
            cylinder(d2=3,d1=6, h=2.2,$fn=10);
            cylinder(d=3, h=3,$fn=10);
          }
    }
      }
    }
  }
  difference(){
    translate([33,0,0])
      rotate([0,180,0])
        rotate([90,0,0])
          translate([0,0,-75/2])
            inner_round_corner(r=2, h=75, $fn=10*4);

    for(k=[0,1])
      mirror([0,k,0])
        translate([0,24.40,9])
          rotate([45,0,0])
            translate([0,0,-50])
              cube(50);
  }

  for(k=[0,1])
    mirror([0,k,0])
      intersection() {
        translate([33,cubesize/2,-3])
          rotate([0,0,90])
            inner_round_corner(r=2, h=12, ang=90, $fn=10*4);
        translate([0,24.4,9])
          rotate([45,0,0])
            translate([0,0,-50])
              cube(50);
  }
}


translate([0,0,35]){
  translate([-2.5+33,0,0])
  rotate([0,90,0])
  motor_bracket();
  //translate([33,0,0])
  //%import("../stl/whitelabel_motor.stl");
  //!rotate([0,90,0])
  translate([4.5,0,0])
  rotate([0,0,2*90])
  encoder_bracket();
}
module encoder_bracket() {
  difference() {
    rotate([0,90,0]) {
      difference(){
        union(){
          translate([33, -90/2, -20.5])
            rotate([90,0,90])
              ydir_rounded_cube2([90, 25, 2], 3, $fn=5*4);
          translate([16,-20/2,-2.5])
            difference(){
              left_rounded_cube2([18, 20, 7], 3, $fn=5*4);
              translate([-1,-1,4])
                rotate([0,11,0])
                  translate([0,0,-50])
                    cube(50);

            }
          intersection(){
            translate([33,0,0])
              rotate([90,-180,0])
                translate([0,1.66,-25/2])
                  inner_round_corner(r=2, h=25, $fn=10*4, ang=90-11, center=false);
            translate([0,0,-50*sqrt(2)+8.4])
              rotate([45,0,0])
                cube(50);
          }
          difference(){
            for(k=[0,1])
              mirror([0,k,0])
                translate([33,20/2,0])
                    rotate([0,0,90])
                    translate([0,0,-6.5])
                      inner_round_corner(r=2, h=9+2, $fn=10*4, center=false);
            translate([0,0,-50*sqrt(2)+8.4])
              rotate([45,0,0])
                cube(50);
          }
        }
        for(k=[0,1]) {
          mirror([0,k,0]){
            translate([32.2,90/2-3.5,3.5-5/2]){
              rotate([0,90,0]){
                cylinder(d2=3,d1=6, h=2.2,$fn=10);
                cylinder(d=3, h=3,$fn=10);
              }
            }
          }
        }
      }
    }
    translate([0.1,0,0])
      rotate([90,0,-90]) {
        translate([0,-45.5/2,-5])
          hull(){
            translate([0,3,0])
              cylinder(d=3.1, h=16, $fn=10);
            translate([0,-1,0])
              cylinder(d=3.1, h=16, $fn=10);
          }
        translate([0,-45.5/2,-0.4-2])
          hull(){
            translate([0,3,0])
              rotate([0,0,30])
                cylinder(d=6.2, h=5, $fn=6);
            translate([0,-1,0])
              rotate([0,0,30])
                cylinder(d=6.2, h=5, $fn=6);
          }
    }
  }
}
