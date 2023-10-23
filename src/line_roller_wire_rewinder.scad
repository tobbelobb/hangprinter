include <lib/parameters.scad>
use <lib/util.scad>

bearing_lift = b608_vgroove_small_r+Gap_between_sandwich_and_plate + Sep_disc_radius - Spool_r;

//walls(b608_width+0.8, Line_roller_wall_th, Line_roller_ABCD_winch_h, with_bearing=false);
module walls(space_between_walls, wall_th, height, rot_nut=0, bearing_screw=true, with_bearing=true){
  d = 2*b608_vgroove_big_r;

  translate([0,-space_between_walls/2 - wall_th + 0, Base_th-0.05])
    rotate([90,0,-90])
      translate([0,0,-d/2-3])
        inner_round_corner(h=d+3, r=5, ang=90, back=1.5, $fn=6*4);
  translate([0,space_between_walls/2 + wall_th - 0, Base_th-0.05])
    rotate([90,0,90])
      translate([0,0,-d/2])
        inner_round_corner(h=d+3, r=5, ang=90, back=1.5, $fn=6*4);
  translate([10.1,-8/2,bearing_lift+b608_outer_dia/2+3])
    difference(){
      cube([6, 8, 5]);
      translate([6/2,8/2,0.3])
        cylinder(d=2.7, h=10);
      translate([6/2,8/2,-1])
        translate([0,0,6-3.3-0.4])
          eyelet(h=10);

    }

  translate([0,0,bearing_lift]){
    if (with_bearing) {
      %rotate([90,0,0])
        difference(){
          b608_vgroove();
          M8_screw(h=40, center=true);
        }
    }
    for (k = [0,1]) mirror([0,k,0])
      difference(){
        union(){
          translate([-d/2, space_between_walls/2,-height+d/2-10])
            cube([d+3, wall_th, height+16]);
          translate([0, b608_width/2-0.1, 0])
            rotate([-90,0,0])
              cylinder(r=8.1/2 + 1.5, h=wall_th, $fn=24);
        }
        translate([0,0,6])
          rotate([-90,0,0])
            inner_round_corner(r=d/2, h=d, center=true, $fn=4*7);
        if(bearing_screw){
          translate([0,space_between_walls/2 - 1, 0])
            rotate([-90,0,0]){
              M8_screw(h=wall_th+2);
              translate([0,0,1+wall_th - min(wall_th/2, 2)])
                rotate([0,0,rot_nut])
                  M8_nut(h=8);
            }
        }
      }
  }
}

module base_2d(){
  w = 29.2;
  l = 44;
  translate([1.5,0,0])
  difference(){
    translate([-w/2,-l/2])
      rounded_cube2_2d([w, l], r=3, $fn=4*8);
    for(mirrx = [0,1])
      for(mirry = [0,1])
        mirror([mirrx,0,0]){
          mirror([0,mirry,0])
            translate([w/2-4.5,-l/2+4.5])
              Mounting_screw(twod=true);
    }
  }
}

module base(){
  linear_extrude(height=Base_th)
    base_2d();
}

line_roller_wire_rewinder(with_bearings=false, twod=false);
module line_roller_wire_rewinder(twod=false,
                          tower_h = Line_roller_ABCD_winch_h,
                          with_bearings=false){

  s = b608_width + 0.8;
  wall_th = Line_roller_wall_th;

  if(!twod){
    difference() {
      union(){
        walls(s, wall_th, tower_h, with_bearing=with_bearings);
      }
      translate([0,0,-50])
        cube(100, center=true);
      translate([-40/2,-Spool_height-1-Spool_height/2-1, Base_th])
        cube([40,Spool_height+1, Gap_between_sandwich_and_plate+(Sep_disc_radius-Spool_r)/2 + (Sep_disc_radius - Spool_r)/sqrt(2)]);
      translate([-40/2,-Spool_height-1-Spool_height/2, Gap_between_sandwich_and_plate+(Sep_disc_radius-Spool_r)/2])
        translate([0,Spool_height,(Sep_disc_radius - Spool_r)])
          rotate([-45,0,0])
            translate([0,-Spool_height,-(Sep_disc_radius - Spool_r)])
              cube([40,Spool_height, Sep_disc_radius - Spool_r]);
    }

    difference(){
      translate([-b608_vgroove_big_r,-b608_width/2-1,  0])
        cube([2*(b608_vgroove_big_r)+3,b608_width+2,  bearing_lift]);
      translate([0,0,bearing_lift])
        rotate([90,0,0])
          cylinder(r=b608_vgroove_big_r+2, h=b608_width+4, center=true, $fn=4*12);
      translate([-2*b608_vgroove_big_r-3,-b608_width/2-1,  bearing_lift - b608_vgroove_big_r - 2])
        cube([2*(b608_vgroove_big_r)+3,b608_width+2,  bearing_lift]);
    }
    base();

  } else {
    base_2d();
  }
}

