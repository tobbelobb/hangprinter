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
#ifndef __FLASH__H__
#define __FLASH__H__

#include <Arduino.h>
#include "syslog.h"


#define FLASH_PAGE_SIZE_NZS (64) //bytes
#define FLASH_ROW_SIZE (FLASH_PAGE_SIZE_NZS*4) //defined in the datasheet as 4x page size
#define FLASH_ERASE_VALUE (0xFF) //value of flash after an erase

#define FLASH_ALLOCATE(name, size) \
	__attribute__((__aligned__(FLASH_ROW_SIZE))) \
   const uint8_t name[(size+(FLASH_ROW_SIZE-1))/FLASH_ROW_SIZE*FLASH_ROW_SIZE] = { };

bool flashInit(void); //this checks that our assumptions are true

bool flashErase(const volatile void *flash_ptr, uint32_t size);
void flashWrite(const volatile void *flash_ptr,const void *data,uint32_t size);
void flashWritePage(const volatile void *flash_ptr, const void *data, uint32_t size);

//you can read by dereferencing pointer but we will add a read
static inline int32_t flashRead(const volatile void *flash_ptr, void *data, uint32_t size)
{
  memcpy(data, (const void *)flash_ptr, size);
}




#endif //__FLASH__H__
