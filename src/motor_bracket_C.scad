use <lib/whitelabel_motor.scad>

motor_bracket_C();
module motor_bracket_C(twod=false){
  motor_bracket_extreme(leftHanded=true, twod=twod, text="C");
}
