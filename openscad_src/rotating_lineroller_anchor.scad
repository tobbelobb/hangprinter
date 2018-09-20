include <parameters.scad>
use <util.scad>
use <lineroller_ABC_winch.scad>

// The base parameters
base_th = 6;
main_x = 32;
main_y = Depth_of_lineroller_base;
wing_x = main_y-4;
wing_y = main_y - 2;
slot_x = main_x - main_y/2;
slot_0_y = main_y/2;
slot_1_y = main_y + wing_y/2 - 1;
head_r = 3.5;   // Max r of countersunc screw in slot
screw_r = 1.5;

translate([-b623_outer_dia/2-2, -main_y/2,0])
  the_base();
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
        three_rounded_cube2([main_x, main_y, base_th], Lineroller_base_r, $fn=10*4);
      translate([slot_x, slot_0_y, -0.1])
        slot_for_countersunk_screw(main_x);
    }
  }

  base_wing();
  module base_wing(){
    difference(){
      union(){
        translate([main_x-wing_x, main_y, 0]) // Rotate and translate
          ydir_rounded_cube2([wing_x, wing_y, base_th], Lineroller_base_r, $fn=10*4);
        translate([main_x-wing_x, main_y, 0])
          rotate([0,0,90])
          inner_round_corner(r=2, h=base_th, $fn=4*7);
      }
      translate([slot_x, slot_1_y, -0.1])
        slot_for_countersunk_screw(wing_x);
    }
  }
}

//the_top();
module the_top(){
  translate([0,0,base_th-0.01]){
    difference(){ // Press against lower 623
      cylinder(r2 = 3, r1 = 6, h=3);
      translate([0,0,-1])
        cylinder(d = 3.1, h = 5);
    }
    //translate([0,0,base_th + b623_sep + b623_width])

  }
}
