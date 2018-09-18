/*
 * nzs_lcd.h
 *
 *  Created on: Dec 8, 2016
 *      Author: trampas
 *
 *
 *	Misfit Tech invests time and resources providing this open source code,
 *	please support Misfit Tech and open-source hardware by purchasing
 *	products from Misfit Tech, www.misifittech.net!
 *
 *	Written by Trampas Stern  for Misfit Tech.
 *	BSD license, check license.txt for more information
 *	All text above, must be included in any redistribution
 *********************************************************************/

#ifndef NZS_LCD_H_
#define NZS_LCD_H_

#include "Arduino.h"
#include "syslog.h"
#include "board.h"
#include "stepper_controller.h"

#include "Adafruit_GFX.h"
#include "Adafruit_SSD1306.h"
#include "gfxfont.h"


typedef struct {
	char str[15];
} options_t;

typedef struct {
	char str[15];

	//only one of the following should be not null
	int (*func)(int argc, char *argv[]);
	options_t *ptrOptions;

} menuItem_t;





class LCD
{
	private:
		bool displayEnabled;
		Adafruit_SSD1306 display;
		StepperCtrl *ptrStepperCtrl;
		menuItem_t *ptrMenu;
		int32_t menuIndex;
		bool menuActive;

		options_t *ptrOptions;
		int32_t optionIndex;

		int32_t buttonState;

		void updateLCD(void);
		void showMenu(void);
		void updateMenu(void);
		void showOptions(void);
	public:
		void forceMenuActive(void);
		void setMenu(menuItem_t *pMenu);
		void begin(StepperCtrl *ptrStepperCtrl); //sets up the LCD
		void process(void); //processes the LCD and updates as needed
		void showSplash(void);
		void lcdShow(const char *line1, const char *line2,const char *line3);


};


#endif /* NZS_LCD_H_ */
