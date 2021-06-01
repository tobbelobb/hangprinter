use <lib/whitelabel_motor.scad>

motor_bracket_B();
module motor_bracket_B(twod=false){
  motor_bracket_extreme(leftHanded=true, twod=twod, text="B");
}
