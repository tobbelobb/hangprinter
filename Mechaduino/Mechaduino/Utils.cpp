#include <SPI.h>
#include <Wire.h>
#include "Parameters.h"
#include "Controller.h"
#include "Utils.h"
#include "State.h"
#include "analogFastWrite.h"

void setupPins() {
  pinMode(VREF_2, OUTPUT);
  pinMode(VREF_1, OUTPUT);
  pinMode(IN_4, OUTPUT);
  pinMode(IN_3, OUTPUT);
  pinMode(IN_2, OUTPUT);
  pinMode(IN_1, OUTPUT);
  pinMode(chipSelectPin, OUTPUT); // CSn -- has to toggle high and low to signal chip to start data transfer
  #ifdef ENABLE_PROFILE_IO
    pinMode(TEST1, OUTPUT);
  #endif
  pinMode(ledPin, OUTPUT);
  analogFastWrite(VREF_2, 0.33 * uMAX);
  analogFastWrite(VREF_1, 0.33 * uMAX);
  IN_4_HIGH();   //  digitalWrite(IN_4, HIGH);
  IN_3_LOW();    //  digitalWrite(IN_3, LOW);
  IN_2_HIGH();   //  digitalWrite(IN_2, HIGH);
  IN_1_LOW();    //  digitalWrite(IN_1, LOW);
}

void setupSPI() {
  SPISettings settingsA(10000000, MSBFIRST, SPI_MODE1);
  SPI.begin(); //AS5047D SPI uses mode=1 (CPOL=0, CPHA=1)
  SerialUSB.println("Beginning SPI communication with AS5047 encoder...");
  delay(1000);
  SPI.beginTransaction(settingsA);
}

void giveAngle() {
  float ang = yw - yw_ref;
  Wire.write((byte*)&ang, 4);
}

void handle_cmd(int numBytes) {
  if(numBytes >= 1){
    uint8_t cmd = Wire.read();
    if(cmd == 0x5f){ // 95 in hexadecimal is 0x5f
      if(numBytes == 5){ // Should receive a float upon G95
        union {
          uint8_t b[4]; // hard coded 4 instead of sizeof(float)
          float fval;
        } requested_torque;
        int i = 0;
        while(Wire.available()){
          requested_torque.b[i] = Wire.read();
          i++;
        }
        if(fabs(requested_torque.fval) < 0.01){
          r = yw;  // Set pos/vel setpoint to current position
          mode = 'x';
        } else if(fabs(requested_torque.fval) < 255.0) {
          torque = requested_torque.fval;
          mode = 't';
        } // TODO: Don't know if positive torques are ever desired... Filter them out?
      }
    } else if(cmd == 0x60){ // 96 in hexadecimal is 0x60
      yw_ref = yw;
    }
  }
}

/* There's only three types of interactions on the i2c line:
 *  - RAMPS tells Mechaduino to go into torque mode or go into position mode
 *  - RAMPS tells Mechaduino to fixate its reference angle
 *  - RAMPS requests current angle of Mechaduino (relative to reference angle) */
void setupI2C() {
  Wire.begin(I2C_ID);
  Wire.onRequest(giveAngle);
  Wire.onReceive(handle_cmd);
}

void configureStepDir() {
  pinMode(step_pin, INPUT);
  pinMode(dir_pin, INPUT);
  attachInterrupt(step_pin, stepInterrupt, RISING);
  attachInterrupt(dir_pin, dirInterrupt, CHANGE);
  dirInterrupt(); // Ensure right direction from start
}

void configureEnablePin() {
  pinMode(enable_pin, INPUT);
  attachInterrupt(enable_pin, enableInterrupt, CHANGE);
}

void stepInterrupt() {
  if (dir) r += stepangle;
  else r -= stepangle;
}

void dirInterrupt() {
  if (REG_PORT_IN0 & PORT_PA11) dir = false; // check if dir_pin is HIGH
  else dir = true;
}

void enableInterrupt() {           // Enable pin interrupt handler
  if (REG_PORT_IN0 & PORT_PA14) {  // Check if enable_pin is HIGH
    disableTCInterrupts();
    analogFastWrite(VREF_2, 0.33 * uMAX);
    analogFastWrite(VREF_1, 0.33 * uMAX);
  } else {
    enableTCInterrupts();
  }
}

void output(float theta, int effort) {
  int angle_1;
  int angle_2;
  int v_coil_A;
  int v_coil_B;
  int sin_coil_A;
  int sin_coil_B;
  int phase_multiplier = 10 * spr / 4;
  angle_1 = mod((phase_multiplier * theta), 3600);
  angle_2 = mod((phase_multiplier * theta) + 900, 3600);
  sin_coil_A  = sin_1[angle_1];
  sin_coil_B = sin_1[angle_2];
  v_coil_A = ((effort * sin_coil_A) / 1024);
  v_coil_B = ((effort * sin_coil_B) / 1024);
  analogFastWrite(VREF_1, abs(v_coil_A));
  analogFastWrite(VREF_2, abs(v_coil_B));
  if (v_coil_A >= 0) {
    IN_2_HIGH();  //REG_PORT_OUTSET0 = PORT_PA21;     //write IN_2 HIGH
    IN_1_LOW();   //REG_PORT_OUTCLR0 = PORT_PA06;     //write IN_1 LOW
  } else {
    IN_2_LOW();   //REG_PORT_OUTCLR0 = PORT_PA21;     //write IN_2 LOW
    IN_1_HIGH();  //REG_PORT_OUTSET0 = PORT_PA06;     //write IN_1 HIGH
  }
  if (v_coil_B >= 0) {
    IN_4_HIGH();  //REG_PORT_OUTSET0 = PORT_PA20;     //write IN_4 HIGH
    IN_3_LOW();   //REG_PORT_OUTCLR0 = PORT_PA15;     //write IN_3 LOW
  } else {
    IN_4_LOW();   //REG_PORT_OUTCLR0 = PORT_PA20;     //write IN_4 LOW
    IN_3_HIGH();  //REG_PORT_OUTSET0 = PORT_PA15;     //write IN_3 HIGH
  }
}

void calibrate() {
  int encoderReading = 0; // or float?  not sure if we can average for more res?
  int currentencoderReading = 0;
  int lastencoderReading = 0;
  int avg = 10; // How many readings to average
  int iStart = 0; // Encoder zero position index
  int jStart = 0;
  int stepNo = 0;
  int fullStepReadings[spr];
  int fullStep = 0;
  int ticks = 0;
  float lookupAngle = 0.0;
  SerialUSB.println("Beginning calibration routine...");
  encoderReading = readEncoder();
  dir = true;
  oneStep();
  delay(500);
  if ((readEncoder() - encoderReading) < 0) { // Check which way motor moves when dir = true
    SerialUSB.println("Wired backwards");     // Rewiring either phase should fix this. You may get a false message if you happen to be near the point where the encoder rolls over...
    return;
  }
  while (stepNumber != 0) { // Go to step zero
    if (stepNumber > 0) {
      dir = true;
    } else {
      dir = false;
    }
    oneStep();
    delay(100);
  }
  dir = true;
  for (int x = 0; x < spr; x++) { // Step through all full step positions, recording their encoder readings
    encoderReading = 0;
    delay(100); // Moving too fast may not give accurate readings. Motor needs time to settle after each step.
    lastencoderReading = readEncoder();
    for (int reading = 0; reading < avg; reading++) { // Average multple readings at each step
      currentencoderReading = readEncoder();
      if ((currentencoderReading-lastencoderReading)<(-(cpr/2))) {
        currentencoderReading += cpr;
      } else if ((currentencoderReading-lastencoderReading)>((cpr/2))) {
        currentencoderReading -= cpr;
      }
      encoderReading += currentencoderReading;
      delay(10);
      lastencoderReading = currentencoderReading;
    }
    encoderReading = encoderReading / avg;
    if (encoderReading>cpr) {
      encoderReading-= cpr;
    } else if (encoderReading<0) {
      encoderReading+= cpr;
    }
    fullStepReadings[x] = encoderReading;
    SerialUSB.print(100.0*x/spr,1);
    SerialUSB.println("%");
    oneStep();
  }
  for (int i = 0; i < spr; i++) {
    ticks = fullStepReadings[mod((i + 1), spr)] - fullStepReadings[mod((i), spr)];
    if (ticks < -15000) {
      ticks += cpr;
    } else if (ticks > 15000) {
      ticks -= cpr;
    }
    if (ticks > 1) { // Note starting point with iStart,jStart
      for (int j = 0; j < ticks; j++) {
        stepNo = (mod(fullStepReadings[i] + j, cpr));
        if (stepNo == 0) {
          iStart = i;
          jStart = j;
        }
      }
    }
    if (ticks < 1) { // Note starting point with iStart,jStart
      for (int j = -ticks; j > 0; j--) {
        stepNo = (mod(fullStepReadings[spr - 1 - i] + j, cpr));
        if (stepNo == 0) {
          iStart = i;
          jStart = j;
        }
      }
    }
  }
  SerialUSB.println(" ");          // The code below generates the lookup table by intepolating between full steps and mapping each encoder count to a calibrated angle
  SerialUSB.println("newLookup:"); // The lookup table is too big to store in volatile memory, so we must generate and print it on the fly
  SerialUSB.println(" ");          // In the future, we hope to be able to print this directly to non-volatile memory
  for (int i = iStart; i < (iStart + spr + 1); i++) {
    ticks = fullStepReadings[mod((i + 1), spr)] - fullStepReadings[mod((i), spr)];
    if (ticks < -15000) {          // Check if current interval wraps over encoder's zero positon
      ticks += cpr;
    } else if (ticks > 15000) {
      ticks -= cpr;
    }
    /* Here we print an interpolated angle corresponding to each encoder count (in order) */
    if (ticks > 1) { // If encoder counts were increasing during cal routine...
      if (i == iStart) { // This is an edge case
        for (int j = jStart; j < ticks; j++) {
          lookupAngle = 0.001 * mod(1000 * ((aps * i) + ((aps * j ) / float(ticks))), 360000.0);
          SerialUSB.print(lookupAngle);
          SerialUSB.print(" , ");
        }
      } else if (i == (iStart + spr)) { // This is an edge case
        for (int j = 0; j < jStart; j++) {
          lookupAngle = 0.001 * mod(1000 * ((aps * i) + ((aps * j ) / float(ticks))), 360000.0);
          SerialUSB.print(lookupAngle);
          SerialUSB.print(" , ");
        }
      } else { // This is the general case
        for (int j = 0; j < ticks; j++) {
          lookupAngle = 0.001 * mod(1000 * ((aps * i) + ((aps * j ) / float(ticks))), 360000.0);
          SerialUSB.print(lookupAngle);
          SerialUSB.print(" , ");
        }
      }
    } else if (ticks < 1) { // Similar to above. For case when encoder counts were decreasing during cal routine.
      if (i == iStart) {
        for (int j = - ticks; j > (jStart); j--) {
          lookupAngle = 0.001 * mod(1000 * (aps * (i) + (aps * ((ticks + j)) / float(ticks))), 360000.0);
          SerialUSB.print(lookupAngle);
          SerialUSB.print(" , ");
        }
      } else if (i == iStart + spr) {
        for (int j = jStart; j > 0; j--) {
          lookupAngle = 0.001 * mod(1000 * (aps * (i) + (aps * ((ticks + j)) / float(ticks))), 360000.0);
          SerialUSB.print(lookupAngle);
          SerialUSB.print(" , ");
        }
      } else {
        for (int j = - ticks; j > 0; j--) {
          lookupAngle = 0.001 * mod(1000 * (aps * (i) + (aps * ((ticks + j)) / float(ticks))), 360000.0);
          SerialUSB.print(lookupAngle);
          SerialUSB.print(" , ");
        }
      }
    }
  }
  SerialUSB.println(" ");
}

void serialCheck() { // Monitors serial for commands. Must be called in routinely in loop for serial interface to work.
  if (SerialUSB.available()) {
    char inChar = (char)SerialUSB.read();
    switch (inChar) {
      case 'p': // Print
        print_angle();
        break;
      case 's': // Step
        oneStep();
        print_angle();
        break;
      case 'd': // Change direction
        if (dir) {
          dir = false;
        } else {
          dir = true;
        }
        break;
      case 'w': // Print absolute pos
        SerialUSB.println(yw, 2);
        SerialUSB.println(yw_ref, 2);
        SerialUSB.println(yw - yw_ref, 2);
        break;
      case 'c':
        calibrate(); // Calibration routine
        break;
      case 'e':
        readEncoderDiagnostics(); // Encoder error?
        break;
      case 'y':
        enableTCInterrupts(); // Enable closed loop
        break;
      case 'n':
        disableTCInterrupts(); // Disable closed loop
        break;
      case 'r': // New setpoint
        SerialUSB.println("Enter setpoint:");
        while (SerialUSB.available() == 0)  {}
        r = SerialUSB.parseFloat();
        SerialUSB.println(r);
        break;
      case 'o': // New torque setpoint
        SerialUSB.println("Enter torque setpoint:");
        while (SerialUSB.available() == 0)  {}
        torque = SerialUSB.parseFloat();
        SerialUSB.println(torque);
        break;
      case 'x': // Enable position mode
        mode = 'x';
        break;
      case 'v': // Enable velocity mode
        mode = 'v';
        break;
      case 't': // Enable torque mode
        mode = 't';
        break;
      case 'h': // Enable hybrid mode
        mode = 'h';
        break;
      case 'q': // Print copy-able parameters
        parameterQuery();
        break;
      case 'a':
        antiCoggingCal();
        break;
      case 'k':
        parameterEditmain();
        break;
      case 'g':
        sineGen();
        break;
      case 'm':
        serialMenu();
        break;
      case 'j':
        stepResponse();
        break;
      default:
        break;
    }
  }
}

void parameterQuery() { // Print current parameters in a format that can be copied directly in to Parameters.cpp
  SerialUSB.println(' ');
  SerialUSB.println("----Current Parameters-----");
  SerialUSB.println(' ');
  SerialUSB.println(' ');
  SerialUSB.print("volatile float Fs = ");
  SerialUSB.print(Fs, DEC);
  SerialUSB.println(";  //Sample frequency in Hz");
  SerialUSB.println(' ');
  SerialUSB.print("volatile float pKp = ");
  SerialUSB.print(pKp, DEC);
  SerialUSB.println(";      //position mode PID vallues.");
  SerialUSB.print("volatile float pKi = ");
  SerialUSB.print(pKi, DEC);
  SerialUSB.println(";");
  SerialUSB.print("volatile float pKd = ");
  SerialUSB.print(pKd, DEC);
  SerialUSB.println(";");
  SerialUSB.print("volatile float pLPF = ");
  SerialUSB.print(pLPF, DEC);
  SerialUSB.println(";");
  SerialUSB.println(' ');
  SerialUSB.print("volatile float vKp = ");
  SerialUSB.print(vKp, DEC);
  SerialUSB.println(";      //velocity mode PID vallues.");
  SerialUSB.print("volatile float vKi = ");
  SerialUSB.print(vKi , DEC);
  SerialUSB.println(";");
  SerialUSB.print("volatile float vKd = ");
  SerialUSB.print(vKd, DEC);
  SerialUSB.println(";");
  SerialUSB.print("volatile float vLPF = ");
  SerialUSB.print(vLPF, DEC);
  SerialUSB.println(";");
  SerialUSB.println("");
  SerialUSB.println("//This is the encoder lookup table (created by calibration routine)");
  SerialUSB.println("");
  SerialUSB.println("const float lookup[] = {");
  for (int i = 0; i < 16384; i++) { // cpr = 16384
    SerialUSB.print(lookup[i]);
    SerialUSB.print(", ");
  }
  SerialUSB.println("");
  SerialUSB.println("};");
}

void oneStep() {
  if (!dir) {
    stepNumber += 1;
  } else {
    stepNumber -= 1;
  }
  output(aps * stepNumber, (int)(0.33 * uMAX));
  delay(10);
}

int readEncoder() {
  long angleTemp;
  CHIPSELECT_LOW();
  byte b1 = SPI.transfer(0xFF);
  byte b2 = SPI.transfer(0xFF);
  angleTemp = (((b1 << 8) | b2) & 0B0011111111111111);
  CHIPSELECT_HIGH();
  return angleTemp;
}

void readEncoderDiagnostics() {
  long angleTemp;
  CHIPSELECT_LOW();

  SerialUSB.println("------------------------------------------------");
  SerialUSB.println("Checking AS5047 diagnostic and error registers");
  SerialUSB.println("See AS5047 datasheet for details");
  SerialUSB.println(" ");
  SPI.transfer(0xFF);
  SPI.transfer(0xFC);
  CHIPSELECT_HIGH();
  delay(1);
  CHIPSELECT_LOW();
  byte b1 = SPI.transfer(0xC0);
  byte b2 = SPI.transfer(0x00);
  SerialUSB.print("Check DIAAGC register (0x3FFC) ...  ");
  SerialUSB.println(" ");
  angleTemp = (((b1 << 8) | b2) & 0B1111111111111111);
  SerialUSB.println((angleTemp | 0B1110000000000000000 ), BIN);
  if (angleTemp & (1 << 14)) SerialUSB.println("Error occurred  ");
  if (angleTemp & (1 << 11)) SerialUSB.println("MAGH - magnetic field strength too high, set if AGC = 0x00. This indicates the non-linearity error may be increased");
  if (angleTemp & (1 << 10)) SerialUSB.println("MAGL - magnetic field strength too low, set if AGC = 0xFF. This indicates the output noise of the measured angle may be increased");
  if (angleTemp & (1 << 9))  SerialUSB.println("COF - CORDIC overflow. This indicates the measured angle is not reliable");
  if (angleTemp & (1 << 8))  SerialUSB.println("LF - offset compensation completed. At power-up, an internal offset compensation procedure is started, and this bit is set when the procedure is completed");
  if (!((angleTemp & (1 << 14)) | (angleTemp & (1 << 11)) | (angleTemp & (1 << 10)) | (angleTemp & (1 << 9))))  SerialUSB.println("Looks good!");
  SerialUSB.println(" ");
  CHIPSELECT_HIGH();
  delay(1);
  CHIPSELECT_LOW();
  SPI.transfer(0x40);
  SPI.transfer(0x01);
  CHIPSELECT_HIGH();
  delay(1);
  CHIPSELECT_LOW();
  b1 = SPI.transfer(0xC0);
  b2 = SPI.transfer(0x00);
  SerialUSB.print("Check ERRFL register (0x0001) ...  ");
  SerialUSB.println(" ");
  angleTemp = (((b1 << 8) | b2) & 0B1111111111111111);
  SerialUSB.println((angleTemp | 0B1110000000000000000 ), BIN);
  if (angleTemp & (1 << 14)) {
    SerialUSB.println("  Error occurred  ");
  }
  if (angleTemp & (1 << 2)) {
    SerialUSB.println("  parity error ");
  }
  if (angleTemp & (1 << 1)) {
    SerialUSB.println("  invalid register  ");
  }
  if (angleTemp & (1 << 0)) {
    SerialUSB.println("  framing error  ");
  }
  if (!((angleTemp & (1 << 14)) | (angleTemp & (1 << 2)) | (angleTemp & (1 << 1)) | (angleTemp & (1 << 0))))  SerialUSB.println("Looks good!");
  SerialUSB.println(" ");
  CHIPSELECT_HIGH();
  delay(1);
}


void print_angle() {
  int avg = 10; // Average a few readings
  int encoderReading = 0;
  int rawReading = 0;
  float anglefloat = 0.0;
  disableTCInterrupts(); // Can't use readEncoder while in closed loop
  for (int reading = 0; reading < avg; reading++) { // Average multple readings at each step
    encoderReading += readEncoder();
    delay(10);
  }
  anglefloat = encoderReading * 0.02197265625 / avg; // 360/16384 = 0.021972....
  SerialUSB.print("stepNumber: ");
  SerialUSB.print(stepNumber, DEC);
  SerialUSB.print(" , ");
  SerialUSB.print("Angle: ");
  SerialUSB.println(anglefloat, 2);
}

void receiveEvent(int howMany) {
  while (1 < Wire.available()) { // Loop through all but the last
    char c = Wire.read(); // Receive byte as a character
    SerialUSB.print(c); // Print the character
  }
  int x = Wire.read(); // Receive byte as an integer
  SerialUSB.println(x); // Print the integer
  r = 0.1 * ((float)x);
}

int mod(int xMod, int mMod) {
  return (xMod % mMod + mMod) % mMod;
}

void setupTCInterrupts() { // Configure the controller interrupt
  /* Enable GCLK for TC4 and TC5 (timer counter input clock) */
  GCLK->CLKCTRL.reg = (uint16_t) (GCLK_CLKCTRL_CLKEN | GCLK_CLKCTRL_GEN_GCLK0 | GCLK_CLKCTRL_ID(GCM_TC4_TC5));
  while (GCLK->STATUS.bit.SYNCBUSY);
  TC5->COUNT16.CTRLA.reg &= ~TC_CTRLA_ENABLE;          // Disable TCx
  WAIT_TC16_REGS_SYNC(TC5)                             // Wait for sync
    TC5->COUNT16.CTRLA.reg |= TC_CTRLA_MODE_COUNT16;   // Set Timer counter Mode to 16 bits
  WAIT_TC16_REGS_SYNC(TC5)
    TC5->COUNT16.CTRLA.reg |= TC_CTRLA_WAVEGEN_MFRQ;   // Set TC as normal Normal Frq
  WAIT_TC16_REGS_SYNC(TC5)
    TC5->COUNT16.CTRLA.reg |= TC_CTRLA_PRESCALER_DIV1; // Set perscaler
  WAIT_TC16_REGS_SYNC(TC5)
    TC5->COUNT16.CC[0].reg = (int)( round(48000000 / Fs)); // 0x3E72; //0x4AF0;
  WAIT_TC16_REGS_SYNC(TC5)
    TC5->COUNT16.INTENSET.reg = 0;                     // Disable all interrupts
  TC5->COUNT16.INTENSET.bit.OVF = 1;                   // Enable overfollow
  TC5->COUNT16.INTENSET.bit.MC0 = 1;                   // Enable compare match to CC0
  NVIC_SetPriority(TC5_IRQn, 1);                       // Set interrupt priority
  NVIC_EnableIRQ(TC5_IRQn);                            // Enable InterruptVector
}

void enableTCInterrupts() { // Enables the controller interrupt ("closed loop mode")
  TC5->COUNT16.CTRLA.reg |= TC_CTRLA_ENABLE; // Enable TC5
  WAIT_TC16_REGS_SYNC(TC5)                   // Wait for sync
}

void disableTCInterrupts() { // Disables the controller interrupt ("closed loop mode")
  TC5->COUNT16.CTRLA.reg &= ~TC_CTRLA_ENABLE; // Disable TC5
  WAIT_TC16_REGS_SYNC(TC5)                    // Wait for sync
}

/* This is still under development.
 * The idea is that we can calibrate out the stepper motor's detent torque
 * by measuring the torque required to hold all possible positions. */
void antiCoggingCal() {
  SerialUSB.println(" -----------------BEGIN ANTICOGGING CALIBRATION!----------------");
  mode = 'x';
  r = lookup[1];
  enableTCInterrupts();
  delay(1000);
  for (int i = 1; i < 657; i++) {
    r = lookup[i];
    SerialUSB.print(r, DEC);
    SerialUSB.print(" , ");
    delay(100);
    SerialUSB.println(u, DEC);
  }
  SerialUSB.println(" -----------------REVERSE!----------------");
  for (int i = 656; i > 0; i--) {
    r = lookup[i];
    SerialUSB.print(r, DEC);
    SerialUSB.print(" , ");
    delay(100);
    SerialUSB.println(u, DEC);
  }
  SerialUSB.println(" -----------------DONE!----------------");
  disableTCInterrupts();
}

void parameterEditmain() {
  SerialUSB.println();
  SerialUSB.println("Edit parameters:");
  SerialUSB.println();
  SerialUSB.println("p ----- position loop");
  SerialUSB.println("v ----- velocity loop");
  SerialUSB.println("o ----- other");
  SerialUSB.println("q ----- quit");
  SerialUSB.println();
  while (SerialUSB.available() == 0)  {}
  char inChar2 = (char)SerialUSB.read();
  switch (inChar2) {
    case 'p':
      {
        parameterEditp();
      }
      break;

    case 'v':
      {
        parameterEditv();
      }
      break;

    case 'o':
      {
        parameterEdito();
      }
      break;
    default:
      {}
      break;
  }
}

void parameterEditp() {
  bool quit = false;
  while(!quit){
    SerialUSB.println("Edit position loop gains:");
    SerialUSB.println();
    SerialUSB.print("p ----- pKp = ");
    SerialUSB.println(pKp, DEC);
    SerialUSB.print("i ----- pKi = ");
    SerialUSB.println(pKi, DEC);
    SerialUSB.print("d ----- pKd = ");
    SerialUSB.println(pKd, DEC);
    SerialUSB.print("l----- LPF = ");
    SerialUSB.println(pLPF,DEC);
    SerialUSB.println("q ----- quit");
    SerialUSB.println();
    while (SerialUSB.available() == 0)  {}
    char inChar3 = (char)SerialUSB.read();
    switch (inChar3) {
      case 'p':
        {
          SerialUSB.println("pKp = ?");
          while (SerialUSB.available() == 0)  {}
          pKp = SerialUSB.parseFloat();
          SerialUSB.print("new pKp = ");
          SerialUSB.println(pKp, DEC);
          SerialUSB.println("");
        }
        break;
      case 'i':
        {
          SerialUSB.println("pKi = ?");
          while (SerialUSB.available() == 0)  {}
          pKi = SerialUSB.parseFloat();
          SerialUSB.print("new pKi = ");
          SerialUSB.println(pKi, DEC);
          SerialUSB.println("");
        }
        break;
      case 'd':
        {
          SerialUSB.println("pKd = ?");
          while (SerialUSB.available() == 0)  {}
          pKd = SerialUSB.parseFloat();
          SerialUSB.print("new pKd = ");
          SerialUSB.println(pKd, DEC);
          SerialUSB.println("");
        }
        break;
      case 'l':
        {
          SerialUSB.println("pLPF = ?");
          while (SerialUSB.available() == 0)  {}
          pLPF = SerialUSB.parseFloat();
          pLPFa = exp(pLPF*-2*3.14159/Fs);
          pLPFb = (1.0-pLPFa);
          SerialUSB.print("new pLPF = ");
          SerialUSB.println(pLPF, DEC);
          SerialUSB.println("");
        }
        break;
      case 'q':
        {
          quit = true;
          SerialUSB.println("");
          SerialUSB.println("done...");
          SerialUSB.println("");
        }
      default:
        {}
        break;
    }
  }
}

void parameterEditv() {
  bool quit = false;
  while(!quit) {
    SerialUSB.println("Edit velocity loop gains:");
    SerialUSB.println();
    SerialUSB.print("p ----- vKp = ");
    SerialUSB.println(vKp, DEC);
    SerialUSB.print("i ----- vKi = ");
    SerialUSB.println(vKi, DEC);
    SerialUSB.print("d ----- vKd = ");
    SerialUSB.println(vKd, DEC);
    SerialUSB.print("l ----- vLPF = ");
    SerialUSB.println(vLPF, DEC);
    SerialUSB.println("q ----- quit");
    SerialUSB.println();
    while (SerialUSB.available() == 0)  {}
    char inChar4 = (char)SerialUSB.read();
    switch (inChar4) {
      case 'p':
        {
          SerialUSB.println("vKp = ?");
          while (SerialUSB.available() == 0)  {}
          vKp = SerialUSB.parseFloat();
          SerialUSB.print("new vKp = ");
          SerialUSB.println(vKp, DEC);
        }
        break;
      case 'i':
        {
          SerialUSB.println("vKi = ?");
          while (SerialUSB.available() == 0)  {}
          vKi = SerialUSB.parseFloat();
          SerialUSB.print("new vKi = ");
          SerialUSB.println(vKi, DEC);
        }
        break;
      case 'd':
        {
          SerialUSB.println("vKd = ?");
          while (SerialUSB.available() == 0)  {}
          vKd = SerialUSB.parseFloat();
          SerialUSB.print("new vKd = ");
          SerialUSB.println(vKd, DEC);
        }
        break;
      case 'l':
        {
          SerialUSB.println("vLPF = ?");
          while (SerialUSB.available() == 0)  {}
          vLPF = SerialUSB.parseFloat();
          vLPFa = (exp(vLPF*-2*3.14159/Fs));
          vLPFb = (1.0-vLPFa)* Fs * 0.16666667;
          SerialUSB.print("new vLPF = ");
          SerialUSB.println(vLPF, DEC);
          SerialUSB.println("");
        }
        break;
      case 'q':
        {
          quit = true;
          SerialUSB.println("");
          SerialUSB.println("done...");
          SerialUSB.println("");
        }
      default:
        {}
        break;
    }
  }
}

void parameterEdito() {
  SerialUSB.println("Edit other parameters:");
  SerialUSB.println();
  SerialUSB.print("p ----- PA = ");
  SerialUSB.println(PA, DEC);
  SerialUSB.println();
  while (SerialUSB.available() == 0)  {}
  char inChar3 = (char)SerialUSB.read();
  switch (inChar3) {
    case 'p':
      {
        SerialUSB.println("PA = ?");
        while (SerialUSB.available() == 0)  {}
        PA = SerialUSB.parseFloat();
        SerialUSB.print("new PA = ");
        SerialUSB.println(PA, DEC);
      }
      break;
    default:
      {}
      break;
  }
}

void hybridControl() { // Under development
  static int missed_steps = 0;
  /* Hybrid stepping current level.
   * In this mode, this current is continuous (unlike closed loop mode).
   * Be very careful raising this value as you risk overheating the A4954 driver! */
  static float iLevel = 0.6;
  static float rSense = 0.15;
  if (yw < r - aps) {
    missed_steps -= 1;
  } else if (yw > r + aps) {
    missed_steps += 1;
  }
  output(0.1125 * (-(r - missed_steps)), (255 / 3.3) * (iLevel * 10 * rSense));
}

void serialMenu() {
  SerialUSB.println("");
  SerialUSB.println("");
  SerialUSB.println("----- Mechaduino 0.X -----");
  SerialUSB.print("Firmware: ");
  SerialUSB.println(firmware_version);
  SerialUSB.print("Identifier: ");
  SerialUSB.println(identifier);
  SerialUSB.println("");
  SerialUSB.println("Main menu");
  SerialUSB.println("");
  SerialUSB.println(" s  -  step");
  SerialUSB.println(" d  -  dir");
  SerialUSB.println(" p  -  print angle");
  SerialUSB.println(" w  -  print yw, yw_ref and yw-yw_ref");
  SerialUSB.println("");
  SerialUSB.println(" c  -  write new calibration table");
  SerialUSB.println(" e  -  check encoder diagnositics");
  SerialUSB.println(" q  -  parameter query");
  SerialUSB.println("");
  SerialUSB.println(" x  -  position mode");
  SerialUSB.println(" v  -  velocity mode");
  SerialUSB.println(" t  -  torque mode");
  SerialUSB.println("");
  SerialUSB.println(" y  -  enable control loop");
  SerialUSB.println(" n  -  disable control loop");
  SerialUSB.println(" r  -  enter new setpoint");
  SerialUSB.println(" o  -  enter new torque setpoint");
  SerialUSB.println("");
  SerialUSB.println(" j  -  step response");
  SerialUSB.println(" k  -  edit controller gains -- note, these edits are stored in volatile memory and will be reset if power is cycled");
  SerialUSB.println(" g  -  generate sine commutation table");
  SerialUSB.println(" m  -  print main menu");
  SerialUSB.println("");
}
void sineGen() {
  int temp;
  SerialUSB.println("");
  SerialUSB.println("The sineGen() function in Utils.cpp generates a sinusoidal commutation table.");
  SerialUSB.println("You can experiment with different commutation profiles by modifying this table.");
  SerialUSB.println("The below table should be copied into sine_1 in Parameters.cpp.");
  SerialUSB.println("");
  delay(3000);
  SerialUSB.println("Printing sine look up table:...");
  SerialUSB.println("");
  for (int x = 0; x <= 3600; x++) {
    temp = round(1024.0 * sin((3.14159265358979 * ((x * 0.1 / 180.0) + 0.0))));
    SerialUSB.print(temp);
    SerialUSB.print(", ");
  }
}

void stepResponse() { // Under development
  SerialUSB.println("");
  SerialUSB.println("--------------------------------");
  SerialUSB.println("");
  SerialUSB.println("Get ready for step response!");
  SerialUSB.println("Close Serial Monitor and open Tools>>Serial Plotter");
  SerialUSB.println("You have 10 seconds...");
  enableTCInterrupts(); // Start in closed loop mode
  r = 0;
  delay(1000);
  SerialUSB.println("9...");
  delay(1000);
  SerialUSB.println("8...");
  delay(1000);
  SerialUSB.println("7...");
  delay(1000);
  SerialUSB.println("6...");
  delay(1000);
  SerialUSB.println("5...");
  delay(1000);
  SerialUSB.println("4...");
  delay(1000);
  SerialUSB.println("3...");
  delay(1000);
  SerialUSB.println("2...");
  delay(1000);
  SerialUSB.println("1...");
  delay(1000);
  print_yw = true;
  delay(100);
  r = 97.65; // Choose step size as you like. 97.65 gives a nice plot since 97.65*1024 = 10,000
  delay(400);
  print_yw = false;
  r = 0;
  delay(500);
  disableTCInterrupts();
}

void moveRel(float pos_final,int vel_max, int accel) {
  /* Use this function for slow relative movements in closed loop position mode
   *
   * This function creates a "trapezoidal speed" trajectory (constant accel, and max speed, constant decel);
   * It works pretty well, but it may not be perfect
   *
   * pos_final is the desired position in degrees
   * vel_max is the max velocity in degrees/second
   * accel is the max accel in degrees/second^2
   *
   * Note that the actual max velocity is limited by the execution speed of all the math below.
   * Adjusting dpos (delta position, or step size) allows you to trade higher speeds for smoother motion
   * Max speed with dpos = 0.225 degrees is about 180 deg/sec
   * Max speed with dpos = 0.45 degrees is about 360 deg/sec */
  float pos = 0;
  float dpos = 0.45; // "step size" in degrees, smaller is smoother, but will limit max speed, keep below stepper step angle
  float vel = 0;
  float vel_1 =0;
  int start = micros(); // For debugging
  float accel_x_dpos = accel*dpos;  // Pre calculate
  float dpos_x_1000000 = dpos*1000000.0; // Pre calculate
  float pos_remaining = pos_final-pos;
  unsigned long dt =0;
  unsigned long t = micros();
  unsigned long t_1 = t;
  float r0 = r; // Hold initial setpoint
  /* Assume we're decelerating and calculate speed along deceleration profile */
  while (abs(pos_remaining) >(dpos/2)){  // May not actually reach exactly so leave some margin
    if (pos_remaining > 0) // Clockwise
      vel = sqrt(2.0 * pos_remaining * accel);
    else                   // Counter clockwise
      vel = -sqrt(2.0 * -pos_remaining * accel);
    if (vel > vel_1) { // Check if we actually need to accelerate in  clockwise direction
      if (vel_1 == 0)
        vel = sqrt(2.0 * accel_x_dpos);
      else
        vel = vel_1 + abs(accel_x_dpos/ vel_1);
      if (vel > vel_max)
        vel = vel_max;
    } else if (vel < vel_1) { // Need to accelerate in  counter clockwise direction
      if (vel_1 == 0)
        vel = -sqrt(2.0 * accel_x_dpos);
      else
        vel = vel_1 - abs(accel_x_dpos/ vel_1);
      if (vel < -vel_max)
        vel = -vel_max;
    }
    dt = abs(dpos_x_1000000 / vel);
    while(t < t_1 + dt) { // Wait calculated dt
      t = micros();
    }
    if (vel > 0)  pos += dpos; // Update setpoint
    else if (vel < 0) pos -= dpos;
    r= r0 + pos;
    t_1 = t;
    vel_1 = vel;
    pos_remaining = pos_final-pos;
  }
  r = r0 +pos_final;
}

void moveAbs(float pos_final,int vel_max, int accel){
  /* Use this function for slow absolute movements in closed loop position mode
   *
   *  This function creates a "trapezoidal speed" trajectory (constant accel, and max speed, constant decel);
   *  It works pretty well, but it may not be perfect
   *
   *  pos_final is the desired position in degrees
   *  vel_max is the max velocity in degrees/second
   *  accel is the max accel in degrees/second^2
   *
   * Note that the actual max velocity is limited by the execution speed of all the math below.
   * Adjusting dpos (delta position, or step size) allows you to trade higher speeds for smoother motion
   * Max speed with dpos = 0.225 degrees is about 180 deg/sec
   * Max speed with dpos = 0.45 degrees is about 360 deg/sec */
  float pos = r;
  float dpos = 0.225; // "step size" in degrees, smaller is smoother, but will limit max speed, keep below stepper step angle
  float vel = 0;
  float vel_1 =0;
  float accel_x_dpos = accel*dpos;  // Pre calculate
  float dpos_x_1000000 = dpos*1000000.0; // Pre calculate
  float pos_remaining = pos_final-pos;
  unsigned long dt =0;
  unsigned long t = micros();
  unsigned long t_1 = t;
  /* Assume we're decelerating and calculate speed along deceleration profile */
  while (abs(pos_remaining) >(dpos/2)) { // May not actually reach exactly so leave some margin

    if (pos_remaining > 0) // Clockwise
      vel = sqrt(2.0 * pos_remaining * accel);
    else                   // Counter clockwise
      vel = -sqrt(2.0 * -pos_remaining * accel);
    if (vel > vel_1) { // Check if we actually need to accelerate in  clockwise direction
      if (vel_1 == 0)
        vel = sqrt(2.0 * accel_x_dpos);
      else
        vel = vel_1 + abs(accel_x_dpos/ vel_1);
      if (vel > vel_max)
        vel = vel_max;
    } else if (vel < vel_1) { // Need to accelerate in  counter clockwise direction
      if (vel_1 == 0)
        vel = -sqrt(2.0 * accel_x_dpos);
      else
        vel = vel_1 - abs(accel_x_dpos/ vel_1);
      if (vel < -vel_max)
        vel = -vel_max;
    }
    dt = abs(dpos_x_1000000 / vel);
    while(t < t_1 + dt) { // Wait calculated dt
      t = micros();
    }
    if (vel > 0)  pos += dpos; // Update setpoint
    else if (vel < 0) pos -= dpos;
    r = pos;
    t_1 = t;
    vel_1 = vel;
    pos_remaining = pos_final-pos;
  }
  r = pos_final;
}
