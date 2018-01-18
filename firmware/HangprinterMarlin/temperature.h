/*
  temperature.h - temperature controller
  Part of Marlin

  Copyright (c) 2011 Erik van der Zalm

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

#ifndef temperature_h
#define temperature_h

#include "Marlin.h"
#include "planner.h"
#ifdef PID_ADD_EXTRUSION_RATE
  #include "stepper.h"
#endif

// public functions
void tp_init();  //initialize the heating
void manage_heater(); //it is critical that this is called periodically.

// low level conversion routines
// do not use these routines and variables outside of temperature.cpp
extern int target_temperature[1];
extern float current_temperature[1];
extern int target_temperature_bed;
extern float current_temperature_bed;

#if defined(CONTROLLERFAN_PIN) && CONTROLLERFAN_PIN > -1
  extern unsigned char soft_pwm_bed;
#endif

#ifdef PIDTEMP
  extern float Kp, Ki, Kd, Kc; // one param per extruder - saves 20 or 36 bytes of ram (inc array pointer)
  float scalePID_i(float i);
  float scalePID_d(float d);
  float unscalePID_i(float i);
  float unscalePID_d(float d);
#endif

//high level conversion routines, for use outside of temperature.cpp
//inline so that there is no performance decrease.
//deg=degreeCelsius

FORCE_INLINE float degHotend(uint8_t extruder) {
  return current_temperature[extruder];
};

FORCE_INLINE float degBed() {
  return current_temperature_bed;
};

FORCE_INLINE float degTargetHotend(uint8_t extruder) {
  return target_temperature[extruder];
};

FORCE_INLINE float degTargetBed() {
  return target_temperature_bed;
};

FORCE_INLINE void setTargetHotend(const float &celsius, uint8_t extruder) {
  target_temperature[extruder] = celsius;
};

FORCE_INLINE void setTargetBed(const float &celsius) {
  target_temperature_bed = celsius;
};

FORCE_INLINE bool isHeatingHotend(uint8_t extruder){
  return target_temperature[extruder] > current_temperature[extruder];
};

FORCE_INLINE bool isHeatingBed() {
  return target_temperature_bed > current_temperature_bed;
};

FORCE_INLINE bool isCoolingHotend(uint8_t extruder) {
  return target_temperature[extruder] < current_temperature[extruder];
};

FORCE_INLINE bool isCoolingBed() {
  return target_temperature_bed < current_temperature_bed;
};

#define degHotend0() degHotend(0)
#define degTargetHotend0() degTargetHotend(0)
#define setTargetHotend0(_celsius) setTargetHotend((_celsius), 0)
#define isHeatingHotend0() isHeatingHotend(0)
#define isCoolingHotend0() isCoolingHotend(0)

int getHeaterPower(int heater);
void disable_heater();
void setWatch();
void updatePID();

FORCE_INLINE void autotempShutdown(){
#ifdef AUTOTEMP
  if(autotemp_enabled)
  {
    autotemp_enabled=false;
    if(degTargetHotend(active_extruder)>autotemp_min)
      setTargetHotend(0,active_extruder);
  }
#endif
}

void PID_autotune(float temp, int extruder, int ncycles);

void setExtruderAutoFanState(int pin, bool state);
void checkExtruderAutoFans();

#endif
