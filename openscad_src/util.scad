include <parameters.scad>

//!rounded_cube([40,61,42], 8, center=true);
module rounded_cube(v, r, center=false){
  fn = 32;
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
          cylinder(r=r, h=v[2]-d, $fn = fn);
          for(j=[0,v[2]-d]){
            translate([0,0,j]){
              sphere(r, $fn = fn);
              rotate([0,90,0])
                rotate([0,0,0.5*360/fn])
                cylinder(r=r, h=l, $fn = fn);
            }
          }
        }
      }
    }
  }

  //!core();
  module core(){
    translate([r, r, 0]){
      cube([v[0] - d, v[1] - d, v[2]]);
    }
    translate([r, 0, r]){
      cube([v[0] - d, v[1], v[2] - d]);
    }
    translate([0, r, r]){
      cube([v[0], v[1] - d, v[2] - d]);
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
  $fn = 16;
  union(){
    translate([r,0,0])           cube([v[0]-2*r, v[1]    , v[2]]);
    translate([0,r,0])           cube([v[0]    , v[1]-2*r, v[2]]);
    translate([r,r,0])           cylinder(h=v[2], r=r);
    translate([v[0]-r,r,0])      cylinder(h=v[2], r=r);
    translate([v[0]-r,v[1]-r,0]) cylinder(h=v[2], r=r);
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

// Functions for use with sweep
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

