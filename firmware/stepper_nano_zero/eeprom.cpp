/*
 * eeprom.cpp
 *
 *  Created on: May 30, 2017
 *      Author: tstern
 */
#include "eeprom.h"
#include "calibration.h"
#include "Flash.h"
#include "board.h" //for divide with rounding macro
#include <Arduino.h>
#include "syslog.h"

//since we will write the following structure into each page, we need to find our latest page
// to do this we will use the header to contain a checksum and write counter.
#define EEPROM_SIZE (FLASH_ROW_SIZE*2)

typedef struct {
      uint16_t checksum;
      uint16_t count;
}eepromHeader_t;

#define EEPROM_DATA_SIZE (FLASH_PAGE_SIZE_NZS-sizeof(eepromHeader_t))
typedef struct {
      eepromHeader_t header;
      uint8_t data[EEPROM_DATA_SIZE];
} eepromData_t;



static eepromData_t EEPROMCache;

static int32_t NextPageWrite=-1;

//we need to reserve two pages for EEPROM
__attribute__((__aligned__(FLASH_ROW_SIZE))) const uint8_t NVM_eeprom[EEPROM_SIZE]={0xFFF};


static uint16_t checksum(uint8_t *ptrData, uint32_t nBytes)
{
   uint16_t sum=0;
   uint32_t i;
   i=0;
   //LOG("running checksum %d",nBytes);
   while(i<nBytes)
   {
      sum += ptrData[i];
      i++;
   }

   return sum;
}

static bool isPageGood(uint32_t page)
{
   eepromData_t *ptrData;
   uint16_t cs;
   ptrData=(eepromData_t *)&NVM_eeprom[page];

   cs=checksum(ptrData->data, EEPROM_DATA_SIZE);
   //LOG("checksum is %d %d",cs,ptrData->header.checksum);

   if (cs==ptrData->header.checksum)
   {
      //LOG("Page good %d",page);
      return true;
   }
   //LOG("page bad %d",page);
   return false;
}

static void printEEPROM(uint32_t page)
{
   eepromData_t *ptrData;
   int i;
   ptrData=(eepromData_t *)&NVM_eeprom[page];
   LOG("count %d", ptrData->header.count);
   LOG("checksum %d", ptrData->header.checksum);
   for (i=0; i<10; i++)
   {
      LOG("Data[%d]=%02X",i,ptrData->data[i]);
   }
}

static uint32_t findLastGoodPage(void)
{
   uint32_t lastGoodPage=0;
   uint32_t page;
   uint16_t lastCnt=0;
   eepromData_t *ptrData;

   page=0;
   while(page < (EEPROM_SIZE))
   {
      //LOG("checking page %d",page);
      if (isPageGood(page))
      {
	 ptrData=(eepromData_t *)&NVM_eeprom[page];

	 //check for roll over which is OK
	 if (lastCnt==16534 && ptrData->header.count==1)
	 {
	    lastCnt=ptrData->header.count;
	    lastGoodPage=page;
	 }
	 if (ptrData->header.count>lastCnt)
	 {
	    //make sure we have not rolled over.
	    if ((ptrData->header.count-lastCnt)<(16534/2))
	    {
	       lastCnt=ptrData->header.count;
	       lastGoodPage=page;
	    }
	 }
      }
      page=page + FLASH_PAGE_SIZE_NZS;
   }
   //LOG("last good page %d",lastGoodPage);
   return lastGoodPage;
}

//find the next page to write
static uint32_t eepromGetNextWritPage(void)
{
   eepromHeader_t *ptrHeader;
   uint32_t page;
   uint32_t row;
   int blockCount;
   int done=0;

   //start at first address:
   page=0;

   while(page < (EEPROM_SIZE))
   {
      //LOG("checking page %d",page);
      ptrHeader=(eepromHeader_t *) &NVM_eeprom[page];
      if (ptrHeader->count == 0xFFFF)
      {
	 uint32_t i;
	 uint8_t *ptrData;
	 //uint8_t erasedByte=(uint8_t)ptrHeader->count;
	 bool erased=true;

	 //verify page is erased
	 ptrData= (uint8_t *)&NVM_eeprom[page];

	 for (i=0; i<FLASH_PAGE_SIZE_NZS; i++)
	 {
	    if (ptrData[i] != FLASH_ERASE_VALUE)
	    {
	       erased=false;
	       break;
	    }
	 }

	 if (erased)
	 {
	    //LOG("Found Page %d erased",page);
	    return page;
	 }
      }
      page=page+FLASH_PAGE_SIZE_NZS;
   }
   //if we get get here all the pages are full...
   // we need to find the page with last good data.
   page=findLastGoodPage();

   //find which row the page is in
   row=page/FLASH_ROW_SIZE;

   //increment to next row for erase
   row++;
   if ((row*FLASH_ROW_SIZE)>=EEPROM_SIZE)
   {
      row=0;
      //TODO we should make sure this not where good data is
      // however if it is what should we do?
   }

   //now we need to erase that row
   //WARNING("Erasing page %d",row*FLASH_ROW_SIZE);
   flashErase(&NVM_eeprom[row*FLASH_ROW_SIZE],FLASH_ROW_SIZE);
   page=row*FLASH_ROW_SIZE;
   //LOG("Next free page is %d",page);
   return page;
}


eepromError_t eepromInit(void)
{
   uint32_t page;


   //find the last good page offset in flash
   page=findLastGoodPage();
   LOG("EEPROM Init found page %d",page);
   if (isPageGood(page))
   {
      LOG("EEPROM page good %d",page);
      memcpy(&EEPROMCache, &NVM_eeprom[page], sizeof(EEPROMCache));

      NextPageWrite=eepromGetNextWritPage();
      return EEPROM_OK;
   }
   //ERROR("page is bad");
   memset(&EEPROMCache, 0, sizeof(EEPROMCache));
   NextPageWrite=eepromGetNextWritPage();
   return EEPROM_CORRUPT;
}


int eepromWriteCache(uint8_t *ptrData, uint32_t size)
{
   //LOG("Cache write %d",size);
   if (NextPageWrite==-1) //some one did not init the module
   {
      //lets handle gracefully and do it ourselves
      eepromInit();
   }
   if (size>EEPROM_DATA_SIZE)
   {
      size =EEPROM_DATA_SIZE;
   }
   memcpy(EEPROMCache.data, ptrData, size);
   EEPROMCache.header.checksum=checksum(EEPROMCache.data,EEPROM_DATA_SIZE);


   return size;
}

int eepromRead(uint8_t *ptrData, uint32_t size) //returns number of bytes actually read, whcih could be less than size requested
{
   if (NextPageWrite==-1) //some one did not init the module
   {
      //lets handle gracefully and do it ourselves
      eepromInit();
   }
   if (size>EEPROM_DATA_SIZE)
   {
      size =EEPROM_DATA_SIZE;
   }
   if (EEPROMCache.header.count == 0)
   {
      return 0; //cache is new/corrupt
   }
   memcpy(ptrData, EEPROMCache.data, size);
   return size;
}

eepromError_t eepromFlush(void) //flush the cache to flash memory
{
   if (NextPageWrite==-1)
   {
      ERROR("EEPROM WRITE FAILED");
      return EEPROM_FAILED; //most likely no one has written to cache
   }
   EEPROMCache.header.count++;
   if (EEPROMCache.header.count>=16535)
   {
      EEPROMCache.header.count=1;
   }
   //WARNING("Writting to Page %d",NextPageWrite);
   flashWrite(&NVM_eeprom[NextPageWrite], &EEPROMCache, sizeof(EEPROMCache));

  // printEEPROM(NextPageWrite);

   if (!SYSCTRL->PCLKSR.bit.BOD33DET) //if not in brown out condition find next write location
   {
       //LOG("getting next page to write");
      NextPageWrite=eepromGetNextWritPage(); //find next write location and erase if needed
   } else
   {
      //LOG("BOD active");
      NextPageWrite=-1; //else we will just clear NextPageWrite location just in case we recover from brown out
   }
   return EEPROM_OK;
}



