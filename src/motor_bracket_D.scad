use <lib/whitelabel_motor.scad>

motor_bracket_D();
module motor_bracket_D(twod=false){
  mirror([1,0,0]) motor_bracket_extreme(leftHanded=false, twod=twod, "D");
}
