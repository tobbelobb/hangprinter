include <parameters.scad>
use <util.scad>

//screws_space();
module screws_space(){
  flerp0 = 6;
  flerp1 = 6;
  l = Depth_of_lineroller_base + 2*b623_vgroove_big_r + 2*Bearing_wall + flerp0 + flerp1;
  translate([Depth_of_lineroller_base/2-2,0,0])
    for(a=[0:90:359])
      rotate([0,0,a])
        translate([Depth_of_lineroller_base/2+flerp0,0,0])
          cylinder(d1=Mounting_screw_head_d, d2=Mounting_screw_head_d-4, h=12);
}

//base(center=true, twod=true, openings=[true,false,true,true]);
module base(base_th = Base_th,
            flerp0 = 6,
            flerp1 = 6,
            center=false,
            twod=false,
            openings=[false, false, false, false]){
  l = Depth_of_lineroller_base + 2*b623_vgroove_big_r + 2*Bearing_wall + flerp0 + flerp1;
  for(k=[0,1])
  translate([+k*(l/2+Depth_of_lineroller_base/2),-k*(l/2-Depth_of_lineroller_base/2),0])
    translate([center ? -l/2 : -Depth_of_lineroller_base/2-flerp0, -Depth_of_lineroller_base/2, 0])
    rotate([0,0,k*90])
    difference(){
      if(twod){
        rounded_cube2([l, Depth_of_lineroller_base], Lineroller_base_r, $fn=13*4);
      } else {
        rounded_cube2([l, Depth_of_lineroller_base, base_th], Lineroller_base_r, $fn=13*4);
      }
      for(x=[Depth_of_lineroller_base/2-2, l - (Depth_of_lineroller_base/2-2)])
        translate([x, Depth_of_lineroller_base/2, -1])
          if(twod)
            circle(d=Mounting_screw_d, $fs=1);
          else
            cylinder(d=Mounting_screw_d, h=base_th+2, $fs=1);
    }
  for(i=[0:4])
    if(twod && openings[i])
      translate([center ? 0 : l/2-Depth_of_lineroller_base/2-flerp0,0,0])
      rotate([0,0,i*90])
        translate([l/2-1,-1])
          square([6,2]);
}

function foot_shape(r, e, f, w) = concat([
  for(i=[90:10:181])
     [-e-Lineroller_wall_th+r,f+w-r] + r*[cos(i), sin(i)]
  ],
  [for(i=[180:10:271])
     [-e-Lineroller_wall_th+r,-f+r] + r*[cos(i), sin(i)]
  ],
  [for(i=[270:10:361])
     [-r,-f+r] + r*[cos(i), sin(i)]
  ],
  [for(i=[0:10:91])
     [-r,w+f-r] + r*[cos(i), sin(i)]
  ]);

function wall_shape(a, w, extr) = 1 - (sin(a*90))*extr/((w/2)+extr); // a 0 -> 1

lineroller_ABC_winch(edge_start=0, edge_stop = 180, with_base=true);
module lineroller_ABC_winch(base_th = Base_th, edge_start=0, edge_stop=180, tower_h = Tower_h, bearing_width=b623_width, shoulder=0.4, with_base=false, twod = false, big_y_r = 190, big_z_r=94){
  module wall(){
    // Foot parameters
    c = 10;
    e = 5.52;
    //f = 2.5; // extra x-length for swung wall
    w = b623_vgroove_big_r*2+2*Bearing_wall;

    q = 3.9;
    round_part = 0.65;
    // Main block
    r2 = b623_bore_r+1.3;
    foot_shape_r = 1.0;
    f = Depth_of_lineroller_base-w-2*foot_shape_r; // extra x-length for swung wall

    b_th = Lineroller_wall_th+e;
    top_off_r = -foot_shape_r+b623_vgroove_big_r;

    translate([0, -(bearing_width + 2*Wall_th)/2, 0])
      rotate([-90,-90,0]){
        difference(){
          union(){
            // Foot with a swing
            translate([0,0,Lineroller_wall_th])
              translate([tower_h-b623_vgroove_big_r,w/2,0])
                difference(){
                  translate([-tower_h+b623_vgroove_big_r, -(w+f+2*foot_shape_r)/2, -b_th])
                    cube([tower_h-foot_shape_r, w+f+2*foot_shape_r, b_th]);
                  translate([0,-big_y_r-w/2,-15])
                    cylinder(r=big_y_r, h=30, $fn=250);
                  translate([0,+big_y_r+w/2,-15])
                    cylinder(r=big_y_r, h=30, $fn=250);
                  translate([top_off_r, -w/2-0.1, -15])
                    rotate([0,0,90])
                      inner_round_corner(r=top_off_r, h=30, back=5, $fn=50);
                  translate([top_off_r, w/2+0.1, -15])
                    rotate([0,0,180])
                      inner_round_corner(r=top_off_r, h=30, back=5, $fn=50);
                  translate([0,0,-big_z_r-Wall_th])
                    rotate([90,0,0])
                      cylinder(r=big_z_r, h=30, center=true, $fn=250);
                  translate([-0.1-tower_h+b623_vgroove_big_r,-(w+f+2*foot_shape_r+20)/2,-15])
                    cube([base_th, w+f+2*foot_shape_r+20, 30]);
                }
            translate([tower_h-b623_vgroove_big_r,b623_vgroove_big_r+Bearing_wall,0]){
              cylinder(r=r2, h=Lineroller_wall_th+shoulder, $fs=1);
              dpth = 1.5;
              translate([0,0,-dpth])
              hexagon_for_nut(h=dpth);
            }

          }
          translate([tower_h-b623_vgroove_big_r,b623_vgroove_big_r+Bearing_wall,-1])
            cylinder(d=b623_bore_r*2+0.3, h=Lineroller_wall_th+0.5+2, $fs=1);
        }
      }
    // Edge to prevent line from falling of...
    a = 1.75;
    b= 0.8;
    rot_r = b623_vgroove_big_r+b;
    difference(){
      translate([b623_vgroove_big_r+Bearing_wall, -bearing_width/2-0.8, tower_h - b623_vgroove_big_r])
        rotate([-90,0,0])
          difference(){
            rotate_extrude(angle=180, convexity=10, $fn=60)
              translate([rot_r,0])
                polygon(points = [[0,0], [0,-0.5], [b+a, -0.5], [b+a,0], [b, a], [0, a]]);
            rotate([0,0,edge_stop])
              translate([0,0,-1])
                linear_extrude(height=b+a+1)
                  polygon(points=circle_sector(360-(edge_stop-edge_start), 1, rot_r+b+a+1));
            rotate([0,0,edge_start])
              translate([rot_r-1,0,0])
                rotate([45,0,0])
                  cube(b+a+1);
            rotate([0,0,edge_stop])
              translate([rot_r-1,0,0])
                rotate([45,0,0])
                  cube(b+a+1);
          }
      translate([-10,-10,0])
        cube([10,10,tower_h]);
      translate([2*b623_vgroove_big_r+2*Bearing_wall,-10,0])
        cube([10,10,tower_h]);
    }
  }

  if(!twod){
    difference(){
      union(){
        wall();
        mirror([0,1,0])
          wall();
      }
      screws_space();
    }
  }
  if(with_base)
    base(twod=twod, openings=[true,false,true,false]);
}
