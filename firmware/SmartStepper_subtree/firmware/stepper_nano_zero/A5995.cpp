/*
 * A5995.cpp
 *
 *  Created on: Feb 2, 2017
 *      Author: tstern
 */


#include "A5995.h"
#include "wiring_private.h"
#include "syslog.h"
#include "angle.h"
#include "Arduino.h"
#include "sine.h"

static uint8_t pinState=0;

#pragma GCC push_options
#pragma GCC optimize ("-Ofast")




#define DAC_MAX (0x01FFL)
// Wait for synchronization of registers between the clock domains
static __inline__ void syncTCC(Tcc* TCCx) __attribute__((always_inline, unused));
static void syncTCC(Tcc* TCCx) {
	//int32_t t0=1000;
	while (TCCx->SYNCBUSY.reg & TCC_SYNCBUSY_MASK)
	{
		//		t0--;
		//		if (t0==0)
		//		{
		//			break;
		//		}
		//		delay(1);
	}
}



static void setDAC(uint32_t DAC1, uint32_t DAC2)
{
	TCC1->CC[1].reg = (uint32_t)DAC1; //D9 PA07 - VREF2
	syncTCC(TCC1);
	TCC1->CC[0].reg = (uint32_t)DAC2; //D4 - VREF1
	syncTCC(TCC1);

}

static void setupDAC(void)
{
	Tcc* TCCx = TCC1 ;


	pinPeripheral(PIN_A5995_VREF1, PIO_TIMER_ALT);
	pinPeripheral(PIN_A5995_VREF2, PIO_TIMER);

	GCLK->CLKCTRL.reg = (uint16_t) (GCLK_CLKCTRL_CLKEN | GCLK_CLKCTRL_GEN_GCLK0 | GCLK_CLKCTRL_ID( GCM_TCC0_TCC1 )) ;

	while ( GCLK->STATUS.bit.SYNCBUSY == 1 ) ;

	//ERROR("Setting TCC %d %d",ulValue,ulPin);
	TCCx->CTRLA.reg &= ~TCC_CTRLA_ENABLE;
	syncTCC(TCCx);

	// Set TCx as normal PWM
	TCCx->WAVE.reg |= TCC_WAVE_WAVEGEN_NPWM;
	syncTCC(TCCx);

	// Set TCx in waveform mode Normal PWM
	TCCx->CC[1].reg = (uint32_t)0;
	syncTCC(TCCx);

	TCCx->CC[0].reg = (uint32_t)0;
	syncTCC(TCCx);

	// Set PER to maximum counter value (resolution : 0xFFF = 12 bits)
	// =48e6/2^12=11kHz frequency
	TCCx->PER.reg = DAC_MAX;
	syncTCC(TCCx);

	// Enable TCCx
	TCCx->CTRLA.reg |= TCC_CTRLA_ENABLE ;
	syncTCC(TCCx);

}


void A5995::begin()
{
	//setup the A5995 pins
	digitalWrite(PIN_A5995_ENABLE1,LOW);
	pinMode(PIN_A5995_ENABLE1,OUTPUT);
	digitalWrite(PIN_A5995_ENABLE2,LOW);
	pinMode(PIN_A5995_ENABLE2,OUTPUT);
	digitalWrite(PIN_A5995_MODE1,LOW);
	pinMode(PIN_A5995_MODE1,OUTPUT);
	digitalWrite(PIN_A5995_MODE2,LOW);
	pinMode(PIN_A5995_MODE2,OUTPUT);
	digitalWrite(PIN_A5995_PHASE1,LOW);
	pinMode(PIN_A5995_PHASE1,OUTPUT);
	digitalWrite(PIN_A5995_PHASE2,LOW);
	pinMode(PIN_A5995_PHASE2,OUTPUT);

	digitalWrite(PIN_A5995_SLEEPn,HIGH);
	pinMode(PIN_A5995_SLEEPn,OUTPUT);



	//setup the PWM for current on the A4954, set for low current
	digitalWrite(PIN_A5995_VREF1,LOW);
	digitalWrite(PIN_A5995_VREF2,LOW);
	pinMode(PIN_A5995_VREF1, OUTPUT);
	pinMode(PIN_A5995_VREF2, OUTPUT);

	enabled=true;
	lastStepMicros=0;
	forwardRotation=true;

	setupDAC();


//
//	GPIO_HIGH(PIN_A5995_ENABLE1);
//		GPIO_HIGH(PIN_A5995_ENABLE2);
//		GPIO_LOW(PIN_A5995_MODE1);
//		GPIO_LOW(PIN_A5995_MODE2);
//		GPIO_HIGH(PIN_A5995_PHASE1);
//		GPIO_HIGH(PIN_A5995_PHASE2);
//	int i=0;;
//	while (1)
//	{
//		int32_t x;
//		WARNING("MA %d",i);
//		x=(int32_t)((int64_t)i*(DAC_MAX))/3300;
//		setDAC(x,x);
//		delay(1000);
//		i=i+10;
//		if (i>1000)
//		{
//			i=0;
//		}
//
//	}


	return;
}



void A5995::enable(bool enable)
{
	enabled=enable;
	if (enabled == false)
	{
		WARNING("A4954 disabled");
		setDAC(0,0); //turn current off
		GPIO_LOW(PIN_A5995_ENABLE1);
		GPIO_LOW(PIN_A5995_ENABLE2);
		GPIO_LOW(PIN_A5995_MODE1);
		GPIO_LOW(PIN_A5995_MODE2);
		GPIO_LOW(PIN_A5995_PHASE1);
		GPIO_LOW(PIN_A5995_PHASE2);
	}
}



//this is precise move and modulo of A4954_NUM_MICROSTEPS is a full step.
// stepAngle is in A4954_NUM_MICROSTEPS units..
// The A4954 has no idea where the motor is, so the calling function has to
// to tell the A4954 what phase to drive motor coils.
// A4954_NUM_MICROSTEPS is 256 by default so stepAngle of 1024 is 360 degrees
// Note you can only move up to +/-A4954_NUM_MICROSTEPS from where you
// currently are.
int32_t A5995::move(int32_t stepAngle, uint32_t mA)
{
	uint16_t angle;
	int32_t cos,sin;
	int32_t dacSin,dacCos;
	static int32_t lastSin=0,lastCos=0;
	static int i=1;

	if (enabled == false)
	{
		WARNING("A4954 disabled");
		setDAC(0,0); //turn current off
		GPIO_LOW(PIN_A5995_ENABLE1);
		GPIO_LOW(PIN_A5995_ENABLE2);
		GPIO_LOW(PIN_A5995_MODE1);
		GPIO_LOW(PIN_A5995_MODE2);
		GPIO_LOW(PIN_A5995_PHASE1);
		GPIO_LOW(PIN_A5995_PHASE2);
		return stepAngle;
	}

	//WARNING("move %d %d",stepAngle,mA);

	stepAngle=(stepAngle) % SINE_STEPS;
	//figure out our sine Angle
	// note our SINE_STEPS is 4x of microsteps for a reason
	//angle=(stepAngle+(SINE_STEPS/8)) % SINE_STEPS;
	angle=stepAngle;

	if (i==0)
	{
		WARNING("angle  %d ",angle);
	}
	//calculate the sine and cosine of our angle
	sin=sine(angle);
	cos=cosine(angle);

	//if we are reverse swap the sign of one of the angels
	if (false == forwardRotation)
	{
		cos=-cos;
	}

	//scale sine result by current(mA)
	dacSin=((int32_t)mA*(int64_t)(sin))/SINE_MAX;

	if (i==0)
	{
	   WARNING("dacsine  %d ",dacSin);
	}
//	if ((lastSin-dacSin)>100) //decreasing current
//	{
//		GPIO_LOW(PIN_A5995_MODE2); //fast decay
//	} else
//	{
//		GPIO_HIGH(PIN_A5995_MODE2); //slow decay
//	}
	lastSin=dacSin;

	//convert value into DAC scaled to 3300mA max
	dacSin=(int32_t)((int64_t)abs(dacSin)*(DAC_MAX))/3300;


	//scale cosine result by current(mA)
	dacCos=((int32_t)mA*(int64_t)(cos))/SINE_MAX;

   if (i==0)
	{
   WARNING("daccos  %d ",dacCos);
	}
//	if ((lastCos-dacCos)>100) //decreasing current
//	{
//		GPIO_LOW(PIN_A5995_MODE1); //fast decay
//	} else
//	{
//		GPIO_HIGH(PIN_A5995_MODE1); //slow decay
//	}
	lastCos=dacCos;

	//convert value into DAC scaled to 3300mA max
	dacCos=(int32_t)((int64_t)abs(dacCos)*(DAC_MAX))/3300;


if (i==0)
{
	WARNING("dacs are %d %d",dacSin,dacCos);
}
	setDAC(dacSin,dacCos);

	GPIO_HIGH(PIN_A5995_ENABLE1);
	GPIO_HIGH(PIN_A5995_ENABLE2);
	GPIO_LOW(PIN_A5995_MODE1);
	GPIO_LOW(PIN_A5995_MODE2);


if (i==0)
{
	WARNING("sins are %d %d",sin,cos);
}

	if (sin>0)
	{
		GPIO_HIGH(PIN_A5995_PHASE2);
	}else
	{
		GPIO_LOW(PIN_A5995_PHASE2);

	}
	if (cos>0)
	{
		GPIO_HIGH(PIN_A5995_PHASE1);

	}else
	{
		GPIO_LOW(PIN_A5995_PHASE1);

	}

//	i++;
//	if (i>3000) i=0;
	//	YELLOW_LED(led);
	//	led=(led+1) & 0x01;
	lastStepMicros=micros();
	return stepAngle;
}
#pragma GCC pop_options



