/*
 * syslog.c
 *
 *  Created on: Sep 14, 2011
 *      Author: trampas.stern
 *
 *	Misfit Tech invests time and resources providing this open source code,
 *	please support Misfit Tech and open-source hardware by purchasing
 *	products from Misfit Tech, www.misifittech.net!
 *
 *	Written by Trampas Stern  for Misfit Tech.
 *	BSD license, check license.txt for more information
 *	All text above, must be included in any redistribution
 *********************************************************************/
#include "syslog.h"
#include <Arduino.h>
#include "board.h"


#define ANSI_WHITE 		"\033[37m"
#define ANSI_NORMAL 	"\033[0m"
#define ANSI_BLINK 		"\033[5m"
#define ANSI_BLUE 		"\033[34m"
#define ANSI_MAGENTA 	"\033[35m"
#define ANSI_CYAN 		"\033[36m"
#define ANSI_WHITE 		"\033[37m"
#define ANSI_RED 		"\033[31m"
#define ANSI_GREEN 		"\033[32m"
#define ANSI_PINK 		"\033[35m\033[1m"
#define ANSI_BROWN 		"\033[33m"
#define ANSI_YELLOW 	"\033[33m\033[1m"
#define ANSI_BLACK      "\033[30m"
#define ANSI_BELL_AND_RED 		"\a\033[31m"

#define NEW_LINE "\n\r"

Uart *ptrSerial=NULL;
eLogLevel SyslogLevelToWrite;

bool DebugUART=false;
static char buffer[SYSLOG_BUFFER_SIZE];
static unsigned int BufIndex=0;

static int SysLog_Enabled=1;

int SysLogDisable(void)
{
	SysLog_Enabled=0;
	return 0;
}

int SysLogEnable(void)
{
	SysLog_Enabled=1;
	return 0;
}

int SysLogIsEnabled(void)
{
	return SysLog_Enabled;
}
void SysLogDebug(bool x)
{
	DebugUART=x;
}

void SysLogPuts(const char *ptrStr)
{
	if (!SysLog_Enabled)
		return;

	if (NULL == ptrSerial)
	{
		while(*ptrStr)
		{

			SYSLOG_PUTC(*ptrStr);
			ptrStr++;
		}
	} else
	{
		ptrSerial->write(ptrStr);
	}
	if (DebugUART)
	{
		SerialUSB.write(ptrStr);
	}
}

int SysLogInitDone=0;
void SysLogInit(Uart *ptrSerialObj, eLogLevel LevelToWrite)
{
	ptrSerial=ptrSerialObj;
	SyslogLevelToWrite=LevelToWrite;

	SysLogInitDone=1;
	BufIndex=0;
	memset(buffer,0,SYSLOG_BUFFER_SIZE);
}


int SysLogProcessing=0; // this is used such that syslog can be reentrent
int SysLogMissed=0;


void SysLog(eLogLevel priorty, const char *fmt, ...)
{
    //UINT32 ret;
	int previousState=SysLog_Enabled;
    char vastr[MAX_SYSLOG_STRING]={0};
    //char outstr[MAX_SYSLOG_STRING]={0};


    va_list ap;

    if (SysLogProcessing)
    {
    	//we have a syslog from a syslog call thus return as not much we can do...
    	//memset(buffer,0,SYSLOG_BUFFER_SIZE);
    	va_start(ap,fmt);
    	vsnprintf(&buffer[BufIndex],SYSLOG_BUFFER_SIZE-BufIndex,(char *)fmt,ap);
    	BufIndex=strlen(buffer);
    	snprintf(&buffer[BufIndex],SYSLOG_BUFFER_SIZE-BufIndex,NEW_LINE);
    	BufIndex=strlen(buffer);
    	SysLogMissed++; //set flag that we missed a call
    	return;
    }

    SysLogProcessing=1;

    //stop the watch dog will doing a SysLog print
    Sys_WDogHoldOn();

    if(!SysLogInitDone)
    {
    	SysLogInit(NULL, LOG_WARNING); //not sure who is reseting serial port but before we print set it up
        WARNING("You should init SysLog");
    	//SysLogInitDone=0;
    }

    //Send out a * that we missed a SysLog Message before this current message
    if (SysLogMissed)
    {
    	//SysLogPuts(ANSI_RED);
    	SysLogPuts("*** Reentrant Log call possible loss of message(s):");
    	SysLogPuts(NEW_LINE);
    	if (BufIndex>0)
    	{
    		SysLogPuts(buffer);
    		memset(buffer,0,SYSLOG_BUFFER_SIZE);
    		BufIndex=0;
    	}
    	//SysLogPuts(ANSI_RED);
    	SysLogPuts("***********");
    	SysLogPuts(NEW_LINE);
    	SysLogMissed=0;
    }
    memset(vastr,0,MAX_SYSLOG_STRING);
    va_start(ap,fmt);
//#ifndef PGM_P
#if 1
   vsnprintf(vastr,MAX_SYSLOG_STRING,(char *)fmt,ap);
#else
    vsprintf_P(vastr,(const char *)fmt,ap);
#endif
    //get time and store in datetimestr if desired
    //sprintf(outstr, "[%s] %s\r\n", datetimestr, vastr);



    if (priorty<=LOG_ERROR)
    {
    	SysLog_Enabled=1;
    	SysLogPuts(ANSI_RED);

    }else if (priorty==LOG_DEBUG)
    {
    	SysLogPuts(ANSI_WHITE);
    }else if (priorty==LOG_WARNING)
    {
    	SysLogPuts(ANSI_BLUE);
    }

#ifdef RTC_H_
#ifdef TIME_H_
    {
    	struct tm tp;
    	RTC_Time_s tm;
    	time_t secs;
    	char datetimestr[MAX_SYSLOG_STRING]={0};

    	RTC_ReadTime(&tm);
    	secs=tm.seconds;
    	convertFlexNetTime((time_t *)&secs, &tp);
    	time_str(datetimestr,&tp);
    	SysLogPuts(datetimestr);

    	if (priorty<=SyslogLevelToWrite && SysLogWriteFunc!=NULL)
		{
			SysLogWriteFunc(datetimestr,strlen(datetimestr));
		}
    }
#endif
#endif

    SysLogPuts(vastr);
//
//    if (priorty<=SyslogLevelToWrite && SysLogWriteFunc!=NULL)
//    {
//    	SysLogWriteFunc(vastr,strlen(vastr));
//    	SysLogWriteFunc(NEW_LINE,strlen(NEW_LINE));
//    }


    SysLogPuts(ANSI_NORMAL);
    SysLogPuts(NEW_LINE);



    if (priorty == LOG_EMERG) {
    	//you can reboot processor here
    }

    //start the watch dog where left off..
    Sys_WDogHoldOff();
    SysLogProcessing=0;
    SysLog_Enabled=previousState;
    return;
}

