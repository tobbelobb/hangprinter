include <parameters.scad>
use <whitelabel_motor.scad>

motor_bracket_D();
module motor_bracket_D(twod=false){
  motor_bracket_extreme(leftHanded=false, twod=twod);
}
