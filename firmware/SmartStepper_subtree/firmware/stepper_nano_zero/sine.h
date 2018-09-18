/**********************************************************************
 * sine.h
 *
 *  Created on: Dec 24, 2016
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


#ifndef SINE_H_
#define SINE_H_

#include "board.h"

#define SINE_STEPS (1024L)

#define SINE_MAX ((int32_t)(32768L))


int16_t sine(uint16_t angle);
int16_t cosine(uint16_t angle);


#endif /* SINE_H_ */
