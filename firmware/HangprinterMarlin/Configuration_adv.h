#ifndef CONFIGURATION_ADV_H
#define CONFIGURATION_ADV_H

//===========================================================================
//=============================Thermal Settings  ============================
//===========================================================================

//// Heating sanity check:
// This waits for the watchperiod in milliseconds whenever an M104 or M109 increases the target temperature
// If the temperature has not increased at the end of that period, the target temperature is set to zero.
// It can be reset with another M104/M109. This check is also only triggered if the target temperature and the current temperature
//  differ by at least 2x WATCH_TEMP_INCREASE
//#define WATCH_TEMP_PERIOD 40000 //40 seconds
//#define WATCH_TEMP_INCREASE 10  //Heat up at least 10 degree in 20 seconds

#ifdef PIDTEMP
// this adds an experimental additional term to the heatingpower, proportional to the extrusion speed.
// if Kc is choosen well, the additional required power due to increased melting should be compensated.
#define PID_ADD_EXTRUSION_RATE
#ifdef PID_ADD_EXTRUSION_RATE
#define  DEFAULT_Kc (1) //heatingpower=Kc*(e_speed)
#endif
#endif


//automatic temperature: The hot end target temperature is calculated by all the buffered lines of gcode.
//The maximum buffered steps/sec of the extruder motor are called "se".
//You enter the autotemp mode by a M109 S<mintemp> T<maxtemp> F<factor>
// the target temperature is set to mintemp+factor*se[steps/sec] and limited by mintemp and maxtemp
// you exit the value by any M109 without F*
// Also, if the temperature is set to a value <mintemp, it is not changed by autotemp.
// on an ultimaker, some initial testing worked with M109 S215 B260 F1 in the start.gcode
// Hangprinter could make good use of this? tobben 9 sep 2015
#define AUTOTEMP
#ifdef AUTOTEMP
#define AUTOTEMP_OLDWEIGHT 0.98
#endif

//  extruder run-out prevention.
//if the machine is idle, and the temperature over MINTEMP, every couple of SECONDS some filament is extruded
//#define EXTRUDER_RUNOUT_PREVENT
#define EXTRUDER_RUNOUT_MINTEMP 190
#define EXTRUDER_RUNOUT_SECONDS 30.
#define EXTRUDER_RUNOUT_ESTEPS 14. //mm filament
#define EXTRUDER_RUNOUT_SPEED 1500.  //extrusion speed
#define EXTRUDER_RUNOUT_EXTRUDE 100

//These defines help to calibrate the AD595 sensor in case you get wrong temperature measurements.
//The measured temperature is defined as "actualTemp = (measuredTemp * TEMP_SENSOR_AD595_GAIN) + TEMP_SENSOR_AD595_OFFSET"
#define TEMP_SENSOR_AD595_OFFSET 0.0
#define TEMP_SENSOR_AD595_GAIN   1.0

//This is for controlling a fan to cool down the stepper drivers
//it will turn on when any driver is enabled
//and turn off after the set amount of seconds from last driver being disabled again
#define CONTROLLERFAN_PIN -1 //Pin used for the fan to cool controller (-1 to disable)
#define CONTROLLERFAN_SECS 60 //How many seconds, after all motors were disabled, the fan should run
#define CONTROLLERFAN_SPEED 255  // == full speed

// When first starting the main fan, run it at full speed for the
// given number of milliseconds.  This gets the fan spinning reliably
// before setting a PWM value. (Does not work with software PWM for fan on Sanguinololu)
//#define FAN_KICKSTART_TIME 100

//===========================================================================
//=============================Mechanical Settings===========================
//===========================================================================

#define ENDSTOPS_ONLY_FOR_HOMING // If defined the endstops will only be used for homing


//// AUTOSET LOCATIONS OF LIMIT SWITCHES
//// Added by ZetaPhoenix 09-15-2012
#ifdef MANUAL_HOME_POSITIONS  // Use manual limit switch locations
#define X_HOME_POS MANUAL_X_HOME_POS
#define Y_HOME_POS MANUAL_Y_HOME_POS
#define Z_HOME_POS MANUAL_Z_HOME_POS
#else //Set min/max homing switch positions based upon homing direction and min/max travel limits
//X axis
#if X_HOME_DIR == -1
#ifdef BED_CENTER_AT_0_0
#define X_HOME_POS X_MAX_LENGTH * -0.5
#else
#define X_HOME_POS X_MIN_POS
#endif //BED_CENTER_AT_0_0
#else
#ifdef BED_CENTER_AT_0_0
#define X_HOME_POS X_MAX_LENGTH * 0.5
#else
#define X_HOME_POS X_MAX_POS
#endif //BED_CENTER_AT_0_0
#endif //X_HOME_DIR == -1

//Y axis
#if Y_HOME_DIR == -1
#ifdef BED_CENTER_AT_0_0
#define Y_HOME_POS Y_MAX_LENGTH * -0.5
#else
#define Y_HOME_POS Y_MIN_POS
#endif //BED_CENTER_AT_0_0
#else
#ifdef BED_CENTER_AT_0_0
#define Y_HOME_POS Y_MAX_LENGTH * 0.5
#else
#define Y_HOME_POS Y_MAX_POS
#endif //BED_CENTER_AT_0_0
#endif //Y_HOME_DIR == -1

// Z axis
#if Z_HOME_DIR == -1 //BED_CENTER_AT_0_0 not used
#define Z_HOME_POS Z_MIN_POS
#else
#define Z_HOME_POS Z_MAX_POS
#endif //Z_HOME_DIR == -1
#endif //End auto min/max positions
//END AUTOSET LOCATIONS OF LIMIT SWITCHES -ZP

//homing hits the endstop, then retracts by this distance, before it tries to slowly bump again:
#define X_HOME_RETRACT_MM 5
#define Y_HOME_RETRACT_MM 5
#define Z_HOME_RETRACT_MM 5 // deltas need the same for all three axis

//#define QUICK_HOME  //if this is defined, if both x and y are to be homed, a diagonal move will be performed initially.

#define AXIS_RELATIVE_MODES {false, false, false, false, false}
//#define AXIS_RELATIVE_MODES {true, true, true, true, false} // Does not affect hangprinter coords...

#define MAX_STEP_FREQUENCY 40000 // Max step frequency for Ultimaker (5000 pps / half step)

//By default pololu step drivers require an active high signal. However, some high power drivers require an active low signal as step.
#define INVERT_X_STEP_PIN  false
#define INVERT_Y_STEP_PIN  false
#define INVERT_Z_STEP_PIN  false
#define INVERT_E_STEP_PIN  false
#define INVERT_E1_STEP_PIN false

#define DEFAULT_MINIMUMFEEDRATE       0.0     // minimum feedrate
#define DEFAULT_MINTRAVELFEEDRATE     0.0

// minimum time in microseconds that a movement needs to take if the buffer is emptied.
#define DEFAULT_MINSEGMENTTIME        20000

// Minimum planner junction speed. Sets the default minimum speed the planner plans for at the end
// of the buffer and all stops. This should not be much greater than zero and should only be changed
// if unwanted behavior is observed on a user's machine when running at very slow speeds.
#define MINIMUM_PLANNER_SPEED 0.05// (mm/sec)

// MS1 MS2 Stepper Driver Microstepping mode table
#define MICROSTEP1 LOW,LOW
#define MICROSTEP2 HIGH,LOW
#define MICROSTEP4 LOW,HIGH
#define MICROSTEP8 HIGH,HIGH
#define MICROSTEP16 HIGH,HIGH

// Microstep setting (Only functional when stepper driver microstep pins are connected to MCU.
#define MICROSTEP_MODES {16,16,16,16,16} // [1,2,4,8,16]

//===========================================================================
//=============================Additional Features===========================
//===========================================================================

//#define CHDK 4        //Pin for triggering CHDK to take a picture see how to use it here http://captain-slow.dk/2014/03/09/3d-printing-timelapses/
#define CHDK_DELAY 50 //How long in ms the pin should stay HIGH before going LOW again

// if a file is deleted, it frees a block. hence, the order is not purely cronological. To still have auto0.g accessible, there is again the option to do that.
// using:
//#define MENU_ADDAUTOSTART

#ifdef LCD_PROGRESS_BAR
// Amount of time (ms) to show the bar
#define PROGRESS_BAR_BAR_TIME 2000
// Amount of time (ms) to show the status message
#define PROGRESS_BAR_MSG_TIME 2000
// Amount of time (ms) to retain the status message (0=forever)
#define PROGRESS_MSG_EXPIRE   0
// Enable this to show messages for MSG_TIME then hide them
//#define PROGRESS_MSG_ONCE
#endif

// Arc interpretation settings:
#define MM_PER_ARC_SEGMENT 1
#define N_ARC_CORRECTION 25

//const unsigned int dropsegments=5; //everything with less than this number of steps will be ignored as move and joined with the next movement
const unsigned int dropsegments=1;   //set to 1 while we only use full steps

// Power Signal Control Definitions
// By default use ATX definition
#ifndef POWER_SUPPLY
  #define POWER_SUPPLY 1
#endif
// 1 = ATX
#if (POWER_SUPPLY == 1)
  #define PS_ON_AWAKE  LOW
  #define PS_ON_ASLEEP HIGH
#endif
// 2 = X-Box 360 203W
#if (POWER_SUPPLY == 2)
  #define PS_ON_AWAKE  HIGH
  #define PS_ON_ASLEEP LOW
#endif

//===========================================================================
//============================ Buffers ======================================
//===========================================================================

// The number of linear motions that can be in the plan at any give time.
// THE BLOCK_BUFFER_SIZE NEEDS TO BE A POWER OF 2, i.g. 8,16,32 because shifts and ors are used to do the ringbuffering.
#define BLOCK_BUFFER_SIZE 16   // SD,LCD,Buttons take more memory, block buffer needs to be smaller

//The ASCII buffer for recieving from the serial:
#define MAX_CMD_SIZE 96
#define BUFSIZE 4

#ifdef FILAMENTCHANGEENABLE
  #ifdef EXTRUDER_RUNOUT_PREVENT
    #error EXTRUDER_RUNOUT_PREVENT currently incompatible with FILAMENTCHANGE
  #endif
#endif

//===========================================================================
//=======================  Geometry conventions check  ======================
//===========================================================================
#if defined(CONVENTIONAL_GEOMETRY)
  #if !(ANCHOR_A_X == 0)
    #error "ANCHOR_A_X should be set to 0 by convention."
  #endif
  #if !(ANCHOR_A_Y < 0)
    #error "ANCHOR_A_Y should be a negative number by convention."
  #endif
  #if !(ANCHOR_B_X*ANCHOR_C_X < 0)
    #error "ANCHOR_B_X and ANCHOR_C_X should have different signs by convention."
  #endif
  #if !(ANCHOR_B_Y > 0)
    #error "ANCHOR_B_Y should be a positive number by convention."
  #endif
  #if !(ANCHOR_C_Y > 0)
    #error "ANCHOR_C_Y should be a positive number by convention."
  #endif
  #if !(ANCHOR_A_Z < 0)
    #error "ANCHOR_A_Z should be a negative number by convention."
  #endif
  #if !(ANCHOR_B_Z < 0)
    #error "ANCHOR_B_Z should be a negative number by convention."
  #endif
  #if !(ANCHOR_C_Z < 0)
    #error "ANCHOR_C_Z should be a negative number by convention."
  #endif
  #if !(ANCHOR_D_Z > 0)
    #error "ANCHOR_D_Z should be a positive number by convention."
  #endif
#endif

//===========================================================================
//=============================  Define Defines  ============================
//===========================================================================

#if TEMP_SENSOR_0 > 0
  #define THERMISTORHEATER_0 TEMP_SENSOR_0
  #define HEATER_0_USES_THERMISTOR
#endif
#if TEMP_SENSOR_0 == -1
  #define HEATER_0_USES_AD595
#endif
#if TEMP_SENSOR_0 == -2
  #define HEATER_0_USES_MAX6675
#endif
#if TEMP_SENSOR_0 == 0
  #undef HEATER_0_MINTEMP
  #undef HEATER_0_MAXTEMP
#endif

#endif //__CONFIGURATION_ADV_H
