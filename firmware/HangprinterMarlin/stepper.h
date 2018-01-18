/*
   stepper.h - stepper motor driver: executes motion plans of planner.c using the stepper motors
   Part of Grbl

   Copyright (c) 2009-2011 Simen Svale Skogsrud

   Grbl is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   Grbl is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with Grbl.  If not, see <http://www.gnu.org/licenses/>.
   */

#ifndef stepper_h
#define stepper_h

#include "planner.h"

#if defined(HAVE_TMC2130)
  #include "Configuration.h"
  #include <SPI.h>
  #include <TMC2130Stepper.h>
  void tmc2130_init(TMC2130Stepper &st, const uint16_t microsteps, const uint16_t maxcurrent);
  extern TMC2130Stepper stepperA;
  extern TMC2130Stepper stepperB;
  extern TMC2130Stepper stepperC;
  extern TMC2130Stepper stepperD;
  extern TMC2130Stepper stepperE;
#endif // defined(HAVE_TMC2130)

#define WRITE_E_STEP(v) WRITE(E0_STEP_PIN, v)
#define NORM_E_DIR() WRITE(E0_DIR_PIN, !INVERT_E0_DIR)
#define REV_E_DIR() WRITE(E0_DIR_PIN, INVERT_E0_DIR)

#ifdef ABORT_ON_ENDSTOP_HIT_FEATURE_ENABLED
extern bool abort_on_endstop_hit;
#endif

// Initialize and start the stepper motor subsystem
void st_init();

// Block until all buffered steps are executed
void st_synchronize();

// Set current position in steps
void st_set_position(const long &a, const long &b, const long &c, const long &d, const long &e);
void st_set_e_position(const long &e);

// Get current position in steps
long st_get_position(uint8_t axis);

// The stepper subsystem goes to sleep when it runs out of things to execute. Call this
// to notify the subsystem that it is time to go to work.
void st_wake_up();


void checkHitEndstops(); //call from somewhere to create an serial error message with the locations the endstops where hit, in case they were triggered
void endstops_hit_on_purpose(); //avoid creation of the message, i.e. after homing and before a routine call of checkHitEndstops();

void enable_endstops(bool check); // Enable/disable endstop checking

void checkStepperErrors(); //Print errors detected by the stepper

void finishAndDisableSteppers();

extern block_t *current_block;  // A pointer to the block currently being traced

void quickStop();

void microstep_ms(uint8_t driver, int8_t ms1, int8_t ms2);
void microstep_mode(uint8_t driver, uint8_t stepping);
void microstep_init();
void microstep_readings();

#endif
