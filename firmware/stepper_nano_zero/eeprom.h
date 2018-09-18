/*
 * eeprom.h
 *
 *  Created on: May 30, 2017
 *      Author: tstern
 */

#ifndef EEPROM_H_
#define EEPROM_H_
#include "Flash.h"
#include "calibration.h"
#include "board.h"

/*
 *  This EEPROM implementation provides 60bytes of "eeprom space"  (we reserve 4 bytes for overhead)
 * 	The EEPROM uses two rows of flash (256 bytes per row), which
 * 	for the SAMD21G18A this allows a minimual 200k writes, but typically 1200k
 */

typedef enum {
	EEPROM_OK =0,
	EEPROM_FAILED=1,
	EEPROM_CORRUPT=2,
} eepromError_t;


eepromError_t eepromInit(void);
int eepromWriteCache(uint8_t *ptrData, uint32_t size); //returns number bytes written to cache
eepromError_t eepromFlush(void); //flush the cache to flash memory
int eepromRead(uint8_t *ptrData, uint32_t size); //returns number of bytes actually read, whcih could be less than size requested

#endif /* EEPROM_H_ */
