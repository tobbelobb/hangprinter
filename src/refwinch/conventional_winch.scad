include <conventional_guide/self_reversing_thread_bosl2.scad>
include <../lib/parameters.scad>
include <../lib/util.scad>
include <../lib/gears.scad>
include <../lib/gear_util.scad>

stroke = 42;
rod_l = stroke + 2*7 + 2*b608_width;
echo("rod_l", rod_l);
rod_d = 11;

module grooved_rod(){
    self_reversing_grooved_rod(
      rod_d=rod_d,
      rod_l= stroke+5,
      stroke=stroke,
      turns_per_stroke=4,
      cycles=1,
      groove_d=1.8,
      groove_depth=1.75,
      samples_per_turn=120,
      reversal_frac=0.250
  );
}

//pawl();
module pawl(){
  intersection(){
  color("orange")
    self_reversing_follower_pawl(
        rod_d=rod_d,
        stroke=stroke,
        turns_per_stroke=4,
        groove_d=1.8,
        groove_depth=1.75,
        half_index=0,
        q_center=0.5,
        angular_span=125,
        samples_per_turn=120,
        reversal_frac=0.250
    );
  rotate([53,0,0])
    self_reversing_follower_pawl(
        rod_d=rod_d,
        stroke=stroke,
        turns_per_stroke=4,
        groove_d=1.8,
        groove_depth=1.75,
        half_index=1,
        q_center=0.5,
        angular_span=125,
        samples_per_turn=120,
        reversal_frac=0.250
    );
  }
}

//%translate([0,0,2.835])
//   rotate([0,0,90])
//   grooved_rod();

gear_th = 8;
module torx_thing(gear_th=8){
  intersection(){
    for(ang=[0:360/6:359])
      rotate([0,0,ang])
        translate([3,0,0])
        cylinder(d=3.2,h=gear_th);
      cylinder(d=8,h=gear_th);
  }
  cylinder(d=6.4,h=gear_th);

}

//!rotate([180,0,0])
//full_shaft();
module full_shaft(){
  union(){
    grooved_rod();
    for(k=[0,1]) mirror([0,0,k]) {
      translate([0,0,-rod_l/2-1-0.5])
        cylinder(d=8, h=b608_width+1+0.5);
      translate([0,0,-rod_l/2 + b608_width-0.5])
        cylinder(d1=8, d2 = rod_d, h=rod_l/2 - b608_width - (stroke+5)/2 + 0.5);
    }
    translate([0,0,-rod_l/2-gear_th-1-1-2])
    torx_thing(gear_th+2.5);
  }

  //for(k=[0,1]) mirror([0,0,k])
  //  translate([0,0,-rod_l/2-0.5])
  //  b608();
}

//helix_gear_big();
module helix_gear_big(
  modul=1,
  tooth_number=63, // (2/10.5)*63. 2 is max line width. 10.5 is diamond groove pitch. 63 is the number of teeth needed to match the small gears' 12 teeth.
  width=8,
  bore=12,
  pressure_angle=20,
  helix_angle=45
){
  for(k=[0,1]) mirror([0,0,k])
  spur_gear(
    modul=modul,
    tooth_number=tooth_number,
    width=width/2,
    bore=bore,
    pressure_angle=pressure_angle,
    helix_angle=helix_angle,
    optimized=true
  );
  tol = 0.3;
  torx_thing_w = 6.4;
  s = (torx_thing_w+tol)/torx_thing_w;
  difference() {
    cylinder(d=13, h=width, center=true);
    translate([0,0,-(width+2)/2])
    scale([s,s,1])
    torx_thing(width+2);
  }
}

//helix_gear_small();
module helix_gear_small(
  modul=1.0,
  tooth_number=12,
  width=8+1,
  bore=0,
  pressure_angle=20,
  helix_angle=45
){
  for(k=[0,1]) mirror([0,0,k])
  spur_gear(
    modul=modul,
    tooth_number=tooth_number,
    width=width/2,
    bore=bore,
    pressure_angle=pressure_angle,
    helix_angle=helix_angle,
    optimized=false
  );
}

//guide_rods();
module guide_rods(tol=0.1){
  rod_d = 3.2;
  for (dist=[0,10])
    translate([0,0,-14-dist])
    rotate([0,90,0])
    color("gray") {
    cylinder(d=rod_d+tol, h=rod_l+3, center=true);
  }
}

module line_entry(){
  translate([0,0,-19])
    rotate([90,0,0])
    cylinder(d=Eyelet_diameter, h=30, center=true);
}

pawl_cylinder_d=9;
pawl_cylinder_h=20;
//cut_pawl();
module cut_pawl(){
  intersection(){
    translate([0,0,rod_d/2])
    rotate([0,90,26.5])
      pawl();
    translate([0,0,-5])
      cylinder(d=rod_d, h=12);
    down(4)
      cube(13, center=true);
  }
  difference() {
    translate([0,0,-pawl_cylinder_h-1])
      cylinder(d=pawl_cylinder_d, h=pawl_cylinder_h);
    for(ang=[-26.5:3:26.5]) rotate([0,0,ang]) {
      translate([0,0,6]){
        line_entry();
        guide_rods(tol=0.5);
      }
    }
  }
}


leg_depth = b608_outer_dia + 2*3;
push_legs_up = 3; // base thickness (=3) is max
leg_height = 50;
//base();
module base(){
  difference(){
    for(k=[0,1]) mirror([k,0,0])
      translate([-rod_l/2-0.51,-leg_depth/2,-leg_height+leg_depth/2])
      difference(){
        translate([0,0,push_legs_up])
          top2_rounded_cube2([b608_width, leg_depth, leg_height],3);
        translate([(b608_width)/2, leg_depth/2,leg_height-leg_depth/2])
          rotate([0,90,0])
          hull(){
            cylinder(d=b608_outer_dia+0.2, h=b608_width+10, center=true);
            translate([-(b608_outer_dia+0.2)/2,0,0])
              cylinder(d=4, h=b608_width+10, center=true);
          }
      }
    guide_rods();
  }
  translate([-76/2,-60+2*3.4,-leg_height+leg_depth/2])
    rounded_cube2([76, 75.6-2*3.4, 3], 0);
  translate([-76/2,-60+2*3.35,-leg_height+leg_depth/2])
    rounded_cube2([97.1, 31.2, 3], 0);
  // Inner rounded corners
  //for(k=[0,1]) for(l=[0,1]) mirror([k, 0, 0]) mirror([0,l,0])
  //  translate([rod_l/2+0.51,leg_depth/2,-leg_height+leg_depth/2+3])
  //  rotate([0,-90,0])
  //  translate([0,0,-2])
  //  difference(){
  //    inner_round_corner(r=2, h=b608_width+4);
  //    translate([-1,0,2])
  //      rotate([-45,0,0])
  //      translate([0,-1,-10])
  //      cube(10);
  //    translate([-1,0,b608_width+2])
  //      rotate([45,0,0])
  //      cube(10);
  //  }
  //  for(l=[0,1]) mirror([l,0,0])
  //  translate([-(rod_l/2+0.51),leg_depth/2,-leg_height+leg_depth/2+3])
  //  for(k=[0,1]) translate([k*b608_width,0,0]) mirror([k,0,0])
  //  rotate([90,-90,0])
  //  translate([0,0,-2])
  //  difference(){
  //    inner_round_corner(r=2, h=leg_depth+4);
  //    translate([-1,0,2])
  //      rotate([-45,0,0])
  //      translate([0,-1,-10])
  //      cube(10);
  //    translate([-1,0,leg_depth+2])
  //      rotate([45,0,0])
  //      cube(10);
  //  }

  for(xs=[-rod_l/2-0.51, 43+5+2])
    translate([xs,-leg_depth/2 - (37.5 + gear_backlash_tol),-leg_height+leg_depth/2])
    difference(){
      translate([0,0,push_legs_up])
        top2_rounded_cube2([b608_width, leg_depth, leg_height],3);
      translate([(b608_width)/2, leg_depth/2,leg_height-leg_depth/2])
        rotate([0,90,0])
        hull(){
          cylinder(d=b608_outer_dia+0.2, h=b608_width+10, center=true);
          translate([-(b608_outer_dia+0.2)/2,0,0])
            cylinder(d=4, h=b608_width+10, center=true);
        }
    }
}

//base_sides();
module base_sides(){
  skirt = 0;
  difference(){
    translate([rod_l/2-8,-leg_depth/2,-leg_height+leg_depth/2+2])
      translate([0,0,push_legs_up])
        difference(){
          translate([0,-1.5,-2 + skirt])
            top2_rounded_cube2([b608_width+4, leg_depth+3, leg_height-skirt],3);
          translate([2-0.5,0,-2 - 1])
            top2_rounded_cube2([b608_width+0.5, leg_depth, leg_height+5],3);
          translate([2-5,1,-2-1])
            top2_rounded_cube2([b608_width+5, leg_depth-2, leg_height+5],3);
        }
    rotate([0,90,0])
      hull() {
        cylinder(d=13, h=50);
        translate([-7,0,0])
          cylinder(d=2, h=50);
      }
    for(k=[0,1]) mirror([0,k,0])
      translate([rod_l/2-8,-leg_depth/2-0.25,push_legs_up-leg_height+leg_depth/2-1])
      rotate([0,0,45])
      cube([3,3,leg_height+10]);
  }
}

//translate([21.1,0,0])
//sock();
module sock(){
  difference(){
    translate([0,0,-pawl_cylinder_h-7-2])
      cylinder(d=pawl_cylinder_d + 5, h=pawl_cylinder_h);
    translate([0,0,-pawl_cylinder_h-7-2])
      translate([0,0,2])
      cylinder(d=pawl_cylinder_d+0.5, h=pawl_cylinder_h);
    guide_rods(tol=0.25);
    line_entry();
  }
}

gear_backlash_tol = 0.2;
translate([0,37.5 + gear_backlash_tol,0]) // Big gear pitch = 63/2, Small gear pitch = 12/2. Total pitch = 37.5
drive_train_assembly();
module drive_train_assembly(){
  rotate([0,-90,0]) {
    rotate([0,0,180]){
      translate([0,0,-21.1])
      rotate([-20,0,0])
      translate([6,0,0])
      rotate([0,-90,0])
        cut_pawl();
      full_shaft();
    }
    translate([0,0,-rod_l/2-gear_th/2-1-1-2])
      helix_gear_big();
  }
  base();
  translate([21.1,0,0])
    sock();
  //for(k=[0,1]) mirror([k,0,0])
  //  base_sides();
  //translate([21,-37.5 - gear_backlash_tol])
  //  base_sides();
  //mirror([1,0,0])
  //  translate([0,-37.5 - gear_backlash_tol])
  //  base_sides();
  translate([0,-(37.5 + gear_backlash_tol),0]) // Big gear pitch = 63/2, Small gear pitch = 12/2. Total pitch = 37.5
  drum();
  translate([57.1,0,0])
    translate([0,-(37.5 + gear_backlash_tol),0]) // Big gear pitch = 63/2, Small gear pitch = 12/2. Total pitch = 37.5
    drum_shaft();
  translate([0,-(37.5 + gear_backlash_tol),0]) // Big gear pitch = 63/2, Small gear pitch = 12/2. Total pitch = 37.5
  rotate([0,90,0])
    translate([0,0,stroke/2+6.4])
    rotate([0,0,12])
    sep_disc(dia=60, r_drum=r_drum, depth=1.5, tooth_width_ang=10, height=1.2, center=true, $fn=64);
}



//!sep_disc();
module sep_disc(dia=60, r_drum=20, depth=0.8, tooth_width_ang=9, height = 1, center=false){
  difference(){
    cylinder(d = dia, h = height, $fn=64, center=center);
    translate([0,0,-1]){
      cylinder(r = r_drum - depth, h = 3, $fn=100);
      for(v=[0:30:359])
        rotate([0,0,v]) {
          p = circle_sector(r0=1, r1=r_drum+0.2, max_ang=30-tooth_width_ang);
          rotate([0,0,+tooth_width_ang/2+15])
          linear_extrude(height=3) polygon(points=p);
          for(a=[tooth_width_ang/2,-tooth_width_ang/2])
            rotate([0,0,15+a])
            translate([-0.5/2,0,0])
              cube([0.5,(r_drum+dia/2)/2,3]);
        }
    }
  }
}


// 22.7 gives four layers of 2 mm thick line on a 42 mm drum fits 12000 mm of line.
//r_drum = 22.7;
// However to get an effective radius of 22.7 over this range of wind in we need a smaller base radius.
r_drum = 20;
// 30.315 gives three layers of 2 mm thick line on a 42 mm drum fits 12000 mm of line.
//r_drum = 30.315;
//rotate([0,-90,0])
//drum();
module drum(){
  difference(){
  difference(){
    rotate([0,90,0]) {
      union(){
        cylinder(r=r_drum, h=stroke + 2*7, center=true, $fn=64);
        // GT2 pulley, mounted immediately outboard of the small helical gear.
        translate([0,0,(stroke+2*7)/2 + 0])
          GT2_2mm_pulley_extrusion(GT2_belt_width+2, 63);
      }
      translate([0,0,43])
        rotate([0,0,7])
        helix_gear_small();
      cylinder(d=14, h=38.5, $fn=64);
      translate([0,0,-(stroke/2+6.5)])
        cylinder(d=60, h=1, center=true, $fn=64);
    }
    rotate([0,90,0])
    translate([0,0,11])
      cylinder(d=8, h=75, $fn=64, center=true);
    rotate([0,90,0])
    translate([0,0,-stroke/2-3])
      cylinder(r=r_drum-2, h=50, $fn=64, center=false);
    rotate([0,90,0])
    translate([0,0,-stroke/2-3+50])
      cylinder(r2=8/2, r1=r_drum-2, h=10, $fn=64, center=false);
    rotate([0,90,0])
      translate([0,0,stroke/2+6.4])
      rotate([0,0,12])
      sep_disc(dia=60, r_drum=r_drum, depth=1.5, tooth_width_ang=10, height=1.2, center=true, $fn=64);
  }
  //translate([-50,-100,-50])
  //  cube(100);

  }
  translate([50,0,0]) rotate([0,90,0]) b608();
  translate([-35.55,0,0]) rotate([0,90,0]) b608();
}

//drum_shaft();
module drum_shaft(){
  rotate([-90,0,0])
  rotate([0,-90,0])
    difference(){
      cylinder(d=7.9, h=92.6);
      translate([-50,3.3,0])
        cube(100);
    }
}
