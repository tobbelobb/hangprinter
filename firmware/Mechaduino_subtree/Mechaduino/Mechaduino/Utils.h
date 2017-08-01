//Contains the declarations for the functions used by the firmware

#ifndef __UTILS_H__
#define __UTIL_H__


	void setupPins();                 // initializes pins

	void setupSPI();                  //initializes SPI

  void setupI2C();                  // initializes I2C

  void configureStepDir();          //configure step/dir interface

  void configureEnablePin();        //configure enable pin

	void stepInterrupt();             //step interrupt handler

  void dirInterrupt();              //dir interrupt handler

  void enableInterrupt();           //enable pin interrupt handler

  void modeChangeInterrupt();

	void output(float theta, int effort);	  //calculates phase currents (commutation) and outputs to Vref pins

	void calibrate();	                //calibration routine

	void serialCheck();               //checks serial port for commands.  Must include this in loop() for serial interface to work

	void parameterQuery();            //Prints current parameters

	void oneStep(void);               //take one step

	int readEncoder();                //read raw encoder position

	void readEncoderDiagnostics();    //check encoder diagnostics registers

	void print_angle();               //for debigging purposes in open loop mode:  prints [step number] , [encoder reading]

	void receiveEvent(int howMany);   //for i2c interface...

	int mod(int xMod, int mMod);      //modulo, handles negative values properly

	void setupTCInterrupts();         //configures control loop interrupt

	void enableTCInterrupts();        //enables control loop interrupt.  Use this to enable "closed-loop" modes

	void disableTCInterrupts();       //disables control loop interrupt.  Use this to diable "closed-loop" mode

	void antiCoggingCal();            //under development...

	void parameterEditmain();         //parameter editing menu

	void parameterEditp();            //parameter editing menu

	void parameterEditv();            //parameter editing menu

	void parameterEdito();            //parameter editing menu

  void hybridControl();             //open loop stepping, but corrects for missed steps.  under development

  void serialMenu();                //main menu

  void sineGen();                   //generates sinusoidal commutation table. you can experiment with other commutation profiles

  void stepResponse();              //generates position mode step response in Serial Plotter

  void moveRel(float pos_final,int vel_max, int accel);     // Generates trapezoidal motion profile for closed loop position mode

  void moveAbs(float pos_final,int vel_max, int accel);     // Generates trapezoidal motion profile for closed loop position mode

#endif







