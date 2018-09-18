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
#ifndef __CALIBRAITON_H__
#define __CALIBRAITON_H__

#include <Arduino.h>
#include "syslog.h"
#include "angle.h"


//this file implements a table that is linearly interpolated circular calibration table
// it is assumed the data wraps around, ie you interpolated 65536==0
//we want this to be "whole" steps, for 1.8 degree motors this should be 200.
// 200 will work for 0.9 degree too, but could be 400. However 400 is not good for 1.8 degree motors
#define CALIBRATION_TABLE_SIZE (200)  

#define CALIBRATION_STEPS ((uint32_t)ANGLE_STEPS) // this is one rotation ie 0-65535 aka 65536 steps is 0-360 degrees

#define CALIBRATION_ERROR_NOT_SET (-1) //indicated that the calibration value is not set. 

#define CALIBRATION_UPDATE_RATE (32) //number of samples to keep 1 pole running average
#define CALIBRATION_MIN_ERROR (4)  //the minimal expected error on our calibration 4 ~=+/0.2 degrees 


typedef struct {
	uint16_t table[CALIBRATION_TABLE_SIZE];
	bool status;
} FlashCalData_t;





typedef struct {
  Angle value;  //cal value 
  int16_t error; //error assuming it is constantly updated
} CalData_t;

class CalibrationTable
{
  private:
    CalData_t table[CALIBRATION_TABLE_SIZE];

    bool fastCalVaild=false;
    void loadFromFlash(void);
    bool flashGood(void); //returns true if the flash copy of calibration is valid

    void updateFastCal(void);
    void createFastCal(void);

  public:
    void init(void);
    void saveToFlash(void); //saves the calibration to flash
    bool updateTableValue(int32_t index, int32_t value);
    void updateTable(Angle actualAngle, Angle encoderValue);
    int getValue(Angle actualAngle, CalData_t *ptrData); 
    Angle getCal(Angle actualAngle);
    bool calValid(void);
    Angle reverseLookup(Angle encoderAngle); //this turns encoder angle into real angle
    void printCalTable(void);
     void smoothTable(void);

    Angle fastReverseLookup(Angle encoderAngle);
};




#endif //__CALIBRAITON_H__
