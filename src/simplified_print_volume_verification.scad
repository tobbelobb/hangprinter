left = 0;
right = 1;
X = 0;
Y = 1;
Z = 2;

// This is the A anchor position that is
// calibrated and configured in firmware.
// We can not use it directly because
// it does not account for the fact that there
// are two action points (lines) in the A-direction.
// Therefore, it lacks information about
// where lines enter the effector.
A_calib = [0, -1604, -114];

// This is the cartesian position of the two
// action points on the effector, relative to the nozzle.
A_offset = [[-220, -135, 110],
            [ 220, -135, 110]];

// This is the cartesian position of the action points
// on the anchor, relative to the origin
A = [A_calib + A_offset[left],
     A_calib + A_offset[right]];

B_calib = [1312, 1271, -162];
B_offset = [[ 220, -135, 110],
            [   0,  260, 110]];
B = [B_calib + B_offset[left],
     B_calib + B_offset[right]];

C_calib = [-1440, 741, -161];
C_offset = [[   0,  260, 110],
            [-220, -135, 110]];
C = [C_calib + C_offset[left],
     C_calib + C_offset[right]];


//echo(circle_points2d(100, 3));
function circle_points2d(r, steps) =
  [for (a=[0:360/steps:360-360/(steps+1)])
    r*[cos(a), sin(a)]];

//linear_extrude(height=4)
//  polygon(points = circle_points2d(100, 3));
function circle_points(r, steps, v) =
  [for (a=[0:360/steps:360-360/(steps+1)])
    r*[cos(a), sin(a), 0] + v];

//echo(roundabout_cone(3));
function roundabout_cone(size) =
  [for (elem=[0:1:size-1])
     [elem, (elem+1)%size, size]];

//echo(roundabout_plane(4));
function roundabout_plane(size) =
  [for (elem=[1:1:size-2])
    [0, elem + 1, elem]];

module line_vol(path, path_size, anch){
  polyhedron(points = concat(path, [anch]),
             faces = concat(roundabout_cone(path_size), roundabout_plane(path_size)));
}

layer_height = 1;
r = 600/2;
edges = 101;
for (layer = 1200){
  %linear_extrude(height=layer_height*layer)
    polygon(circle_points2d(r, edges));
  color("lime"){
    intersection(){
      linear_extrude(height=layer_height*layer)
        polygon(circle_points2d(r, edges));
      #union(){
        // A lines
        line_vol(circle_points(r, edges,
                    A_offset[left] + [0, 0, layer*layer_height]),
          edges, A[left]);
        line_vol(circle_points(r, edges,
                    A_offset[right] + [0, 0, layer*layer_height]),
          edges, A[right]);
        // B lines
        line_vol(circle_points(r, edges,
                    B_offset[left] + [0, 0, layer*layer_height]),
          edges, B[left]);
        line_vol(circle_points(r, edges,
                    B_offset[right] + [0, 0, layer*layer_height]),
          edges, B[right]);
        // C lines
        line_vol(circle_points(r, edges,
                    C_offset[left] + [0, 0, layer*layer_height]),
          edges, C[left]);
        line_vol(circle_points(r, edges,
                    C_offset[right] + [0, 0, layer*layer_height]),
          edges, C[right]);
      }
    }
  }
}
