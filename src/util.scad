include <parameters.scad>


//spectri_2d(10);
module spectri_2d(hyp){
  polygon(points=[[0,0],[hyp/2,0],[0,sqrt(3)*hyp/2]]);
}

//spectri(10, 2);
module spectri(hyp, h){
  linear_extrude(height=h, convexity=2)
    spectri_2d(hyp);
}

//rounded_spectri_2d(18, 1, $fn=36);
module rounded_spectri_2d(hyp, r){
  hull(){
    translate([                r,                               r]) circle(r);
    translate([hyp/2 - r*sqrt(3),                               r]) circle(r);
    translate([                r, sqrt(3)*hyp/2 - (2 + sqrt(3))*r]) circle(r);

  }
}

//translate([0,0,0.1])
//%spectri(18, 3, $fn=36);
//rounded_spectri(18, 2, 2, $fn=36);
module rounded_spectri(hyp, h, r){
  linear_extrude(height=h, convexity=2)
    rounded_spectri_2d(hyp, r);
}

// Could have used circle($fn=3) and some scaling...
//eqtri_2d(20);
module eqtri_2d(s){
  polygon(points=[[-s/2,0],[s/2,0],[0,sqrt(3)*s/2]]);
}

//eqtri(20, 5);
module eqtri(s, h){
  linear_extrude(height=h, convexity=2)
    eqtri_2d(s);
}

//rounded_eqtri_2d(20,2);
module rounded_eqtri_2d(s, r){
  hull(){
    translate([-s/2+r, r]) circle(r=r);
    translate([ s/2-r, r]) circle(r=r);
    translate([     0, sqrt(3)*s/2 - r]) circle(r=r);
  }
}

//rounded_eqtri(20,2, 1);
module rounded_eqtri(s, h, r){
  linear_extrude(height=h, convexity=2)
    rounded_eqtri_2d(s, r);
}

//rounded_cube([40,61,42], 8, center=true);
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

//rounded_cube2_2d([10,20], 3);
module rounded_cube2_2d(v, r){
  $fs = 1;
  translate([r,0])           square([v[0]-2*r, v[1]    ]);
  translate([0,r])           square([v[0]    , v[1]-2*r]);
  translate([r,r])           circle(r=r);
  translate([v[0]-r,r])      circle(r=r);
  translate([v[0]-r,v[1]-r]) circle(r=r);
  translate([r,v[1]-r])      circle(r=r);
}

//rounded_cube2([20,30,2], 2);
module rounded_cube2(v, r){
  linear_extrude(height = v[2], slices = 1, convexity = 2)
    rounded_cube2_2d([v[0], v[1]], r);
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

//ydir_rounded_cube2_2d([20,30,2], 2);
module ydir_rounded_cube2_2d(v, r){
                               square([v[0]    , v[1]-r]);
    translate([r,0])           square([v[0]-2*r, v[1]  ]);
    translate([r,v[1]-r])      circle(r=r);
    translate([v[0]-r,v[1]-r]) circle(r=r);
}

//ydir_rounded_cube2([20,30,2], 2);
module ydir_rounded_cube2(v, r){
  linear_extrude(height=v[2], convexity=2)
    ydir_rounded_cube2_2d([v[0],v[1]], r);
}


//top_rounded_cube2([20,2,30], 7);
module top_rounded_cube2(v, r){
  translate([0,v[1],0])
  rotate([90,0,0])
  linear_extrude(height=v[1], convexity=2)
    ydir_rounded_cube2_2d([v[0],v[2]], r);
}

//ymdir_rounded_cube2([20,30,2], 2);
module ymdir_rounded_cube2(v, r){
  $fs = 1;
  union(){
    translate([0,r,0])      cube([v[0]   , v[1]-r, v[2]]);
    translate([r,0,0])      cube([v[0]-2*r, v[1] , v[2]]);
    translate([r,r,0])      cylinder(h=v[2], r=r);
    translate([v[0]-r,r,0]) cylinder(h=v[2], r=r);
  }
}

//left_rounded_cube2_2d([20,30,2], 2);
module left_rounded_cube2_2d(v, r){
  translate([r,0])      square([v[0]-r, v[1]    ]);
  translate([0,r])      square([v[0]  , v[1]-2*r]);
  translate([r,r])      circle(r=r);
  translate([r,v[1]-r]) circle(r=r);
}

//left_rounded_cube2([20,30,2], 2);
module left_rounded_cube2(v, r){
  linear_extrude(height=v[2], convexity=2)
    left_rounded_cube2_2d([v[0], v[1]], r);
}

//one_rounded_cube2([20,30,2], 2);
module one_rounded_cube2(v, r){
  $fs = 1;
  translate([r,0,0]) cube([v[0]-  r, v[1]  , v[2]]);
  translate([0,r,0]) cube([v[0]   , v[1]-r, v[2]]);
  translate([r,r,0]) cylinder(h=v[2], r=r);
}

module one_rounded_cube2_2(v, r){
  $fs = 1;
  translate([0,0,0]) cube([v[0]-  r, v[1]  , v[2]]);
  translate([0,0,0]) cube([v[0]   , v[1]-r, v[2]]);
  translate([v[0]-r,v[1]-r,0]) cylinder(h=v[2], r=r);
}

module one_rounded_cube2_3(v, r){
  $fs = 1;
  translate([r,0,0]) cube([v[0]-  r, v[1]  , v[2]]);
  translate([0,0,0]) cube([v[0]   , v[1]-r, v[2]]);
  translate([r,v[1]-r,0]) cylinder(h=v[2], r=r);
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
    translate([0,0,0])           cube([v[0]-  r, v[1]-r  , v[2]]);
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

//round_ends_alt_2d(5, 20);
module round_ends_alt_2d(d, l){
  between = l - d;
  translate([-d/2, -between/2, 0]) square([d, between]);
  translate([   0,  between/2, 0]) circle(d = d);
  translate([   0, -between/2, 0]) circle(d = d);
}

//round_ends_alt(5, 20, 2);
module round_ends_alt(d, l, h){
  linear_extrude(height = h, slices=1, convexity=2)
    round_ends_alt_2d(d, l);
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

module round_end2d(v){
  v = (v[0] == undef) ? [v, v] : v;
  square([v[0]-v[1]/2, v[1]]);
  translate([v[0]-v[1]/2, v[1]/2,0]) circle(d=v[1]);
}

// Looks best with $fn = n*8
//round_end([45,41,8]);
module round_end(v){
  v = (v[0] == undef) ? [v, v] : v;
  linear_extrude(height = v[2], slices = 1, convexity = 2)
    round_end2d([v[0], v[1]]);
}

//round_ends2d([56,41]);
module round_ends2d(v){
  v = (v[0] == undef) ? [v, v] : v;
  translate([     v[1]/2,      0, 0]) square([v[0]-v[1], v[1]]);
  translate([v[0]-v[1]/2, v[1]/2, 0]) circle(d=v[1]);
  translate([     v[1]/2, v[1]/2, 0]) circle(d=v[1]);
}

//round_ends([56,41,8]);
module round_ends(v){
  v = (v[0] == undef) ? [v, v] : v;
  linear_extrude(height = v[2], slices = 1, convexity = 2)
    round_ends2d([v[0], v[1]]);
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

//linear_extrude(height=4, convexity=4)
//inner_round_corner_2d(13, 60, 0.2, false);
module inner_round_corner_2d(r, ang=90, back=0.1, center=false){
  cx = r*(1-cos(ang/2+45));
  if(center){
    translate([-r , -r])
      difference(){
        translate([-back, -back])
          square([cx+back, cx+back]);
        translate([r,r])
          circle(r=r);
      }
  } else {
    translate([-r*(1-sin(ang/2+45)), -r*(1-sin(ang/2+45))])
      difference(){
        translate([-back, -back])
          square([cx+back, cx+back]);
        translate([r,r])
          circle(r=r);
      }
  }
}

//translate([0,-13*(1-cos(60/2+45)) + 13*(1-sin(60/2+45)),0])
//inner_round_corner(13, 2, 60);
//inner_round_corner(13, 2, 60, 0.2, false);
module inner_round_corner(r, h, ang=90, back = 0.1, center=false){
  linear_extrude(height=h, convexity=4)
    inner_round_corner_2d(r, ang, back, center);
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


module nut(h){
  cylinder(d=5.6/cos(30), h, $fn=6);
}

module M3_nut(h){
  nut(h);
}

module nut_wall(h){
  cylinder(d=7/cos(30), h, $fn=6);
}

module hexagon_for_nut(h = 1.5){
  difference(){
    cylinder(d=7/cos(30), h=h, $fn=6);
    translate([0,0,-1])
      nut(h+2);
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

module line_from_to(v0, v1, r = 1.0){
  v2 = v1 - v0;
  color("yellow")
    if(len(v2) == 3){
      v2l = sqrt(v2[0]*v2[0] + v2[1]*v2[1] + v2[2]*v2[2]);
      v2n = v2/v2l;
      theta = acos(v2n[2]);
      phi   = acos(v2n[1]/sqrt(v2n[1]*v2n[1] + v2n[0]*v2n[0]));
      //echo(theta);
      //echo(phi);
      translate(v0)
        if(v2n[0] < 0){
          rotate([-theta,0,phi])
            cylinder(r=r, h=v2l);
        } else {
          rotate([-theta,0,-phi])
            cylinder(r=r, h=v2l);
        }
    } else {
      v2l = sqrt(v2[0]*v2[0] + v2[1]*v2[1]);
      v2n = v2/v2l;
      phi   = acos(v2n[1]/sqrt(v2n[1]*v2n[1] + v2n[0]*v2n[0]));
      translate(v0)
        if(v2n[0] < 0){
          rotate([-90,0,phi])
            cylinder(r=r, h=v2l);
        } else {
          rotate([-90,0,-phi])
            cylinder(r=r, h=v2l);
        }
    }
}

module b623_vgroove(){
  $fn=4*8;
  color("purple"){
    cylinder(r=b623_vgroove_small_r, h=b623_width, center=true);
    for(k=[0,0,1])
      mirror([0,0,k]){
        cylinder(r1=b623_vgroove_small_r, r2=b623_vgroove_big_r, h=b623_width/2);
      }
  }
}

//elong_b623_vgroove();
module elong_b623_vgroove(elong=10){
  $fn=4*8;
  color("purple"){
    hull(){
      cylinder(r=b623_vgroove_small_r, h=b623_width, center=true);
      translate([0,elong,0])
        cylinder(r=b623_vgroove_small_r, h=b623_width, center=true);
    }
    for(k=[0,0,1])
      mirror([0,0,k]){
        hull(){
          cylinder(r1=b623_vgroove_small_r,r2=b623_vgroove_big_r,h=b623_width/2);
          translate([0,elong,0]){
            cylinder(r1=b623_vgroove_small_r,r2=b623_vgroove_big_r,h=b623_width/2);
          }
        }
      }
  }

}

module b623(){
  color("purple")
  difference(){
    cylinder(d = b623_outer_dia, h = b623_width, $fn=32);
    translate([0,0,-1])
      cylinder(r = b623_bore_r, h = b623_width + 2);
  }
}

module b608(){
  color("purple")
  difference(){
    cylinder(d = b608_outer_dia, h = b608_width, $fn=32);
    translate([0,0,-1])
      cylinder(r = b608_bore_r, h = b608_width + 2);
  }
}

module Mounting_screw_countersink(twod=false){
  if (twod) {
    circle(d=Mounting_screw_d, $fn=12*4);
  } else {
    translate([0,0,-19.9])
      cylinder(d=Mounting_screw_d, h=20, $fn=20);
    cylinder(d1=Mounting_screw_d,
             d2=Mounting_screw_d + 2*2.7, // 90 degree countersink
             h=2.7, $fn=20);
    translate([0,0,2.64])
      cylinder(d=Mounting_screw_d + 2*2.7, h=3, $fn=20);
  }
}

//roller_base();
module roller_base(twod=false,
                   yextra=0,
                   base_extra_w=0,
                   wing=0,
                   screw_holes=true,
                   mv_edg=0,
                   wall_th=Line_roller_wall_th,
                   space_between_walls,
                   openings=[false, false, false, false]){
  l = Roller_l+base_extra_w;
  d = Depth_of_roller_base;
  s = space_between_walls;
  mounting_screw_z = Base_th-1.7;

  if(!twod){
    difference(){
      union(){
        translate([-d/2, -l/2-wing, 0])
          left_rounded_cube2([d, l+yextra+wing, Base_th], r=8, $fn=13*4);
        translate([-d/2-Roller_fl,-d/2,0])
          left_rounded_cube2([d+Roller_fl, d+yextra, Base_th], r=8, $fn=13*4);
        for(k=[0,1])
          mirror([0,k,0])
            translate([-d/2,-d/2-k*yextra, 0])
            rotate([0,0,180])
            inner_round_corner(r=2, h=Base_th, $fn=6*4); // Fillet
        for(k=[0,1])
          mirror([0,k,0])
            translate([0,s/2 + wall_th+(1-k)*mv_edg, Base_th])
            rotate([90,0,90])
            translate([0,0,-(d+10)/2])
            inner_round_corner(h=d+10, r=5, back=0.1, $fn=4*5);
        if(mv_edg>wall_th+s){
          translate([-d/2, s/2+wall_th+mv_edg, Base_th])
            rotate([0,-90,90])
            // new fillet for outermost wall
            inner_round_corner(r=5, h=wall_th, $fn=4*5);
          for(k=[0,1])
            mirror([0,k,0])
              translate([-d/2, s/2+wall_th+(1-k)*(mv_edg-wall_th-s), Base_th])
              rotate([0,-90,90])
              inner_round_corner(r=5,
                  h=wall_th+(1-k)*(mv_edg - wall_th - s),
                  $fn=4*5);
        } else {
          for(k=[0,1])
            mirror([0,k,0])
              translate([-d/2, s/2+wall_th, Base_th])
              rotate([0,-90,90])
              inner_round_corner(r=5, h=wall_th, $fn=4*5);
        }
      }
      translate([d/2, -l/2-1])
        cube([10,l+yextra+2,50]);
      for(k=[0,1])
        mirror([0,k,0]){
          if(yextra>s)
            translate([-14, -k*yextra, mounting_screw_z])
              Mounting_screw_countersink();
          else
            translate([-14, 0, mounting_screw_z])
              Mounting_screw_countersink();
          translate([0,-14-k*yextra-base_extra_w/2 - (1-k)*wing, mounting_screw_z])
            Mounting_screw_countersink();
          translate([-d/2-5,5,5+Base_th])
            rotate([90,0,0])
            cylinder(r=5, h=50, center=true,$fn=4*5);
          translate([-d/2-2, -d/2-2-k*yextra,-1]){
            cylinder(r=2, h=Base_th+5, $fn=4*6);
            translate([-10,+2-Base_th-5,0])
              cube([10, Base_th+5, Base_th+5]);
            translate([2-Base_th-5,-10,0])
              cube([Base_th+5, 10, Base_th+5]);
          }
        }
      for(k=[0,1])
        mirror([0,k,0])
          translate([-l/2,-d/2-k*yextra,-1])
          rotate([0,0,0])
          inner_round_corner(r=8, h=Base_th+3,$fn=4*13);
    }
  } else {
    difference(){
      union(){
        translate([-d/2, -l/2-wing])
          left_rounded_cube2_2d([d, l+yextra+wing], r=8, $fn=13*4);
        translate([-d/2-Roller_fl,-d/2])
          left_rounded_cube2_2d([d+Roller_fl, d+yextra], r=8, $fn=13*4);
        for(k=[0,1])
          mirror([0,k,0])
            translate([-d/2,-d/2-k*yextra, 0])
            rotate([0,0,180])
            inner_round_corner_2d(r=2, $fn=6*4); // Fillet
      }
      if(screw_holes){
        for(k=[0,1]) {
          mirror([0,k]){
            if(yextra>s)
              translate([-14,-k*yextra])
                Mounting_screw_countersink(twod=true);
            else
              translate([-14,0])
                Mounting_screw_countersink(twod=true);
            translate([0,-14-k*yextra-base_extra_w/2-(1-k)*wing])
              Mounting_screw_countersink(twod=true);
          }
        }
      }
    }
  }
}

//roller_wall(4, 5, 20);
module roller_wall(space_between_walls, wall_th, height, rot_nut=0, bearing_screw=true){
  d = Depth_of_roller_base;
  difference(){
    union(){
      translate([-d/2, space_between_walls/2,0])
        cube([d, wall_th, height]);
      translate([0, space_between_walls/2-0.4, height - d/2])
        rotate([-90,0,0])
          cylinder(r=3.4/2 + 1, h=wall_th, $fn=12);
    }
    translate([0,0,height - d/2])
      rotate([-90,0,0])
      inner_round_corner(r=d/2, h=d, center=true, $fn=4*7);
    if(bearing_screw){
      translate([0,space_between_walls/2 - 1, height - d/2])
        rotate([-90,0,0]){
          cylinder(d=3.4, h=wall_th + 2, $fn=12);
          translate([0,0,1+wall_th - min(wall_th/2, 2)])
            rotate([0,0,rot_nut])
              nut(h=8);
        }
    }
  }
}

//roller_wall_pair(10, 5, 20);
module roller_wall_pair(space_between_walls, wall_th, height, rot_nut=0, base_extra_w=0, wing=0, bearing_screw=true){
      roller_base(wall_th = wall_th,
                  space_between_walls=space_between_walls,
                  openings=[true,false,true,false],
                  yextra=0,
                  wing=wing,
                  base_extra_w=base_extra_w);
      roller_wall(space_between_walls, wall_th, height, rot_nut, bearing_screw);
      mirror([0,1,0])
        roller_wall(space_between_walls, wall_th, height, rot_nut, bearing_screw);
}

//preventor_edges(22, b623_width, back1=1.9, back2=0.9);
module preventor_edges(tower_h,
                       space_between_walls,
                       with_bearing=false,
                       edge_start=0,
                       edge_stop=180,
                       back1 = 0.5,
                       back2 = 0){
  // Edge to prevent line from falling of...
  a = 1.75;
  b= 0.8;
  rot_r = b623_vgroove_big_r+b;

  if(with_bearing){
    translate([0,0,tower_h-Depth_of_roller_base/2])
    rotate([90,0,0])
      b623_vgroove();
  }

  module preventor_edge(){
    difference(){
      translate([0, -space_between_walls/2 - 0.4,
          tower_h - Depth_of_roller_base/2])
        rotate([-90,0,0])
        difference(){
          rotate_extrude(angle=360, convexity=10, $fn=60)
            translate([rot_r,0])
            polygon(points = [[0,-back2],[0,-back1],[b+a, -back1],[b+a,-back2],[b, a],[0, a]]);
          rotate([0,0,edge_stop])
            translate([0,0,-0.5-back1])
            linear_extrude(height=b+a+0.5+back1)
            polygon(points=circle_sector(360-(edge_stop-edge_start),1,rot_r+b+a+1));
          rotate([0,0,edge_start])
            translate([rot_r-1,0,0])
            rotate([45,0,0])
            cube(b+a+1);
          rotate([0,0,edge_stop])
            translate([rot_r-1,0,0])
            rotate([45,0,0])
            cube(b+a+1);
        }
      translate([Depth_of_roller_base/2,-10,0])
        cube([10,10,tower_h]);
      translate([-Depth_of_roller_base/2-10,-10,0])
        cube([10,10,tower_h]);
    }

  }

  preventor_edge();
  mirror([0,1,0])
    preventor_edge();
}

//corner_rounder();
module corner_rounder(r1=3, r2=2, sq=[10,10], angle=90){
  translate([-r1, -r1])
    rotate_extrude(angle=angle, $fn=4*6)
    translate([r1,0])
    rounded_square(sq, r2, $fn=20);
}

//inner_corner_rounder(3, $fn=24);
module inner_corner_rounder(r, ang1=90, ang2=90, back=1){
  rotate([0,0,180])
    rotate_extrude(angle=ang2)
    translate([-r,0])
    inner_round_corner_2d(r, ang=ang1, back=back);
}

//spacer(Spacer_ABC_width); //ABC
//spacer(Spacer_D_width); //D
module spacer(width){
  $fn=36;
  difference(){
    cylinder(d=15, h=width);
    translate([0,0,-1])
      cylinder(d=8.5, h=width + 2);
    // Phase in/out
    p = 6.7;
    for(k=[0,1]){
      translate([0,0,k*width])
        rotate_extrude(angle=360, convexity=5)
          translate([Motor_pitch-1.3,0])
            rotate([0,0,-45])
              square([4,5]);
    }
  }
}
