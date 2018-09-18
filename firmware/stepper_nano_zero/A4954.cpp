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
#include "A4954.h"
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


static inline void bridge1(int state)
{
	if (state==0)
	{
		PORT->Group[g_APinDescription[PIN_A4954_IN1].ulPort].PINCFG[g_APinDescription[PIN_A4954_IN1].ulPin].bit.PMUXEN = 0;
		GPIO_OUTPUT(PIN_A4954_IN1);//pinMode(PIN_A4954_IN1,OUTPUT);
		GPIO_OUTPUT(PIN_A4954_IN2);//pinMode(PIN_A4954_IN2,OUTPUT);
		GPIO_HIGH(PIN_A4954_IN1);// digitalWrite(PIN_A4954_IN1, HIGH);
		GPIO_LOW(PIN_A4954_IN2);//digitalWrite(PIN_A4954_IN2, LOW);
		//pinPeripheral(PIN_A4954_IN2, PIO_TIMER_ALT);
		pinState=(pinState & 0x0C) | 0x1;
	}
	if (state==1)
	{
		PORT->Group[g_APinDescription[PIN_A4954_IN2].ulPort].PINCFG[g_APinDescription[PIN_A4954_IN2].ulPin].bit.PMUXEN = 0;
		GPIO_OUTPUT(PIN_A4954_IN2);//pinMode(PIN_A4954_IN2,OUTPUT);
		GPIO_OUTPUT(PIN_A4954_IN1);pinMode(PIN_A4954_IN1,OUTPUT);
		GPIO_LOW(PIN_A4954_IN1);//digitalWrite(PIN_A4954_IN1, LOW);
		GPIO_HIGH(PIN_A4954_IN2);//digitalWrite(PIN_A4954_IN2, HIGH);
		//pinPeripheral(PIN_A4954_IN1, PIO_TIMER);
		pinState=(pinState & 0x0C) | 0x2;
	}
	if (state==3)
	{
		GPIO_LOW(PIN_A4954_IN1);
		GPIO_LOW(PIN_A4954_IN2);
		//digitalWrite(PIN_A4954_IN1, LOW);
		//digitalWrite(PIN_A4954_IN2, LOW);
	}
}

static inline void bridge2(int state)
{
	if (state==0)
	{
		PORT->Group[g_APinDescription[PIN_A4954_IN3].ulPort].PINCFG[g_APinDescription[PIN_A4954_IN3].ulPin].bit.PMUXEN = 0;
		GPIO_OUTPUT(PIN_A4954_IN3); //pinMode(PIN_A4954_IN3,OUTPUT);
		GPIO_OUTPUT(PIN_A4954_IN4);//pinMode(PIN_A4954_IN4,OUTPUT);
		GPIO_HIGH(PIN_A4954_IN3);//digitalWrite(PIN_A4954_IN3, HIGH);
		GPIO_LOW(PIN_A4954_IN4);//digitalWrite(PIN_A4954_IN4, LOW);
		//pinPeripheral(PIN_A4954_IN4, PIO_TIMER_ALT);
		pinState=(pinState & 0x03) | 0x4;
	}
	if (state==1)
	{
		PORT->Group[g_APinDescription[PIN_A4954_IN4].ulPort].PINCFG[g_APinDescription[PIN_A4954_IN4].ulPin].bit.PMUXEN = 0;
		GPIO_OUTPUT(PIN_A4954_IN4);//pinMode(PIN_A4954_IN4,OUTPUT);
		GPIO_OUTPUT(PIN_A4954_IN3);//pinMode(PIN_A4954_IN3,OUTPUT);
		GPIO_LOW(PIN_A4954_IN3);//digitalWrite(PIN_A4954_IN3, LOW);
		GPIO_HIGH(PIN_A4954_IN4);//digitalWrite(PIN_A4954_IN4, HIGH);
		//pinPeripheral(PIN_A4954_IN3, PIO_TIMER_ALT);
		pinState=(pinState & 0x03) | 0x8;
	}
	if (state==3)
	{
		GPIO_LOW(PIN_A4954_IN3);
		GPIO_LOW(PIN_A4954_IN4);
		//digitalWrite(PIN_A4954_IN3, LOW);
		//digitalWrite(PIN_A4954_IN4, LOW);
	}
}

static void enableTCC0(uint8_t percent)
{
#ifdef MECHADUINO_HARDWARE
	return;
#else
	Tcc* TCCx = TCC0 ;


	uint32_t ulValue=((uint32_t)(100-percent)*480)/100;
	//ERROR("Enable TCC0");

	GCLK->CLKCTRL.reg = (uint16_t) (GCLK_CLKCTRL_CLKEN | GCLK_CLKCTRL_GEN_GCLK0 | GCLK_CLKCTRL_ID( GCM_TCC0_TCC1 )) ;

	while ( GCLK->STATUS.bit.SYNCBUSY == 1 ) ;

	//ERROR("Setting TCC %d %d",ulValue,ulPin);
	TCCx->CTRLA.reg &= ~TCC_CTRLA_ENABLE;
	syncTCC(TCCx);

	// Set TCx as normal PWM
	TCCx->WAVE.reg |= TCC_WAVE_WAVEGEN_NPWM;
	syncTCC(TCCx);

	// Set TCx in waveform mode Normal PWM
	TCCx->CC[1].reg = (uint32_t)ulValue; //ch5 //IN3
	syncTCC(TCCx);

	TCCx->CC[2].reg = (uint32_t)ulValue; //ch6 //IN4
	syncTCC(TCCx);

	TCCx->CC[3].reg = (uint32_t)ulValue; //ch7  //IN2
	syncTCC(TCCx);

	TCCx->CC[1].reg = (uint32_t)ulValue; //ch1 == ch5 //IN1

	syncTCC(TCCx);

	// Set PER to maximum counter value (resolution : 0xFF)
	TCCx->PER.reg = DAC_MAX;
	syncTCC(TCCx);

	// Enable TCCx
	TCCx->CTRLA.reg |= TCC_CTRLA_ENABLE ;
	syncTCC(TCCx);
	//ERROR("Enable TCC0 DONE");
#endif
}

static void setDAC(uint32_t DAC1, uint32_t DAC2)
{
	TCC1->CC[1].reg = (uint32_t)DAC1; //D9 PA07 - VREF12
	syncTCC(TCC1);
	TCC1->CC[0].reg = (uint32_t)DAC2; //D4 - VREF34
	syncTCC(TCC1);


}

static void setupDAC(void)
{
	Tcc* TCCx = TCC1 ;


	pinPeripheral(PIN_A4954_VREF34, PIO_TIMER_ALT);
	pinPeripheral(PIN_A4954_VREF12, PIO_TIMER);

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


void A4954::begin()
{
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

	enabled=true;
	lastStepMicros=0;
	forwardRotation=true;

	enableTCC0(90);
	setupDAC();
//
//	int i=0;
//	bridge1(0);
//	bridge2(0);
//while (1)
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

//
//	WARNING("Setting DAC for 500mA output");
//	setDAC((int32_t)((int64_t)1000*(DAC_MAX))/3300,(int32_t)((int64_t)1000*(DAC_MAX))/3300);
//	bridge1(0);
//	bridge2(0);
//	while(1)
//	{
//
//	}
	return;
}

void A4954::limitCurrent(uint8_t percent)
{
#ifdef MECHADUINO_HARDWARE
	return;
#else
	//WARNING("current limit %d",percent);
	enableTCC0(percent);
	if (pinState & 0x01)
	{
		pinPeripheral(PIN_A4954_IN2, PIO_TIMER_ALT); //TCC0 WO[7]
	}
	if (pinState & 0x02)
	{
		pinPeripheral(PIN_A4954_IN1, PIO_TIMER); //TCC0 WO[1]
	}
	if (pinState & 0x04)
	{
		pinPeripheral(PIN_A4954_IN4, PIO_TIMER_ALT);
	}
	if (pinState & 0x08)
	{
		pinPeripheral(PIN_A4954_IN3, PIO_TIMER_ALT);
	}
#endif
}


void A4954::enable(bool enable)
{
	enabled=enable;
	if (enabled == false)
	{
		WARNING("A4954 disabled");
		setDAC(0,0); //turn current off
		bridge1(3); //tri state bridge outputs
		bridge2(3); //tri state bridge outputs
	}
}



//this is precise move and modulo of A4954_NUM_MICROSTEPS is a full step.
// stepAngle is in A4954_NUM_MICROSTEPS units..
// The A4954 has no idea where the motor is, so the calling function has to
// to tell the A4954 what phase to drive motor coils.
// A4954_NUM_MICROSTEPS is 256 by default so stepAngle of 1024 is 360 degrees
// Note you can only move up to +/-A4954_NUM_MICROSTEPS from where you
// currently are.
int32_t A4954::move(int32_t stepAngle, uint32_t mA)
{
	uint16_t angle;
	int32_t cos,sin;
	int32_t dacSin,dacCos;
	//static int i=0;

	if (enabled == false)
	{
		//WARNING("A4954 disabled");
		setDAC(0,0); //turn current off
		bridge1(3); //tri state bridge outputs
		bridge2(3); //tri state bridge outputs
		return stepAngle;
	}

	//WARNING("move %d %d",stepAngle,mA);
	//handle roll overs, could do with modulo operator
	stepAngle=stepAngle%SINE_STEPS;

	//figure out our sine Angle
	// note our SINE_STEPS is 4x of microsteps for a reason
	//angle=(stepAngle+(SINE_STEPS/8)) % SINE_STEPS;
	angle=(stepAngle);

	//calculate the sine and cosine of our angle
	sin=sine(angle);
	cos=cosine(angle);

	//if we are reverse swap the sign of one of the angels
	if (false == forwardRotation)
	{
		cos=-cos;
	}

	//scale sine result by current(mA)
	dacSin=((int32_t)mA*(int64_t)abs(sin))/SINE_MAX;

	//scale cosine result by current(mA)
	dacCos=((int32_t)mA*(int64_t)abs(cos))/SINE_MAX;

//	if (i==0)
//	{
//		WARNING("dacs are %d %d",dacSin,dacCos);
//	}

	//convert value into DAC scaled to 3300mA max
	dacCos=(int32_t)((int64_t)dacCos*(DAC_MAX))/3300;
		//convert value into DAC scaled to 3300mA max
	dacSin=(int32_t)((int64_t)dacSin*(DAC_MAX))/3300;

	//WARNING("dacs are %d %d ",dacSin,dacCos);

	setDAC(dacSin,dacCos);

	if (sin>0)
	{
		bridge1(1);
	}else
	{
		bridge1(0);
	}
	if (cos>0)
	{
		bridge2(1);
	}else
	{
		bridge2(0);
	}

//	if (i++>3000)
//	{
//		i=0;
//	}
	//	YELLOW_LED(led);
	//	led=(led+1) & 0x01;
	lastStepMicros=micros();
	return stepAngle;
}
#pragma GCC pop_options

