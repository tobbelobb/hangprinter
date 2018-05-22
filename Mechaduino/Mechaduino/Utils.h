#ifndef __UTILS_H__
#define __UTIL_H__
void setupPins();                     // Initializes pins
void setupSPI();                      // Initializes SPI
void setupI2C();                      // Initializes I2C
void configureStepDir();              // Configure step/dir interface
void configureEnablePin();            // Configure enable pin
void stepInterrupt();                 // Step interrupt handler
void dirInterrupt();                  // Dir interrupt handler
void enableInterrupt();               // Enable pin interrupt handler
void modeChangeInterrupt();
void output(float theta, int effort); // Calculates phase currents (commutation) and outputs to Vref pins
void calibrate();	                    // Calibration routine
void serialCheck();                   // Checks serial port for commands.  Must include this in loop() for serial interface to work
void parameterQuery();                // Prints current parameters
void oneStep(void);                   // Take one step
int readEncoder();                    // Read raw encoder position
void readEncoderDiagnostics();        // Check encoder diagnostics registers
void print_angle();                   // For debigging purposes in open loop mode:  prints [step number] , [encoder reading]
void receiveEvent(int howMany);       // For i2c interface...
int mod(int xMod, int mMod);          // Modulo, handles negative values properly
void setupTCInterrupts();             // Configures control loop interrupt
void enableTCInterrupts();            // Enables control loop interrupt.  Use this to enable "closed-loop" modes
void disableTCInterrupts();           // Disables control loop interrupt.  Use this to diable "closed-loop" mode
void antiCoggingCal();                // Under development...
void parameterEditmain();             // Parameter editing menu
void parameterEditp();                // Parameter editing menu
void parameterEditv();                // Parameter editing menu
void parameterEdito();                // Parameter editing menu
void hybridControl();                 // Open loop stepping, but corrects for missed steps.  under development
void serialMenu();                    // Main menu
void sineGen();                       // Generates sinusoidal commutation table. you can experiment with other commutation profiles
void stepResponse();                  // Generates position mode step response in Serial Plotter
void moveRel(float pos_final,int vel_max, int accel); // Generates trapezoidal motion profile for closed loop position mode
void moveAbs(float pos_final,int vel_max, int accel); // Generates trapezoidal motion profile for closed loop position mode
#endif
