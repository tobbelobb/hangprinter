include <parameters.scad>
use <sweep.scad>
use <util.scad>

//%prev_art();
module prev_art(){
  translate([0,-Wall_th-Beam_width/2,25])
    import("../stl/corner_clamp.stl");
}

corner_clamp();
module corner_clamp(){
  little_r = 3/2;
  big_r = 9.35;
  step = 3;
  l = 72.75;
  wall_th = Wall_th;

  module flerp(){
    difference(){
      rotate([90,0,0])
        sweep(my_rounded_eqtri(l,big_r, step=step),
            [for(i=[-little_r:2*little_r/20:little_r])
            scaling([1+little_r*sqrt(1-i*i/(little_r*little_r))/(l*sqrt(3)/6),
              1+little_r*sqrt(1-i*i/(little_r*little_r))/(l*sqrt(3)/6), 1])
            * translation([0,0,i])
            * translation([-l/2,-l*sqrt(3)/6,0])
            ]);
      translate([0,0,-10])
        cube([l, 30, 38+2*10], center=true);
      translate([0,0,30])
        rotate([90,0,0])
        cylinder(r=1.5, h=2*little_r+2, center=true, $fs=1);
    }
  }

  w = 52;
  d = Beam_width + 2*wall_th;
  height = 20;
  little_r2 = 1.4;
  hup = height-little_r2;
  bts = 1-(hup/sqrt(3))/(w/2); // bottom-top (hup) -scaling
  l0 = w/2*bts;

  module main_block(){
    path0 = [translation([-w/2,-d/2,0]),
              scaling([bts,1,1])
              * translation([-w/2,-d/2,hup])];

    // Just round off top edges
    path1 = [for(i=[0.02:0.01-(0.02/10):1])
              scaling([1-(1-sqrt(1-i*i))*little_r2/l0,
              1 - (1-sqrt(1-i*i))*little_r2/(d/2), 1])
              * scaling([1-((hup+i*little_r2)/sqrt(3))/(w/2),1,1])
              * translation([-w/2,-d/2,hup+i*little_r2])
              ];

    sweep(my_rounded_square([w,d], little_r2),
      concat(path0,path1));
  }

  incoming_depth = hup*2/sqrt(3);
  module incoming_beam(){
    translate([w/2-wall_th-0.1,0,0])
      rotate([0,60,0])
      translate([-incoming_depth,-Fat_beam_width/2,-Fat_beam_width])
      fat_beam(30);
  }

  difference(){
    main_block();
    incoming_beam();
    mirror([1,0,0])
      incoming_beam();
    cube([Beam_width, Fat_beam_width-2*1.875, 2*(hup-Fat_beam_width/2)], center=true);
    translate([0,0,3])
      rotate([90,0,0])
      cylinder(r = 3.5/2, h=d+2, center=true, $fs=1);
    for(i=[1,-1])
      translate([i*12.1,0,7])
        rotate([90,0,0])
        cylinder(r = 3.5/2, h=d+2, center=true, $fs=1);
  }
  flerp();

}
