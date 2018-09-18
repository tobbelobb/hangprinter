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
#ifndef __A4954__H__
#define __A4954__H__
#include <Arduino.h>
#include "board.h"
#include "angle.h"
#include "sine.h"

#define A4954_NUM_MICROSTEPS (256)
#define A4954_MIN_TIME_BETWEEN_STEPS_MICROS  (1000)

//prevent someone for making a mistake with the code
#if ((A4954_NUM_MICROSTEPS*4) != SINE_STEPS)
#error "SINE_STEPS must be 4x of Micro steps for the move function"
#endif



/*
 *  When it comes to the stepper driver if we use angles
 *  we will always have a rounding error. For example
 *  a 0-65536(360) angle for 1.8 degree step is 327.68 so
 *  if you increment 200 of these as 327 you have a 13.6 error
 *  after one rotation.
 *  If you use floating point the effect is the same but takes longer.
 *
 *  The only error-less accumulation system is to use native units, ie full
 *  steps and microsteps.
 *
 */

class A4954
{
private:
	uint32_t lastStepMicros; // time in microseconds that last step happened
	bool forwardRotation=true;
	volatile bool enabled=true;

public:
	void begin(void);

	//moves motor where the modulo of A4954_NUM_MICROSTEPS is a full step.
	int32_t move(int32_t stepAngle, uint32_t mA);

	uint32_t microsSinceStep(void) {return micros()-lastStepMicros;};
	void setRotationDirection(bool forward) {forwardRotation=forward;};

	void enable(bool enable);
	void limitCurrent(uint8_t percent); //higher more current
};



#endif //__A4954__H__
