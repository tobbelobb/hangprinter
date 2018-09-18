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
#include "stepper_controller.h"

#include "nonvolatile.h" //for programmable parameters
#include <Wire.h>
#include <inttypes.h>
#include "steppin.h"

#pragma GCC push_options
#pragma GCC optimize ("-Ofast")

#define WAIT_TC16_REGS_SYNC(x) while(x->COUNT16.STATUS.bit.SYNCBUSY);

volatile bool TC5_ISR_Enabled=false;

void setupTCInterrupts() {



	// Enable GCLK for TC4 and TC5 (timer counter input clock)
	GCLK->CLKCTRL.reg = (uint16_t) (GCLK_CLKCTRL_CLKEN | GCLK_CLKCTRL_GEN_GCLK0 | GCLK_CLKCTRL_ID(GCM_TC4_TC5));
	while (GCLK->STATUS.bit.SYNCBUSY);

	TC5->COUNT16.CTRLA.reg &= ~TC_CTRLA_ENABLE;   // Disable TCx
	WAIT_TC16_REGS_SYNC(TC5)                      // wait for sync

	TC5->COUNT16.CTRLA.reg |= TC_CTRLA_MODE_COUNT16;   // Set Timer counter Mode to 16 bits
	WAIT_TC16_REGS_SYNC(TC5)

	TC5->COUNT16.CTRLA.reg |= TC_CTRLA_WAVEGEN_MFRQ; // Set TC as normal Normal Frq
	WAIT_TC16_REGS_SYNC(TC5)

	TC5->COUNT16.CTRLA.reg |= TC_CTRLA_PRESCALER_DIV1;   // Set perscaler
	WAIT_TC16_REGS_SYNC(TC5)


	TC5->COUNT16.CC[0].reg = F_CPU/NZS_CONTROL_LOOP_HZ;
	WAIT_TC16_REGS_SYNC(TC5)


	TC5->COUNT16.INTENSET.reg = 0;              // disable all interrupts
	TC5->COUNT16.INTENSET.bit.OVF = 1;          // enable overfollow
	//  TC5->COUNT16.INTENSET.bit.MC0 = 1;         // enable compare match to CC0


	NVIC_SetPriority(TC5_IRQn, 2);


	// Enable InterruptVector
	NVIC_EnableIRQ(TC5_IRQn);


	// Enable TC
	TC5->COUNT16.CTRLA.reg |= TC_CTRLA_ENABLE;
	WAIT_TC16_REGS_SYNC(TC5)

}

static void enableTCInterrupts() {

	TC5_ISR_Enabled=true;
	NVIC_EnableIRQ(TC5_IRQn);
	TC5->COUNT16.INTENSET.bit.OVF = 1;
	//  TC5->COUNT16.CTRLA.reg |= TC_CTRLA_ENABLE;    //Enable TC5
	//  WAIT_TC16_REGS_SYNC(TC5)                      //wait for sync
}

static void disableTCInterrupts() {

	TC5_ISR_Enabled=false;
	//NVIC_DisableIRQ(TC5_IRQn);
	TC5->COUNT16.INTENCLR.bit.OVF = 1;
}

static bool enterCriticalSection()
{
	bool state=TC5_ISR_Enabled;
	disableTCInterrupts();
	return state;
}

static void exitCriticalSection(bool prevState)
{
	if (prevState)
	{
		enableTCInterrupts();
	} //else do nothing
}


void StepperCtrl::updateParamsFromNVM(void)
{
	bool state=enterCriticalSection();

	pPID.Kd=NVM->pPID.Kd*CTRL_PID_SCALING;
	pPID.Ki=NVM->pPID.Ki*CTRL_PID_SCALING;
	pPID.Kp=NVM->pPID.Kp*CTRL_PID_SCALING;

	vPID.Kd=NVM->vPID.Kd*CTRL_PID_SCALING;
	vPID.Ki=NVM->vPID.Ki*CTRL_PID_SCALING;
	vPID.Kp=NVM->vPID.Kp*CTRL_PID_SCALING;

	sPID.Kd=NVM->sPID.Kd*CTRL_PID_SCALING;
	sPID.Ki=NVM->sPID.Ki*CTRL_PID_SCALING;
	sPID.Kp=NVM->sPID.Kp*CTRL_PID_SCALING;

	if (NVM->SystemParams.parametersVaild)
	{
		memcpy((void *)&systemParams, (void *)&NVM->SystemParams, sizeof(systemParams));
		LOG("Home pin %d",systemParams.homePin);

	}else
	{
		ERROR("This should never happen but just in case");
		systemParams.microsteps=16;
		#if defined(CTRL_POS_PID_AS_DEFAULT)
			systemParams.controllerMode=CTRL_POS_PID;
		#else
			systemParams.controllerMode=CTRL_SIMPLE;
		#endif
		systemParams.dirPinRotation=CW_ROTATION; //default to clockwise rotation when dir is high
		systemParams.errorLimit=(int32_t)ANGLE_FROM_DEGREES(1.8);
		systemParams.errorPinMode=ERROR_PIN_MODE_ENABLE;  //default to enable pin
		systemParams.errorLogic=false;
		systemParams.homeAngleDelay=ANGLE_FROM_DEGREES(10);
		systemParams.homePin=-1; //no homing pin configured
	}

	//default the error pin to input, if it is an error pin the
	// handler for this will change the pin to be an output.
	// for bidirection error it has to handle input/output it's self as well.
	// This is not the cleanest way to handle this...
	// TODO implement this cleaner?
	pinMode(PIN_ERROR, INPUT_PULLUP); //we have input pin

	if (NVM->motorParams.parametersVaild)
	{
		memcpy((void *)&motorParams, (void *)&NVM->motorParams, sizeof(motorParams));
	} else
	{
		//MotorParams_t Params;
		motorParams.fullStepsPerRotation=200;
		motorParams.currentHoldMa=500;
		motorParams.currentMa=800;
		motorParams.homeHoldMa=200;
		motorParams.homeMa=800;
		motorParams.motorWiring=true;
		//memcpy((void *)&Params, (void *)&motorParams, sizeof(motorParams));
		//nvmWriteMotorParms(Params);
	}

	stepperDriver.setRotationDirection(motorParams.motorWiring);

	exitCriticalSection(state);
}


void  StepperCtrl::motorReset(void)
{
	//when we reset the motor we want to also sync the motor
	// phase.  Therefore we move forward a few full steps then back
	// to sync motor phasing, leaving the motor at "phase 0"
	bool state=enterCriticalSection();

	//	stepperDriver.move(0,motorParams.currentMa);
	//	delay(100);
	//	stepperDriver.move(A4954_NUM_MICROSTEPS,motorParams.currentMa);
	//	delay(100);
	//	stepperDriver.move(A4954_NUM_MICROSTEPS*2,motorParams.currentMa);
	//	delay(100);
	//	stepperDriver.move(A4954_NUM_MICROSTEPS*3,motorParams.currentMa);
	//	delay(100);
	//	stepperDriver.move(A4954_NUM_MICROSTEPS*2,motorParams.currentMa);
	//	delay(100);
	//	stepperDriver.move(A4954_NUM_MICROSTEPS,motorParams.currentMa);
	//	delay(100);
	stepperDriver.move(0,motorParams.currentMa);
	delay(1000);

	setLocationFromEncoder(); //measure new starting point
	exitCriticalSection(state);
}

void StepperCtrl::setLocationFromEncoder(void)
{
	numSteps=0;
	currentLocation=0;

	if (calTable.calValid())
	{
		int32_t n,x;
		int32_t calIndex;
		Angle a;

		//set our angles based on previous cal data

		x=sampleMeanEncoder(200);
		a=calTable.fastReverseLookup(x);

		//our cal table starts at angle zero, so lets set starting based on this and stepsize
		LOG("start angle %d, encoder %d", (uint16_t)a,x);

		// we were rounding to nearest full step, but this should not be needed TBS 10/12/2017
		//		//TODO we need to handle 0.9 degree motor
		//		if (CALIBRATION_TABLE_SIZE == motorParams.fullStepsPerRotation)
		//		{
		//			n=(int32_t)ANGLE_STEPS/CALIBRATION_TABLE_SIZE;
		//
		//			calIndex=((int32_t)((uint16_t)a+n/2)*CALIBRATION_TABLE_SIZE)/ANGLE_STEPS; //find calibration index
		//			if (calIndex>CALIBRATION_TABLE_SIZE)
		//			{
		//				calIndex-=CALIBRATION_TABLE_SIZE;
		//			}
		//			a=(uint16_t)((calIndex*ANGLE_STEPS)/CALIBRATION_TABLE_SIZE);
		//		}


		x=(int32_t)((((float)(uint16_t)a)*360.0/(float)ANGLE_STEPS)*1000);
		LOG("start angle after rounding %d %d.%03d", (uint16_t)a,x/1000,x%1000);

		//we need to set our numSteps
		numSteps=DIVIDE_WITH_ROUND( ((int32_t)a *motorParams.fullStepsPerRotation*systemParams.microsteps),ANGLE_STEPS);
		currentLocation=(uint16_t)a;
	}
	zeroAngleOffset=getCurrentLocation(); //zero the angle shown on LCD
}

void StepperCtrl::acceptPositionAndStealthSwitchMode(feedbackCtrl_t m)
{
	bool state=enterCriticalSection();
	currentLocationIsDesiredLocation();
	systemParams.controllerMode=m;
	exitCriticalSection(state);
}

void StepperCtrl::stealthSwitchMode(feedbackCtrl_t m)
{
	bool state=enterCriticalSection();
	systemParams.controllerMode=m;
	exitCriticalSection(state);
}

int64_t StepperCtrl::getZeroAngleOffset(void)
{
	int64_t x;
	bool state=enterCriticalSection();

	x=zeroAngleOffset;

	exitCriticalSection(state);
	return x;
}

void StepperCtrl::setAngle(int64_t angle)
{
	bool state=enterCriticalSection();

	zeroAngleOffset=getCurrentLocation()-angle;

	exitCriticalSection(state);
}

void StepperCtrl::setZero(void)
{
	//we want to set the starting angle to zero.
	bool state=enterCriticalSection();

	zeroAngleOffset=getCurrentLocation();

	exitCriticalSection(state);
}

void StepperCtrl::encoderDiagnostics(char *ptrStr)
{
	bool state=TC5_ISR_Enabled;
	disableTCInterrupts();

	encoder.diagnostics(ptrStr);

	if (state) enableTCInterrupts();
}


//TODO This function does two things, set rotation direction
//  and measures step size, it should be two functions.
//return is anlge in degreesx100 ie 360.0 is returned as 36000
float StepperCtrl::measureStepSize(void)
{
	int32_t angle1,angle2,x,i;
	bool feedback=enableFeedback;
	int32_t microsteps=systemParams.microsteps;

	systemParams.microsteps=1;
	enableFeedback=false;
	motorParams.motorWiring=true; //assume we are forward wiring to start with
	stepperDriver.setRotationDirection(motorParams.motorWiring);
	/////////////////////////////////////////
	//// Measure the full step size /////
	/// Note we assume machine can take one step without issue///

	LOG("reset motor");
	motorReset(); //this puts stepper motor at stepAngle of zero

	LOG("sample encoder");

	angle1=sampleMeanEncoder(200);

	LOG("move");
	stepperDriver.move(A4954_NUM_MICROSTEPS/2,motorParams.currentMa); //move one half step 'forward'
	delay(100);
	stepperDriver.move(A4954_NUM_MICROSTEPS,motorParams.currentMa); //move one half step 'forward'
	delay(500);
	LOG("sample encoder");
	angle2=sampleMeanEncoder(200);

	LOG("Angles %d %d",angle1,angle2);
	if ((abs(angle2-angle1))>(ANGLE_STEPS/2))
	{
		//we crossed the wrap around
		if (angle1>angle2)
		{
			angle1=angle1+(int32_t)ANGLE_STEPS;
		}else
		{
			angle2=angle2+(int32_t)ANGLE_STEPS;
		}
	}
	LOG("Angles %d %d",angle1,angle2);

	//when we are increase the steps in the  stepperDriver.move() command
	// we want the encoder increasing. This ensures motor is moving clock wise
	// when encoder is increasing.
	//	if (angle2>angle1)
	//	{
	//		motorParams.motorWiring=true;
	//		stepperDriver.setRotationDirection(true);
	//		LOG("Forward rotating");
	//	}else
	//	{
	//		//the motor is wired backwards so correct in stepperDriver
	//		motorParams.motorWiring=false;
	//		stepperDriver.setRotationDirection(false);
	//		LOG("Reverse rotating");
	//	}
	x=((int64_t)(angle2-angle1)*36000)/(int32_t)ANGLE_STEPS;
	// if x is ~180 we have a 1.8 degree step motor, if it is ~90 we have 0.9 degree step
	LOG("%angle delta %d %d (%d %d)",x,abs(angle2-angle1),angle1,angle2 );

	//move back
	stepperDriver.move(-A4954_NUM_MICROSTEPS/2,motorParams.currentMa); //move one half step 'forward'
	delay(100);
	stepperDriver.move(-A4954_NUM_MICROSTEPS,motorParams.currentMa); //move one half step 'forward'

	systemParams.microsteps=microsteps;
	enableFeedback=feedback;

	return ((float)x)/100.0;
}


int32_t StepperCtrl::measureError(void)
{
	//LOG("current %d desired %d %d",(int32_t) currentLocation, (int32_t)getDesiredLocation(), numSteps);

	return ((int32_t)currentLocation-(int32_t)getDesiredLocation());
}

/*
bool StepperCtrl::changeMicrostep(uint16_t microSteps)
{
	bool state=TC5_ISR_Enabled;
	disableTCInterrupts();
	systemParams.microsteps=microSteps;
	motorReset();
	if (state) enableTCInterrupts();
	return true;
}
 */
Angle StepperCtrl::maxCalibrationError(void)
{
	//Angle startingAngle;
	bool done=false;
	int32_t mean;
	int32_t maxError=0, j;
	int16_t dist;
	uint16_t angle=0;
	bool feedback=enableFeedback;
	uint16_t microSteps=systemParams.microsteps;
	int32_t steps;
	bool state=TC5_ISR_Enabled;
	disableTCInterrupts();


	if (false == calTable.calValid())
	{
		return ANGLE_MAX;
	}

	enableFeedback=false;
	j=0;
	LOG("Running calibration test");

	systemParams.microsteps=1;
	motorReset();
	steps=0;

	while(!done)
	{
		Angle cal;
		Angle act, desiredAngle;

		//todo we should measure mean and wait until stable.
		delay(200);
		mean=sampleMeanEncoder(200);
		desiredAngle=(uint16_t)(getDesiredLocation() & 0x0FFFFLL);

		cal=calTable.getCal(desiredAngle);
		dist=Angle(mean)-cal;
		act=calTable.fastReverseLookup(cal);

		LOG("actual %d, cal %d",mean,(uint16_t)cal);
		LOG("desired %d",(uint16_t)desiredAngle);
		LOG("numSteps %d", numSteps);

		LOG("cal error for step %d is %d",j,dist);
		LOG("mean %d, cal %d",mean, (uint16_t)cal);

		updateStep(0,1);

		// move one half step at a time, a full step move could cause a move backwards depending on how current ramps down
		steps+=A4954_NUM_MICROSTEPS/2;
		stepperDriver.move(steps,motorParams.currentMa);

		delay(50);
		steps+=A4954_NUM_MICROSTEPS/2;
		stepperDriver.move(steps,motorParams.currentMa);


		if (400==motorParams.fullStepsPerRotation)
		{
			delay(100);
			updateStep(0,1);
			// move one half step at a time, a full step move could cause a move backwards depending on how current ramps down
			steps+=A4954_NUM_MICROSTEPS/2;
			stepperDriver.move(steps,motorParams.currentMa);

			delay(100);
			steps+=A4954_NUM_MICROSTEPS/2;
			stepperDriver.move(steps,motorParams.currentMa);
		}
		//delay(400);

		if (abs(dist)>maxError)
		{
			maxError=abs(dist);
		}

		j++;
		if (j>=(1*CALIBRATION_TABLE_SIZE+3))
		{
			done=true;
		}


	}
	systemParams.microsteps=microSteps;
	motorReset();
	enableFeedback=feedback;
	if (state) enableTCInterrupts();
	LOG("max error is %d cnts", maxError);
	return Angle((uint16_t)maxError);
}


//The encoder needs to be calibrated to the motor.
// we will assume full step detents are correct,
// ex 1.8 degree motor will have 200 steps for 360 degrees.
// We also need to calibrate the phasing of the motor
// to the A4954. This requires that the A4954 "step angle" of
// zero is the first entry in the calibration table.
bool StepperCtrl::calibrateEncoder(void)
{
	int32_t x,i,j;
	uint32_t angle=0;
	int32_t steps;
	bool done=false;

	int32_t mean;
	uint16_t microSteps=systemParams.microsteps;
	bool feedback=enableFeedback;
	bool state=TC5_ISR_Enabled;

	disableTCInterrupts();

	enableFeedback=false;
	systemParams.microsteps=1;
	LOG("reset motor");
	motorReset();
	LOG("Starting calibration");
	delay(200);
	steps=0;
	j=0;
	while(!done)
	{
		int ii,N;
		Angle cal,desiredAngle;
		desiredAngle=(uint16_t)(getDesiredLocation() & 0x0FFFFLL);
		cal=calTable.getCal(desiredAngle);
		delay(200);
		mean=sampleMeanEncoder(200);

		LOG("Previous cal distance %d, %d, mean %d, cal %d",j, cal-Angle((uint16_t)mean), mean, (uint16_t)cal);

		calTable.updateTableValue(j,mean);

		updateStep(0,1);

		N=2;
		// move one half step at a time, a full step move could cause a move backwards depending on how current ramps down
		for (ii=0; ii<N; ii++)
		{
			steps+=A4954_NUM_MICROSTEPS/N;
			stepperDriver.move(steps,motorParams.currentMa);

			delay(50);
		}
		//steps+=A4954_NUM_MICROSTEPS/2;
		//stepperDriver.move(steps,motorParams.currentMa);



		if (400==motorParams.fullStepsPerRotation)
		{
			delay(100);
			updateStep(0,1);
			// move one half step at a time, a full step move could cause a move backwards depending on how current ramps down
			steps+=A4954_NUM_MICROSTEPS/2;
			stepperDriver.move(steps,motorParams.currentMa);

			delay(100);
			steps+=A4954_NUM_MICROSTEPS/2;
			stepperDriver.move(steps,motorParams.currentMa);

		}

		j++;
		if (j>=CALIBRATION_TABLE_SIZE)
		{
			done=true;
		}


	}
	//calTable.printCalTable();
	//calTable.smoothTable();
	//calTable.printCalTable();
	calTable.saveToFlash(); //saves the calibration to flash
	calTable.printCalTable();

	systemParams.microsteps=microSteps;
	motorReset();
	enableFeedback=feedback;
	if (state) enableTCInterrupts();
	return done;
}





stepCtrlError_t StepperCtrl::begin(void)
{
	int i;
	float x;


	enableFeedback=false;
	velocity=0;
	currentLocation=0;
	numSteps=0;

	//we have to update from NVM before moving motor
	updateParamsFromNVM(); //update the local cache from the NVM

	LOG("start up encoder");
	if (false == encoder.begin(PIN_AS5047D_CS))
	{
		return STEPCTRL_NO_ENCODER;
	}

	LOG("cal table init");
	calTable.init();

	startUpEncoder=(uint16_t)getEncoderAngle();
	WARNING("start up encoder %d",startUpEncoder);

	LOG("start stepper driver");
	stepperDriver.begin();

#ifdef NEMA17_SMART_STEPPER_3_21_2017
	if (NVM->motorParams.parametersVaild)
	{
		//lets read the motor voltage
		if (GetMotorVoltage()<5)
		{
			//if we have less than 5 volts the motor is not powered
			uint32_t x;
			x=(uint32_t)(GetMotorVoltage()*1000.0);
			ERROR("Motor voltage is %" PRId32 "mV",x); //default printf does not support floating point numbers
			ERROR("Motor may not have power");
			return STEPCTRL_NO_POWER;
		}
		bool state=enterCriticalSection();
		setLocationFromEncoder(); //measure new starting point
		exitCriticalSection(state);

	}else
	{
		LOG("measuring step size");
		x=measureStepSize();
		if (abs(x)<0.5)
		{
			ERROR("Motor may not have power");
			return STEPCTRL_NO_POWER;
		}
	}

#else
	LOG("measuring step size");
	x=measureStepSize();
	if (abs(x)<0.5)
	{
		ERROR("Motor may not have power");
		return STEPCTRL_NO_POWER;
	}
#endif


	LOG("Checking the motor parameters");
	//todo we might want to move this up a level to the NZS
	//  especially since it has default values
	if (false == NVM->motorParams.parametersVaild)
	{
		MotorParams_t params;
		WARNING("NVM motor parameters are not set, we will update");

		//power could have just been applied and step size read wrong
		// if we are more than 200 steps/rotation which is most common
		// lets read again just to be sure.
		if (abs(x)<1.5)
		{
			//run step test a second time to be sure
			x=measureStepSize();
		}

		if (x>0)
		{
			motorParams.motorWiring=true;
		} else
		{
			motorParams.motorWiring=false;
		}
		if (abs(x)<=1.2)
		{
			motorParams.fullStepsPerRotation=400;
		}else
		{
			motorParams.fullStepsPerRotation=200;
		}

		memcpy((void *)&params, (void *)&motorParams,sizeof(motorParams));
		nvmWriteMotorParms(params);
	}

	LOG("Motor params are now good");
	LOG("fullSteps %d", motorParams.fullStepsPerRotation);
	LOG("motorWiring %d", motorParams.motorWiring);
	LOG("currentMa %d", motorParams.currentMa);
	LOG("holdCurrentMa %d", motorParams.currentHoldMa);
	LOG("homeMa %d", motorParams.homeMa);
	LOG("homeHoldMa %d", motorParams.homeHoldMa);


	updateParamsFromNVM(); //update the local cache from the NVM


	if (false == calTable.calValid())
	{
		return STEPCTRL_NO_CAL;
	}


	enableFeedback=true;
	setupTCInterrupts();
	enableTCInterrupts();
	return STEPCTRL_NO_ERROR;

}

Angle StepperCtrl::sampleAngle(void)
{
	uint16_t angle;
	int32_t x,y;

#ifdef NZS_AS5047_PIPELINE
	//read encoder twice such that we get the latest sample as the pipeline is always once sample behind


	y=encoder.readEncoderAnglePipeLineRead(); //convert the 14 bit encoder value to a 16 bit number
	x=encoder.readEncoderAnglePipeLineRead();


	angle=((uint32_t)(x)*4); //convert the 14 bit encoder value to a 16 bit number
#else
	angle=((uint32_t)encoder.readEncoderAngle())<<2; //convert the 14 bit encoder value to a 16 bit number
#endif
	return Angle(angle);
}

//when sampling the mean of encoder if we are on roll over
// edge we can have an issue so we have this function
// to do the mean correctly
Angle StepperCtrl::sampleMeanEncoder(int32_t numSamples)
{

	int32_t i,last,x=0;
	int64_t mean=0;
	int32_t min,max;

	mean=0;
	for (i=0; i<(numSamples); i++)
	{
		int32_t d;
		last=x;
		x=(((int32_t)encoder.readEncoderAngle())*4);
		if (encoder.getError())
		{

			SerialUSB.println("AS5047 Error");
			delay(1000);
			return 0;
		}
		if(i==0)
		{
			last=x;
			min=x;
			max=x;
		}
		//LOG("i %d,min %d, max %d, last %d, x %d", i, min, max, last, x);
		if (abs(last-x)>65536/2)
		{
			if (last>x)
			{
				x=x+65536;
			} else
			{
				x=x-65536;
			}
		}


		if (x>max)
		{
			max=x;
		}
		if (x<min)
		{
			min=x;
		}

		mean=mean+(x);
	}

	LOG("min %d, max %d, mean %d", min, max, (int32_t)(mean/numSamples));
	return Angle(mean/numSamples);
}

void StepperCtrl::feedback(bool enable)
{
	disableTCInterrupts();
	motorReset();
	enableFeedback=enable;
	if (enable == true)
	{
		enableTCInterrupts();
	}
}


void StepperCtrl::updateSteps(int64_t steps)
{
	bool state=TC5_ISR_Enabled;
	disableTCInterrupts();
	numSteps+=steps;
	if (state) enableTCInterrupts();
}

void StepperCtrl::updateStep(int dir, uint16_t steps)
{
	bool state=TC5_ISR_Enabled;
	disableTCInterrupts();
	if (dir)
	{
		numSteps-=steps;
	}else
	{
		numSteps+=steps;
	}
	if (state) enableTCInterrupts();
}

void StepperCtrl::requestStep(int dir, uint16_t steps)
{
	bool state;
	state=TC5_ISR_Enabled;
	disableTCInterrupts();

	if (dir)
	{
		numSteps-=steps;
	}else
	{
		numSteps+=steps;
	}

	if (false == enableFeedback)
	{
		moveToAngle(getDesiredLocation(),motorParams.currentMa);
	}
	if (state) enableTCInterrupts();
}


void StepperCtrl::move(int dir, uint16_t steps)
{
	int64_t ret;
	int32_t n;



	updateStep(dir,steps);

	if (false == enableFeedback)
	{
		n=systemParams.microsteps;
		ret=((int64_t)numSteps * A4954_NUM_MICROSTEPS+(n/2))/n;
		n=A4954_NUM_MICROSTEPS*motorParams.fullStepsPerRotation;
		while(ret>n)
		{
			ret-=n;
		}
		while(ret<-n)
		{
			ret+=n;
		}
		n=(int32_t)(ret);
		LOG("s is %d %d",n,steps);
		stepperDriver.move(n,motorParams.currentMa);
	}


}



int64_t StepperCtrl::getDesiredLocation(void)
{
	int64_t ret;
	int32_t n;
	bool state=TC5_ISR_Enabled;
	disableTCInterrupts();
	n=motorParams.fullStepsPerRotation * systemParams.microsteps;
	ret=((int64_t)numSteps * (int64_t)ANGLE_STEPS+(n/2))/n ;
	if (state) enableTCInterrupts();
	return ret;
}


//int32_t StepperCtrl::getSteps(void)
//{
//	int32_t ret;
//	bool state=enterCriticalSection();
//	ret=numSteps;
//	exitCriticalSection(state);
//	return ret;
//}

void StepperCtrl::moveToAbsAngle(int32_t a)
{

	int64_t ret;
	int32_t n;


	n=motorParams.fullStepsPerRotation * systemParams.microsteps;

	ret=(((int64_t)a+zeroAngleOffset)*n+ANGLE_STEPS/2)/(int32_t)ANGLE_STEPS;
	bool state=enterCriticalSection();
	numSteps=ret;
	exitCriticalSection(state);
}

void StepperCtrl::moveToAngle(int32_t a, uint32_t ma)
{
	//we need to convert 'Angle' to A4954 steps
	a=a % ANGLE_STEPS;  //we only interested in the current angle


	a=DIVIDE_WITH_ROUND( (a*motorParams.fullStepsPerRotation*A4954_NUM_MICROSTEPS), ANGLE_STEPS);

	//LOG("move %d %d",a,ma);
	stepperDriver.move(a,ma);

}

Angle StepperCtrl::getEncoderAngle(void)
{
	Angle a;
	bool state=enterCriticalSection();
	a=calTable.fastReverseLookup(sampleAngle());
	exitCriticalSection(state);
	return a;
}

int64_t StepperCtrl::getCurrentLocation(void)
{
	Angle a;
	int32_t x;
	bool state=TC5_ISR_Enabled;
	disableTCInterrupts();
	a=calTable.fastReverseLookup(sampleAngle());
	x=(int32_t)a - (int32_t)((currentLocation) & ANGLE_MAX);

	if (x>((int32_t)ANGLE_STEPS/2))
	{
		currentLocation -= ANGLE_STEPS;
	}
	if (x<-((int32_t)ANGLE_STEPS/2))
	{
		currentLocation += ANGLE_STEPS;
	}
	currentLocation=(currentLocation & 0xFFFFFFFFFFFF0000UL) | (uint16_t)a;
	if (state) enableTCInterrupts();
	return currentLocation;

}

int64_t StepperCtrl::getCurrentAngleNoEncoderRead(void)
{
	int64_t x;
	x=currentLocation-zeroAngleOffset;
	return x;
}


int64_t StepperCtrl::getCurrentAngle(void)
{
	int64_t x;
	x=getCurrentLocation()-zeroAngleOffset;
	return x;
}


int64_t StepperCtrl::getDesiredAngle(void)
{
	int64_t x;
	x=getDesiredLocation()-zeroAngleOffset;
	return x;
}

void StepperCtrl::setVelocity(int64_t vel)
{
	bool state=enterCriticalSection();
	velocity=vel;
	exitCriticalSection(state);
}

void StepperCtrl::setTorque(int8_t tor)
{
	bool state=enterCriticalSection();
	torque=tor;
	exitCriticalSection(state);
}

int8_t StepperCtrl::getTorque(void)
{
	int8_t tor;
	bool state=enterCriticalSection();
	tor=torque;
	exitCriticalSection(state);
	return tor;
}

int64_t StepperCtrl::getVelocity(void)
{
	int64_t vel;
	bool state=enterCriticalSection();

	vel=velocity;
	exitCriticalSection(state);
	return vel;
}

void StepperCtrl::PrintData(void)
{
	char s[128];
	bool state=enterCriticalSection();
	sprintf(s, "%u,%u,%u", (uint32_t)numSteps,(uint32_t)getDesiredAngle(),(uint32_t)getCurrentAngle());
	SerialUSB.println(s);
	exitCriticalSection(state);
}
//this is the velocity PID feedback loop
bool StepperCtrl::vpidFeedback(int64_t desiredLoc, int64_t currentLoc, Control_t *ptrCtrl)
{
	int32_t fullStep=ANGLE_STEPS/motorParams.fullStepsPerRotation;
	static int64_t lastY=getCurrentLocation();
	static int32_t lastError=0;
	static int64_t Iterm=0;
	int64_t y,z;
	int64_t v,dy;
	int64_t u;

	//get the current location
	y =currentLoc;

	v=y-lastY;

	//add in phase prediction
	y=y+calculatePhasePrediction(currentLoc);
	z=y;


	lastY=y;

	v=v*NZS_CONTROL_LOOP_HZ;


	if (enableFeedback) //if ((micros()-lastCall)>(updateRate/10))
	{
		int64_t error,U;
		error = velocity-v;


		Iterm += (vPID.Ki * error);
		if (Iterm>(16*4096*CTRL_PID_SCALING *motorParams.currentMa))
		{
			Iterm=(16*4096*CTRL_PID_SCALING *motorParams.currentMa);
		}
		if (Iterm<-(16*4096*CTRL_PID_SCALING *motorParams.currentMa))
		{
			Iterm=-(16*4096*CTRL_PID_SCALING*motorParams.currentMa);
		}

		u=((vPID.Kp * error) + Iterm - (vPID.Kd *(lastError-error)));
		U=abs(u)/CTRL_PID_SCALING/1024; //scale the error to make PID params close to 1.0;//scale the error to make PID params close to 1.0 by dividing by 1024

		if (U>motorParams.currentMa)
		{
			U=motorParams.currentMa;
		}




		//when error is positive we need to move reverse direction
		if (u>0)
		{
			z=z+(fullStep);
		}else
		{
			z=z-(fullStep);

		}

		ptrCtrl->ma=U;
		ptrCtrl->angle=(int32_t)z;
		moveToAngle(z,U);
		loopError=error;
		lastError=error;
	} else
	{
		lastError=0;
		Iterm=0;
	}

	if (abs(lastError)>(systemParams.errorLimit))
	{
		return 1;
	}
	return 0;
}


bool StepperCtrl::torqueLoop(int64_t currentLoc, Control_t *ptrCtrl)
{
	int32_t U, ma;
	int64_t u, y;

	int32_t fullStep=ANGLE_STEPS/motorParams.fullStepsPerRotation;

	y=currentLoc;
	ma=motorParams.currentMa;
	u=torque*ma/128; // Make ma the maximum torque at 128
	// If dir pin changes meaning then torque also changes direction
	if (CW_ROTATION == systemParams.dirPinRotation)
	{
		u=-u;
	}
	U=abs(u);
	if (U>ma)
		U=ma;
	if (u>0)
		y=y+fullStep;
	else
		y=y-fullStep;
	ptrCtrl->ma=U;
	ptrCtrl->angle=(int32_t)y;
	moveToAngle(y,U);
}

//Since we are doing fixed point math our
// threshold needs to be large.
// We need a large threshold when we have fast update
// rate as well. But for most part it is random
bool StepperCtrl::pidFeedback(int64_t desiredLoc, int64_t currentLoc, Control_t *ptrCtrl)
{
	static int count=0;

	static int32_t maxError=0;
	static int32_t lastError=0;
	static int32_t Iterm=0;
	int32_t ma;
	int64_t y;

	int32_t fullStep=ANGLE_STEPS/motorParams.fullStepsPerRotation;
	int32_t dy;

	y=currentLoc;

	//add in phase prediction
	y=y+calculatePhasePrediction(currentLoc);

	if (enableFeedback) //if ((micros()-lastCall)>(updateRate/10))
	{
		int64_t error,u;
		int32_t U,x;

		//error is in units of degrees when 360 degrees == 65536
		error=(desiredLoc-y); //error is currentPos-desiredPos

		Iterm+=(pPID.Ki * error);

		if (systemParams.homePin>0 && digitalRead(systemParams.homePin)==0)
		{
			ma=motorParams.homeMa;
		} else
		{
			ma=motorParams.currentMa;
		}

		//Over the long term we do not want error
		// to be much more than our threshold
		if (Iterm> (ma*CTRL_PID_SCALING) )
		{
			Iterm=(ma*CTRL_PID_SCALING) ;
		}
		if (Iterm<-(ma*CTRL_PID_SCALING)  )
		{
			Iterm=-(ma*CTRL_PID_SCALING) ;
		}

		// Lower effort if we're very far off
		if(abs(error) > 90304) // 540 degrees
		{
			u=(int64_t)((float)ma*(float)CTRL_PID_SCALING*90304.0/(float)error);
		}
		else
		{
			u=((pPID.Kp * error) + Iterm - (pPID.Kd *(lastError-error)));
		}


		U=abs(u)/CTRL_PID_SCALING;
		if (U>ma)
		{
			U=ma;
		}


		//when error is positive we need to move reverse direction
		if (u>0)
		{
			y=y+fullStep;
		}else
		{
			y=y-fullStep;

		}

		ptrCtrl->ma=U;
		ptrCtrl->angle=(int32_t)y;
		moveToAngle(y,U);
		loopError=error;
		lastError=error;

	}else
	{
		lastError=0;
		Iterm=0;
	}

	if (abs(lastError)>(systemParams.errorLimit))
	{
		return 1;
	}
	return 0;
}



// the phase prediction tries to predict error from sensor based
// on current location and previous location.
// TODO our error can help in the phase prediction.
// if the error
int64_t StepperCtrl::calculatePhasePrediction(int64_t currentLoc)
{
	static int64_t lastLoc=0;
	static int32_t mean=0;
	int32_t dx,x;

#ifndef ENABLE_PHASE_PREDICTION
	return 0;
#endif

	//what was our change in the location
	dx=currentLoc-lastLoc;  //max value is typically less than 327(1.8 degrees) or 163(0.9 degree)

	//if the motor direction changes,  zero phase prediction
	if (SIGN(dx) != SIGN(mean))
	{
		//last thing we want is phase prediction during direction change.
		mean=0;
	} else
	{
		if (abs(dx)>abs(mean))
		{
			//increase mean really slowly, 2048 ~ 1/3 second with 6khz processing loop
			// in fixed point since the dx is so small we need to scale it up to average
			// dx has be be greater than 8 to change the mean...
			// this limits the acceleration of motor above max processing speed (6k*1.8)=1800RPM
			//  however I doubt the motor can accelerate that fast with any load...
			//  The average helps prevent external impulse error from causing prediction to cause issues.
			mean=DIVIDE_WITH_ROUND(2047*mean + dx*128, 2048);
		}else
		{
			//decrease fast
			//do not add more phase prediction than the difference in last two samples.
			mean=dx*128;
		}
	}
	lastLoc=currentLoc;

	x= mean/128; //scale back to normal
	return x;
}


bool StepperCtrl::determineError(int64_t currentLoc,int64_t error)
{
	static int64_t lastLocation=0;
	static int64_t lastError=0;
	static int64_t lastVelocity=0;

	int64_t velocity;

	//since this is called on periodic timer the velocity
	// is propotional to the change in location
	// one rotation per second is velocity of 10, assumming 6khz update rate
	// one rotation per minute is 10/60 velocity units
	// since this is less than 1 we will scale the velo
	velocity=(currentLoc-lastLocation);

	if (velocity>0 &&  lastVelocity>0)
	{

	}


	lastVelocity=velocity;
	lastError=error;
	lastLocation=currentLoc;
}

//this was written to do the PID loop not modeling a DC servo
// but rather using features of stepper motor.
bool StepperCtrl::simpleFeedback(int64_t desiredLoc, int64_t currentLoc, Control_t *ptrCtrl)
{
	static uint32_t t0=0;
	static uint32_t calls=0;
	bool ret=false;

	static int32_t maxError=0;
	static int32_t lastError=0;
	static int32_t i=0;
	static int32_t iTerm=0;
	//static int64_t lastY=getCurrentLocation();
	static int32_t velocity=0;
	static int32_t errorCount=0;

	static bool lastProbeState=false;
	static int64_t probeStartAngle=0;
	static int32_t maxMa=0;


	static int64_t filteredError=0;
	static int32_t probeCount=0;

	int32_t fullStep=ANGLE_STEPS/motorParams.fullStepsPerRotation;

	int32_t ma=0;

	int64_t y;



	//estimate our current location based on the encoder
	y=currentLoc;

	//add in phase prediction
	y=y+calculatePhasePrediction(currentLoc);


	//we can limit the velocity by controlling the amount we move per call to this function
	// this only works for velocity greater than 100rpm
	/*	if (velocity!=0)
	{
		fullStep=velocity/NZS_CONTROL_LOOP_HZ;
	}
	if (fullStep==0)
	{
		fullStep=1; //this RPM of (1*NZS_CONTROL_LOOP_HZ)/60 ie at 6Khz it is 100RPM
	}
	 */
	if (enableFeedback)
	{
		int64_t error;
		int32_t u;

		int32_t x;
		int32_t kp;

		//error is in units of degrees when 360 degrees == 65536
		error=(desiredLoc-y);//measureError(); //error is currentPos-desiredPos


		//data[i]=(int16_t)error;
		//i++;
		if (i>=N_DATA)
		{
			i=0;
		}

		kp=sPID.Kp;
		if (1)//(abs(error)<(fullStep))
		{
			iTerm+=(sPID.Ki*error);
			x=iTerm/CTRL_PID_SCALING;
		}else
		{
			kp=(CTRL_PID_SCALING*9)/10;
			x=0;
			iTerm=0;
		}

		if (x>fullStep)
		{
			x=fullStep;
			iTerm=fullStep;
		}
		if (x<-fullStep)
		{
			x=-fullStep;
			iTerm=-fullStep;
		}

		// Lower effort if we're very far off
		if(abs(error) > 90304) // 540 degrees
		{
			u=(int64_t)((float)fullStep*90304.0/(float)error);
		}
		else
		{
			u=(kp * error)/CTRL_PID_SCALING+x+(sPID.Kd *(error-lastError))/CTRL_PID_SCALING;
		}

		//limit error to full step
		if (u>fullStep)
		{
			u=fullStep;
		}
		if (u<-fullStep)
		{
			u=-fullStep;
		}

		ma=(abs(u)*(motorParams.currentMa-motorParams.currentHoldMa))/ fullStep + motorParams.currentHoldMa;
		if (ma>motorParams.currentMa)
		{
			ma=motorParams.currentMa;
		}
		//maxMa=motorParams.currentMa;

		if (systemParams.homePin>=0)
		{

			if (digitalRead(systemParams.homePin)==0)
			{
				if (lastProbeState==false)
				{
					//record our current angle for homing
					probeStartAngle=desiredLoc;
					probeCount=0;
					maxMa=0;
				}
				lastProbeState=true;
				probeCount++;
				//we will lower current after whe have moved some amount

				if (probeCount > NZS_CONTROL_LOOP_HZ && probeCount <(2* NZS_CONTROL_LOOP_HZ))
				{
					maxMa+=ma;
					if (abs(error)>maxError)
					{
						maxError=abs(error);
					}

				}
				if (probeCount>(2*NZS_CONTROL_LOOP_HZ))
				{
					//					ma=(abs(u)*(maxMa))/ fullStep;// + motorParams.homeHoldMa;
					//					if (ma>motorParams.homeMa)
					//					{
					//						ma=motorParams.homeMa;
					//					}

					//if (ma>maxMa/NZS_CONTROL_LOOP_HZ)
					{
						ma=((maxMa/NZS_CONTROL_LOOP_HZ)*9)/10;
					}

				}

			} else
			{
				lastProbeState=false;
			}
		}else
		{
			maxError=0;
			probeCount=0;
			//maxMa=0;
		}


		y=y+u;
		ptrCtrl->ma=ma;
		ptrCtrl->angle=(int32_t)y;
		moveToAngle(y,ma); //35us

		lastError=error;
		loopError=error;
		//stepperDriver.limitCurrent(99);
	}

	//filteredError=(filteredError*15+lastError)/16;

	if (probeCount>(2*NZS_CONTROL_LOOP_HZ))
	{
		if (abs(lastError) > maxError )
		{

			errorCount++;
			if (errorCount>(10))
			{
				return 1;
			}
			return 0;
		}

	}
	else
	{
		if (abs(lastError) > systemParams.errorLimit)
		{

			errorCount++;
			if (errorCount>(NZS_CONTROL_LOOP_HZ/128)) // error needs to exist for some time period
			{
				return 1;
			}
			return 0;
		}
	}

	if (errorCount>0)
	{
		errorCount--;
	}

	//errorCount=0;
	stepperDriver.limitCurrent(99); //reduce noise on low error
	return 0;

}

void StepperCtrl::torqueZeroI2C(void)
{
	if(getControlMode() == CTRL_TORQUE) // Don't do anything unless we're exiting torque mode
	{
		bool state=enterCriticalSection();
		moveToAbsAngle(getCurrentAngleNoEncoderRead()); // Stop at the previous registered currentLocation
		systemParams.controllerMode=NVM->SystemParams.controllerMode; // Read default mode from non volatile memory
		exitCriticalSection(state);
	}
}


void StepperCtrl::currentLocationIsDesiredLocation(){
	bool state=enterCriticalSection();
	moveToAbsAngle(getCurrentAngle());
	exitCriticalSection(state);
}

void StepperCtrl::enable(bool enable)
{
	bool state=TC5_ISR_Enabled;
	disableTCInterrupts();
	bool feedback=enableFeedback;

	stepperDriver.enable(enable); //enable or disable the stepper driver as needed


	if (enabled==true && enable==false)
	{
		feedback = false;
	}
	if (enabled==false && enable==true) //if we are enabling previous disabled motor
	{
		feedback = true;
		setLocationFromEncoder();
	}

	enabled=enable;
	enableFeedback=feedback;
	if (state) enableTCInterrupts();
}

/*
void StepperCtrl::testRinging(void)
{
	uint16_t c;
	int32_t steps;
	int32_t microSteps=systemParams.microsteps;
	bool feedback=enableFeedback;

	enableFeedback=false;
	systemParams.microsteps=1;
	motorReset();
	for (c=2000; c>10; c=c-10)
	{
		SerialUSB.print("Current ");
		SerialUSB.println(c);
		steps+=A4954_NUM_MICROSTEPS;
		stepperDriver.move(steps,NVM->SystemParams.currentMa);
		currentLimit=false;
		measure();
	}
	systemParams.microsteps=microSteps;
	motorReset();
	enableFeedback=feedback;
}
 */

//returns -1 if no data, else returns number of data points remaining.
int32_t StepperCtrl::getLocation(Location_t *ptrLoc)
{
	bool state=enterCriticalSection();
	int32_t n;
	//check for empty
	if (locReadIndx==locWriteIndx)
	{
		//empty data
		exitCriticalSection(state);
		return -1;
	}

	//else read data
	memcpy(ptrLoc,(void *)&locs[locReadIndx], sizeof(Location_t));

	//update the read index
	locReadIndx=(locReadIndx+1)%MAX_NUM_LOCATIONS;

	//calculate number of locations left
	n=((locWriteIndx+MAX_NUM_LOCATIONS)-locReadIndx)%MAX_NUM_LOCATIONS;


	exitCriticalSection(state);
	return n;
}

void StepperCtrl::updateLocTable(int64_t desiredLoc, int64_t currentLoc, Control_t *ptrCtrl)
{
	bool state=enterCriticalSection();
	int32_t next;

	// set the next write location
	next=(locWriteIndx+1)%MAX_NUM_LOCATIONS;

	if (next==locReadIndx)
	{
		//we are full, exit
		exitCriticalSection(state);
		//RED_LED(true); //turn Red LED on to indciate buffer full
		return;
	}

	//use ticks for the moment so we can tell if we miss data on the print.
	locs[locWriteIndx].microSecs=(int32_t)micros();
	locs[locWriteIndx].desiredLoc=(int32_t)(desiredLoc-zeroAngleOffset);
	locs[locWriteIndx].actualLoc=(int32_t)(currentLoc-zeroAngleOffset);
	locs[locWriteIndx].angle=(ptrCtrl->angle-zeroAngleOffset);
	locs[locWriteIndx].ma=ptrCtrl->ma;
	locWriteIndx=next;


	exitCriticalSection(state);
}

/* Stop shaft rotation and return to default mode,
 * which is one of CTRL_POS_PID or CTRL_SIMPLE,
 * this should be read from nonvolative memory */
void StepperCtrl::torqueSetToZeroSpecialBehaviour(void)
{
	if(getControlMode() == CTRL_TORQUE) // Don't do anything unless we're exiting torque mode
	{
		acceptPositionAndStealthSwitchMode(NVM->SystemParams.controllerMode);
	}
}

bool StepperCtrl::processFeedback(void)
{
	bool ret;
	int32_t us,j;
	Control_t ctrl;
	int64_t desiredLoc;
	int64_t currentLoc;
	int32_t steps;
	static int64_t mean=0;;

	us=micros();

#ifdef USE_TC_STEP
	static int64_t lastSteps;
	int64_t x;
	x=getSteps()-lastSteps;
	updateSteps(x);
	lastSteps+=x;
#endif

//	steps=getSteps();
//	if (steps>0)
//	{
//		requestStep(1, (uint16_t)steps);
//	}else
//	{
//		requestStep(0, (uint16_t)(-steps));
//	}

	desiredLoc=getDesiredLocation();

	currentLoc=getCurrentLocation();
	mean=(31*mean+currentLoc+16)/32;
	if (i2c_master_wants_something)
	{
		i2c_master_wants_something = false;
		if (got_G95_float)
		{
			got_G95_float = false;
			if (torque == 0)
			{
				torqueSetToZeroSpecialBehaviour();
			}
			else
			{
				stealthSwitchMode(CTRL_TORQUE);
			}
		}
		if (got_G96)
		{
			got_G96 = false;
			setZero();
		}
	}

#ifdef A5995_DRIVER //the A5995 is has more driver noise
	if (abs(currentLoc-mean)<ANGLE_FROM_DEGREES(0.9))
#else
		if (abs(currentLoc-mean)<ANGLE_FROM_DEGREES(0.3))
#endif
		{
			currentLoc=mean;
		}



	switch (systemParams.controllerMode)
	{
	#if defined(CTRL_POS_PID_AS_DEFAULT)
		default:
	#endif
	case CTRL_POS_PID:
	{
		ret=pidFeedback(desiredLoc, currentLoc,  &ctrl);
		break;
	}
	#if !defined(CTRL_POS_PID_AS_DEFAULT)
		default:
	#endif
	case CTRL_SIMPLE:
	{
		ret=simpleFeedback(desiredLoc, currentLoc,&ctrl);
		break;
	}
	case CTRL_POS_VELOCITY_PID:
	{
		ret=vpidFeedback(desiredLoc, currentLoc,&ctrl);
		break;
	}
	case CTRL_TORQUE:
	{
		ret=torqueLoop(currentLoc, &ctrl);
		break;
	}
	//TODO if disable feedback and someone switches mode
	// they will have to turn feedback back on.
	case CTRL_OFF:
	{
		enableFeedback=false;
		break;
	}
	case CTRL_OPEN:
	{
		enableFeedback=false;
		break;
	}
	}
	ticks++;
	updateLocTable(desiredLoc, currentLoc,&ctrl);
	loopTimeus=micros()-us;
	return ret;
}


//auto tuning of PID parameters based on documentation here:
// http://brettbeauregard.com/blog/2012/01/arduino-pid-autotune-library
// http://www.controleng.com/search/search-single-display/relay-method-automates-pid-loop-tuning/4a5774decc.html
void StepperCtrl::PID_Autotune(void)
{
	int32_t noiseMin, noiseMax, error;
	int32_t eMin, eMax;
	int64_t mean;
	int32_t startAngle, thres;
	int32_t i,j;
	int32_t t0,t1;
	int32_t times[100];
	int32_t angle;

	//save previous state;
	uint16_t microSteps=systemParams.microsteps;
	bool feedback=enableFeedback;
	feedbackCtrl_t prevCtrl=systemParams.controllerMode;

	//disable interrupts and feedback controller
	bool state=TC5_ISR_Enabled;
	disableTCInterrupts();
	systemParams.controllerMode=CTRL_POS_PID;
	enableFeedback=false;
	motorReset();
	//nvmWritePID(1,0,0,2);
	//set the number of microsteps to 1
	//systemParams.microsteps=1;
	for (i=0; i<10; i++)
	{
		angle=getCurrentLocation();
	}
	//	pKp=NVM->PIDparams.Kp;
	//	pKi=NVM->PIDparams.Ki;
	//	pKd=NVM->PIDparams.Kd;
	//	threshold=NVM->PIDparams.Threshold;

	//enableTCInterrupts();
	moveToAngle(angle,motorParams.currentMa);


	//moveToAngle(angle,NVM->SystemParams.currentMa);
	/*
	//next lets measure our noise on the encoder
	noiseMin=(int32_t)ANGLE_MAX;
	noiseMax=-(int32_t)ANGLE_MAX;
	mean=0;
	j=1000000UL/NZS_CONTROL_LOOP_HZ;
	prevAngle=sampleAngle();
	for (i=0; i<(NZS_CONTROL_LOOP_HZ/2); i++)
	{
		Angle a;
		a=sampleAngle();
		error=(int32_t)(prevAngle-a);

		if (error<noiseMin)
		{
			noiseMin=error;
		}

		if (error>noiseMax)
		{
			noiseMax=error;
		}
		mean=mean+(int32_t)a;
		delayMicroseconds(j);

	}
	mean=mean/i;
	while (mean>ANGLE_MAX)
	{
		mean=mean-ANGLE_STEPS;
	}
	while (mean<0)
	{
		mean=mean+ANGLE_STEPS;
	}
	//mean is the average of the encoder.
	 */



	stepperDriver.move(0,motorParams.currentMa);
	delay(1000);

	//now we need to do the relay control
	for (i=0; i<10; i++)
	{
		startAngle=getCurrentLocation();
		LOG("Start %d", (int32_t)startAngle);
	}
	thres=startAngle + (int32_t)((ANGLE_STEPS/motorParams.fullStepsPerRotation)*10/9);
	LOG("Thres %d, start %d",(int32_t)thres,(int32_t)startAngle);
	eMin=(int32_t)ANGLE_MAX;
	eMax=-(int32_t)ANGLE_MAX;
	int32_t reset=0;
	int32_t force=(motorParams.currentMa);

	for (i=0; i<100; i++)
	{
		int32_t error;
		if (reset)
		{
			motorReset();
			stepperDriver.move(0,motorParams.currentMa);
			delay(1000);
			startAngle=getCurrentLocation();
			LOG("Start %d", (int32_t)startAngle);
			force=force-100;

			eMin=(int32_t)ANGLE_MAX;
			eMax=-(int32_t)ANGLE_MAX;

			if (force<100)
			{
				i=100;
				break;
			}
			LOG("force set to %d",force);
			i=0;
		}
		reset=0;

		stepperDriver.move(A4954_NUM_MICROSTEPS,force);
		//moveToAngle(startAngle+(ANGLE_STEPS/motorParams.fullStepsPerRotation),force);
		//stepperDriver.move(A4954_NUM_MICROSTEPS,NVM->SystemParams.currentMa);
		t0=micros();

		error=0;
		while(error<=((ANGLE_STEPS/motorParams.fullStepsPerRotation)/2+40))
		{
			int32_t y;
			y=getCurrentLocation();
			error=y-startAngle;
			//LOG("Error1 %d",error);
			if (error<eMin)
			{
				eMin=error;
			}
			if (error>eMax)
			{
				eMax=error;
			}
			if (abs(error)>ANGLE_STEPS/motorParams.fullStepsPerRotation*2)
			{
				LOG("large Error1 %d, %d, %d",error, y, startAngle);

				reset=1;
				break;
			}

		}

		stepperDriver.move(0,force);

		//stepperDriver.move(0,NVM->SystemParams.currentMa);
		t1=micros();

		error=(ANGLE_STEPS/motorParams.fullStepsPerRotation);
		while(error>=((ANGLE_STEPS/motorParams.fullStepsPerRotation)/2-40))
		{
			error=getCurrentLocation()-startAngle;
			//LOG("Error2 %d",error);
			if (error<eMin)
			{
				eMin=error;
			}
			if (error>eMax)
			{
				eMax=error;
			}
			if (abs(error)>ANGLE_STEPS/motorParams.fullStepsPerRotation*2)
			{
				LOG("large Error2 %d",error);
				reset=1;
				break;
			}
		}

		times[i]=t1-t0;

	}
	for (i=0; i<100; i++)
	{
		LOG("Time %d %d",i,times[i]);
	}
	LOG("errorMin=%d",eMin);
	LOG("errorMax=%d",eMax);

	motorReset();
	systemParams.controllerMode=prevCtrl;
	systemParams.microsteps=microSteps;
	enableFeedback=feedback;
	if (state) enableTCInterrupts();

}

//void StepperCtrl::printData(void)
//{
//	bool state=TC5_ISR_Enabled;
//	disableTCInterrupts();
//	int32_t i;
//	for(i=0; i<N_DATA; i++)
//	{
//		LOG ("%d\n",data[i]);
//	}
//
//	if (state) enableTCInterrupts();
//
//}

#pragma GCC pop_options
