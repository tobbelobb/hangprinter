// Declarations of state variables for the control loop

#ifndef __STATE_H__
#define __STATE_H__

/* interrupt vars */
extern volatile int U; // Control effort (abs)
extern volatile float r; // Setpoint
extern volatile float torque; // Setpoint
extern volatile float y; // Measured angle
extern volatile float v; // Estimated velocity (velocity loop)
extern volatile float yw;
extern volatile float yw_ref;
extern volatile float yw_1;
extern volatile float e; // e = r-y (error)
extern volatile float p; // Proportional effort
extern volatile float i; // Integral effort
extern volatile float u; // Real control effort (not abs)
extern volatile float u_1;
extern volatile float e_1;
extern volatile long counter;
extern volatile long wrap_count;
extern volatile float y_1;
extern volatile long step_count; // For step/dir interrupt
extern int stepNumber; // Step index for cal routine
extern volatile float ITerm;
extern volatile float DTerm;
extern char mode;
extern int dir;
extern bool print_yw; // For step response, under development...
#endif
