
line_length_tuner_hook();
module line_length_tuner_hook(){
  d = 6;
  opening = 3;
  h = 10;
  $fn = 30;
  difference()
  {
    union(){
      cylinder(d = d, h = h);
      translate([-opening - 1,0,d/2 + opening - 3])
        rotate([-90,0,0])
          rotate_extrude(angle=200)
            translate([opening,0,0])
              circle(d=d-2);
    }
    translate([0,0,-20])
      cube(40, center=true);
    translate([0,0,-1])
    cylinder(d=3.7, h = h - 1);
  }
}
