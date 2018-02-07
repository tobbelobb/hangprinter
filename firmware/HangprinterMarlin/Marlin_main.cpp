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
#include "temperature.h"
#include "ConfigurationStore.h"
#include "language.h"
#include "pins_arduino.h"
#include "math.h"
#if defined(EXPERIMENTAL_AUTO_CALIBRATION_FEATURE)
#include "Wire.h"
#endif

// look here for descriptions of G-codes: http://linuxcnc.org/handbook/gcode/g-code.html
// http://objects.reprap.org/wiki/Mendel_User_Manual:_RepRapGCodes

//Implemented Codes
//-------------------
// G0  -> G1
// G1  - Coordinated Movement X Y Z E
// G6  - Uncoordinated movement A B C D E
// G7  - Do relative A B C D moves, and remember new line lengths.
// G8  - Do absolute A B C D moves, and remember new line lengths.
// G90 - Use Absolute Coordinates
// G91 - Use Relative Coordinates
// G92 - Set current position to coordinates given
// G95 - Set servo torque mode status
// G96 - Tell sensor servo to mark its reference point
// G98 - Set absolute line length based on servo encoder output

// M Codes
// M17  - Enable/Power all stepper motors
// M42  - Change pin status via gcode Use M42 Px Sy to set pin x to value y, when omitting Px the onboard led will be used.
// M82  - Set E codes absolute (default)
// M83  - Set E codes relative while in Absolute Coordinates (G90) mode
// M92  - Set axis_steps_per_unit or spool_buildup_factor
// M104 - Set extruder target temp
// M105 - Read current temp
// M106 - Fan on
// M107 - Fan off
// M109 - Sxxx Wait for extruder current temp to reach target temp. Waits only when heating
//        Rxxx Wait for extruder current temp to reach target temp. Waits when heating and cooling
//        IF AUTOTEMP is enabled, S<mintemp> B<maxtemp> F<factor>. Exit autotemp by any M109 without F
// M112 - Emergency stop
// M114 - Output current position to serial port
//      - S1 Compute length travelled since last G96 from  encoder poistion data
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
// M665 - Set anchor locations
// M666 - Set delta endstop adjustment
// M350 - Set microstepping mode.
// M351 - Toggle MS1 MS2 pins directly.

// M999 - Restart after being stopped by error

float homing_feedrate[] = HOMING_FEEDRATE;
bool axis_relative_modes[] = AXIS_RELATIVE_MODES;
int feedmultiply = 100; //100->1 200->2
int saved_feedmultiply;
int extrudemultiply = 100; //100->1 200->2
int extruder_multiply[1] = { 100 };
bool volumetric_enabled = false;
float filament_size[1] = { DEFAULT_NOMINAL_FILAMENT_DIA };
float volumetric_multiplier[1] = { 1.0 };

float current_position[4] = { 0.0, 0.0, 0.0, 0.0 }; //gcode carthesian
float add_homing[DIRS] = { 0 };
#ifdef DELTA
float endstop_adj[DIRS] = { 0 };
#endif

float min_pos[DIRS] = { A_MIN_POS, B_MIN_POS, C_MIN_POS, D_MIN_POS };
float max_pos[DIRS] = { A_MAX_POS, B_MAX_POS, C_MAX_POS, D_MAX_POS };
bool axis_known_position[DIRS] = { false, false, false, false };
float zprobe_zoffset;

uint8_t active_extruder = 0;
int fanSpeed = 0;

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
float line_lengths[DIRS] = { 0 };

bool cancel_heatup = false;

const char errormagic[] PROGMEM = "Error:";
const char echomagic[] PROGMEM = "echo:";

// destinations are directly from gcode, so Carthesian xyze
const char axis_codes_carthesian[4] = {'X', 'Y', 'Z', 'E'};
const char axis_codes[5] = {'A', 'B', 'C', 'D', 'E'};
static float destination[4] = { 0, 0, 0, 0 };

static float offset[3] = { 0, 0, 0 };
static float feedrate = 1500.0, next_feedrate, saved_feedrate;
static long gcode_LastN, Stopped_gcode_LastN = 0;

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

unsigned long starttime = 0; ///< Print job start time
unsigned long stoptime = 0;  ///< Print job stop time

static uint8_t tmp_extruder;

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
bool setTargetedHotend(int code);

void serial_echopair_P(const char *s_P, float v)
{ serialprintPGM(s_P); SERIAL_ECHO(v); }
void serial_echopair_P(const char *s_P, double v)
{ serialprintPGM(s_P); SERIAL_ECHO(v); }
void serial_echopair_P(const char *s_P, unsigned long v)
{ serialprintPGM(s_P); SERIAL_ECHO(v); }

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
#if defined(EXPERIMENTAL_AUTO_CALIBRATION_FEATURE)
  // Initialize i2c as master.
  Wire.begin();
#endif
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

  tp_init();    // Initialize temperature loop
  plan_init();  // Initialize planner;
  st_init();    // Initialize stepper, this enables interrupts!
  setup_photpin();

#if defined(CONTROLLERFAN_PIN) && CONTROLLERFAN_PIN > -1
  SET_OUTPUT(CONTROLLERFAN_PIN); //Set pin used for driver cooling fan
#endif

  setup_homepin();
// Hangprinter needs it motors always enabled
#if defined(HANGPRINTER)
enable_x();
enable_y();
enable_z();
enable_e1();
calculate_line_lengths(current_position, line_lengths);
#endif
}

void loop(){
  if(buflen < (BUFSIZE-1)) get_command();
  if(buflen){
    process_commands();
    buflen = (buflen-1);
    bufindr = (bufindr + 1)%BUFSIZE;
  }
  //check heater every n milliseconds
  manage_heater();
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
}

float code_value(){
  return (strtod(&cmdbuffer[bufindr][strchr_pointer - cmdbuffer[bufindr] + 1], NULL));
}

long code_value_long(){
  return (strtol(&cmdbuffer[bufindr][strchr_pointer - cmdbuffer[bufindr] + 1], NULL, 10));
}

inline unsigned long code_value_ulong(){
  return strtoul(strchr_pointer + 1, NULL, 10);
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

#if defined(EXPERIMENTAL_AUTO_CALIBRATION_FEATURE)
// Ang is angle moved away from origo position
// Output is line length from origo in mm
float ang_to_mm(float ang, int axis){
  if(axis < 0 || axis > D_AXIS){
    return 0.0;
  }
#if defined(EXPERIMENTAL_LINE_BUILDUP_COMPENSATION_FEATURE)
  float abs_step_in_origo = k0[axis]*(sqrtf(k1[axis] + k2[axis]*INITIAL_DISTANCES[axis]) - sqrtk1[axis]);
#else
  float abs_step_in_origo = INITIAL_DISTANCES[axis]*axis_steps_per_unit[axis];
#endif
  float microstepping = MICROSTEPPING;
  float steps_per_rot = 200.0*microstepping;
  float steps_per_ang = steps_per_rot/360.0;
  float step_diff = steps_per_ang*ang;
  float c = abs_step_in_origo + step_diff; // current step count
#if defined(EXPERIMENTAL_LINE_BUILDUP_COMPENSATION_FEATURE)
  return ((c/k0[axis] + sqrtk1[axis])*(c/k0[axis] + sqrtk1[axis]) - k1[axis])/k2[axis] - INITIAL_DISTANCES[axis]; // Inverse function found in planner.cpp line 567, setting target[AXIS_A]
#else
  return c/axis_steps_per_unit[axis] - INITIAL_DISTANCES[axis];
#endif
}
#endif // EXPERIMENTAL_AUTO_CALIBRATION_FEATURE

void refresh_cmd_timeout(void){
  previous_millis_cmd = millis();
}

#if defined(HAVE_TMC2130)

  static void tmc2130_print_current(const int mA, const char name) {
    SERIAL_CHAR(name);
    SERIAL_ECHOPGM(" axis driver current: ");
    SERIAL_ECHOLN(mA);
  }
  static void tmc2130_print_load(const uint16_t load, const char name) {
    SERIAL_CHAR(name);
    SERIAL_ECHOPGM(" axis driver load: ");
    SERIAL_ECHOLN(load);
  }
  static void tmc2130_set_current(const int mA, TMC2130Stepper &st, const char name) {
    tmc2130_print_current(mA, name);
    st.setCurrent(mA, 0.11, 0.5);
  }
  static void tmc2130_get_current(TMC2130Stepper &st, const char name) {
    tmc2130_print_current(st.getCurrent(), name);
  }
  static void tmc2130_get_load(TMC2130Stepper &st, const char name) {
    tmc2130_print_load(st.sg_result(), name);
  }
  static void tmc2130_report_otpw(TMC2130Stepper &st, const char name) {
    SERIAL_CHAR(name);
    SERIAL_ECHOPGM(" axis temperature prewarn triggered: ");
    serialprintPGM(st.getOTPW() ? PSTR("true") : PSTR("false"));
    SERIAL_CHAR('\n');
  }
  static void tmc2130_clear_otpw(TMC2130Stepper &st, const char name) {
    st.clear_otpw();
    SERIAL_CHAR(name);
    SERIAL_ECHOLNPGM(" prewarn flag cleared");
  }

  /**
   * M906: Set motor current in milliamps using axis codes A, B, C, D, E
   *
   * Report driver currents when no axis specified
   */
  inline void gcode_M906() {
    uint16_t values[NUM_AXIS];
    for(int8_t i=0; i < NUM_AXIS; i++){
      if(code_seen(axis_codes[i])){
        values[i] = code_value_ulong();
      }else{
        values[i] = 0;
      }
    }

    if (values[A_AXIS]) tmc2130_set_current(values[A_AXIS], stepperA, 'A');
    else tmc2130_get_current(stepperA, 'A');
    if (values[B_AXIS]) tmc2130_set_current(values[B_AXIS], stepperB, 'B');
    else tmc2130_get_current(stepperB, 'B');
    if (values[C_AXIS]) tmc2130_set_current(values[C_AXIS], stepperC, 'C');
    else tmc2130_get_current(stepperC, 'C');
    if (values[D_AXIS]) tmc2130_set_current(values[D_AXIS], stepperD, 'D');
    else tmc2130_get_current(stepperD, 'D');
    if (values[E_AXIS]) tmc2130_set_current(values[E_AXIS], stepperE, 'E');
    else tmc2130_get_current(stepperE, 'E');
  }

  /**
   * M907: Read stallGuard load from tmc2130 using axis codes A, B, C, D, E
   */
  inline void gcode_M907() {
    if(code_seen(axis_codes[A_AXIS])){
      tmc2130_get_load(stepperA, 'A');
    }
    if(code_seen(axis_codes[B_AXIS])){
      tmc2130_get_load(stepperB, 'B');
    }
    if(code_seen(axis_codes[C_AXIS])){
      tmc2130_get_load(stepperC, 'C');
    }
    if(code_seen(axis_codes[D_AXIS])){
      tmc2130_get_load(stepperD, 'D');
    }
    if(code_seen(axis_codes[E_AXIS])){
      tmc2130_get_load(stepperE, 'E');
    }
  }

  /**
   * M908: Change stallGuard sensitivity using axis codes A, B, C, D, E
   */
  inline void gcode_M908() {
    if(code_seen(axis_codes[A_AXIS])){
      float val = code_value();
      int8_t valint = (int8_t)val;
      SERIAL_ECHOPGM("Got A: ");
      SERIAL_ECHOLN(valint);
      stepperA.sgt((uint8_t)valint);
    }
    if(code_seen(axis_codes[B_AXIS])){
      float val = code_value();
      int8_t valint = (int8_t)val;
      SERIAL_ECHOPGM("Got B: ");
      SERIAL_ECHOLN(valint);
      stepperB.sgt((uint8_t)valint);
    }
    if(code_seen(axis_codes[C_AXIS])){
      float val = code_value();
      int8_t valint = (int8_t)val;
      SERIAL_ECHOPGM("Got C: ");
      SERIAL_ECHOLN(valint);
      stepperC.sgt((uint8_t)valint);
    }
    if(code_seen(axis_codes[D_AXIS])){
      float val = code_value();
      int8_t valint = (int8_t)val;
      SERIAL_ECHOPGM("Got D: ");
      SERIAL_ECHOLN(valint);
      stepperD.sgt((uint8_t)valint);
    }
    if(code_seen(axis_codes[E_AXIS])){
      float val = code_value();
      int8_t valint = (int8_t)val;
      SERIAL_ECHOPGM("Got E: ");
      SERIAL_ECHOLN(valint);
      stepperE.sgt((uint8_t)valint);
    }
  }

  /**
   * M911: Report TMC2130 stepper driver overtemperature pre-warn flag
   * The flag is held by the library and persist until manually cleared by M912
   */
  inline void gcode_M911() {
      tmc2130_report_otpw(stepperA, 'A');
      tmc2130_report_otpw(stepperB, 'B');
      tmc2130_report_otpw(stepperC, 'C');
      tmc2130_report_otpw(stepperD, 'D');
      tmc2130_report_otpw(stepperE, 'E');
  }

  /**
   * M912: Clear TMC2130 stepper driver overtemperature pre-warn flag held by the library
   */
  inline void gcode_M912() {
      if (code_seen('A')) tmc2130_clear_otpw(stepperA, 'A');
      if (code_seen('B')) tmc2130_clear_otpw(stepperB, 'B');
      if (code_seen('C')) tmc2130_clear_otpw(stepperC, 'C');
      if (code_seen('D')) tmc2130_clear_otpw(stepperD, 'D');
      if (code_seen('E')) tmc2130_clear_otpw(stepperE, 'E');
  }

#endif // HAVE_TMC2130


void process_commands(){
  unsigned long codenum; //throw away variable
  if(code_seen('G')){
    switch((int)code_value()){
      case 0: // G0 -> G1
      case 1: // G1
        if(Stopped == false){
          get_coordinates(); // Put X Y Z E into destination[] and update feedrate based on F
          prepare_move();
        }
        break;
      // G4 P100 means dwell for 100 milliseconds
      case 4:
        if (code_seen('P')){
          unsigned long dwell_ms = 0;
          dwell_ms = code_value_ulong(); // milliseconds to wait
          st_synchronize();
          refresh_cmd_timeout(); // Set previous_millis_cmd = millis();
          dwell_ms += previous_millis_cmd;  // keep track of when we started waiting
          while((long)(millis() - dwell_ms) < 0){
            manage_heater();
            manage_inactivity();
          }
        }
        break;
      // G6 tighten Hangprinter lines.
      // Make moves without altering position variables.
      // Speed variables for planning are modified.
      // TODO: look over G6 G7 G8
      case 6:
        {
          float tmp_line_lengths[NUM_AXIS];
          tmp_line_lengths[A_AXIS] = line_lengths[A_AXIS];
          tmp_line_lengths[B_AXIS] = line_lengths[B_AXIS];
          tmp_line_lengths[C_AXIS] = line_lengths[C_AXIS];
          tmp_line_lengths[D_AXIS] = line_lengths[D_AXIS];

          if(code_seen('A')) tmp_line_lengths[A_AXIS] += code_value();
          if(code_seen('B')) tmp_line_lengths[B_AXIS] += code_value();
          if(code_seen('C')) tmp_line_lengths[C_AXIS] += code_value();
          if(code_seen('D')) tmp_line_lengths[D_AXIS] += code_value();
          if(code_seen('E')) destination[E_CARTH] += code_value();
          if(code_seen('F')){
            next_feedrate = code_value();
            if(next_feedrate > 0.0){
              saved_feedrate = feedrate;
              feedrate = next_feedrate;
            }
          }
          plan_buffer_line(tmp_line_lengths, line_lengths,
              destination[E_CARTH], feedrate*feedmultiply/60/100, active_extruder, false);
        }
        break;
      case 7: // G7: Do relative A B C D moves, and remember/count new line lengths.
        {
          // WARNING: Using G7 first, then G1 will give you chaos!
          //          Make sure to use G92 after G7 moves, so G1 sees sane previous line lengths.
          float prev_line_lengths[NUM_AXIS];
          prev_line_lengths[A_AXIS] = line_lengths[A_AXIS];
          prev_line_lengths[B_AXIS] = line_lengths[B_AXIS];
          prev_line_lengths[C_AXIS] = line_lengths[C_AXIS];
          prev_line_lengths[D_AXIS] = line_lengths[D_AXIS];

          if(code_seen('A')) line_lengths[A_AXIS] += code_value();
          if(code_seen('B')) line_lengths[B_AXIS] += code_value();
          if(code_seen('C')) line_lengths[C_AXIS] += code_value();
          if(code_seen('D')) line_lengths[D_AXIS] += code_value();
          if(code_seen('F')){
            next_feedrate = code_value();
            if(next_feedrate > 0.0){
              saved_feedrate = feedrate;
              feedrate = next_feedrate;
            }
          }
          plan_buffer_line(line_lengths, prev_line_lengths,
              destination[E_CARTH], feedrate*feedmultiply/60/100, active_extruder, true);
        }
        break;
      case 8: // G8: Do A B C D moves, and remember new line lengths.
        {
          // WARNING: Using G8 first, then G1 will give you chaos!
          //          Make sure to use G92 after G8 moves, so G1 sees sane previous line lengths.
          float prev_line_lengths[NUM_AXIS];
          prev_line_lengths[A_AXIS] = line_lengths[A_AXIS];
          prev_line_lengths[B_AXIS] = line_lengths[B_AXIS];
          prev_line_lengths[C_AXIS] = line_lengths[C_AXIS];
          prev_line_lengths[D_AXIS] = line_lengths[D_AXIS];

          if(code_seen('A')) line_lengths[A_AXIS] = INITIAL_DISTANCES[A_AXIS] + code_value();
          if(code_seen('B')) line_lengths[B_AXIS] = INITIAL_DISTANCES[B_AXIS] + code_value();
          if(code_seen('C')) line_lengths[C_AXIS] = INITIAL_DISTANCES[C_AXIS] + code_value();
          if(code_seen('D')) line_lengths[D_AXIS] = INITIAL_DISTANCES[D_AXIS] + code_value();
          if(code_seen('F')){
            next_feedrate = code_value();
            if(next_feedrate > 0.0){
              saved_feedrate = feedrate;
              feedrate = next_feedrate;
            }
          }
          plan_buffer_line(line_lengths, prev_line_lengths,
              destination[E_CARTH], feedrate*feedmultiply/60/100, active_extruder, true);
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
              current_position[i] = code_value();
              calculate_line_lengths(current_position, line_lengths);
              plan_set_position(line_lengths, destination[E_CARTH]);
            }
          }
        }
        break;
#if defined(EXPERIMENTAL_AUTO_CALIBRATION_FEATURE)
      case 95: // G95 Set servo torque mode.
        float torque;
        byte cmd[5];
        cmd[0] = 0x5f; // 95 in hexadecimal is 0x5f
        if(code_seen('A')){
          torque = -fabs(code_value());
          if(!INVERT_X_DIR){
            torque = -torque;
          }
          memcpy(cmd+1, &torque, 4);
          Wire.beginTransmission(0x0a);
          Wire.write(cmd, 5);
          Wire.endTransmission(0x0a);
        }
        if(code_seen('B')){
          torque = -fabs(code_value());
          if(!INVERT_Y_DIR){
            torque = -torque;
          }
          memcpy(cmd+1, &torque, 4);
          Wire.beginTransmission(0x0b);
          Wire.write(cmd, 5);
          Wire.endTransmission(0x0b);
        }
        if(code_seen('C')){
          torque = -fabs(code_value());
          if(!INVERT_Z_DIR){
            torque = -torque;
          }
          memcpy(cmd+1, &torque, 4);
          Wire.beginTransmission(0x0c);
          Wire.write(cmd, 5);
          Wire.endTransmission(0x0c);
        }
        if(code_seen('D')){
          torque = -fabs(code_value());
          if(!INVERT_E1_DIR){
            torque = -torque;
          }
          memcpy(cmd+1, &torque, 4);
          Wire.beginTransmission(0x0d);
          Wire.write(cmd, 5);
          Wire.endTransmission(0x0d);
        }
        break;
      case 96: // G96 Tell sensor servo to mark its reference point
        if(code_seen('A')){
          Wire.beginTransmission(0x0a);
          Wire.write(0x60); // 96 in hexadecimal is 0x60
          Wire.endTransmission(0x0a);
        }
        if(code_seen('B')){
          Wire.beginTransmission(0x0b);
          Wire.write(0x60);
          Wire.endTransmission(0x0b);
        }
        if(code_seen('C')){
          Wire.beginTransmission(0x0c);
          Wire.write(0x60);
          Wire.endTransmission(0x0c);
        }
        if(code_seen('D')){
          Wire.beginTransmission(0x0d);
          Wire.write(0x60);
          Wire.endTransmission(0x0d);
        }
        break;
      case 98: // G98 Set absolute line length based on servo encoder output
        if(code_seen('A')){
         union {
           byte b[4]; // hard coded 4 instead of sizeof(float)
           float fval;
         } ang_a;
         Wire.requestFrom(0x0a, 4);
         int i = 0;
         while(Wire.available()){
           ang_a.b[i] = Wire.read();
           i++;
         }    line_lengths[A_AXIS] = INITIAL_DISTANCES[A_AXIS] + ang_to_mm(ang_a.fval, A_AXIS);
       }
       if(code_seen('B')){
         union {
           byte b[4]; // hard coded 4 instead of sizeof(float)
           float fval;
         } ang_b;
         Wire.requestFrom(0x0b, 4);
         int i = 0;
         while(Wire.available()){
           ang_b.b[i] = Wire.read();
           i++;
         }    line_lengths[B_AXIS] = INITIAL_DISTANCES[B_AXIS] + ang_to_mm(ang_b.fval, B_AXIS);
       }
       if(code_seen('C')){
         union {
           byte b[4]; // hard coded 4 instead of sizeof(float)
           float fval;
         } ang_c;
         Wire.requestFrom(0x0c, 4);
         int i = 0;
         while(Wire.available()){
           ang_c.b[i] = Wire.read();
           i++;
         }    line_lengths[C_AXIS] = INITIAL_DISTANCES[C_AXIS] + ang_to_mm(ang_c.fval, C_AXIS);
       }
       if(code_seen('D')){
         union {
           byte b[4]; // hard coded 4 instead of sizeof(float)
           float fval;
         } ang_d;
         Wire.requestFrom(0x0d, 4);
         int i = 0;
         while(Wire.available()){
           ang_d.b[i] = Wire.read();
           i++;
         }    line_lengths[D_AXIS] = INITIAL_DISTANCES[D_AXIS] + ang_to_mm(ang_d.fval, D_AXIS);
       }
       break;

#endif // end of EXPERIMENTAL_AUTO_CALIBRATION_FEATURE code
      case 28: // G28 means "we're already in origo" for Hangprinter
        current_position[X_AXIS] = 0.0;
        current_position[Y_AXIS] = 0.0;
        current_position[Z_AXIS] = 0.0;
        calculate_line_lengths(current_position, line_lengths);
        plan_set_position(line_lengths, destination[E_CARTH]);
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
      case 31: //M31 take time since an M109 command
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
          autotempShutdown();
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

      case 104: // M104
        if(setTargetedHotend(104)){
          break;
        }
        if(code_seen('S')) setTargetHotend(code_value(), tmp_extruder);
        setWatch();
        break;
      case 112: //  M112 -Emergency Stop
        kill();
        break;
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
        SERIAL_PROTOCOLPGM(" T");
        SERIAL_PROTOCOL(0);
        SERIAL_PROTOCOLPGM(":");
        SERIAL_PROTOCOL_F(degHotend(0),1);
        SERIAL_PROTOCOLPGM(" /");
        SERIAL_PROTOCOL_F(degTargetHotend(0),1);
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
        SERIAL_PROTOCOL(getHeaterPower(-1));
        SERIAL_PROTOCOLLN("");
        return;
        break;
      case 109:
        {// M109 - Wait for extruder heater to reach target.
          if(setTargetedHotend(109)){
            break;
          }
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
              //lcd_update();
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
            //LCD_MESSAGEPGM(MSG_HEATING_COMPLETE);
            starttime=millis();
            previous_millis_cmd = millis();
          }
          break;
          case 190: // M190 - Wait for bed heater to reach target.
#if defined(TEMP_BED_PIN) && TEMP_BED_PIN > -1
          //LCD_MESSAGEPGM(MSG_BED_HEATING);
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
            //lcd_update();
          }
          //LCD_MESSAGEPGM(MSG_BED_DONE);
          previous_millis_cmd = millis();
#endif
          break;

#if defined(FAN_PIN) && FAN_PIN > -1
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

          case 82: // Set extruder relative mode
          axis_relative_modes[NUM_AXIS-1] = false;
          break;
          case 83:
          axis_relative_modes[NUM_AXIS-1] = true;
          break;

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
          // Update step-count, keep old carth-position
          calculate_line_lengths(current_position, line_lengths);
          plan_set_position(line_lengths, destination[E_CARTH]);
          break;
          case 114: // M114
            #if defined(EXPERIMENTAL_AUTO_CALIBRATION_FEATURE)
              if(code_seen('S') && code_value_ulong() == 1){ // Encoder flag. Read encoder instead of internal state to determine position.
                union {
                        byte b[4]; // hard coded 4 instead of sizeof(float)
                        float fval;
                      } angle;
                const int addr[DIRS] = { 0x0a, 0x0b, 0x0c, 0x0d };
                const bool inv[DIRS] = { INVERT_X_DIR, INVERT_Y_DIR, INVERT_Z_DIR, INVERT_E1_DIR };
                const bool flip[DIRS] = { FLIPPED_A_CONNECTOR_ON_MECHADUINO,
                                          FLIPPED_B_CONNECTOR_ON_MECHADUINO,
                                          FLIPPED_C_CONNECTOR_ON_MECHADUINO,
                                          FLIPPED_D_CONNECTOR_ON_MECHADUINO};

                SERIAL_ERROR("[ ");
                for(int axis = A_AXIS; axis <= D_AXIS; axis++){
                  Wire.requestFrom(addr[axis], 4);
                  for(int i = 0; Wire.available(); i++) angle.b[i] = Wire.read();
                  if(inv[axis] == flip[axis]) angle.fval = -angle.fval;
                  SERIAL_ERROR(ang_to_mm(angle.fval, axis));
                  if(axis != D_AXIS)
                    SERIAL_ERROR(", ");
                  else
                    SERIAL_ERROR("],\n");
                }
              } else
            #endif
            {
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
              SERIAL_PROTOCOLPGM(" A:");
              SERIAL_PROTOCOL(st_get_position(A_AXIS));
              SERIAL_PROTOCOLPGM(" B:");
              SERIAL_PROTOCOL(st_get_position(B_AXIS));
              SERIAL_PROTOCOLPGM(" C:");
              SERIAL_PROTOCOL(st_get_position(C_AXIS));
              SERIAL_PROTOCOLPGM(" D:");
              SERIAL_PROTOCOL(st_get_position(D_AXIS));

              SERIAL_PROTOCOLPGM("\n Absolute line lengths:\n");
              SERIAL_PROTOCOLPGM(" A:");
              SERIAL_PROTOCOL(line_lengths[A_AXIS]);
              SERIAL_PROTOCOLPGM(" B:");
              SERIAL_PROTOCOL(line_lengths[B_AXIS]);
              SERIAL_PROTOCOLPGM(" C:");
              SERIAL_PROTOCOL(line_lengths[C_AXIS]);
              SERIAL_PROTOCOLPGM(" D:");
              SERIAL_PROTOCOL(line_lengths[D_AXIS]);
              SERIAL_PROTOCOLLN("");
            }
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
          case 200: // M200 D<millimeters> set filament diameter and set E axis units to cubic millimeters (use S0 to set back to millimeters).
          {
            tmp_extruder = active_extruder;
            if(code_seen('T')){
              tmp_extruder = code_value();
              if(tmp_extruder >= 1){
                SERIAL_ECHO_START;
                SERIAL_ECHO(MSG_M200_INVALID_EXTRUDER);
                break;
              }
            }

            if(code_seen('D')){
              float diameter = code_value();
              // setting any extruder filament size disables volumetric on the assumption that
              // slicers either generate in extruder values as cubic mm or as as filament feeds
              // for all extruders
              volumetric_enabled = (diameter != 0.0);
              if(volumetric_enabled){

                filament_size[tmp_extruder] = diameter;
                // make sure all extruders have some sane value for the filament size
                for (int i=0; i<1; i++)
                  if(! filament_size[i]) filament_size[i] = DEFAULT_NOMINAL_FILAMENT_DIA;
              }
            } else {
              //reserved for setting filament diameter via UFID or filament measuring device
              break;
            }
            calculate_volumetric_multipliers();
          }
          break;
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
          case 665: // M665 set line_lengths config
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

          case 666: // M666 set delta endstop adjustemnt
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
                    manage_heater();
                    manage_inactivity();
                  }
                }
              }
            }
          }
          break;
#ifdef PIDTEMP
          case 301: // M301
          {
            // multi-extruder PID patch: M301 updates or prints a single extruder's PID values
            // default behaviour (omitting E parameter) is to update for extruder 0 only
            int e = 0; // extruder being updated
            if(code_seen('E')){
              e = (int)code_value();
            }
            if(e < 1) // catch bad input value
            {

              if(code_seen('P')) Kp = code_value();
              if(code_seen('I')) Ki = scalePID_i(code_value());
              if(code_seen('D')) Kd = scalePID_d(code_value());
#ifdef PID_ADD_EXTRUSION_RATE
              if(code_seen('C')) Kc = code_value();
#endif

              updatePID();
              SERIAL_PROTOCOL(MSG_OK);
              SERIAL_PROTOCOL(" p:");
              SERIAL_PROTOCOL(Kp);
              SERIAL_PROTOCOL(" i:");
              SERIAL_PROTOCOL(unscalePID_i(Ki));
              SERIAL_PROTOCOL(" d:");
              SERIAL_PROTOCOL(unscalePID_d(Kd));
#ifdef PID_ADD_EXTRUSION_RATE
              SERIAL_PROTOCOL(" c:");
              //Kc does not have scaling applied above, or in resetting defaults
              SERIAL_PROTOCOL(Kc);
#endif
              SERIAL_PROTOCOLLN("");

            }else{
              SERIAL_ECHO_START;
              SERIAL_ECHOLN(MSG_INVALID_EXTRUDER);
            }

          }
          break;
#endif //PIDTEMP
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
            Config_PrintSettings(code_seen('S') && code_value() == 0);
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
#if defined(HAVE_TMC2130)
          case 906:
            gcode_M906();
            break;
          case 907:
            gcode_M907();
            break;
          case 908:
            gcode_M908();
            break;
          case 911:
            gcode_M911();
            break;
          case 912:
            gcode_M912();
            break;
#endif // defined(HAVE_TMC2130)
          case 999: // M999: Restart after being stopped
          Stopped = false;
          gcode_LastN = Stopped_gcode_LastN;
          FlushSerialRequestResend();
          break;
        }
    }

    else if(code_seen('T')){
      tmp_extruder = code_value();
      if(tmp_extruder >= 1){
        SERIAL_ECHO_START;
        SERIAL_ECHO("T");
        SERIAL_ECHO(tmp_extruder);
        SERIAL_ECHOLN(MSG_INVALID_EXTRUDER);
      }else {
        if(code_seen('F')){
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
    MYSERIAL.flush();
    SERIAL_PROTOCOLPGM(MSG_RESEND);
    SERIAL_PROTOCOLLN(gcode_LastN + 1);
    ClearToSend();
  }

  void ClearToSend(){
    previous_millis_cmd = millis();
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

// array destination[3] filled with absolute coordinates is fed into this. tobben 20. may 2015
  void calculate_line_lengths(float cartesian[3], float line_lengths[4])
  {
    // With current calculations line_lengths will contain the new absolute coordinate
    // Geometry of hangprinter makes sq(anchor_ABC_Z - carthesian[Z_AXIS]) the smallest term in the sum.
    // Starting sum with smallest number givest smallest roundoff error.
    line_lengths[A_AXIS] = sqrt(sq(anchor_A_z - cartesian[Z_AXIS])
                              + sq(anchor_A_y - cartesian[Y_AXIS])
                              + sq(anchor_A_x - cartesian[X_AXIS]));
    line_lengths[B_AXIS] = sqrt(sq(anchor_B_z - cartesian[Z_AXIS])
                              + sq(anchor_B_y - cartesian[Y_AXIS])
                              + sq(anchor_B_x - cartesian[X_AXIS]));
    line_lengths[C_AXIS] = sqrt(sq(anchor_C_z - cartesian[Z_AXIS])
                              + sq(anchor_C_y - cartesian[Y_AXIS])
                              + sq(anchor_C_x - cartesian[X_AXIS]));
    line_lengths[D_AXIS] = sqrt(sq(             cartesian[X_AXIS])
                              + sq(             cartesian[Y_AXIS])
                              + sq(anchor_D_z - cartesian[Z_AXIS]));
  }

  void prepare_move(){
    previous_millis_cmd = millis();
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
      float prev_line_lengths[DIRS];
      memcpy(prev_line_lengths, line_lengths, sizeof(line_lengths));
      calculate_line_lengths(destination, line_lengths); // line_lengths will be in absolute hangprinter abcde coords
      plan_buffer_line(line_lengths, prev_line_lengths, destination[E_CARTH], feedrate*feedmultiply/60/100.0, active_extruder, true);
    }

    for(int8_t i=0; i < 4; i++){
      current_position[i] = destination[i];
    }
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


#ifdef TEMP_STAT_LEDS
  static bool blue_led = false;
  static bool red_led = false;
  static uint32_t stat_update = 0;

  void handle_status_leds(void){
    float max_temp = 0.0;
    if(millis() > stat_update){
      stat_update += 500; // Update every 0.5s
      for (int8_t cur_extruder = 0; cur_extruder < 1; ++cur_extruder){
        max_temp = max(max_temp, degHotend(cur_extruder));
        max_temp = max(max_temp, degTargetHotend(cur_extruder));
      }
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

  void manage_inactivity(){ //default argument false set in Marlin.h
    #if defined(KILL_PIN) && KILL_PIN > -1
      static int killCount = 0;   // make the inactivity button a bit less responsive
      const int KILL_DELAY = 10000;
    #endif
    #if defined(HOME_PIN) && HOME_PIN > -1
      static int homeDebounceCount = 0;   // poor man's debouncing count
      const int HOME_DEBOUNCE_DELAY = 10000;
    #endif
    if(buflen < (BUFSIZE-1)) get_command();

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
    #ifdef TEMP_STAT_LEDS
      handle_status_leds();
    #endif
    check_axes_activity();
  }

  void kill(){
    cli(); // Stop interrupts
    disable_heater();

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
    disable_heater();
    if(Stopped == false){
      Stopped = true;
      Stopped_gcode_LastN = gcode_LastN; // Save last g_code for restart
      SERIAL_ERROR_START;
      SERIAL_ERRORLNPGM(MSG_ERR_STOPPED);
    }
  }

  bool IsStopped(){ return Stopped; }

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

  bool setTargetedHotend(int code){
    tmp_extruder = active_extruder;
    if(code_seen('T')){
      tmp_extruder = code_value();
      if(tmp_extruder >= 1){
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
    for (int i=0; i<1; i++)
      volumetric_multiplier[i] = calculate_volumetric_multiplier(filament_size[i]);
  }

