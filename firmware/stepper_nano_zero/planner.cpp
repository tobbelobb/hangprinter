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
#include "planner.h"

#include "board.h"
#include "wiring_private.h"
#include "syslog.h"
#include "angle.h"
#include "Arduino.h"

#define WAIT_TC16_REGS_SYNC(x) while(x->COUNT16.STATUS.bit.SYNCBUSY);

//define the planner class as being global
Planner SmartPlanner;

static bool enterTC3CriticalSection()
{
	bool state=NVIC_IS_IRQ_ENABLED(TC3_IRQn);
	NVIC_DisableIRQ(TC3_IRQn);
	return state;
}

static void exitTC3CriticalSection(bool prevState)
{
	if (prevState)
	{
		NVIC_EnableIRQ(TC3_IRQn);
	} //else do nothing
}




void TC3_Init(void)
{
	// Enable GCLK for TC3
	GCLK->CLKCTRL.reg = (uint16_t) (GCLK_CLKCTRL_CLKEN | GCLK_CLKCTRL_GEN_GCLK0 | GCLK_CLKCTRL_ID( GCM_TCC2_TC3 )) ;
	while (GCLK->STATUS.bit.SYNCBUSY);

	TC3->COUNT16.CTRLA.reg &= ~TC_CTRLA_ENABLE;   // Disable TCx
	WAIT_TC16_REGS_SYNC(TC3)                      // wait for sync

	TC3->COUNT16.CTRLA.reg |= TC_CTRLA_MODE_COUNT16;   // Set Timer counter Mode to 16 bits
	WAIT_TC16_REGS_SYNC(TC3)

	TC3->COUNT16.CTRLA.reg |= TC_CTRLA_WAVEGEN_MFRQ; // Set TC as normal Normal Frq
	WAIT_TC16_REGS_SYNC(TC3)

	TC3->COUNT16.CTRLA.reg |= TC_CTRLA_PRESCALER_DIV2;   // Set perscaler
	WAIT_TC16_REGS_SYNC(TC3)


	TC3->COUNT16.CC[0].reg = F_CPU/PLANNER_UPDATE_RATE_HZ/2; //divide by two because of prescaler

	WAIT_TC16_REGS_SYNC(TC3)


	TC3->COUNT16.INTENSET.reg = 0;              // disable all interrupts
	TC3->COUNT16.INTENSET.bit.OVF = 1;          // enable overfollow



	NVIC_SetPriority(TC3_IRQn, 3);


	// Enable InterruptVector
	NVIC_EnableIRQ(TC3_IRQn);


	// Enable TC
	TC3->COUNT16.CTRLA.reg |= TC_CTRLA_ENABLE;
	WAIT_TC16_REGS_SYNC(TC3);
}


void TC3_Handler(void)
{
	interrupts(); //allow other interrupts
	//do the planner tick
	SmartPlanner.tick();
	//SerialUSB.println('x');
	TC3->COUNT16.INTFLAG.bit.OVF = 1; //clear interrupt by writing 1 to flag
}

void Planner::begin(StepperCtrl *ptrStepper)
{

	ptrStepperCtrl=ptrStepper;
	currentMode=PLANNER_NONE;
	//setup the timer and interrupt as the last thing
	TC3_Init();
}

void Planner::tick(void)
{
	if (currentMode == PLANNER_NONE)
	{
		return; //do nothing
	}

	if (PLANNER_CV == currentMode)
	{
//		SerialUSB.println(currentSetAngle);
//		SerialUSB.println(endAngle);
//		SerialUSB.println(tickIncrement);
//		SerialUSB.println(fabs(currentSetAngle-endAngle));
//		SerialUSB.println(fabs(tickIncrement*2));
//		SerialUSB.println();
		int32_t x;
		if (fabs(currentSetAngle-endAngle) >= fabs(tickIncrement))
		{
			currentSetAngle+=tickIncrement;
			x=ANGLE_FROM_DEGREES(currentSetAngle);
			ptrStepperCtrl->moveToAbsAngle(x);
		}else
		{
			//we are done, make sure we end at the right point
			//SerialUSB.println("done");
			x=ANGLE_FROM_DEGREES(endAngle);
			ptrStepperCtrl->moveToAbsAngle(x);
			currentMode=PLANNER_NONE;
		}
	}


}

void Planner::stop(void)
{
	bool state;
	state = enterTC3CriticalSection();
	currentMode=PLANNER_NONE;
	exitTC3CriticalSection(state);
}

bool Planner::moveConstantVelocity(float finalAngle, float rpm)
{
	bool state;
	state = enterTC3CriticalSection();

	//first determine if operation is in progress
	if (PLANNER_NONE != currentMode)
	{
		//we are in operation return false
		SerialUSB.println("planner operational");
		exitTC3CriticalSection(state);
		return false;
	}

	//get current posistion
	startAngle = ANGLE_T0_DEGREES(ptrStepperCtrl->getCurrentAngle());

	//deterime the tick increment
	tickIncrement=360.0*fabs(rpm)/60/PLANNER_UPDATE_RATE_HZ;



	//set the desired end angle
	endAngle=finalAngle;


	//set the current angle
	currentSetAngle=startAngle;

	if (startAngle>endAngle)
	{
		SerialUSB.println("reverse");
		tickIncrement=-tickIncrement;
	}

//	SerialUSB.println(currentSetAngle);
//		SerialUSB.println(endAngle);
//		SerialUSB.println(tickIncrement);
//		SerialUSB.println();

	currentMode=PLANNER_CV;

	exitTC3CriticalSection(state);
	return true;
}
