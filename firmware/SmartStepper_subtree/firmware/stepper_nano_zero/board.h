/**********************************************************************
 *      Author: tstern
 *
 *	Misfit Tech invests time and resources providing this open source code,
 *	please support Misfit Tech and open-source hardware by purchasing
 *	products from Misfit Tech, www.misifittech.net!
 *
 *	Written by Trampas Stern  for Misfit Tech.
 *	BSD license, check license.txt for more information
 *	All text above, must be included in any redistribution
 *********************************************************************/
#ifndef __BOARD_H__
#define __BOARD_H__

#include <Arduino.h>

//uncomment this if you are using the Mechaduino hardware
//#define MECHADUINO_HARDWARE

//uncomment this if you will be using Hangprinter's TWI/i2c interface
#define HP_I2C

//uncomment the follow lines if using the NEMA 23 10A hardware
//#define NEMA_23_10A_HW

//uncomment the following if the board uses the A5995 driver (NEMA 23 3.2A boards)
//#define A5995_DRIVER

//The March 21 2017 NEMA 17 Smart Stepper has changed some pin outs
// A1 was changed to read motor voltage, hence SW4 is now using D4
// comment out this next line if using the older hardware
#define NEMA17_SMART_STEPPER_3_21_2017


#ifdef A5995_DRIVER
#ifdef NEMA17_SMART_STEPPER_3_21_2017
#error "Only NEMA17_SMART_STEPPER_3_21_2017 or A5595_DRIVER may be defined"
#endif
#endif

#define NZS_FAST_CAL // define this to use 32k of flash for fast calibration table
#define NZS_FAST_SINE //uses 2048 extra bytes to implement faster sine tables


#define NZS_AS5047_PIPELINE //does a pipeline read of encoder, which is slightly faster

#define NZS_CONTROL_LOOP_HZ (6000) //update rate of control loop


#define NZS_LCD_ABSOULTE_ANGLE  //define this to show angle from zero in positive and negative direction
// for example 2 rotations from start will be angle of 720 degrees

//#define ENABLE_PHASE_PREDICTION //this enables prediction of phase at high velocity to increase motor speed
//as of FW0.11 it is considered development only

#define VERSION "FW: 0.37" //this is what prints on LCD during splash screen

//Define this to allow command out serial port, else hardware serial is debug log
//#define CMD_SERIAL_PORT

#define SERIAL_BAUD (115200) //baud rate for the serial ports

//This section is for using the step and dir pins as serial port
// when the enable pin is inactive.
#define USE_STEP_DIR_SERIAL
#define STEP_DIR_BAUD (19200) //this is the baud rate we will use

// These are used as an attempt to use TC4 to count steps
//  currently this is not working.
//#define USE_NEW_STEP //define this to use new step method
#define USE_TC_STEP //use timer counter for step pin

#ifndef F_CPU
#define F_CPU (48000000UL)
#endif

/* TODO are flaged with TODO
 *   TODO - add detection of magnet to make sure PCB is on motor
 */

/* change log
 *   0.02 added fixes for 0.9 degree motor
 *   0.03 added code for using error pin as an enable pin, enable feedback by default
 *   0.04
 *   0.05 added different modes added support for mechaduino
 *   0.06 added time out pipeline read, add some error logging on encoder failure for mechaduino
 *   0.07 many changes including
 *   	- fixed error on display when doing a move 99999
 *   	- added velocity and position PID modes
 *   	- fixed LCD menu and put LCD code in own file
 *   	- include LCD source files from adafruit as that ssd1306 need lcd resoultion fix
 *   	- added motor parameters to NVM such step size and rotation are only check on first boot
 *   	- added test on power up to see if motor power is applied.
 *   	- added factory reset command
 *   	- pPID is not stable in my testing.
 *   0.08
 *   	- moved enable pin processing out of interrupt context
 *   	- added mode for inverted logic on the enable pin
 *   	- added pin definitions for NEMA23 10A hardware
 *   	- Changed enable such that it does not move motor but just sets current posistion
 *	 0.09
 *	 	- enabled auto detection of LCD
 *	 	- cleaned up the commands, made motorparams and systemparams individual commands
 *	 	- added the option to the move command to move at a constant RPM
 *	 	- Added the setzero command to zero the relative location of motor
 *	 	- Added the stop command to stop the planner based moves.
 *	 0.10
 *	 	-Fixed bug in switching control mode to 3
 *	 0.11
 *	    - Fixed bug where output current was half of what it should have been (sine.h)
 *	    - Added #define for phase predictive advancement
 *	    - Changed calibration to be done with one coil/phase on
 *	    - Added smoothing for calibration
 *	    - Continue to work on the Fet Driver code.
 *	0.12
 *		- Continue to work on the FET driver code
 *		- fixed a constant issue with the DAC for the A4954 driver
 *		- added command for setting the operational mode of the enable pin
 *		- added the start of the A5995 driver.
 *	0.13
 *		- Added delay in for the 0.9 degree motor calibration and testing
 *		- changed calibration to move 1/2 step at time as it was causing problems on A5995 due to current ramp down
 *	0.14  	- Added in data logging
 *		- Averaged the encoder when the motor is stationary to reduce noise/vibrations
 *  	0.15 - Fixed some fet driver code
 *  	 	- Added support for the NEMA17 smart stepper
 *  	 	- Fixed RPM display bug on the LCD
 * 	0.16 - Added support for enable and error pins on the 3-21-2017 hardware
 *
 *	0.17 - Added the ability for the command line to go over the hardwired serial port
 *		 - Fixed a bug where step and direction pin were setup as pulled down pins
 *		    which could cause false stepping in nosiey environments
 * 	0.18 - Added support for EEPROM writting of last location during brown out - currently brown out is too fast to write
 * 	     - Added commands to support reading and restoring location from eeprom
 * 	     - Check for pull up on SDA/SCL before doing a I2C read as that SERCOM driver has not time outs and locks.
 * 	     - Added faster detection of USB not being plugged in, reduces power up time with no USB
 * 	0.19 - removed debug information in the ssd1306 driver which caused LCD not always to be found
 *	0.20 - Fixed bug in calibration, thanks to Oliver E.
 *	0.21 - Fixed issues compiling for mechaduino, including disabling LCD for MEchaduino
 *	0.22 - Added home command;
 *	0.23 -- added motor voltage sense to remove stepping on power up
 *	0.24 - Disabled the home command which used the enable pin if you do not have enable pin
 *	0.25 - Added pin read command
 *  0.26 - changed the step/dir pins to be input_pullups
 *  0.27 - added the option to make the step/dir uart when enable is low.
 *  	 - fixed enable to line to disable the A4954 driver
 *  0.28 - Enabled some homing options (still under development)
 *  0.29  - fixed rounding bug in ANGLE_T0_DEGREES
 *  0.30  - Added support for the AS5048A encoder
 *  0.31  - Added reading enable pin on during main loop
 *  0.32  - Fixed issue where steps were not being counted correctly
 *  0.33  - changed sPID parameters back to 0.9 0.0001 0.01
 *  0.34  - Added board type to the splash screen
 *  0.35 - fixed usign TC4 (USE_TC_STEP) for counting steps. We can measure steps
 *       - at over 125khz, however the dir pin has ~8us setup time due to interrupt latency.
 *       - Added debug command to allow debug messages out the USB serial port
 *  0.36 - eeprom set location math was wrong.
 *  0.37 - fixed bug where the motor would pause periodically do the the TC4 counter.
 */


/*
 *  Typedefs that are used across multiple files/modules
 */
typedef enum {
	CW_ROTATION=0,
	CCW_ROTATION=1,
} RotationDir_t;

typedef enum {
	ERROR_PIN_MODE_ENABLE=0, //error pin works like enable on step sticks
	ERROR_PIN_MODE_ACTIVE_LOW_ENABLE=1, //error pin works like enable on step sticks
	ERROR_PIN_MODE_ERROR=2,  //error pin is low when there is angle error
	ERROR_PIN_MODE_BIDIR=3,   //error pin is bidirection open collector
} ErrorPinMode_t;

typedef enum {
	CTRL_OFF =0, 	 //controller is disabled
	CTRL_OPEN=1, 	 //controller is in open loop mode
	CTRL_SIMPLE = 2, //simple error controller
	CTRL_POS_PID =3, //PID  Position controller
	CTRL_POS_VELOCITY_PID =4, //PID  Velocity controller
	CTRL_TORQUE =5, //Set a fixed torque
} feedbackCtrl_t;

// ******** EVENT SYS USAGAE ************
// Channel 0 - Step pin event

// ******** TIMER USAGE A4954 versions ************
//TCC1 is used for DAC PWM to the A4954
//TCC0 can be used as PWM for the input pins on the A4954
//D0 step input could use TCC1 or TCC0 if not used
//TC3 is used for planner tick
//TC4 is used for step count
//TC5 is use for timing the control loop

// ******** TIMER USAGE NEMA23 10A versions ************
//TCC0 PWM for the FET IN pins
//D10 step input could use TC3 or TCC0 if not used
//TC3 is used for planner tick
//TC4 is used for step count
//TC5 is use for timing the control loop


//mechaduio and Arduino Zero has defined serial ports differently than NZS
#ifdef MECHADUINO_HARDWARE
#warning "Compiling source for Mechaduino NOT NZS"
#define DISABLE_LCD
#define Serial5 Serial
#else
#define SerialUSB Serial
#endif

#ifdef HP_I2C
#warning "Compiling source for Hangprinter use"
#define DISABLE_LCD
#endif

#define PIN_STEP_INPUT  (0)
#define PIN_DIR_INPUT   (1)

#define PIN_MOSI        (23)
#define PIN_SCK         (24)
#define PIN_MISO        (22)

#ifdef MECHADUINO_HARDWARE
#ifdef USE_STEP_DIR_SERIAL
#error "Step/Dir UART not supported on Mechaduino yet"
#endif

#define PIN_ERROR 		(19)  //analogInputToDigitalPin(PIN_A5))
#else //not Mechaduino hardware
#ifdef NEMA17_SMART_STEPPER_3_21_2017
#define PIN_SW1		(19)//analogInputToDigitalPin(PIN_A5))
#define PIN_SW3		(14)//analogInputToDigitalPin(PIN_A0))
#define PIN_SW4		(2)//D2
#define PIN_ENABLE	(10)
#define PIN_ERROR	(3)

#define PIN_VMOTOR (A1) //analog pin for the motor

#else
#define PIN_SW1		(19)//analogInputToDigitalPin(PIN_A5))
#define PIN_SW3		(14)//analogInputToDigitalPin(PIN_A0))
#define PIN_SW4		(15)//analogInputToDigitalPin(PIN_A1))
#define PIN_ERROR		(10)
#endif

#endif

#ifdef A5995_DRIVER
#define PIN_ENABLE	(3)
#endif

#define PIN_SCL (21)
#define PIN_SDA (20)
#define PIN_USB_PWR (38) // this pin is high when usb is connected

#define PIN_AS5047D_CS  (16)//analogInputToDigitalPin(PIN_A2))
#ifndef MECHADUINO_HARDWARE
#define PIN_AS5047D_PWR	(11) //pull low to power on AS5047D
#endif

//these pins use the TIMER in the A4954 driver
// changing the pin definitions here may require changes in the A4954.cpp file

#define PIN_FET_IN1		(5) //PA15 TC3/WO[1] TCC0/WO[5]1
#define PIN_FET_IN2		(6) //PA20 TC7/W0[0] TCC0/WO[6]2
#define PIN_FET_IN3		(7) //PA21 TC7/WO[1] TCC0/WO[7]3
#define PIN_FET_IN4		(2) //PA14 TC3/W0[0] TCC0/WO[4] 0
#define PIN_FET_VREF1	(4)
#define PIN_FET_VREF2	(3)
#define PIN_FET_ENABLE		(12)
//current sense pin from each H-bridge
#define ISENSE_FET_A	 (17) //analogInputToDigitalPin(PIN_A3)
#define ISENSE_FET_B	 (8)
//Comparators analog inputs
//#define COMP_FET_A		 (18)//analogInputToDigitalPin(PIN_A4))
//#define COMP_FET_B		 (9)


//these are the pins used on the A5995 driver
#define PIN_A5995_ENABLE1 	(2) //PA14
#define PIN_A5995_ENABLE2 	(18) //PA05  analogInputToDigitalPin(PIN_A4))
#define PIN_A5995_MODE1 	(8) //PA06 TCC1 WO[0]
#define PIN_A5995_MODE2 	(7)	//PA21 TCC0 WO[4] //3
#define PIN_A5995_PHASE1 	(6)	//PA20 TCC0 WO[6] //2
#define PIN_A5995_PHASE2 	(5) //PA15 TCC0 W0[5] //1
#define PIN_A5995_VREF1		(4) //PA08
#define PIN_A5995_VREF2		(9) //PA07
#define PIN_A5995_SLEEPn	(25) //RXLED

#ifndef MECHADUINO_HARDWARE
#define PIN_YELLOW_LED  (8)
#endif




#ifdef NEMA_23_10A_HW
#undef PIN_YELLOW_LED
#define PIN_YELLOW_LED  	(26) //TXLED (PA27)
#endif //NEMA_23_10A_HW


#define PIN_RED_LED     (13)
#define PIN_A4954_IN3		(5)
#define PIN_A4954_IN4		(6)
#define PIN_A4954_IN2		(7)
#ifdef MECHADUINO_HARDWARE
#define PIN_A4954_IN1		(8)
#else
#define PIN_A4954_IN1		(18) //analogInputToDigitalPin(PIN_A4))
#endif
#define PIN_A4954_VREF34	(4)
#define PIN_A4954_VREF12	(9)



//Here are some useful macros
#define DIVIDE_WITH_ROUND(x,y)  ((x+y/2)/y)


#define GPIO_LOW(pin) {PORT->Group[g_APinDescription[(pin)].ulPort].OUTCLR.reg = (1ul << g_APinDescription[(pin)].ulPin);}
#define GPIO_HIGH(pin) {PORT->Group[g_APinDescription[(pin)].ulPort].OUTSET.reg = (1ul << g_APinDescription[(pin)].ulPin);}
#define GPIO_OUTPUT(pin) {PORT->Group[g_APinDescription[(pin)].ulPort].PINCFG[g_APinDescription[(pin)].ulPin].reg &=~(uint8_t)(PORT_PINCFG_INEN) ;  PORT->Group[g_APinDescription[(pin)].ulPort].DIRSET.reg = (uint32_t)(1<<g_APinDescription[(pin)].ulPin) ;}

#define PIN_GPIO_OUTPUT(pin) {PORT->Group[g_APinDescription[(pin)].ulPort].PINCFG[g_APinDescription[(pin)].ulPin].reg &=~(uint8_t)(PORT_PINCFG_INEN | PORT_PINCFG_PMUXEN) ;  PORT->Group[g_APinDescription[(pin)].ulPort].DIRSET.reg = (uint32_t)(1<<g_APinDescription[(pin)].ulPin) ;}

#define PIN_GPIO(pin) {PORT->Group[g_APinDescription[(pin)].ulPort].PINCFG[g_APinDescription[(pin)].ulPin].reg &=~(uint8_t)(PORT_PINCFG_INEN | PORT_PINCFG_PMUXEN);}
#define GPIO_READ(ulPin) {(PORT->Group[g_APinDescription[ulPin].ulPort].IN.reg & (1ul << g_APinDescription[ulPin].ulPin)) != 0}
#define PIN_PERIPH(pin) {PORT->Group[g_APinDescription[(pin)].ulPort].PINCFG[g_APinDescription[(pin)].ulPin].reg |= PORT_PINCFG_PMUXEN;}
//sets up the pins for the board
static void boardSetupPins(void)
{
	//setup switch pins
#ifdef PIN_SW1
	pinMode(PIN_SW1, INPUT_PULLUP);
	pinMode(PIN_SW3, INPUT_PULLUP);
	pinMode(PIN_SW4, INPUT_PULLUP);
#endif

	pinMode(PIN_STEP_INPUT, INPUT_PULLUP);
	pinMode(PIN_DIR_INPUT, INPUT_PULLUP);

#ifdef PIN_ENABLE
	pinMode(PIN_ENABLE, INPUT_PULLUP); //default error pin as enable pin with pull up
#endif
	pinMode(PIN_ERROR, INPUT_PULLUP); //default error pin as enable pin with pull up

	pinMode(PIN_AS5047D_CS,OUTPUT);
	digitalWrite(PIN_AS5047D_CS,LOW); //pull CS LOW by default (chip powered off)

	//turn the AS5047D off by default
#ifdef PIN_AS5047D_PWR
	pinMode(PIN_AS5047D_PWR,OUTPUT);
	digitalWrite(PIN_AS5047D_PWR,HIGH);
#endif



	pinMode(PIN_MOSI,OUTPUT);
	digitalWrite(PIN_MOSI,LOW);
	pinMode(PIN_SCK,OUTPUT);
	digitalWrite(PIN_SCK,LOW);
	pinMode(PIN_MISO,INPUT);

	//setup the A4954 pins
	digitalWrite(PIN_A4954_IN3,LOW);
	pinMode(PIN_A4954_IN3,OUTPUT);
	digitalWrite(PIN_A4954_IN4,LOW);
	pinMode(PIN_A4954_IN4,OUTPUT);
	digitalWrite(PIN_A4954_IN2,LOW);
	pinMode(PIN_A4954_IN2,OUTPUT);
	digitalWrite(PIN_A4954_IN1,LOW);
	pinMode(PIN_A4954_IN1,OUTPUT);

	//setup the PWM for current on the A4954, set for low current
	digitalWrite(PIN_A4954_VREF12,LOW);
	digitalWrite(PIN_A4954_VREF34,LOW);
	pinMode(PIN_A4954_VREF34, OUTPUT);
	pinMode(PIN_A4954_VREF12, OUTPUT);



	pinMode(PIN_RED_LED,OUTPUT);
#ifdef PIN_YELLOW_LED
	pinMode(PIN_YELLOW_LED,OUTPUT);
	digitalWrite(PIN_YELLOW_LED,HIGH);
#endif
}

#ifdef NEMA17_SMART_STEPPER_3_21_2017
static float GetMotorVoltage(void)
{
	uint32_t x;
	float f;
	//the motor voltage is 1/101 of the adc
	x=analogRead(PIN_VMOTOR);  //this should be a 10bit value mapped to 3.3V
	f=(float)x*3.3/1024.0*101.0;
	return f;
}
#endif

static void inline YELLOW_LED(bool state)
{
#ifdef PIN_YELLOW_LED
	digitalWrite(PIN_YELLOW_LED,!state);
#endif
}

static void inline RED_LED(bool state)
{
	digitalWrite(PIN_RED_LED,state);
}

#define MIN(a,b) (((a)<(b))?(a):(b))
#define MAX(a,b) (((a)>(b))?(a):(b))
#define ABS(a) (((a)>(0))?(a):(-(a)))
#define DIV(x,y) (((y)>(0))?((x)/(y)):(4294967295))
#define SIGN(x)  (((x) > 0) - ((x) < 0))

#define NVIC_IS_IRQ_ENABLED(x) (NVIC->ISER[0] & (1 << ((uint32_t)(x) & 0x1F)))!=0

static inline uint8_t  getPinMux(uint16_t ulPin)
{
	uint8_t temp;
	if ((ulPin & 0x01)==0)
	{
		temp = (PORT->Group[g_APinDescription[ulPin].ulPort].PMUX[g_APinDescription[ulPin].ulPin >> 1].reg) & PORT_PMUX_PMUXE( 0xF ) ;
	}else
	{
		temp = (PORT->Group[g_APinDescription[ulPin].ulPort].PMUX[g_APinDescription[ulPin].ulPin >> 1].reg)>>4 & 0xF;
	}
	return temp;
}


static inline uint8_t  getPinCfg(uint16_t ulPin)
{
	uint8_t temp;

	temp = PORT->Group[g_APinDescription[ulPin].ulPort].PINCFG[g_APinDescription[ulPin].ulPin].reg;
	return temp;
}

static inline void  setPinCfg(uint16_t ulPin, uint8_t val)
{
	PORT->Group[g_APinDescription[ulPin].ulPort].PINCFG[g_APinDescription[ulPin].ulPin].reg=val;
}



static inline void  setPinMux(uint16_t ulPin, uint8_t val)
{
	uint8_t temp;
	temp = (PORT->Group[g_APinDescription[ulPin].ulPort].PMUX[g_APinDescription[ulPin].ulPin >> 1].reg);
	if ((ulPin & 0x01)==0)
	{
		//if an even pin
		temp =  (temp & 0xF0) | (val & 0x0F);
	}else
	{
		temp =  (temp & 0x0F) | ((val<<4) & 0x0F);
	}
	PORT->Group[g_APinDescription[ulPin].ulPort].PMUX[g_APinDescription[ulPin].ulPin >> 1].reg=temp;
	PORT->Group[g_APinDescription[ulPin].ulPort].PINCFG[g_APinDescription[ulPin].ulPin].reg |= PORT_PINCFG_PMUXEN ; // Enable port mux
}

static inline void SET_PIN_PERHERIAL(uint16_t ulPin,EPioType ulPeripheral)
{
	if ( g_APinDescription[ulPin].ulPin & 1 ) // is pin odd?
	{
		uint32_t temp ;

		// Get whole current setup for both odd and even pins and remove odd one
		temp = (PORT->Group[g_APinDescription[ulPin].ulPort].PMUX[g_APinDescription[ulPin].ulPin >> 1].reg) & PORT_PMUX_PMUXE( 0xF ) ;
		// Set new muxing
		PORT->Group[g_APinDescription[ulPin].ulPort].PMUX[g_APinDescription[ulPin].ulPin >> 1].reg = temp|PORT_PMUX_PMUXO( ulPeripheral ) ;
		// Enable port mux
		PORT->Group[g_APinDescription[ulPin].ulPort].PINCFG[g_APinDescription[ulPin].ulPin].reg |= PORT_PINCFG_PMUXEN ;
	}
	else // even pin
	{
		uint32_t temp ;

		temp = (PORT->Group[g_APinDescription[ulPin].ulPort].PMUX[g_APinDescription[ulPin].ulPin >> 1].reg) & PORT_PMUX_PMUXO( 0xF ) ;
		PORT->Group[g_APinDescription[ulPin].ulPort].PMUX[g_APinDescription[ulPin].ulPin >> 1].reg = temp|PORT_PMUX_PMUXE( ulPeripheral ) ;
		PORT->Group[g_APinDescription[ulPin].ulPort].PINCFG[g_APinDescription[ulPin].ulPin].reg |= PORT_PINCFG_PMUXEN ; // Enable port mux
	}
}


//the Arduino delay function requires interrupts to work.
// if interrupts are disabled use the delayMicroseconds which is a spin loop
static inline void DelayMs(uint32_t ms)
{
	uint32_t prim;
	/* Read PRIMASK register, check interrupt status before you disable them */
	/* Returns 0 if they are enabled, or non-zero if disabled */
	prim = __get_PRIMASK();

	if (prim==0)
	{
		delay(ms);
	}else
	{
		while(ms)
		{
			delayMicroseconds(1000);
			ms--;
		}
	}
}

#endif//__BOARD_H__

