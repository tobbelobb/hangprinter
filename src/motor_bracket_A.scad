include <parameters.scad>
use <whitelabel_motor.scad>

motor_bracket_A();
module motor_bracket_A(twod=false){
  mirror([1,0,0]) motor_bracket_extreme(leftHanded=false, twod=twod, "A");
}
