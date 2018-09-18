#include "commands.h"
#include "command.h"
#include "calibration.h"
#include "stepper_controller.h"
#include <stdlib.h>
#include "nonvolatile.h"
#include "Reset.h"
#include "nzs.h"
#include "ftoa.h"
#include "board.h"
#include "eeprom.h"
#include "steppin.h"
#ifdef HP_I2C
#include "HP_i2c.h"
#endif

extern int32_t dataEnabled;

#define COMMANDS_PROMPT (":>")
sCmdUart UsbUart;
sCmdUart SerialUart;
sCmdUart HostUart; //uart on the step/dir pins

static int isPowerOfTwo (unsigned int x)
{
	while (((x % 2) == 0) && x > 1) /* While x is even and > 1 */
		x /= 2;
	return (x == 1);
}

CMD_STR(help,"Displays this message");
CMD_STR(getcal,"Prints the calibration table");
CMD_STR(calibrate,"Calbirates the encoder, should be done with motor disconnected from machine");
CMD_STR(testcal,"tests the calibaration of the encoder");
CMD_STR(microsteps,"gets/sets the microstep size, example 'microsteps 16'");
CMD_STR(step, "Steps motor one step, optionally direction can be set is 'step 1' for reverse");
CMD_STR(feedback, "enable or disable feedback controller, 'feedback 0' - disables, 'feedback 1' - enables");
CMD_STR(readpos, "reads the current angle, applies calibration if valid");
CMD_STR(encoderdiag, "Prints encoder diagnostic")
CMD_STR(spid, "with no arguments prints SIMPLE PID parameters, with arguments sets PID 'sPID Kp Ki Kd' "
		"Where Kp,Ki,Kd are floating point numbers");
CMD_STR(vpid, "with no arguments prints VELOCITY PID parameters, with arguments sets PID 'sPID Kp Ki Kd' "
		"Where Kp,Ki,Kd are floating point numbers");
CMD_STR(ppid, "with no arguments prints POSITIONAL PID parameters, with arguments sets PID 'sPID Kp Ki Kd' "
		"Where Kp,Ki,Kd are floating point numbers");
//CMD_STR(testringing ,"Steps motor at various currents and measures encoder");
//CMD_STR(microsteperror ,"test error on microstepping")
CMD_STR(dirpin, "with no arguments read dirpin setting, with argument sets direction pin rotation. "
		"Changing this also inverts torque mode direction.");
#ifndef PIN_ENABLE
CMD_STR(errorpinmode,"gets/sets the functionality of the error/enable pin");
#else
CMD_STR(enablepinmode,"gets/sets the functionality of the enable pin");
#endif
CMD_STR(errorlimit, "gets/set the error limit which will assert error pin (when error pin is set for error output)");
CMD_STR(ctrlmode, "gets/set the feedback controller mode of operation");
#ifdef HP_I2C
CMD_STR(i2cid, "gets/set the i2c id. Write 'i2cid 0x0a' to set i2c id to 0x0a");
#endif
CMD_STR(maxcurrent, "gets/set the maximum motor current allowed in milliAmps");
CMD_STR(holdcurrent, "gets/set the motor holding current in milliAmps, only used in the simple positional PID mode");
CMD_STR(homecurrent, "gets/set the motor moving and holding currents that will be used when pin A3 is low");
CMD_STR(motorwiring, "gets/set the motor wiring direction, should only be used by experts");
CMD_STR(stepsperrotation, "gets/set the motor steps per rotation, should only be used by experts");
//CMD_STR(sysparams, "with no arguments read parameters, will set with arguments");
//CMD_STR(motorparams, "with no arguments read parameters, will set with arguments");
CMD_STR(boot, "Enters the bootloader");
CMD_STR(move, "moves encoder to absolute angle in degrees 'move 400.1'");
//CMD_STR(printdata, "prints last n error terms");
CMD_STR(velocity, "gets/set velocity in RPMs");
CMD_STR(torque, "prints torque parameter, with argument sets 'torque t' "
		"Where torque is an integer between -128 and 127. The special value 0 disables torque mode and enables position mode.");
CMD_STR(factoryreset, "resets board to factory defaults");
CMD_STR(stop, "stops the motion planner");
CMD_STR(setzero, "set the reference angle to zero");
CMD_STR(data, "enables/disables binary data output");
CMD_STR(looptime, "returns the control loop processing time");
CMD_STR(eepromerror, "returns error in degreees from eeprom at power up realtive to current encoder");
CMD_STR(eepromloc, "returns location in degreees eeprom on power up");
CMD_STR(eepromwrite, "forces write of location to eeprom");
CMD_STR(eepromsetloc, "sets the device angle based on EEPROM last reading, compenstates for error")
CMD_STR(setpos, "sets the current angle in degrees");
CMD_STR(reboot, "reboots the unit");
CMD_STR(homepin, "sets the pin used to drop to homing current");
CMD_STR(homeangledelay, "sets the angle delay in dropping to homing current");
#ifdef PIN_ENABLE
CMD_STR(home, "moves the motor until home switch (enable pin) is pulled low. example 'home 360 0.5' move up to 360 degrees at 0.5 RPM ")
#endif
CMD_STR(pinread, "reads pins as binary (bit 0-step, bit 1 - Dir, bit 2 - Enable, bit 3 - Error, bit 4 - A3, bit 5- TX, bit 6 - RX")
CMD_STR(errorpin, "Sets the logic level of error pin")
CMD_STR(geterror, "gets current error")
CMD_STR(getsteps, "returns number of steps seen")
CMD_STR(debug, "enables debug commands out USB")
//List of supported commands
sCommand Cmds[] =
{
		COMMAND(help),
		COMMAND(calibrate),
		COMMAND(getcal),
		COMMAND(testcal),
		COMMAND(microsteps),
		COMMAND(step),
		COMMAND(feedback),
		COMMAND(readpos),
		COMMAND(encoderdiag),
		COMMAND(spid),
		COMMAND(vpid),
		COMMAND(ppid),
		//COMMAND(testringing),
		//COMMAND(microsteperror),
		COMMAND(dirpin),
#ifndef PIN_ENABLE
		COMMAND(errorpinmode),
#else
		COMMAND(enablepinmode),
#endif
		COMMAND(errorlimit),
		COMMAND(ctrlmode),
		COMMAND(i2cid),
		COMMAND(maxcurrent),
		COMMAND(holdcurrent),
		COMMAND(homecurrent),
		COMMAND(motorwiring),
		COMMAND(stepsperrotation),
		//COMMAND(sysparams),
		//COMMAND(motorparams),
		COMMAND(boot),
		COMMAND(move),
		//COMMAND(printdata),
		COMMAND(velocity),
		COMMAND(torque),
		COMMAND(factoryreset),
		COMMAND(stop),
		COMMAND(setzero),
		COMMAND(data),
		COMMAND(looptime),
		COMMAND(eepromerror),
		COMMAND(eepromloc),
		COMMAND(eepromwrite),
		COMMAND(setpos),
		COMMAND(reboot),
		COMMAND(eepromsetloc),
		COMMAND(homepin),
		COMMAND(homeangledelay),
#ifdef PIN_ENABLE
		COMMAND(home),
#endif
		COMMAND(pinread),
		COMMAND(errorpin),
		COMMAND(geterror),
		COMMAND(getsteps),
		COMMAND(debug),
		{"",0,""}, //End of list signal
};

static int debug_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	uint32_t i;
	if (argc>=1)
	{
		i=atol(argv[0]);
		SysLogDebug(i);
	}
}

static int getsteps_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	int32_t s;
	s=(int32_t)getSteps();
	CommandPrintf(ptrUart,"steps %" PRIi32 "\n\r",s);
	return 0;
}

static int geterror_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	float f;
	char str[30];
	f=ANGLE_T0_DEGREES(stepperCtrl.getLoopError());
	ftoa(f,str,2,'f');
	CommandPrintf(ptrUart,"error %s deg",str);
	return 0;
}

static int errorpin_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	if (argc==1)
	{
		SystemParams_t params;

		memcpy(&params,&NVM->SystemParams, sizeof(SystemParams_t) );
		params.errorLogic=atol(argv[0]);

		nvmWriteSystemParms(params);
		stepperCtrl.updateParamsFromNVM();

	}
	CommandPrintf(ptrUart,"error pin assert level is %d\n\r",NVM->SystemParams.errorLogic);
	return 0;
}

static int pinread_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	uint8_t ret=0;

	if (digitalRead(PIN_STEP_INPUT))
	{
		ret |= 0x01;
	}
	if (digitalRead(PIN_DIR_INPUT))
	{
		ret |= 0x02;
	}
#ifdef PIN_ENABLE
	if (digitalRead(PIN_ENABLE))
	{
		ret |= 0x04;
	}
#endif
	if (digitalRead(PIN_ERROR))
	{
		ret |= 0x08;
	}
	if (digitalRead(PIN_A3))
	{
		ret |= 0x10;
	}
	if (digitalRead(30))
	{
		ret |= 0x20;
	}
	if (digitalRead(31))
	{
		ret |= 0x40;
	}
	CommandPrintf(ptrUart,"0x%02X\n\r",ret);
	return 0;
}

#ifdef PIN_ENABLE
static void errorPinISR(void)
{
	SmartPlanner.stop(); //stop the planner
}

static int home_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	float rpm=1;
	float startDegrees=ANGLE_T0_DEGREES(stepperCtrl.getCurrentAngle());
	float finalDegrees=startDegrees+360.0;
	char str[20];
	float deg;

	if (argc>=1)
	{
		finalDegrees=startDegrees+atof(argv[0]);
	}

	if (argc>=2)
	{
		rpm=atof(argv[1]);
	}

	//setup a interrupt for the enable  pin
	attachInterrupt(digitalPinToInterrupt(PIN_ENABLE), errorPinISR, FALLING);

	SmartPlanner.moveConstantVelocity(finalDegrees,rpm);

	while(!SmartPlanner.done())
	{
		//do nothing
	}
	detachInterrupt(digitalPinToInterrupt(PIN_ENABLE));
	deg=ANGLE_T0_DEGREES(stepperCtrl.getCurrentAngle());
	ftoa(deg,str,2,'f');
	CommandPrintf(ptrUart,"home is %s deg\n\r",str);
	stepperCtrl.setZero();

	return 0;
}
#endif

static int reboot_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	NVIC_SystemReset();
	return 0;
}

static int setpos_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	if (argc>=1)
	{
		int64_t a;
		float x;
		x=fabs(atof(argv[0]));
		a=ANGLE_FROM_DEGREES(x);
		stepperCtrl.setAngle(a);
		return 0;
	}
	return 1;
}

static int eepromwrite_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	eepromFlush();
	return 0;
}

static int eepromerror_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	Angle a;
	uint16_t error;
	float deg;
	char str[20];
	a=(Angle)PowerupEEPROM.encoderAngle;

	LOG("EEPROM encoder %d",(uint16_t)a);
	LOG("start encoder %d",(uint16_t)stepperCtrl.getStartupEncoder());
	LOG("current encoder %d",(uint16_t)stepperCtrl.getEncoderAngle());
	a=(a-(Angle)stepperCtrl.getStartupEncoder());

	deg=ANGLE_T0_DEGREES((uint16_t)a) ;
	if (deg>360.0)
	{
		deg=deg-360.0;
	}

	ftoa(deg,str,2,'f');
	CommandPrintf(ptrUart,"startup error(+/-) %s deg\n\r",str);

	a=(Angle)PowerupEEPROM.encoderAngle;
	a=(a-(Angle)stepperCtrl.getEncoderAngle());
	deg=ANGLE_T0_DEGREES((uint16_t)a);
	if (deg>360.0)
	{
		deg=deg-360.0;
	}
	ftoa(deg,str,2,'f');
	CommandPrintf(ptrUart,"current error(+/-) %s deg\n\r",str);

	return 0;
}

static int eepromsetloc_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	Angle a;
	int64_t deg;
	int32_t x;

	x=(uint32_t)PowerupEEPROM.encoderAngle-(uint32_t)stepperCtrl.getEncoderAngle();

	deg=PowerupEEPROM.angle-x;

	stepperCtrl.setAngle(deg);
	return 0;
}

static int eepromloc_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	Angle a;
	int64_t deg;
	int32_t x,y;

	deg=PowerupEEPROM.angle;

	deg=(deg*360*100)/(int32_t)ANGLE_STEPS;
	x=(deg)/100;
	y=abs(deg-(x*100));
	CommandPrintf(ptrUart,"%d.%0.2d deg\n\r",x,y);
	return 0;
}

static int looptime_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	CommandPrintf(ptrUart,"%dus",stepperCtrl.getLoopTime());
	return 0;
}

static int setzero_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	stepperCtrl.setZero();
	return 0;
}

static int stop_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	SmartPlanner.stop();
	return 0;
}

static int data_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	if (argc == 1)
	{
		uint32_t x;

		x=atol(argv[0]);
		dataEnabled=x;
		return 0;
	}
	return 1;
}

static int stepsperrotation_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{

	if (argc == 0)
	{
		uint32_t x;
		x=NVM->motorParams.fullStepsPerRotation;
		CommandPrintf(ptrUart,"full steps per rotation %u\n\r",x);
		return 0;
	}

	if (argc == 1)
	{
		uint32_t x;

		x=atol(argv[0]);

		if (x==200 || x==400)
		{
			MotorParams_t motorParams;

			memcpy(&motorParams,&NVM->motorParams, sizeof(motorParams) );
			motorParams.fullStepsPerRotation=x;

			nvmWriteMotorParms(motorParams);
			stepperCtrl.updateParamsFromNVM();


			x=NVM->motorParams.fullStepsPerRotation;
			CommandPrintf(ptrUart,"full steps per rotation %u\n\r",x);
			CommandPrintf(ptrUart,"please power cycle board\n\r");
			return 0;
		}

	}
	CommandPrintf(ptrUart,"usage 'stepsperrotation 200' or 'stepsperrotation 400'\n\r");

	return 1;
}

static int motorwiring_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{

	if (argc == 0)
	{
		uint32_t x;
		x=NVM->motorParams.motorWiring;
		CommandPrintf(ptrUart,"motor wiring %u\n\r",x);
		return 0;
	}

	if (argc == 1)
	{
		uint32_t x;

		x=atol(argv[0]);

		if (x<=1)
		{
			MotorParams_t motorParams;

			memcpy(&motorParams,&NVM->motorParams, sizeof(motorParams) );
			motorParams.motorWiring=x;

			nvmWriteMotorParms(motorParams);
			stepperCtrl.updateParamsFromNVM();


			x=NVM->motorParams.motorWiring;
			CommandPrintf(ptrUart,"motor wiring %u\n\r",x);
			CommandPrintf(ptrUart,"please power cycle board\n\r");
			return 0;
		}

	}
	CommandPrintf(ptrUart,"usage 'motorwiring 0' or 'motorwiring 1'\n\r");

	return 1;
}

static int homeangledelay_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
		float f;
		char str[30];

		if (argc == 1)
		{
			f=atof(argv[0]);

			SystemParams_t params;

			memcpy(&params,&NVM->SystemParams, sizeof(SystemParams_t) );
			params.homeAngleDelay=ANGLE_FROM_DEGREES(f);

			nvmWriteSystemParms(params);
			stepperCtrl.updateParamsFromNVM();

		}

		f=ANGLE_T0_DEGREES(NVM->SystemParams.homeAngleDelay);
		ftoa(f,str,2,'f');
		CommandPrintf(ptrUart,"home angle delay %s\n\r",str);
		return 0;
}

static int homepin_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
		int32_t x;
		if (argc == 0)
		{
			x=NVM->SystemParams.homePin;
			CommandPrintf(ptrUart,"home pin %d\n\r",x);
			return 0;
		}

		if (argc == 1)
		{
			x=atol(argv[0]);

			SystemParams_t params;

			memcpy(&params,&NVM->SystemParams, sizeof(SystemParams_t) );
			params.homePin=x;

			nvmWriteSystemParms(params);
			stepperCtrl.updateParamsFromNVM();


			x=NVM->SystemParams.homePin;
			CommandPrintf(ptrUart,"home pin %d\n\r",x);
			return 0;

		}

		CommandPrintf(ptrUart, "use 'sethomepin 17' to set maximum home pin to A3");

		return 1;
}

static int homecurrent_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	uint32_t x,y;
	if (argc == 0)
	{
		x=NVM->motorParams.homeMa;
		y=NVM->motorParams.homeHoldMa;
		CommandPrintf(ptrUart,"current %umA, %umA\n\r",x,y);
		return 0;
	}

	if (argc == 1)
	{
		x=atol(argv[0]);

		MotorParams_t motorParams;

		memcpy(&motorParams,&NVM->motorParams, sizeof(motorParams) );
		motorParams.homeMa=x;

		nvmWriteMotorParms(motorParams);
		stepperCtrl.updateParamsFromNVM();


		x=NVM->motorParams.homeMa;
		y=NVM->motorParams.homeHoldMa;
		CommandPrintf(ptrUart,"current %umA, %umA\n\r",x,y);
		return 0;

	}
	if (argc == 2)
	{
		x=atol(argv[0]);
		y=atol(argv[1]);

		MotorParams_t motorParams;

		memcpy(&motorParams,&NVM->motorParams, sizeof(motorParams) );
		motorParams.homeMa=x;
		motorParams.homeHoldMa=y;

		nvmWriteMotorParms(motorParams);
		stepperCtrl.updateParamsFromNVM();


		x=NVM->motorParams.homeMa;
		y=NVM->motorParams.homeHoldMa;
		CommandPrintf(ptrUart,"current %umA, %umA\n\r",x,y);
		return 0;

	}
	CommandPrintf(ptrUart, "use 'homecurrent 1000 500' to set maximum home current to 1.0A and hold to 500ma");

	return 1;
}

static int holdcurrent_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{

	if (argc == 0)
	{
		uint32_t x;
		x=NVM->motorParams.currentHoldMa;
		CommandPrintf(ptrUart,"hold current %u mA\n\r",x);
		return 0;
	}

	if (argc == 1)
	{
		uint32_t x;

		x=atol(argv[0]);

		MotorParams_t motorParams;

		memcpy(&motorParams,&NVM->motorParams, sizeof(motorParams) );
		motorParams.currentHoldMa=x;

		nvmWriteMotorParms(motorParams);
		stepperCtrl.updateParamsFromNVM();


		x=NVM->motorParams.currentHoldMa;
		CommandPrintf(ptrUart,"hold current %u mA\n\r",x);
		return 0;


	}
	CommandPrintf(ptrUart, "use 'holdcurrent 1000' to set maximum current to 1.0A");

	return 1;
}

static int maxcurrent_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{

	if (argc == 0)
	{
		uint32_t x;
		x=NVM->motorParams.currentMa;
		CommandPrintf(ptrUart,"max current %u mA\n\r",x);
		return 0;
	}

	if (argc == 1)
	{
		uint32_t x;

		x=atol(argv[0]);

		MotorParams_t motorParams;

		memcpy(&motorParams,&NVM->motorParams, sizeof(motorParams) );

		motorParams.currentMa=x;
		nvmWriteMotorParms(motorParams);
		stepperCtrl.updateParamsFromNVM();


		x=NVM->motorParams.currentMa;
		CommandPrintf(ptrUart,"max current %u mA\n\r",x);
		return 0;


	}
	CommandPrintf(ptrUart, "use 'maxcurrent 2000' to set maximum current to 2.0A");

	return 1;
}

static int i2cid_cmd(sCmdUart *ptrUart, int argc, char * argv[])
{
	bool ret;
	if (argc == 0)
	{
		CommandPrintf(ptrUart,"I2C id: 0x%02x", NVM->networkingParams.i2c_id);
		return 0;
	}
	else
	{
		uint32_t x;
		int base = 10;
		int skip = 0;

		if (argv[0][0] == '0' && (argv[0][1] == 'x' || argv[0][1] == 'X'))
		{
			base = 16;
			skip = 2;
		}

		x=strtoul(&(argv[0][skip]), nullptr, base);

		if (x<=127 && x>=0)
		{
			CommandPrintf(ptrUart,"Changing I2C id from 0x%02x to 0x%02x. You must reboot for change to take effect.", NVM->networkingParams.i2c_id, x);
			NetworkingParams_t networkingParams;
			memcpy(&networkingParams,&NVM->networkingParams, sizeof(networkingParams) );
			networkingParams.i2c_id = (uint8_t)x;
			nvmWriteNetworkingParms(networkingParams);
		}
	}
}

static int ctrlmode_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	bool ret;
	if (argc == 0)
	{
		switch(NVM->SystemParams.controllerMode)
		{
		case CTRL_OFF:
			CommandPrintf(ptrUart,"controller Off(0)");
			return 0;
		case CTRL_OPEN:
			CommandPrintf(ptrUart,"controller Open-loop(1)");
			return 0;
		case CTRL_SIMPLE:
			CommandPrintf(ptrUart,"controller Simple-Position-PID(2)");
			return 0;
		case CTRL_POS_PID:
			CommandPrintf(ptrUart,"controller Current-Position-PID(3)");
			return 0;
		case CTRL_POS_VELOCITY_PID:
			CommandPrintf(ptrUart,"controller Velocity-PID(4)");
			return 0;
		case CTRL_TORQUE:
			CommandPrintf(ptrUart,"controller Torque(5)");
			return 0;
		}
		return 1;
	}

	if (argc == 1)
	{
		uint32_t x;

		x=atol(argv[0]);

		if (x<=5)
		{
			SystemParams_t systemParams;

			memcpy(&systemParams,&NVM->SystemParams, sizeof(systemParams) );

			systemParams.controllerMode=(feedbackCtrl_t)(x);

			nvmWriteSystemParms(systemParams);
			stepperCtrl.updateParamsFromNVM();

			switch(NVM->SystemParams.controllerMode)
			{
			case CTRL_OFF:
				CommandPrintf(ptrUart,"controller Off(0)");
				return 0;
			case CTRL_OPEN:
				CommandPrintf(ptrUart,"controller Open-loop(1)");
				return 0;
			case CTRL_SIMPLE:
				CommandPrintf(ptrUart,"controller Simple-Position-PID(2)");
				return 0;
			case CTRL_POS_PID:
				CommandPrintf(ptrUart,"controller Current-Position-PID(3)");
				return 0;
			case CTRL_POS_VELOCITY_PID:
				CommandPrintf(ptrUart,"controller Velocity-PID(4)");
				return 0;
			case CTRL_TORQUE:
				CommandPrintf(ptrUart,"controller Torque(5)");
				return 0;
			}
			return 1;
		}
	}
	CommandPrintf(ptrUart, "use 'ctrlmode [0 .. 5]' to set control mode");

	return 1;
}

static int errorlimit_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	bool ret;
	char str[20];
	if (argc == 0)
	{
		float x;
		x=ANGLE_T0_DEGREES(NVM->SystemParams.errorLimit);
		ftoa(x,str,2,'f');
		CommandPrintf(ptrUart,"errorLimit %s deg\n\r",str);
		return 0;
	}

	if (argc == 1)
	{
		float x;

		x=fabs(atof(argv[0]));

		SystemParams_t systemParams;

		memcpy(&systemParams,&NVM->SystemParams, sizeof(systemParams) );

		systemParams.errorLimit=ANGLE_FROM_DEGREES(x);

		nvmWriteSystemParms(systemParams);
		stepperCtrl.updateParamsFromNVM();

		x=ANGLE_T0_DEGREES(NVM->SystemParams.errorLimit);
		ftoa(x,str,2,'f');
		CommandPrintf(ptrUart,"errorLimit %s deg\n\r",str);
		return 0;


	}
	CommandPrintf(ptrUart, "use 'errorlimit 1.8' to set error limit to 1.8 degrees");

	return 1;
}


static int dirpin_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	bool ret;

	if (argc == 0)
	{
		if (CW_ROTATION == NVM->SystemParams.dirPinRotation)
		{
			CommandPrintf(ptrUart,"dirpin CW(%d)\n\r",(uint32_t)NVM->SystemParams.dirPinRotation);
		}else
		{
			CommandPrintf(ptrUart,"dirpin CCW(%d)\n\r",(uint32_t)NVM->SystemParams.dirPinRotation);
		}
		return 0;
	}

	if (argc == 1)
	{
		uint32_t x;

		x=abs(atol(argv[0]));
		if (x<=1)
		{

			SystemParams_t systemParams;

			memcpy(&systemParams,&NVM->SystemParams, sizeof(systemParams) );

			systemParams.dirPinRotation=(RotationDir_t)x;

			nvmWriteSystemParms(systemParams);
			stepperCtrl.updateParamsFromNVM();

			if (CW_ROTATION == NVM->SystemParams.dirPinRotation)
			{
				CommandPrintf(ptrUart,"dirpin CW(%d)\n\r",(uint32_t)NVM->SystemParams.dirPinRotation);
			}else
			{
				CommandPrintf(ptrUart,"dirpin CCW(%d)\n\r",(uint32_t)NVM->SystemParams.dirPinRotation);
			}
			return 0;

		}
	}
	CommandPrintf(ptrUart, "used 'dirpin 0' for CW rotation and 'dirpin 1' for CCW");


	return 1;
}

#ifndef PIN_ENABLE
static int errorpinmode_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	bool ret;

	if (argc == 0)
	{
		if (ERROR_PIN_MODE_ENABLE == NVM->SystemParams.errorPinMode)
		{
			CommandPrintf(ptrUart,"Error pin -  Enable Active High(%d)\n\r",(uint32_t)NVM->SystemParams.errorPinMode);
		}else if (ERROR_PIN_MODE_ACTIVE_LOW_ENABLE == NVM->SystemParams.errorPinMode)
		{
			CommandPrintf(ptrUart,"Error pin -  Enable active low(%d)\n\r",(uint32_t)NVM->SystemParams.errorPinMode);
		}else if (ERROR_PIN_MODE_ERROR == NVM->SystemParams.errorPinMode)
		{
			CommandPrintf(ptrUart,"Error pin -  Error pin(%d)\n\r",(uint32_t)NVM->SystemParams.errorPinMode);
		} else if (ERROR_PIN_MODE_BIDIR == NVM->SystemParams.errorPinMode)
		{
			CommandPrintf(ptrUart,"Error pin -  Bidi error(%d)\n\r",(uint32_t)NVM->SystemParams.errorPinMode);
		}

		return 0;
	}

	if (argc == 1)
	{
		uint32_t x;

		x=abs(atol(argv[0]));
		if (x<=3)
		{

			SystemParams_t systemParams;

			memcpy(&systemParams,&NVM->SystemParams, sizeof(systemParams) );

			systemParams.errorPinMode=(ErrorPinMode_t)x;

			nvmWriteSystemParms(systemParams);
			stepperCtrl.updateParamsFromNVM();

			if (ERROR_PIN_MODE_ENABLE == NVM->SystemParams.errorPinMode)
			{
				CommandPrintf(ptrUart,"Error pin -  Enable Active High(%d)\n\r",(uint32_t)NVM->SystemParams.errorPinMode);
			}else if (ERROR_PIN_MODE_ACTIVE_LOW_ENABLE == NVM->SystemParams.errorPinMode)
			{
				CommandPrintf(ptrUart,"Error pin -  Enable active low(%d)\n\r",(uint32_t)NVM->SystemParams.errorPinMode);
			}else if (ERROR_PIN_MODE_ERROR == NVM->SystemParams.errorPinMode)
			{
				CommandPrintf(ptrUart,"Error pin -  Error pin(%d)\n\r",(uint32_t)NVM->SystemParams.errorPinMode);
			} else if (ERROR_PIN_MODE_BIDIR == NVM->SystemParams.errorPinMode)
			{
				CommandPrintf(ptrUart,"Error pin -  Bidi error(%d)\n\r",(uint32_t)NVM->SystemParams.errorPinMode);
			}
			return 0;

		}
	}
	CommandPrintf(ptrUart, "use 'errorpinmode 0' for enable active high, 'errorpinmode 1' for enable active low  and 'errorpinmode 2' for error output"  );


	return 1;
}
#else
static int enablepinmode_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	bool ret;

	if (argc == 0)
	{
		if (ERROR_PIN_MODE_ENABLE == NVM->SystemParams.errorPinMode)
		{
			CommandPrintf(ptrUart,"Enable pin -  Enable Active High(%d)\n\r",(uint32_t)NVM->SystemParams.errorPinMode);
		}else if (ERROR_PIN_MODE_ACTIVE_LOW_ENABLE == NVM->SystemParams.errorPinMode)
		{
			CommandPrintf(ptrUart,"Enable pin -  Enable active low(%d)\n\r",(uint32_t)NVM->SystemParams.errorPinMode);
		} else if (ERROR_PIN_MODE_BIDIR == NVM->SystemParams.errorPinMode)
		{
			CommandPrintf(ptrUart,"Enable pin -  Bidi error(%d)\n\r",(uint32_t)NVM->SystemParams.errorPinMode);
		} else
		{
			CommandPrintf(ptrUart,"UNDEFINED  Pin Mode error(%d)\n\r",(uint32_t)NVM->SystemParams.errorPinMode);
		}

		return 0;
	}

	if (argc == 1)
	{
		uint32_t x;

		x=abs(atol(argv[0]));

		if (x<=1)
		{

			SystemParams_t systemParams;

			memcpy(&systemParams,&NVM->SystemParams, sizeof(systemParams) );

			systemParams.errorPinMode=(ErrorPinMode_t)x;

			nvmWriteSystemParms(systemParams);
			stepperCtrl.updateParamsFromNVM();

			if (ERROR_PIN_MODE_ENABLE == NVM->SystemParams.errorPinMode)
			{
				CommandPrintf(ptrUart,"Enable pin -  Enable Active High(%d)\n\r",(uint32_t)NVM->SystemParams.errorPinMode);
			}else if (ERROR_PIN_MODE_ACTIVE_LOW_ENABLE == NVM->SystemParams.errorPinMode)
			{
				CommandPrintf(ptrUart,"Enable pin -  Enable active low(%d)\n\r",(uint32_t)NVM->SystemParams.errorPinMode);
			}else if (ERROR_PIN_MODE_BIDIR == NVM->SystemParams.errorPinMode)
			{
				CommandPrintf(ptrUart,"Enable pin -  Bidi error(%d)\n\r",(uint32_t)NVM->SystemParams.errorPinMode);
			}
			return 0;

		}
	}
	CommandPrintf(ptrUart, "use 'enablepinmode 0' for enable active high, 'enablepinmode 1' for enable active low "  );


	return 1;
}
#endif

static int factoryreset_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	nvmErase(); //erase all of the flash
	NVIC_SystemReset();
}
static int velocity_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	int64_t x;

	if (1 == argc)
	{
		float rpm;
		rpm=atof(argv[0]);
		x=(int64_t)(DIVIDE_WITH_ROUND(rpm*ANGLE_STEPS,60)); //divide with r


		stepperCtrl.setVelocity(x);
	}
	int64_t y;
	x=(stepperCtrl.getVelocity()*100 *60)/(ANGLE_STEPS);
	y=abs(x-((x/100)*100));
	CommandPrintf(ptrUart,"Velocity is %d.%02d - %d\n\r",(int32_t)(x/100),(int32_t)y,(int32_t)stepperCtrl.getVelocity());

	return 0;
}

//
//static int printdata_cmd(sCmdUart *ptrUart,int argc, char * argv[])
//{
//	int32_t x;
//
//	stepperCtrl.printData();
//
//	return 0;
//}


static int move_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	int32_t x,ma;
	//CommandPrintf(ptrUart, "Move %d",argc);

	if (1 == argc)
	{
		float f;

		f=atof(argv[0]);
		//		if (f>1.8)
		//			f=1.8;
		//		if (f<-1.8)
		//			f=-1.8;
		x=ANGLE_FROM_DEGREES(f);
		LOG("moving %d", x);

		stepperCtrl.moveToAbsAngle(x);
	}
	if (2 == argc)
	{
		float f,rpm,a,y;
		float pos,dx;

		f=atof(argv[0]);
		rpm=atof(argv[1]);
		//		if (f>1.8)
		//			f=1.8;
		//		if (f<-1.8)
		//			f=-1.8;

		SmartPlanner.moveConstantVelocity(f,rpm);
		return 0;
		a=360*rpm/60/1000; //rotations/100ms

		pos=ANGLE_T0_DEGREES(stepperCtrl.getCurrentAngle());
		y=pos;
		if (y>f) a=-a;

		SerialUSB.println(f);
		SerialUSB.println(y);
		SerialUSB.println(a);

		while (abs(y-f)>(2*abs(a)))
		{
			//			SerialUSB.println();
			//			SerialUSB.println(f);
			//		SerialUSB.println(y);
			//		SerialUSB.println(a);
			y=y+a;

			x=ANGLE_FROM_DEGREES(y);
			//LOG("moving %d", x);
			stepperCtrl.moveToAbsAngle(x);
			delay(1);
			//y=stepperCtrl.getCurrentAngle();
		}
		x=ANGLE_FROM_DEGREES(f);
		LOG("moving %d", x);
		stepperCtrl.moveToAbsAngle(x);
	}

	return 0;
}

static int boot_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	initiateReset(250);
}

/*
static int microsteperror_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	int i,n,j;
	bool feedback=stepperCtrl.getFeedback();
	n=200*stepperCtrl.getMicroSteps();

	CommandPrintf(ptrUart, "Function needs fixed");
	return 0;
	stepperCtrl.feedback(false);
	for (j=0; j<2; j++)
	{
		for (i=0; i<n; i++)
		{
			int32_t e;
			stepperCtrl.requestStep(1,1);
			//stepperCtrl.step(1, 2000);
			stepperCtrl.pidFeedback();

			//average 1readings
			int32_t sum=0,ii;
			for (ii=0; ii<1; ii++)
			{
				sum+=stepperCtrl.measureError();
				stepperCtrl.pidFeedback();
			}
			e=sum/ii;
			CommandPrintf(ptrUart,"%d %d\n\r",i,e);
		}
	}
	stepperCtrl.feedback(feedback); //restore feedback
	return 0;
} */

/*
static int testringing_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	stepperCtrl.testRinging();
	return 0;
}
 */

//static int sysparams_cmd(sCmdUart *ptrUart,int argc, char * argv[])
//{
//	if (0 == argc)
//	{
//		CommandPrintf(ptrUart,"microsteps %d\n\r",NVM->SystemParams.microsteps);
//		CommandPrintf(ptrUart,"dirPinRotation %d\n\r",NVM->SystemParams.dirPinRotation);
//		CommandPrintf(ptrUart,"errorLimit %d\n\r",NVM->SystemParams.errorLimit);
//		CommandPrintf(ptrUart,"errorPinMode %d\n\r",NVM->SystemParams.errorPinMode);
//		CommandPrintf(ptrUart,"controllerMode %d\n\r",NVM->SystemParams.controllerMode);
//
//	} else	if (5 == argc)
//	{
//		int32_t x;
//		SystemParams_t systemParams;
//
//		systemParams.microsteps=atol(argv[0]);
//		x=atol(argv[1]);
//		systemParams.dirPinRotation=CCW_ROTATION;
//		if (x==0)
//		{
//			systemParams.dirPinRotation=CW_ROTATION;
//		}
//		systemParams.errorLimit=atol(argv[2]);
//		systemParams.errorPinMode=(ErrorPinMode_t)atol(argv[3]);
//		systemParams.controllerMode=(feedbackCtrl_t)atol(argv[4]);
//
//		nvmWriteSystemParms(systemParams);
//		stepperCtrl.updateParamsFromNVM();
//
//		CommandPrintf(ptrUart,"microsteps %d\n\r",NVM->SystemParams.microsteps);
//		CommandPrintf(ptrUart,"dirPinRotation %d\n\r",NVM->SystemParams.dirPinRotation);
//		CommandPrintf(ptrUart,"errorLimit %d\n\r",NVM->SystemParams.errorLimit);
//		CommandPrintf(ptrUart,"errorPinMode %d\n\r",NVM->SystemParams.errorPinMode);
//		CommandPrintf(ptrUart,"controllerMode %d\n\r",NVM->SystemParams.controllerMode);
//	} else
//	{
//		CommandPrintf(ptrUart, "try 'sysparams microsteps dirPinRotation errorLimit errorPinMode controllerMode'\n\r\tlike 'sysparams 16 0 327 0 2'\n\e");
//	}
//	return 0;
//}

/*
static int motorparams_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	if (0 == argc)
	{
		CommandPrintf(ptrUart,"currentMa %d\n\r",NVM->motorParams.currentMa);
		CommandPrintf(ptrUart,"currentHoldMa %d\n\r",NVM->motorParams.currentHoldMa);
		CommandPrintf(ptrUart,"motorWiring %d\n\r",NVM->motorParams.motorWiring);
		CommandPrintf(ptrUart,"fullStepsPerRotation %d\n\r",NVM->motorParams.fullStepsPerRotation);

	} else	if (4 == argc)
	{
		int32_t x;
		MotorParams_t motorParams;

		motorParams.currentMa=atol(argv[0]);
		motorParams.currentHoldMa=atol(argv[1]);
		motorParams.motorWiring=atol(argv[2]);
		motorParams.fullStepsPerRotation=atol(argv[3]);

		nvmWriteMotorParms(motorParams);
		stepperCtrl.updateParamsFromNVM();

		CommandPrintf(ptrUart,"currentMa %d\n\r",NVM->motorParams.currentMa);
		CommandPrintf(ptrUart,"currentHoldMa %d\n\r",NVM->motorParams.currentHoldMa);
		CommandPrintf(ptrUart,"motorWiring %d\n\r",NVM->motorParams.motorWiring);
		CommandPrintf(ptrUart,"fullStepsPerRotation %d\n\r",NVM->motorParams.fullStepsPerRotation);
	} else
	{
		CommandPrintf(ptrUart, "try 'motorparams currentMa currentHoldMa motorWiring fullStepsPerRotation'\n\r\tlike 'motroparams 2200 1500 0 200'\n\e");
	}
	return 0;
}
 */
static int vpid_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	CommandPrintf(ptrUart, "args %d\n\r",argc);
	if (0 == argc)
	{
		int32_t x,y;
		x=(int32_t)NVM->vPID.Kp;
		y=abs(1000*NVM->vPID.Kp-(x*1000));
		CommandPrintf(ptrUart,"Kp %d.%03d\n\r",x,y);

		x=(int32_t)NVM->vPID.Ki;
		y=abs(1000*NVM->vPID.Ki-(x*1000));
		CommandPrintf(ptrUart,"Ki %d.%03d\n\r",x,y);

		x=(int32_t)NVM->vPID.Kd;
		y=abs(1000*NVM->vPID.Kd-(x*1000));
		CommandPrintf(ptrUart,"Kd %d.%03d\n\r",x,y);
	}
	if (3 == argc)
	{
		float Kp,Ki,Kd;
		int32_t x,y;

		Kp=atof(argv[0]);
		Ki=atof(argv[1]);
		Kd=atof(argv[2]);

		nvmWrite_vPID(Kp,Ki,Kd);
		stepperCtrl.updateParamsFromNVM(); //force the controller to use the new parameters

		x=(int32_t)NVM->vPID.Kp;
		y=abs(1000*NVM->vPID.Kp-(x*1000));
		CommandPrintf(ptrUart,"Kp %d.%03d\n\r",x,y);

		x=(int32_t)NVM->vPID.Ki;
		y=abs(1000*NVM->vPID.Ki-(x*1000));
		CommandPrintf(ptrUart,"Ki %d.%03d\n\r",x,y);

		x=(int32_t)NVM->vPID.Kd;
		y=abs(1000*NVM->vPID.Kd-(x*1000));
		CommandPrintf(ptrUart,"Kd %d.%03d\n\r",x,y);
	}
	return 0;
}

static int ppid_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	if (0 == argc)
	{
		int32_t x,y;
		x=(int32_t)NVM->pPID.Kp;
		y=abs(1000*NVM->pPID.Kp-(x*1000));
		CommandPrintf(ptrUart,"Kp %d.%03d\n\r",x,y);

		x=(int32_t)NVM->pPID.Ki;
		y=abs(1000*NVM->pPID.Ki-(x*1000));
		CommandPrintf(ptrUart,"Ki %d.%03d\n\r",x,y);

		x=(int32_t)NVM->pPID.Kd;
		y=abs(1000*NVM->pPID.Kd-(x*1000));
		CommandPrintf(ptrUart,"Kd %d.%03d\n\r",x,y);
	}
	if (3 == argc)
	{
		float Kp,Ki,Kd;
		int32_t x,y;

		Kp=atof(argv[0]);
		Ki=atof(argv[1]);
		Kd=atof(argv[2]);

		nvmWrite_pPID(Kp,Ki,Kd);
		stepperCtrl.updateParamsFromNVM(); //force the controller to use the new parameters

		x=(int32_t)NVM->pPID.Kp;
		y=abs(1000*NVM->pPID.Kp-(x*1000));
		CommandPrintf(ptrUart,"Kp %d.%03d\n\r",x,y);

		x=(int32_t)NVM->pPID.Ki;
		y=abs(1000*NVM->pPID.Ki-(x*1000));
		CommandPrintf(ptrUart,"Ki %d.%03d\n\r",x,y);

		x=(int32_t)NVM->pPID.Kd;
		y=abs(1000*NVM->pPID.Kd-(x*1000));
		CommandPrintf(ptrUart,"Kd %d.%03d\n\r",x,y);
	}
	return 0;
}

static int spid_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	if (0 == argc)
	{
		int32_t x,y;
		x=(int32_t)NVM->sPID.Kp;
		y=abs(1000*NVM->sPID.Kp-(x*1000));
		CommandPrintf(ptrUart,"Kp %d.%03d\n\r",x,y);

		x=(int32_t)NVM->sPID.Ki;
		y=abs(1000*NVM->sPID.Ki-(x*1000));
		CommandPrintf(ptrUart,"Ki %d.%03d\n\r",x,y);

		x=(int32_t)NVM->sPID.Kd;
		y=abs(1000*NVM->sPID.Kd-(x*1000));
		CommandPrintf(ptrUart,"Kd %d.%03d\n\r",x,y);
	}
	if (3 == argc)
	{
		float Kp,Ki,Kd;
		int32_t x,y;

		Kp=atof(argv[0]);
		Ki=atof(argv[1]);
		Kd=atof(argv[2]);

		nvmWrite_sPID(Kp,Ki,Kd);
		stepperCtrl.updateParamsFromNVM(); //force the controller to use the new parameters

		x=(int32_t)NVM->sPID.Kp;
		y=abs(1000*NVM->sPID.Kp-(x*1000));
		CommandPrintf(ptrUart,"Kp %d.%03d\n\r",x,y);

		x=(int32_t)NVM->sPID.Ki;
		y=abs(1000*NVM->sPID.Ki-(x*1000));
		CommandPrintf(ptrUart,"Ki %d.%03d\n\r",x,y);

		x=(int32_t)NVM->sPID.Kd;
		y=abs(1000*NVM->sPID.Kd-(x*1000));
		CommandPrintf(ptrUart,"Kd %d.%03d\n\r",x,y);
	}
	return 0;
}

static int torque_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	if (0 == argc)
	{
		CommandPrintf(ptrUart,"torque %d\n\r", stepperCtrl.getTorque());
	}
	else if (1 == argc)
	{
		int32_t rec32;
		int8_t rec;
		rec32 = atoi(argv[0]);
		if(rec32 > 127 || rec32 < -128)
		{
			CommandPrintf(ptrUart, "Error setting torque %d: not in valid range [-128, 127].", rec);
		}
		else
		{
			rec = (int8_t)rec32;
			if (0 == rec)
			{
				stepperCtrl.torqueSetToZeroSpecialBehaviour();
				if (stepperCtrl.getControlMode() == CTRL_POS_PID)
				{
					CommandPrintf(ptrUart,"controller Current-Position-PID(3)");
				}
				else if (stepperCtrl.getControlMode() == CTRL_SIMPLE)
				{
					CommandPrintf(ptrUart,"controller Simple-Position-PID(2)");
				}
			}
			else
			{
				stepperCtrl.setTorque(rec); // Units -128 - 127
				CommandPrintf(ptrUart, "torque set to %d", rec);
				stepperCtrl.stealthSwitchMode(CTRL_TORQUE);
			}
		}
	}
	return 0;
}

static int encoderdiag_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	char str[512];
	stepperCtrl.encoderDiagnostics(str);
	CommandPrintf(ptrUart,"%s",str);
	return 0;
}

static int readpos_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	float pos;
	int32_t x,y;

	pos=ANGLE_T0_DEGREES(stepperCtrl.getCurrentAngle());
	x=int(pos);
	y=abs((pos-x)*100);
	CommandPrintf(ptrUart,"encoder %d.%02d",x,y);
	return 0;
}
static int feedback_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	if (0 == argc)
	{
		CommandPrintf(ptrUart,"must pass argument, 'feedback 0' - disables, 'feedback 1' - enables");
		return 1;
	}
	stepperCtrl.feedback(atoi(argv[0]));
	return 0;
}

static int step_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	if (argc == 0 )
	{
		stepperCtrl.move(0, 1);
		//stepperCtrl.step(STEPPER_FORWARD);
	}else
	{
		int d, steps=1;
		d=atoi(argv[0]);
		if (argc >1)
		{
			steps=atoi(argv[1]);
		}
		if (1 == d)
		{
			stepperCtrl.move(1, steps);
		} else
		{
			stepperCtrl.move(0, steps);
		}
	}
	return 0;
}


static int microsteps_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	bool ret;

	if (argc != 1)
	{
		CommandPrintf(ptrUart,"microsteps %d\n\r",NVM->SystemParams.microsteps);
		return 0;
	}

	int32_t x;

	x=atol(argv[0]);
	if (isPowerOfTwo(x) && x>0 && x<=256)
	{
		SystemParams_t systemParams;

		memcpy(&systemParams,&NVM->SystemParams, sizeof(systemParams) );

		systemParams.microsteps=atol(argv[0]);

		nvmWriteSystemParms(systemParams);
		stepperCtrl.updateParamsFromNVM();

		CommandPrintf(ptrUart,"microsteps %d\n\r",NVM->SystemParams.microsteps);

	}else
	{
		CommandPrintf(ptrUart,"number of microsteps must be a power of 2 between 1 and 256");
		return 1; //return error
	}

	return 0;
}


// print out the help strings for the commands
static int help_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	sCommand cmd_list;
	int i;

	//now let's parse the command
	i=0;
	memcpy(&cmd_list, &Cmds[i], sizeof(sCommand));
	while(cmd_list.function!=0)
	{

		CommandPrintf(ptrUart,(cmd_list.name));
		CommandPrintf(ptrUart,(" - "));
		CommandPrintf(ptrUart,(cmd_list.help));
		CommandPrintf(ptrUart,("\n\r"));
		i=i+1;
		memcpy(&cmd_list, &Cmds[i], sizeof(sCommand));
	}
	return 0;
}



static int getcal_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	stepperCtrl.calTable.printCalTable();
	return 0;
}

static int calibrate_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	stepperCtrl.calibrateEncoder();
	CommandPrintf(ptrUart,"Calibration DONE!\n\r");
	return 0;
}

static int testcal_cmd(sCmdUart *ptrUart,int argc, char * argv[])
{
	Angle a;
	int32_t x;

	a=stepperCtrl.maxCalibrationError();
	x=(uint16_t)a*(int32_t)360000L/(int32_t)ANGLE_MAX;

	CommandPrintf(ptrUart,"Max error is %d.%03d degrees\n\r", x/1000,abs(x)%1000);
	return 0;
}




uint8_t kbhit(void)
{
	return SerialUSB.available();
	//return SerialUSB.peek() != -1;
}
uint8_t getChar(void)
{
	return SerialUSB.read();
}
uint8_t putch(char data)
{
	return SerialUSB.write((uint8_t)data);
}


uint8_t kbhit_hw(void)
{
	return Serial5.available();
	//return SerialUSB.peek() != -1;
}
uint8_t getChar_hw(void)
{
	return Serial5.read();
}
uint8_t putch_hw(char data)
{
	return Serial5.write((uint8_t)data);
}


uint8_t kbhit_step_dir(void)
{
	return Serial1.available();
	//return SerialUSB.peek() != -1;
}
uint8_t getChar_step_dir(void)
{
	return Serial1.read();
}
uint8_t putch_step_dir(char data)
{
	return Serial1.write((uint8_t)data);
}



void commandsInit(void)
{
	CommandInit(&UsbUart, kbhit, getChar, putch ,NULL); //set up the UART structure

	CommandInit(&HostUart, kbhit_step_dir, getChar_step_dir, putch_step_dir ,NULL); //set up the UART structure for step and dir pins

#ifdef CMD_SERIAL_PORT
	CommandInit(&SerialUart, kbhit_hw, getChar_hw, putch_hw ,NULL); //set up the UART structure
	Serial5.print("\n\rPower Up\n\r");
	Serial5.print(COMMANDS_PROMPT);
#endif

	SerialUSB.print("\n\rPower Up\n\r");
	SerialUSB.print(COMMANDS_PROMPT);
}

int commandsProcess(void)
{
#ifdef USE_STEP_DIR_SERIAL
	//if the step pin is configured to the SerialCom 0 then we need to process commands
	//if PA11 (D0) is configured to perpherial C then the step pin is UART
	if (getPinMux(PIN_STEP_INPUT) ==  PORT_PMUX_PMUXE_C_Val)
	{
		//SerialUSB.println("host");
		CommandProcess(&HostUart,Cmds,' ',COMMANDS_PROMPT);
	}
#endif //USE_STEP_DIR_SERIAL


#ifdef CMD_SERIAL_PORT
	CommandProcess(&SerialUart,Cmds,' ',COMMANDS_PROMPT);
#endif
	return CommandProcess(&UsbUart,Cmds,' ',COMMANDS_PROMPT);
}
