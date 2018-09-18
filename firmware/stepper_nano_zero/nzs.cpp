/*
 * nzs.cpp
 *
 *  Created on: Dec 8, 2016
 *      Author: trampas
 *
 *	Misfit Tech invests time and resources providing this open source code,
 *	please support Misfit Tech and open-source hardware by purchasing
 *	products from Misfit Tech, www.misifittech.net!
 *
 *	Written by Trampas Stern  for Misfit Tech.
 *	BSD license, check license.txt for more information
 *	All text above, must be included in any redistribution
 *********************************************************************/

#include "nzs.h"
#include "commands.h"
#include "HP_i2c.h"
#include "nonvolatile.h"
#include "angle.h"
#include "eeprom.h"
#include "steppin.h"

#pragma GCC push_options
#pragma GCC optimize ("-Ofast")

eepromData_t PowerupEEPROM={0};


volatile bool enableState=true;

int32_t dataEnabled=0;

StepperCtrl stepperCtrl;
LCD Lcd;

int menuCalibrate(int argc, char *argv[])
{
	stepperCtrl.calibrateEncoder();
}

int menuTestCal(int argc, char *argv[])
{
	Angle error;
	int32_t x,y;
	char str[25];
	error=stepperCtrl.maxCalibrationError();

	x=(36000*(int32_t)error)/ANGLE_STEPS;
	LOG("Error %d %d", (int32_t)error, x);
	y=x/100;
	x=x-(y*100);
	x=abs(x);
	sprintf(str, "%d.%02d deg",y,x);
#ifndef DISABLE_LCD
	Lcd.lcdShow("Cal Error", str,"");
#endif

	LOG("Calibration error %s",str);
#ifndef MECHADUINO_HARDWARE
	while(digitalRead(PIN_SW3)==1)
	{
		//wait for button press
	}
	while(digitalRead(PIN_SW3)==0)
	{
		//wait for button release
	}
#endif
}

static  options_t stepOptions[] {
		{"200"},
		{"400"},
		{""},
};

//returns the index of the stepOptions when called
// with no arguments.
int motorSteps(int argc, char *argv[])
{
	if (argc==0)
	{
		int i;
		i=NVM->motorParams.fullStepsPerRotation;
		if (i==400)
		{
			return 1;
		}
		return 0; //default to 200
	}
	if (argc>0)
	{
		int32_t i;
		MotorParams_t params;
		memcpy((void *)&params, (void *)&NVM->motorParams, sizeof(params));
		i=atol(argv[0]);
		if (i!=params.fullStepsPerRotation)
		{
			params.fullStepsPerRotation=i;
			nvmWriteMotorParms(params);
		}
	}

	return 0;
}

static  options_t currentOptions[] {
		{"0"},
		{"100"},
		{"200"},
		{"300"},
		{"400"},
		{"500"},
		{"600"},
		{"700"},
		{"800"},
		{"900"},
		{"1000"},
		{"1100"},
		{"1200"},
		{"1300"},
		{"1400"},
		{"1500"},
		{"1600"},
		{"1700"},
		{"1800"},
		{"1900"},
		{"2000"},
		{"2100"},
		{"2200"},
		{"2300"},
		{"2400"},
		{"2500"},
		{"2600"},
		{"2700"},
		{"2800"},
		{"2900"},
		{"3000"},
		{"3100"},
		{"3200"},
		{"3300"},
		{""},
};

int motorCurrent(int argc, char *argv[])
{
	LOG("called motorCurrent %d",argc);
	if (argc==1)
	{
		int i;
		LOG("called %s",argv[0]);
		i=atol(argv[0]);
		i=i*100;
		MotorParams_t params;
		memcpy((void *)&params, (void *)&NVM->motorParams, sizeof(params));
		if (i!=params.currentMa)
		{
			params.currentMa=i;
			nvmWriteMotorParms(params);
		}
		return i/100;
	}
	int i;
	i=NVM->motorParams.currentMa/100;
	LOG(" motorCurrent return %d",i);
	return i;

}

int motorHoldCurrent(int argc, char *argv[])
{
	if (argc==1)
	{
		int i;
		i=atol(argv[0]);
		i=i*100;
		MotorParams_t params;
		memcpy((void *)&params, (void *)&NVM->motorParams, sizeof(params));
		if (i!=params.currentHoldMa)
		{
			params.currentHoldMa=i;
			nvmWriteMotorParms(params);
		}
		return i/100;
	}else
	{
		int i;
		i=NVM->motorParams.currentHoldMa/100;
		return i;
	}
}

static  options_t microstepOptions[] {
		{"1"},
		{"2"},
		{"4"},
		{"8"},
		{"16"},
		{"32"},
		{"64"},
		{"128"},
		{"256"},
		{""}
};

int microsteps(int argc, char *argv[])
{
	if (argc==1)
	{
		int i,steps;
		i=atol(argv[0]);
		SystemParams_t params;
		memcpy((void *)&params, (void *)&NVM->SystemParams, sizeof(params));
		steps=0x01<<i;
		if (steps!=params.microsteps)
		{
			params.microsteps=steps;
			nvmWriteSystemParms(params);
		}
		return i;
	}
	int i,j;
	i=NVM->SystemParams.microsteps;
	for (j=0; j<9; j++)
	{

		if ((0x01<<j) == i)
		{
			return j;
		}
	}
	return 0;
}

static  options_t controlLoopOptions[] {
		{"Off"},
		{"Open"},
		{"Simple"},
		{"Pos PID"},
		{"Vel PID"},
		{""}
};



int controlLoop(int argc, char *argv[])
{
	if (argc==1)
	{
		int i;
		i=atol(argv[0]);
		SystemParams_t params;
		memcpy((void *)&params, (void *)&NVM->SystemParams, sizeof(params));
		if (i!=params.controllerMode)
		{
			params.controllerMode=(feedbackCtrl_t)i;
			nvmWriteSystemParms(params);
		}
		return i;
	}
	return NVM->SystemParams.controllerMode;
}




#ifndef PIN_ENABLE
static  options_t errorPinOptions[] {
		{"Enable"},
		{"!Enable"}, //error pin works like enable on step sticks
		{"Error"},
		//	{"BiDir"}, //12/12/2016 not implemented yet
		{""}
};

int errorPin(int argc, char *argv[])
{
	if (argc==1)
	{
		int i;
		i=atol(argv[0]);
		SystemParams_t params;
		memcpy((void *)&params, (void *)&NVM->SystemParams, sizeof(params));
		if (i!=params.errorPinMode)
		{
			params.errorPinMode=(ErrorPinMode_t)i;
			nvmWriteSystemParms(params);
		}
		return i;
	}
	return NVM->SystemParams.errorPinMode;
}
#else

	static  options_t errorPinOptions[] {
			{"Enable"},
			{"!Enable"}, //error pin works like enable on step sticks
			//      {"Error"},
			//	{"BiDir"}, //12/12/2016 not implemented yet
			{""}
	};

	int enablePin(int argc, char *argv[])
	{
		if (argc==1)
		{
			int i;
			i=atol(argv[0]);
			SystemParams_t params;
			memcpy((void *)&params, (void *)&NVM->SystemParams, sizeof(params));
			if (i!=params.errorPinMode)
			{
				params.errorPinMode=(ErrorPinMode_t)i;
				nvmWriteSystemParms(params);
			}
			return i;
		}
		return NVM->SystemParams.errorPinMode;
	}

#endif

static  options_t dirPinOptions[] {
		{"High CW"},
		{"High CCW"},
		{""}
};

int dirPin(int argc, char *argv[])
{
	if (argc==1)
	{
		int i;
		i=atol(argv[0]);
		SystemParams_t params;
		memcpy((void *)&params, (void *)&NVM->SystemParams, sizeof(params));
		if (i!=params.dirPinRotation)
		{
			params.dirPinRotation=(RotationDir_t)i;
			nvmWriteSystemParms(params);
		}
		return i;
	}
	return NVM->SystemParams.dirPinRotation;
}


static  menuItem_t MenuMain[] {
		{"Calibrate", menuCalibrate,NULL},
		{"Test Cal", menuTestCal,NULL},
		//		{"Mtr steps", motorSteps,stepOptions}, NOT GOOD for user to call this
		{"Motor mA", motorCurrent,currentOptions},
		{"Hold mA", motorHoldCurrent,currentOptions},
		{"Microstep", microsteps,microstepOptions},
		//		{"Ctlr Mode", controlLoop,controlLoopOptions}, //this may not be good for user to call
#ifndef PIN_ENABLE
		{"Error Pin", errorPin,errorPinOptions},
#else
		{"EnablePin", enablePin,errorPinOptions},
#endif
		{"Dir Pin", dirPin,dirPinOptions},


		{ "", NULL}
};

static  menuItem_t MenuCal[] {
		{"Calibrate", menuCalibrate,NULL},
		//{"Test Cal", menuTestCal,NULL},
		{ "", NULL}
};






//this function is called when error pin changes as enable signal
static void enableInput(void)
{
	static bool lastState=true;
#ifdef PIN_ENABLE
	if (NVM->SystemParams.errorPinMode == ERROR_PIN_MODE_ENABLE)
	{
		static int enable;
		//read our enable pin
		enable = digitalRead(PIN_ENABLE);
		if (enable != enableState)
		{
			WARNING("Enable now %d",enable);
		}
		enableState=enable;
		//stepperCtrl.enable(enable);
	}
	if (NVM->SystemParams.errorPinMode == ERROR_PIN_MODE_ACTIVE_LOW_ENABLE)
	{
		static int enable;
		//read our enable pin
		enable = !digitalRead(PIN_ENABLE);
		if (enable != enableState)
		{
			WARNING("Enable now %d",enable);
		}
		enableState=enable;
		//stepperCtrl.enable(enable);
	}
#else
	if (NVM->SystemParams.errorPinMode == ERROR_PIN_MODE_ENABLE)
	{
		static int enable;
		//read our enable pin
		enable = digitalRead(PIN_ERROR);
		enableState=enable;
		//stepperCtrl.enable(enable);
	}
	if (NVM->SystemParams.errorPinMode == ERROR_PIN_MODE_ACTIVE_LOW_ENABLE)
	{
		static int enable;
		//read our enable pin
		enable = !digitalRead(PIN_ERROR);
		enableState=enable;
		//stepperCtrl.enable(enable);
	}
#endif

#ifdef USE_STEP_DIR_SERIAL

	static uint8_t pinCFG[2];
	static uint8_t pinMux[2];
	if (enableState == false  && lastState==true)
	{
		// turn the step/dir to serial port

		//save pin config for restoring
		pinCFG[0]=getPinCfg(PIN_STEP_INPUT);
		pinCFG[1]=getPinCfg(PIN_DIR_INPUT);
		pinMux[0]=getPinMux(PIN_STEP_INPUT);
		pinMux[1]=getPinMux(PIN_DIR_INPUT);

		//lets see if the step pin has interrupt enabled
		if (pinMux[0] == PORT_PMUX_PMUXE_A_Val)
		{
			EExt_Interrupts in = g_APinDescription[PIN_STEP_INPUT].ulExtInt;
			EIC->INTENCLR.reg = EIC_INTENCLR_EXTINT(1 << in); //disable the interrupt
			//we need to disable the interrupt
		}

		//now we need to set the pins to serial port peripheral (sercom0)
		setPinMux(PIN_STEP_INPUT,PORT_PMUX_PMUXE_C_Val);
		setPinMux(PIN_DIR_INPUT,PORT_PMUX_PMUXE_C_Val);

		//make sure that step pin is input with mux to peripheral
		setPinCfg(PIN_STEP_INPUT, PORT_PINCFG_PMUXEN | PORT_PINCFG_INEN | PORT_PINCFG_PULLEN);

		//make sure that dir pin is an output with mux to peripheral
		setPinCfg(PIN_DIR_INPUT, PORT_PINCFG_PMUXEN );

		Serial1.begin(STEP_DIR_BAUD);

	}
	if (enableState == true  && lastState==false)
	{
		Serial1.end();
		setPinMux(PIN_STEP_INPUT,pinMux[0]);
		setPinMux(PIN_DIR_INPUT,pinMux[1]);
		setPinCfg(PIN_STEP_INPUT,pinCFG[0]);
		setPinCfg(PIN_DIR_INPUT,pinCFG[1]);
		//turn step/dir pins back to GPIO
		if (PORT_PMUX_PMUXE_A_Val == pinMux[0])
		{
			//if interrupt was enabled for step pin renable it.
			EExt_Interrupts in = g_APinDescription[PIN_STEP_INPUT].ulExtInt;
			EIC->INTENSET.reg = EIC_INTENCLR_EXTINT(1 << in); //enable the interrupt
		}

	}

#endif //USE_STEP_DIR_SERIAL
	lastState=enableState;
}





void TC5_Handler()
{
//	static bool led=false;
//	YELLOW_LED(led);
//	led=!led;
	interrupts(); //allow other interrupts
	if (TC5->COUNT16.INTFLAG.bit.OVF == 1)
	{
		int error=0;


		error=(stepperCtrl.processFeedback()); //handle the control loop
		YELLOW_LED(error);
#ifdef PIN_ENABLE
		GPIO_OUTPUT(PIN_ERROR);
		bool level;
		level = !NVM->SystemParams.errorLogic;
		if (error)
		{	//assume high is inactive and low is active on error pin
			digitalWrite(PIN_ERROR,level);
		}else
		{
			digitalWrite(PIN_ERROR,!level);
		}
#else

		if (NVM->SystemParams.errorPinMode == ERROR_PIN_MODE_ERROR)
		{
			GPIO_OUTPUT(PIN_ERROR);
			if (error)
			{	//assume high is inactive and low is active on error pin
				digitalWrite(PIN_ERROR,LOW);
			}else
			{
				digitalWrite(PIN_ERROR,HIGH);
			}
		}
#endif
		TC5->COUNT16.INTFLAG.bit.OVF = 1;    // writing a one clears the flag ovf flag
	}

}

//check the NVM and set to defaults if there is any
void validateAndInitNVMParams(void)
{

	if (false == NVM->sPID.parametersVaild)
	{
		nvmWrite_sPID(0.9,0.0001, 0.01);
	}

	if (false == NVM->pPID.parametersVaild)
	{
		nvmWrite_pPID(1.0, 0, 0);
	}

	if (false == NVM->vPID.parametersVaild)
	{
		nvmWrite_vPID(2.0, 1.0, 1.0);
	}

	if (false == NVM->SystemParams.parametersVaild)
	{
		SystemParams_t params;
		params.microsteps=16;
		#if defined(CTRL_POS_PID_AS_DEFAULT)
			params.controllerMode=CTRL_POS_PID;
		#else
			params.controllerMode=CTRL_SIMPLE;
		#endif
		params.dirPinRotation=CW_ROTATION; //default to clockwise rotation when dir is high
		params.errorLimit=(int32_t)ANGLE_FROM_DEGREES(1.8);
		params.errorPinMode=ERROR_PIN_MODE_ENABLE;  //default to enable pin
		params.homePin=-1;
		params.errorLogic=false;
		params.homeAngleDelay=ANGLE_FROM_DEGREES(10);
		nvmWriteSystemParms(params);
	}

	if (false == NVM->networkingParams.parametersVaild)
	{
		NetworkingParams_t params;
		params.i2c_id = I2C_ID;
		nvmWriteNetworkingParms(params);
	}


	//the motor parameters are check in the stepper_controller code
	// as that there we can auto set much of them.


}



void SYSCTRL_Handler(void)
{
	if (SYSCTRL->INTFLAG.reg & SYSCTRL_INTFLAG_BOD33DET)
	{
		eepromFlush(); //flush the eeprom
		SYSCTRL->INTFLAG.reg |= SYSCTRL_INTFLAG_BOD33DET;
	}
}

// Wait for synchronization of registers between the clock domains
static __inline__ void syncBOD33(void) __attribute__((always_inline, unused));
static void syncBOD33(void)  {
	//int32_t t0=1000;
	while (SYSCTRL->PCLKSR.bit.BOD33RDY==1)
	{
		//		t0--;
		//		if (t0==0)
		//		{
		//			break;
		//		}
	}
}
static void configure_bod(void)
{
	//syncBOD33();
	//SYSCTRL->BOD33.reg=0; //disable BOD33 before starting
	//syncBOD33();
	SYSCTRL->BOD33.reg=SYSCTRL_BOD33_ACTION_INTERRUPT | //generate interrupt when BOD is triggered
			SYSCTRL_BOD33_LEVEL(48) | //about 3.2V
			//SYSCTRL_BOD33_HYST | //enable hysteresis
			SYSCTRL_BOD33_ENABLE; //turn module on

	LOG("BOD33 %02X", SYSCTRL->BOD33.reg );
	SYSCTRL->INTENSET.reg |= SYSCTRL_INTENSET_BOD33DET;

	NVIC_SetPriority(SYSCTRL_IRQn, 1); //make highest priority as we need to save eeprom
	// Enable InterruptVector
	NVIC_EnableIRQ(SYSCTRL_IRQn);
}


void NZS::begin(void)
{
	int to=20;
	stepCtrlError_t stepCtrlError;

	//set up the pins correctly on the board.
	boardSetupPins();

	//start up the USB serial interface
	//TODO check for power on USB before doing this...
	SerialUSB.begin(SERIAL_BAUD);

	//setup the serial port for syslog
	Serial5.begin(SERIAL_BAUD);


#ifndef CMD_SERIAL_PORT
	SysLogInit(&Serial5,LOG_DEBUG); //use SWO for the sysloging
#else
	SysLogInit(NULL, LOG_WARNING);
#endif

	LOG("Power up!");
	pinMode(PIN_USB_PWR, INPUT);


	if (digitalRead(PIN_USB_PWR))
	{
		//wait for USB serial port to come alive
		while (!SerialUSB)
		{
			to--;
			if (to == 0)
			{
				break;
			}
			delay(500);
		};     //wait for serial
	} else
	{
		WARNING("USB Not connected");
	}

	validateAndInitNVMParams();

	LOG("EEPROM INIT");
	if (EEPROM_OK == eepromInit()) //init the EEPROM
	{
		eepromRead((uint8_t *)&PowerupEEPROM, sizeof(PowerupEEPROM));
	}
	configure_bod(); //configure the BOD
#ifndef DISABLE_LCD
	LOG("Testing LCD");
	Lcd.begin(&stepperCtrl);

#ifdef A5995_DRIVER
	Lcd.lcdShow("MisfitTech","NEMA 23", VERSION);
#else
	Lcd.lcdShow("MisfitTech","NEMA 17", VERSION);
#endif

#elif defined(HP_I2C)
	setup_HP_I2C();
#endif

	LOG("command init!");
	commandsInit(); //setup command handler system


	stepCtrlError=STEPCTRL_NO_CAL;


	while (STEPCTRL_NO_ERROR != stepCtrlError)
	{
		LOG("init the stepper controller");
		stepCtrlError=stepperCtrl.begin(); //start controller before accepting step inputs

		//todo we need to handle error on LCD and through command line
		if (STEPCTRL_NO_POWER == stepCtrlError)
		{

			SerialUSB.println("Appears that there is no Motor Power");
			SerialUSB.println("Connect motor power!");
#ifndef DISABLE_LCD
			Lcd.lcdShow("Waiting", "MOTOR", "POWER");
#endif
			while (STEPCTRL_NO_POWER == stepCtrlError)
			{
				stepCtrlError=stepperCtrl.begin(); //start controller before accepting step inputs
			}

		}

		if (STEPCTRL_NO_CAL == stepCtrlError)
		{
			SerialUSB.println("You need to Calibrate");
#ifndef DISABLE_LCD
			Lcd.lcdShow("   NOT ", "Calibrated", " ");
			delay(1000);
			Lcd.setMenu(MenuCal);
			Lcd.forceMenuActive();

			//TODO add code here for LCD and command line loop
			while(false == stepperCtrl.calibrationValid())
			{
				commandsProcess(); //handle commands

				Lcd.process();

			}

			Lcd.setMenu(NULL);
#endif
		}

		if (STEPCTRL_NO_ENCODER == stepCtrlError)
		{
			SerialUSB.println("AS5047D not working");
			SerialUSB.println(" try disconnecting power from board for 15+mins");
			SerialUSB.println(" you might have to short out power pins to ground");
#ifndef DISABLE_LCD
			Lcd.lcdShow("Encoder", " Error!", " REBOOT");
#endif
			while(1)
			{

			}
		}

	}
#ifndef DISABLE_LCD
	Lcd.setMenu(MenuMain);
#endif

	stepPinSetup(); //setup the step pin

#ifdef PIN_ENABLE
	//attachInterrupt(digitalPinToInterrupt(PIN_ENABLE), enableInput, CHANGE);
	NVIC_SetPriority(EIC_IRQn, 0); //set port A interrupt as highest priority
#else
	attachInterrupt(digitalPinToInterrupt(PIN_ERROR), enableInput, CHANGE);
#endif

	SmartPlanner.begin(&stepperCtrl);
	RED_LED(false);
	LOG("SETUP DONE!");
}


void printLocation(void)
{
	char buf[128]={0};
	Location_t loc;
	int32_t n, i, len;
	int32_t pktSize;

	if (dataEnabled==0)
	{
		//RED_LED(false);
		return;
	}

	//the packet length for binary print is 12bytes
	// assuming rate of 6Khz this would be 72,000 baud
	i=0;
	n=stepperCtrl.getLocation(&loc);
	if (n==-1)
	{
		//RED_LED(false);
		return;
	}

	len=0;
	pktSize=sizeof(Location_t)+1; //packet lenght is size location plus sync byte

	//     //binary write

	while(n>=0 && (len)<=(128-pktSize))
	{
		memcpy(&buf[len],&loc,sizeof(Location_t));
		len+=sizeof(Location_t);
		buf[len]=0XAA; //sync
		len++;
		buf[len]=sizeof(Location_t); //data len
		len++;

		n=stepperCtrl.getLocation(&loc);
		i++;
	}
	SerialUSB.write(buf,len);

	//hex write
	// hex write is 29 bytes per tick, @ 6khz this 174000 baud
	//   while(n>=0 && (i*29)<(200-29))
	//   {
	//      sprintf(buf,"%s%08X\t%08X\t%08X\n\r",buf,loc.microSecs,loc.desiredLoc,loc.actualLoc);
	//      n=stepperCtrl.getLocation(&loc);
	//      i++;
	//   }
	//   SerialUSB.write(buf,strlen(buf));

//	if (n<=0)
//	{
//		RED_LED(false);
//	}else
//	{
//		RED_LED(true);
//	}

	return;
}

void NZS::loop(void)
{
	eepromData_t eepromData;


	//   if (dataEnabled==0)
	//   {
	//      LOG("loop time is %dus",stepperCtrl.getLoopTime());
	//   }

	//read the enable pin and update
	// this is also done as an edge interrupt but does not always see
	// to trigger the ISR.
	enableInput();

	if (enableState != stepperCtrl.getEnable())
	{
		stepperCtrl.enable(enableState);
	}

	//handle EEPROM
	eepromData.angle=stepperCtrl.getCurrentAngle();
	eepromData.encoderAngle=stepperCtrl.getEncoderAngle();
	eepromData.valid=1;
	eepromWriteCache((uint8_t *)&eepromData,sizeof(eepromData));

	commandsProcess(); //handle commands
#ifndef DISABLE_LCD
	Lcd.process();
#endif
	//stepperCtrl.PrintData(); //prints steps and angle to serial USB.


	printLocation(); //print out the current location

	return;
}

#pragma GCC pop_options
