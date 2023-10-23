include <../lib/parameters.scad>
include <lib/layout_params.scad>
use <../lib/gear_util.scad>
use <../lib/util.scad>
use <../lib/whitelabel_motor.scad>
use <../lib/spool_core.scad>
use <lib/layout_lib.scad>

use <../GT2_spool_gear.scad>
use <../corner_clamp.scad>
use <../ileft_spool.scad>
use <../ileft_spool_cover.scad>
use <../iright_spool_top.scad>
use <../iright_spool_bottom.scad>
use <../iright_spool_cover.scad>
use <../horizontal_line_deflector.scad>
use <../landing_brackets.scad>
use <../line_roller_anchor.scad>
use <../line_roller_wire_rewinder.scad>
use <../line_verticalizer.scad>
use <../motor_bracket_A.scad>
use <../motor_bracket_B.scad>
use <../motor_bracket_C.scad>
use <../motor_bracket_D.scad>
use <../motor_bracket_I.scad>
use <../sep_disc.scad>
use <../spool.scad>
use <../spool_mirrored.scad>
use <../spool_cover.scad>
use <../spool_cover_mirrored.scad>
use <../ziptie_tensioner_wedge.scad>
use <../ram_1000_3dpotter_holder.scad>
use <../ram_1000_3dpotter_top_holder.scad>
use <../ram_1000_3dpotter.scad>
use <placed_winch_unit_A.scad>
use <placed_winch_unit_B.scad>
use <placed_winch_unit_C.scad>
use <placed_winch_unit_D.scad>
use <placed_winch_unit_I.scad>



//top_plate();
module top_plate(cx, cy, mvy){
  if(!twod){
    color(Color0, Color0_alpha)
      translate([-cx/2,mvy,-12])
      cube([cx, cy, 12]); // Top plate
  //} else {
  //  translate([-cx/2,mvy])
  //    %square([cx, cy]);
  }
}


if(mounted_in_ceiling && !twod && !mover){
  translate(anchors[I]  + [0,0,33])
    rotate([180,0,0])
      full_winch();
} else if (!mounted_in_ceiling) {
  full_winch();
}
module full_winch(){
  placed_winch_unit_A();
  placed_winch_unit_B();
  placed_winch_unit_C();
  placed_winch_unit_D();
  placed_winch_unit_I();

  echo("Top plate width: ", cx);
  echo("Top plate depth: ", cy);
  mvy = Yshift_top_plate;
  top_plate(cx, cy, mvy);
}


//mover();
module mover(pos = [0,0,0]) {
  translate(pos)
    translate([-Sidelength/2, -Sidelength/2, 35])
      cube([Sidelength, Sidelength, 64]);
}

//i_lines();
module i_lines(pos=[0,0,0]){
  l = Sidelength/2;
  color(Color_line){
    line_from_to(pos + [l,l, length_of_toolhead], anchors[I] + [l,l,0]);
    line_from_to(pos + [-l,l, length_of_toolhead], anchors[I] + [-l,l,0]);
    line_from_to(pos + [l,-l, length_of_toolhead], anchors[I] + [l,-l,0]);
    line_from_to(pos + [-l,-l, length_of_toolhead], anchors[I] + [-l,-l,0]);
  }
}

if(bottom_triangle)
  bottom_triangle();
module bottom_triangle(){
  for(i=[0,120,240])
    rotate([0,0,i])
      translate([0,-3000*sqrt(2)/sqrt(6),0]){
        color("sandybrown")
          rotate([0,0,30])
          translate([-45/2,0,-45])
          cube([45, 3000, 45]);
        translate([0,200,0])
          cube([500, 100, 12], center=true);
      }
}

//ABCD_anchor();
module ABCD_anchor(){
  Ext_sidelength = 500;
  translate([0, -Ext_sidelength/2, -8])
    cube([50,Ext_sidelength, 8]);
  color(Color1,0.6)
    for(k=[0,1]) mirror([0,k,0])
      translate([26,Ext_sidelength/2-27.91,0])
        if(false){
          rotate([0,0,-90])
          import("../../stl/line_roller_anchor.stl");
        } else {
          rotate([0,0,-90])
            newer_line_roller_anchor();
        }
}

function rotation(v, ang) = [v[0]*cos(ang)-v[1]*sin(ang), v[0]*sin(ang)+v[1]*cos(ang), v[2]];

module ABCD_anchors(pos = [0,0,0]){
  a_high_left = [-Sidelength/2, -Sidelength/sqrt(8)+5, length_of_toolhead+21];
  a_low_left = a_high_left - [0,0,Corner_clamp_bearings_center_to_center + 2*b623_big_ugroove_big_r];
  a_high_right = a_high_left + [Sidelength,0,0];
  a_low_right = a_low_left + [Sidelength,0,0];
  for(i = [A, B, C, D]){
    translate(anchors[i])
      rotate([0,0,i*90])
        translate([0,-Sidelength/sqrt(8)+5,length_of_toolhead-50])
          rotate([0,0,-90])
            ABCD_anchor();
    action_high_left = rotation(a_high_left, i*90);
    action_low_left = rotation(a_low_left, i*90);
    action_high_right = rotation(a_high_right, i*90);
    action_low_right = rotation(a_low_right, i*90);

    line_from_to(pos + action_high_left, action_high_left + anchors[i]);
    line_from_to(pos + action_low_left, action_low_left + anchors[i]);
    line_from_to(pos + action_high_right, action_high_right + anchors[i]);
    line_from_to(pos + action_low_right, action_low_right + anchors[i]);
  }
}


data_collection_positions_standard = [[  -0.527094,   -0.634946,    0.      ],
                                      [-266.144   , -284.39    ,    0.      ],
                                      [ 240.691   , -273.008   ,    0.      ],
                                      [ 283.932   ,    7.41853 ,    0.      ],
                                      [ 304.608   ,  435.201   ,    0.      ],
                                      [-177.608   ,  438.733   ,    0.      ],
                                      [-369.145   ,   45.972   ,    0.      ],
                                      [-198.326   ,   25.0843  ,    0.      ],
                                      [  62.8474  ,  -55.7797  , 1388.51    ]];
                                      //[-465.720402,  -47.402828,  144.462088],
                                      //[-632.793181,  331.407685,  122.435335],
                                      //[-703.172374,  411.749689,   50.923223],
                                      //[-278.128747,  523.583008,   39.482521],
                                      //[ 441.360892,  672.851237,  123.346511],
                                      //[ 467.518466,  132.214308,  198.583508],
                                      //[  39.373078, -623.440677,  128.088103],
                                      //[-344.024592, -330.341518,  169.432092],
                                      //[-421.991046,   27.298237,  237.089385],
                                      //[-677.856009,  394.575547,  195.634237],
                                      //[-290.097311,  588.750296,  297.186251],
                                      //[ 473.710129,  653.111136,  207.072464],
                                      //[ 307.115412,  278.143918,  232.68222 ],
                                      //[  45.919828, -414.746019,  316.203898],
                                      //[ -28.007028, -776.782475,  232.726695],
                                      //[-338.464034, -217.561424,  269.973839],
                                      //[-644.658706,  365.415558,  318.17921 ],
                                      //[-343.384771,  391.053272,  412.917205],
                                      //[  70.982196,  550.599654,  509.60238 ],
                                      //[ 508.298514,  644.358488,  516.594187],
                                      //[ 238.492781,  -34.479055,  529.969725],
                                      //[  -7.909342, -660.701143,  520.943697],
                                      //[-312.373073, -177.474784,  578.96939 ],
                                      //[-510.821387,  300.767972,  600.966488],
                                      //[ -64.220889,   36.870639,  609.332198],
                                      //[  23.381683,  458.95078 ,  667.581437],
                                      //[ 306.075462,  473.876435,  817.046954],
                                      //[ 189.72739 ,  -72.936578,  805.059794],
                                      //[ -22.17987 , -518.797106,  882.381174],
                                      //[-277.601788,  -29.334304,  955.430122],
                                      //[ -65.297082,  279.999283,  954.259647],
                                      //[ -30.786666,  152.851294, 1153.945947]];//,
                                      //[  67.137601, -860.083044,  605.952846],
                                      //[ 284.655962, -102.262586,  867.814654],
                                      //[-560.690875,  -25.340757,  271.465517]];

hp_marks_measurements = [[-0.527094, -0.634946, -0.370821],
                         [-266.144, -284.39, 5.48368],
                         [240.691, -273.008, 1.84387],
                         [283.932, 7.41853, -0.878299],
                         [304.608, 435.201, 0.00422374],
                         [-177.608, 438.733, -1.03731],
                         [-369.145, 45.972, 3.83473],
                         [-198.326, 25.0843, 1.23042],
                         [-465.56, -47.6696, 148.958],
                         [-632.978, 330.731, 123.941],
                         [-703.697, 410.585, 53.9513],
                         [-277.863, 522.619, 36.4518],
                         [443.706, 670.927, 121.135],
                         [465.545, 131.309, 197.025],
                         [38.9178, -623.777, 137.685],
                         [-343.296, -331.299, 175.893],
                         [-419.43, 25.5785, 243.119],
                         [-684.896, 395.692, 186.824],
                         [-287.429, 587.691, 297.107],
                         [476.717, 650.558, 205.9],
                         [307.146, 275.748, 231.131],
                         [43.8489, -415.35, 318.255],
                         [-28.077, -777.228, 241.797],
                         [-339.945, -219.036, 269.015],
                         [-642.961, 364.091, 321.117],
                         [-340.953, 389.898, 413.864],
                         [75.86, 545.978, 511.986],
                         [510.734, 641.667, 514.656],
                         [238.593, -33.943, 528.039],
                         [-8.68617, -660.259, 526.475],
                         [-307.971, -177.118, 588.672],
                         [-506.395, 298.312, 602.812],
                         [-59.6972, 35.2041, 611.094],
                         [28.0547, 457.294, 667.879],
                         [308.339, 471.581, 815.545],
                         [189.286, -72.3184, 806.111],
                         [-23.5655, -517.217, 886.333],
                         [-275.386, -30.794, 959.031],
                         [-62.4441, 278.419, 954.677],
                         [-29.8298, 147.913, 1155.45],
                         [62.8474, -55.7797, 1388.51]];


if(mounted_in_ceiling && mover && !twod) {
  color([0.7, 0.2, 0.2], 0.5)
  bed();
}
module bed(){
  translate([-14,91,-2.5-ram_1000_3dpotter_height_diff])
    cube([800,800,5], center=true);
}

if(mounted_in_ceiling && mover && !twod){
  partial_way = min(1.3*($t*(len(data_collection_positions_standard)-1) - floor($t*(len(data_collection_positions_standard)-1))), 1);
  render_pos = (1-partial_way)*data_collection_positions_standard[$t*(len(data_collection_positions_standard)-1)]
               + partial_way*data_collection_positions_standard[$t*(len(data_collection_positions_standard)-1)+1];
  render_full_position(render_pos);
}
module render_full_position(pos = [100,0,0]) {
  mover(pos);
  i_lines(pos);
  translate(anchors[I]  + [0,0,33])
    rotate([180,0,0])
      full_winch();
  ABCD_anchors(pos);
}



//data_collection_points(hp_marks_measurements, 9, "cyan", "cyan");
//data_collection_points(data_collection_positions_standard, 9);
module data_collection_points(points, knowns = 0, color0 = "green", color1 = "blue") {
  for(i = [0:len(points)-1])
    translate(points[i])
      if(i < knowns)
        color(color0)
          sphere(d=25);
      else
        color(color1)
          sphere(d=25);

}
