// Declarations of control loop state variables

/* Interrupt vars */
volatile int U = 0; // Control effort (abs)
volatile float r = 0.0; // Setpoint
volatile float torque = -40.0; // Torque setpoint
volatile float y = 0.0; // Measured angle
volatile float v = 0.0; // Estimated velocity (velocity mode)
volatile float yw = 0.0; // "wrapped" angle (not limited to 0-360)
volatile float yw_1 = 0.0;
volatile float yw_ref = 0.0;
volatile float e = 0.0; // e = r-y (error)
volatile float e_1 = 0.0;
volatile float p = 0.0; // Proportional effort
volatile float i = 0.0; // Integral effort
volatile float u = 0.0; // Real control effort (not abs)
volatile float u_1 = 0.0; // Value of u at previous time step, etc...
volatile long counter = 0;
volatile long wrap_count = 0; // Keeps track of how many revolutions the motor has gone though (so you can command angles outside of 0-360)
volatile float y_1 = 0;
volatile long step_count = 0; // For step/dir interrupt (closed loop)
int stepNumber = 0; // Open loop step number (used by 's' and for cal routine)
volatile float ITerm;
volatile float DTerm;
char mode;
char prev_mode;
volatile bool dir = false;
bool print_yw = false; // For step response, under development...
