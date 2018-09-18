#ifndef __STEPPIN_H___
#define __STEPPIN_H___
#include "board.h"

void stepPinSetup(void); //setup step pin

int64_t getSteps(void); //returns the number of steps changed since last call


#endif // __STEPPIN_H___
