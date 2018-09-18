/*
 * A5995.h
 *
 *  Created on: Feb 2, 2017
 *      Author: tstern
 */

#ifndef A5995_H_
#define A5995_H_

#include <Arduino.h>
#include "board.h"
#include "angle.h"
#include "sine.h"

#define A5995_NUM_MICROSTEPS (256)


//prevent someone for making a mistake with the code
#if ((A5995_NUM_MICROSTEPS*4) != SINE_STEPS)
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

class A5995
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
	void limitCurrent(uint8_t percent) {return;};  //Not used
};



#endif /* A5995_H_ */
