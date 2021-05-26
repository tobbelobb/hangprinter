include <parameters.scad>
use <whitelabel_motor.scad>

motor_bracket_C();
module motor_bracket_C(){
  mirror([1,0,0]) motor_bracket_extreme(true);
}
