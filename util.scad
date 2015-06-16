//////////// Utility numbers //////////////
Big   = 300;
Sqrt3 = sqrt(3);
pi    = 3.1415926535897932384626433832795;

function mirror_point_x(coord) = 
[
	-coord[0], 
	coord[1],
  coord[2]
];

function rotate_point_around_z(angle, p) = 
[
	cos(angle)*p[0] + sin(angle)*p[1],
	cos(angle)*p[1] - sin(angle)*p[0],
  p[2]
  
];

// Expects circle centered around 0 in xy-plane
// A line through p and the returned point is a tangent
// to that circle.
// One point is exactly
// p
// The other point satisfies
//     x*x + y*y = r*r               (1)
// and we have a 90 degree angle between two vectors so
//     dot(p - (x, y), (x, y)) = 0
// translates to
//     (p[0] - x)x = (y - p[1])y     (2)
// use (1) and get
//     ax + by = r*r
// This is linear, so extract x and plug into (1)
function tangent_point(r, p) = 
[
  r*r*p[0]/(p[0]*p[0] + p[1]*p[1])
   + (r/sqrt(p[0]*p[0] + p[1]*p[1]))
     *sqrt(r*r*p[0]*p[0]/(p[0]*p[0]+p[1]*p[1]) - r*r + p[1]*p[1]),
  r*r*p[1]/(p[0]*p[0] + p[1]*p[1])
   - (r/sqrt(p[0]*p[0] + p[1]*p[1]))
     *sqrt(r*r*p[1]*p[1]/(p[0]*p[0]+p[1]*p[1]) - r*r + p[0]*p[0])
];

function tangent_3d_point(r, p) = 
[
  r*r*p[0]/(p[0]*p[0] + p[1]*p[1])
   + (r/sqrt(p[0]*p[0] + p[1]*p[1]))
     *sqrt(r*r*p[0]*p[0]/(p[0]*p[0]+p[1]*p[1]) - r*r + p[1]*p[1]),
  r*r*p[1]/(p[0]*p[0] + p[1]*p[1])
   - (r/sqrt(p[0]*p[0] + p[1]*p[1]))
     *sqrt(r*r*p[1]*p[1]/(p[0]*p[0]+p[1]*p[1]) - r*r + p[0]*p[0]),
  0
];

function tangent_point_2(r, p) = 
[
  r*r*p[0]/(p[0]*p[0] + p[1]*p[1])
   + (r/sqrt(p[0]*p[0] + p[1]*p[1]))
     *sqrt(r*r*p[0]*p[0]/(p[0]*p[0]+p[1]*p[1]) - r*r + p[1]*p[1]),
  r*r*p[1]/(p[0]*p[0] + p[1]*p[1])
   + (r/sqrt(p[0]*p[0] + p[1]*p[1]))
     *sqrt(r*r*p[1]*p[1]/(p[0]*p[0]+p[1]*p[1]) - r*r + p[0]*p[0])
];

function tangent_3d_point_2(r, p) = 
[
  r*r*p[0]/(p[0]*p[0] + p[1]*p[1])
   + (r/sqrt(p[0]*p[0] + p[1]*p[1]))
     *sqrt(r*r*p[0]*p[0]/(p[0]*p[0]+p[1]*p[1]) - r*r + p[1]*p[1]),
  r*r*p[1]/(p[0]*p[0] + p[1]*p[1])
   + (r/sqrt(p[0]*p[0] + p[1]*p[1]))
     *sqrt(r*r*p[1]*p[1]/(p[0]*p[0]+p[1]*p[1]) - r*r + p[0]*p[0]),
  0
];

function tangent_point_3(r, p) = 
[
  r*r*p[0]/(p[0]*p[0] + p[1]*p[1])
   - (r/sqrt(p[0]*p[0] + p[1]*p[1]))
     *sqrt(r*r*p[0]*p[0]/(p[0]*p[0]+p[1]*p[1]) - r*r + p[1]*p[1]),
  r*r*p[1]/(p[0]*p[0] + p[1]*p[1])
   + (r/sqrt(p[0]*p[0] + p[1]*p[1]))
     *sqrt(r*r*p[1]*p[1]/(p[0]*p[0]+p[1]*p[1]) - r*r + p[0]*p[0])
];

function tangent_3d_point_3(r, p) = 
[
  r*r*p[0]/(p[0]*p[0] + p[1]*p[1])
   - (r/sqrt(p[0]*p[0] + p[1]*p[1]))
     *sqrt(r*r*p[0]*p[0]/(p[0]*p[0]+p[1]*p[1]) - r*r + p[1]*p[1]),
  r*r*p[1]/(p[0]*p[0] + p[1]*p[1])
   + (r/sqrt(p[0]*p[0] + p[1]*p[1]))
     *sqrt(r*r*p[1]*p[1]/(p[0]*p[0]+p[1]*p[1]) - r*r + p[0]*p[0]),
  0
];

//////////// Utility modules //////////////

// Equilateral triangle, all sides same length
// Aligned along y-axis
module eq_tri(s, h){
  linear_extrude(height=h, slices=1)
    polygon(points = [[s/2,-s/(2*Sqrt3)],[0,s/Sqrt3],[-s/2,-s/(2*Sqrt3)]],
    paths=[[0,1,2]]);
}
//eq_tri(10,10);

// Special triangle, 30, 60 and 90 degree angles
module special_tri(s, h){
  linear_extrude(height=h, slices=1)
    polygon(points = [[0,0],
                      [Sqrt3*s/2,0],
                      [0,s/2]],
            paths=[[0,1,2]]);
}
//special_tri(40,10);

// pline cant handle vertical lines
// Handles 2D-lines
module pline(v0, v1, r = 0.7){
  v2 = v1 - v0;
  if(len(v2) == 3){
    v2l = sqrt(v2[0]*v2[0] + v2[1]*v2[1] + v2[2]*v2[2]);
    v2n = v2/v2l;
    theta = acos(v2n[2]);
    phi   = acos(v2n[1]/sqrt(v2n[1]*v2n[1] + v2n[0]*v2n[0]));
//    echo(theta);
//    echo(phi);
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
//pline([-23,41,-25],[10,-32,34],7);

// eline handles vertical lines...
module eline(p0, p1, r=0.8) {
  v  = p0 - p1;
  vl = sqrt(v[0]*v[0] + v[1]*v[1] + v[2]*v[2]);
  translate(v/2 + p1)
    //rotation of XoY plane by the Z axis with the angle of the [p1 p2] line projection with the X axis on the XoY plane
    rotate([0, 0, -atan2(v[1], v[0])]) //rotation
    //rotation of ZoX plane by the y axis with the angle given by the z coordinate and the sqrt(x^2 + y^2)) point in the XoY plane
    rotate([0, atan2(sqrt(v[0]*v[0] + v[1]*v[1]), v[2]), 0])
    cylinder(h = vl, r = r,center=true);
}
//eline([0, 106.512, 7.62857],  [0, 106.512, 500]);

// Thickness of wall, radius to swing around, height of wall
module cyl_wall_2(th, r, h, ang){
  fn = 3;
  theta = ang/fn;
  translate([r-th/2,0,0])
    cylinder(r=th/2,h=h);
  rotate([0,0,-ang]){
    translate([r*cos(theta/2),0,0])
      translate([-th,0,0])
      cube([th,sin(theta/2)*r,h]);
    for(i=[1:1:fn-1]){
      translate([r*cos((-0.5 + i)*theta),r*sin((-0.5 + i)*theta),0])
        rotate([0,0,ang*i/fn])
        translate([-th,0,0])
        cube([th,2*sin(theta/2)*r,h]);
    }
    translate([r*cos((-0.5 + fn)*theta),r*sin((-0.5 + fn)*theta),0])
      rotate([0,0,ang])
      translate([-th,0,0])
      cube([th,sin(theta/2)*r,h]);
  }
}
//cyl_wall_2(3, 20, 12,90);
