/* -*- c++ -*- */

/*
   Hangprinter firmware is mostly just a reduced version of Marlin

   Reprap firmware based on Sprinter and grbl.
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
   */

#include "Marlin.h"

#include "planner.h"
#include "stepper.h"
#ifdef EXTRUDERS
#include "temperature.h"
#endif
#include "motion_control.h"
#include "cardreader.h"
#include "watchdog.h"
#include "ConfigurationStore.h"
#include "language.h"
#include "pins_arduino.h"
#include "math.h"

#if defined(DIGIPOTSS_PIN) && DIGIPOTSS_PIN > -1
#include <SPI.h>
#endif

// look here for descriptions of G-codes: http://linuxcnc.org/handbook/gcode/g-code.html
// http://objects.reprap.org/wiki/Mendel_User_Manual:_RepRapGCodes

//Implemented Codes
//-------------------
// G0  -> G1
// G1  - Coordinated Movement X Y Z E
// G90 - Use Absolute Coordinates
// G91 - Use Relative Coordinates
// G92 - Set current position to coordinates given

// M Codes
// M17  - Enable/Power all stepper motors
// M20  - List SD card
// M21  - Init SD card
// M22  - Release SD card
// M23  - Select SD file (M23 filename.g)
// M24  - Start/resume SD print
// M25  - Pause SD print
// M26  - Set SD position in bytes (M26 S12345)
// M27  - Report SD print status
// M928  - Start SD write (M28 filename.g)
// M29  - Stop SD write
// M30  - Delete file from SD (M30 filename.g)
// M31  - Output time since last M109 or SD card start to serial
// M32  - Select file and start SD print (Can be used _while_ printing from SD card files):
//        syntax "M32 /path/filename#", or "M32 S<startpos bytes> !filename#"
//        Call gcode file : "M32 P !filename#" and return to caller file after finishing (similar to #include).
//        The '#' is necessary when calling from within sd files, as it stops buffer prereading
// M42  - Change pin status via gcode Use M42 Px Sy to set pin x to value y, when omitting Px the onboard led will be used.
// M82  - Set E codes absolute (default)
// M83  - Set E codes relative while in Absolute Coordinates (G90) mode
// M92  - Set axis_steps_per_unit - same syntax as G92
// M104 - Set extruder target temp
// M105 - Read current temp
// M106 - Fan on
// M107 - Fan off
// M109 - Sxxx Wait for extruder current temp to reach target temp. Waits only when heating
//        Rxxx Wait for extruder current temp to reach target temp. Waits when heating and cooling
//        IF AUTOTEMP is enabled, S<mintemp> B<maxtemp> F<factor>. Exit autotemp by any M109 without F
// M112 - Emergency stop
// M114 - Output current position to serial port
// M119 - Output Endstop status to serial port
// M140 - Set bed target temp
// M190 - Sxxx Wait for bed current temp to reach target temp. Waits only when heating
//        Rxxx Wait for bed current temp to reach target temp. Waits when heating and cooling
// M200 D<millimeters>- set filament diameter and set E axis units to cubic millimeters (use S0 to set back to millimeters).
// M201 - Set max acceleration in units/s^2 for print moves (M201 X1000 Y1000)
// M202 - Set max acceleration in units/s^2 for travel moves (M202 X1000 Y1000) Unused in Marlin!!
// M203 - Set maximum feedrate that your machine can sustain (M203 X200 Y200 Z300 E10000) in mm/sec
// M204 - Set default acceleration: S normal moves T filament only moves (M204 S3000 T7000) in mm/sec^2  also sets minimum segment time in ms (B20000) to prevent buffer under-runs and M20 minimum feedrate
// M205 -  advanced settings:  minimum travel speed S=while printing T=travel only,  B=minimum segment time X= maximum xy jerk, Z=maximum Z jerk, E=maximum E jerk
// M220 S<factor in percent>- set speed factor override percentage
// M221 S<factor in percent>- set extrude factor override percentage
// M226 P<pin number> S<pin state>- Wait until the specified pin reaches the state required
// M300 - Play beep sound S<frequency Hz> P<duration ms>
// M301 - Set PID parameters P I and D
// M302 - Allow cold extrudes, or set the minimum extrude S<temperature>.
// M303 - PID relay autotune S<temperature> sets the target temperature. (default target temperature = 150C)
// M304 - Set bed PID parameters P I and D
// M400 - Finish all moves
// M500 - Store parameters in EEPROM
// M501 - Read parameters from EEPROM (if you need reset them after you changed them temporarily).
// M502 - Revert to the default "factory settings".  You still need to store them in EEPROM afterwards if you want to.
// M503 - Print the current settings (from memory not from EEPROM). Use S0 to leave off headings.
// M540 - Use S[0|1] to enable or disable the stop SD card print on endstop hit (requires ABORT_ON_ENDSTOP_HIT_FEATURE_ENABLED)
// M665 - Set delta configurations
// M666 - Set delta endstop adjustment
// M350 - Set microstepping mode.
// M351 - Toggle MS1 MS2 pins directly.

// ************ SCARA Specific - This can change to suit future G-code regulations
// M360 - SCARA calibration: Move to cal-position ThetaA (0 deg calibration)
// M361 - SCARA calibration: Move to cal-position ThetaB (90 deg calibration - steps per degree)
// M362 - SCARA calibration: Move to cal-position PsiA (0 deg calibration)
// M363 - SCARA calibration: Move to cal-position PsiB (90 deg calibration - steps per degree)
// M364 - SCARA calibration: Move to cal-position PSIC (90 deg to Theta calibration position)
// M365 - SCARA calibration: Scaling factor, X, Y, Z axis
//************* SCARA End ***************

// M928 - Start SD logging (M928 filename.g) - ended by M29
// M999 - Restart after being stopped by error

#ifdef SDSUPPORT
CardReader card;
#endif

float homing_feedrate[] = HOMING_FEEDRATE;
bool axis_relative_modes[] = AXIS_RELATIVE_MODES;
int feedmultiply = 100; //100->1 200->2
int saved_feedmultiply;
#ifdef EXTRUDERS
int extrudemultiply = 100; //100->1 200->2
int extruder_multiply[EXTRUDERS] = { 100
#if EXTRUDERS > 1
  , 100
#if EXTRUDERS > 2
    , 100
#if EXTRUDERS > 3
    , 100
#endif
#endif
#endif
};
bool volumetric_enabled = false;
float filament_size[EXTRUDERS] = { DEFAULT_NOMINAL_FILAMENT_DIA
#if EXTRUDERS > 1
  , DEFAULT_NOMINAL_FILAMENT_DIA
#if EXTRUDERS > 2
    , DEFAULT_NOMINAL_FILAMENT_DIA
#if EXTRUDERS > 3
    , DEFAULT_NOMINAL_FILAMENT_DIA
#endif
#endif
#endif
};
float volumetric_multiplier[EXTRUDERS] = {1.0
#if EXTRUDERS > 1
  , 1.0
#if EXTRUDERS > 2
    , 1.0
#if EXTRUDERS > 3
    , 1.0
#endif
#endif
#endif
};
#endif // ifdef EXTRUDERS
float current_position[4] = { 0.0, 0.0, 0.0, 0.0 }; // gcode carthesian
float add_homing[DIRS] = { 0 };
#ifdef DELTA
float endstop_adj[DIRS] = { 0 };
#endif

float min_pos[DIRS] = { A_MIN_POS, B_MIN_POS, C_MIN_POS, D_MIN_POS };
float max_pos[DIRS] = { A_MAX_POS, B_MAX_POS, C_MAX_POS, D_MAX_POS };
bool axis_known_position[DIRS] = { false, false, false, false };
float zprobe_zoffset;

// Extruder offset
#ifdef EXTRUDERS
#if EXTRUDERS > 1
#define NUM_EXTRUDER_OFFSETS 2 // only in XY plane
float extruder_offset[NUM_EXTRUDER_OFFSETS][EXTRUDERS] = {
#if defined(EXTRUDER_OFFSET_X)
  EXTRUDER_OFFSET_X
#else
    0
#endif
    ,
#if defined(EXTRUDER_OFFSET_Y)
  EXTRUDER_OFFSET_Y
#else
    0
#endif
};
#endif // if EXTRUDERS > 1

#endif // ifdef EXTRUDERS
uint8_t active_extruder = 0;
int fanSpeed = 0;

// TODO: separate DELTA and HANGPRINTER completely. Using one define per geometry is more clean.
float anchor_A_x = ANCHOR_A_X;
float anchor_A_y = ANCHOR_A_Y;
float anchor_A_z = ANCHOR_A_Z;
float anchor_B_x = ANCHOR_B_X;
float anchor_B_y = ANCHOR_B_Y;
float anchor_B_z = ANCHOR_B_Z;
float anchor_C_x = ANCHOR_C_X;
float anchor_C_y = ANCHOR_C_Y;
float anchor_C_z = ANCHOR_C_Z;
float anchor_D_z = ANCHOR_D_Z;
float delta_segments_per_second = DELTA_SEGMENTS_PER_SECOND;
float delta[DIRS] = { 0 }; // TODO: should this be static?

#ifdef SCARA
float axis_scaling[3] = { 1, 1, 1 };    // Build size scaling, default to 1
#endif				

#ifdef EXTRUDERS
bool cancel_heatup = false;
#endif // ifdef EXTRUDERS

const char errormagic[] PROGMEM = "Error:";
const char echomagic[] PROGMEM = "echo:";

// destinations are directly from gcode, so Carthesian xyze
const char axis_codes_carthesian[4] = {'X', 'Y', 'Z', 'E'};
const char axis_codes[5] = {'A', 'B', 'C', 'D', 'E'};
static float destination[4] = { 0, 0, 0, 0 };

static float offset[3] = { 0, 0, 0 };
static bool home_all_axis = true;
static float feedrate = 1500.0, next_feedrate, saved_feedrate;
static long gcode_N, gcode_LastN, Stopped_gcode_LastN = 0;

static bool relative_mode = false;

static char cmdbuffer[BUFSIZE][MAX_CMD_SIZE];
static bool fromsd[BUFSIZE];
static int bufindr = 0;
static int bufindw = 0;
static int buflen = 0; /* Incremented in enquecommand(), enquecommand_P(), get_command(). Decremented in loop(). */

static char serial_char;
static int serial_count = 0;
static boolean comment_mode = false;
static char *strchr_pointer; ///< A pointer to find chars in the command string (X, Y, Z, E, etc.)

const int sensitive_pins[] = SENSITIVE_PINS; ///< Sensitive pin list for M42

// Inactivity shutdown
static unsigned long previous_millis_cmd = 0;
static unsigned long max_inactive_time = 0;
static unsigned long stepper_inactive_time = DEFAULT_STEPPER_DEACTIVE_TIME*1000l;

unsigned long starttime = 0; ///< Print job start time
unsigned long stoptime = 0;  ///< Print job stop time

#ifdef EXTRUDERS
static uint8_t tmp_extruder;
#endif // ifdef EXTRUDERS


bool Stopped = false;

bool CooldownNoWait = true;
bool target_direction;

#ifdef CHDK
unsigned long chdkHigh = 0;
boolean chdkActive = false;
#endif

//===========================================================================
//=============================Routines======================================
//===========================================================================

void get_arc_coordinates();
#ifdef EXTRUDERS
bool setTargetedHotend(int code);
#endif // ifdef EXTRUDERS

void serial_echopair_P(const char *s_P, float v)
{ serialprintPGM(s_P); SERIAL_ECHO(v); }
void serial_echopair_P(const char *s_P, double v)
{ serialprintPGM(s_P); SERIAL_ECHO(v); }
void serial_echopair_P(const char *s_P, unsigned long v)
{ serialprintPGM(s_P); SERIAL_ECHO(v); }

#ifdef SDSUPPORT
#include "SdFatUtil.h"
int freeMemory(){ return SdFatUtil::FreeRam(); }
#else
extern "C" {
  extern unsigned int __bss_end;
  extern unsigned int __heap_start;
  extern void *__brkval;

  int freeMemory(){
    int free_memory;

    if((int)__brkval == 0)
      free_memory = ((int)&free_memory) - ((int)&__bss_end);
    else
      free_memory = ((int)&free_memory) - ((int)__brkval);

    return free_memory;
  }
}
#endif //!SDSUPPORT

//adds an command to the main command buffer
//thats really done in a non-safe way.
//needs overworking someday
void enquecommand(const char *cmd){
  if(buflen < BUFSIZE){
    //this is dangerous if a mixing of serial and this happens
    strcpy(&(cmdbuffer[bufindw][0]),cmd);
    SERIAL_ECHO_START;
    SERIAL_ECHOPGM(MSG_Enqueing);
    SERIAL_ECHO(cmdbuffer[bufindw]);
    SERIAL_ECHOLNPGM("\"");
    bufindw= (bufindw + 1)%BUFSIZE;
    buflen += 1;
  }
}

void enquecommand_P(const char *cmd){
  if(buflen < BUFSIZE){
    //this is dangerous if a mixing of serial and this happens
    strcpy_P(&(cmdbuffer[bufindw][0]),cmd);
    SERIAL_ECHO_START;
    SERIAL_ECHOPGM(MSG_Enqueing);
    SERIAL_ECHO(cmdbuffer[bufindw]);
    SERIAL_ECHOLNPGM("\"");
    bufindw= (bufindw + 1)%BUFSIZE;
    buflen += 1;
  }
}

void setup_killpin(){
#if defined(KILL_PIN) && KILL_PIN > -1
  SET_INPUT(KILL_PIN);
  WRITE(KILL_PIN,HIGH);
#endif
}

// Set home pin
void setup_homepin(void){
#if defined(HOME_PIN) && HOME_PIN > -1
  SET_INPUT(HOME_PIN);
  WRITE(HOME_PIN,HIGH);
#endif
}


void setup_photpin(){
#if defined(PHOTOGRAPH_PIN) && PHOTOGRAPH_PIN > -1
  SET_OUTPUT(PHOTOGRAPH_PIN);
  WRITE(PHOTOGRAPH_PIN, LOW);
#endif
}

void setup_powerhold(){
#if defined(SUICIDE_PIN) && SUICIDE_PIN > -1
  SET_OUTPUT(SUICIDE_PIN);
  WRITE(SUICIDE_PIN, HIGH);
#endif
#if defined(PS_ON_PIN) && PS_ON_PIN > -1
  SET_OUTPUT(PS_ON_PIN);
#endif
}

void suicide(){
#if defined(SUICIDE_PIN) && SUICIDE_PIN > -1
  SET_OUTPUT(SUICIDE_PIN);
  WRITE(SUICIDE_PIN, LOW);
#endif
}

void setup(){
  setup_killpin();
  setup_powerhold();
  MYSERIAL.begin(BAUDRATE);
  SERIAL_PROTOCOLLNPGM("start");
  SERIAL_ECHO_START;

  // Check startup - does nothing if bootloader sets MCUSR to 0
  byte mcu = MCUSR;
  if(mcu & 1) SERIAL_ECHOLNPGM(MSG_POWERUP);
  if(mcu & 2) SERIAL_ECHOLNPGM(MSG_EXTERNAL_RESET);
  if(mcu & 4) SERIAL_ECHOLNPGM(MSG_BROWNOUT_RESET);
  if(mcu & 8) SERIAL_ECHOLNPGM(MSG_WATCHDOG_RESET);
  if(mcu & 32) SERIAL_ECHOLNPGM(MSG_SOFTWARE_RESET);
  MCUSR=0;

  SERIAL_ECHOPGM(MSG_MARLIN);
  SERIAL_ECHOLNPGM(STRING_VERSION);
#ifdef STRING_VERSION_CONFIG_H
#ifdef STRING_CONFIG_H_AUTHOR
  SERIAL_ECHO_START;
  SERIAL_ECHOPGM(MSG_CONFIGURATION_VER);
  SERIAL_ECHOPGM(STRING_VERSION_CONFIG_H);
  SERIAL_ECHOPGM(MSG_AUTHOR);
  SERIAL_ECHOLNPGM(STRING_CONFIG_H_AUTHOR);
  SERIAL_ECHOPGM("Compiled: ");
  SERIAL_ECHOLNPGM(__DATE__);
#endif // STRING_CONFIG_H_AUTHOR
#endif // STRING_VERSION_CONFIG_H
  SERIAL_ECHO_START;
  SERIAL_ECHOPGM(MSG_FREE_MEMORY);
  SERIAL_ECHO(freeMemory());
  SERIAL_ECHOPGM(MSG_PLANNER_BUFFER_BYTES);
  SERIAL_ECHOLN((int)sizeof(block_t)*BLOCK_BUFFER_SIZE);
  for(int8_t i = 0; i < BUFSIZE; i++){
    fromsd[i] = false;
  }

  // loads data from EEPROM if available else uses defaults (and resets step acceleration rate)
  Config_RetrieveSettings();

#ifdef EXTRUDERS
  tp_init();    // Initialize temperature loop
#endif // ifdef EXTRUDERS
  plan_init();  // Initialize planner;
  watchdog_init();
  st_init();    // Initialize stepper, this enables interrupts!
  setup_photpin();

#if defined(CONTROLLERFAN_PIN) && CONTROLLERFAN_PIN > -1
  SET_OUTPUT(CONTROLLERFAN_PIN); //Set pin used for driver cooling fan
#endif

#ifdef DIGIPOT_I2C
  digipot_i2c_init();
#endif
  setup_homepin();
}

void loop(){
  if(buflen < (BUFSIZE-1)) get_command();
#ifdef SDSUPPORT
  card.checkautostart(false);
#endif
  if(buflen){
#ifdef SDSUPPORT
    if(card.saving){
      if(strstr_P(cmdbuffer[bufindr], PSTR("M29")) == NULL){
        card.write_command(cmdbuffer[bufindr]);
        if(card.logging){
          process_commands();
        }else{
          SERIAL_PROTOCOLLNPGM(MSG_OK);
        }
      }else{
        card.closefile();
        SERIAL_PROTOCOLLNPGM(MSG_FILE_SAVED);
      }
    }else{
      process_commands();
    }
#else
    process_commands();
#endif //SDSUPPORT
    buflen = (buflen-1);
    bufindr = (bufindr + 1)%BUFSIZE;
  }
  //check heater every n milliseconds
#ifdef EXTRUDERS
  manage_heater();
#endif // ifdef EXTRUDERS
  manage_inactivity();
  //checkHitEndstops();
}

void get_command(){
  while(MYSERIAL.available() > 0  && buflen < BUFSIZE){
    serial_char = MYSERIAL.read(); // Gets ring_buffers tail byte and increments tail count
    if(serial_char == '\n' ||      // Found end of something
        serial_char == '\r' ||
        (serial_char == ':' && comment_mode == false) ||
        serial_count >= (MAX_CMD_SIZE - 1) ){
      if(!serial_count){ //if empty line
        comment_mode = false; //for new command
        return;
      }
      cmdbuffer[bufindw][serial_count] = '\0'; //terminate string
      if(!comment_mode){
        comment_mode = false; //for new command
        fromsd[bufindw] = false;
        if((strchr(cmdbuffer[bufindw], 'G') != NULL)){ // TODO: would be interesting to see how much time is spent in strchr. tobben 21 may 2015
          strchr_pointer = strchr(cmdbuffer[bufindw], 'G');
          // why not switch(atoi(strchr_pointer + 1)) ? tobben 21 may 2015
          switch((int)((strtod(&cmdbuffer[bufindw][strchr_pointer - cmdbuffer[bufindw] + 1], NULL)))){
            case 0:
            case 1:
            case 2:
            case 3:
              if(Stopped == true){
                SERIAL_ERRORLNPGM(MSG_ERR_STOPPED);
              }
              break;
            default:
              break;
          }
        }
        //If command was e-stop process now
        if(strcmp(cmdbuffer[bufindw], "M112") == 0)
          kill();
        bufindw = (bufindw + 1)%BUFSIZE; // Prepare for next command (code to prevent bufindw overflow must be somewhere. tobben 21 may 2015)
        buflen += 1;
      }
      serial_count = 0; //clear buffer (or start from beginning of cmdbuffer[bufindw]? tobben 21 may 2015)
    }else{
      if(serial_char == ';') comment_mode = true;
      if(!comment_mode) // cmdbuffer is filled with characters one by one here
        cmdbuffer[bufindw][serial_count++] = serial_char;
    }
  }
#ifdef SDSUPPORT
  if(!card.sdprinting || serial_count!=0){
    return;
  }

  //'#' stops reading from SD to the buffer prematurely, so procedural macro calls are possible
  // if it occurs, stop_buffering is triggered and the buffer is ran dry.
  // this character _can_ occur in serial com, due to checksums. however, no checksums are used in SD printing

  static bool stop_buffering=false;
  if(buflen==0) stop_buffering=false;

  while( !card.eof()  && buflen < BUFSIZE && !stop_buffering){
    int16_t n=card.get();
    serial_char = (char)n; // using the name serial_char here is not good since the char is not from serial. tobben 21 may 2015
    if(serial_char == '\n' ||
        serial_char == '\r' ||
        (serial_char == '#' && comment_mode == false) ||
        (serial_char == ':' && comment_mode == false) ||
        serial_count >= (MAX_CMD_SIZE - 1)||n==-1){
      if(card.eof()){
        SERIAL_PROTOCOLLNPGM(MSG_FILE_PRINTED);
        stoptime=millis();
        char time[30];
        unsigned long t=(stoptime-starttime)/1000;
        int hours, minutes;
        minutes=(t/60)%60;
        hours=t/60/60;
        sprintf_P(time, PSTR("%i hours %i minutes"),hours, minutes);
        SERIAL_ECHO_START;
        SERIAL_ECHOLN(time);
        card.printingHasFinished();
        card.checkautostart(true);

      }
      if(serial_char=='#')
        stop_buffering=true;

      if(!serial_count){
        comment_mode = false; //for new command
        return; //if empty line
      }
      cmdbuffer[bufindw][serial_count] = '\0'; //terminate string
      //      if(!comment_mode){
      fromsd[bufindw] = true;
      buflen += 1;
      bufindw = (bufindw + 1)%BUFSIZE;
      //      }
      comment_mode = false; //for new command
      serial_count = 0; //clear buffer
    }else{
      if(serial_char == ';') comment_mode = true;
      if(!comment_mode) cmdbuffer[bufindw][serial_count++] = serial_char;
    }
  }
#endif //SDSUPPORT
}

float code_value(){
  return (strtod(&cmdbuffer[bufindr][strchr_pointer - cmdbuffer[bufindr] + 1], NULL));
}

long code_value_long(){
  return (strtol(&cmdbuffer[bufindr][strchr_pointer - cmdbuffer[bufindr] + 1], NULL, 10));
}

bool code_seen(char code){
  strchr_pointer = strchr(cmdbuffer[bufindr], code);
  return (strchr_pointer != NULL);  //Return True if a character was found
}

#define DEFINE_PGM_READ_ANY(type, reader)       \
  static inline type pgm_read_any(const type *p)  \
{ return pgm_read_##reader##_near(p); }

DEFINE_PGM_READ_ANY(float,       float);
DEFINE_PGM_READ_ANY(signed char, byte);

#define XYZ_CONSTS_FROM_CONFIG(type, array, CONFIG) \
  static const PROGMEM type array##_P[3] =        \
{ X_##CONFIG, Y_##CONFIG, Z_##CONFIG };     \
static inline type array(int axis)          \
{ return pgm_read_any(&array##_P[axis]); }

XYZ_CONSTS_FROM_CONFIG(float, base_min_pos,    MIN_POS);
XYZ_CONSTS_FROM_CONFIG(float, base_max_pos,    MAX_POS);
XYZ_CONSTS_FROM_CONFIG(float, base_home_pos,   HOME_POS);
XYZ_CONSTS_FROM_CONFIG(float, max_length,      MAX_LENGTH);
XYZ_CONSTS_FROM_CONFIG(float, home_retract_mm, HOME_RETRACT_MM);
XYZ_CONSTS_FROM_CONFIG(signed char, home_dir,  HOME_DIR);

static void axis_is_at_home(int axis){
#ifdef SCARA
  float homeposition[3];
  char i;

  if(axis < 2){

    for (i=0; i<3; i++){
      homeposition[i] = base_home_pos(i); 
    }  
    // SERIAL_ECHOPGM("homeposition[x]= "); SERIAL_ECHO(homeposition[0]);
    //  SERIAL_ECHOPGM("homeposition[y]= "); SERIAL_ECHOLN(homeposition[1]);
    // Works out real Homeposition angles using inverse kinematics, 
    // and calculates homing offset using forward kinematics
    calculate_delta(homeposition);

    // SERIAL_ECHOPGM("base Theta= "); SERIAL_ECHO(delta[X_AXIS]);
    // SERIAL_ECHOPGM(" base Psi+Theta="); SERIAL_ECHOLN(delta[Y_AXIS]);

    for (i=0; i<2; i++){
      delta[i] -= add_homing[i];
    } 

    // SERIAL_ECHOPGM("addhome X="); SERIAL_ECHO(add_homing[X_AXIS]);
    // SERIAL_ECHOPGM(" addhome Y="); SERIAL_ECHO(add_homing[Y_AXIS]);
    // SERIAL_ECHOPGM(" addhome Theta="); SERIAL_ECHO(delta[X_AXIS]);
    // SERIAL_ECHOPGM(" addhome Psi+Theta="); SERIAL_ECHOLN(delta[Y_AXIS]);

    calculate_SCARA_forward_Transform(delta);

    // SERIAL_ECHOPGM("Delta X="); SERIAL_ECHO(delta[X_AXIS]);
    // SERIAL_ECHOPGM(" Delta Y="); SERIAL_ECHOLN(delta[Y_AXIS]);

    current_position[axis] = delta[axis];

    // SCARA home positions are based on configuration since the actual limits are determined by the 
    // inverse kinematic transform.
    min_pos[axis] =          base_min_pos(axis); // + (delta[axis] - base_home_pos(axis));
    max_pos[axis] =          base_max_pos(axis); // + (delta[axis] - base_home_pos(axis));
  } 
  else
  {
    current_position[axis] = base_home_pos(axis) + add_homing[axis];
    min_pos[axis] =          base_min_pos(axis) + add_homing[axis];
    max_pos[axis] =          base_max_pos(axis) + add_homing[axis];
  }
#else
  current_position[axis] = base_home_pos(axis) + add_homing[axis];
  min_pos[axis] =          base_min_pos(axis) + add_homing[axis];
  max_pos[axis] =          base_max_pos(axis) + add_homing[axis];
#endif
}

// TODO: Homing procedure goes here. tobben 8. sep 2015
static void homeaxis(int axis){}
//#define HOMEAXIS_DO(LETTER) \
//  ((LETTER##_MIN_PIN > -1 && LETTER##_HOME_DIR==-1) || (LETTER##_MAX_PIN > -1 && LETTER##_HOME_DIR==1))
//
//  if( axis==X_AXIS ? HOMEAXIS_DO(X) :
//      axis==Y_AXIS ? HOMEAXIS_DO(Y) :
//      axis==Z_AXIS ? HOMEAXIS_DO(Z) :
//      0){
//    int axis_home_dir = home_dir(axis);
//
//    current_position[axis] = 0;
//    calculate_delta(current_position);
//    plan_set_position(delta[A_AXIS],
//                      delta[B_AXIS],
//                      delta[C_AXIS],
//                      delta[D_AXIS],
//                      destination[E_CARTH]);
//
//    destination[axis] = 1.5 * max_length(axis) * axis_home_dir;
//    feedrate = homing_feedrate[axis];
//    plan_buffer_line(destination[X_AXIS],
//                     destination[Y_AXIS],
//                     destination[Z_AXIS],
//                     destination[E_CARTH], feedrate/60, active_extruder);
//    st_synchronize();
//
//    current_position[axis] = 0;
//    calculate_delta(current_position);
//    plan_set_position(delta[A_AXIS],
//                      delta[B_AXIS],
//                      delta[C_AXIS],
//                      delta[D_AXIS],
//                      destination[E_CARTH]);
//
//    destination[axis] = -home_retract_mm(axis) * axis_home_dir;
//    plan_buffer_line(destination[X_AXIS],
//                     destination[Y_AXIS],
//                     destination[Z_AXIS],
//                     destination[E_CARTH], feedrate/60, active_extruder);
//    st_synchronize();
//
//    destination[axis] = 2*home_retract_mm(axis) * axis_home_dir;
//    feedrate = homing_feedrate[axis]/10;
//    plan_buffer_line(destination[X_AXIS],
//                     destination[Y_AXIS],
//                     destination[Z_AXIS],
//                     destination[E_CARTH], feedrate/60, active_extruder);
//    st_synchronize();
//    // retrace by the amount specified in endstop_adj
//    if(endstop_adj[axis] * axis_home_dir < 0){
//      calculate_delta(current_position);
//      plan_set_position(delta[A_AXIS],
//                        delta[B_AXIS],
//                        delta[C_AXIS],
//                        delta[D_AXIS],
//                        destination[E_CARTH]);
//      destination[axis] = endstop_adj[axis];
//      plan_buffer_line(destination[X_AXIS],
//                       destination[Y_AXIS],
//                       destination[Z_AXIS],
//                       destination[E_CARTH], feedrate/60, active_extruder);
//      st_synchronize();
//    }
//    axis_is_at_home(axis);
//    destination[axis] = current_position[axis];
//    feedrate = 0.0;
//    endstops_hit_on_purpose();
//    axis_known_position[axis] = true;
//  }
//}
//#define HOMEAXIS(LETTER) homeaxis(LETTER##_AXIS)

void refresh_cmd_timeout(void){
  previous_millis_cmd = millis();
}

void process_commands(){
  unsigned long codenum; //throw away variable
  char *starpos = NULL;
  if(code_seen('G')){
    switch((int)code_value()){
      case 0: // G0 -> G1
        //SERIAL_ECHOPGM("Got G0");
        //break;
      case 1: // G1
        if(Stopped == false){
          //SERIAL_ECHOPGM("Not stopped");
          get_coordinates(); // Put X Y Z E into destination[] and update feedrate based on F
          prepare_move();
          //SERIAL_ECHOLN("Got past prepare_move");
          //ClearToSend();
        }
        break;
      case 90: // G90
        relative_mode = false;
        break;
      case 91: // G91
        relative_mode = true;
        break;
      case 92: // G92
        if(!code_seen(axis_codes_carthesian[E_AXIS]))
          st_synchronize();
        for(int8_t i=0; i < 4; i++){
          if(code_seen(axis_codes_carthesian[i])){
            if(i == E_CARTH){
              current_position[i] = code_value();
              plan_set_e_position(current_position[E_CARTH]);
            }else {
              current_position[i] = code_value();//+add_homing[i]; mixture of carthesian and hp-coord arrays. tobben 10 sep 2015
              calculate_delta(current_position);
              plan_set_position(delta[A_AXIS],
                                delta[B_AXIS],
                                delta[C_AXIS],
                                delta[D_AXIS],
                                destination[E_CARTH]);
            }
          }
        }
        break;
    }
  }

  else if(code_seen('M')){
    switch( (int)code_value() ){
      case 17:
        enable_x();
        enable_y();
        enable_z();
        enable_e0();
        enable_e1();
        break;

#ifdef SDSUPPORT
      case 20: // M20 - list SD card
        SERIAL_PROTOCOLLNPGM(MSG_BEGIN_FILE_LIST);
        card.ls();
        SERIAL_PROTOCOLLNPGM(MSG_END_FILE_LIST);
        break;
      case 21: // M21 - init SD card

        card.initsd();

        break;
      case 22: //M22 - release SD card
        card.release();

        break;
      case 23: //M23 - Select file
        starpos = (strchr(strchr_pointer + 4,'*'));
        if(starpos!=NULL)
          *(starpos)='\0';
        card.openFile(strchr_pointer + 4,true);
        break;
      case 24: //M24 - Start SD print
        card.startFileprint();
        starttime=millis();
        break;
      case 25: //M25 - Pause SD print
        card.pauseSDPrint();
        break;
      case 26: //M26 - Set SD index
        if(card.cardOK && code_seen('S')){
          card.setIndex(code_value_long());
        }
        break;
      case 27: //M27 - Get SD status
        card.getStatus();
        break;
      case 28: //M28 - Start SD write
        starpos = (strchr(strchr_pointer + 4,'*'));
        if(starpos != NULL){
          char* npos = strchr(cmdbuffer[bufindr], 'N');
          strchr_pointer = strchr(npos,' ') + 1;
          *(starpos) = '\0';
        }
        card.openFile(strchr_pointer+4,false);
        break;
      case 29: //M29 - Stop SD write
        //processed in write to file routine above
        //card,saving = false;
        break;
      case 30: //M30 <filename> Delete File
        if(card.cardOK){
          card.closefile();
          starpos = (strchr(strchr_pointer + 4,'*'));
          if(starpos != NULL){
            char* npos = strchr(cmdbuffer[bufindr], 'N');
            strchr_pointer = strchr(npos,' ') + 1;
            *(starpos) = '\0';
          }
          card.removeFile(strchr_pointer + 4);
        }
        break;
      case 32: //M32 - Select file and start SD print
        {
          if(card.sdprinting){
            st_synchronize();

          }
          starpos = (strchr(strchr_pointer + 4,'*'));

          char* namestartpos = (strchr(strchr_pointer + 4,'!'));   //find ! to indicate filename string start.
          if(namestartpos==NULL){
            namestartpos=strchr_pointer + 4; //default name position, 4 letters after the M
          }else
            namestartpos++; //to skip the '!'

          if(starpos!=NULL)
            *(starpos)='\0';

          bool call_procedure=(code_seen('P'));

          if(strchr_pointer>namestartpos)
            call_procedure=false;  //false alert, 'P' found within filename

          if( card.cardOK ){
            card.openFile(namestartpos,true,!call_procedure);
            if(code_seen('S'))
              if(strchr_pointer<namestartpos) //only if "S" is occuring _before_ the filename
                card.setIndex(code_value_long());
            card.startFileprint();
            if(!call_procedure)
              starttime=millis(); //procedure calls count as normal print time.
          }
        } break;
      case 928: //M928 - Start SD write
        starpos = (strchr(strchr_pointer + 5,'*'));
        if(starpos != NULL){
          char* npos = strchr(cmdbuffer[bufindr], 'N');
          strchr_pointer = strchr(npos,' ') + 1;
          *(starpos) = '\0';
        }
        card.openLogFile(strchr_pointer+5);
        break;

#endif //SDSUPPORT

      case 31: //M31 take time since the start of the SD print or an M109 command
        {
          stoptime=millis();
          char time[30];
          unsigned long t=(stoptime-starttime)/1000;
          int sec,min;
          min=t/60;
          sec=t%60;
          sprintf_P(time, PSTR("%i min, %i sec"), min, sec);
          SERIAL_ECHO_START;
          SERIAL_ECHOLN(time);
#ifdef EXTRUDERS
          autotempShutdown();
#endif // ifdef EXTRUDERS
        }
        break;
      case 42: //M42 -Change pin status via gcode
        if(code_seen('S')){
          int pin_status = code_value();
          int pin_number = LED_PIN;
          if(code_seen('P') && pin_status >= 0 && pin_status <= 255)
            pin_number = code_value();
          for(int8_t i = 0; i < (int8_t)(sizeof(sensitive_pins)/sizeof(int)); i++){
            if(sensitive_pins[i] == pin_number){
              pin_number = -1;
              break;
            }
          }
#if defined(FAN_PIN) && FAN_PIN > -1
          if(pin_number == FAN_PIN)
            fanSpeed = pin_status;
#endif
          if(pin_number > -1){
            pinMode(pin_number, OUTPUT);
            digitalWrite(pin_number, pin_status);
            analogWrite(pin_number, pin_status);
          }
        }
        break;

#ifdef EXTRUDERS
      case 104: // M104
        if(setTargetedHotend(104)){
          break;
        }
        if(code_seen('S')) setTargetHotend(code_value(), tmp_extruder);
        setWatch();
        break;
#endif // ifdef EXTRUDERS
      case 112: //  M112 -Emergency Stop
        kill();
        break;
#ifdef EXTRUDERS
      case 140: // M140 set bed temp
        if(code_seen('S')) setTargetBed(code_value());
        break;
      case 105 : // M105
        if(setTargetedHotend(105)){
          break;
        }
#if defined(TEMP_0_PIN) && TEMP_0_PIN > -1
        SERIAL_PROTOCOLPGM("ok T:");
        SERIAL_PROTOCOL_F(degHotend(tmp_extruder),1);
        SERIAL_PROTOCOLPGM(" /");
        SERIAL_PROTOCOL_F(degTargetHotend(tmp_extruder),1);
#if defined(TEMP_BED_PIN) && TEMP_BED_PIN > -1
        SERIAL_PROTOCOLPGM(" B:");
        SERIAL_PROTOCOL_F(degBed(),1);
        SERIAL_PROTOCOLPGM(" /");
        SERIAL_PROTOCOL_F(degTargetBed(),1);
#endif //TEMP_BED_PIN
        for (int8_t cur_extruder = 0; cur_extruder < EXTRUDERS; ++cur_extruder){
          SERIAL_PROTOCOLPGM(" T");
          SERIAL_PROTOCOL(cur_extruder);
          SERIAL_PROTOCOLPGM(":");
          SERIAL_PROTOCOL_F(degHotend(cur_extruder),1);
          SERIAL_PROTOCOLPGM(" /");
          SERIAL_PROTOCOL_F(degTargetHotend(cur_extruder),1);
        }
#else
        SERIAL_ERROR_START;
        SERIAL_ERRORLNPGM(MSG_ERR_NO_THERMISTORS);
#endif

        SERIAL_PROTOCOLPGM(" @:");
#ifdef EXTRUDER_WATTS
        SERIAL_PROTOCOL((EXTRUDER_WATTS * getHeaterPower(tmp_extruder))/127);
        SERIAL_PROTOCOLPGM("W");
#else
        SERIAL_PROTOCOL(getHeaterPower(tmp_extruder));
#endif

        SERIAL_PROTOCOLPGM(" B@:");
#ifdef BED_WATTS
        SERIAL_PROTOCOL((BED_WATTS * getHeaterPower(-1))/127);
        SERIAL_PROTOCOLPGM("W");
#else
        SERIAL_PROTOCOL(getHeaterPower(-1));
#endif

#ifdef SHOW_TEMP_ADC_VALUES
#if defined(TEMP_BED_PIN) && TEMP_BED_PIN > -1
        SERIAL_PROTOCOLPGM("    ADC B:");
        SERIAL_PROTOCOL_F(degBed(),1);
        SERIAL_PROTOCOLPGM("C->");
        SERIAL_PROTOCOL_F(rawBedTemp()/OVERSAMPLENR,0);
#endif
        for (int8_t cur_extruder = 0; cur_extruder < EXTRUDERS; ++cur_extruder){
          SERIAL_PROTOCOLPGM("  T");
          SERIAL_PROTOCOL(cur_extruder);
          SERIAL_PROTOCOLPGM(":");
          SERIAL_PROTOCOL_F(degHotend(cur_extruder),1);
          SERIAL_PROTOCOLPGM("C->");
          SERIAL_PROTOCOL_F(rawHotendTemp(cur_extruder)/OVERSAMPLENR,0);
        }
#endif

        SERIAL_PROTOCOLLN("");
        return;
        break;
      case 109: // M109 - Wait for extruder heater to reach target.
        if(setTargetedHotend(109)){
          break;
        }
        LCD_MESSAGEPGM(MSG_HEATING);
#ifdef AUTOTEMP
        autotemp_enabled=false;
#endif
        if(code_seen('S')){
          setTargetHotend(code_value(), tmp_extruder);
          CooldownNoWait = true;
        } else if(code_seen('R')){
          setTargetHotend(code_value(), tmp_extruder);
          CooldownNoWait = false;
        }
#ifdef AUTOTEMP
        if(code_seen('S')) autotemp_min=code_value();
        if(code_seen('B')) autotemp_max=code_value();
        if(code_seen('F')){
          autotemp_factor=code_value();
          autotemp_enabled=true;
        }
#endif
        setWatch();
        codenum = millis();

        /* See if we are heating up or cooling down */
        target_direction = isHeatingHotend(tmp_extruder); // true if heating, false if cooling

        cancel_heatup = false;

#ifdef TEMP_RESIDENCY_TIME
        long residencyStart;
        residencyStart = -1;
        /* continue to loop until we have reached the target temp
           _and_ until TEMP_RESIDENCY_TIME hasn't passed since we reached it */
        while((!cancel_heatup)&&((residencyStart == -1) ||
              (residencyStart >= 0 && (((unsigned int) (millis() - residencyStart)) < (TEMP_RESIDENCY_TIME * 1000UL)))) ){
#else
          while ( target_direction ? (isHeatingHotend(tmp_extruder)) : (isCoolingHotend(tmp_extruder)&&(CooldownNoWait==false)) ){
#endif //TEMP_RESIDENCY_TIME
            if( (millis() - codenum) > 1000UL )
            { //Print Temp Reading and remaining time every 1 second while heating up/cooling down
              SERIAL_PROTOCOLPGM("T:");
              SERIAL_PROTOCOL_F(degHotend(tmp_extruder),1);
              SERIAL_PROTOCOLPGM(" E:");
              SERIAL_PROTOCOL((int)tmp_extruder);
#ifdef TEMP_RESIDENCY_TIME
              SERIAL_PROTOCOLPGM(" W:");
              if(residencyStart > -1){
                codenum = ((TEMP_RESIDENCY_TIME * 1000UL) - (millis() - residencyStart)) / 1000UL;
                SERIAL_PROTOCOLLN( codenum );
              }else{
                SERIAL_PROTOCOLLN( "?" );
              }
#else
              SERIAL_PROTOCOLLN("");
#endif
              codenum = millis();
            }
            manage_heater();
            manage_inactivity();
            lcd_update();
#ifdef TEMP_RESIDENCY_TIME
            /* start/restart the TEMP_RESIDENCY_TIME timer whenever we reach target temp for the first time
               or when current temp falls outside the hysteresis after target temp was reached */
            if((residencyStart == -1 &&  target_direction && (degHotend(tmp_extruder) >= (degTargetHotend(tmp_extruder)-TEMP_WINDOW))) ||
                (residencyStart == -1 && !target_direction && (degHotend(tmp_extruder) <= (degTargetHotend(tmp_extruder)+TEMP_WINDOW))) ||
                (residencyStart > -1 && labs(degHotend(tmp_extruder) - degTargetHotend(tmp_extruder)) > TEMP_HYSTERESIS) ){
              residencyStart = millis();
            }
#endif //TEMP_RESIDENCY_TIME
          }
          LCD_MESSAGEPGM(MSG_HEATING_COMPLETE);
          starttime=millis();
          previous_millis_cmd = millis();
        }
        break;
      case 190: // M190 - Wait for bed heater to reach target.
#if defined(TEMP_BED_PIN) && TEMP_BED_PIN > -1
        LCD_MESSAGEPGM(MSG_BED_HEATING);
        if(code_seen('S')){
          setTargetBed(code_value());
          CooldownNoWait = true;
        } else if(code_seen('R')){
          setTargetBed(code_value());
          CooldownNoWait = false;
        }
        codenum = millis();

        cancel_heatup = false;
        target_direction = isHeatingBed(); // true if heating, false if cooling

        while ( (target_direction)&&(!cancel_heatup) ? (isHeatingBed()) : (isCoolingBed()&&(CooldownNoWait==false)) ){
          if(( millis() - codenum) > 1000 ) //Print Temp Reading every 1 second while heating up.
          {
            float tt=degHotend(active_extruder);
            SERIAL_PROTOCOLPGM("T:");
            SERIAL_PROTOCOL(tt);
            SERIAL_PROTOCOLPGM(" E:");
            SERIAL_PROTOCOL((int)active_extruder);
            SERIAL_PROTOCOLPGM(" B:");
            SERIAL_PROTOCOL_F(degBed(),1);
            SERIAL_PROTOCOLLN("");
            codenum = millis();
          }
          manage_heater();
          manage_inactivity();
          lcd_update();
        }
        LCD_MESSAGEPGM(MSG_BED_DONE);
        previous_millis_cmd = millis();
#endif
        break;

#if defined(FAN_PIN) && FAN_PIN > -1
#endif // ifdef EXTRUDERS loooong way up (above case: 140
      case 106: //M106 Fan On
        if(code_seen('S')){
          fanSpeed=constrain(code_value(),0,255);
        }else {
          fanSpeed=255;
        }
        break;
      case 107: //M107 Fan Off
        fanSpeed = 0;
        break;
#endif //FAN_PIN
#if defined(EXTRUDERS)
      case 82: // Set extruder relative mode
        axis_relative_modes[NUM_AXIS] = false;
        break;
      case 83:
        axis_relative_modes[NUM_AXIS] = true;
        break;
#endif
      case 92: // M92
        for(int8_t i=0; i < NUM_AXIS; i++){
          if(code_seen(axis_codes[i])){
            if(i == E_AXIS){ // E
              float value = code_value();
              if(value < 20.0){
                float factor = axis_steps_per_unit[i] / value; // increase e constants if M92 E14 is given for netfab.
                max_e_jerk *= factor;
                max_feedrate[i] *= factor;
                axis_steps_per_sqr_second[i] *= factor;
              }
              axis_steps_per_unit[i] = value;
            }else {
              axis_steps_per_unit[i] = code_value();
              //SERIAL_ECHO("Axis nr ");
              //SERIAL_ECHO(i);
              //SERIAL_ECHO(" got steps per unit: ");
              //SERIAL_ECHOLN(axis_steps_per_unit[i]);
            }
          }
        }
        calculate_delta(current_position);
        plan_set_position(delta[A_AXIS], delta[B_AXIS], delta[C_AXIS], delta[D_AXIS], destination[E_CARTH]); // Update step-count, keep old carth-position
        break;
      case 114: // M114
        SERIAL_ECHOLN("Current position in Carthesian system:");
        SERIAL_PROTOCOLPGM("X:");
        SERIAL_PROTOCOL(current_position[X_AXIS]);
        SERIAL_PROTOCOLPGM(" Y:");
        SERIAL_PROTOCOL(current_position[Y_AXIS]);
        SERIAL_PROTOCOLPGM(" Z:");
        SERIAL_PROTOCOL(current_position[Z_AXIS]);
        SERIAL_PROTOCOLPGM(" E:");
        SERIAL_PROTOCOL(current_position[E_CARTH]);

        SERIAL_PROTOCOLPGM("\nStep count along each motor abcd-axis:\nA:");
        SERIAL_PROTOCOL(st_get_position(A_AXIS));
        SERIAL_PROTOCOLPGM(" B:");
        SERIAL_PROTOCOL(st_get_position(B_AXIS));
        SERIAL_PROTOCOLPGM(" C:");
        SERIAL_PROTOCOL(st_get_position(C_AXIS));
        SERIAL_PROTOCOLPGM(" D:");
        SERIAL_PROTOCOL(st_get_position(D_AXIS));

        SERIAL_PROTOCOLPGM("\n Absolute line lengths:\n");
        SERIAL_PROTOCOL(float(st_get_position(A_AXIS))/axis_steps_per_unit[A_AXIS]);
        SERIAL_PROTOCOLPGM(" B:");
        SERIAL_PROTOCOL(float(st_get_position(B_AXIS))/axis_steps_per_unit[B_AXIS]);
        SERIAL_PROTOCOLPGM(" C:");
        SERIAL_PROTOCOL(float(st_get_position(C_AXIS))/axis_steps_per_unit[C_AXIS]);
        SERIAL_PROTOCOLPGM(" D:");
        SERIAL_PROTOCOL(float(st_get_position(D_AXIS))/axis_steps_per_unit[D_AXIS]);

        SERIAL_PROTOCOLLN("");
        break;
      case 120: // M120
        enable_endstops(false) ;
        break;
      case 121: // M121
        enable_endstops(true) ;
        break;
      case 119: // M119
        SERIAL_PROTOCOLLN(MSG_M119_REPORT);
#if defined(X_MIN_PIN) && X_MIN_PIN > -1
        SERIAL_PROTOCOLPGM(MSG_X_MIN);
        SERIAL_PROTOCOLLN(((READ(X_MIN_PIN)^X_MIN_ENDSTOP_INVERTING)?MSG_ENDSTOP_HIT:MSG_ENDSTOP_OPEN));
#endif
#if defined(X_MAX_PIN) && X_MAX_PIN > -1
        SERIAL_PROTOCOLPGM(MSG_X_MAX);
        SERIAL_PROTOCOLLN(((READ(X_MAX_PIN)^X_MAX_ENDSTOP_INVERTING)?MSG_ENDSTOP_HIT:MSG_ENDSTOP_OPEN));
#endif
#if defined(Y_MIN_PIN) && Y_MIN_PIN > -1
        SERIAL_PROTOCOLPGM(MSG_Y_MIN);
        SERIAL_PROTOCOLLN(((READ(Y_MIN_PIN)^Y_MIN_ENDSTOP_INVERTING)?MSG_ENDSTOP_HIT:MSG_ENDSTOP_OPEN));
#endif
#if defined(Y_MAX_PIN) && Y_MAX_PIN > -1
        SERIAL_PROTOCOLPGM(MSG_Y_MAX);
        SERIAL_PROTOCOLLN(((READ(Y_MAX_PIN)^Y_MAX_ENDSTOP_INVERTING)?MSG_ENDSTOP_HIT:MSG_ENDSTOP_OPEN));
#endif
#if defined(Z_MIN_PIN) && Z_MIN_PIN > -1
        SERIAL_PROTOCOLPGM(MSG_Z_MIN);
        SERIAL_PROTOCOLLN(((READ(Z_MIN_PIN)^Z_MIN_ENDSTOP_INVERTING)?MSG_ENDSTOP_HIT:MSG_ENDSTOP_OPEN));
#endif
#if defined(Z_MAX_PIN) && Z_MAX_PIN > -1
        SERIAL_PROTOCOLPGM(MSG_Z_MAX);
        SERIAL_PROTOCOLLN(((READ(Z_MAX_PIN)^Z_MAX_ENDSTOP_INVERTING)?MSG_ENDSTOP_HIT:MSG_ENDSTOP_OPEN));
#endif
        break;
        //TODO: update for all axis, use for loop
#ifdef EXTRUDERS
      case 200: // M200 D<millimeters> set filament diameter and set E axis units to cubic millimeters (use S0 to set back to millimeters).
        {

          tmp_extruder = active_extruder;
          if(code_seen('T')){
            tmp_extruder = code_value();
            if(tmp_extruder >= EXTRUDERS){
              SERIAL_ECHO_START;
              SERIAL_ECHO(MSG_M200_INVALID_EXTRUDER);
              break;
            }
          }

          float area = .0;
          if(code_seen('D')){
            float diameter = code_value();
            // setting any extruder filament size disables volumetric on the assumption that
            // slicers either generate in extruder values as cubic mm or as as filament feeds
            // for all extruders
            volumetric_enabled = (diameter != 0.0);
            if(volumetric_enabled){
              filament_size[tmp_extruder] = diameter;
              // make sure all extruders have some sane value for the filament size
              for (int i=0; i<EXTRUDERS; i++)
                if(! filament_size[i]) filament_size[i] = DEFAULT_NOMINAL_FILAMENT_DIA;
            }
          } else {
            //reserved for setting filament diameter via UFID or filament measuring device
            break;
          }
          calculate_volumetric_multipliers();
        }
        break;
#endif // ifdef EXTRUDERS
      case 201: // M201 // max_acceleration_units_per_sq_second is defined per abcd axis, so axis_codes ABCD here
        for(int8_t i=0; i < NUM_AXIS; i++){
          if(code_seen(axis_codes[i])){
            max_acceleration_units_per_sq_second[i] = code_value();
          }
        }
        // steps per sq second need to be updated to agree with the units per sq second (as they are what is used in the planner)
        reset_acceleration_rates();
        break;
      case 203: // M203 max feedrate mm/sec // max_feedrate[NUM_AXIS] is abcd axis, do axis_codes ABCD here
        for(int8_t i=0; i < NUM_AXIS; i++){
          if(code_seen(axis_codes[i])) max_feedrate[i] = code_value();
        }
        break;
      case 204: // M204 acclereration S normal moves T filmanent only moves
        {
          if(code_seen('S')) acceleration = code_value() ;
          if(code_seen('T')) retract_acceleration = code_value() ;
        }
        break;
      case 205: //M205 advanced settings:  minimum travel speed S=while printing T=travel only,  B=minimum segment time X= maximum xy jerk, Z=maximum Z jerk
        {
          if(code_seen('S')) minimumfeedrate = code_value();
          if(code_seen('T')) mintravelfeedrate = code_value();
          if(code_seen('B')) minsegmenttime = code_value() ;
          if(code_seen('X')) max_xy_jerk = code_value() ;
          if(code_seen('Z')) max_z_jerk = code_value() ;
          if(code_seen('E')) max_e_jerk = code_value() ;
        }
        break;
#ifdef DELTA
      case 665: 
        // M665 set delta config
#ifdef HANGPRINTER
        // Hangprinter config:
        // Q<Ax> W<Ay> E<Az> R<Bx> T<By> Y<Bz> U<Cx> I<Cy> O<Cz> P<Dz> S<segments_per_sec>
        if(code_seen('Q')) anchor_A_x = code_value();
        if(code_seen('W')) anchor_A_y = code_value();
        if(code_seen('E')) anchor_A_z = code_value();
        if(code_seen('R')) anchor_B_x = code_value();
        if(code_seen('T')) anchor_B_y = code_value();
        if(code_seen('Y')) anchor_B_z = code_value();
        if(code_seen('U')) anchor_C_x = code_value();
        if(code_seen('I')) anchor_C_y = code_value();
        if(code_seen('O')) anchor_C_z = code_value();
        if(code_seen('P')) anchor_D_z = code_value();
#else // M665 set delta configurations L<diagonal_rod> R<delta_radius> S<segments_per_sec>
        if(code_seen('L')){
          delta_diagonal_rod= code_value();
        }
        if(code_seen('R')){
          delta_radius= code_value();
        }
        recalc_delta_settings(delta_radius, delta_diagonal_rod);
#endif // HANGPRINTER
        if(code_seen('S')){
          delta_segments_per_second= code_value();
        }
        break;
      case 666: // M666 set delta endstop adjustemnt // ABCD needs one endstop each so axis_codes ABCD here
        for(int8_t i=0; i < 3; i++){
          if(code_seen(axis_codes[i])) endstop_adj[i] = code_value();
        }
        break;
#endif // DELTA
      case 220: // M220 S<factor in percent>- set speed factor override percentage
        {
          if(code_seen('S')){
            feedmultiply = code_value() ;
          }
        }
        break;
#ifdef EXTRUDERS
      case 221: // M221 S<factor in percent>- set extrude factor override percentage
        {
          if(code_seen('S')){
            int tmp_code = code_value();
            if(code_seen('T')){
              if(setTargetedHotend(221)){
                break;
              }
              extruder_multiply[tmp_extruder] = tmp_code;
            }else{
              extrudemultiply = tmp_code ;
            }
          }
        }
        break;
#endif // ifdef EXTRUDERS
      case 226: // M226 P<pin number> S<pin state>- Wait until the specified pin reaches the state required
        {
          if(code_seen('P')){
            int pin_number = code_value(); // pin number
            int pin_state = -1; // required pin state - default is inverted

            if(code_seen('S')) pin_state = code_value(); // required pin state

            if(pin_state >= -1 && pin_state <= 1){

              for(int8_t i = 0; i < (int8_t)(sizeof(sensitive_pins)/sizeof(int)); i++){
                if(sensitive_pins[i] == pin_number){
                  pin_number = -1;
                  break;
                }
              }

              if(pin_number > -1){
                int target = LOW;

                st_synchronize();

                pinMode(pin_number, INPUT);

                switch(pin_state){
                  case 1:
                    target = HIGH;
                    break;

                  case 0:
                    target = LOW;
                    break;

                  case -1:
                    target = !digitalRead(pin_number);
                    break;
                }

                while(digitalRead(pin_number) != target){
#ifdef EXTRUDERS
                  manage_heater();
#endif // ifdef EXTRUDERS
                  manage_inactivity();
                }
              }
            }
          }
        }
        break;
#if(LARGE_FLASH == true && ( BEEPER > 0 || defined(ULTRALCD) || defined(LCD_USE_I2C_BUZZER)))
      case 300: // M300
        {
          int beepS = code_seen('S') ? code_value() : 110;
          int beepP = code_seen('P') ? code_value() : 1000;
          if(beepS > 0){
#if BEEPER > 0
            tone(BEEPER, beepS);
            delay(beepP);
            noTone(BEEPER);
#elif defined(ULTRALCD)
            lcd_buzz(beepS, beepP);
#elif defined(LCD_USE_I2C_BUZZER)
            lcd_buzz(beepP, beepS);
#endif
          }else{
            delay(beepP);
          }
        }
        break;
#endif // M300

#ifdef PIDTEMP
#ifdef EXTRUDERS
      case 301: // M301
        {
          // multi-extruder PID patch: M301 updates or prints a single extruder's PID values
          // default behaviour (omitting E parameter) is to update for extruder 0 only
          int e = 0; // extruder being updated
          if(code_seen('E')){
            e = (int)code_value();
          }
          if(e < EXTRUDERS) // catch bad input value
          {

            if(code_seen('P')) PID_PARAM(Kp,e) = code_value();
            if(code_seen('I')) PID_PARAM(Ki,e) = scalePID_i(code_value());
            if(code_seen('D')) PID_PARAM(Kd,e) = scalePID_d(code_value());
#ifdef PID_ADD_EXTRUSION_RATE
            if(code_seen('C')) PID_PARAM(Kc,e) = code_value();
#endif			

            updatePID();
            SERIAL_PROTOCOL(MSG_OK);
#ifdef PID_PARAMS_PER_EXTRUDER
            SERIAL_PROTOCOL(" e:"); // specify extruder in serial output
            SERIAL_PROTOCOL(e);
#endif // PID_PARAMS_PER_EXTRUDER
            SERIAL_PROTOCOL(" p:");
            SERIAL_PROTOCOL(PID_PARAM(Kp,e));
            SERIAL_PROTOCOL(" i:");
            SERIAL_PROTOCOL(unscalePID_i(PID_PARAM(Ki,e)));
            SERIAL_PROTOCOL(" d:");
            SERIAL_PROTOCOL(unscalePID_d(PID_PARAM(Kd,e)));
#ifdef PID_ADD_EXTRUSION_RATE
            SERIAL_PROTOCOL(" c:");
            //Kc does not have scaling applied above, or in resetting defaults
            SERIAL_PROTOCOL(PID_PARAM(Kc,e));
#endif
            SERIAL_PROTOCOLLN("");

          }else{
            SERIAL_ECHO_START;
            SERIAL_ECHOLN(MSG_INVALID_EXTRUDER);
          }

        }
        break;
#endif // ifdef EXTRUDERS
#endif //PIDTEMP
#ifdef PIDTEMPBED
      case 304: // M304
        {
          if(code_seen('P')) bedKp = code_value();
          if(code_seen('I')) bedKi = scalePID_i(code_value());
          if(code_seen('D')) bedKd = scalePID_d(code_value());

          updatePID();
          SERIAL_PROTOCOL(MSG_OK);
          SERIAL_PROTOCOL(" p:");
          SERIAL_PROTOCOL(bedKp);
          SERIAL_PROTOCOL(" i:");
          SERIAL_PROTOCOL(unscalePID_i(bedKi));
          SERIAL_PROTOCOL(" d:");
          SERIAL_PROTOCOL(unscalePID_d(bedKd));
          SERIAL_PROTOCOLLN("");
        }
        break;
#endif //PIDTEMP
#ifdef EXTRUDERS
#ifdef PREVENT_DANGEROUS_EXTRUDE
      case 302: // allow cold extrudes, or set the minimum extrude temperature
        {
          float temp = .0;
          if(code_seen('S')) temp=code_value();
          set_extrude_min_temp(temp);
        }
        break;
#endif
      case 303: // M303 PID autotune
        {
          float temp = 150.0;
          int e=0;
          int c=5;
          if(code_seen('E')) e=code_value();
          if(e<0)
            temp=70;
          if(code_seen('S')) temp=code_value();
          if(code_seen('C')) c=code_value();
          PID_autotune(temp, e, c);
        }
        break;
#endif // ifdef EXTRUDERS
      case 400: // M400 finish all moves
        {
          st_synchronize();
        }
        break;
      case 500: // M500 Store settings in EEPROM
        {
          Config_StoreSettings();
        }
        break;
      case 501: // M501 Read settings from EEPROM
        {
          Config_RetrieveSettings();
        }
        break;
      case 502: // M502 Revert to default settings
        {
          Config_ResetDefault();
        }
        break;
      case 503: // M503 print settings currently in memory
        {
          Config_PrintSettings(code_seen('S') && code_value == 0);
        }
        break;
#ifdef ABORT_ON_ENDSTOP_HIT_FEATURE_ENABLED
      case 540:
        {
          if(code_seen('S')) abort_on_endstop_hit = code_value() > 0;
        }
        break;
#endif
      case 350: // M350 Set microstepping mode. Warning: Steps per unit remains unchanged. S code sets stepping mode for all drivers.
        {
#if defined(X_MS1_PIN) && X_MS1_PIN > -1
          if(code_seen('S')) for(int i=0;i<=NUM_AXIS;i++) microstep_mode(i,code_value());
          for(int i=0;i<NUM_AXIS;i++) if(code_seen(axis_codes[i])) microstep_mode(i,(uint8_t)code_value());
          if(code_seen('B')) microstep_mode(4,code_value());
          microstep_readings();
#endif
        }
        break;
      case 351: // M351 Toggle MS1 MS2 pins directly, S# determines MS1 or MS2, X# sets the pin high/low.
        {
#if defined(X_MS1_PIN) && X_MS1_PIN > -1
          if(code_seen('S')) switch((int)code_value()){
            case 1:
              for(int i=0;i<NUM_AXIS;i++) if(code_seen(axis_codes[i])) microstep_ms(i,code_value(),-1);
              if(code_seen('B')) microstep_ms(4,code_value(),-1);
              break;
            case 2:
              for(int i=0;i<NUM_AXIS;i++) if(code_seen(axis_codes[i])) microstep_ms(i,-1,code_value());
              if(code_seen('B')) microstep_ms(4,-1,code_value());
              break;
          }
          microstep_readings();
#endif
        }
        break;
      case 999: // M999: Restart after being stopped
        Stopped = false;
        gcode_LastN = Stopped_gcode_LastN;
        FlushSerialRequestResend();
        break;
    }
  }

#ifdef EXTRUDERS
  else if(code_seen('T')){
    tmp_extruder = code_value();
    if(tmp_extruder >= EXTRUDERS){
      SERIAL_ECHO_START;
      SERIAL_ECHO("T");
      SERIAL_ECHO(tmp_extruder);
      SERIAL_ECHOLN(MSG_INVALID_EXTRUDER);
    }else {
      boolean make_move = false;
      if(code_seen('F')){
        make_move = true;
        next_feedrate = code_value();
        if(next_feedrate > 0.0){
          feedrate = next_feedrate;
        }
      }
      SERIAL_ECHO_START;
      SERIAL_ECHO(MSG_ACTIVE_EXTRUDER);
      SERIAL_PROTOCOLLN((int)active_extruder);
    }
  }
#endif //ifdef EXTRUDERS

  else
  {
    SERIAL_ECHO_START;
    SERIAL_ECHOPGM(MSG_UNKNOWN_COMMAND);
    SERIAL_ECHO(cmdbuffer[bufindr]);
    SERIAL_ECHOLNPGM("\"");
  }

  ClearToSend();
}

void FlushSerialRequestResend(){
  //char cmdbuffer[bufindr][100]="Resend:";
  MYSERIAL.flush();
  SERIAL_PROTOCOLPGM(MSG_RESEND);
  SERIAL_PROTOCOLLN(gcode_LastN + 1);
  ClearToSend();
}

void ClearToSend(){
  previous_millis_cmd = millis();
#ifdef SDSUPPORT
  if(fromsd[bufindr])
    return;
#endif //SDSUPPORT
  SERIAL_PROTOCOLLNPGM(MSG_OK);
}

void get_coordinates(){
  for(int8_t i=0; i < 4; i++){
    if(code_seen(axis_codes_carthesian[i])){ // No float casting should be needed. code_value returns float. tobben 21 may 2015
      destination[i] = (float)code_value() + (axis_relative_modes[i] || relative_mode)*current_position[i];
    }else destination[i] = current_position[i];
  }
  if(code_seen('F')){
    next_feedrate = code_value();
    if(next_feedrate > 0.0) feedrate = next_feedrate;
  }
  //SERIAL_ECHO("destination[0]: ");
  //SERIAL_ECHOLN(destination[0]);
  //SERIAL_ECHO("destination[1]: ");
  //SERIAL_ECHOLN(destination[1]);
  //SERIAL_ECHO("destination[2]: ");
  //SERIAL_ECHOLN(destination[2]);
  //SERIAL_ECHO("destination[3]: ");
  //SERIAL_ECHOLN(destination[3]);
}

void get_arc_coordinates(){
#ifdef SF_ARC_FIX
  bool relative_mode_backup = relative_mode;
  relative_mode = true;
#endif
  get_coordinates();
#ifdef SF_ARC_FIX
  relative_mode=relative_mode_backup;
#endif

  if(code_seen('I')){
    offset[0] = code_value();
  }else {
    offset[0] = 0.0;
  }
  if(code_seen('J')){
    offset[1] = code_value();
  }else {
    offset[1] = 0.0;
  }
}

#if defined(DELTA) && !defined(HANGPRINTER) // Not available for HANGPRINTER
void recalc_delta_settings(float radius, float diagonal_rod){
  delta_tower1_x= -SIN_60*radius; // front left tower
  delta_tower1_y= -COS_60*radius;	   
  delta_tower2_x=  SIN_60*radius; // front right tower
  delta_tower2_y= -COS_60*radius;	   
  delta_tower3_x= 0.0;                  // back middle tower
  delta_tower3_y= radius;
  delta_diagonal_rod_2= sq(diagonal_rod);
}
#endif

void calculate_delta(float cartesian[3]) // array destination[3] filled with absolute coordinates is fed into this. tobben 20. may 2015
{
  // With current calculations delta will contain the new absolute coordinate
  delta[A_AXIS] = sqrt(sq(anchor_A_x - cartesian[X_AXIS])
                     + sq(anchor_A_y - cartesian[Y_AXIS])
                     + sq(anchor_A_z - cartesian[Z_AXIS])); //-DELTA_RADIUS
  delta[B_AXIS] = sqrt(sq(anchor_B_x - cartesian[X_AXIS])
                     + sq(anchor_B_y - cartesian[Y_AXIS])
                     + sq(anchor_B_z - cartesian[Z_AXIS])); //-DELTA_RADIUS
  //SERIAL_ECHOLN("anchor_C_x");
  //SERIAL_ECHOLN(anchor_C_x);
  //SERIAL_ECHOLN("anchor_C_y");
  //SERIAL_ECHOLN(anchor_C_y);
  //SERIAL_ECHOLN("anchor_C_z");
  //SERIAL_ECHOLN(anchor_C_z);
  //SERIAL_ECHOLN("cartesian[X_AXIS]");
  //SERIAL_ECHOLN(cartesian[X_AXIS]);
  //SERIAL_ECHOLN("cartesian[Y_AXIS]");
  //SERIAL_ECHOLN(cartesian[Y_AXIS]);
  //SERIAL_ECHOLN("cartesian[Z_AXIS]");
  //SERIAL_ECHOLN(cartesian[Z_AXIS]);
  // TODO: when using anchor_C_x it get overwritten, so we have serious overflow problems in our code...
  delta[C_AXIS] = sqrt(sq(anchor_C_x - cartesian[X_AXIS])
                     + sq(anchor_C_y - cartesian[Y_AXIS])
                     + sq(anchor_C_z - cartesian[Z_AXIS])); //-DELTA_RADIUS
  delta[D_AXIS] = sqrt(sq(             cartesian[X_AXIS])
                     + sq(             cartesian[Y_AXIS])
                     + sq(anchor_D_z - cartesian[Z_AXIS])); //-DELTA_RADIUS

  //SERIAL_ECHOPGM(" x="); SERIAL_ECHOLN(cartesian[X_AXIS]);
  //SERIAL_ECHOPGM(" y="); SERIAL_ECHOLN(cartesian[Y_AXIS]);
  //SERIAL_ECHOPGM(" z="); SERIAL_ECHOLN(cartesian[Z_AXIS]);

  //SERIAL_ECHOPGM(" a="); SERIAL_ECHOLN(delta[A_AXIS]);
  //SERIAL_ECHOPGM(" b="); SERIAL_ECHOLN(delta[B_AXIS]);
  //SERIAL_ECHOPGM(" c="); SERIAL_ECHOLN(delta[C_AXIS]);
  //SERIAL_ECHOPGM(" d="); SERIAL_ECHOLN(delta[D_AXIS]);

}

void prepare_move(){
  previous_millis_cmd = millis();

  // TODO: Make separate HANGPRINTER version of prepare_move(). tobben 20. may 2015
  float difference[4]; // difference will be in gcode Carthesian xyze. tobben 21. may 2015
  for (int8_t i=0; i < 4; i++){ // if we are in relative mode we could wait with making destination global to after this. tobben 21. may 2015
    difference[i] = destination[i] - current_position[i];
  }
  float cartesian_mm = sqrt(sq(difference[X_AXIS]) +
      sq(difference[Y_AXIS]) +
      sq(difference[Z_AXIS]));
  if(cartesian_mm < 0.000001){ cartesian_mm = abs(difference[E_CARTH]); }
  if(cartesian_mm < 0.000001){ return; }
  float seconds = 6000 * cartesian_mm / feedrate / feedmultiply;
  int steps = max(1, int(delta_segments_per_second * seconds));
  // SERIAL_ECHOPGM("mm="); SERIAL_ECHO(cartesian_mm);
  // SERIAL_ECHOPGM(" seconds="); SERIAL_ECHO(seconds);
  // SERIAL_ECHOPGM(" steps="); SERIAL_ECHOLN(steps);
  for (int s = 1; s <= steps; s++){ // Here lines are split into segments. tobben 20. may 2015
    float fraction = float(s) / float(steps);
    for(int8_t i=0; i < 4; i++){
      destination[i] = current_position[i] + difference[i] * fraction;
    }
    //SERIAL_ECHO(destination[0]);
    //SERIAL_ECHO("\n");
    //SERIAL_ECHO(destination[1]);
    //SERIAL_ECHO("\n");
    //SERIAL_ECHO(destination[2]);
    //SERIAL_ECHO("\n");
    //SERIAL_ECHO(destination[3]);
    //SERIAL_ECHO("\n");
    calculate_delta(destination); // delta will be in hangprinter abcde coords
    // TODO: plan_buffer_line must be specific for HANGPRINTER too. tobben 20. may 2015
    plan_buffer_line(delta[A_AXIS], delta[B_AXIS], delta[C_AXIS], delta[D_AXIS],
        destination[E_CARTH], feedrate*feedmultiply/60/100.0,
        active_extruder);
    //SERIAL_ECHOLN("Got past plan_buffer_line");
  }

  for(int8_t i=0; i < 4; i++){
    current_position[i] = destination[i];
  }
}

void prepare_arc_move(char isclockwise){
  float r = hypot(offset[X_AXIS], offset[Y_AXIS]); // Compute arc radius for mc_arc

  // Trace the arc
  mc_arc(current_position, destination, offset, X_AXIS, Y_AXIS, Z_AXIS, feedrate*feedmultiply/60/100.0, r, isclockwise, active_extruder);

  // As far as the parser is concerned, the position is now == target. In reality the
  // motion control system might still be processing the action and the real tool position
  // in any intermediate location.
  for(int8_t i=0; i < 4; i++){
    current_position[i] = destination[i];
  }
  previous_millis_cmd = millis();
}

#if defined(CONTROLLERFAN_PIN) && CONTROLLERFAN_PIN > -1

#if defined(FAN_PIN)
#if CONTROLLERFAN_PIN == FAN_PIN
#error "You cannot set CONTROLLERFAN_PIN equal to FAN_PIN"
#endif
#endif

unsigned long lastMotor = 0; //Save the time for when a motor was turned on last
unsigned long lastMotorCheck = 0;

void controllerFan(){
  if((millis() - lastMotorCheck) >= 2500) //Not a time critical function, so we only check every 2500ms
  {
    lastMotorCheck = millis();

    if(!READ(X_ENABLE_PIN) || !READ(Y_ENABLE_PIN) || !READ(Z_ENABLE_PIN) || (soft_pwm_bed > 0)
#if EXTRUDERS > 2
        || !READ(E2_ENABLE_PIN)
#endif
#if EXTRUDER > 1
#if defined(X2_ENABLE_PIN) && X2_ENABLE_PIN > -1
        || !READ(X2_ENABLE_PIN)
#endif
        || !READ(E1_ENABLE_PIN)
#endif
        || !READ(E0_ENABLE_PIN)) //If any of the drivers are enabled...
    {
      lastMotor = millis(); //... set time to NOW so the fan will turn on
    }

    if((millis() - lastMotor) >= (CONTROLLERFAN_SECS*1000UL) || lastMotor == 0) //If the last time any driver was enabled, is longer since than CONTROLLERSEC...
    {
      digitalWrite(CONTROLLERFAN_PIN, 0);
      analogWrite(CONTROLLERFAN_PIN, 0);
    }else{
      // allows digital or PWM fan output to be used (see M42 handling)
      digitalWrite(CONTROLLERFAN_PIN, CONTROLLERFAN_SPEED);
      analogWrite(CONTROLLERFAN_PIN, CONTROLLERFAN_SPEED);
    }
  }
}
#endif

#ifdef SCARA
void calculate_SCARA_forward_Transform(float f_scara[3]){
  // Perform forward kinematics, and place results in delta[3]
  // The maths and first version has been done by QHARLEY . Integrated into masterbranch 06/2014 and slightly restructured by Joachim Cerny in June 2014

  float x_sin, x_cos, y_sin, y_cos;

  //SERIAL_ECHOPGM("f_delta x="); SERIAL_ECHO(f_scara[X_AXIS]);
  //SERIAL_ECHOPGM(" y="); SERIAL_ECHO(f_scara[Y_AXIS]);

  x_sin = sin(f_scara[X_AXIS]/SCARA_RAD2DEG) * Linkage_1;
  x_cos = cos(f_scara[X_AXIS]/SCARA_RAD2DEG) * Linkage_1;
  y_sin = sin(f_scara[Y_AXIS]/SCARA_RAD2DEG) * Linkage_2;
  y_cos = cos(f_scara[Y_AXIS]/SCARA_RAD2DEG) * Linkage_2;

  //  SERIAL_ECHOPGM(" x_sin="); SERIAL_ECHO(x_sin);
  //  SERIAL_ECHOPGM(" x_cos="); SERIAL_ECHO(x_cos);
  //  SERIAL_ECHOPGM(" y_sin="); SERIAL_ECHO(y_sin);
  //  SERIAL_ECHOPGM(" y_cos="); SERIAL_ECHOLN(y_cos);

  delta[X_AXIS] = x_cos + y_cos + SCARA_offset_x;  //theta
  delta[Y_AXIS] = x_sin + y_sin + SCARA_offset_y;  //theta+phi

  //SERIAL_ECHOPGM(" delta[X_AXIS]="); SERIAL_ECHO(delta[X_AXIS]);
  //SERIAL_ECHOPGM(" delta[Y_AXIS]="); SERIAL_ECHOLN(delta[Y_AXIS]);
}  

void calculate_delta(float cartesian[3]){
  //reverse kinematics.
  // Perform reversed kinematics, and place results in delta[3]
  // The maths and first version has been done by QHARLEY . Integrated into masterbranch 06/2014 and slightly restructured by Joachim Cerny in June 2014

  float SCARA_pos[2];
  static float SCARA_C2, SCARA_S2, SCARA_K1, SCARA_K2, SCARA_theta, SCARA_psi; 

  SCARA_pos[X_AXIS] = cartesian[X_AXIS] * axis_scaling[X_AXIS] - SCARA_offset_x;  //Translate SCARA to standard X Y
  SCARA_pos[Y_AXIS] = cartesian[Y_AXIS] * axis_scaling[Y_AXIS] - SCARA_offset_y;  // With scaling factor.

#if (Linkage_1 == Linkage_2)
  SCARA_C2 = ( ( sq(SCARA_pos[X_AXIS]) + sq(SCARA_pos[Y_AXIS]) ) / (2 * (float)L1_2) ) - 1;
#else
  SCARA_C2 =   ( sq(SCARA_pos[X_AXIS]) + sq(SCARA_pos[Y_AXIS]) - (float)L1_2 - (float)L2_2 ) / 45000; 
#endif

  SCARA_S2 = sqrt( 1 - sq(SCARA_C2) );

  SCARA_K1 = Linkage_1 + Linkage_2 * SCARA_C2;
  SCARA_K2 = Linkage_2 * SCARA_S2;

  SCARA_theta = ( atan2(SCARA_pos[X_AXIS],SCARA_pos[Y_AXIS])-atan2(SCARA_K1, SCARA_K2) ) * -1;
  SCARA_psi   =   atan2(SCARA_S2,SCARA_C2);

  delta[X_AXIS] = SCARA_theta * SCARA_RAD2DEG;  // Multiply by 180/Pi  -  theta is support arm angle
  delta[Y_AXIS] = (SCARA_theta + SCARA_psi) * SCARA_RAD2DEG;  //       -  equal to sub arm angle (inverted motor)
  delta[Z_AXIS] = cartesian[Z_AXIS];

  /*
     SERIAL_ECHOPGM("cartesian x="); SERIAL_ECHO(cartesian[X_AXIS]);
     SERIAL_ECHOPGM(" y="); SERIAL_ECHO(cartesian[Y_AXIS]);
     SERIAL_ECHOPGM(" z="); SERIAL_ECHOLN(cartesian[Z_AXIS]);

     SERIAL_ECHOPGM("scara x="); SERIAL_ECHO(SCARA_pos[X_AXIS]);
     SERIAL_ECHOPGM(" y="); SERIAL_ECHOLN(SCARA_pos[Y_AXIS]);

     SERIAL_ECHOPGM("delta x="); SERIAL_ECHO(delta[X_AXIS]);
     SERIAL_ECHOPGM(" y="); SERIAL_ECHO(delta[Y_AXIS]);
     SERIAL_ECHOPGM(" z="); SERIAL_ECHOLN(delta[Z_AXIS]);

     SERIAL_ECHOPGM("C2="); SERIAL_ECHO(SCARA_C2);
     SERIAL_ECHOPGM(" S2="); SERIAL_ECHO(SCARA_S2);
     SERIAL_ECHOPGM(" Theta="); SERIAL_ECHO(SCARA_theta);
     SERIAL_ECHOPGM(" Psi="); SERIAL_ECHOLN(SCARA_psi);
     SERIAL_ECHOLN(" ");*/
}

#endif

#ifdef TEMP_STAT_LEDS
static bool blue_led = false;
static bool red_led = false;
static uint32_t stat_update = 0;

void handle_status_leds(void){
  float max_temp = 0.0;
  if(millis() > stat_update){
    stat_update += 500; // Update every 0.5s
#ifdef EXTRUDERS
    for (int8_t cur_extruder = 0; cur_extruder < EXTRUDERS; ++cur_extruder){
      max_temp = max(max_temp, degHotend(cur_extruder));
      max_temp = max(max_temp, degTargetHotend(cur_extruder));
    }
#endif
#if defined(TEMP_BED_PIN) && TEMP_BED_PIN > -1
    max_temp = max(max_temp, degTargetBed());
    max_temp = max(max_temp, degBed());
#endif
    if((max_temp > 55.0) && (red_led == false)){
      digitalWrite(STAT_LED_RED, 1);
      digitalWrite(STAT_LED_BLUE, 0);
      red_led = true;
      blue_led = false;
    }
    if((max_temp < 54.0) && (blue_led == false)){
      digitalWrite(STAT_LED_RED, 0);
      digitalWrite(STAT_LED_BLUE, 1);
      red_led = false;
      blue_led = true;
    }
  }
}
#endif

void manage_inactivity(bool ignore_stepper_queue/*=false*/) //default argument set in Marlin.h
{

#if defined(KILL_PIN) && KILL_PIN > -1
  static int killCount = 0;   // make the inactivity button a bit less responsive
  const int KILL_DELAY = 10000;
#endif

#if defined(HOME_PIN) && HOME_PIN > -1
  static int homeDebounceCount = 0;   // poor man's debouncing count
  const int HOME_DEBOUNCE_DELAY = 10000;
#endif


  if(buflen < (BUFSIZE-1))
    get_command();

  if( (millis() - previous_millis_cmd) >  max_inactive_time )
    if(max_inactive_time)
      kill();
  if(stepper_inactive_time){
    if( (millis() - previous_millis_cmd) >  stepper_inactive_time ){
      if(blocks_queued() == false && ignore_stepper_queue == false){
        disable_x();
        disable_y();
        disable_z();
        disable_e0();
        disable_e1();
      }
    }
  }

#ifdef CHDK //Check if pin should be set to LOW after M240 set it to HIGH
  if(chdkActive && (millis() - chdkHigh > CHDK_DELAY)){
    chdkActive = false;
    WRITE(CHDK, LOW);
  }
#endif

#if defined(KILL_PIN) && KILL_PIN > -1

  // Check if the kill button was pressed and wait just in case it was an accidental
  // key kill key press
  // -------------------------------------------------------------------------------
  if( 0 == READ(KILL_PIN) ){
    killCount++;
  }else if(killCount > 0){
    killCount--;
  }
  // Exceeded threshold and we can confirm that it was not accidental
  // KILL the machine
  // ----------------------------------------------------------------
  if( killCount >= KILL_DELAY){
    kill();
  }
#endif

#if defined(HOME_PIN) && HOME_PIN > -1
  // Check to see if we have to home, use poor man's debouncer
  // ---------------------------------------------------------
  if( 0 == READ(HOME_PIN) ){
    if(homeDebounceCount == 0){
      enquecommand_P((PSTR("G28")));
      homeDebounceCount++;
      LCD_ALERTMESSAGEPGM(MSG_AUTO_HOME);
    }else if(homeDebounceCount < HOME_DEBOUNCE_DELAY){
      homeDebounceCount++;
    }else{
      homeDebounceCount = 0;
    }
  }
#endif

#if defined(CONTROLLERFAN_PIN) && CONTROLLERFAN_PIN > -1
  controllerFan(); //Check if fan should be turned on to cool stepper drivers down
#endif
#ifdef EXTRUDER_RUNOUT_PREVENT
  if( (millis() - previous_millis_cmd) >  EXTRUDER_RUNOUT_SECONDS*1000 )
    if(degHotend(active_extruder)>EXTRUDER_RUNOUT_MINTEMP){
      bool oldstatus=READ(E0_ENABLE_PIN);
      enable_e0();
      float oldepos=current_position[E_CARTH];
      float oldedes=destination[E_CARTH];
      plan_buffer_line(destination[X_AXIS], destination[Y_AXIS], destination[Z_AXIS],
          destination[E_CARTH]+EXTRUDER_RUNOUT_EXTRUDE*EXTRUDER_RUNOUT_ESTEPS/axis_steps_per_unit[E_AXIS],
          EXTRUDER_RUNOUT_SPEED/60.*EXTRUDER_RUNOUT_ESTEPS/axis_steps_per_unit[E_AXIS], active_extruder);
      current_position[E_CARTH]=oldepos;
      destination[E_CARTH]=oldedes;
      plan_set_e_position(oldepos);
      previous_millis_cmd=millis();
      st_synchronize();
      WRITE(E0_ENABLE_PIN,oldstatus);
    }
#endif
#ifdef TEMP_STAT_LEDS
  handle_status_leds();
#endif
  check_axes_activity();
}

void kill(){
  cli(); // Stop interrupts
#ifdef EXTRUDERS
  disable_heater();
#endif // ifdef EXTRUDERS

  disable_x();
  disable_y();
  disable_z();
  disable_e0();
  disable_e1();

#if defined(PS_ON_PIN) && PS_ON_PIN > -1
  pinMode(PS_ON_PIN,INPUT);
#endif
  SERIAL_ERROR_START;
  SERIAL_ERRORLNPGM(MSG_ERR_KILLED);

  // FMC small patch to update the LCD before ending
  sei();   // enable interrupts
  cli();   // disable interrupts
  suicide();
  while(1){ /* Intentionally left empty */ } // Wait for reset
}

void Stop(){
#ifdef EXTRUDERS
  disable_heater();
#endif // ifdef EXTRUDERS
  if(Stopped == false){
    Stopped = true;
    Stopped_gcode_LastN = gcode_LastN; // Save last g_code for restart
    SERIAL_ERROR_START;
    SERIAL_ERRORLNPGM(MSG_ERR_STOPPED);
  }
}

bool IsStopped(){
  return Stopped;
}

#ifdef FAST_PWM_FAN
void setPwmFrequency(uint8_t pin, int val){
  val &= 0x07;
  switch(digitalPinToTimer(pin)){

#if defined(TCCR0A)
    case TIMER0A:
    case TIMER0B:
      //         TCCR0B &= ~(_BV(CS00) | _BV(CS01) | _BV(CS02));
      //         TCCR0B |= val;
      break;
#endif

#if defined(TCCR1A)
    case TIMER1A:
    case TIMER1B:
      //         TCCR1B &= ~(_BV(CS10) | _BV(CS11) | _BV(CS12));
      //         TCCR1B |= val;
      break;
#endif

#if defined(TCCR2)
    case TIMER2:
    case TIMER2:
      TCCR2 &= ~(_BV(CS10) | _BV(CS11) | _BV(CS12));
      TCCR2 |= val;
      break;
#endif

#if defined(TCCR2A)
    case TIMER2A:
    case TIMER2B:
      TCCR2B &= ~(_BV(CS20) | _BV(CS21) | _BV(CS22));
      TCCR2B |= val;
      break;
#endif

#if defined(TCCR3A)
    case TIMER3A:
    case TIMER3B:
    case TIMER3C:
      TCCR3B &= ~(_BV(CS30) | _BV(CS31) | _BV(CS32));
      TCCR3B |= val;
      break;
#endif

#if defined(TCCR4A)
    case TIMER4A:
    case TIMER4B:
    case TIMER4C:
      TCCR4B &= ~(_BV(CS40) | _BV(CS41) | _BV(CS42));
      TCCR4B |= val;
      break;
#endif

#if defined(TCCR5A)
    case TIMER5A:
    case TIMER5B:
    case TIMER5C:
      TCCR5B &= ~(_BV(CS50) | _BV(CS51) | _BV(CS52));
      TCCR5B |= val;
      break;
#endif

  }
}
#endif //FAST_PWM_FAN

#ifdef EXTRUDERS
bool setTargetedHotend(int code){
  tmp_extruder = active_extruder;
  if(code_seen('T')){
    tmp_extruder = code_value();
    if(tmp_extruder >= EXTRUDERS){
      SERIAL_ECHO_START;
      switch(code){
        case 104:
          SERIAL_ECHO(MSG_M104_INVALID_EXTRUDER);
          break;
        case 105:
          SERIAL_ECHO(MSG_M105_INVALID_EXTRUDER);
          break;
        case 109:
          SERIAL_ECHO(MSG_M109_INVALID_EXTRUDER);
          break;
        case 218:
          SERIAL_ECHO(MSG_M218_INVALID_EXTRUDER);
          break;
        case 221:
          SERIAL_ECHO(MSG_M221_INVALID_EXTRUDER);
          break;
      }
      SERIAL_ECHOLN(tmp_extruder);
      return true;
    }
  }
  return false;
}

float calculate_volumetric_multiplier(float diameter){
  float area = .0;
  float radius = .0;

  radius = diameter * .5;
  if(! volumetric_enabled || radius == 0){
    area = 1;
  }else {
    area = M_PI * pow(radius, 2);
  }

  return 1.0 / area;
}

void calculate_volumetric_multipliers(){
  for (int i=0; i<EXTRUDERS; i++)
    volumetric_multiplier[i] = calculate_volumetric_multiplier(filament_size[i]);
}
#endif // ifdef EXTRUDERS
