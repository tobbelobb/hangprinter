include <parameters.scad>
use <util.scad>
use <lineroller_ABC_winch.scad>

// The base parameters
base_th = 6;
main_x = 32;
main_y = 32;

side_extra = 9;
slot_x = main_x - side_extra;
slot_0_y = side_extra;
slot_1_y = main_y - side_extra;

head_r = 3.5;   // Max r of countersunc screw in slot
screw_r = 1.5;

b623_sep = Anchor_bearings_center_to_center+ 4 + 3;
z_clearance = 1;
b623_sep_and_clear = b623_sep + z_clearance;

full_height = base_th + 2 + b623_sep_and_clear + b623_width + 2 + 5;

wall_th_around_b623 = 2.5;
b_and_holder_dia = b623_outer_dia + 2*wall_th_around_b623;
clearance_d = b_and_holder_dia+2;

holder_cube_x = 17;

module vgroove_bearing(){
  $fn=4*8;
  cylinder(r=b623_vgroove_small_r, h=b623_width+2, center=true);
  for(k=[0,0,1])
    mirror([0,0,k]){
      cylinder(r1=b623_vgroove_small_r, r2=b623_vgroove_big_r, h=b623_width/2);
      translate([0,0,b623_width/2])
        cylinder(r=b623_vgroove_big_r, h=1);
    }
}

// Modelled to sit in positive quadrant
//the_base();
module the_base(){
  //!slot_for_countersunk_screw();
  module slot_for_countersunk_screw(){
    rotate([0,0,180]){
      translate([0,0,Screw_h+Screw_head_h-0.01])
        linear_extrude(height=1)
        scale(1+(head_r-screw_r)/screw_r)
        translate([0,-screw_r])
        union(){
          square([main_x-screw_r, 2*screw_r]);
          translate([0,screw_r])
            circle(r=screw_r,$fn=4*10);
        }
      linear_extrude(height=Screw_h+1)
        translate([0,-screw_r])
        union(){
          square([main_x-screw_r, 2*screw_r]);
          translate([0,screw_r])
            circle(r=screw_r,$fn=4*10);
        }
      translate([0,0,Screw_h])
        linear_extrude(height=Screw_head_h, scale=1+(head_r-screw_r)/screw_r)
        translate([0,-screw_r])
        union(){
          square([main_x-screw_r, 2*screw_r]);
          translate([0,screw_r])
            circle(r=screw_r,$fn=4*10);
        }
    }
  }

  base_mid();
  module base_mid(){
    difference(){
      //translate([-wing_x, -main_y/2, 0])
      translate([main_x, main_y,0])
        rotate([0,0,180])
        rounded_cube2([main_x, main_y, base_th], Lineroller_base_r, $fn=10*4);
      translate([slot_x, slot_0_y, -0.1])
        slot_for_countersunk_screw();
      translate([slot_x, slot_1_y, -0.1])
        slot_for_countersunk_screw();
    }
  }
}

//the_top();
module the_top(){
  translate([0,0,base_th-0.01])
    cylinder(r2 = 3, r1 = b623_outer_dia/2, h=2, $fn=40); // Press against lower 623
  translate([0,0,base_th + 2 + b623_sep_and_clear + b623_width])
    cylinder(r1 = 3, r2 = b623_outer_dia/2, h=2, $fn=40); // Press against higher 623
  translate([0,0,base_th + 2 + 0.3])
    cylinder(r=3, h=b623_sep_and_clear+b623_width-0.6); // A little support structure
  translate([-b623_outer_dia/2, -(b623_outer_dia)/2 ,base_th + 2 + b623_sep_and_clear + b623_width + 2])
    hull(){
      ang = 89.75;
      translate([b623_outer_dia/2, b623_outer_dia/2, 0])
        cylinder(d=b623_outer_dia, h=5, $fn=40);
      translate([b623_outer_dia/2+1, b623_outer_dia/2, 0])
        linear_extrude(height=5, scale=[1.0, 0.807])
        rotate([0,0,-ang/2])
        polygon(points=circle_sector(ang, (clearance_d+0.56)/2, (clearance_d-0.94)/2, 40));
    }

  difference(){
    hull(){
      translate([b623_outer_dia/2, -main_y/2,base_th-1])
        rounded_cube2([main_x-b623_outer_dia, main_y, 1], Lineroller_base_r, $fn=40);
      translate([0, -b623_outer_dia/2 ,base_th + 2 + b623_sep_and_clear + b623_width + 2])
        round_ends([b623_outer_dia*1.5, b623_outer_dia, 5], $fn=40);
    }
    for(k = [1, -1])
      rotate([0,0,k*60]){
        translate([-20, -clearance_d/2, 0])
          cube([20, clearance_d, 100]);
      }
    cylinder(d=clearance_d, h=100, $fn=4*6);
  }
}

stationary_part();
module stationary_part(){
  difference(){
    union(){
      translate([-b623_outer_dia/2, -main_y/2,0])
        the_base();
      the_top();
    }
    translate([0,0,-1])
      nut(h=base_th+1-2);
    translate([0,0,full_height-2])
      nut(h=3);
    cylinder(d=3.1, h=100);
  }
}

module mounted_render(){
  stationary_part();
  rotate([0,0,180])
    translate([0,0,base_th+2+b623_width/4 + z_clearance/2])
    bearing_holder();
}

translate([0,30,0])
bearing_holder();
module bearing_holder(){
  holder_cube_z = b623_sep+b623_width/2;
  difference(){
    union(){
      cylinder(d=b_and_holder_dia, h=b623_sep+b623_width/2);
      translate([0, -b_and_holder_dia/2, 0])
        cube([holder_cube_x, b_and_holder_dia, holder_cube_z]);
    }
    translate([0,0,-1])
      cylinder(d=3.1, h=100);
    translate([0,0,-b623_width/4])
      cylinder(d=b623_outer_dia+0.1, h=b623_width, $fn=16);
    translate([0,0,-b623_width/4 + b623_sep])
      cylinder(d=b623_outer_dia+0.1, h=b623_width);

    // Round holder cube corners
    translate([holder_cube_x,0,-0.1])
      rotate([90,-90,0])
      translate([0,0,-30])
      inner_round_corner(r=3, h=60, $fn=4*4);
    mirror([0,0,1])
      translate([holder_cube_x,0,-holder_cube_z])
      rotate([90,-90,0])
      translate([0,0,-30])
      inner_round_corner(r=3, h=60, $fn=4*4);

    translate([b623_outer_dia/2+1,-b623_width/2 - 0.25,-1])
      cube([holder_cube_x, b623_width + 0.5, holder_cube_z + 2]);

    translate([holder_cube_x - 3 - 1.5, 0, 4.5 + Anchor_bearings_center_to_center])
      rotate([90,0,0])
      cylinder(d=3.1, h=40, center=true, $fn=6); // Screw through v-groove bearing
    for(k=[0,1])
      mirror([0, k, 0])
      translate([holder_cube_x-4.5, -b623_width/2-0.25-2.5, 4.5+Anchor_bearings_center_to_center])
      rotate([90,0,0])
      cylinder(d=5.6/cos(30), h=4, $fn=6); // Nutlocks
    translate([holder_cube_x - 3 - 1.5, 0, 4.5 + Anchor_bearings_center_to_center])
      rotate([90,0,0])
      cylinder(d=3.1, h=40, center=true, $fn=6); // Screw through v-groove bearing

  }
  translate([0,0,3*b623_width/4])
    cylinder(r=2, h=0.2); // Bridge the vertical screw hole for easier printing
  // The "virtual" bearing at the bottom
  intersection(){
    union(){
      translate([holder_cube_x,0,-0.1])
        rotate([90,-90,0])
        translate([0,0,-30])
        cylinder(r=3, h=60, $fn=4*4); // Just to not have ugly bottom
      translate([holder_cube_x - 3 - 1.5, 0, 4.5])
        rotate([90,0,0])
        vgroove_bearing();
    }
      difference(){
        translate([0, -b_and_holder_dia/2, 0])
          cube([holder_cube_x, b_and_holder_dia, holder_cube_z]);
        translate([holder_cube_x,0,-0.1])
          rotate([90,-90,0])
          translate([0,0,-30])
          inner_round_corner(r=3, h=60, $fn=4*4);
      }
  }
  // Teardrop shoulder
  for(k=[0,1])
    mirror([0, k, 0])
    translate([holder_cube_x-4.5, -2.25 + 0.2, 4.5+Anchor_bearings_center_to_center])
    rotate([90,0,0])
  difference(){
    teardrop(r=3.7/2, h=0.2, $fn=16);
    translate([0,0,-1])
      teardrop(r=3.1/2, h=2.2, $fn=16);
  }
}

