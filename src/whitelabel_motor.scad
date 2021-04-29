use <donkey_bracket.scad>
use <util.scad>

module stationary_part(){
  difference(){
    linear_extrude(height=7, convexity=6)
      scale(0.1550)
        rotate([0,0,-32-180])
          translate([-102,-151.5])
            import("./whitelabel_motor.svg");
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

//rotate([0,-90,0])
//  %whitelabel_motor();
//translate([-33,0,0])
//rotate([90,0,-90])
//  encoder();


//translate([-2.5,0,0])
//  rotate([0,90,0])
motor_bracket();
module motor_bracket(){
  cubesize = 60.8+6;

  difference(){
  //%translate([-32,0,0])
    //  rotate([0,90,0])
    //    donkey_face();
  translate([-cubesize/2,-cubesize/2,0])
    cube([cubesize, cubesize,20]);
  difference(){
    translate([0,0,-1])
      cylinder(d=60.8-3,h=50, $fn=100);
    for(k=[0,1])
      mirror([0,k,0]) {
        translate([-15,-4-29.6/(2*sqrt(2)),0])
          rounded_cube2([cubesize, 8, 20],2,$fn=6*4);
        translate([23.6,-29.6/(sqrt(8))-4.6,-1])
            rotate([0,0,166])
            inner_round_corner(r=2, h=10, ang=131, back=2, $fn=10*4);
        translate([28.49,-29.6/(sqrt(8))+3.95,-1])
            rotate([0,0,90])
            inner_round_corner(r=2, h=10, ang=74, back=2, $fn=10*4);
      }
  }
    mirror([1,0,0])
      translate([0,0,-7+2.5])
        stationary_part();

  // Erasor cubes
  translate([-50+7, -cubesize+0,-1])
    cube([50,50,50]);
  translate([-41,17,-1])
    cube([30,39,50]);
  translate([-51,-20,-1])
    cube([30,40,50]);
  translate([7,-cubesize/2,-1])
    inner_round_corner(r=2, h=10, $fn=24);
  translate([7,-cubesize/2+6,-1])
      rotate([0,0,-90])
      inner_round_corner(r=2, h=10, $fn=24);
  translate([-11,cubesize/2,-1])
      rotate([0,0,-90])
      inner_round_corner(r=2, h=10, $fn=24);
  translate([-10.8,cubesize/2-6.4,-1])
      rotate([0,0,10])
      inner_round_corner(r=1, h=10, ang=110, back=1, $fn=24);

  // Big flat front slant cube
  translate([-cubesize/2,-cubesize/2-1,1])
    rotate([0,-7,0])
      cube([cubesize+6, cubesize+2,20]);

  // Screw holes
  for(ang=[0:90:359])
    rotate([0,0,ang+45]) {
      translate([29.6/2,0,-1])
        cylinder(d=3.01, h=10);
      translate([29.6/2,0,3.5])
        cylinder(d=5.8, h=10);
      }
  }
  difference(){
    translate([33, -90/2, 0])
    rotate([90,0,90])
        rounded_cube2([90, 15, 2],3);
  for(k=[0,1]) {
    mirror([0,k,0]){
      translate([32.2,90/2-3.5,3.5])
        rotate([0,90,0]){
          cylinder(d2=3,d1=6, h=2.2,$fn=10);
          cylinder(d=3, h=3,$fn=10);
          }
      translate([32.2,90/2-3.5,15-3.5])
        rotate([0,90,0]){
          cylinder(d2=3,d1=6, h=2.2,$fn=10);
          cylinder(d=3, h=3,$fn=10);
          }
      }
      }
  }
  difference(){
    translate([33.02,0,8.91])
      rotate([90,-90,0])
        translate([0,0,-75/2])
          inner_round_corner(r=2, h=75, ang=83, $fn=5*4);

    for(k=[0,1])
    mirror([0,k,0])
        translate([0,24.5,0])
        rotate([45,0,0])
          translate([0,0,-50])
            cube(50);
  }

  for(k=[0,1])
    mirror([0,k,0])
      intersection() {
        translate([33,cubesize/2,0])
          rotate([0,0,90])
            inner_round_corner(r=2, h=12, ang=90, $fn=5*4);
        translate([0,24.5,0])
        rotate([45,0,0])
          translate([0,0,-50])
            cube(50);
  }
}
