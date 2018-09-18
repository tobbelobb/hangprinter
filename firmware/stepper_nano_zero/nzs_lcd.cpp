/*
 * nzs_lcd.cpp
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

#include "nzs_lcd.h"
#include <string.h>
#include <stdio.h>
#include <Wire.h>


#ifndef DISABLE_LCD
void LCD::begin(StepperCtrl *ptrsCtrl)
{
#ifndef MECHADUINO_HARDWARE
	pinMode(PIN_SW1, INPUT_PULLUP);
	pinMode(PIN_SW3, INPUT_PULLUP);
	pinMode(PIN_SW4, INPUT_PULLUP);
#endif
	buttonState=0;

	//we need access to the stepper controller
	ptrStepperCtrl=ptrsCtrl; //save a pointer to the stepper controller


	ptrMenu=NULL;
	menuIndex=0;
	menuActive=false;
	optionIndex=0;
	ptrOptions=NULL;
	displayEnabled=true;

	//check that the SCL and SDA are pulled high
	pinMode(PIN_SDA, INPUT);
	pinMode(PIN_SCL, INPUT);
	if (digitalRead(PIN_SDA)==0)
	{
		//pin is not pulled up
		displayEnabled=false;
	}
	if (digitalRead(PIN_SCL)==0)
	{
		//pin is not pulled up
		displayEnabled=false;
	}

	if (displayEnabled)
	{
		displayEnabled=display.begin(SSD1306_SWITCHCAPVCC, 0x3C);
	}else
	{
		WARNING("SCL/SDA not pulled up");
	}
	if (false == displayEnabled)
	{
		WARNING("NO display found, LCD will not be used");
	}
	Wire.setClock(800000);

	//showSplash();

}


void __attribute__ ((optimize("Ofast"))) LCD::lcdShow(const char *line1, const char *line2,const char *line3)
{

	if (false == displayEnabled)
	{
		return;
	}
	display.clearDisplay();
	display.setTextSize(2);
	display.setTextColor(WHITE);
	display.setCursor(0,0);
	display.println(line1);
	display.setCursor(0,20);
	display.println(line2);
	display.setCursor(0,40);
	display.println(line3);
	display.display();

}

void LCD::showSplash(void)
{
	if (false == displayEnabled)
	{
		return;
	}
#ifdef A5995_DRIVER
	lcdShow("MisfitTech","NEMA 23", VERSION);
#else
	lcdShow("MisfitTech","NEMA 17", VERSION);
#endif
}


void LCD::setMenu(menuItem_t *pMenu)
{
	if (false == displayEnabled)
	{
		return;
	}
	ptrMenu=pMenu;
	menuIndex=0;
}


void LCD::showOptions(void)
{
	int32_t i,j;
	char str[3][26]={0};
	if (false == displayEnabled)
	{
		return;
	}

	i=optionIndex;
	j=0;
	while(strlen(ptrOptions[i].str)>0 && j<3)
	{
		if (i == optionIndex)
		{
			sprintf(str[j],"*%s",ptrOptions[i].str);
		}else
		{
			sprintf(str[j]," %s",ptrOptions[i].str);
		}
		j++;
		i++;
	}

	lcdShow(str[0], str[1], str[2]);

	return;
}


void __attribute__ ((optimize("Ofast"))) LCD::showMenu(void)
{
	int32_t i,j;
	char str[3][26]={0};
	if (false == displayEnabled)
	{
		return;
	}

	i=menuIndex;
	j=0;
	while(ptrMenu[i].func!=NULL && j<3)
	{
		if (i == menuIndex)
		{
			sprintf(str[j],"*%s",ptrMenu[i].str);
		}else
		{
			sprintf(str[j]," %s",ptrMenu[i].str);
		}
		j++;
		i++;
	}

	//show exit if there is room
	if (j<3)
	{
		if (j==0)
		{
			sprintf(str[j],"*Exit");
		}else
		{
			sprintf(str[j]," Exit");
		}
	}

	lcdShow(str[0], str[1], str[2]);


	return;
}


void __attribute__ ((optimize("Ofast"))) LCD::updateMenu(void)
{
	if (false == displayEnabled)
	{
		return;
	}

	if (ptrOptions != NULL)
	{
		showOptions();
	}else
	{
		showMenu();
	}

	//handle push buttons
	if (digitalRead(PIN_SW3)==0 && (buttonState & 0x02)==0)
	{
		buttonState |= 0x02;

		LOG("SW3 pressed");
		if (ptrMenu[menuIndex].func == NULL)
		{
			//exit pressed
			menuIndex=0; //reset menu index
			menuActive=false;
			return;
		}

		if (ptrMenu[menuIndex].func != NULL)
		{
			LOG("Calling function for %s",ptrMenu[menuIndex].str);
			if (ptrOptions != NULL)
			{
				char *ptrArgV[1];
				char str[25]={0};
				ptrArgV[0]=str;
				sprintf(str,"%d",optionIndex);
				LOG("Calling function for %s %s",ptrMenu[menuIndex].str,str);
				ptrMenu[menuIndex].func(1,ptrArgV);
				ptrOptions=NULL;
				optionIndex=0;
			}else
			{
				int i;
				i=ptrMenu[menuIndex].func(0,NULL);
				if (ptrMenu[menuIndex].ptrOptions != NULL)
				{
					LOG("displaying options for %s %d",ptrMenu[menuIndex].str,i);
					ptrOptions=ptrMenu[menuIndex].ptrOptions;
					optionIndex=i;
				}
			}

			return;
		}

	}
	if (digitalRead(PIN_SW1)==0 && (buttonState & 0x01)==0)
	{
		buttonState |= 0x01;
		LOG("SW1 pressed");
		if (ptrOptions != NULL)
		{
			optionIndex++;
			if (strlen(ptrOptions[optionIndex].str) == 0)
			{
				optionIndex=0;
			}
		} else
		{
			if (ptrMenu[menuIndex].func != NULL)
			{
				menuIndex++;
			} else
			{
				menuIndex=0;
			}
		}

	}

	if (digitalRead(PIN_SW1))
	{
		buttonState &= ~0x01;
	}

	if (digitalRead(PIN_SW3))
	{
		buttonState &= ~0x02;
	}
}

void LCD::forceMenuActive(void)
{

	menuActive=true;
}

void __attribute__((optimize("Ofast")))LCD::process(void)
{
	if (false == displayEnabled)
	{
		return;
	}

	if (false == menuActive || ptrMenu==NULL)
	{
		updateLCD();
	}else
	{
		updateMenu();
	}

	if (digitalRead(PIN_SW4)==0 && (buttonState & 0x04)==0)
	{
		buttonState |= 0x04;
		menuActive=!menuActive;
	}

	if (digitalRead(PIN_SW4))
	{
		buttonState &= ~0x04;
	}
}
#endif
/*
//does the LCD menu system
void StepperCtrl::menu(void)
{

	bool done=false;
	int menuItem=0;
	char str[100];
	int sw1State=0;
	int sw3State=0;

	pinMode(PIN_SW1, INPUT_PULLUP);
	pinMode(PIN_SW3, INPUT_PULLUP);
	pinMode(PIN_SW4, INPUT_PULLUP);


	while (!done)
	{
		display.clearDisplay();
		display.setTextSize(2);
		display.setTextColor(WHITE);

		if (menuItem==0)
		{
			sprintf(str,"*Run Cal");
			display.setCursor(0,0);
			display.println(str);
		}else
		{
			sprintf(str," Run Cal");
			display.setCursor(0,0);
			display.println(str);
		}

		if (menuItem==1)
		{
			sprintf(str,"*Check Cal");
			display.setCursor(0,20);
			display.println(str);
		}else
		{
			sprintf(str," Check Cal");
			display.setCursor(0,20);
			display.println(str);
		}

		if (menuItem==2)
		{
			sprintf(str,"*Exit");
			display.setCursor(0,40);
			display.println(str);
		}else
		{
			sprintf(str," Exit");
			display.setCursor(0,40);
			display.println(str);
		}

		display.display();

		if (sw1State==1)
		{
			while (digitalRead(PIN_SW1)==0);
			sw1State=0;
		}

		if (digitalRead(PIN_SW1)==0)
		{
			sw1State=1;
			menuItem=(menuItem+1)%3;
		}

		if (sw3State==1)
		{
			while (digitalRead(PIN_SW3)==0);
			sw3State=0;
		}

		if (digitalRead(PIN_SW3)==0)
		{
			sw3State=1;
			switch(menuItem)
			{
				case 0:
					display.clearDisplay();
					display.setTextSize(2);
					display.setTextColor(WHITE);
					display.setCursor(0,0);
					display.println("Running");
					display.setCursor(0,20);
					display.println("Cal");
					display.display();
					calibrateEncoder();
					break;
				case 1:
				{
					display.clearDisplay();
					display.setTextSize(2);
					display.setTextColor(WHITE);
					display.setCursor(0,0);
					display.println("Testing");
					display.setCursor(0,20);
					display.println("Cal");
					display.display();
					int32_t error,x,y,m;
					error=maxCalibrationError();
					x=(error*100 *360)/ANGLE_STEPS;
					m=x/100;
					y=abs(x-(m*100));
					display.clearDisplay();
					display.setTextSize(2);
					display.setTextColor(WHITE);
					display.setCursor(0,0);
					display.println("Error");

					sprintf(str, "%02d.%02d deg",m,y);
					display.setCursor(0,20);
					display.println(str);
					display.display();
					while (digitalRead(PIN_SW3));
					break;
				}
				case 2:
					return;
					break;

			}

		}

	}

}

 */

void LCD::updateLCD(void)
{
	if (false == displayEnabled)
	{
		return;
	}
	char str[3][25];
	static int highRPM=0;
	int32_t y,z,err;

	static int64_t lastAngle,deg;
	static int32_t RPM=0;
	static int32_t lasttime=0;

	bool state;
	static int32_t dt=40;
	static uint32_t t0=0;

	static bool rpmDone=false;

	if ((millis()-t0)>500)
	{

		int32_t x,d;

		//do first half of RPM measurement
		if (!rpmDone)
		{
			//LOG("loop time is %dus",ptrStepperCtrl->getLoopTime());
			lastAngle=ptrStepperCtrl->getCurrentAngle();
			lasttime=millis();
			rpmDone=true;
			return;
		}

		//do the second half of rpm measurement and update LCD.
		if (rpmDone && (millis()-lasttime)>(dt))
		{
			rpmDone=false;
			deg=ptrStepperCtrl->getCurrentAngle();
			y=millis()-lasttime;
			err=ptrStepperCtrl->getLoopError();

			t0=millis();
			d=(int64_t)(lastAngle-deg);

			d=abs(d);

			x=0;
			if (d>0)
			{
				x=((int64_t)d*(60*1000UL))/((int64_t)y * ANGLE_STEPS);
			}

			lastAngle=deg;
			RPM=(int32_t)x; //(7*RPM+x)/8; //average RPMs
			if (RPM>500)
			{
				dt=10;
			}
			if (RPM<100)
			{
				dt=100;
			}
			str[0][0]='\0';
			//LOG("RPMs is %d, %d, %d",(int32_t)x,(int32_t)d,(int32_t)y);
			switch(ptrStepperCtrl->getControlMode())
			{
				case CTRL_SIMPLE:
					sprintf(str[0], "%dRPM simp",RPM);
					break;

				case CTRL_TORQUE:
					sprintf(str[0], "%dRPM torque",RPM);
					break;

				case CTRL_POS_PID:
					sprintf(str[0], "%dRPM pPID",RPM);
					break;

				case CTRL_POS_VELOCITY_PID:
					sprintf(str[0], "%dRPM vPID",RPM);
					break;

				case CTRL_OPEN:
					sprintf(str[0], "%dRPM open",RPM);
					break;
				case CTRL_OFF:
					sprintf(str[0], "%dRPM off",RPM);
					break;
				default:
					sprintf(str[0], "error %u",ptrStepperCtrl->getControlMode());
					break;

			}


			err=(err*360*100)/(int32_t)ANGLE_STEPS;
			//LOG("error is %d %d %d",err,(int32_t)ptrStepperCtrl->getCurrentLocation(),(int32_t)ptrStepperCtrl->getDesiredLocation());
			z=(err)/100;
			y=abs(err-(z*100));

			sprintf(str[1],"%01d.%02d err", z,y);


			deg=ptrStepperCtrl->getDesiredAngle();

#ifndef NZS_LCD_ABSOULTE_ANGLE
			deg=deg & ANGLE_MAX; //limit to 360 degrees
#endif

			deg=(deg*360*10)/(int32_t)ANGLE_STEPS;
			int K=0;
			if (abs(deg)>9999)
			{
				K=1;
				deg=deg/1000;
			}

			x=(deg)/10;
			y=abs(deg-(x*10));

			if (K==1)
			{
				sprintf(str[2],"%03d.%01uKdeg", x,y);
			}else
			{
				sprintf(str[2],"%03d.%01udeg", x,y);
			}
			str[0][10]='\0';
			str[1][10]='\0';
			str[2][10]='\0';
			lcdShow(str[0],str[1],str[2]);
		}
	}
}


