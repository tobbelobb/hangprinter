/*
 * nzs.h
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

#ifndef NZS_H_
#define NZS_H_

#include "board.h"
#include "nzs_lcd.h"
#include "stepper_controller.h"
#include "planner.h"

typedef struct
{
	int64_t angle;
	uint16_t encoderAngle;
	uint8_t valid;
}eepromData_t;

class NZS //nano Zero Stepper
{

	public:
		void begin(void);
		void loop(void);

};


#endif /* NZS_H_ */
