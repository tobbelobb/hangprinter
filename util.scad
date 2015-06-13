//////////// Utility numbers //////////////
Big   = 300;
Sqrt3 = sqrt(3);
pi    = 3.1415926535897932384626433832795;

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

module pline(v0, v1, r){
  v2 = v1 - v0;
  v2l = sqrt(v2[0]*v2[0] + v2[1]*v2[1] + v2[2]*v2[2]);
  v2n = v2/v2l;
  theta = acos(v2n[2]);
  phi   = acos(v2n[1]/sqrt(v2n[1]*v2n[1] + v2n[0]*v2n[0]));
  translate(v0)
    if(v2n[0] < 0){
      rotate([-theta,0,phi])
        cylinder(r=r, h=v2l);
    } else {
      rotate([-theta,0,-phi])
        cylinder(r=r, h=v2l);
    }
}
//pline([-23,41,-25],[10,-32,34],7);
