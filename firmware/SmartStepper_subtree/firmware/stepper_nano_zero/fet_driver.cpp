/*
 * fet_driver.cpp
 *
 *  Created on: Dec 24, 2016
 *      Author: tstern
 *
 * This file supports using discrete FETs as drivers for stepper motor
 *
 *	Misfit Tech invests time and resources providing this open source code,
 *	please support Misfit Tech and open-source hardware by purchasing
 *	products from Misfit Tech, www.misifittech.net!
 *
 *	Written by Trampas Stern  for Misfit Tech.
 *	BSD license, check license.txt for more information
 *	All text above, must be included in any redistribution
 *********************************************************************/
#include "fet_driver.h"
#include "wiring_private.h"
#include "syslog.h"
#include "angle.h"
#include "Arduino.h"
#include "sine.h"
#include "nonvolatile.h"

#pragma GCC push_options
#pragma GCC optimize ("-Ofast")

#ifdef NEMA_23_10A_HW

#define FET_DRIVER_FREQ  (46875UL) //FET PWM pin driver frequency

FetDriver *FetDriver::ptrInstance=0;

// Wait for synchronization of registers between the clock domains
static __inline__ void syncDAC() __attribute__((always_inline, unused));
static void syncDAC() {
	while (DAC->STATUS.bit.SYNCBUSY == 1)
		;
}


volatile uint32_t coilA_Value=0;
/*
 *  The discrete FETs on the NEMA 23 10A board are configured such that each H-bridge has:
 *    IN1 - Input 1
 *    IN2 - Input 2
 *    Enable - Enable driver
 *    Isense - current sense
 *
 *    The truth table for the H-Bridge is:
 *    Enable	IN1		IN2		Bridge State
 *    0			x		x		floating (FETs off)
 *    1			0		0		coil shorted to Gnd
 *    1			0		1		forward
 *    1			1		0		reverse
 *    1			1		1		coil shorted to VCC
 *
 *    For peak current control there is two state (fast decay, and slow decay)
 *
 *    Fast Decay
 *    When driving coil in forward direction and current peak is reached the fast decay turns
 *    The bridge in the reverse direction. This cause the reverse EMF from coil to charge
 *    capacitors back up and the current on the coil to drop very quickly
 *
 *    Slow Decay
 *    During this mode the current decay is slower by shorting the coil leads to ground.
 *    This in effect shorts the coil leads and reverse EMF is converted to heat.
 *
 *    In the Fast Decay mode we reverse the motor, this in effect is trying to drive coil
 *    current in the reverse direction. This in effect reduces current faster than just
 *    shorting the coil out.
 *
 *    see www.misfittech.net's blog for more information on this subject
 *
 */

/* driver code's logic
 *
 * 	This driver code needs not only to control the FETs but also handle the current limits.
 *
 * 	The way the code handles limiting current is by using two comparators internal to
 * 	the microprocessor.
 *
 * 	We first use two PWM signals to generate reference voltage for each comparator.
 * 	Then when the current sense voltage exceeds this reference voltage an interrupt is
 * 	generated. In the interrupt handler we will then set the decay mode as needed.
 *
 * 	It will have to be determined if we will use a fixed time decay mode like the A4954,
 * 	or use current as the threshold. There is a lot to do here to maintain quite operation,
 * 	that is we need this current control to be running at more than 20khz to be quite.
 *
 * 	Additionally we can use ADC on the current sense for detecting the flyback and
 * 	get some idea of the inductance. This can be used for stall dection as well as
 * 	auto tuning of some of the driver parameters.
 */



#pragma GCC push_options
#pragma GCC optimize ("-Ofast")

#define WAIT_TC16_REGS_SYNC(x) while(x->COUNT16.STATUS.bit.SYNCBUSY);

typedef enum {
	CURRENT_ON = 0,
	CURRENT_FAST_DECAY = 1,
	CURRENT_SLOW_DECAY = 2,
} CurrentMode_t;

typedef enum {
	COIL_FORWARD =0,
	COIL_REVERSE =1,
	COIL_BRAKE =2
} CoilState_t;

typedef struct {
	bool currentIncreasing; //true when we are increasing current
	CurrentMode_t currentState; //how is bridge driven
} BridgeState_t;

volatile BridgeState_t BridgeA, BridgeB;


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

	}
}





static inline void coilA(CoilState_t state)
{
	PIN_GPIO_OUTPUT(PIN_FET_IN1);
	PIN_GPIO_OUTPUT(PIN_FET_IN2);
	switch(state){

		case COIL_FORWARD:
			GPIO_HIGH(PIN_FET_IN1);
			GPIO_LOW(PIN_FET_IN2);
			break;

		case COIL_REVERSE:
			GPIO_HIGH(PIN_FET_IN2);
			GPIO_LOW(PIN_FET_IN1);
			break;

		case COIL_BRAKE:
			GPIO_LOW(PIN_FET_IN2);
			GPIO_LOW(PIN_FET_IN1);
			break;

		default:
			ERROR("Not a known state");
			break;
	}

}

static inline void coilB(CoilState_t state)
{
	PIN_GPIO_OUTPUT(PIN_FET_IN3);
	PIN_GPIO_OUTPUT(PIN_FET_IN4);
	switch(state){
		case COIL_FORWARD:
			GPIO_HIGH(PIN_FET_IN3);
			GPIO_LOW(PIN_FET_IN4);
			break;

		case COIL_REVERSE:
			GPIO_HIGH(PIN_FET_IN4);
			GPIO_LOW(PIN_FET_IN3);
			break;

		case COIL_BRAKE:
			GPIO_LOW(PIN_FET_IN3);
			GPIO_LOW(PIN_FET_IN4);
			break;

		default:
			ERROR("Not a known state");
			break;
	}
}


int FetDriver::coilA_PWM(int32_t value)
{
	int32_t x;
	// PIN_FET_IN1	 (PA15)		(5)  (TCC0 WO[5], aka ch1)
	//PIN_FET_IN2    (PA20)		(6)  (TCC0 WO[6], aka ch2)
	Tcc* TCCx = TCC0 ;

//
//	if (value==0)
//	{
//		GPIO_LOW(PIN_FET_IN1);
//		GPIO_LOW(PIN_FET_IN2);
//		PIN_GPIO(PIN_FET_IN1);
//		PIN_GPIO(PIN_FET_IN2);
//		return;
//	}

	if (value<0)
	{
		GPIO_LOW(PIN_FET_IN1);
		PIN_GPIO(PIN_FET_IN1);
		PIN_PERIPH(PIN_FET_IN2);
		//pinPeripheral(PIN_FET_IN2, PIO_TIMER_ALT); //TCC0 WO[7]
		value=-value;
	}else
	{
		GPIO_LOW(PIN_FET_IN2);
		PIN_GPIO(PIN_FET_IN2);
		PIN_PERIPH(PIN_FET_IN1);
		//pinPeripheral(PIN_FET_IN1, PIO_TIMER_ALT);
	}


#if (F_CPU/FET_DRIVER_FREQ)==1024
	x=value & 0x3FF;
#else
	x=MIN(value, (int32_t)(F_CPU/FET_DRIVER_FREQ));
#endif

	syncTCC(TCCx);
	TCCx->CC[1].reg = (uint32_t)x; //ch1 == ch5 //IN3
	//syncTCC(TCCx);
	TCCx->CC[2].reg = (uint32_t)x; //ch2 == ch6 //IN4
	if (x!=value)
	{
		return 1;
	}
	return 0;

}

void FetDriver::coilB_PWM(int32_t value)
{

	//PIN_FET_IN3	 (PA21)		(7)	 (TCC0 WO[7], aka ch3)
	//PIN_FET_IN4    (PA14)		(2)  (TCC0 WO[4], aka ch0)
	Tcc* TCCx = TCC0 ;


//
//	if (value==0)
//	{
//		GPIO_LOW(PIN_FET_IN3);
//		GPIO_LOW(PIN_FET_IN4);
//		PIN_GPIO(PIN_FET_IN3);
//		PIN_GPIO(PIN_FET_IN4);
//		return;
//	}


	if (value<=0)
	{
		GPIO_LOW(PIN_FET_IN3);
		PIN_GPIO(PIN_FET_IN3);
		PIN_PERIPH(PIN_FET_IN4);
		//SET_PIN_PERHERIAL(PIN_FET_IN4, PIO_TIMER_ALT); //TCC0 WO[7]
		value=-value;
	}else
	{
		GPIO_LOW(PIN_FET_IN4);
		PIN_GPIO(PIN_FET_IN4);
		PIN_PERIPH(PIN_FET_IN3);
		//SET_PIN_PERHERIAL(PIN_FET_IN3, PIO_TIMER_ALT);
	}


#if (F_CPU/FET_DRIVER_FREQ)==1024
	value=value & 0x3FF;
#else
	value=MIN(value, (int32_t)(F_CPU/FET_DRIVER_FREQ));
#endif

	//LOG("value is %d",value);
	//	if (value> 300) //(F_CPU/FET_DRIVER_FREQ))
	//	{
	//		value= 300; //F_CPU/FET_DRIVER_FREQ;
	//	}
	syncTCC(TCCx);
	TCCx->CC[0].reg = (uint32_t)value; //ch0 == ch4 //IN4
	//syncTCC(TCCx);
	TCCx->CC[3].reg = (uint32_t)value; //ch3 == ch7  //IN3


}

static void enableTCC0(void)
{
	Tcc* TCCx = TCC0 ;

	GCLK->CLKCTRL.reg = (uint16_t) (GCLK_CLKCTRL_CLKEN | GCLK_CLKCTRL_GEN_GCLK0 | GCLK_CLKCTRL_ID( GCM_TCC0_TCC1 )) ;

	while ( GCLK->STATUS.bit.SYNCBUSY == 1 ) ;

	//ERROR("Setting TCC %d %d",ulValue,ulPin);
	TCCx->CTRLA.reg &= ~TCC_CTRLA_ENABLE;
	syncTCC(TCCx);

	// Set TCx as normal PWM
	TCCx->WAVE.reg |= TCC_WAVE_WAVEGEN_NPWM;
	syncTCC(TCCx);

	// Set PER to maximum counter value (resolution : 0xFF)
	TCCx->PER.reg = F_CPU/FET_DRIVER_FREQ; //set frequency to 100Khz
	syncTCC(TCCx);

	// Enable TCCx
	TCCx->CTRLA.reg |= TCC_CTRLA_ENABLE ;
	syncTCC(TCCx);
	//ERROR("Enable TCC0 DONE");

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


	pinPeripheral(PIN_FET_VREF1, PIO_TIMER_ALT);
	pinPeripheral(PIN_FET_VREF2, PIO_TIMER_ALT);

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


/*
 * The SAMD21 has two analog comparators
 *  COMP_FET_A(A4/PA05) and COMP_FET_B(D9/PA07) are the reference voltages
 *
 *  ISENSE_FET_A(A3/PA04) and ISENSE_FET_B(D8/PA06) are the current sense
 *
 */
/*
static void setupComparators(void)
{
	//setup the pins as analog inputs
	pinPeripheral(COMP_FET_A, PIO_ANALOG); //AIN[1]
	pinPeripheral(COMP_FET_B, PIO_ANALOG); 	//AIN[3]
	pinPeripheral(ISENSE_FET_A, PIO_ANALOG);  //AIN[0]
	pinPeripheral(ISENSE_FET_B, PIO_ANALOG);  //AIN[2]

	//enable the clock for the Analog comparator
	PM->APBCMASK.reg |= PM_APBCMASK_AC; //enable clock in the power manager

	//setup the GCLK for the analog and digital clock to the AC
	GCLK->CLKCTRL.reg = (uint16_t) (GCLK_CLKCTRL_CLKEN | GCLK_CLKCTRL_GEN_GCLK0 | GCLK_CLKCTRL_ID( GCM_AC_ANA )) ;
	 while ( GCLK->STATUS.bit.SYNCBUSY == 1 ) ;
	GCLK->CLKCTRL.reg = (uint16_t) (GCLK_CLKCTRL_CLKEN | GCLK_CLKCTRL_GEN_GCLK0 | GCLK_CLKCTRL_ID( GCM_AC_DIG )) ;
	 while ( GCLK->STATUS.bit.SYNCBUSY == 1 ) ;


	//we will drive the CMP0 and CMP1 high when our current is exceeded.
	// To do this we will set ISense Pins as the non-inverting input
	AC->CTRLA.reg=0x01; //disable AC_COMPCTRL_ENABLE and reset
	while ( AC->STATUSB.bit.SYNCBUSY == 1 ) ;
	AC->CTRLB.reg=0x0; // set start bits low (will not be used)
	while ( AC->STATUSB.bit.SYNCBUSY == 1 ) ;
	AC->COMPCTRL[0].reg = 	AC_COMPCTRL_FLEN_MAJ3_Val | //add a 3 bit majority digital filter
							AC_COMPCTRL_HYST | //enable hysterisis
							AC_COMPCTRL_MUXPOS_PIN0 | //non-inverting is AIN[0]
							AC_COMPCTRL_MUXNEG_PIN1 | //inverting pin is AIN[1]
							AC_COMPCTRL_INTSEL_RISING | //interrupt on the rising edge (TODO we might want on both edges)
							AC_COMPCTRL_SPEED_HIGH |
							AC_COMPCTRL_ENABLE;  //set to high speed mode, we don't care about power consumption
	while ( AC->STATUSB.bit.SYNCBUSY == 1 ) ;
	AC->COMPCTRL[1].reg = 	//AC_COMPCTRL_FLEN_MAJ3_Val | //add a 3 bit majority digital filter
							//AC_COMPCTRL_HYST | //enable hysterisis
							AC_COMPCTRL_MUXPOS_PIN2 | //non-inverting is AIN[2]
							AC_COMPCTRL_MUXNEG_PIN3 | //inverting pin is AIN[3]
							AC_COMPCTRL_INTSEL_RISING | //interrupt on the rising edge (TODO we might want on both edges)
							AC_COMPCTRL_SPEED_HIGH |
							//AC_COMPCTRL_SWAP |
							AC_COMPCTRL_ENABLE;  //set to high speed mode, we don't care about power consumption
	while ( AC->STATUSB.bit.SYNCBUSY == 1 ) ;

	//enable the comparator
	AC->CTRLA.reg=AC_CTRLA_ENABLE;
	while ( AC->STATUSB.bit.SYNCBUSY == 1 );



	AC->INTENSET.bit.COMP0=1;
	AC->INTENSET.bit.COMP1=1;
	NVIC_EnableIRQ(AC_IRQn); //enable the comparator interrupt
}
 */

static __inline__ void syncADC() __attribute__((always_inline, unused));
static void syncADC() {
	volatile int32_t t0=100;
	while ((ADC->STATUS.bit.SYNCBUSY == 1))// && t0>0)
	{
		t0--;
		if (t0>0)
		{
			break;
		}
	}
	if (t0<=0)
	{
		ERROR("sync ADC timeout");
	}
}




static uint32_t ADCRead(uint32_t ulPin)
{
	uint32_t valueRead = 0;
	uint32_t gainValue=0;

	if ( ulPin <= 5 ) // turn '0' -> 'A0'
	{
		ulPin += A0 ;
	}
	if (ulPin == 6) ulPin = PIN_A6;
	if (ulPin == 7) ulPin = PIN_A7;

	pinPeripheral(PIN_A4, PIO_ANALOG);

	pinPeripheral(ulPin, PIO_ANALOG);

	syncADC();
	ADC->CTRLB.reg = ADC_CTRLB_PRESCALER_DIV32 |    // Divide Clock by 512.
			ADC_CTRLB_RESSEL_12BIT;         // 10 bits resolution as default
	//  syncADC();
	// ADC->INPUTCTRL.reg = 0;

	//  syncADC();
	//  ADC->INPUTCTRL.bit.MUXNEG=  ADC_INPUTCTRL_MUXNEG_GND;//g_APinDescription[ulPin].ulADCChannelNumber; //ADC_INPUTCTRL_MUXNEG_GND;
	//ADC_INPUTCTRL_MUXNEG_IOGND; //ADC_INPUTCTRL_MUXNEG_PIN5;   // No Negative input (Internal Ground)


	syncADC();
	ADC->INPUTCTRL.bit.MUXPOS =  g_APinDescription[ulPin].ulADCChannelNumber;//ADC_INPUTCTRL_MUXPOS_DAC;// g_APinDescription[ulPin].ulADCChannelNumber; // Selection for the positive ADC input


	syncADC();
	ADC->INPUTCTRL.bit.GAIN = 0xF; //0x0F == gain of 1/2

	syncADC();
	ADC->REFCTRL.reg=ADC_REFCTRL_REFSEL_INTVCC1; //set the ADC reference to 1/2VDDANA

	syncADC();
	ADC->SAMPCTRL.reg=0x02;
	/*
	 * Bit 1 ENABLE: Enable
	 *   0: The ADC is disabled.
	 *   1: The ADC is enabled.
	 * Due to synchronization, there is a delay from writing CTRLA.ENABLE until the peripheral is enabled/disabled. The
	 * value written to CTRL.ENABLE will read back immediately and the Synchronization Busy bit in the Status register
	 * (STATUS.SYNCBUSY) will be set. STATUS.SYNCBUSY will be cleared when the operation is complete.
	 *
	 * Before enabling the ADC, the asynchronous clock source must be selected and enabled, and the ADC reference must be
	 * configured. The first conversion after the reference is changed must not be used.
	 */

	syncADC();
	ADC->CTRLA.bit.ENABLE = 0x01;             // Enable ADC


	// Clear the Data Ready flag
	syncADC();
	ADC->INTFLAG.bit.RESRDY = 1;
	// Start conversion
	syncADC();
	ADC->SWTRIG.bit.START = 1;


	// wait for conversion to be done
	while ( ADC->INTFLAG.bit.RESRDY == 0 );   // Waiting for conversion to complete

	// Clear the Data Ready flag
	syncADC();
	ADC->INTFLAG.bit.RESRDY = 1;
	// Start conversion again, since The first conversion after the reference is changed must not be used.
	syncADC();
	ADC->SWTRIG.bit.START = 1;

	while ( ADC->INTFLAG.bit.RESRDY == 0 );   // Waiting for conversion to complete
	valueRead = ADC->RESULT.reg;

	//	syncADC();
	//	ADC->CTRLA.bit.ENABLE = 0x00;             // Disable ADC
	//	syncADC();

	return valueRead; //mapResolution(valueRead, _ADCResolution, _readResolution);

}

int32_t fastADCRead(uint32_t ulPin)
{
	int32_t valueRead;
	if ( ulPin <= 5 ) // turn '0' -> 'A0'
	{
		ulPin += A0 ;
	}
	if (ulPin == 6) ulPin = PIN_A6;
	if (ulPin == 7) ulPin = PIN_A7;
	syncADC();
	ADC->INPUTCTRL.bit.MUXPOS =  g_APinDescription[ulPin].ulADCChannelNumber;//ADC_INPUTCTRL_MUXPOS_DAC;// g_APinDescription[ulPin].ulADCChannelNumber; // Selection for the positive ADC input
	// Clear the Data Ready flag
	syncADC();
	ADC->INTFLAG.bit.RESRDY = 1;
	// Start conversion again, since The first conversion after the reference is changed must not be used.
	syncADC();
	ADC->SWTRIG.bit.START = 1;

	while ( ADC->INTFLAG.bit.RESRDY == 0 );   // Waiting for conversion to complete
	valueRead = ADC->RESULT.reg;
	return valueRead;
}

int32_t GetMeanAdc(uint16_t pin, uint16_t samples)
{
	int32_t i=0;
	int32_t mean=0;
	int32_t adc;
	while (i<samples)
	{
		adc=ADCRead(pin);
		mean+=adc;
		i++;
	}
	return mean/i;
}

static uint32_t ADCStart(uint32_t ulPin)
{
	uint32_t valueRead = 0;
	uint32_t gainValue=0;

	if ( ulPin <= 5 ) // turn '0' -> 'A0'
	{
		ulPin += A0 ;
	}
	if (ulPin == 6) ulPin = PIN_A6;
	if (ulPin == 7) ulPin = PIN_A7;

	pinPeripheral(PIN_A4, PIO_ANALOG);

	pinPeripheral(ulPin, PIO_ANALOG);

	syncADC();
	ADC->CTRLB.reg = ADC_CTRLB_PRESCALER_DIV64 |    // Divide Clock by 512.
			ADC_CTRLB_RESSEL_12BIT;         // 10 bits resolution as default
	//  syncADC();
	// ADC->INPUTCTRL.reg = 0;

	//  syncADC();
	//  ADC->INPUTCTRL.bit.MUXNEG=  ADC_INPUTCTRL_MUXNEG_GND;//g_APinDescription[ulPin].ulADCChannelNumber; //ADC_INPUTCTRL_MUXNEG_GND;
	//ADC_INPUTCTRL_MUXNEG_IOGND; //ADC_INPUTCTRL_MUXNEG_PIN5;   // No Negative input (Internal Ground)

	syncADC();
	ADC->INPUTCTRL.bit.MUXPOS =  g_APinDescription[ulPin].ulADCChannelNumber;//ADC_INPUTCTRL_MUXPOS_DAC;// g_APinDescription[ulPin].ulADCChannelNumber; // Selection for the positive ADC input

	syncADC();
	ADC->INPUTCTRL.bit.INPUTSCAN=0;
	//
	//	switch (gain)
	//	{
	//		case 1:
	//			gainValue=ADC_INPUTCTRL_GAIN_1X_Val;
	//			break;
	//		case 2:
	//			gainValue=ADC_INPUTCTRL_GAIN_2X_Val;
	//			break;
	//		case 4:
	//			gainValue=ADC_INPUTCTRL_GAIN_4X_Val;
	//			break;
	//		case 8:
	//			gainValue=ADC_INPUTCTRL_GAIN_8X_Val;
	//			break;
	//		case 16:
	//			gainValue=ADC_INPUTCTRL_GAIN_16X_Val;
	//			break;
	//		default:
	//			gainValue=ADC_INPUTCTRL_GAIN_1X_Val;
	//			break;
	//	}

	//  syncADC();
	// ADC->CTRLB.bit.DIFFMODE = 0; //set to differential mode

	syncADC();
	ADC->INPUTCTRL.bit.GAIN = 0xF; //0x0F == gain of 1/2

	// syncADC();
	// ADC->AVGCTRL.reg=5;

	syncADC();
	ADC->REFCTRL.reg=ADC_REFCTRL_REFSEL_INTVCC1; //set the ADC reference to 1/2VDDANA

	syncADC();
	ADC->SAMPCTRL.reg=0x0F;
	/*
	 * Bit 1 ENABLE: Enable
	 *   0: The ADC is disabled.
	 *   1: The ADC is enabled.
	 * Due to synchronization, there is a delay from writing CTRLA.ENABLE until the peripheral is enabled/disabled. The
	 * value written to CTRL.ENABLE will read back immediately and the Synchronization Busy bit in the Status register
	 * (STATUS.SYNCBUSY) will be set. STATUS.SYNCBUSY will be cleared when the operation is complete.
	 *
	 * Before enabling the ADC, the asynchronous clock source must be selected and enabled, and the ADC reference must be
	 * configured. The first conversion after the reference is changed must not be used.
	 */
	syncADC();
	ADC->CTRLA.bit.ENABLE = 0x01;             // Enable ADC


	//Setup up for ISR
	ADC->INTENCLR.reg=0x0F;
	ADC->INTENSET.bit.RESRDY=1;

	NVIC_SetPriority(ADC_IRQn, 3);


	// Clear the Data Ready flag
	ADC->INTFLAG.bit.RESRDY = 1;

	// Start conversion
	syncADC();
	ADC->SWTRIG.bit.START = 1;



	// Start conversion again, since The first conversion after the reference is changed must not be used.
	//syncADC();
	//ADC->SWTRIG.bit.START = 1;

	//ADC->INTENSET.bit.RESRDY=1;

	//  // Store the value
	while ( ADC->INTFLAG.bit.RESRDY == 0 );   // Waiting for conversion to complete
	//  valueRead = ADC->RESULT.reg;
	//
	//  syncADC();
	//  ADC->CTRLA.bit.ENABLE = 0x00;             // Disable ADC
	//  syncADC();

	uint32_t reg;

	syncADC();
	reg=ADC->CTRLA.reg;
	LOG("ADC CTRLA 0x%04X",reg);

	syncADC();
	reg=ADC->REFCTRL.reg;
	LOG("ADC REFCTRL 0x%04X",reg);

	syncADC();
	reg=ADC->AVGCTRL.reg;
	LOG("ADC AVGCTRL 0x%04X",reg);

	syncADC();
	reg=ADC->SAMPCTRL.reg;
	LOG("ADC SAMPCTRL 0x%04X",reg);

	syncADC();
	reg=ADC->CTRLB.reg;
	LOG("ADC CTRLB 0x%04X",reg);

	syncADC();
	reg=ADC->INPUTCTRL.reg;
	LOG("ADC INPUTCTRL 0x%04X",reg);

	syncADC();
	reg=ADC->GAINCORR.reg;
	LOG("ADC GAINCORR 0x%04X",reg);

	syncADC();
	reg=ADC->OFFSETCORR.reg;
	LOG("ADC OFFSETCORR 0x%04X",reg);

	syncADC();
	reg=ADC->CALIB.reg;
	LOG("ADC CALIB 0x%04X",reg);


	// Enable InterruptVector
	NVIC_EnableIRQ(ADC_IRQn);

	// Clear the Data Ready flag
	ADC->INTFLAG.bit.RESRDY = 1;


	// Start conversion
	syncADC();
	ADC->SWTRIG.bit.START = 1;

	return 0;//valueRead; //mapResolution(valueRead, _ADCResolution, _readResolution);
}
void ADC_Handler(void)
{

	uint16_t channel;
	uint16_t value;
	static uint16_t lastChannel=0;

	//static int state=0;
	YELLOW_LED(1);
	//state=(state+1)&0x01;

	value=ADC->RESULT.reg;
	channel=ADC->INPUTCTRL.bit.MUXPOS;// + ADC->INPUTCTRL.bit.INPUTOFFSET;

	//LOG("channel is %d %d", lastChannel,value);

	FetDriver::ADC_Callback(lastChannel,value);
	lastChannel=channel;

	if (channel == g_APinDescription[ISENSE_FET_B].ulADCChannelNumber)
	{
		syncADC();
		ADC->INPUTCTRL.bit.MUXPOS =  g_APinDescription[ISENSE_FET_A].ulADCChannelNumber;
	} else
	{
		syncADC();
		ADC->INPUTCTRL.bit.MUXPOS =  g_APinDescription[ISENSE_FET_B].ulADCChannelNumber;
	}

	//LOG("channel is %d %d", ADC->INPUTCTRL.bit.MUXPOS ,value);
	//syncADC();
	ADC->INTFLAG.bit.RESRDY = 1;
	//syncADC();
	ADC->SWTRIG.bit.START = 1;
	YELLOW_LED(0);
	//state=(state+1)&0x01;

}



void FetDriver::ADC_Callback(uint16_t channel, uint16_t value)
{

	//ptrInstance->begin();
	if (ptrInstance==NULL)
	{
		return;
	}
	ptrInstance->ctrl_update(channel,value);

}

void FetDriver::ctrl_update(uint16_t channel, uint16_t value)
{
	int32_t x,error;

	if (channel ==  g_APinDescription[ISENSE_FET_A].ulADCChannelNumber)
	{
		static int32_t iterm;

		x=value-coilA_Zero;
		error=coilA_SetPoint-x;
		coilA_error=x;
		iterm+=error;

		x=error*15;//+iterm/10;
		x=x/1024;
		coilA_value+=x;

//		if (error>0)
//			coilA_value++;
//			else
//				coilA_value--;
//
//		coilA_value+= iterm/1024;
		coilA_PWM(coilA_value);
//		if (error>0)
//		{
//			coilA(COIL_FORWARD);
//		}else
//		{
//			coilA(COIL_BRAKE);
//		}

	}

	if (channel ==  g_APinDescription[ISENSE_FET_B].ulADCChannelNumber)
	{
		static int32_t itermB;
		x=value-coilB_Zero;
		error=coilB_SetPoint-x;
		coilB_error=error;


		x=error*15+itermB/10;
		x=x/1024;
		coilB_value+=x;

		//coilB_PWM(coilB_value);
//		if (error>0)
//		{
//			coilB(COIL_FORWARD);
//		}else
//		{
//			coilB(COIL_BRAKE);
//		}

	}
	return;

	//LOG("channel is %d %d", channel,value);
	if (channel ==  g_APinDescription[ISENSE_FET_B].ulADCChannelNumber)
	{
		static int32_t ib=0;
		static int32_t meanb=0;
		int32_t error,u,de;
		static int32_t itermb=0;;
		static int32_t lastErrorb=0;

		adc=value;
		x=value-coilB_Zero;
		if (coilB_Zero==-1)
		{
			if(ib<FET_DRIVER_NUM_ZERO_AVG)
			{
				meanb=meanb+x;
				ib++;
			}else
			{
				coilB_Zero=meanb/ib;
			}
			return;
		}

		error=coilB_SetPoint-x;

		//		if (error>0)
		//			u=1;
		//		else
		//			u=-1;

		de=error-lastErrorb;
		lastErrorb=error;

		if (ABS(error)<50)
		{
			itermb=itermb+1*error;
		}else
		{
			itermb=0;
		}
		u=error*320 + itermb +100*de;
		u=u/16382;
		if (u>10) u=10;
		if (u<-10) u=-10;

		coilB_value+=u;;
		//LOG("coil value %d, %d",coilB_value,u);
		coilB_value=MIN(coilB_value,(int32_t)(F_CPU/FET_DRIVER_FREQ));
		coilB_value=MAX(coilB_value,(int32_t)(-(F_CPU/FET_DRIVER_FREQ)));

		coilB_PWM(coilB_value);

		return;
	}

	if (channel ==  g_APinDescription[ISENSE_FET_A].ulADCChannelNumber)
	{
		static int32_t i=0;
		static int32_t mean=0;
		int32_t error,u,de;
		static int32_t iterm=0;;
		static int32_t lastError=0;


		x=value-coilA_Zero;
		if (coilA_Zero==-1)
		{
			if(i<FET_DRIVER_NUM_ZERO_AVG)
			{
				mean=mean+x;
				i++;
			}else
			{
				coilA_Zero=mean/i;
			}

			return;
		}

		error=coilA_SetPoint-x;
		de=error-lastError;
		lastError=error;

		if (ABS(error)<50)
		{
			iterm=iterm+1*error;
		}else
		{
			iterm=0;
		}
		u=error*320 + iterm +100*de;
		u=u/16382;
		if (u>10) u=10;
		if (u<-10) u=-10;

		coilA_value+=u;
		//LOG("coil value %d, %d",coilB_value,u);
		coilA_value=MIN(coilA_value,(int32_t)(F_CPU/FET_DRIVER_FREQ));
		coilA_value=MAX(coilA_value,(int32_t)(-(F_CPU/FET_DRIVER_FREQ)));

		coilA_PWM(coilA_value);
		return;
	}

}


void FetDriver::measureCoilB_zero(void)
{
	coilB_Zero=GetMeanAdc(ISENSE_FET_B,FET_DRIVER_NUM_ZERO_AVG);
	LOG("Coil B Zero is %d",coilB_Zero);
	return;
}

void FetDriver::measureCoilA_zero(void)
{
	coilA_Zero=GetMeanAdc(ISENSE_FET_A,FET_DRIVER_NUM_ZERO_AVG);
	LOG("Coil A Zero is %d",coilA_Zero);
	return;
}


void FetDriver::CalTableA(int32_t maxMA)
{

	int16_t table2[512]={0};
	int32_t pwm=0;
	int32_t mA=0;
	int i;


	while (mA>-maxMA)
	{
		int32_t adc;
		//LOG("Running %d",pwm);
		adc=GetMeanAdc(ISENSE_FET_A,10)-coilA_Zero;
		//LOG("ADC is %d",adc);
		mA=FET_ADC_TO_MA(adc);
		//LOG("mA is %d, ADC %d",mA,ADC);
		pwm=pwm-1;

		if (coilA_PWM(pwm)==1)
		{
			ERROR("CoilA PWM maxed");
			break;
		}
		//delay(5);
	}

	//LOG("First PWM is %d %d",pwm, mA);
	PWM_Table_A[0]=pwm;
	table2[0]=mA;
	i=1;
	while (i<512)
	{
		int32_t adc;
		adc=GetMeanAdc(ISENSE_FET_A,10)-coilA_Zero;
		mA=FET_ADC_TO_MA(adc);

		//LOG("PWM %d, %d %d",i,mA,pwm);
		if (mA>((i-255)*maxMA/256))
		{
			PWM_Table_A[i]=pwm;
			table2[i]=mA;
			i++;
		}else
		{
			pwm=pwm+1;
			coilA_PWM(pwm);
			//delay(5);
		}
	}
	coilA_PWM(0);

	Serial.print("\n\r TABLE A \n\r");;
	for (i=0; i<512; i++)
	{
		Serial.print(PWM_Table_A[i]);
		Serial.print(",");
	}
	Serial.print("\n\r");

	Serial.print("\n\r");
	for (i=0; i<512; i++)
	{
		Serial.print(table2[i]);
		Serial.print(",");
	}
	Serial.print("\n\r");
}

void FetDriver::CalTableB(int32_t maxMA)
{

	int16_t table2[512]={0};
	int32_t pwm=0;
	int32_t mA=0;
	int i;

	while (mA>-maxMA)
	{
		int32_t adc;
		adc=GetMeanAdc(ISENSE_FET_B,10)-coilB_Zero;
		mA=FET_ADC_TO_MA(adc);
		pwm=pwm-1;
		coilB_PWM(pwm);
		//delay(5);
	}

	//LOG("First PWM is %d %d",pwm, mA);
	PWM_Table_B[0]=pwm;
	table2[0]=mA;
	i=1;
	while (i<512)
	{
		int32_t adc;
		adc=GetMeanAdc(ISENSE_FET_B,10)-coilB_Zero;
		mA=FET_ADC_TO_MA(adc);

		//LOG("PWM %d, %d %d",i,mA,pwm);
		if (mA>((i-255)*maxMA/256))
		{
			PWM_Table_B[i]=pwm;
			table2[i]=mA;
			i++;
		}else
		{
			pwm=pwm+1;
			coilB_PWM(pwm);
			//delay(5);
		}
	}

	coilB_PWM(0);
	Serial.print("\n\r TABLE B \n\r");
	for (i=0; i<512; i++)
	{
		Serial.print(PWM_Table_B[i]);
		Serial.print(",");
	}
	Serial.print("\n\r");

	Serial.print("\n\r");
	for (i=0; i<512; i++)
	{
		Serial.print(table2[i]);
		Serial.print(",");
	}
	Serial.print("\n\r");
}


void FetDriver::begin()
{
	int16_t i;
	uint32_t t0;
	int32_t i0=0;
	uint32_t zero,x,k;
	int32_t max_mA;


	ptrInstance=(FetDriver *)this;
	//enable 1V reference
	SYSCTRL->VREF.reg |= SYSCTRL_VREF_BGOUTEN;
	ADCRead(ISENSE_FET_A); //setup the adc with fast timing
	//nt32_t min,max,avg;
	//Setup the FET inputs
	GPIO_OUTPUT(PIN_FET_IN1);
	GPIO_OUTPUT(PIN_FET_IN2);
	GPIO_OUTPUT(PIN_FET_IN3);
	GPIO_OUTPUT(PIN_FET_IN4);
	GPIO_OUTPUT(PIN_FET_ENABLE);
	GPIO_HIGH(PIN_FET_ENABLE);

	//setup the Pin peripheral setting correct
	pinPeripheral(PIN_FET_IN2, PIO_TIMER_ALT); //TCC0 WO[7]
	pinPeripheral(PIN_FET_IN1, PIO_TIMER_ALT);
	SET_PIN_PERHERIAL(PIN_FET_IN4, PIO_TIMER_ALT); //TCC0 WO[7]
	SET_PIN_PERHERIAL(PIN_FET_IN3, PIO_TIMER_ALT);

	pinPeripheral(ISENSE_FET_A, PIO_ANALOG);  //AIN[0]
	pinPeripheral(ISENSE_FET_B, PIO_ANALOG);  //AIN[2]

	enableTCC0();
	coilB_PWM(0);
	coilA_PWM(0);
	delay(100);
	measureCoilA_zero();
	measureCoilB_zero();


//	ADCStart(ISENSE_FET_A);


	//return;
//	while(1)
//	{
//		LOG("tick %d %d", TCC0->CC[1].reg,TCC0->CC[0].reg);
//		LOG("%d %d",coilA_error,coilB_error);
//	}

//	uint16_t data[1000];
//		ADCRead(ISENSE_FET_A);
//
//		t0=micros();
//		GPIO_LOW(PIN_FET_IN2);
//				GPIO_GPIO_OUTPUT(PIN_FET_IN2);
//				GPIO_HIGH(PIN_FET_IN1);
//				GPIO_GPIO_OUTPUT(PIN_FET_IN1);
//
//		for (i=0; i<1000; i++)
//		{
//			data[i]=fastADCRead(ISENSE_FET_A);
//		}
//		coilA_PWM(0);
//
//		t0=micros()-t0;
//
//		Serial.print("\n\r Step response \n\r");
//		Serial.print(t0);
//
//		Serial.print("\n\r Step response \n\r");
//		for (i=0; i<1000; i++)
//		{
//			Serial.print(data[i]);
//			Serial.print(",");
//		}
//		Serial.print("\n\r");
//
//		while(1)
//		{
//
//		}
	max_mA=NVM->motorParams.currentMa;
	WARNING("Maximum current is %d",max_mA);


	if (NVM->motorParams.parametersVaild && max_mA!=0)
	{
		CalTableA(max_mA);
		CalTableB(max_mA);

	}else
	{
		WARNING("NVM is not correct default to 1500mA");
		max_mA=1500;
		WARNING("calibrating phase A %dmA",max_mA);
		CalTableA(max_mA);
		WARNING("calibrating phase B %dmA",max_mA);
		CalTableB(max_mA);

	}
	return;

	//coilA_PWM(100);

	x=0;
	while(1)
	{
		//LOG("Trying to move motor %d",x);
		delay(1);
		move(x, 1000);
		x=x+256;

	}


	return; // all done

	//	//set DAC to mid level
	//	syncDAC();
	//	DAC->DATA.reg = 0x2FF;  // DAC on 10 bits.
	//	syncDAC();
	//	DAC->CTRLA.bit.ENABLE = 0x01;     // Enable DAC
	//	syncDAC();

	//	WARNING("Running ADC ISR test");
	//	ADCRead(3);

	//LOG("coil value %d %d",coilB_value,coilB_Zero);
	i=47;
	x=0;
	while(1)
	{
		int32_t adc,value;
		int32_t mA;

		if (0)
		{

			coilB_PWM(i);
			delayMicroseconds(1000);
			//LOG("%d",i);
			//if (i==47 ) delay(50);

			if (x==0)
			{
				i=i+1;
				if (i>200)
				{
					x=1;
					//i=47;

				}
			}

			if (x == 1)
			{
				i=i-1;
				if (i<47)
				{
					x=2;
					i=-47;
				}

			}

			if (x == 2)
			{
				i=i-1;
				if (i<-200)
				{
					x=3;
				}
			}

			if (x == 3)
			{
				i=i+1;
				if (i>-47)
				{
					x=0;
					i=47;
				}
			}
		}else
		{

			adc=ADCRead(ISENSE_FET_A);
			value=adc-coilA_Zero;

			mA=(value*2206)/1000;



			//
			//delay(500);
			//NVIC_DisableIRQ(ADC_IRQn);

			LOG("coil A %d %d, %d ",coilA_Zero, value, mA );

		}
		//			NVIC_DisableIRQ(ADC_IRQn);
		//
		//			NVIC_EnableIRQ(ADC_IRQn);
	}

	x=0;
	for (k=0; k<128; k++)
	{
		x=x+ADCRead(8);
	}
	zero=x/32;

	//setupDAC();
	//setDAC(5,5);
	enableTCC0();
	//setupComparators();


	ERROR("Enable PWM");
	pinPeripheral(PIN_FET_IN4, PIO_TIMER_ALT); //TCC0 WO[7]

	//
	//	for (i=40; i<55; i++)
	//	{
	//		coilB_PWM(i);
	//		delay(200);
	//		ADCRead(8,16);
	//		LOG("COMP is 0x%04X ", AC->STATUSA.reg);
	//		LOG("%d ADC is %d ",i, ADCRead(8,16));
	//		YELLOW_LED(0);
	//	}

	//ADCRead(8,16);
	//AC->INTENCLR.bit.COMP1=1;
	//coilA_Value=0;

	coilB_PWM(0);

	i=47;
	coilB_PWM(i);
	while(1)
	{
		int32_t x=0,k;
		coilB_PWM(i);
		delay(3000);
		for (k=0; k<128; k++)
		{
			x=x+ADCRead(8);
		}
		x=x/32;
		LOG("%d %d %d",i,x-zero,(x*3300)/(4096*4));
		LOG("%d",((x-zero)*5517)/10000);

		i=i+20;
		if (i>140)
		{
			i=47;
		}

	}
	/*	AC->INTENSET.bit.COMP1=1;
	while(1)
	{
		AC->INTENCLR.bit.COMP1=1;
		YELLOW_LED(0);
		AC->INTENSET.bit.COMP1=1;
		if ((millis()-t0)>10000)
		{
			int j;
			min=0xFFFFFF;
			max=(int16_t)ADCRead(8,16);
			avg=0;
			j=0;
			t0=micros();
			while( (micros()-t0)<1000)
			{
				 int16_t valueRead;

				  valueRead = ADCRead(8,16);

				  if (valueRead<min)
				  {
					  min=valueRead;
				  }
				  if (valueRead>max)
				  {
					  max=valueRead;
				  }
				  avg+=valueRead;
				  j++;
			}


			int32_t ma,x,duty;
			duty=i-45;
			duty=(1000*duty)/(F_CPU/FET_DRIVER_FREQ);

			LOG("min %d max %d, avg %d j %d, %d", min, max, (avg*10)/j, j,(avg*10)/j*(1000-duty)/1000);

			x=(avg*10)/j*(1000-duty)/1000;
			x=(x*600)/1000+200;

			LOG("mA %d\n\r",x);

			if (i<150)
			{
				i=100;
			}else
			{
				i=45;
			}
			LOG("COMP is 0x%04X ", AC->STATUSA.reg);
			LOG("%d ADC is %d %d",i, ADCRead(8,16),coilA_Value);
			t0=millis();
			AC->INTENCLR.bit.COMP1=1;
			coilA_Value=0;
			coilB_PWM(i);
			AC->INTENSET.bit.COMP1=1;
		}
	}
	 */
	return;

	//setup the PWM for current on the A4954, set for low current
	digitalWrite(PIN_A4954_VREF12,LOW);
	digitalWrite(PIN_A4954_VREF34,LOW);
	pinMode(PIN_A4954_VREF34, OUTPUT);
	pinMode(PIN_A4954_VREF12, OUTPUT);

	enabled=true;
	lastStepMicros=0;
	forwardRotation=true;

	enableTCC0();
	setupDAC();
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








int32_t FetDriver::getCoilB_mA(void)
{
	int32_t adc,ret;
	//fastADCRead(ISENSE_FET_B);
	adc=(int32_t)fastADCRead(ISENSE_FET_B);
	ret=FET_ADC_TO_MA(adc-coilB_Zero);
	//LOG("coilb %d %d",adc,ret);
	return ret;
}
int32_t FetDriver::getCoilA_mA(void)
{
	int32_t adc,ret;
	//fastADCRead(ISENSE_FET_A);
	adc=(int32_t)fastADCRead(ISENSE_FET_A);
	ret=FET_ADC_TO_MA(adc-coilA_Zero);
	//LOG("coila %d %d",adc,ret);
	return ret;
}


//this is precise move and modulo of A4954_NUM_MICROSTEPS is a full step.
// stepAngle is in A4954_NUM_MICROSTEPS units..
// The A4954 has no idea where the motor is, so the calling function has to
// to tell the A4954 what phase to drive motor coils.
// A4954_NUM_MICROSTEPS is 256 by default so stepAngle of 1024 is 360 degrees
// Note you can only move up to +/-A4954_NUM_MICROSTEPS from where you
// currently are.
int32_t FetDriver::move(int32_t stepAngle, uint32_t mA)
{
	uint16_t angle;
	int32_t cos,sin;
	int32_t dacSin,dacCos;
	int32_t dacSin_mA,dacCos_mA;
	int32_t maxMa;
	static int32_t last_dacSin_mA=0,last_dacCos_mA=0;;
	if (enabled == false)
	{
		WARNING("FET Driver disabled");

		//turn the current off to FETs
		coilA_PWM(0);
		coilB_PWM(0);

		//float the FET outputs by disabling FET driver.
		GPIO_LOW(PIN_FET_ENABLE);
		return stepAngle;
	}
	GPIO_HIGH(PIN_FET_ENABLE);


	maxMa=NVM->motorParams.currentMa;
	if (maxMa==0)
	{
		maxMa=2200;
	}

	//WARNING("move %d %d",stepAngle,mA);
	//handle roll overs, could do with modulo operator
	//stepAngle=stepAngle%SINE_STEPS;
	//	while (stepAngle<0)
	//	{
	//		stepAngle=stepAngle+SINE_STEPS;
	//	}
	//	while (stepAngle>=SINE_STEPS)
	//	{
	//		stepAngle=stepAngle-SINE_STEPS;
	//	}

	//figure out our sine Angle
	// note our SINE_STEPS is 4x of microsteps for a reason
	//angle=(stepAngle+(SINE_STEPS/8)) % SINE_STEPS;
	angle=(stepAngle) % SINE_STEPS;
	//calculate the sine and cosine of our angle
	sin=sine(angle);
	cos=cosine(angle);

	//if we are reverse swap the sign of one of the angels
	if (false == forwardRotation)
	{
		cos=-cos;
	}

	//LOG("sin/cos %d %d %d", sin,cos,angle);
	//scale sine result by current(mA)
	dacSin_mA=((int32_t)mA*(int32_t)(sin))/SINE_MAX;

	//scale cosine result by current(mA)
	dacCos_mA=((int32_t)mA*(int32_t)(cos))/SINE_MAX;

	coilA_SetPoint=FET_MA_TO_ADC(dacSin_mA);
	coilB_SetPoint=FET_MA_TO_ADC(dacCos_mA);
	//LOG("sin/cos %d %d", dacSin,dacCos);

	//convert value into 12bit DAC scaled to 3300mA max
	dacSin=(int32_t)((int64_t)dacSin_mA*(255))/maxMa;

	//convert value into 12bit DAC scaled to 3300mA max
	dacCos=(int32_t)((int64_t)dacCos_mA*(255))/maxMa;

	//LOG("sin/cos %d %d", dacSin,dacCos);
	//limit the table index to +/-255
	dacCos=MIN(dacCos,(int32_t)255);
	dacCos=MAX(dacCos,(int32_t)-255);
	dacSin=MIN(dacSin,(int32_t)255);
	dacSin=MAX(dacSin,(int32_t)-255);


	if ((dacSin_mA-last_dacSin_mA)>200)
	{
		GPIO_LOW(PIN_FET_IN2);
		PIN_GPIO_OUTPUT(PIN_FET_IN2);
		GPIO_HIGH(PIN_FET_IN1);
		PIN_GPIO_OUTPUT(PIN_FET_IN1);
	}else if ((dacSin_mA-last_dacSin_mA)<-200)
	{
		GPIO_HIGH(PIN_FET_IN2);
		PIN_GPIO_OUTPUT(PIN_FET_IN2);
		GPIO_LOW(PIN_FET_IN1);
		PIN_GPIO_OUTPUT(PIN_FET_IN1);
	}

	if ((dacCos_mA-last_dacCos_mA)>200)
	{
		GPIO_LOW(PIN_FET_IN4);
		PIN_GPIO_OUTPUT(PIN_FET_IN4);
		GPIO_HIGH(PIN_FET_IN3);
		PIN_GPIO_OUTPUT(PIN_FET_IN3);
	}else if ((dacCos_mA-last_dacCos_mA)<-200)
	{
		GPIO_HIGH(PIN_FET_IN4);
		PIN_GPIO_OUTPUT(PIN_FET_IN4);
		GPIO_LOW(PIN_FET_IN3);
		PIN_GPIO_OUTPUT(PIN_FET_IN3);
		}
	delayMicroseconds(20);
	last_dacSin_mA=dacSin_mA;
	last_dacCos_mA=dacCos_mA;

//	YELLOW_LED(1);
//	uint32_t t0=micros();
//	int done=0;
//	int32_t a,b;
//	a=FET_MA_TO_ADC(dacSin_mA);
//	b=FET_MA_TO_ADC(dacCos_mA);
//	while ((micros()-t0)<20 && done!=0x03)
//	{
//		if ( (fastADCRead(ISENSE_FET_A)-a)<FET_MA_TO_ADC(200))
//		{
//			GPIO_LOW(PIN_FET_IN2);
//			PIN_GPIO_OUTPUT(PIN_FET_IN2);
//			GPIO_HIGH(PIN_FET_IN1);
//			PIN_GPIO_OUTPUT(PIN_FET_IN1);
//			//coilA_PWM(PWM_Table_A[dacSin+255]);
//			done |=0x01;
//		}
//
//		if ((fastADCRead(ISENSE_FET_A)-a)>FET_MA_TO_ADC(200))
//		{
//			GPIO_HIGH(PIN_FET_IN2);
//			PIN_GPIO_OUTPUT(PIN_FET_IN2);
//			GPIO_LOW(PIN_FET_IN1);
//			PIN_GPIO_OUTPUT(PIN_FET_IN1);
//			done |=0x01;
//		}
//		if  ((fastADCRead(ISENSE_FET_B)-b)<FET_MA_TO_ADC(200))
//		{
//			GPIO_LOW(PIN_FET_IN4);
//			PIN_GPIO_OUTPUT(PIN_FET_IN4);
//			GPIO_HIGH(PIN_FET_IN3);
//			PIN_GPIO_OUTPUT(PIN_FET_IN3);
//			done |=0x02;
//		}
//		if  ((fastADCRead(ISENSE_FET_B)-b)>FET_MA_TO_ADC(200))
//		{
//			GPIO_HIGH(PIN_FET_IN4);
//			PIN_GPIO_OUTPUT(PIN_FET_IN4);
//			GPIO_LOW(PIN_FET_IN3);
//			PIN_GPIO_OUTPUT(PIN_FET_IN3);
//			done |=0x02;
//		}
//
//	}
//
//	YELLOW_LED(0);


	//LOG("sin/cos %d %d", dacSin,dacCos);
	//loop up the current from table and set the PWM
	coilA_PWM(PWM_Table_A[dacSin+255]);
	coilB_PWM(PWM_Table_B[dacCos+255]);

	lastStepMicros=micros();
	return stepAngle;
}
#pragma GCC pop_options //fast optimization

#endif //NEMA_23_10A_HW

#pragma GCC pop_options
