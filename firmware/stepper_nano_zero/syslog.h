/*
 * syslog.h
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

#ifndef SYSLOG_H_
#define SYSLOG_H_

#include <stdarg.h>
#include <string.h>
#include <stdio.h>
#include "Arduino.h"
#include "variant.h"

#ifdef __cplusplus
extern "C"
{
#endif // __cplusplus

#define SYSLOG_BUFFER_SIZE  (250)

#define MAX_SYSLOG_STRING   (250)
#define __FILENAME1__ (__builtin_strrchr(__FILE__, '\\') ? __builtin_strrchr(__FILE__, '\\') + 1 : __FILE__)
#define __FILENAME__ (__builtin_strrchr(__FILENAME1__, '/') ? __builtin_strrchr(__FILENAME1__, '/') + 1 : __FILENAME1__)

#define SYSLOG_WRITE(buffer,nBytes)

#ifdef CMD_SERIAL_PORT
#define SYSLOG_PUTC(x)
#else
#define SYSLOG_PUTC(x) //SerialUSB.write(x)
#endif

#define Sys_WDogHoldOn()
#define Sys_WDogHoldOff()
/*
  * priorities/facilities are encoded into a single 32-bit quantity, where the
  * bottom 3 bits are the priority (0-7) and the top 28 bits are the facility
  * (0-big number).  Both the priorities and the facilities map roughly
  * one-to-one to strings in the syslogd(8) source code.  This mapping is
  * included in this file.
  *
  * priorities (these are ordered)
  */

typedef enum _eLogLevel {
    LOG_EMERG    = 0,   // system is unusable
    LOG_ALERT    = 1,   // action must be taken immediately
    LOG_CRIT     = 2,   // critical conditions
    LOG_ERROR    = 3,   // error conditions
    LOG_WARNING  = 4,   // warning conditions
    LOG_NOTICE   = 5,   // normal but significant condition
    LOG_INFO     = 6,   // informational
    LOG_DEBUG    = 7,   // debug-level messages
    LOG_DISABLED = 8    // disabled messages
} eLogLevel;

#if 0
#define CONCAT(x, y) CONCAT_(x, y)
#define CONCAT_(x, y) x##y

#define ID(...) __VA_ARGS__

#define IFMULTIARG(if,then,else) \
CONCAT(IFMULTIARG_, IFMULTIARG_(if, \
1, 1, 1, 1, 1, 1, 1, 1, 1, 1, \
1, 1, 1, 1, 1, 1, 1, 1, 1, 1, \
1, 1, 1, 1, 1, 1, 1, 1, 1, 1, \
1, 1, 1, 1, 1, 1, 1, 1, 1, 1, \
1, 1, 1, 1, 1, 1, 1, 1, 1, 1, \
1, 1, 1, 1, 1, 1, 1, 1, 1, 1, \
1, 1, 0, ))(then,else)
#define IFMULTIARG_(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, \
_10, _11, _12, _13, _14, _15, _16, _17, _18, _19, \
_20, _21, _22, _23, _24, _25, _26, _27, _28, _29, \
_30, _31, _32, _33, _34, _35, _36, _37, _38, _39, \
_40, _41, _42, _43, _44, _45, _46, _47, _48, _49, \
_50, _51, _52, _53, _54, _55, _56, _57, _58, _59, \
_60, _61, _62, _63, ...) _63
#define IFMULTIARG_0(then, else) else
#define IFMULTIARG_1(then, else) then

#define PROVIDE_SECOND_ARGUMENT(x, ...)  CONCAT( IFMULTIARG(ID(__VA_ARGS__), INSERT_, ADD_), SECOND_ARGUMENT ) (x, __VA_ARGS__)
#define PROVIDE_SECOND_ARGUMENT2(x, y, ...)  CONCAT( IFMULTIARG(ID(__VA_ARGS__), INSERT_, ADD_), SECOND_ARGUMENT2 ) (x, y, __VA_ARGS__)

#define ADD_SECOND_ARGUMENT(x, y) y, x
#define INSERT_SECOND_ARGUMENT(x, y, ...) y, x, __VA_ARGS__

#define ADD_SECOND_ARGUMENT2(x, z, y) y, x, z
#define INSERT_SECOND_ARGUMENT2(x, z, y, ...) y, x, z, __VA_ARGS__

#endif 
//#define DEBUG1(...) printf( "DEBUG %s %s: "
//PROVIDE_SECOND_ARGUMENT2(__FILE__, __LINE__, __VA_ARGS__))


//TXT(x) macro is used for system which can store strings in flash, like AVR processors
#ifndef TXT
    #define TXT(x) x
#endif

void     SysLog(eLogLevel priorty,  const char *fmt, ...);



static inline const char * __file__( const char *filename ) {
    char const *p = strrchr( filename, '/' );
    if ( p )
        return p+1;
    else
        return filename;
}                               // __file__


//These macros abstract the logging and append the file and line number to errors.
#ifndef SYSLOG_DISABLE
//#ifndef PGM_P
#if 1
//EMERG means system is unstable thus will force a reboot!
#define EMERG(fmt, ...)    SysLog( LOG_EMERG,   "EMERG:    %s %4d: " fmt, __FILENAME__, __LINE__, ## __VA_ARGS__ )
#define ALERT(fmt, ...)    SysLog( LOG_ALERT,   "ALERT:    %s %4d: " fmt, __FILENAME__, __LINE__, ## __VA_ARGS__ )
#define CRITICAL(fmt, ...) SysLog( LOG_CRIT,    "CRITICAL: %s %4d: " fmt, __FILENAME__, __LINE__, ## __VA_ARGS__ )
#define ERROR(fmt, ...)    SysLog( LOG_ERROR,   "ERROR:    %s %4d: " fmt, __FILENAME__, __LINE__, ## __VA_ARGS__ )
#define WARNING(fmt, ...)  SysLog( LOG_WARNING, "WARNING:  %s %4d: " fmt, __FILENAME__, __LINE__, ## __VA_ARGS__ )
#define NOTICE(fmt, ...)   SysLog( LOG_NOTICE,  "NOTICE:   %s %4d: " fmt, __FILENAME__, __LINE__, ## __VA_ARGS__ )
#define INFO(fmt, ...)     SysLog( LOG_INFO,    "INFO:     %s %4d: " fmt, __FILENAME__, __LINE__, ## __VA_ARGS__ )
#define LOG(fmt, ...)      SysLog( LOG_DEBUG,   "%s %4d: "           fmt, __FILENAME__ , __LINE__, ## __VA_ARGS__ )
//
//#define EMERG(...)    SysLog( LOG_EMERG,   "EMERG:    %15s %4d: " PROVIDE_SECOND_ARGUMENT2(BASE_FILE_NAME, __LINE__,__VA_ARGS__ ) )
//#define ALERT(...)    SysLog( LOG_ALERT,   "ALERT:    %15s %4d: " PROVIDE_SECOND_ARGUMENT2(BASE_FILE_NAME, __LINE__,__VA_ARGS__ ) )
//#define CRITICAL(...) SysLog( LOG_CRIT,    "CRITICAL: %15s %4d: " PROVIDE_SECOND_ARGUMENT2(BASE_FILE_NAME, __LINE__,__VA_ARGS__ ) )
//#define ERROR(...)    SysLog( LOG_ERROR,   "ERROR:    %15s %4d: " PROVIDE_SECOND_ARGUMENT2(BASE_FILE_NAME, __LINE__,__VA_ARGS__ ) )
//#define WARNING(...)  SysLog( LOG_WARNING, "WARNING:  %15s %4d: " PROVIDE_SECOND_ARGUMENT2(BASE_FILE_NAME, __LINE__,__VA_ARGS__ ) )
//#define NOTICE(...)   SysLog( LOG_NOTICE,  "NOTICE:   %15s %4d: " PROVIDE_SECOND_ARGUMENT2(BASE_FILE_NAME, __LINE__,__VA_ARGS__ ) )
//#define INFO(...)     SysLog( LOG_INFO,    "INFO:     %15s %4d: " PROVIDE_SECOND_ARGUMENT2(BASE_FILE_NAME, __LINE__,__VA_ARGS__ ) )
//#define LOG(...) 	  SysLog( LOG_DEBUG,   "%s %4d: "             PROVIDE_SECOND_ARGUMENT2(BASE_FILE_NAME, __LINE__,__VA_ARGS__ ) )
#else
//EMERG means system is unstable thus will force a reboot!
#define EMERG(fmt, ...)    SysLog( LOG_EMERG,   PSTR("EMERG:    %15s %4d: " fmt), __file__(__FILE__), __LINE__, ## __VA_ARGS__ )
#define ALERT(fmt, ...)    SysLog( LOG_ALERT,   PSTR("ALERT:    %15s %4d: " fmt), __file__(__FILE__), __LINE__, ## __VA_ARGS__ )
#define CRITICAL(fmt, ...) SysLog( LOG_CRIT,    PSTR("CRITICAL: %15s %4d: " fmt), __file__(__FILE__), __LINE__, ## __VA_ARGS__ )
#define ERROR(fmt, ...)    SysLog( LOG_ERROR,   PSTR("ERROR:    %15s %4d: " fmt), __file__(__FILE__), __LINE__, ## __VA_ARGS__ )
#define WARNING(fmt, ...)  SysLog( LOG_WARNING, PSTR("WARNING:  %15s %4d: " fmt), __file__(__FILE__), __LINE__, ## __VA_ARGS__ )
#define NOTICE(fmt, ...)   SysLog( LOG_NOTICE,  PSTR("NOTICE:   %15s %4d: " fmt), __file__(__FILE__), __LINE__, ## __VA_ARGS__ )
#define INFO(fmt, ...)     SysLog( LOG_INFO,    PSTR("INFO:     %15s %4d: " fmt), __file__(__FILE__), __LINE__, ## __VA_ARGS__ )
#define LOG(fmt, ...)      SysLog( LOG_DEBUG,   PSTR("%15s %4d: " fmt), __file__(__FILE__), __LINE__, ## __VA_ARGS__ )

#endif
#else
#define EMERG(fmt, ...)
#define ALERT(fmt, ...)
#define CRITICAL(fmt, ...)
#define ERROR(fmt, ...)
#define WARNING(fmt, ...)
#define NOTICE(fmt, ...)
#define INFO(fmt, ...)
#define LOG(fmt, ...)

#endif //SYSLOG_DIABLE

//Note that if you are running debug code with JTAG the assert will stop
// However you might want to run release code with syslog enabled for testing
// where you want error logging, but asserts are not enabled.
// Thus this macro does error logging and an assert.
//This macro assumed to take a constant string as argument


//this can be enabled to log asserts to the history file, if you have code space to do it.
#ifdef ASSERT_HISTORY
#define ASSERT(x) {if(!(x)){ERROR(#x); HISTORY_ASSERT();} assert(x);}
#define ASSERT_ERROR(x) {HISTORY_ASSERT(); ERROR(x); ASSERT_FAIL(x);}
#else
#define ASSERT(x) {if(!(x)){ERROR(#x);} assert(x);}
#define ASSERT_ERROR(x) {ERROR(x); ASSERT_FAIL(x);}
#endif


void SysLogInit(Uart *ptrSerialObj, eLogLevel LevelToWrite);
int SysLogDisable(void);
int SysLogEnable(void);
int SysLogIsEnabled(void);

void SysLogDebug(bool x);

#ifdef __cplusplus
}
#endif // __cplusplus

#endif /* SYSLOG_H_ */
