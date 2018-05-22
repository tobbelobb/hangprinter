// TC5 Controller definition
// The main control loop is executed by the TC5 timer interrupt:

#include <SPI.h>
#include "State.h"
#include "Utils.h"
#include "Parameters.h"

void TC5_Handler() { // Gets called with FPID frequency
  static int print_counter = 0; // This is used by step response
  static char prev_mode;
  if (TC5->COUNT16.INTFLAG.bit.OVF == 1) {        // A counter overflow caused the interrupt
    y = lookup[readEncoder()];                    // Read encoder and lookup corrected angle in calibration lookup table
    if ((y - y_1) < -180.0) wrap_count += 1;      // Check if we've rotated more than a full revolution
    else if ((y - y_1) > 180.0) wrap_count -= 1;
    yw = (y + (360.0 * wrap_count));              // yw is the wrapped angle (can exceed one revolution)
    if (mode == 'h') {                            // Choose control algorithm based on mode
      hybridControl();                            // Hybrid control is still under development...
    } else {
      switch (mode) {
        case 'x': // Position control
          e = (r - yw);
          ITerm += (pKi * e); // Integral wind up limit
          if (ITerm > 150.0) ITerm = 150.0;
          else if (ITerm < -150.0) ITerm = -150.0;
          DTerm = pLPFa*DTerm -  pLPFb*pKd*(yw-yw_1);
          u = (pKp * e) + ITerm + DTerm;
          if(fabs(e) > 1800.0){ // We're faaar off. Someone might be stuck. Lower power for safety.
            if(fabs(e) < 3600.0){
              if(u > 0.0){
                u = 2.0*uMAX/3.0;
              } else {
                u = -2.0*uMAX/3.0;
              }
            } else { // We're even further off. Lower more.
              if(u > 0.0){
                u = uMAX/2.0;
              } else {
                u = -uMAX/2.0;
              }
            }
          }
          break;
        case 'v': // Velocity control
          v = vLPFa*v +  vLPFb*(yw-yw_1);   // Filtered velocity called "DTerm" because it is similar to derivative action in position loop
          e = (r - v);                      // Error in degrees per rpm (sample frequency in Hz * (60 seconds/min) / (360 degrees/rev))
          ITerm += (vKi * e);               // Integral wind up limit
          if (ITerm > 200) ITerm = 200;
          else if (ITerm < -200) ITerm = -200;
          u = ((vKp * e) + ITerm - (vKd * (e-e_1)));
          break;
        case 't': // Torque control
          u = 1.0 * torque;
          break;
        default:
          u = 0;
          break;
      }
      y_1 = y;  // Copy current value of y to previous value (y_1) for next control cycle before PA angle added
      /* Depending on direction we want to apply torque, add or subtract a phase angle of PA for max effective torque.
       * PA should be equal to one full step angle: if the excitation angle is the same as the current position, we would not move! */
      if (u > 0) {                // You can experiment with "Phase Advance" by increasing PA when operating at high speeds
        y += PA;                  // Update phase excitation angle
        if (u > uMAX) u = uMAX;   // Limit control effort
      } else {
        y -= PA;                  // Update phase excitation angle
        if (u < -uMAX) u = -uMAX; // Limit control effort
      }
      U = abs(u);
      if (abs(e) < 0.1) ledPin_HIGH(); // Turn on LED if error is less than 0.1
      else ledPin_LOW();
      output(-y, round(U)); // Update phase currents
    }
    e_1 = e;
    u_1 = u;
    yw_1 = yw;
    if (print_yw ==  true) { // For step resonse. still under development
      print_counter += 1;
      if (print_counter >= 5) { // Print position every 5th loop (every time is too much data for plotter and may slow down control loop
        SerialUSB.println(int(yw*1024)); //*1024 allows us to print ints instead of floats. May be faster
        print_counter = 0;
      }
    }
    TC5->COUNT16.INTFLAG.bit.OVF = 1; // Writing a one clears the flag ovf flag
  }
}
