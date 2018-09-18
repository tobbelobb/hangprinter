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
#include "calibration.h"
#include "Flash.h"
#include "nonvolatile.h"
#include "board.h" //for divide with rounding macro
#include "utils.h"


static uint16_t getTableIndex(uint16_t value)
{
	int32_t x;

	x=((int32_t)value*CALIBRATION_TABLE_SIZE)/CALIBRATION_STEPS; //the divide is a floor not a round which is what we want
	return (uint16_t)x;

}
static uint16_t interp(Angle x1, Angle y1, Angle x2, Angle y2, Angle x)
{
	int32_t dx,dy,dx2,y;
	dx=x2-x1;
	dy=y2-y1;
	dx2=x-x1;
	y=(int32_t)y1+DIVIDE_WITH_ROUND((dx2*dy),dx);
	if (y<0)
	{
		y=y+CALIBRATION_STEPS;
	}
	return (uint16_t)y;
}

static void printData(int32_t *data, int32_t n)
{
	int32_t i;
	Serial.print("\n\r");
	for (i=0; i<n; i++)
	{
		Serial.print(data[i]);
		if (i!=(n-1))
		{
			Serial.print(",");
		}
	}
	Serial.print("\n\r");
}
bool CalibrationTable::updateTableValue(int32_t index, int32_t value)
{

	table[index].value=value;
	table[index].error=CALIBRATION_STEPS/CALIBRATION_TABLE_SIZE; //or error is roughly like variance, so set it to span to next calibration value.
	return true;

}
void CalibrationTable::printCalTable(void)
{
	int i;
	Serial.print("\n\r");
	for (i=0; i<CALIBRATION_TABLE_SIZE; i++)
	{
		Serial.print((uint16_t)table[i].value);
		Serial.print(",");
	}
	Serial.print("\n\r");
}

Angle CalibrationTable::fastReverseLookup(Angle encoderAngle)
{
#ifdef NZS_FAST_CAL
	//assume calibration is good
	if (fastCalVaild)
	{
		uint16_t x;
		x=((uint16_t)encoderAngle)/4;  //we only have 16384 values in table

		return (Angle)NVM->FastCal.angle[x];
	}else
	{
		return reverseLookup(encoderAngle);
	}
#else
	return reverseLookup(encoderAngle)
#endif
}

Angle CalibrationTable::reverseLookup(Angle encoderAngle)
{

	int32_t i=0;
	int32_t a1,a2;
	int32_t x;
	int16_t y;
	int32_t min,max;
	min=(uint16_t)table[0].value;
	max=min;



	for (i=0; i<CALIBRATION_TABLE_SIZE; i++)
	{
		x=(uint16_t)table[i].value;
		if (x<min)
		{
			min=x;
		}
		if (x>max)
		{
			max=x;
		}
	}


	x=(uint16_t)encoderAngle;
	if (x<min)
	{
		x=x+CALIBRATION_STEPS;
	}

	i=0;

	while (i<CALIBRATION_TABLE_SIZE)
	{
		a1=(uint16_t)table[i].value;

		//handle index wrap around
		if (i==(CALIBRATION_TABLE_SIZE-1))
		{
			a2=(uint16_t)table[0].value;
		}else
		{
			a2=(uint16_t)table[i+1].value;
		}

		//wrap
		if (abs(a1-a2)>CALIBRATION_STEPS/2)
		{
			if (a1<a2)
			{
				a1=a1+CALIBRATION_STEPS;
			}else
			{
				a2=a2+CALIBRATION_STEPS;
			}

			//LOG("xxxx %d %d %d",a1,a2,x);
		}

		//finding matching location
		if ( (x>=a1 && x<=a2) ||
				(x>=a2 && x<=a1) )
		{
			//LOG("%d", i);
			// inerpolate results and return
			//LOG("%d %d %d",a1,a2,x);
			//LOG("%d,%d",(i*CALIBRATION_MAX)/CALIBRATION_TABLE_SIZE,((i+2)*CALIBRATION_MAX)/CALIBRATION_TABLE_SIZE);

			y=interp(a1, DIVIDE_WITH_ROUND((i*CALIBRATION_STEPS),CALIBRATION_TABLE_SIZE), a2, DIVIDE_WITH_ROUND( ((i+1)*CALIBRATION_STEPS),CALIBRATION_TABLE_SIZE), x);

			return y;
		}
		i++;
	}
	ERROR("WE did some thing wrong");




}


void CalibrationTable::smoothTable(void)
{
	uint16_t b[]={1,2,4,5,4,2,1};
	uint16_t sum_b=19;  //sum of b filter

	int32_t data[CALIBRATION_TABLE_SIZE];
	int32_t table2[CALIBRATION_TABLE_SIZE];

	int32_t i;
	int32_t offset=0;
	int32_t startNum;

	//first lets handle the wrap around in the table
	for (i=0; i<CALIBRATION_TABLE_SIZE; i++)
	{
		if (i>0 && offset==0)
		{
			if(((uint16_t)table[i-1].value-(uint16_t)table[i].value) <-32768)
			{
				offset=-65536;
			}

			if (((uint16_t)table[i-1].value-(uint16_t)table[i].value) > 32768)
			{
				offset=65536;
			}
		}
		table2[i]=(int32_t)((uint16_t)table[i].value)+offset;
	}

	//Serial.print("after wrap\n\r");
	//printData(table2,CALIBRATION_TABLE_SIZE);

	//remove the starting offset and compensate table for index
	startNum=table2[0];
	for (i=0; i<CALIBRATION_TABLE_SIZE; i++)
	{
		table2[i]=table2[i]-startNum - (i*65536)/CALIBRATION_TABLE_SIZE;
	}

	//Serial.print("after phase comp\n\r");
	//printData(table2,CALIBRATION_TABLE_SIZE);

	//filter the data
	for (i=0; i<CALIBRATION_TABLE_SIZE; i++)
	{
		int j,ix,ib;;
		int32_t sum=0;

		ib=0;
		for (j=i-3; j<i+4; j++)
		{
			ix=j;
			if (ix<0)
			{
				ix=ix+CALIBRATION_TABLE_SIZE;
			}
			if (ix>=CALIBRATION_TABLE_SIZE)
			{
				ix=ix-CALIBRATION_TABLE_SIZE;
			}
			if (i==0)
			{
				LOG("index %d",ix);
			}
			sum=sum+table2[ix]*b[ib];
			ib++;
		}
		sum=DIVIDE_WITH_ROUND(sum,sum_b);
		data[i]=sum;
	}

	//Serial.print("after filter\n\r");
	//printData(data,CALIBRATION_TABLE_SIZE);

	//add in offset and the phase compenstation
	for (i=0; i<CALIBRATION_TABLE_SIZE; i++)
	{
		data[i]=data[i]+startNum + (i*65536)/CALIBRATION_TABLE_SIZE;
	}

	//Serial.print("after phase comp added\n\r");
	//printData(data,CALIBRATION_TABLE_SIZE);

	//remove the uint16_t wrap
	for (i=0; i<CALIBRATION_TABLE_SIZE; i++)
	{
		if (data[i]>=65536)
		{
			data[i]=data[i]-65536;
		}
	}

	//Serial.print("after wrap added\n\r");
	//printData(data,CALIBRATION_TABLE_SIZE);

	//save new table
	for (i=0; i<CALIBRATION_TABLE_SIZE; i++)
	{
		table[i].value=data[i];
	}
}

void CalibrationTable::saveToFlash(void)
{
	FlashCalData_t data;
	int i;
	for (i=0; i<CALIBRATION_TABLE_SIZE; i++ )
	{
		data.table[i]=(uint16_t)table[i].value;
	}
	data.status=true;

	LOG("Writting Calbiration to Flash");
	nvmWriteCalTable(&data,sizeof(data));

	memset(&data,0,sizeof(data));
	memcpy(&data, &NVM->CalibrationTable,sizeof(data));
	createFastCal();

	LOG("after writting status is %d",data.status);
	loadFromFlash();

}

void CalibrationTable::loadFromFlash(void)
{
	FlashCalData_t data;
	int i;
	LOG("Reading Calbiration to Flash");
	memcpy(&data, &NVM->CalibrationTable,sizeof(data));
	for (i=0; i<CALIBRATION_TABLE_SIZE; i++ )
	{
		table[i].value=Angle(data.table[i]);
		table[i].error=CALIBRATION_MIN_ERROR;
	}
	data.status=true;
}

bool CalibrationTable::flashGood(void)
{
	LOG("calibration table status is: %d",NVM->CalibrationTable.status);
	return NVM->CalibrationTable.status;
}


void CalibrationTable::createFastCal(void)
{
#ifdef NZS_FAST_CAL
	int32_t i;
	uint16_t cs=0;
	uint16_t data[256];
	int32_t j;
	j=0;
	cs=0;
	LOG("setting fast calibration");
	for (i=0; i<16384; i++)
	{

		uint16_t x;
		x=reverseLookup(i*4);
		data[j]=x;
		j++;
		if (j>=256)
		{
			flashWrite(&NVM->FastCal.angle[i-255],data,256*sizeof(uint16_t));
			//LOG("Wrote fastcal at index %d-%d", i-255, i);
			j=0;
		}
		cs+=x;
	}
	//update the checksum
	flashWrite(&NVM->FastCal.checkSum,&cs,sizeof(uint16_t));
	fastCalVaild=true;

	//this is a quick test
	/*
			for (i=0; i<16384; i++)
			{
				LOG("fast Cal %d,%d,%d",i,NVM->FastCal.angle[i],(uint32_t)reverseLookup(i*4));
			}
	 */
#endif
}
void CalibrationTable::updateFastCal(void)
{
#ifdef NZS_FAST_CAL
	int32_t i;
	uint16_t cs=0;
	uint16_t data[256];
	int32_t j;
	bool NonZero=false;
	for (i=0; i<16384; i++)
	{
		cs+=NVM->FastCal.angle[i];
		if (cs != 0)
		{
			NonZero=true;
		}
	}
	if (cs!=NVM->FastCal.checkSum || NonZero==false)
	{
		createFastCal();
	}
	else
	{
		LOG("fast cal is valid");
		fastCalVaild=true;
	}
#endif
}

void CalibrationTable::init(void)
{
	int i;

	if (true == flashGood())
	{
		loadFromFlash();
		updateFastCal();
	}else
	{
		for (i=0; i<CALIBRATION_TABLE_SIZE; i++)
		{
			table[i].value=0;
			table[i].error=CALIBRATION_ERROR_NOT_SET;
		}
	}
	return;
}

#if 0 
//This code was removed because with micro stepping we can not assume
// our actualAngle is correct. 
void CalibrationTable::updateTable(Angle actualAngle, Angle encoderValue);
{
	static int32_t lastAngle=-1;
	static uint16_t lastEncoderValue=0;

	if (last != -1)
	{
		int32_t dist;

		//hopefull we can use the current point and last point to interpolate and set a value or two in table.
		dist=abs((int32_t)actualAngle-(int32_t)lastAngle); //distance between the two angles

		//since our angles wrap the shortest distance will be one less than 32768
		if (dist>CALIBRATION_STEPS/2)
		{
			dist=dist-CALIBRATION_STEPS;
		}

		//if our distance is larger than size between calibration points in table we will ignore this sample
		if (dist>CALIBRATION_STEPS/CALIBRATION_TABLE_SIZE)
		{
			//spans two or more table calibration points for this implementation we will not use
			lastIndex=(int32_t)index;
			lastValue=value;
			return;
		}

		//now lets see if the values are above and below a table calibration point
		dist= abs(getTableIndex(lastAngle)-getTableIndex(actualAngle));
		if (dist != 0) //if the two indexs into table are not the same it spans a calibration point in table.
		{
			//the two span a set calibation table point.
			uint16_t newValue;
			newValue=interp(lastAngle, lastEncoderValue, actualAngle, encoderValue, getTableIndex(actualAngle)*(CALIBRATION_STEPS/CALIBRATION_TABLE_SIZE))
    						  //this new value is our best guess as to the correct calibration value.
    						  updateTableValue(getTableIndex(actualAngle),newValue);
		} else
		{
			//we should calibate the table value for the point the closest
		}





	}
	lastAngle=(int32_t)actualAngle;
	lastEncoderValue=encoderValue;

}
#endif

//when we are microstepping and are in between steps the probability the stepper motor did not move
// is high. That is the actualAngle will be correct but the encoderValue will be behind due to not having enough torque to move motor. 
// Therefore we only want to update the calibration on whole steps where we have highest probability of things being correct. 
void CalibrationTable::updateTable(Angle actualAngle, Angle encoderValue)
{
	int32_t dist, index;
	Angle tableAngle;

	index = getTableIndex((uint32_t)actualAngle+CALIBRATION_STEPS/CALIBRATION_TABLE_SIZE/2);  //add half of distance to next entry to round to closest table index

	tableAngle=(index*CALIBRATION_STEPS)/CALIBRATION_TABLE_SIZE; //calculate the angle for this index

	dist=tableAngle-actualAngle;  //distance to calibration table angle

	//LOG("Dist is %d",dist);
	if (abs(dist)<CALIBRATION_MIN_ERROR) //if we are with in our minimal error we can calibrate
	{
		updateTableValue(index,(int32_t)encoderValue);
	}
}

bool CalibrationTable::calValid(void)
{
	uint32_t i;
	for (i=0; i<CALIBRATION_TABLE_SIZE; i++)
	{
		if (table[i].error == CALIBRATION_ERROR_NOT_SET)
		{
			return false;
		}
	}
	if (false == flashGood())
	{
		saveToFlash();
	}
	return true;
}
//We want to linearly interpolate between calibration table angle
int CalibrationTable::getValue(Angle actualAngle, CalData_t *ptrData)
{
	int32_t indexLow,indexHigh;
	int32_t angleLow,angleHigh;
	uint16_t value;
	int32_t y1,y2;
	int16_t err;

	indexLow=getTableIndex((uint16_t)actualAngle);
	// LOG("index %d, actual %u",indexLow, (uint16_t)actualAngle);
	indexHigh=indexLow+1;

	angleLow=(indexLow*CALIBRATION_STEPS)/CALIBRATION_TABLE_SIZE;
	angleHigh=(indexHigh*CALIBRATION_STEPS)/CALIBRATION_TABLE_SIZE;

	if (indexHigh>=CALIBRATION_TABLE_SIZE)
	{
		indexHigh -= CALIBRATION_TABLE_SIZE;
	}

	//LOG("AngleLow %d, AngleHigh %d",angleLow,angleHigh);
	//LOG("TableLow %u, TableHigh %d",(uint16_t)table[indexLow].value,(uint16_t)table[indexHigh].value);
	y1=table[indexLow].value;
	y2=table[indexHigh].value;

	//handle the wrap condition
	if (abs(y2-y1)>CALIBRATION_STEPS/2)
	{
		if (y2<y1)
		{
			y2=y2+CALIBRATION_STEPS;
		}else
		{
			y1=y1+CALIBRATION_STEPS;
		}
	}

	value=interp(angleLow, y1, angleHigh, y2,actualAngle);

	//handle the wrap condition
	if (value>=CALIBRATION_STEPS)
	{
		value=value-CALIBRATION_STEPS;
	}

	err=table[indexLow].error;
	if (table[indexHigh].error > err)
	{
		err=table[indexHigh].error;
	}

	if (table[indexLow].error == CALIBRATION_ERROR_NOT_SET ||
			table[indexHigh].error == CALIBRATION_ERROR_NOT_SET)
	{
		err=CALIBRATION_ERROR_NOT_SET;
	}
	ptrData->value=value;
	ptrData->error=err;

	return 0;

}

Angle CalibrationTable::getCal(Angle actualAngle)
{
	CalData_t data;
	getValue(actualAngle, &data);
	return data.value;
}


