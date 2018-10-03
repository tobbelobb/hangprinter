include <parameters.scad>
use <util.scad>
use <line_roller_single.scad>

//!eyelet();
module eyelet(){
  hi = 3.45;
  color("sandybrown")
  difference(){
    union(){
      cylinder(d=3.42,h=hi);
      translate([0,0,hi-1])
        cylinder(d=4.66, h=1);
    }
    translate([0,0,-1])
      cylinder(d=1.75,h=hi+2);
  }
}


space_between_walls = b623_width + 0.8;
tower_h = Gap_between_sandwich_and_plate
          + Sep_disc_radius
          - Spool_r
          + Depth_of_roller_base/2
          + b623_vgroove_small_r;

//rotate([90,0,0])
//horizontal_line_deflector();
module horizontal_line_deflector(){
  cx = b623_vgroove_big_r*2 + 7;
  cy = 20;
  bz = Gap_between_sandwich_and_plate + Sep_disc_radius - Spool_r;
  bit_y = cy;
  module bit(){
    rotate([0,0,90])
      translate([-Bit_width/2, -bit_y/2, 0])
      difference(){
        one_rounded_cube2([Bit_width+4,bit_y,Base_th], 5.5, $fn=28);
      }
  }

  extra_b_height = 1.3; // half of this above, half below
  extra_b_width = 1.5; // half of this to the left of bearing, half to the right
  full_h = bz+8;
  take_away_angle = 90;

  // something to aim for
  //translate([0,-b623_vgroove_small_r,bz])
  //  b623_vgroove();
  difference(){
    translate([-cx/2, -cy+5, 0])
      //cube([cx, cy, bz+5]);
      ydir_rounded_cube2([cx, cy, full_h], 3, $fn=4*6);
    translate([0,-b623_vgroove_small_r-1,bz]){
      //#cylinder(r=b623_vgroove_big_r+1,h=b623_width+extra_b_height,center=true);
      scale([(b623_vgroove_big_r+extra_b_width/2)/b623_vgroove_big_r,
             (b623_vgroove_big_r+extra_b_width/2)/b623_vgroove_big_r,
             (b623_width + extra_b_height)/b623_width]){
        elong_b623_vgroove(20);
        rotate([0,0,-90-take_away_angle/2])
        translate([0,0,-b623_width/2])
        linear_extrude(height=b623_width, convexity=4)
          polygon(points=circle_sector(take_away_angle, 1, b623_vgroove_big_r, 40));
        //cylinder(r=b623_vgroove_big_r, h=b623_width, center=true);
      }
    }
    translate([0,-b623_vgroove_small_r,-1]){
      cylinder(d=3.3, h=100, center=true, $fn=12); // The M3 screw
      nut(h=bz+1-b623_width/2-extra_b_height/2 - 5);
      translate([0,0,full_h - 1.5])
        nut(h=10);
    }
    sly = 40;
    for(k=[0,1])
      mirror([k,0,0])
    translate([b623_vgroove_small_r,-sly,bz-0.5])
      cube([100,sly, 1]);

    //translate([(cx-4)/2, ])
    //cube([cx-4, b623_vgroove_big_r*2 + 2, b623_width+2]);
  }

  shoulder_height = extra_b_height/2;
  for(hl=[-(b623_width+extra_b_height)/2-2+shoulder_height,
           (b623_width+extra_b_height)/2 - shoulder_height])
    translate([0,-b623_vgroove_small_r, hl+bz])
      difference(){
        cylinder(d=5, h=2, $fn=12);
        translate([0,0,-1])
          cylinder(d=3.3, h=4, $fn=12); // The ring to rest b623_vgroove bore on
      }

  pl = 5.5;
  ybit = -cy+5+bit_y/2;
  ybit_hole = ybit + 4;
  for(k=[0,1])
    mirror([k,0,0]){
      difference(){
        union(){
          translate([cx/2,-cy+5,Base_th])
            rotate([0,-90,-90])
            inner_round_corner(r=2, h=cy, $fn=4*5, back=Base_th-0.1);
          translate([cx/2+pl,ybit,0])
            rotate([0,0,90])
            bit();
        }
        translate([cx/2,5,Base_th])
          corner_rounder();
        translate([cx/2+pl,ybit_hole,2.3])
          Mounting_screw_countersink();
      }
    }

  //translate([0,-cy+5-pl,0])
  //  bit();
  //difference(){
  //  translate([0,-cy+5,Base_th])
  //    rotate([90,0,-90])
  //    translate([0,0,-Bit_width/2])
  //    inner_round_corner(r=2, h=Bit_width, $fn=4*5);
  //  translate([0,-cy+5-pl,2.3])
  //    Mounting_screw_countersink();
  //}
}

//eyelet_holder(Depth_of_roller_base);
module eyelet_holder(w){
  bx = Depth_of_roller_base/2;
  translate([bx/2,
      0,
      tower_h-Depth_of_roller_base/2 + b623_vgroove_small_r])
    difference(){
      translate([-bx/2, -w/2, -5])
        cube([bx, w, 9]);
      translate([-bx/2+b623_vgroove_small_r,0,-3])
        cylinder(d=3.35, h=10);
      translate([-bx/2,0,-5])
        scale(1.05)
        rotate([90,0,0])
        cylinder(r=b623_vgroove_big_r, h=Depth_of_roller_base+2, center=true);
    }
}

//line_verticalizer();
module line_verticalizer(){
  line_roller_single(tower_h=tower_h);
  eyelet_holder(Depth_of_roller_base);
}

//rotate([0,90,0])
//translate([-b623_vgroove_small_r,0,0])
line_verticalizer_thin();
module line_verticalizer_thin(twod = false, with_bearing = false){
  wall_w = 5;
  difference(){
    union(){
      roller_wall(space_between_walls, wall_w, tower_h);
      mirror([0,1,0])
        roller_wall(space_between_walls, wall_w, tower_h);
      preventor_edges(tower_h, space_between_walls, edge_stop=110);
      //roller_base();
      // Custom base
      translate([-Depth_of_roller_base/2, -Roller_l/2, 0])
        left_rounded_cube2([Depth_of_roller_base, Roller_l, Base_th], r=8,
                           $fn=13*4);
      translate([-Depth_of_roller_base/2-Roller_fl,-Depth_of_roller_base/2,0])
        left_rounded_cube2([Depth_of_roller_base+Roller_fl, Depth_of_roller_base, Base_th], r=8,
                         $fn=13*4);

      for(k=[0,1])
        mirror([0,k,0])
          translate([-Depth_of_roller_base/2,-Depth_of_roller_base/2, 0])
          rotate([0,0,180])
          inner_round_corner(r=2, h=Base_th, $fn=6*4); // Fillet
      inner_round_corner(r=4, h=Base_th);
      eyelet_holder(2*wall_w+space_between_walls);
      for(k=[0,1])
        mirror([0,k,0])
          translate([0,space_between_walls/2 + wall_w, Base_th])
          rotate([90,0,90])
          translate([0,0,-(Depth_of_roller_base+10)/2])
          inner_round_corner(h=Depth_of_roller_base+10, r=5, back=0.1, $fn=4*5);
    }
    translate([Depth_of_roller_base/2, -50/2])
      cube([10,50,50]);
    for(ang=[0:90:359])
      rotate([0,0,ang]){
        translate([14,0,2.3])
        Mounting_screw_countersink();
      translate([Depth_of_roller_base/2+5,0,5+Base_th])
        rotate([90,0,0])
        cylinder(r=5, h=50, center=true,$fn=4*5);
      translate([Depth_of_roller_base/2+2, Depth_of_roller_base/2+2,-1]){
        cylinder(r=2, h=Base_th+5, $fn=4*6);
        translate([0,-2,0])
          cube([10, 4, Base_th+5]);
        translate([-2,0,0])
          cube([4, 10, Base_th+5]);
      }
    }
    for(k=[0,1])
      mirror([0,k,0])
      translate([-Roller_l/2,-Depth_of_roller_base/2,-1])
      rotate([0,0,0])
      inner_round_corner(r=8, h=Base_th+3,$fn=4*13);
    //translate([Depth_of_roller_base/2+2, Depth_of_roller_base/2+2,-1])

    //translate([Depth_of_roller_base/2,space_between_walls/2+wall_w,Base_th])
    //  corner_rounder(0, 5, [20,20]);
  }
}
