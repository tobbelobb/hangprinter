include <lib/parameters.scad>
use <lib/util.scad>

height_from_platform = Line_roller_ABC_winch_h + 175 + Wall_th;

module beam(twist){
  rotate([0,0,90-twist])
  translate([-100,-Beam_width/2, height_from_platform])
    cube([200, Beam_width, Beam_width]);
}

th = 20;
th2 = 44;
module gaping_mouth(twist=0){
  difference(){
    union(){
      rotate([0,0,-twist]){
        for(k=[0,1])
          rotate([0,0,k*180])
            translate([Beam_width/2,
                -(th/cos(abs(twist))+abs(twist))/2,
                Line_roller_ABC_winch_h + 175 + Wall_th])
            rotate([0,45,0])
            translate([0,0,-15])
            cube([5, th/cos(abs(twist))+abs(twist), 60]); // Gaping mouth
        hull(){
          for(k=[0,1])
            rotate([0,0,k*180])
              translate([Beam_width/2,
                  -(th/cos(abs(twist))+abs(twist))/2,
                  Line_roller_ABC_winch_h + 175 + Wall_th])
              rotate([0,45,0])
              translate([0,0,-15])
              cube([5, th/cos(abs(twist))+abs(twist), 15]); // Gaping mouth
        }
      }
    }
    translate([-100,-200-th/2,170])
      cube(200);
    translate([-100,th/2,170])
      cube(200);
  }
}

print_these();
module print_these(){
  rotate([90,0,0]){
    landing_bracket_c();
    translate([112,0,0])
      landing_bracket_b();
    translate([-110,0,0])
      landing_bracket_a();
  }

}

module landing_bracket_b(twist=-30, twod=false){
  landing_bracket_a(twist=twist, twod=twod);
}

module landing_bracket_c(twist=-30, twod=false){
  mirror([1,0,0])
    landing_bracket_b(twist, twod);
}

//landing_bracket_a(twod=true);
module landing_bracket_a(tunnel=true, twist=0, rightside=1, twod=false){
  twist = twist - 360*(floor(twist/360)) - 180;
  if (!twod) {
    difference(){
      union(){
        linear_extrude(height = Line_roller_ABC_winch_h + 175 + Wall_th)
          translate([-th/2, -th/2, 0])
          square([th, th]);
        difference(){
          if(floor((twist+45+180)/90)%2 == 1)
            rotate([0,0,90])
              gaping_mouth(twist=90+twist);
          else
              gaping_mouth(twist=twist);
        }
        difference(){
          translate([-th2/2, -th/2,0])
            ydir_rounded_cube2([th2, th + (th2-th)/2, 5], r=5.5, $fn=13*4);
          for(k=[0,rightside])
            mirror([k,0]){
              translate([th2/2-5.5,th/2 +  (th2-th)/2 - 5.5,3])
                Mounting_screw_countersink();
              translate([th2/2-5.5, 2 ,3])
                Mounting_screw_countersink();
            }
        }

        for(x=[0, rightside])
          mirror([x, 0])
            translate([0,-th/2,5])
              standing_triangle([th2/2, 5, Line_roller_ABC_winch_h+175-Wall_th],bottom=1);
        for(x=[0, 1])
          mirror([x, 0]){
            translate([th/2, 0, 5])
              rotate([0,0,90])
              standing_triangle([th2/2, 5, Line_roller_ABC_winch_h+175-Wall_th],bottom=1);
          }
      }
      if(tunnel)
        cube([10,50,53], center=true);
    }
  } else {
    difference(){
      translate([-th2/2, -th/2,0])
        ydir_rounded_cube2_2d([th2, th + (th2-th)/2, 5], r=5.5, $fn=13*4);
      for(k=[0,rightside])
        mirror([k,0]){
          translate([th2/2-5.5,th/2 +  (th2-th)/2 - 5.5])
            Mounting_screw_countersink(twod);
          translate([th2/2-5.5, 2])
            Mounting_screw_countersink(twod);
        }
    }
    //color("sandybrown")
    //  beam(twist);
  }
}


//standing_triangle([35, 5, 144]);
module standing_triangle(v, bottom=0){
  x = v[0];
  y = v[1];
  z = v[2];

  translate([0,y,0])
    rotate([90,0,0])
    linear_extrude(height=y)
    polygon([[0,-bottom],[x,-bottom],[x,0],[0,z]]);
}
