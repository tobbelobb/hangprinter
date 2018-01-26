/**
 * ConfigurationStore.cpp
 *
 * Configuration and EEPROM storage
 */
#include "Marlin.h"
#include "planner.h"
#include "temperature.h"
#include "language.h"
#include "Configuration.h"
#include "ConfigurationStore.h"

void _EEPROM_writeData(int &pos, uint8_t* value, uint8_t size) {
  uint8_t c;
  while(size--) {
    eeprom_write_byte((unsigned char*)pos, *value);
    c = eeprom_read_byte((unsigned char*)pos);
    if (c != *value) {
      SERIAL_ECHO_START;
      SERIAL_ECHOLNPGM(MSG_ERR_EEPROM_WRITE);
    }
    pos++;
    value++;
  };
}
void _EEPROM_readData(int &pos, uint8_t* value, uint8_t size) {
  do {
    *value = eeprom_read_byte((unsigned char*)pos);
    pos++;
    value++;
  } while (--size);
}
#define EEPROM_WRITE_VAR(pos, value) _EEPROM_writeData(pos, (uint8_t*)&value, sizeof(value))
#define EEPROM_READ_VAR(pos, value) _EEPROM_readData(pos, (uint8_t*)&value, sizeof(value))

//======================================================================================

#define DUMMY_PID_VALUE 3000.0f

#define EEPROM_OFFSET 100


// IMPORTANT:  Whenever there are changes made to the variables stored in EEPROM
// in the functions below, also increment the version number. This makes sure that
// the default values are used whenever there is a change to the data, to prevent
// wrong data being written to the variables.
// ALSO:  always make sure the variables in the Store and retrieve sections are in the same order.

#define EEPROM_VERSION "V16"

#ifdef EEPROM_SETTINGS

void Config_StoreSettings()  {
  char ver[4] = "000";
  int i = EEPROM_OFFSET;
  EEPROM_WRITE_VAR(i, ver); // invalidate data first
  EEPROM_WRITE_VAR(i, axis_steps_per_unit);
  EEPROM_WRITE_VAR(i, max_feedrate);
  EEPROM_WRITE_VAR(i, max_acceleration_units_per_sq_second);
  EEPROM_WRITE_VAR(i, acceleration);
  EEPROM_WRITE_VAR(i, retract_acceleration);
  EEPROM_WRITE_VAR(i, minimumfeedrate);
  EEPROM_WRITE_VAR(i, mintravelfeedrate);
  EEPROM_WRITE_VAR(i, minsegmenttime);
  EEPROM_WRITE_VAR(i, max_xy_jerk);
  EEPROM_WRITE_VAR(i, max_z_jerk);
  EEPROM_WRITE_VAR(i, max_e_jerk);
  EEPROM_WRITE_VAR(i, add_homing);

  EEPROM_WRITE_VAR(i, endstop_adj);               // 3 floats
  EEPROM_WRITE_VAR(i, delta_segments_per_second); // 1 float
  EEPROM_WRITE_VAR(i, anchor_A_x);                // 1 float
  EEPROM_WRITE_VAR(i, anchor_A_y);                // 1 float
  EEPROM_WRITE_VAR(i, anchor_A_z);                // 1 float
  EEPROM_WRITE_VAR(i, anchor_B_x);                // 1 float
  EEPROM_WRITE_VAR(i, anchor_B_y);                // 1 float
  EEPROM_WRITE_VAR(i, anchor_B_z);                // 1 float
  EEPROM_WRITE_VAR(i, anchor_C_x);                // 1 float
  EEPROM_WRITE_VAR(i, anchor_C_y);                // 1 float
  EEPROM_WRITE_VAR(i, anchor_C_z);                // 1 float
  EEPROM_WRITE_VAR(i, anchor_D_z);                // 1 float

  char ver2[4] = EEPROM_VERSION;
  int j = EEPROM_OFFSET;
  EEPROM_WRITE_VAR(j, ver2); // validate data

  // Report storage size
  SERIAL_ECHO_START;
  SERIAL_ECHOPAIR("Settings Stored (", (unsigned long)i);
  SERIAL_ECHOLNPGM(" bytes)");
}

void Config_RetrieveSettings() {

  int i = EEPROM_OFFSET;
  char stored_ver[4];
  char ver[4] = EEPROM_VERSION;
  EEPROM_READ_VAR(i, stored_ver); //read stored version
  SERIAL_ECHO("Version: [");
  SERIAL_ECHO(ver);
  SERIAL_ECHO("] Stored version: [");
  SERIAL_ECHO(stored_ver);
  SERIAL_ECHOLN("]");

  if (strncmp(ver, stored_ver, 3) != 0) {
    SERIAL_ECHOLN("Version numbers don't match. Fallin back to default settings.");
    Config_ResetDefault();
  }
  else {
    // version number match
    EEPROM_READ_VAR(i, axis_steps_per_unit);
    EEPROM_READ_VAR(i, max_feedrate);
    EEPROM_READ_VAR(i, max_acceleration_units_per_sq_second);

    // steps per sq second need to be updated to agree with the units per sq second (as they are what is used in the planner)
    reset_acceleration_rates();

    EEPROM_READ_VAR(i, acceleration);
    EEPROM_READ_VAR(i, retract_acceleration);
    EEPROM_READ_VAR(i, minimumfeedrate);
    EEPROM_READ_VAR(i, mintravelfeedrate);
    EEPROM_READ_VAR(i, minsegmenttime);
    EEPROM_READ_VAR(i, max_xy_jerk);
    EEPROM_READ_VAR(i, max_z_jerk);
    EEPROM_READ_VAR(i, max_e_jerk);
    EEPROM_READ_VAR(i, add_homing);

    EEPROM_READ_VAR(i, endstop_adj);                // 3 floats
    EEPROM_READ_VAR(i, delta_segments_per_second);  // 1 float
    EEPROM_READ_VAR(i, anchor_A_x);                // 1 float
    EEPROM_READ_VAR(i, anchor_A_y);                // 1 float
    EEPROM_READ_VAR(i, anchor_A_z);                // 1 float
    EEPROM_READ_VAR(i, anchor_B_x);                // 1 float
    EEPROM_READ_VAR(i, anchor_B_y);                // 1 float
    EEPROM_READ_VAR(i, anchor_B_z);                // 1 float
    EEPROM_READ_VAR(i, anchor_C_x);                // 1 float
    EEPROM_READ_VAR(i, anchor_C_y);                // 1 float
    EEPROM_READ_VAR(i, anchor_C_z);                // 1 float
    EEPROM_READ_VAR(i, anchor_D_z);                // 1 float

    // Report settings retrieved and length
    SERIAL_ECHO_START;
    SERIAL_ECHO(ver);
    SERIAL_ECHOPAIR(" stored settings retrieved (", (unsigned long)i);
    SERIAL_ECHOLNPGM(" bytes)");
  }

#ifdef EEPROM_CHITCHAT
  Config_PrintSettings();
#endif
}

#endif // EEPROM_SETTINGS

void Config_ResetDefault() {
  float tmp1[] = DEFAULT_AXIS_STEPS_PER_UNIT;
  float tmp2[] = DEFAULT_MAX_FEEDRATE;
  long tmp3[] = DEFAULT_MAX_ACCELERATION;
  for (int i = 0; i < NUM_AXIS; i++) {
    axis_steps_per_unit[i] = tmp1[i];
    max_feedrate[i] = tmp2[i];
    max_acceleration_units_per_sq_second[i] = tmp3[i];
  }

  // steps per sq second need to be updated to agree with the units per sq second
  reset_acceleration_rates();

  acceleration = DEFAULT_ACCELERATION;
  retract_acceleration = DEFAULT_RETRACT_ACCELERATION;
  minimumfeedrate = DEFAULT_MINIMUMFEEDRATE;
  minsegmenttime = DEFAULT_MINSEGMENTTIME;
  mintravelfeedrate = DEFAULT_MINTRAVELFEEDRATE;
  max_xy_jerk = DEFAULT_XYJERK;
  max_z_jerk = DEFAULT_ZJERK;
  max_e_jerk = DEFAULT_EJERK;
  add_homing[A_AXIS] = add_homing[B_AXIS] = add_homing[C_AXIS] = add_homing[D_AXIS] = 0;
#if defined(HANGPRINTER)
  anchor_A_x = float(ANCHOR_A_X);
  anchor_A_y = float(ANCHOR_A_Y);
  anchor_A_z = float(ANCHOR_A_Z);
  anchor_B_x = float(ANCHOR_B_X);
  anchor_B_y = float(ANCHOR_B_Y);
  anchor_B_z = float(ANCHOR_B_Z);
  anchor_C_x = float(ANCHOR_C_X);
  anchor_C_y = float(ANCHOR_C_Y);
  anchor_C_z = float(ANCHOR_C_Z);
  anchor_D_z = float(ANCHOR_D_Z);
#endif
  delta_segments_per_second =  DELTA_SEGMENTS_PER_SECOND;
  endstop_adj[A_AXIS] = endstop_adj[B_AXIS] = endstop_adj[C_AXIS] = endstop_adj[D_AXIS] = 0;

#ifdef PIDTEMP
  Kp = DEFAULT_Kp;
  Ki = scalePID_i(DEFAULT_Ki);
  Kd = scalePID_d(DEFAULT_Kd);
  #ifdef PID_ADD_EXTRUSION_RATE
    Kc = DEFAULT_Kc;
  #endif
  // call updatePID (similar to when we have processed M301)
  updatePID();
#endif // PIDTEMP

  volumetric_enabled = false;
  filament_size[0] = DEFAULT_NOMINAL_FILAMENT_DIA;
  calculate_volumetric_multipliers();

  SERIAL_ECHO_START;
  SERIAL_ECHOLNPGM("Hardcoded Default Settings Loaded");
}

#ifndef DISABLE_M503

void Config_PrintSettings(bool forReplay) {
  // Always have this function, even with EEPROM_SETTINGS disabled, the current values will be shown

  SERIAL_ECHO_START;

  if (!forReplay) {
    SERIAL_ECHOLNPGM("Steps per unit:");
    SERIAL_ECHO_START;
  }
  SERIAL_ECHOPAIR("  M92 A", axis_steps_per_unit[A_AXIS]);
  SERIAL_ECHOPAIR(" B", axis_steps_per_unit[B_AXIS]);
  SERIAL_ECHOPAIR(" C", axis_steps_per_unit[C_AXIS]);
  SERIAL_ECHOPAIR(" D", axis_steps_per_unit[D_AXIS]);
  SERIAL_ECHOPAIR(" E", axis_steps_per_unit[E_AXIS]);
  SERIAL_EOL;

  SERIAL_ECHO_START;

  if (!forReplay) {
    SERIAL_ECHOLNPGM("Maximum feedrates (mm/s):");
    SERIAL_ECHO_START;
  }
  SERIAL_ECHOPAIR("  M203 A", max_feedrate[A_AXIS]);
  SERIAL_ECHOPAIR(" B", max_feedrate[B_AXIS]);
  SERIAL_ECHOPAIR(" C", max_feedrate[C_AXIS]);
  SERIAL_ECHOPAIR(" D", max_feedrate[D_AXIS]);
  SERIAL_ECHOPAIR(" E", max_feedrate[E_AXIS]);
  SERIAL_EOL;

  SERIAL_ECHO_START;
  if (!forReplay) {
    SERIAL_ECHOLNPGM("Maximum Acceleration (mm/s2):");
    SERIAL_ECHO_START;
  }
  SERIAL_ECHOPAIR("  M201 A", max_acceleration_units_per_sq_second[A_AXIS] );
  SERIAL_ECHOPAIR(" B", max_acceleration_units_per_sq_second[B_AXIS] );
  SERIAL_ECHOPAIR(" C", max_acceleration_units_per_sq_second[C_AXIS] );
  SERIAL_ECHOPAIR(" D", max_acceleration_units_per_sq_second[D_AXIS] );
  SERIAL_ECHOPAIR(" E", max_acceleration_units_per_sq_second[E_AXIS]);
  SERIAL_EOL;
  SERIAL_ECHO_START;
  if (!forReplay) {
    SERIAL_ECHOLNPGM("Acceleration: S=acceleration, T=retract acceleration");
    SERIAL_ECHO_START;
  }
  SERIAL_ECHOPAIR("  M204 S", acceleration );
  SERIAL_ECHOPAIR(" T", retract_acceleration);
  SERIAL_EOL;

  SERIAL_ECHO_START;
  if (!forReplay) {
    SERIAL_ECHOLNPGM("Advanced variables: S=Min feedrate (mm/s), T=Min travel feedrate (mm/s), B=minimum segment time (ms), X=maximum XY jerk (mm/s),  Z=maximum Z jerk (mm/s),  E=maximum E jerk (mm/s)");
    SERIAL_ECHO_START;
  }
  SERIAL_ECHOPAIR("  M205 S", minimumfeedrate );
  SERIAL_ECHOPAIR(" T", mintravelfeedrate );
  SERIAL_ECHOPAIR(" B", minsegmenttime );
  SERIAL_ECHOPAIR(" X", max_xy_jerk );
  SERIAL_ECHOPAIR(" Z", max_z_jerk);
  SERIAL_ECHOPAIR(" E", max_e_jerk);
  SERIAL_EOL;

  SERIAL_ECHO_START;
  if (!forReplay) {
    SERIAL_ECHOLNPGM("Home offset (mm):");
    SERIAL_ECHO_START;
  }
  SERIAL_ECHOPAIR("  M206 A", add_homing[A_AXIS] );
  SERIAL_ECHOPAIR(" B", add_homing[B_AXIS] );
  SERIAL_ECHOPAIR(" C", add_homing[C_AXIS] );
  SERIAL_ECHOPAIR(" D", add_homing[D_AXIS] );
  SERIAL_EOL;

#ifdef DELTA
  SERIAL_ECHO_START;
  if (!forReplay) {
    SERIAL_ECHOLNPGM("Endstop adjustement (mm):");
    SERIAL_ECHO_START;
  }
  SERIAL_ECHOPAIR("  M666 A", endstop_adj[A_AXIS] );
  SERIAL_ECHOPAIR(" B", endstop_adj[B_AXIS] );
  SERIAL_ECHOPAIR(" C", endstop_adj[C_AXIS] );
  SERIAL_ECHOPAIR(" D", endstop_adj[D_AXIS] );
  SERIAL_EOL;
#ifdef HANGPRINTER
  SERIAL_ECHO_START;
  SERIAL_ECHOPAIR("  M665 Q",  anchor_A_x);
  SERIAL_ECHOPAIR(      " W",  anchor_A_y);
  SERIAL_ECHOPAIR(      " E",  anchor_A_z);
  SERIAL_ECHOPAIR(      " R",  anchor_B_x);
  SERIAL_ECHOPAIR(      " T",  anchor_B_y);
  SERIAL_ECHOPAIR(      " Y",  anchor_B_z);
  SERIAL_ECHOPAIR(      " U",  anchor_C_x);
  SERIAL_ECHOPAIR(      " I",  anchor_C_y);
  SERIAL_ECHOPAIR(      " O",  anchor_C_z);
  SERIAL_ECHOPAIR(      " P",  anchor_D_z);
  SERIAL_EOL;
#else
  SERIAL_ECHOLNPGM("Delta settings: L=delta_diagonal_rod, R=delta_radius, S=delta_segments_per_second");
  SERIAL_ECHO_START;
  SERIAL_ECHOPAIR("  M665 L", delta_diagonal_rod );
  SERIAL_ECHOPAIR(" R", delta_radius );
#endif
  SERIAL_ECHO_START;
  SERIAL_ECHOPAIR(" DELTA_SEGMENTS_PER_SECOND: ", delta_segments_per_second );
  SERIAL_EOL;
#endif // DELTA

#ifdef PIDTEMP
  SERIAL_ECHO_START;
  if (!forReplay) {
    SERIAL_ECHOLNPGM("PID settings:");
    SERIAL_ECHO_START;
  }
  SERIAL_ECHOPAIR("   M301 P", Kp); // for compatibility with hosts, only echos values for E0
  SERIAL_ECHOPAIR(" I", unscalePID_i(Ki));
  SERIAL_ECHOPAIR(" D", unscalePID_d(Kd));
  SERIAL_EOL;
#endif // PIDTEMP

  SERIAL_ECHO_START;
  if (volumetric_enabled) {
    if (!forReplay) {
      SERIAL_ECHOLNPGM("Filament settings:");
      SERIAL_ECHO_START;
    }
    SERIAL_ECHOPAIR("   M200 D", filament_size[0]);
    SERIAL_EOL;
  } else {
    if (!forReplay) {
      SERIAL_ECHOLNPGM("Filament settings: Disabled");
    }
  }

}

#endif // !DISABLE_M503
