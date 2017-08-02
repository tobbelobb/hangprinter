//Contains TC5 Controller definition
//The main control loop is executed by the TC5 timer interrupt:

#include <SPI.h>

#include "State.h"
#include "Utils.h"
#include "Parameters.h"


void TC5_Handler() {                // gets called with FPID frequency

  static int print_counter = 0;               //this is used by step response
  static char prev_mode;

  if (TC5->COUNT16.INTFLAG.bit.OVF == 1) {    // A counter overflow caused the interrupt
    //TEST1_HIGH();  //digitalWrite(3, HIGH);       //Fast Write to Digital 3 for debugging

    y = lookup[readEncoder()];                    //read encoder and lookup corrected angle in calibration lookup table

    if ((y - y_1) < -180.0) wrap_count += 1;      //Check if we've rotated more than a full revolution (have we "wrapped" around from 359 degrees to 0 or ffrom 0 to 359?)
    else if ((y - y_1) > 180.0) wrap_count -= 1;

    yw = (y + (360.0 * wrap_count));              //yw is the wrapped angle (can exceed one revolution)


    if (mode == 'h') {                            //choose control algorithm based on mode
      hybridControl();                            // hybrid control is still under development...
    }
    else {
      switch (mode) {
        case 'x':         // position control
            e = (r - yw);

            ITerm += (pKi * e);                             //Integral wind up limit
            if (ITerm > 150.0) ITerm = 150.0;
            else if (ITerm < -150.0) ITerm = -150.0;

            DTerm = pLPFa*DTerm -  pLPFb*pKd*(yw-yw_1);

            u = (pKp * e) + ITerm + DTerm;


            break;

        case 'v':         // velocity controlr
          v = vLPFa*v +  vLPFb*(yw-yw_1);     //filtered velocity called "DTerm" because it is similar to derivative action in position loop

          e = (r - v);   //error in degrees per rpm (sample frequency in Hz * (60 seconds/min) / (360 degrees/rev) )

          ITerm += (vKi * e);                 //Integral wind up limit
          if (ITerm > 200) ITerm = 200;
          else if (ITerm < -200) ITerm = -200;

          u = ((vKp * e) + ITerm - (vKd * (e-e_1)));

          //SerialUSB.println(e);
          break;

        case 't': // torque control
          u = 1.0 * torque;
          break;
        default:
          u = 0;
          break;
      }

    y_1 = y;  //copy current value of y to previous value (y_1) for next control cycle before PA angle added


    if (u > 0)          //Depending on direction we want to apply torque, add or subtract a phase angle of PA for max effective torque.  PA should be equal to one full step angle: if the excitation angle is the same as the current position, we would not move!
      {                 //You can experiment with "Phase Advance" by increasing PA when operating at high speeds
      y += PA;          //update phase excitation angle
      if (u > uMAX)     // limit control effort
        u = uMAX;       //saturation limits max current command
      }
    else
      {
      y -= PA;          //update phase excitation angle
      if (u < -uMAX)    // limit control effort
        u = -uMAX;      //saturation limits max current command
      }

      U = abs(u);       //

      if (abs(e) < 0.1) ledPin_HIGH();    // turn on LED if error is less than 0.1
      else ledPin_LOW();                  //digitalWrite(ledPin, LOW);


      output(-y, round(U));    // update phase currents
    }

   // e_3 = e_2;    //copy current values to previous values for next control cycle
    e_2 = e_1;    //these past values can be useful for more complex controllers/filters.  Uncomment as necessary
    e_1 = e;
   // u_3 = u_2;
    u_2 = u_1;
    u_1 = u;
    yw_1 = yw;
    //y_1 = y;

    if (print_yw ==  true){       //for step resonse... still under development
      print_counter += 1;
      if (print_counter >= 5){    // print position every 5th loop (every time is too much data for plotter and may slow down control loop
        SerialUSB.println(int(yw*1024));    //*1024 allows us to print ints instead of floats... may be faster
        print_counter = 0;
      }
    }
    TC5->COUNT16.INTFLAG.bit.OVF = 1;    // writing a one clears the flag ovf flag
    //TEST1_LOW();            //for testing the control loop timing
  }


}








