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
#include <Arduino.h>
#include "syslog.h"
#include "as5047d.h"
#include "SPI.h"
#include <stdio.h>
#include "board.h"

#define AS5047D_CMD_NOP   (0x0000)
#define AS5047D_CMD_ERRFL (0x0001)
#define AS5047D_CMD_PROG  (0x0003)
#define AS5047D_CMD_DIAAGC (0x3FFC)
#define AS5047D_CMD_MAG    (0x3FFD)
#define AS5047D_CMD_ANGLEUNC (0x3FFE)
#define AS5047D_CMD_ANGLECOM (0x3FFF)


#define AS5048A_CMD_NOP   (0x0000)
#define AS5048A_CMD_ERRFL (0x0001)
#define AS5048A_CMD_PROG  (0x0003)
#define AS5048A_CMD_DIAAGC (0x3FFD)
#define AS5048A_CMD_MAG    (0x3FFE)
#define AS5048A_CMD_ANGLE  (0x3FFF)

#pragma GCC push_options
#pragma GCC optimize ("-Ofast")

static int getBit(int16_t data, int bit)
{
	return (data>>bit) & 0x01;
}

static int getParity(uint16_t data)
{
	int i,bits;
	data=data & 0x7FFF; //mask out upper bit

	//count number of bits, brute force
	bits=0;
	for(i=0; i<16; i++)
	{
		if (0 != (data & ((0x0001)<<i)))
		{
			bits++;
		}
	}
	return (bits & 0x01); //return 1 if odd
}

boolean AS5047D::begin(int csPin)
{
#ifdef PIN_AS5047D_PWR
	digitalWrite(PIN_AS5047D_PWR,HIGH);
#endif
	digitalWrite(PIN_AS5047D_CS,LOW); //pull CS LOW by default (chip powered off)
	digitalWrite(PIN_MOSI,LOW);
	digitalWrite(PIN_SCK,LOW);
	digitalWrite(PIN_MISO,LOW);
	pinMode(PIN_MISO,OUTPUT);
	delay(1000);


	digitalWrite(PIN_AS5047D_CS,HIGH); //pull CS high
#ifdef PIN_AS5047D_PWR
	digitalWrite(PIN_AS5047D_PWR,LOW);
#endif

	pinMode(PIN_MISO,INPUT);

	error=false;
	SPISettings settingsA(5000000, MSBFIRST, SPI_MODE1);             ///400000, MSBFIRST, SPI_MODE1);
	chipSelectPin=csPin;

	LOG("csPin is %d",csPin);
	pinMode(chipSelectPin,OUTPUT);
	digitalWrite(chipSelectPin,HIGH); //pull CS high by default
	delay(1);
	SPI.begin();    //AS5047D SPI uses mode=1 (CPOL=0, CPHA=1)
	LOG("Begin AS5047D...");

	SPI.beginTransaction(settingsA);
	SPI.transfer16(AS5047D_CMD_NOP);
	delay(10);

	//wait for the LF bit to be set
	uint16_t data=0,t0=100;
	while (getBit(data,8)==0 && t0>0)
	{
		delay(1);
		t0--;
		if (t0==0)
		{
			ERROR("LF bit not set");
			error=true;
			break;
			//return false;
		}
		LOG("AS5047D diag data is 0x%04X",data);
		data=readAddress(AS5047D_CMD_DIAAGC);
	}

	if (error)
	{
		error=false;
		uint16_t data=0,t0=100;
		while (getBit(data,8)==0 && t0>0)
		{
			delay(1);
			t0--;
			if (t0==0)
			{
				ERROR("AS5048A OCF bit not set");
				error=true;
				return false;
			}
			data=readAddress(AS5048A_CMD_DIAAGC);
			LOG("AS5048A diag data is 0x%04X",data);
		}
		as5047d=false;

	}


#ifdef NZS_AS5047_PIPELINE
	//read encoder a few times to flush the pipeline
	readEncoderAnglePipeLineRead();
	readEncoderAnglePipeLineRead();
#endif
	return true;
}


//read the encoders 
int16_t AS5047D::readAddress(uint16_t addr)
{
	uint16_t data;
	error=false;
	//make sure it is a read by setting bit 14
	addr=addr | 0x4000;

	//add the parity to the command
	if (1 == getParity(addr))
	{
		addr=(addr & 0x7FFF) | 0x8000; //add parity bit to make command even number of bits
	}

	digitalWrite(chipSelectPin, LOW);
	delayMicroseconds(1);
	//clock out the address to read
	SPI.transfer16(addr);
	digitalWrite(chipSelectPin, HIGH);
	delayMicroseconds(1);
	digitalWrite(chipSelectPin, LOW);
	//clock out zeros to read in the data from address
	data=SPI.transfer16(0x00);

	digitalWrite(chipSelectPin, HIGH);

	if (data & (1<<14))
	{
		//if bit 14 is set then we have an error
		ERROR("read command 0x%04X failed",addr);
		error=true;
		return -1;
	}

	if (data>>15 != getParity(data))
	{
		//parity did not match
		ERROR("read command parity error 0x%04X ",addr);
		error=true;
		return -2;
	}

	data=data & 0x3FFF; //mask off the error and parity bits

	return data;
}

//read the encoders 
int16_t AS5047D::readEncoderAngle(void)
{
	if (as5047d)
	{
		return readAddress(AS5047D_CMD_ANGLECOM);
	}
	return readAddress(AS5048A_CMD_ANGLE);
}

//pipelined read of the encoder angle used for high speed reads, but value is always one read behind
int16_t AS5047D::readEncoderAnglePipeLineRead(void)
{

	int16_t data;
	int error, t0=10;
	GPIO_LOW(chipSelectPin);//(chipSelectPin, LOW);
	//delayMicroseconds(1);
	do {

		// doing two 8 bit transfers is faster than one 16 bit
		data =(uint16_t)SPI.transfer(0xFF)<<8 | ((uint16_t)SPI.transfer(0xFF) & 0x0FF);
		t0--;
		if (t0<=0)
		{
			ERROR("AS5047D problem");
			break;
		}
		//data=SPI.transfer16(0xFFFF); //to speed things up we know the parity and address for the read
	}while(data & (1<<14)); //while error bit is set

	data=data & 0x3FFF; //mask off the error and parity bits
	GPIO_HIGH(chipSelectPin);
	//digitalWrite(chipSelectPin, HIGH);
	//TODO we really should check for errors and return a negative result or something
	return data;
}


void AS5047D::diagnostics(char *ptrStr)
{
	int16_t data;
	int m,d;

	if (as5047d)
	{

	data=readAddress(AS5047D_CMD_DIAAGC);

	if (NULL == ptrStr)
	{
		LOG("DIAAGC: 0x%04X", data);
		LOG("MAGL: %d", getBit(data,11));
		LOG("MAGH: %d", getBit(data,10));
		LOG("COF: %d", getBit(data,9));
		LOG("LFGL: %d", getBit(data,8));
		LOG("AGC: %d", data & 0x0FF);

		data=readAddress(AS5047D_CMD_MAG);
		LOG("CMAG: 0x%04X(%d)",data,data);

		data=readAddress(AS5047D_CMD_ANGLEUNC);
		m=(int)((float)data*AS5047D_DEGREES_PER_BIT);
		d=(int)((float)data*AS5047D_DEGREES_PER_BIT*100 -m*100);
		LOG("CORDICANG: 0x%04X(%d) %d.%02d deg(est)",data,data,m,d);

		data=readAddress(AS5047D_CMD_ANGLECOM);
		m=(int)((float)data*AS5047D_DEGREES_PER_BIT);
		d=(int)((float)data*AS5047D_DEGREES_PER_BIT*100 -m*100);
		LOG("DAECANG: 0x%04X(%d) %d.%02d deg(est)",data,data,m,d);
	}else
	{
		sprintf(ptrStr,"DIAAGC: 0x%04X\n\r", data);
		sprintf(ptrStr,"%sMAGL: %d\n\r", ptrStr,getBit(data,11));
		sprintf(ptrStr,"%sMAGH: %d\n\r", ptrStr,getBit(data,10));
		sprintf(ptrStr,"%sCOF: %d\n\r", ptrStr, getBit(data,9));
		sprintf(ptrStr,"%sLFGL: %d\n\r", ptrStr, getBit(data,8));
		sprintf(ptrStr,"%sAGC: %d\n\r", ptrStr,data & 0x0FF);

		data=readAddress(AS5047D_CMD_MAG);
		sprintf(ptrStr,"%sCMAG: 0x%04X(%d)\n\r", ptrStr,data,data);

		data=readAddress(AS5047D_CMD_ANGLEUNC);
		m=(int)((float)data*AS5047D_DEGREES_PER_BIT);
		d=(int)((float)data*AS5047D_DEGREES_PER_BIT*100 -m*100);
		sprintf(ptrStr,"%sCORDICANG: 0x%04X(%d) %d.%02d deg(est)\n\r", ptrStr,data,data,m,d);

		data=readAddress(AS5047D_CMD_ANGLECOM);
		m=(int)((float)data*AS5047D_DEGREES_PER_BIT);
		d=(int)((float)data*AS5047D_DEGREES_PER_BIT*100 -m*100);
		sprintf(ptrStr,"%sDAECANG: 0x%04X(%d) %d.%02d deg(est)\n\r", ptrStr,data,data,m,d);

	}
	} else
	{
		data=readAddress(AS5048A_CMD_DIAAGC);
		sprintf(ptrStr,"AS5048A DIAAGC: 0x%04X\n\r", data);
		data=readAddress(AS5048A_CMD_MAG);
		sprintf(ptrStr,"%sMagnitude: %d\n\r", ptrStr,data);
		data=readAddress(AS5048A_CMD_ANGLE);
		sprintf(ptrStr,"%sAngle: %d\n\r", ptrStr,data);
	}

}

#pragma GCC pop_options

