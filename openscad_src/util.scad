include <parameters.scad>

//!rounded_cube([40,61,42], 8, center=true);
module rounded_cube(v, r, center=false){
  fn = 4*14;
  v = (v[0] == undef) ? [v, v, v] : v;
  obj_translate = center ?
    [-(v[0] / 2), -(v[1] / 2),	-(v[2] / 2)] : [0, 0, 0];
  d = 2*r;

  //!frame();
  module frame(){
    xy_corners = [[0, 0, 0], [v[0]-d, 0, 0], [v[0]-d, v[1]-d, 0], [0, v[1]-d, 0]];
    translate([r,r,r])
    for(i=[0:3]){
      l = i%2 == 0 ? v[0] - d : v[1] - d;
      translate(xy_corners[i]){
        rotate([0,0,90*i]){
          translate([0,0,-0.005])
          cylinder(r=r, h=v[2]-d+0.01, $fn = fn);
          for(j=[0,v[2]-d]){
            translate([0,0,j]){
              sphere(r, $fn = fn);
              rotate([0,90,0])
                rotate([0,0,0.5*360/fn])
                translate([0,0,-0.005])
                cylinder(r=r, h=l+0.01, $fn = fn);
            }
          }
        }
      }
    }
  }

  //!core();
  module core(){
    //translate([r, r, 0]){
    //  cube([v[0] - d, v[1] - d, v[2]]);
    //}
    //translate([r, 0, r]){
    //  cube([v[0] - d, v[1], v[2] - d]);
    //}
    //translate([0, r, r]){
    //  cube([v[0], v[1] - d, v[2] - d]);
    //}
    translate([r-0.005, r-0.005, 0]){
      cube([v[0] - d+0.01, v[1] - d+0.01, v[2]]);
    }
    translate([r-0.005, 0, r-0.005]){
      cube([v[0] - d+0.01, v[1]+0.01, v[2] - d]);
    }
    translate([0, r-0.005, r-0.005]){
      cube([v[0], v[1] - d+0.01, v[2] - d+0.01]);
    }
  }

  translate(obj_translate){
    union(){
      core();
      frame();
    }
  }
}

//rounded_cube2([20,30,2], 2);
module rounded_cube2(v, r){
  $fs = 1;
  if(v[2]){
    union(){
      translate([r,0,0])           cube([v[0]-2*r, v[1]    , v[2]]);
      translate([0,r,0])           cube([v[0]    , v[1]-2*r, v[2]]);
      translate([r,r,0])           cylinder(h=v[2], r=r);
      translate([v[0]-r,r,0])      cylinder(h=v[2], r=r);
      translate([v[0]-r,v[1]-r,0]) cylinder(h=v[2], r=r);
      translate([r,v[1]-r,0])      cylinder(h=v[2], r=r);
    }
  } else {
    union(){
      translate([r,0])           square([v[0]-2*r, v[1]    ]);
      translate([0,r])           square([v[0]    , v[1]-2*r]);
      translate([r,r])           circle(r=r);
      translate([v[0]-r,r])      circle(r=r);
      translate([v[0]-r,v[1]-r]) circle(r=r);
      translate([r,v[1]-r])      circle(r=r);
    }
  }
}

//right_rounded_cube2([20,30,2], 2);
module right_rounded_cube2(v, r){
  $fs = 1;
  union(){
                                 cube([v[0]-r, v[1]    , v[2]]);
    translate([0,r,0])           cube([v[0]    , v[1]-2*r, v[2]]);
    translate([v[0]-r,r,0])      cylinder(h=v[2], r=r);
    translate([v[0]-r,v[1]-r,0]) cylinder(h=v[2], r=r);
  }
}

//left_rounded_cube2([20,30,2], 2);
module left_rounded_cube2(v, r){
  $fs = 1;
  union(){
    translate([r,0,0])           cube([v[0]-  r, v[1]    , v[2]]);
    translate([0,r,0])           cube([v[0]    , v[1]-2*r, v[2]]);
    translate([r,r,0])           cylinder(h=v[2], r=r);
    translate([r,v[1]-r,0])      cylinder(h=v[2], r=r);
  }
}

//one_rounded_cube2([20,30,2], 2);
module one_rounded_cube2(v, r){
  $fs = 1;
  translate([r,0,0]) cube([v[0]-  r, v[1]  , v[2]]);
  translate([0,r,0]) cube([v[0]   , v[1]-r, v[2]]);
  translate([r,r,0]) cylinder(h=v[2], r=r);
}

module one_rounded_cube3(v, r){
  translate([0,0,0])           cube([v[0]-  r, v[1]  , v[2]]);
  translate([0,0,0])           cube([v[0]   , v[1]-r, v[2]]);
  translate([v[0]-r,v[1]-r,0]) cylinder(h=v[2], r=r);
}

module one_rounded_cube4(v, r){
  translate([0,0,0])      cube([v[0]-  r, v[1]  , v[2]]);
  translate([0,r,0])      cube([v[0]   , v[1]-r, v[2]]);
  translate([v[0]-r,r,0]) cylinder(h=v[2], r=r);
}


//three_rounded_cube2([20,30,2], 2);
module three_rounded_cube2(v, r){
  $fs = 1;
  union(){
    translate([0,0,0])          cube([v[0]-  r, v[1]-r    , v[2]]);
    translate([r,0,0])           cube([v[0]-2*r, v[1]    , v[2]]);
    translate([0,r,0])           cube([v[0]    , v[1]-2*r, v[2]]);
    translate([v[0]-r,r,0])      cylinder(h=v[2], r=r);
    translate([v[0]-r,v[1]-r,0]) cylinder(h=v[2], r=r);
    translate([r,v[1]-r,0])      cylinder(h=v[2], r=r);
  }
}

//three_rounded_cube3([20,30,2], 2);
module three_rounded_cube3(v, r){
  $fs = 1;
  union(){
    translate([r,0,0])           cube([v[0]-2*r, v[1]    , v[2]]);
    translate([0,r,0])           cube([v[0]    , v[1]-2*r, v[2]]);
    translate([r,r,0])           cube([v[0]-r , v[1]-  r, v[2]]);
    translate([r,r,0])           cylinder(h=v[2], r=r);
    translate([v[0]-r,r,0])      cylinder(h=v[2], r=r);
    translate([r,v[1]-r,0])      cylinder(h=v[2], r=r);
  }
}

module rounded_square(v, r){
  union(){
    translate([r,0])           square([v[0]-2*r, v[1]]);
    translate([0,r])           square([v[0], v[1]-2*r]);
    translate([r,r])           circle(r);
    translate([v[0]-r,r])      circle(r);
    translate([v[0]-r,v[1]-r]) circle(r);
    translate([r,v[1]-r])      circle(r);
  }
}


module beam(l, standing = false){
  v = standing ? [Beam_width, Beam_width, l] : [l, Beam_width, Beam_width];
  cube(v);
}

module fat_beam(l, standing = false){
  v = standing ? [Fat_beam_width, Fat_beam_width, l] : [l, Fat_beam_width, Fat_beam_width];
  cube(v);
}

//standing_ls_tri(10, 20);
module standing_ls_tri(l, h){
  difference(){
  cube([l,l,h]);
  translate([l,0,0])
    rotate([0,0,45])
    translate([0,0,-1])
    cube([l*sqrt(2),l*sqrt(2),h+2]);
  }
}

function my_square(v) = [[-v[0]/2, -v[1]/2],
                         [ v[0]/2, -v[1]/2],
                         [ v[0]/2,  v[1]/2],
                         [-v[0]/2,  v[1]/2]];

function my_rounded_square(v, r, step=7.5) = [
  for (i=[0:step:360])
    i < 90 ?
    [r,r] - r*[cos(i), sin(i)] :
    i < 180 ?
    [v[0]-r,r] - r*[cos(i), sin(i)] :
    i < 270 ?
    [v[0]-r,v[1]-r] - r*[cos(i), sin(i)] :
    [r,v[1]-r] - r*[cos(i), sin(i)]];

function my_rounded_eqtri(l, r, step=3) = [
  for (i=[-30:step:360-30.01])
    (i < 120 - 30) ?
    [r*sqrt(3),r] - r*[cos(i), sin(i)] :
    (i < 240 - 30) ?
    [l-r*sqrt(3),r] - r*[cos(i), sin(i)] :
    [l/2,sqrt(3)*l/2-r*2] - r*[cos(i), sin(i)]];

module rounded_2corner(v, r){
  v = (v[0] == undef) ? [v, v] : v;
  square([v[0]-r,v[1]]);
  translate([0,r])
    square([v[0],v[1]-2*r]);
  translate([v[0]-r, r])
    circle(r=r,$fs = 1);
  translate([v[0]-r, v[1]-r])
    circle(r=r,$fs = 1);
}

module Nema17_screw_translate(corners){
  for (i=[0:90:90*corners - 1]){
    rotate([0,0,i+45])
      translate([Nema17_screw_hole_width/2,0,0])
        rotate([0,0,-i-45])
          children();
  }
}

module Nema17_screw_holes(d, h, corners=4, teardrop=false){
  Nema17_screw_translate(corners)
    if(teardrop)
      teardrop(r=d/2,h=h);
    else
      cylinder(r=d/2,h=h);
}

module centered_u_groove_bearing(){
  translate([1.5,-32,0])
    import("U-groove_bearing.stl");
}

// Looks best with $fn = n*8
//round_end([45,41,8]);
module round_end(v){
  v = (v[0] == undef) ? [v, v] : v;
  cube([v[0]-v[1]/2, v[1], v[2]]);
  translate([v[0]-v[1]/2, v[1]/2,0])
    cylinder(d=v[1], h=v[2]);
}

//round_ends([56,41,8]);
module round_ends(v){
  v = (v[0] == undef) ? [v, v] : v;
  translate([v[1]/2,0,0])
    cube([v[0]-v[1], v[1], v[2]]);
  translate([v[0]-v[1]/2, v[1]/2,0])
    cylinder(d=v[1], h=v[2]);
  translate([v[1]/2, v[1]/2,0])
    cylinder(d=v[1], h=v[2]);
}

// Looks best with $fn = n*4
//quarterround_wall([10,20,50,20]);
module quarterround_wall(v){
  v = (v[0] == undef) ? [v, v] : v;
  cube([v[0], v[1], v[2]-v[0]]);
  translate([v[0],0,v[2]-v[0]])
  difference(){
    rotate([-90,0,0])
      cylinder(r=v[0], h=v[1]);
    translate([0,-1,-v[0]-1])
      cube([v[0]+1, v[1]+2, 2*v[0]+2]);
  }
}

//translate([0,-13*(1-cos(60/2+45)) + 13*(1-sin(60/2+45)),0])
//inner_round_corner(13, 2, 60);
module inner_round_corner(r, h, ang=90, back = 0.1){
  cx = r*(1-cos(ang/2+45));
  translate([-r*(1-sin(ang/2+45)), -r*(1-sin(ang/2+45)),0])
  difference(){
    translate([-back, -back, 0])
    cube([cx+back, cx+back, h]);
    translate([r,r,-1])
      cylinder(r=r, h=h+2);
  }
}

module Nema17(){
  M3_diameter = 3;
  cw = Nema17_cube_width;
  ch = Nema17_cube_height;
  sh = Nema17_shaft_height;
  union(){
    color("black")
    difference(){
      translate([-(cw-0.1)/2,-(cw-0.1)/2,1]) cube([cw-0.1,cw-0.1,ch-2]);
      for (i=[0:90:359]){ // Corner cuts black cube
        rotate([0,0,i+45]) translate([50.36/2,-cw/2,-1]) cube([cw,cw,ch+2]);
      }
    }
    color("silver")
    difference(){
      translate([-cw/2,-cw/2,0]) cube([cw,cw,ch]);
      for (i=[0:90:359]){ // Corner cuts silver cube
        rotate([0,0,i+45]) translate([53.36/2,-cw/2,-1]) cube([cw,cw,ch+2]);
      }
      translate([0,0,ch-5]) Nema17_screw_holes(M3_diameter, h=10);
      translate([0,0,-5]) Nema17_screw_holes(M3_diameter, h=10);
      translate([-cw,-cw,9]) cube([2*cw,2*cw,ch-18]);
    }
    color("silver")
    difference(){
      cylinder(r=Nema17_ring_diameter/2, h=ch+Nema17_ring_height);
      translate([0,0,1]) cylinder(r=8.76/2, h=ch+Nema17_ring_height);
    }
    color("silver")
      cylinder(r=5/2, h=sh); // Shaft...
  }
}

module D_shaft(height, extra_radius=0.25){
  difference(){
    cylinder(r=Nema17_shaft_radius+extra_radius, h=height,$fn=13);
    translate([-5,Nema17_shaft_radius+extra_radius-0.6,-1])
      cube([10,10,height+1]);
  }
}

// For making nut locks and stuff
module point_cube(v, ang){
  translate([v[0]/2,0,0])
  difference(){
    translate([-v[0]/2,0,0]) cube(v);
    rotate([0,-ang/2,0]) translate([-2*v[0],1.5-v[1],-v[2]]) cube([2*v[0],2*v[1],3*v[2]]);
    mirror([1,0,0]) rotate([0,-ang/2,0]) translate([-2*v[0],1.5-v[1],-v[2]])
      cube([2*v[0],2*v[1],3*v[2]]);
  }
}

module nutlock(){
  translate([-5.6/2,0,0])
    point_cube([5.6,2.5,9],120);
  translate([0,-3,3.3])
  rotate([-90,0,0])
  cylinder(d=3.5,h=16);
}

module hexagon_for_nut(h = 1.5){
  difference(){
    cylinder(d=5.6/cos(30)+2, h=h, $fn=6);
    translate([0,0,-1])
    cylinder(d=5.6/cos(30), h=h+2, $fn=6);
  }
}

module teardrop(r=10, h=10){
  cylinder(r=r, h=h);
  rotate([0,0,45])
    cube([r,r,h]);
}

function sq_pts(v) = [[0,0], [v[0],0], [v[0], v[1]], [0, v[1]]];

// These are used by beam_clamp and corner_clamp
module opening_top(exclude_left=false, exclude_right=false, wall_th, edges, l, extra_h=2){
  if(!exclude_left){
    translate([wall_th+edges, 0, 2*wall_th+Fat_beam_width+extra_h])
      rotate([0,90,90])
      translate([0,0,-1])
      inner_round_corner(r=2, h=l, $fn=4*5);
  }
  if(!exclude_right){
    mirror([1,0,0])
      translate([-wall_th-Fat_beam_width+edges, 0, 2*wall_th+Fat_beam_width+extra_h])
      rotate([0,90,90])
      translate([0,0,-1])
      inner_round_corner(r=2, h=l, $fn=4*5);
  }
}

module opening_corners(left_one_height=Fat_beam_width,
                       right_one_height=Fat_beam_width,
                       wall_th, edges){
  translate([wall_th+Fat_beam_width,0,wall_th])
    inner_round_corner(r=2, h=right_one_height, back=2, $fn=4*5);
  translate([wall_th,0,wall_th])
    rotate([0,0,90])
    inner_round_corner(r=2, h=left_one_height, back=2, $fn=4*5);

  translate([wall_th+Fat_beam_width-edges,0,wall_th])
    inner_round_corner(r=2, h=Fat_beam_width+2*wall_th+1, back=2, $fn=4*5);
  translate([wall_th+edges,0,wall_th])
    rotate([0,0,90])
    inner_round_corner(r=2, h=Fat_beam_width+2*wall_th+2, back=2, $fn=4*5);
}

function circle_sector(max_ang, r0, r1, steps=100) =
  concat([for (a=[0:max_ang/steps:max_ang+0.5])
            r0*[cos(a), sin(a)]],
         [for (a=[-0:(max_ang)/steps:max_ang+0.01])
           r1*[cos(max_ang-a), sin(max_ang-a)]]);

//chamfer45([10, 19], 1);
module chamfer45(v0, h){
  linear_extrude(height=h, slices=1, convexity=2, scale=[(v0[0]-2*h)/v0[0], (v0[1]-2*h)/v0[1]])
    square(v0, center=true);
}
