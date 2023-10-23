use <lib/whitelabel_motor.scad>

motor_bracket_B();
module motor_bracket_B(twod=false){
  mirror([1,0,0]) motor_bracket_extreme(twod=twod, text="B");
}
