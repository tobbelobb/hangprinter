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


