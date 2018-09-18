#ifndef HP_I2C_H_
#define HP_I2C_H_

#include "stepper_controller.h"
#include "Arduino.h"
#include "nzs.h"
#include "commands.h"
#include "board.h"

#if defined(HP_I2C) && !defined(DISABLE_LCD)
#error "Can't have HP_I2C and LCD enabled at the same time"
#endif

#define I2C_ID 0x0b

void handle_i2c_cmd(int numBytes);
void setup_HP_I2C();

#endif /* HP_I2C_H */
