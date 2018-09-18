#ifndef __COMMANDS_H__
#define __COMMANDS_H__
#include <Arduino.h>
#include "stepper_controller.h"
#include "nzs.h"

extern StepperCtrl stepperCtrl;
extern eepromData_t PowerupEEPROM;

void commandsInit(void);
int commandsProcess(void);

#endif //__COMMANDS_H__
