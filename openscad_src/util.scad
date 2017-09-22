
//!rounded_cube([40,61,42], 8, center=true);
module rounded_cube(v, r, center=false){
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
          cylinder(r=r, h=v[2]-d);
          for(j=[0,v[2]-d]){
            translate([0,0,j]){
              sphere(r);
              rotate([0,90,0])
                cylinder(r=r, h=l);
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
  union(){
    translate([r,0,0])           cube([v[0]-2*r, v[1]    , v[2]]);
    translate([0,r,0])           cube([v[0]    , v[1]-2*r, v[2]]);
    translate([r,r,0])           cylinder(h=v[2], r=r);
    translate([v[0]-r,r,0])      cylinder(h=v[2], r=r);
    translate([v[0]-r,v[1]-r,0]) cylinder(h=v[2], r=r);
    translate([r,v[1]-r,0])      cylinder(h=v[2], r=r);
  }
}

