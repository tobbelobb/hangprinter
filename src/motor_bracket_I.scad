use <lib/whitelabel_motor.scad>

motor_bracket_I();
module motor_bracket_I(twod=false){
  motor_bracket_extreme(leftHanded=false, twod=twod, text="I");
}
