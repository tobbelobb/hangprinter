/*
  temperature.c - temperature control
  Part of Marlin

 Copyright (C) 2011 Camiel Gubbels / Erik van der Zalm

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
 This firmware is a mashup between Sprinter and grbl.
  (https://github.com/kliment/Sprinter)
  (https://github.com/simen/grbl/tree)

 It has preliminary support for Matthew Roberts advance algorithm
    http://reprap.org/pipermail/reprap-dev/2011-May/003323.html

 */


#include "Marlin.h"
#include "Configuration.h"
#include "temperature.h"

//#include "Sd2PinMap.h"
// We get PID_MAX was not declared in this scope...
//#include "ConfigurationStore.h"
//#include "Configuration_adv.h"


//===========================================================================
//============================= public variables ============================
//===========================================================================

// Sampling period of the temperature routine
#ifdef PID_dT
  #undef PID_dT
#endif
#define PID_dT ((OVERSAMPLENR * 12.0)/(F_CPU / 64.0 / 256.0))

int target_temperature[1] = { 0 };
int target_temperature_bed = 0;
int current_temperature_raw[1] = { 0 };
float current_temperature[1] = { 0.0 };
int current_temperature_bed_raw = 0;
float current_temperature_bed = 0.0;

#if defined(THERMAL_RUNAWAY_PROTECTION_PERIOD) && THERMAL_RUNAWAY_PROTECTION_PERIOD > 0
  void thermal_runaway_protection(int *state, unsigned long *timer, float temperature, float target_temperature, int heater_id, int period_seconds, int hysteresis_degc);
  static int thermal_runaway_state_machine[4]; // = {0,0,0,0};
  static unsigned long thermal_runaway_timer[4]; // = {0,0,0,0};
  static bool thermal_runaway = false;
#endif


#ifdef PIDTEMPBED
  float bedKp=DEFAULT_bedKp;
  float bedKi=(DEFAULT_bedKi*PID_dT);
  float bedKd=(DEFAULT_bedKd/PID_dT);
#endif //PIDTEMPBED

#ifdef FAN_SOFT_PWM
  unsigned char fanSpeedSoftPwm;
#endif

unsigned char soft_pwm_bed;

//===========================================================================
//=============================private variables============================
//===========================================================================
static volatile bool temp_meas_ready = false;

#ifdef PIDTEMP
  //static cannot be external:
  static float temp_iState[1] = { 0 };
  static float temp_dState[1] = { 0 };
  static float pTerm[1];
  static float iTerm[1];
  static float dTerm[1];
  //int output;
  static float pid_error[1];
  static float temp_iState_min[1];
  static float temp_iState_max[1];
  static bool pid_reset[1];
#endif //PIDTEMP
#ifdef PIDTEMPBED
  //static cannot be external:
  static float temp_iState_bed = { 0 };
  static float temp_dState_bed = { 0 };
  static float pTerm_bed;
  static float iTerm_bed;
  static float dTerm_bed;
  //int output;
  static float pid_error_bed;
  static float temp_iState_min_bed;
  static float temp_iState_max_bed;
#endif //PIDTEMPBED
  static unsigned char soft_pwm[1];

#ifdef FAN_SOFT_PWM
  static unsigned char soft_pwm_fan;
#endif
#if (defined(EXTRUDER_0_AUTO_FAN_PIN) && EXTRUDER_0_AUTO_FAN_PIN > -1) || \
    (defined(EXTRUDER_1_AUTO_FAN_PIN) && EXTRUDER_1_AUTO_FAN_PIN > -1) || \
    (defined(EXTRUDER_2_AUTO_FAN_PIN) && EXTRUDER_2_AUTO_FAN_PIN > -1)
  static unsigned long extruder_autofan_last_check;
#endif

#ifdef PIDTEMP
  float Kp = DEFAULT_Kp;
  float Ki = DEFAULT_Ki * PID_dT;
  float Kd = DEFAULT_Kd / PID_dT;
  #ifdef PID_ADD_EXTRUSION_RATE
    float Kc = DEFAULT_Kc;
  #endif
#endif

// Init min and max temp with extreme values to prevent false errors during startup
static int minttemp_raw[1] = { HEATER_0_RAW_LO_TEMP };
static int maxttemp_raw[1] = { HEATER_0_RAW_HI_TEMP };
static int minttemp[1] = { 0 };
static int maxttemp[1] = { 16383 };
//static int bed_minttemp_raw = HEATER_BED_RAW_LO_TEMP; /* No bed mintemp error implemented?!? */
#ifdef BED_MAXTEMP
  static int bed_maxttemp_raw = HEATER_BED_RAW_HI_TEMP;
#endif

static void *heater_ttbl_map[1] = { (void *)HEATER_0_TEMPTABLE };
static uint8_t heater_ttbllen_map[1] = { HEATER_0_TEMPTABLE_LEN };

static float analog2temp(int raw, uint8_t e);
static void updateTemperaturesFromRawValues();

#ifdef WATCH_TEMP_PERIOD
  int watch_start_temp[1] = { 0 };
  unsigned long watchmillis[1] = { 0 };
#endif //WATCH_TEMP_PERIOD

#ifndef SOFT_PWM_SCALE
  #define SOFT_PWM_SCALE 0
#endif


#ifdef HEATER_0_USES_MAX6675
  static int read_max6675();
#endif

//===========================================================================
//=============================   functions      ============================
//===========================================================================

void PID_autotune(float temp, int extruder, int ncycles){
  float input = 0.0;
  int cycles=0;
  bool heating = true;

  unsigned long temp_millis = millis();
  unsigned long t1=temp_millis;
  unsigned long t2=temp_millis;
  long t_high = 0;
  long t_low = 0;

  long bias, d;
  float Ku, Tu;
  float Kp, Ki, Kd;
  float max = 0, min = 10000;

  if ((extruder >= 1)
  #if (TEMP_BED_PIN <= -1)
       ||(extruder < 0)
  #endif
       ){
          SERIAL_ECHOLN("PID Autotune failed. Bad extruder number.");
          return;
        }

  SERIAL_ECHOLN("PID Autotune start");

  disable_heater(); // switch off all heaters.

  if (extruder>0)
  {
     soft_pwm[extruder] = (PID_MAX)/2;
     bias = d = (PID_MAX)/2;
  }

 for(;;) {
    if(temp_meas_ready == true) { // temp sample ready
      updateTemperaturesFromRawValues();

      input = (extruder<0)?current_temperature_bed:current_temperature[extruder];

      max=max(max,input);
      min=min(min,input);

      if(heating == true && input > temp) {
        if(millis() - t2 > 5000) {
          heating=false;
          if (extruder<0)
            soft_pwm_bed = (bias - d) >> 1;
          else
            soft_pwm[extruder] = (bias - d) >> 1;
          t1=millis();
          t_high=t1 - t2;
          max=temp;
        }
      }
      if(heating == false && input < temp) {
        if(millis() - t1 > 5000) {
          heating=true;
          t2=millis();
          t_low=t2 - t1;
          if(cycles > 0) {
            bias += (d*(t_high - t_low))/(t_low + t_high);
            bias = constrain(bias, 20 ,PID_MAX-20);
            if(bias > PID_MAX/2)
              d = PID_MAX - 1 - bias;
            else d = bias;

            SERIAL_PROTOCOLPGM(" bias: "); SERIAL_PROTOCOL(bias);
            SERIAL_PROTOCOLPGM(" d: "); SERIAL_PROTOCOL(d);
            SERIAL_PROTOCOLPGM(" min: "); SERIAL_PROTOCOL(min);
            SERIAL_PROTOCOLPGM(" max: "); SERIAL_PROTOCOLLN(max);
            if(cycles > 2) {
              Ku = (4.0*d)/(3.14159*(max-min)/2.0);
              Tu = ((float)(t_low + t_high)/1000.0);
              SERIAL_PROTOCOLPGM(" Ku: "); SERIAL_PROTOCOL(Ku);
              SERIAL_PROTOCOLPGM(" Tu: "); SERIAL_PROTOCOLLN(Tu);
              Kp = 0.6*Ku;
              Ki = 2*Kp/Tu;
              Kd = Kp*Tu/8;
              SERIAL_PROTOCOLLNPGM(" Classic PID ");
              SERIAL_PROTOCOLPGM(" Kp: "); SERIAL_PROTOCOLLN(Kp);
              SERIAL_PROTOCOLPGM(" Ki: "); SERIAL_PROTOCOLLN(Ki);
              SERIAL_PROTOCOLPGM(" Kd: "); SERIAL_PROTOCOLLN(Kd);
              /*
              Kp = 0.33*Ku;
              Ki = Kp/Tu;
              Kd = Kp*Tu/3;
              SERIAL_PROTOCOLLNPGM(" Some overshoot ");
              SERIAL_PROTOCOLPGM(" Kp: "); SERIAL_PROTOCOLLN(Kp);
              SERIAL_PROTOCOLPGM(" Ki: "); SERIAL_PROTOCOLLN(Ki);
              SERIAL_PROTOCOLPGM(" Kd: "); SERIAL_PROTOCOLLN(Kd);
              Kp = 0.2*Ku;
              Ki = 2*Kp/Tu;
              Kd = Kp*Tu/3;
              SERIAL_PROTOCOLLNPGM(" No overshoot ");
              SERIAL_PROTOCOLPGM(" Kp: "); SERIAL_PROTOCOLLN(Kp);
              SERIAL_PROTOCOLPGM(" Ki: "); SERIAL_PROTOCOLLN(Ki);
              SERIAL_PROTOCOLPGM(" Kd: "); SERIAL_PROTOCOLLN(Kd);
              */
            }
          }
          if (extruder<0)
            soft_pwm_bed = (bias + d) >> 1;
          else
            soft_pwm[extruder] = (bias + d) >> 1;
          cycles++;
          min=temp;
        }
      }
    }
    if(input > (temp + 20)) {
      SERIAL_PROTOCOLLNPGM("PID Autotune failed! Temperature too high");
      return;
    }
    if(millis() - temp_millis > 2000) {
      int p;
      if (extruder<0){
        p=soft_pwm_bed;
        SERIAL_PROTOCOLPGM("ok B:");
      }else{
        p=soft_pwm[extruder];
        SERIAL_PROTOCOLPGM("ok T:");
      }

      SERIAL_PROTOCOL(input);
      SERIAL_PROTOCOLPGM(" @:");
      SERIAL_PROTOCOLLN(p);

      temp_millis = millis();
    }
    if(((millis() - t1) + (millis() - t2)) > (10L*60L*1000L*2L)) {
      SERIAL_PROTOCOLLNPGM("PID Autotune failed! timeout");
      return;
    }
    if(cycles > ncycles) {
      SERIAL_PROTOCOLLNPGM("PID Autotune finished! Put the last Kp, Ki and Kd constants from above into Configuration.h");
      return;
    }
  }
}

void updatePID(){
  #ifdef PIDTEMP
    for(int e = 0; e < 1; e++) {
       temp_iState_max[e] = PID_INTEGRAL_DRIVE_MAX / Ki;
    }
  #endif
  #ifdef PIDTEMPBED
    temp_iState_max_bed = PID_INTEGRAL_DRIVE_MAX / bedKi;
  #endif
}

int getHeaterPower(int heater) {
	if (heater<0)
		return soft_pwm_bed;
  return soft_pwm[heater];
}

void manage_heater(){
  float pid_input;
  float pid_output;
  if(temp_meas_ready != true) return;
  updateTemperaturesFromRawValues();
  #ifdef HEATER_0_USES_MAX6675
    if (current_temperature[0] > 1023 || current_temperature[0] > HEATER_0_MAXTEMP) {
      max_temp_error(0);
    }
    if (current_temperature[0] == 0  || current_temperature[0] < HEATER_0_MINTEMP) {
      min_temp_error(0);
    }
  #endif //HEATER_0_USES_MAX6675

  for(int e = 0; e < 1; e++){
    #if defined(THERMAL_RUNAWAY_PROTECTION_PERIOD) && THERMAL_RUNAWAY_PROTECTION_PERIOD > 0
      thermal_runaway_protection(&thermal_runaway_state_machine[e],
                                 &thermal_runaway_timer[e],
                                 current_temperature[e],
                                 target_temperature[e],
                                 e,
                                 THERMAL_RUNAWAY_PROTECTION_PERIOD,
                                 THERMAL_RUNAWAY_PROTECTION_HYSTERESIS);
    #endif
    #ifdef PIDTEMP
      pid_input = current_temperature[e];
      #ifndef PID_OPENLOOP
        pid_error[e] = target_temperature[e] - pid_input;
        if(pid_error[e] > PID_FUNCTIONAL_RANGE) {
          pid_output = BANG_MAX;
          pid_reset[e] = true;
        }else if(pid_error[e] < -PID_FUNCTIONAL_RANGE || target_temperature[e] == 0) {
          pid_output = 0;
          pid_reset[e] = true;
        }else {
          if(pid_reset[e] == true) {
            temp_iState[e] = 0.0;
            pid_reset[e] = false;
          }
          pTerm[e] = Kp * pid_error[e];
          temp_iState[e] += pid_error[e];
          temp_iState[e] = constrain(temp_iState[e], temp_iState_min[e], temp_iState_max[e]);
          iTerm[e] = Ki * temp_iState[e];

          //K1 defined in Configuration.h in the PID settings
          #define K2 (1.0-K1)
          dTerm[e] = (Kd * (pid_input - temp_dState[e]))*K2 + (K1 * dTerm[e]);
          pid_output = pTerm[e] + iTerm[e] - dTerm[e];
          if (pid_output > PID_MAX) {
            if (pid_error[e] > 0 )  temp_iState[e] -= pid_error[e]; // conditional un-integration
            pid_output=PID_MAX;
          } else if (pid_output < 0){
            if (pid_error[e] < 0 )  temp_iState[e] -= pid_error[e]; // conditional un-integration
            pid_output=0;
          }
        }
        temp_dState[e] = pid_input;
      #else
        pid_output = constrain(target_temperature[e], 0, PID_MAX);
      #endif //PID_OPENLOOP
      #ifdef PID_DEBUG
        SERIAL_ECHO_START;
        SERIAL_ECHO(" PID_DEBUG ");
        SERIAL_ECHO(e);
        SERIAL_ECHO(": Input ");
        SERIAL_ECHO(pid_input);
        SERIAL_ECHO(" Output ");
        SERIAL_ECHO(pid_output);
        SERIAL_ECHO(" pTerm ");
        SERIAL_ECHO(pTerm[e]);
        SERIAL_ECHO(" iTerm ");
        SERIAL_ECHO(iTerm[e]);
        SERIAL_ECHO(" dTerm ");
        SERIAL_ECHOLN(dTerm[e]);
      #endif //PID_DEBUG
    #else /* PID off */
      pid_output = 0;
      if(current_temperature[e] < target_temperature[e]) {
        pid_output = PID_MAX;
      }
    #endif // PIDTEMP

    // Check if temperature is within the correct range
    if((current_temperature[e] > minttemp[e]) && (current_temperature[e] < maxttemp[e])){
      soft_pwm[e] = (int)pid_output >> 1;
    }else {
      soft_pwm[e] = 0;
    }

    #ifdef WATCH_TEMP_PERIOD
      if(watchmillis[e] && millis() - watchmillis[e] > WATCH_TEMP_PERIOD){
        if(degHotend(e) < watch_start_temp[e] + WATCH_TEMP_INCREASE){
          setTargetHotend(0, e);
          LCD_MESSAGEPGM("Heating failed");
          SERIAL_ECHO_START;
          SERIAL_ECHOLN("Heating failed");
        }else{
          watchmillis[e] = 0;
        }
      }
    #endif
  } // End extruder for loop
}

#define PGM_RD_W(x)   (short)pgm_read_word(&x)
// Derived from RepRap FiveD extruder::getTemperature()
// For hot end temperature measurement.
static float analog2temp(int raw, uint8_t e){
  if(e >= 1){
    SERIAL_ERROR_START;
    SERIAL_ERROR((int)e);
    SERIAL_ERRORLNPGM(" - Invalid extruder number !");
    kill();
    return 0.0;
  }
  #ifdef HEATER_0_USES_MAX6675
    if (e == 0){
      return 0.25 * raw;
    }
  #endif

  if(heater_ttbl_map[e] != NULL){
    float celsius = 0;
    uint8_t i;
    short (*tt)[][2] = (short (*)[][2])(heater_ttbl_map[e]);

    for (i=1; i<heater_ttbllen_map[e]; i++){
      if (PGM_RD_W((*tt)[i][0]) > raw){
        celsius = PGM_RD_W((*tt)[i-1][1]) +
          (raw - PGM_RD_W((*tt)[i-1][0])) *
          (float)(PGM_RD_W((*tt)[i][1]) - PGM_RD_W((*tt)[i-1][1])) /
          (float)(PGM_RD_W((*tt)[i][0]) - PGM_RD_W((*tt)[i-1][0]));
        break;
      }
    }

    // Overflow: Set to last value in the table
    if (i == heater_ttbllen_map[e]) celsius = PGM_RD_W((*tt)[i-1][1]);

    return celsius;
  }
  return ((raw * ((5.0 * 100.0) / 1024.0) / OVERSAMPLENR) * TEMP_SENSOR_AD595_GAIN) + TEMP_SENSOR_AD595_OFFSET;
}

/* Called to get the raw values into the the actual temperatures. The raw values are created in interrupt context,
    and this function is called from normal context as it is too slow to run in interrupts and will block the stepper routine otherwise */
static void updateTemperaturesFromRawValues(){
  #ifdef HEATER_0_USES_MAX6675
    current_temperature_raw[0] = read_max6675();
  #endif
  for(uint8_t e=0;e<1;e++){
    current_temperature[e] = analog2temp(current_temperature_raw[e], e);
  }

  CRITICAL_SECTION_START;
  temp_meas_ready = false;
  CRITICAL_SECTION_END;
}

void tp_init(){
  // Finish init of mult extruder arrays
  for(int e = 0; e < 1; e++) {
    // populate with the first value
    maxttemp[e] = maxttemp[0];
    #ifdef PIDTEMP
      temp_iState_min[e] = 0.0;
      temp_iState_max[e] = PID_INTEGRAL_DRIVE_MAX / Ki;
    #endif
    #ifdef PIDTEMPBED
      temp_iState_min_bed = 0.0;
      temp_iState_max_bed = PID_INTEGRAL_DRIVE_MAX / bedKi;
    #endif
  }

  #if defined(HEATER_0_PIN) && (HEATER_0_PIN > -1)
    SET_OUTPUT(HEATER_0_PIN);
  #endif
  #if defined(HEATER_1_PIN) && (HEATER_1_PIN > -1)
    SET_OUTPUT(HEATER_1_PIN);
  #endif
  #if defined(HEATER_2_PIN) && (HEATER_2_PIN > -1)
    SET_OUTPUT(HEATER_2_PIN);
  #endif
  #if defined(HEATER_3_PIN) && (HEATER_3_PIN > -1)
    SET_OUTPUT(HEATER_3_PIN);
  #endif
  #if defined(HEATER_BED_PIN) && (HEATER_BED_PIN > -1)
    SET_OUTPUT(HEATER_BED_PIN);
  #endif
  #if defined(FAN_PIN) && (FAN_PIN > -1)
    SET_OUTPUT(FAN_PIN);
    #ifdef FAST_PWM_FAN
      setPwmFrequency(FAN_PIN, 1); // No prescaling. Pwm frequency = F_CPU/256/8
    #endif
    #ifdef FAN_SOFT_PWM
      soft_pwm_fan = fanSpeedSoftPwm / 2;
    #endif
  #endif

  #ifdef HEATER_0_USES_MAX6675
    SET_OUTPUT(SCK_PIN);
    WRITE(SCK_PIN,0);
    SET_OUTPUT(MOSI_PIN);
    WRITE(MOSI_PIN,1);
    SET_INPUT(MISO_PIN);
    WRITE(MISO_PIN,1);
    SET_OUTPUT(MAX6675_SS);
    WRITE(MAX6675_SS,1);
  #endif //HEATER_0_USES_MAX6675

  // Set analog inputs
  ADCSRA = 1<<ADEN | 1<<ADSC | 1<<ADIF | 0x07;
  DIDR0 = 0;
  #ifdef DIDR2
    DIDR2 = 0;
  #endif
  #if defined(TEMP_0_PIN) && (TEMP_0_PIN > -1)
    #if TEMP_0_PIN < 8
       DIDR0 |= 1 << TEMP_0_PIN;
    #else
       DIDR2 |= 1<<(TEMP_0_PIN - 8);
    #endif
  #endif
  #if defined(TEMP_1_PIN) && (TEMP_1_PIN > -1)
    #if TEMP_1_PIN < 8
      DIDR0 |= 1<<TEMP_1_PIN;
    #else
    	DIDR2 |= 1<<(TEMP_1_PIN - 8);
    #endif
  #endif
  #if defined(TEMP_2_PIN) && (TEMP_2_PIN > -1)
    #if TEMP_2_PIN < 8
      DIDR0 |= 1 << TEMP_2_PIN;
    #else
      DIDR2 |= 1<<(TEMP_2_PIN - 8);
    #endif
  #endif
  #if defined(TEMP_3_PIN) && (TEMP_3_PIN > -1)
    #if TEMP_3_PIN < 8
      DIDR0 |= 1 << TEMP_3_PIN;
    #else
      DIDR2 |= 1<<(TEMP_3_PIN - 8);
    #endif
  #endif
  #if defined(TEMP_BED_PIN) && (TEMP_BED_PIN > -1)
    #if TEMP_BED_PIN < 8
       DIDR0 |= 1<<TEMP_BED_PIN;
    #else
       DIDR2 |= 1<<(TEMP_BED_PIN - 8);
    #endif
  #endif

  // Use timer0 for temperature measurement
  // Interleave temperature interrupt with millies interrupt
  OCR0B = 128;
  TIMSK0 |= (1<<OCIE0B);

  // Wait for temperature measurement to settle
  delay(250);

  #ifdef HEATER_0_MINTEMP
    minttemp[0] = HEATER_0_MINTEMP;
    while(analog2temp(minttemp_raw[0], 0) < HEATER_0_MINTEMP){
      #if HEATER_0_RAW_LO_TEMP < HEATER_0_RAW_HI_TEMP
        minttemp_raw[0] += OVERSAMPLENR;
      #else
        minttemp_raw[0] -= OVERSAMPLENR;
      #endif
    }
  #endif // HEATER_0_MINTEMP
  #ifdef HEATER_0_MAXTEMP
    maxttemp[0] = HEATER_0_MAXTEMP;
    while(analog2temp(maxttemp_raw[0], 0) > HEATER_0_MAXTEMP) {
      #if HEATER_0_RAW_LO_TEMP < HEATER_0_RAW_HI_TEMP
        maxttemp_raw[0] -= OVERSAMPLENR;
      #else
        maxttemp_raw[0] += OVERSAMPLENR;
      #endif
    }
  #endif // HEATER_0_MAXTEMP
}

void setWatch(){
  #ifdef WATCH_TEMP_PERIOD
    for (int e = 0; e < 1; e++){
      if(degHotend(e) < degTargetHotend(e) - (WATCH_TEMP_INCREASE * 2)){
        watch_start_temp[e] = degHotend(e);
        watchmillis[e] = millis();
      }
    }
  #endif
}

#if defined(THERMAL_RUNAWAY_PROTECTION_PERIOD) && THERMAL_RUNAWAY_PROTECTION_PERIOD > 0
  void thermal_runaway_protection(int *state, unsigned long *timer, float temperature, float target_temperature, int heater_id, int period_seconds, int hysteresis_degc){
    if ((target_temperature == 0) || thermal_runaway){
      *state = 0;
      *timer = 0;
      return;
    }
    switch (*state){
      case 0: // "Heater Inactive" state
        if (target_temperature > 0) *state = 1;
        break;
      case 1: // "First Heating" state
        if (temperature >= target_temperature) *state = 2;
        break;
      case 2: // "Temperature Stable" state
        if (temperature >= (target_temperature - hysteresis_degc)){
          *timer = millis();
        }else if ( (millis() - *timer) > ((unsigned long) period_seconds) * 1000){
          SERIAL_ERROR_START;
          SERIAL_ERRORLNPGM("Thermal Runaway, system stopped! Heater_ID: ");
          SERIAL_ERRORLN((int)heater_id);
          thermal_runaway = true;
          while(1){
            disable_heater();
            disable_x();
            disable_y();
            disable_z();
            disable_e0();
            disable_e1();
            disable_e2();
            disable_e3();
            manage_heater();
          }
        }
        break;
    }
  }
#endif

void disable_heater(){
  for(int i=0;i<1;i++) setTargetHotend(0,i);

  setTargetBed(0);
  #if defined(TEMP_0_PIN) && TEMP_0_PIN > -1
    target_temperature[0]=0;
    soft_pwm[0]=0;
    #if defined(HEATER_0_PIN) && HEATER_0_PIN > -1
      WRITE(HEATER_0_PIN,LOW);
    #endif
  #endif

  #if defined(TEMP_BED_PIN) && TEMP_BED_PIN > -1
    target_temperature_bed=0;
    soft_pwm_bed=0;
    #if defined(HEATER_BED_PIN) && HEATER_BED_PIN > -1
      WRITE(HEATER_BED_PIN,LOW);
    #endif
  #endif
}

void max_temp_error(uint8_t e) {
  disable_heater();
  if(IsStopped() == false) {
    SERIAL_ERROR_START;
    SERIAL_ERRORLN((int)e);
    SERIAL_ERRORLNPGM(": Extruder switched off. MAXTEMP triggered !");
  }
  #ifndef BOGUS_TEMPERATURE_FAILSAFE_OVERRIDE
    Stop();
  #endif
}

void min_temp_error(uint8_t e) {
  disable_heater();
  if(IsStopped() == false) {
    SERIAL_ERROR_START;
    SERIAL_ERRORLN((int)e);
    SERIAL_ERRORLNPGM(": Extruder switched off. MINTEMP triggered !");
  }
  #ifndef BOGUS_TEMPERATURE_FAILSAFE_OVERRIDE
    Stop();
  #endif
}

void bed_max_temp_error(void) {
  #if HEATER_BED_PIN > -1
    WRITE(HEATER_BED_PIN, 0);
  #endif
  if(IsStopped() == false) {
    SERIAL_ERROR_START;
    SERIAL_ERRORLNPGM("Temperature heated bed switched off. MAXTEMP triggered !!");
  }
  #ifndef BOGUS_TEMPERATURE_FAILSAFE_OVERRIDE
    Stop();
  #endif
}

#ifdef HEATER_0_USES_MAX6675
  #define MAX6675_HEAT_INTERVAL 250
  long max6675_previous_millis = MAX6675_HEAT_INTERVAL;
  int max6675_temp = 2000;

  static int read_max6675(){
    if (millis() - max6675_previous_millis < MAX6675_HEAT_INTERVAL) return max6675_temp;

    max6675_previous_millis = millis();
    max6675_temp = 0;
    #ifdef PRR
      PRR &= ~(1<<PRSPI);
    #elif defined(PRR0)
      PRR0 &= ~(1<<PRSPI);
    #endif
    SPCR = (1<<MSTR) | (1<<SPE) | (1<<SPR0);
    // enable TT_MAX6675
    WRITE(MAX6675_SS, 0);
    // ensure 100ns delay - a bit extra is fine
    asm("nop");//50ns on 20Mhz, 62.5ns on 16Mhz
    asm("nop");//50ns on 20Mhz, 62.5ns on 16Mhz
    // read MSB
    SPDR = 0;
    for (;(SPSR & (1<<SPIF)) == 0;);
    max6675_temp = SPDR;
    max6675_temp <<= 8;
    // read LSB
    SPDR = 0;
    for (;(SPSR & (1<<SPIF)) == 0;);
    max6675_temp |= SPDR;
    // disable TT_MAX6675
    WRITE(MAX6675_SS, 1);
    if (max6675_temp & 4){
      // thermocouple open
      max6675_temp = 4000;
    }else{
      max6675_temp = max6675_temp >> 3;
    }
    return max6675_temp;
  }
#endif //HEATER_0_USES_MAX6675


// Timer 0 is shared with millies
ISR(TIMER0_COMPB_vect){
  //these variables are only accesible from the ISR, but static, so they don't lose their value
  static unsigned char temp_count = 0;
  static unsigned long raw_temp_0_value = 0;
  static unsigned long raw_temp_1_value = 0;
  static unsigned long raw_temp_bed_value = 0;
  static unsigned char temp_state = 12;
  static unsigned char pwm_count = (1 << SOFT_PWM_SCALE);
  static unsigned char soft_pwm_0;
  #ifdef SLOW_PWM_HEATERS
    static unsigned char slow_pwm_count = 0;
    static unsigned char state_heater_0 = 0;
    static unsigned char state_timer_heater_0 = 0;
  #endif

#if HEATER_BED_PIN > -1
  static unsigned char soft_pwm_b;
  #ifdef SLOW_PWM_HEATERS
    static unsigned char state_heater_b = 0;
    static unsigned char state_timer_heater_b = 0;
  #endif
#endif

#if defined(FILWIDTH_PIN) &&(FILWIDTH_PIN > -1)
  static unsigned long raw_filwidth_value = 0;  //added for filament width sensor
#endif

#ifndef SLOW_PWM_HEATERS
   // standard PWM modulation
  if(pwm_count == 0){
    soft_pwm_0 = soft_pwm[0];
    if(soft_pwm_0 > 0) {
      WRITE(HEATER_0_PIN,1);
    } else WRITE(HEATER_0_PIN,0);

    #if defined(HEATER_BED_PIN) && HEATER_BED_PIN > -1
      soft_pwm_b = soft_pwm_bed;
      if(soft_pwm_b > 0) WRITE(HEATER_BED_PIN,1); else WRITE(HEATER_BED_PIN,0);
    #endif
    #ifdef FAN_SOFT_PWM
      soft_pwm_fan = fanSpeedSoftPwm / 2;
      if(soft_pwm_fan > 0) WRITE(FAN_PIN,1); else WRITE(FAN_PIN,0);
    #endif
  }
  if(soft_pwm_0 < pwm_count) {
    WRITE(HEATER_0_PIN,0);
  }

  #if defined(HEATER_BED_PIN) && HEATER_BED_PIN > -1
    if(soft_pwm_b < pwm_count) WRITE(HEATER_BED_PIN,0);
  #endif
  #ifdef FAN_SOFT_PWM
    if(soft_pwm_fan < pwm_count) WRITE(FAN_PIN,0);
  #endif

  pwm_count += (1 << SOFT_PWM_SCALE);
  pwm_count &= 0x7f;

#else //ifndef SLOW_PWM_HEATERS
  // SLOW PWM HEATERS
  // for heaters drived by relay
  #ifndef MIN_STATE_TIME
    #define MIN_STATE_TIME 16 // MIN_STATE_TIME * 65.5 = time in milliseconds
  #endif
  if (slow_pwm_count == 0) {
    // EXTRUDER 0
    soft_pwm_0 = soft_pwm[0];
    if (soft_pwm_0 > 0) {
      // turn ON heather only if the minimum time is up
      if (state_timer_heater_0 == 0) {
	      // if change state set timer
	      if (state_heater_0 == 0) {
	        state_timer_heater_0 = MIN_STATE_TIME;
	      }
	      state_heater_0 = 1;
	      WRITE(HEATER_0_PIN, 1);
      }
    }else{
      // turn OFF heather only if the minimum time is up
      if (state_timer_heater_0 == 0) {
	      // if change state set timer
	      if (state_heater_0 == 1) {
	        state_timer_heater_0 = MIN_STATE_TIME;
	      }
	      state_heater_0 = 0;
	      WRITE(HEATER_0_PIN, 0);
      }
    }

    #if defined(HEATER_BED_PIN) && HEATER_BED_PIN > -1
      // BED
      soft_pwm_b = soft_pwm_bed;
      if (soft_pwm_b > 0) {
        // turn ON heather only if the minimum time is up
        if (state_timer_heater_b == 0) {
	        // if change state set timer
	        if (state_heater_b == 0) {
	          state_timer_heater_b = MIN_STATE_TIME;
	        }
	        state_heater_b = 1;
	        WRITE(HEATER_BED_PIN, 1);
        }
      } else {
        // turn OFF heather only if the minimum time is up
        if (state_timer_heater_b == 0) {
	        // if change state set timer
	        if (state_heater_b == 1) {
	          state_timer_heater_b = MIN_STATE_TIME;
	        }
	        state_heater_b = 0;
	        WRITE(HEATER_BED_PIN, 0);
        }
      }
    #endif
  } // if (slow_pwm_count == 0)

  // EXTRUDER 0
  if (soft_pwm_0 < slow_pwm_count) {
    // turn OFF heather only if the minimum time is up
    if (state_timer_heater_0 == 0) {
      // if change state set timer
      if (state_heater_0 == 1) {
	      state_timer_heater_0 = MIN_STATE_TIME;
      }
      state_heater_0 = 0;
      WRITE(HEATER_0_PIN, 0);
    }
  }

  #if defined(HEATER_BED_PIN) && HEATER_BED_PIN > -1
    // BED
    if (soft_pwm_b < slow_pwm_count) {
      // turn OFF heather only if the minimum time is up
      if (state_timer_heater_b == 0) {
        // if change state set timer
        if (state_heater_b == 1) {
  	      state_timer_heater_b = MIN_STATE_TIME;
        }
        state_heater_b = 0;
        WRITE(HEATER_BED_PIN, 0);
      }
    }
  #endif

  #ifdef FAN_SOFT_PWM
    if (pwm_count == 0){
      soft_pwm_fan = fanSpeedSoftPwm / 2;
      if (soft_pwm_fan > 0) WRITE(FAN_PIN,1); else WRITE(FAN_PIN,0);
    }
    if (soft_pwm_fan < pwm_count) WRITE(FAN_PIN,0);
  #endif

  pwm_count += (1 << SOFT_PWM_SCALE);
  pwm_count &= 0x7f;

  // increment slow_pwm_count only every 64 pwm_count circa 65.5ms
  if ((pwm_count % 64) == 0) {
    slow_pwm_count++;
    slow_pwm_count &= 0x7f;

    // Extruder 0
    if (state_timer_heater_0 > 0) {
      state_timer_heater_0--;
    }

    #if defined(HEATER_BED_PIN) && HEATER_BED_PIN > -1
      // Bed
      if (state_timer_heater_b > 0)
        state_timer_heater_b--;
    #endif
  } //if ((pwm_count % 64) == 0)

#endif //ifndef SLOW_PWM_HEATERS

  switch(temp_state) {
    case 0: // Prepare TEMP_0
      #if defined(TEMP_0_PIN) && (TEMP_0_PIN > -1)
        #if TEMP_0_PIN > 7
          ADCSRB = 1<<MUX5;
        #else
          ADCSRB = 0;
        #endif
        ADMUX = ((1 << REFS0) | (TEMP_0_PIN & 0x07));
        ADCSRA |= 1<<ADSC; // Start conversion
      #endif
      //lcd_buttons_update();
      temp_state = 1;
      break;
    case 1: // Measure TEMP_0
      #if defined(TEMP_0_PIN) && (TEMP_0_PIN > -1)
        raw_temp_0_value += ADC;
      #endif
      temp_state = 2;
      break;
    case 2: // Prepare TEMP_BED
      #if defined(TEMP_BED_PIN) && (TEMP_BED_PIN > -1)
        #if TEMP_BED_PIN > 7
          ADCSRB = 1<<MUX5;
        #else
          ADCSRB = 0;
        #endif
        ADMUX = ((1 << REFS0) | (TEMP_BED_PIN & 0x07));
        ADCSRA |= 1<<ADSC; // Start conversion
      #endif
      //lcd_buttons_update();
      temp_state = 3;
      break;
    case 3: // Measure TEMP_BED
      #if defined(TEMP_BED_PIN) && (TEMP_BED_PIN > -1)
        raw_temp_bed_value += ADC;
      #endif
      temp_state = 4;
      break;
    case 4: // Prepare TEMP_1
      #if defined(TEMP_1_PIN) && (TEMP_1_PIN > -1)
        #if TEMP_1_PIN > 7
          ADCSRB = 1<<MUX5;
        #else
          ADCSRB = 0;
        #endif
        ADMUX = ((1 << REFS0) | (TEMP_1_PIN & 0x07));
        ADCSRA |= 1<<ADSC; // Start conversion
      #endif
      //lcd_buttons_update();
      temp_state = 5;
      break;
    case 5: // Measure TEMP_1
      #if defined(TEMP_1_PIN) && (TEMP_1_PIN > -1)
        raw_temp_1_value += ADC;
      #endif
      temp_state = 6;
      break;
    case 6: // Prepare TEMP_2
      #if defined(TEMP_2_PIN) && (TEMP_2_PIN > -1)
        #if TEMP_2_PIN > 7
          ADCSRB = 1<<MUX5;
        #else
          ADCSRB = 0;
        #endif
        ADMUX = ((1 << REFS0) | (TEMP_2_PIN & 0x07));
        ADCSRA |= 1<<ADSC; // Start conversion
      #endif
      //lcd_buttons_update();
      temp_state = 7;
      break;
    case 7: // Measure TEMP_2
      temp_state = 8;
      break;
    case 8: // Prepare TEMP_3
      #if defined(TEMP_3_PIN) && (TEMP_3_PIN > -1)
        #if TEMP_3_PIN > 7
          ADCSRB = 1<<MUX5;
        #else
          ADCSRB = 0;
        #endif
        ADMUX = ((1 << REFS0) | (TEMP_3_PIN & 0x07));
        ADCSRA |= 1<<ADSC; // Start conversion
      #endif
      //lcd_buttons_update();
      temp_state = 9;
      break;
    case 9: // Measure TEMP_3
      temp_state = 10; //change so that Filament Width is also measured
      break;
    case 10: //Prepare FILWIDTH
     #if defined(FILWIDTH_PIN) && (FILWIDTH_PIN> -1)
      #if FILWIDTH_PIN>7
         ADCSRB = 1<<MUX5;
      #else
         ADCSRB = 0;
      #endif
      ADMUX = ((1 << REFS0) | (FILWIDTH_PIN & 0x07));
      ADCSRA |= 1<<ADSC; // Start conversion
     #endif
     //lcd_buttons_update();
     temp_state = 11;
     break;
    case 11:   //Measure FILWIDTH
     #if defined(FILWIDTH_PIN) &&(FILWIDTH_PIN > -1)
     //raw_filwidth_value += ADC;  //remove to use an IIR filter approach
      if(ADC>102)  //check that ADC is reading a voltage > 0.5 volts, otherwise don't take in the data.
        {
    	raw_filwidth_value= raw_filwidth_value-(raw_filwidth_value>>7);  //multipliy raw_filwidth_value by 127/128

        raw_filwidth_value= raw_filwidth_value + ((unsigned long)ADC<<7);  //add new ADC reading
        }
     #endif
     temp_state = 0;

     temp_count++;
     break;

    case 12: //Startup, delay initial temp reading a tiny bit so the hardware can settle.
      temp_state = 0;
      break;
  }

  if(temp_count >= OVERSAMPLENR) // 10 * 16 * 1/(16000000/64/256)  = 164ms.
  {
    if (!temp_meas_ready) //Only update the raw values if they have been read. Else we could be updating them during reading.
    {
#ifndef HEATER_0_USES_MAX6675
      current_temperature_raw[0] = raw_temp_0_value;
#endif
      current_temperature_bed_raw = raw_temp_bed_value;
    }

//Add similar code for Filament Sensor - can be read any time since IIR filtering is used
#if defined(FILWIDTH_PIN) &&(FILWIDTH_PIN > -1)
  current_raw_filwidth = raw_filwidth_value>>10;  //need to divide to get to 0-16384 range since we used 1/128 IIR filter approach
#endif


    temp_meas_ready = true;
    temp_count = 0;
    raw_temp_0_value = 0;
    raw_temp_1_value = 0;
    raw_temp_bed_value = 0;

#if HEATER_0_RAW_LO_TEMP > HEATER_0_RAW_HI_TEMP
    if(current_temperature_raw[0] <= maxttemp_raw[0]) {
#else
    if(current_temperature_raw[0] >= maxttemp_raw[0]) {
#endif
#ifndef HEATER_0_USES_MAX6675
        max_temp_error(0);
#endif
    }
#if HEATER_0_RAW_LO_TEMP > HEATER_0_RAW_HI_TEMP
    if(current_temperature_raw[0] >= minttemp_raw[0]) {
#else
    if(current_temperature_raw[0] <= minttemp_raw[0]) {
#endif
#ifndef HEATER_0_USES_MAX6675
        min_temp_error(0);
#endif
    }


  /* No bed MINTEMP error? */
#if defined(BED_MAXTEMP) && (TEMP_SENSOR_BED != 0)
# if HEATER_BED_RAW_LO_TEMP > HEATER_BED_RAW_HI_TEMP
    if(current_temperature_bed_raw <= bed_maxttemp_raw) {
#else
    if(current_temperature_bed_raw >= bed_maxttemp_raw) {
#endif
       target_temperature_bed = 0;
       bed_max_temp_error();
    }
#endif
  }

}

#ifdef PIDTEMP
// Apply the scale factors to the PID values


float scalePID_i(float i)
{
	return i*PID_dT;
}

float unscalePID_i(float i)
{
	return i/PID_dT;
}

float scalePID_d(float d)
{
    return d/PID_dT;
}

float unscalePID_d(float d)
{
	return d*PID_dT;
}

#endif //PIDTEMP
