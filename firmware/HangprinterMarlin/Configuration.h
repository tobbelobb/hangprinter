#ifndef CONFIGURATION_H
#define CONFIGURATION_H

#include "boards.h"


//===========================================================================
//============================= Getting Started =============================
//===========================================================================
/*
   Here are some standard links for getting your machine calibrated:
 * http://reprap.org/wiki/Calibration
 * https://vitana.se/opr3d/tbear/index.html#hangprinter_project_21
 */

// This configuration file contains the basic settings.
// Advanced settings can be found in Configuration_adv.h

// User-specified version info of this build to display in [Pronterface, etc] terminal window during
// startup. Implementation of an idea by Prof Braino to inform user that any changes made to this
// build by the user have been successfully uploaded into firmware.
#define STRING_VERSION "3.3.hangprinter"
#define STRING_URL "github.com/tobbelobb/hangprinter"
#define STRING_VERSION_CONFIG_H __DATE__ " " __TIME__ // build date and time
#define STRING_CONFIG_H_AUTHOR "tobbelobb" // Who made the changes.
#define STRING_SPLASH_LINE1 "v" STRING_VERSION // will be shown during bootup in line 1

// SERIAL_PORT selects which serial port should be used for communication with the host.
// This allows the connection of wireless adapters (for instance) to non-default port pins.
// Serial port 0 is still used by the Arduino bootloader regardless of this setting.
#define SERIAL_PORT 0

// This determines the communication speed of the printer
#define BAUDRATE 115200

// The following define selects which electronics board you have.
// Please choose the name from boards.h that matches your setup
#ifndef MOTHERBOARD
#define MOTHERBOARD BOARD_RAMPS_13_EFB
#endif

// Define this to set a custom name for your generic Mendel,
// #define CUSTOM_MENDEL_NAME "This Mendel"

// Define this to set a unique identifier for this printer, (Used by some programs to differentiate between machines)
// You can use an online service to generate a random UUID. (eg http://www.uuidgenerator.net/version4)
// #define MACHINE_UUID "00000000-0000-0000-0000-000000000000"

//// The following define selects which power supply you have. Please choose the one that matches your setup
// 1 = ATX
// 2 = X-Box 360 203Watts (the blue wire connected to PS_ON and the red wire to VCC)
#define POWER_SUPPLY 1

//===========================================================================
//=========================== Hangprinter Settings ==========================
//===========================================================================
#define DELTA
#define HANGPRINTER

// Make delta curves from many straight lines (linear interpolation).
// This is a trade-off between visible corners (not enough segments)
// and processor overload (too many expensive sqrt calls).
#define DELTA_SEGMENTS_PER_SECOND 40

// Measure from pivot point to pivot point of line
// See Hangprinter calibration manual for help:
// http://reprap.org/wiki/Links_Into_Hangprinter_v3_Build_Video#Now_going_into_an_hour_of_measuring_this
#define ANCHOR_A_X     0 // mm
#define ANCHOR_A_Y -2163
#define ANCHOR_A_Z   -75
#define ANCHOR_B_X  1841
#define ANCHOR_B_Y   741
#define ANCHOR_B_Z   -75
#define ANCHOR_C_X -1639
#define ANCHOR_C_Y  1404
#define ANCHOR_C_Z   -75
#define ANCHOR_D_Z  3250

// Comment this out if you plan to place your anchors at unconventional places
// See Configuration_adv.h for exact definition of the tested convention
#define CONVENTIONAL_GEOMETRY

#define NUM_AXIS 5 // The axis order:    A_AXIS, B_AXIS, C_AXIS, D_AXIS, E_AXIS
#define DIRS 4     // The four dirs are: A_AXIS, B_AXIS, C_AXIS, D_AXIS

// If you want the experimental line buildup compensation feature with your Hangprinter, uncomment this.
#define EXPERIMENTAL_LINE_BUILDUP_COMPENSATION_FEATURE

/* ----- How many lines in each direction? --- */
#define MECHANICAL_ADVANTAGE_A 1
#define MECHANICAL_ADVANTAGE_B 1
#define MECHANICAL_ADVANTAGE_C 1
#define MECHANICAL_ADVANTAGE_D 1

#define ACTION_POINTS_A 2
#define ACTION_POINTS_B 2
#define ACTION_POINTS_C 2
#define ACTION_POINTS_D 3

/* ----- This many: -----*/
const int nr_of_lines_in_direction[DIRS] = {MECHANICAL_ADVANTAGE_A*ACTION_POINTS_A,
                                            MECHANICAL_ADVANTAGE_B*ACTION_POINTS_B,
                                            MECHANICAL_ADVANTAGE_C*ACTION_POINTS_C,
                                            MECHANICAL_ADVANTAGE_D*ACTION_POINTS_D};

// line diameter 0.39, spool height 4.6
// approximating volume taken by line on spool to have quadratic cross section gives
// 0.39*0.39/(pi*4.6) = 0.010525
//#define DEFAULT_SPOOL_BUILDUP_FACTOR 0.010525
// line diameter 0.5, spool height 8.0:
// 0.5*0.5/(pi*8.0) = 0.009947
#define DEFAULT_SPOOL_BUILDUP_FACTOR 0.007

// Total length of lines on each spool
// Change if you have cur your lines to custom lengths.
const float MOUNTED_LINE[DIRS] = {7500.0,7500.0,7500.0,4000.0};

// Measuring your spool radii and adjusting this number will improve your Hangprinter's precision
const float SPOOL_RADII[DIRS] = { 55.0, 55.0, 55.0, 55.0 };

// Motor gear teeth: 10
// Sandwich gear teeth: 100
// Steps per motor revolution: 3200 (that is, 1/16 microstepping a motor with 200 full steps per revolution)
// ==> Steps per spool radian = 3200/(2*pi*10/100) = 5093.0
const float STEPS_PER_SPOOL_RADIAN[DIRS] = {5093.0, 5093.0, 5093.0, 5093.0};

// If you want the experimental auto calibration feature with your Hangprinter, uncomment this.
#define EXPERIMENTAL_AUTO_CALIBRATION_FEATURE
#if defined(EXPERIMENTAL_AUTO_CALIBRATION_FEATURE)
  #define MICROSTEPPING 16.0
  // To flip the sign of encoder readings (M114 S1), flip these.
  // Only needed if motor connector is inserted with different orientations on different Mechaduinos
  // Make G6-moves work correctly by adjusting INVERT_X_DIR, INVERT_Y_DIR, INVERT_Z_DIR, INVERT_E1_DIR before flipping these
  #define FLIPPED_A_CONNECTOR_ON_MECHADUINO false
  #define FLIPPED_B_CONNECTOR_ON_MECHADUINO false
  #define FLIPPED_C_CONNECTOR_ON_MECHADUINO false
  #define FLIPPED_D_CONNECTOR_ON_MECHADUINO false
#endif

//==========================================================================
//============================= Driver configuration =======================
//==========================================================================
// Uncomment this to configure for TMC2130 drivers on all axes
#define HAVE_TMC2130
#if defined(HAVE_TMC2130)
  #define HOLD_MULTIPLIER    0.5  // Scales down the holding current
  #define INTERPOLATE          1  // Interpolate X/Y/Z_MICROSTEPS to 256? 1 for yes, 0 for no

  #define ABCDE_MICROSTEPS    16
  #define ABCDE_MAXCURRENT   500

  #define A_CHIP_SELECT       27  // Pin
  #define B_CHIP_SELECT       25  // Pin
  #define C_CHIP_SELECT       23  // Pin
  #define D_CHIP_SELECT       17  // Pin
  #define E_CHIP_SELECT       16  // Pin
#endif // defined(HAVE_TMC2130)


//===========================================================================
//============================= Thermal Settings ============================
//===========================================================================
//
//--NORMAL IS 4.7kohm PULLUP!-- 1kohm pullup can be used on hotend sensor, using correct resistor and table
//
//// Temperature sensor settings:
// -2 is thermocouple with MAX6675 (only for sensor 0)
// -1 is thermocouple with AD595
// 0 is not used
// 1 is 100k thermistor - best choice for EPCOS 100k (4.7k pullup)
// 2 is 200k thermistor - ATC Semitec 204GT-2 (4.7k pullup)
// 3 is Mendel-parts thermistor (4.7k pullup)
// 4 is 10k thermistor !! do not use it for a hotend. It gives bad resolution at high temp. !!
// 5 is 100K thermistor - ATC Semitec 104GT-2 (Used in ParCan & J-Head) (4.7k pullup)
// 6 is 100k EPCOS - Not as accurate as table 1 (created using a fluke thermocouple) (4.7k pullup)
// 7 is 100k Honeywell thermistor 135-104LAG-J01 (4.7k pullup)
// 71 is 100k Honeywell thermistor 135-104LAF-J01 (4.7k pullup)
// 8 is 100k 0603 SMD Vishay NTCS0603E3104FXT (4.7k pullup)
// 9 is 100k GE Sensing AL03006-58.2K-97-G1 (4.7k pullup)
// 10 is 100k RS thermistor 198-961 (4.7k pullup)
// 11 is 100k beta 3950 1% thermistor (4.7k pullup)
// 12 is 100k 0603 SMD Vishay NTCS0603E3104FXT (4.7k pullup) (calibrated for Makibox hot bed)
// 13 is 100k Hisens 3950  1% up to 300°C for hotend "Simple ONE " & "Hotend "All In ONE"
// 20 is the PT100 circuit found in the Ultimainboard V2.x
// 60 is 100k Maker's Tool Works Kapton Bed Thermistor beta=3950
//
//    1k ohm pullup tables - This is not normal, you would have to have changed out your 4.7k for 1k
//                          (but gives greater accuracy and more stable PID)
// 51 is 100k thermistor - EPCOS (1k pullup)
// 52 is 200k thermistor - ATC Semitec 204GT-2 (1k pullup)
// 55 is 100k thermistor - ATC Semitec 104GT-2 (Used in ParCan & J-Head) (1k pullup)
//
// 1047 is Pt1000 with 4k7 pullup
// 1010 is Pt1000 with 1k pullup (non standard)
// 147 is Pt100 with 4k7 pullup
// 110 is Pt100 with 1k pullup (non standard)

#define TEMP_SENSOR_0 5 // Setting gotten from wiki.e3d-online.net instructions for V6 hot end
#define TEMP_SENSOR_1 -1
#define TEMP_SENSOR_2 0

// Actual temperature must be close to target for this long before M109 returns success
#define TEMP_RESIDENCY_TIME 10  // (seconds)
#define TEMP_HYSTERESIS 3       // (degC) range of +/- temperatures considered "close" to the target one
#define TEMP_WINDOW     1       // (degC) Window around target to start the residency timer x degC early.

// The minimal temperature defines the temperature below which the heater will not be enabled It is used
// to check that the wiring to the thermistor is not broken.
// Otherwise this would lead to the heater being powered on all the time.
#define HEATER_0_MINTEMP 5
#define HEATER_1_MINTEMP 5
#define HEATER_2_MINTEMP 5

// When temperature exceeds max temp, your heater will be switched off.
// This feature exists to protect your hotend from overheating accidentally, but *NOT* from thermistor short/failure!
// You should use MINTEMP for thermistor short/failure protection.
#define HEATER_0_MAXTEMP 290
#define HEATER_1_MAXTEMP 275
#define HEATER_2_MAXTEMP 275

//===========================================================================
//============================= PID Settings ================================
//===========================================================================
// PID Tuning Guide here: http://reprap.org/wiki/PID_Tuning

// Comment the following line to disable PID and enable bang-bang.
#define PIDTEMP
#define BANG_MAX 255 // limits current to nozzle while in bang-bang mode; 255=full current
#define PID_MAX 255 // limits current to nozzle while PID is active (see PID_FUNCTIONAL_RANGE below); 255=full current
#ifdef PIDTEMP
//#define PID_DEBUG // Sends debug data to the serial port.
//#define PID_OPENLOOP 1 // Puts PID in open loop. M104/M140 sets the output power from 0 to PID_MAX
#define PID_FUNCTIONAL_RANGE 10 // If the temperature difference between the target temperature and the actual temperature
// is more then PID_FUNCTIONAL_RANGE then the PID will be shut off and the heater will be set to min/max.
#define PID_INTEGRAL_DRIVE_MAX 255  //limit for the integral term
#define K1 0.95 //smoothing factor within the PID
#define PID_dT ((OVERSAMPLENR * 10.0)/(F_CPU / 64.0 / 256.0)) //sampling period of the temperature routine

// If you are using a pre-configured hotend then you can use one of the value sets by uncommenting it
// Hangprinter (Volcano, e3d V6, Ramps)
#define  DEFAULT_Kp 39.76
#define  DEFAULT_Ki 3.26
#define  DEFAULT_Kd 121.18

#endif // PIDTEMP

//this prevents dangerous Extruder moves, i.e. if the temperature is under the limit
//can be software-disabled for whatever purposes by
#define PREVENT_DANGEROUS_EXTRUDE
//if PREVENT_DANGEROUS_EXTRUDE is on, you can still disable (uncomment) very long bits of extrusion separately.
// #define PREVENT_LENGTHY_EXTRUDE

#define EXTRUDE_MINTEMP 170
#define EXTRUDE_MAXLENGTH (X_MAX_LENGTH+Y_MAX_LENGTH) //prevent extrusion of very large distances.

//===========================================================================
//============================= Thermal Runaway Protection ==================
//===========================================================================
/*
   This is a feature to protect your printer from burn up in flames if it has
   a thermistor coming off place (this happened to a friend of mine recently and
   motivated me writing this feature).

   The issue: If a thermistor come off, it will read a lower temperature than actual.
   The system will turn the heater on forever, burning up the filament and anything
   else around.

   After the temperature reaches the target for the first time, this feature will
   start measuring for how long the current temperature stays below the target
   minus _HYSTERESIS (set_temperature - THERMAL_RUNAWAY_PROTECTION_HYSTERESIS).

   If it stays longer than _PERIOD, it means the thermistor temperature
   cannot catch up with the target, so something *may be* wrong. Then, to be on the
   safe side, the system will he halt.

   Bear in mind the count down will just start AFTER the first time the
   thermistor temperature is over the target, so you will have no problem if
   your extruder heater takes 2 minutes to hit the target on heating.

*/
// If you want to enable this feature for all your extruder heaters,
// uncomment the 2 defines below:

// Parameters for all extruder heaters
#define THERMAL_RUNAWAY_PROTECTION_PERIOD 180 //in seconds
#define THERMAL_RUNAWAY_PROTECTION_HYSTERESIS 10 // in degree Celsius

//===========================================================================
//============================= Mechanical Settings =========================
//===========================================================================

// coarse Endstop Settings
#define ENDSTOPPULLUPS // Comment this out (using // at the start of the line) to disable the endstop pullup resistors

#ifndef ENDSTOPPULLUPS
// fine endstop settings: Individual pullups. will be ignored if ENDSTOPPULLUPS is defined
// #define ENDSTOPPULLUP_XMAX
// #define ENDSTOPPULLUP_YMAX
// #define ENDSTOPPULLUP_ZMAX
// #define ENDSTOPPULLUP_XMIN
// #define ENDSTOPPULLUP_YMIN
// #define ENDSTOPPULLUP_ZMIN
#endif

#ifdef ENDSTOPPULLUPS
#define ENDSTOPPULLUP_XMAX
#define ENDSTOPPULLUP_YMAX
#define ENDSTOPPULLUP_ZMAX
#define ENDSTOPPULLUP_XMIN
#define ENDSTOPPULLUP_YMIN
#define ENDSTOPPULLUP_ZMIN
#endif

// The pullups are needed if you directly connect a mechanical endswitch between the signal and ground pins.
const bool X_MIN_ENDSTOP_INVERTING = true; // set to true to invert the logic of the endstop.
const bool Y_MIN_ENDSTOP_INVERTING = true; // set to true to invert the logic of the endstop.
const bool Z_MIN_ENDSTOP_INVERTING = true; // set to true to invert the logic of the endstop.
const bool X_MAX_ENDSTOP_INVERTING = true; // set to true to invert the logic of the endstop.
const bool Y_MAX_ENDSTOP_INVERTING = true; // set to true to invert the logic of the endstop.
const bool Z_MAX_ENDSTOP_INVERTING = true; // set to true to invert the logic of the endstop.
//#define DISABLE_MAX_ENDSTOPS
//#define DISABLE_MIN_ENDSTOPS

// For Inverting Stepper Enable Pins (Active Low) use 0, Non Inverting (Active High) use 1
#define X_ENABLE_ON 0
#define Y_ENABLE_ON 0
#define Z_ENABLE_ON 0
#define E_ENABLE_ON 0 // For all extruders

// Disables axis when it's not being used.
#define DISABLE_X false
#define DISABLE_Y false
#define DISABLE_Z false
#define DISABLE_E false // For all extruders
#define DISABLE_INACTIVE_EXTRUDER false //disable only inactive extruders and keep active extruder enabled

#define INVERT_X_DIR false // INVERT_A
#define INVERT_Y_DIR true  // INVERT_B
#define INVERT_Z_DIR false // INVERT_C

#define INVERT_E0_DIR false   // INVERT_E
#define INVERT_E1_DIR true    // INVERT_D
#define INVERT_E2_DIR false

// ENDSTOP SETTINGS:
// Sets direction of endstops when homing; 1=MAX, -1=MIN
#define X_HOME_DIR 1
#define Y_HOME_DIR 1
#define Z_HOME_DIR 1

#define min_software_endstops false // If true, axis won't move to coordinates less than HOME_POS.
#define max_software_endstops false  // If true, axis won't move to coordinates greater than the defined lengths below.

// TODO: remove this
// Travel limits after homing (units are in mm)
#define X_MAX_POS 90
#define X_MIN_POS -90
#define Y_MAX_POS 90
#define Y_MIN_POS -90
#define Z_MAX_POS MANUAL_Z_HOME_POS
#define Z_MIN_POS 0
// Not in use yet, software endstops will be removed
#define A_MAX_POS 900
#define A_MIN_POS -900
#define B_MAX_POS 900
#define B_MIN_POS -900
#define C_MAX_POS 900
#define C_MIN_POS -900
#define D_MAX_POS MANUAL_Z_HOME_POS
#define D_MIN_POS 0

#define X_MAX_LENGTH (X_MAX_POS - X_MIN_POS)
#define Y_MAX_LENGTH (Y_MAX_POS - Y_MIN_POS)
#define Z_MAX_LENGTH (Z_MAX_POS - Z_MIN_POS)

//===========================================================================
//============================= Bed Auto Leveling ===========================
//===========================================================================

// The position of the homing switches
//#define MANUAL_HOME_POSITIONS  // If defined, MANUAL_*_HOME_POS below will be used
//#define BED_CENTER_AT_0_0  // If defined, the center of the bed is at (X=0, Y=0)

//Manual homing switch locations:

#define MANUAL_HOME_POSITIONS  // MANUAL_*_HOME_POS below will be used
#define MANUAL_X_HOME_POS 0
#define MANUAL_Y_HOME_POS 0
#define MANUAL_Z_HOME_POS 0

#define HOMING_FEEDRATE {200*60, 200*60, 200*60, 200*60, 0}  // set the homing speeds (mm/min)

//===========================================================================
//============================= Steps per unit ==============================
//===========================================================================
// If EXPERIMENTAL_LINE_BUILDUP_COMPENSATION_FEATURE is enabled
// then constant ABCD values are calculated on the fly and used only used to calculate accelerations
#define DEFAULT_ESTEPS 410.0 // 410.0 set quite at random
#if defined(EXPERIMENTAL_LINE_BUILDUP_COMPENSATION_FEATURE)
#define DEFAULT_AXIS_STEPS_PER_UNIT   {0, 0, 0, 0, DEFAULT_ESTEPS}
#else
#define DEFAULT_AXIS_STEPS_PER_UNIT   {92.599, 92.599, 92.599, 92.599, DEFAULT_ESTEPS}
#endif


#define DEFAULT_MAX_FEEDRATE          {500, 500, 500, 300, 25}    // (mm/sec)
#define DEFAULT_MAX_ACCELERATION      {2000,2000,2000,2000,10000}    // X, Y, Z, E maximum start speed for accelerated moves.

#define DEFAULT_ACCELERATION          1000    // X, Y, Z and E max acceleration in mm/s^2 for printing moves
#define DEFAULT_RETRACT_ACCELERATION  3000   // X, Y, Z and E max acceleration in mm/s^2 for retracts

#define DEFAULT_NOMINAL_FILAMENT_DIA 1.75

// Offset of the extruders (uncomment if using more than one and relying on firmware to position when changing).
// The offset has to be X=0, Y=0 for the extruder 0 hotend (default extruder).
// For the other hotends it is their distance from the extruder 0 hotend.
// #define EXTRUDER_OFFSET_X {0.0, 20.00} // (in mm) for each extruder, offset of the hotend on the X axis
// #define EXTRUDER_OFFSET_Y {0.0, 5.00}  // (in mm) for each extruder, offset of the hotend on the Y axis

// The speed change that does not require acceleration (i.e. the software might assume it can be done instantaneously)
#define DEFAULT_XYJERK                13.0    // (mm/sec)
#define DEFAULT_ZJERK                 13.0    // (mm/sec)
#define DEFAULT_EJERK                 5.0    // (mm/sec)

//===========================================================================
//============================= Additional Features =========================
//===========================================================================

// EEPROM
// The microcontroller can store settings in the EEPROM, e.g. max velocity...
// M500 - stores parameters in EEPROM
// M501 - reads parameters from EEPROM (if you need reset them after you changed them temporarily).
// M502 - reverts to the default "factory settings".  You still need to store them in EEPROM afterwards if you want to.
//define this to enable EEPROM support
//#define EEPROM_SETTINGS
//to disable EEPROM Serial responses and decrease program space by ~1700 byte: comment this out:
// please keep turned on if you can.
//#define EEPROM_CHITCHAT

// Preheat Constants
#define PLA_PREHEAT_HOTEND_TEMP 180
#define PLA_PREHEAT_HPB_TEMP 70
#define PLA_PREHEAT_FAN_SPEED 255   // Insert Value between 0 and 255

#define ABS_PREHEAT_HOTEND_TEMP 240
#define ABS_PREHEAT_HPB_TEMP 100
#define ABS_PREHEAT_FAN_SPEED 255   // Insert Value between 0 and 255

// Increase the FAN pwm frequency. Removes the PWM noise but increases heating in the FET/Arduino
//#define FAST_PWM_FAN

// Use software PWM to drive the fan, as for the heaters. This uses a very low frequency
// which is not ass annoying as with the hardware PWM. On the other hand, if this frequency
// is too low, you should also increment SOFT_PWM_SCALE.
//#define FAN_SOFT_PWM

// Incrementing this by 1 will double the software PWM frequency,
// affecting heaters, and the fan if FAN_SOFT_PWM is enabled.
// However, control resolution will be halved for each increment;
// at zero value, there are 128 effective control positions.
#define SOFT_PWM_SCALE 0

// M240  Triggers a camera by emulating a Canon RC-1 Remote
// Data from: http://www.doc-diy.net/photo/rc-1_hacked/
// #define PHOTOGRAPH_PIN     23

#include "Configuration_adv.h"
#include "thermistortables.h"
#endif //__CONFIGURATION_H
