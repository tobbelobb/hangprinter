include <parameters.scad>
use <sweep.scad>
use <util.scad>

%prev_art();
module prev_art(){
  import("../stl/motor_holder.stl");
}

motor_bracket();
module motor_bracket(){
  cw = Nema17_cube_width+3;
  cd = Nema17_cube_width+5.85;
  wall_th = Wall_th + 0.5;
  bd = 28.01;
  flerp = 18.01;
  flerp_h = 30.35;
  flerp_r = 8;
  difference(){
    translate([-cd/2, -wall_th, -cw/2])
      rounded_cube([cd, wall_th, cw], 1);
    translate([0,0,1.5])
      rotate([90,0,0]){
        translate([0,0,-1]){
          cylinder(d=Nema17_ring_diameter+2, h=wall_th+2);
          Nema17_screw_holes(3.5, wall_th+2, $fs=1);
        }
      }
  }
  for(k=[0,1])
    mirror([k,0,0]){
      translate([cd/2-wall_th,-bd+wall_th,-cw/2])
        rotate([90,0,0])
          difference(){
            linear_extrude(height=wall_th)
              rounded_2corner([flerp, flerp_h], flerp_r, $fn=4*6);
            translate([flerp-flerp_r,flerp_r,-1])
              rotate([0,0,90])
                translate([-5/2,-5/2,0])
                  round_ends([flerp_h-2*flerp_r+5, 5, wall_th+2], $fn = 5*4);
            translate([0,flerp_h,-1])
              mirror([0,1,0])
              inner_round_corner(r=1, h=wall_th+2, $fn=4*8);
          }
          translate([-cd/2,-bd+0.1,-cw/2+0.3])
            rounded_cube([wall_th, bd-0.2, flerp_h-0.3], 1);
    }
  translate([-(cd)/2, -bd, -cw/2])
    cube([cd, bd-1, wall_th]);

   // Round corners
   translate([0,0,-cw/2])
   linear_extrude(height=wall_th)
     translate([0,-2])
     rotate([0,0,90])
     translate([0,-cd/2])
     rounded_2corner([2, cd], 1, $fn=4*8);

   function my_outline(r) = concat([[-0.1, -0.1], [r,-0.1]],
     [for (i=[0:10:90])
       [r,r] + r*[cos(270-i), sin(270-i)]],
     [[-0.1, r]]);

   function my_path() = concat([translation([0,0,0]), translation([0,0,flerp_h-wall_th-1])],
   [for(i=[10:10:90])
     translation([0,0,flerp_h-wall_th-1])
     * translation([0,-1,0])
     * rotation([i,0,0])
     * translation([0,1,0])],
     [
     translation([0,-wall_th+2,0])
     * translation([0,0,flerp_h-wall_th-1])
     * translation([0,-1,0])
     * rotation([90,0,0])
     * translation([0,1,0])],
     [for(i=[1:1:10])
       translation([0,-wall_th+2-i/10,0])
       * translation([0,0,flerp_h-wall_th-1])
       * translation([0,-1,0])
       * rotation([90,0,0])
       * translation([0,1,0])
       * translation([sqrt(3)/2,sqrt(3)/2,0])
       * scaling([1+i/10,1+i/10,1])
       * translation([-sqrt(3)/2,-sqrt(3)/2, 0])]
     );


   for(k=[0,1]){
     mirror([k,0,0]){
       translate([-cd/2+wall_th,-wall_th,-cw/2+wall_th])
         rotate([0,0,-90])
         !sweep(my_outline(1),
             my_path());
       translate([-cd/2+wall_th,-bd,-cw/2+wall_th])
         rotate([-90,0,0])
         rotate([0,0,-90])
         inner_round_corner(r=1, h=bd-1.1, $fn=8*4);
     }
   }

   translate([0,-wall_th,-cw/2+wall_th])
   rotate([0,90,0])
   rotate([0,0,180])
   translate([0,0,-(cd-1)/2])
   inner_round_corner(r=1, h=cd-1, $fn=8*4);
}
