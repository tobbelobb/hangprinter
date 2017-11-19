/*
   stepper.c - stepper motor driver: executes motion plans using stepper motors
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

/* The timer calculations of this module informed by the 'RepRap cartesian firmware' by Zack Smith
   and Philipp Tiefenbacher. */

#include "Marlin.h"
#include "stepper.h"
#include "planner.h"
#include "temperature.h"
#include "language.h"
#include "speed_lookuptable.h"
#if defined(DIGIPOTSS_PIN) && DIGIPOTSS_PIN > -1
#include <SPI.h>
#endif

#if defined(HAVE_TMC2130)
#include "Configuration.h"
#include <SPI.h>
#include <TMC2130Stepper.h>
#endif //defined(HAVE_TMC2130)


//===========================================================================
//=============================public variables  ============================
//===========================================================================
block_t *current_block;  // A pointer to the block currently being traced


//===========================================================================
//=============================private variables ============================
//===========================================================================
//static makes it inpossible to be called from outside of this file by extern.!

// Variables used by The Stepper Driver Interrupt
static unsigned char out_bits;        // The next stepping-bits to be output
static long counter_a,       // Counter variables for the bresenham line tracer
            counter_b,
            counter_c,
            counter_d,
            counter_e;
volatile static unsigned long step_events_completed; // The number of step events executed in the current block
static long acceleration_time, deceleration_time;
//static unsigned long accelerate_until, decelerate_after, acceleration_rate, initial_rate, final_rate, nominal_rate;
static unsigned short acc_step_rate; // needed for deccelaration start point
static char step_loops;
static unsigned short OCR1A_nominal;
static unsigned short step_loops_nominal;

volatile long endstops_trigsteps[3]={0,0,0};
volatile long endstops_stepsTotal,endstops_stepsDone;
static volatile bool endstop_x_hit=false;
static volatile bool endstop_y_hit=false;
static volatile bool endstop_z_hit=false;
#ifdef ABORT_ON_ENDSTOP_HIT_FEATURE_ENABLED
bool abort_on_endstop_hit = false;
#endif
#ifdef MOTOR_CURRENT_PWM_XY_PIN
int motor_current_setting[3] = DEFAULT_PWM_MOTOR_CURRENT;
#endif

static bool old_x_min_endstop=false;
static bool old_x_max_endstop=false;
static bool old_y_min_endstop=false;
static bool old_y_max_endstop=false;
static bool old_z_min_endstop=false;
static bool old_z_max_endstop=false;

static bool check_endstops = true;
#ifdef EXPERIMENTAL_LINE_BUILDUP_COMPENSATION_FEATURE
volatile long count_position[NUM_AXIS] = { lround(k0[A_AXIS]*(sqrt(k1[A_AXIS] + k2[A_AXIS]*INITIAL_DISTANCES[A_AXIS]) - sqrtk1[A_AXIS])),
                                           lround(k0[B_AXIS]*(sqrt(k1[B_AXIS] + k2[B_AXIS]*INITIAL_DISTANCES[B_AXIS]) - sqrtk1[B_AXIS])),
                                           lround(k0[C_AXIS]*(sqrt(k1[C_AXIS] + k2[C_AXIS]*INITIAL_DISTANCES[C_AXIS]) - sqrtk1[C_AXIS])),
                                           lround(k0[D_AXIS]*(sqrt(k1[D_AXIS] + k2[D_AXIS]*INITIAL_DISTANCES[D_AXIS]) - sqrtk1[D_AXIS])), 0 }; // Assume we start in origo.
#else
float tmp_def_ax_st_p_u[NUM_AXIS] = DEFAULT_AXIS_STEPS_PER_UNIT;
volatile long count_position[NUM_AXIS] = { INITIAL_DISTANCES[A_AXIS]*tmp_def_ax_st_p_u[A_AXIS],
                                           INITIAL_DISTANCES[B_AXIS]*tmp_def_ax_st_p_u[B_AXIS],
                                           INITIAL_DISTANCES[C_AXIS]*tmp_def_ax_st_p_u[C_AXIS],
                                           INITIAL_DISTANCES[D_AXIS]*tmp_def_ax_st_p_u[D_AXIS], 0 }; // Assume we start in origo.
#endif // EXPERIMENTAL_LINE_BUILDUP_COMPENSATION_FEATURE
volatile signed char count_direction[NUM_AXIS] = { 1, 1, 1, 1, 1};

//===========================================================================
//=============================functions         ============================
//===========================================================================

#define CHECK_ENDSTOPS  if(check_endstops)

// intRes = intIn1 * intIn2 >> 16
// uses:
// r26 to store 0
// r27 to store the byte 1 of the 24 bit result
#define MultiU16X8toH16(intRes, charIn1, intIn2) \
  asm volatile ( \
      "clr r26 \n\t" \
      "mul %A1, %B2 \n\t" \
      "movw %A0, r0 \n\t" \
      "mul %A1, %A2 \n\t" \
      "add %A0, r1 \n\t" \
      "adc %B0, r26 \n\t" \
      "lsr r0 \n\t" \
      "adc %A0, r26 \n\t" \
      "adc %B0, r26 \n\t" \
      "clr r1 \n\t" \
      : \
      "=&r" (intRes) \
      : \
      "d" (charIn1), \
      "d" (intIn2) \
      : \
      "r26" \
      )

// intRes = longIn1 * longIn2 >> 24
// uses:
// r26 to store 0
// r27 to store the byte 1 of the 48bit result
#define MultiU24X24toH16(intRes, longIn1, longIn2) \
  asm volatile ( \
      "clr r26 \n\t" \
      "mul %A1, %B2 \n\t" \
      "mov r27, r1 \n\t" \
      "mul %B1, %C2 \n\t" \
      "movw %A0, r0 \n\t" \
      "mul %C1, %C2 \n\t" \
      "add %B0, r0 \n\t" \
      "mul %C1, %B2 \n\t" \
      "add %A0, r0 \n\t" \
      "adc %B0, r1 \n\t" \
      "mul %A1, %C2 \n\t" \
      "add r27, r0 \n\t" \
      "adc %A0, r1 \n\t" \
      "adc %B0, r26 \n\t" \
      "mul %B1, %B2 \n\t" \
      "add r27, r0 \n\t" \
      "adc %A0, r1 \n\t" \
      "adc %B0, r26 \n\t" \
      "mul %C1, %A2 \n\t" \
      "add r27, r0 \n\t" \
"adc %A0, r1 \n\t" \
"adc %B0, r26 \n\t" \
"mul %B1, %A2 \n\t" \
"add r27, r1 \n\t" \
"adc %A0, r26 \n\t" \
"adc %B0, r26 \n\t" \
"lsr r27 \n\t" \
"adc %A0, r26 \n\t" \
"adc %B0, r26 \n\t" \
"clr r1 \n\t" \
: \
"=&r" (intRes) \
: \
"d" (longIn1), \
"d" (longIn2) \
: \
"r26" , "r27" \
)

// Some useful constants

#define ENABLE_STEPPER_DRIVER_INTERRUPT()  TIMSK1 |= (1<<OCIE1A)
#define DISABLE_STEPPER_DRIVER_INTERRUPT() TIMSK1 &= ~(1<<OCIE1A)


void checkHitEndstops()
{
  if( endstop_x_hit || endstop_y_hit || endstop_z_hit) {
    SERIAL_ECHO_START;
    SERIAL_ECHOPGM(MSG_ENDSTOPS_HIT);
    if(endstop_x_hit) {
      SERIAL_ECHOPAIR(" X:",(float)endstops_trigsteps[X_AXIS]/axis_steps_per_unit[X_AXIS]);
    }
    if(endstop_y_hit) {
      SERIAL_ECHOPAIR(" Y:",(float)endstops_trigsteps[Y_AXIS]/axis_steps_per_unit[Y_AXIS]);
    }
    if(endstop_z_hit) {
      SERIAL_ECHOPAIR(" Z:",(float)endstops_trigsteps[Z_AXIS]/axis_steps_per_unit[Z_AXIS]);
    }
    SERIAL_ECHOLN("");
    endstop_x_hit=false;
    endstop_y_hit=false;
    endstop_z_hit=false;
  }
}

void endstops_hit_on_purpose()
{
  endstop_x_hit=false;
  endstop_y_hit=false;
  endstop_z_hit=false;
}

void enable_endstops(bool check)
{
  check_endstops = check;
}

//         __________________________
//        /|                        |\     _________________         ^
//       / |                        | \   /|               |\        |
//      /  |                        |  \ / |               | \       s
//     /   |                        |   |  |               |  \      p
//    /    |                        |   |  |               |   \     e
//   +-----+------------------------+---+--+---------------+----+    e
//   |               BLOCK 1            |      BLOCK 2          |    d
//
//                           time ----->
//
//  The trapezoid is the shape the speed curve over time. It starts at block->initial_rate, accelerates
//  first block->accelerate_until step_events_completed, then keeps going at constant speed until
//  step_events_completed reaches block->decelerate_after after which it decelerates until the trapezoid generator is reset.
//  The slope of acceleration is calculated with the leib ramp alghorithm.

void st_wake_up() {
  //  TCNT1 = 0;
  ENABLE_STEPPER_DRIVER_INTERRUPT();
}

FORCE_INLINE unsigned short calc_timer(unsigned short step_rate) {
  unsigned short timer;
  if(step_rate > MAX_STEP_FREQUENCY) step_rate = MAX_STEP_FREQUENCY;

  if(step_rate > 20000) { // If steprate > 20kHz >> step 4 times
    step_rate = (step_rate >> 2)&0x3fff;
    step_loops = 4;
  }
  else if(step_rate > 10000) { // If steprate > 10kHz >> step 2 times
    step_rate = (step_rate >> 1)&0x7fff;
    step_loops = 2;
  }
  else {
    step_loops = 1;
  }

  if(step_rate < (F_CPU/500000)) step_rate = (F_CPU/500000);
  step_rate -= (F_CPU/500000); // Correct for minimal speed
  if(step_rate >= (8*256)){ // higher step rate
    unsigned short table_address = (unsigned short)&speed_lookuptable_fast[(unsigned char)(step_rate>>8)][0];
    unsigned char tmp_step_rate = (step_rate & 0x00ff);
    unsigned short gain = (unsigned short)pgm_read_word_near(table_address+2);
    MultiU16X8toH16(timer, tmp_step_rate, gain);
    timer = (unsigned short)pgm_read_word_near(table_address) - timer;
  }
  else { // lower step rates
    unsigned short table_address = (unsigned short)&speed_lookuptable_slow[0][0];
    table_address += ((step_rate)>>1) & 0xfffc;
    timer = (unsigned short)pgm_read_word_near(table_address);
    timer -= (((unsigned short)pgm_read_word_near(table_address+2) * (unsigned char)(step_rate & 0x0007))>>3);
  }
  if(timer < 100) { timer = 100; MYSERIAL.print(MSG_STEPPER_TOO_HIGH); MYSERIAL.println(step_rate); }//(20kHz this should never happen)
  return timer;
}

// Initializes the trapezoid generator from the current block. Called whenever a new
// block begins.
FORCE_INLINE void trapezoid_generator_reset() {
  deceleration_time = 0;
  // step_rate to timer interval
  OCR1A_nominal = calc_timer(current_block->nominal_rate);
  // make a note of the number of step loops required at nominal speed
  step_loops_nominal = step_loops;
  acc_step_rate = current_block->initial_rate;
  acceleration_time = calc_timer(acc_step_rate);
  OCR1A = acceleration_time;

  //    SERIAL_ECHO_START;
  //    SERIAL_ECHOPGM("advance :");
  //    SERIAL_ECHO(current_block->advance/256.0);
  //    SERIAL_ECHOPGM("advance rate :");
  //    SERIAL_ECHO(current_block->advance_rate/256.0);
  //    SERIAL_ECHOPGM("initial advance :");
  //    SERIAL_ECHO(current_block->initial_advance/256.0);
  //    SERIAL_ECHOPGM("final advance :");
  //    SERIAL_ECHOLN(current_block->final_advance/256.0);

}

// "The Stepper Driver Interrupt" - This timer interrupt is the workhorse.
// It pops blocks from the block_buffer and executes them by pulsing the stepper pins appropriately.
ISR(TIMER1_COMPA_vect)
{
  // If there is no current block, attempt to pop one from the buffer
  if (current_block == NULL) {
    // Anything in the buffer?
    current_block = plan_get_current_block();
    if (current_block != NULL) {
      current_block->busy = true;
      trapezoid_generator_reset();
      counter_a = -(current_block->step_event_count >> 1);
      counter_b = counter_a;
      counter_c = counter_a;
      counter_d = counter_a;
      counter_e = counter_a;
      step_events_completed = 0;
    }
    else {
      OCR1A=2000; // 1kHz.
    }
  }

  if (current_block != NULL) {
    // Set directions TO DO This should be done once during init of trapezoid. Endstops -> interrupt
    out_bits = current_block->direction_bits;
#if defined(HANGPRINTER)
    // Pins on RAMPS are marked X, Y, Z, E0, E1
    // To avoid as much confusion as possible, we map
    // hardware names to software names like the following
    // X  --> A
    // Y  --> B
    // Z  --> C
    // E0 --> E
    // E1 --> D
    if(out_bits & (1<<A_AXIS)){
      WRITE(X_DIR_PIN, INVERT_X_DIR);
      count_direction[A_AXIS]=-1;
    }else{
      WRITE(X_DIR_PIN, !INVERT_X_DIR);
      count_direction[A_AXIS]=1;
    }

    if(out_bits & (1<<B_AXIS)){
      WRITE(Y_DIR_PIN, INVERT_Y_DIR);
      count_direction[B_AXIS]=-1;
    }else{
      WRITE(Y_DIR_PIN, !INVERT_Y_DIR);
      count_direction[B_AXIS]=1;
    }

    if(out_bits & (1<<C_AXIS)){
      WRITE(Z_DIR_PIN, INVERT_Z_DIR);
      count_direction[C_AXIS]=-1;
    }else{
      WRITE(Z_DIR_PIN, !INVERT_Z_DIR);
      count_direction[C_AXIS]=1;
    }

    if(out_bits & (1<<D_AXIS)){
      WRITE(E1_DIR_PIN, INVERT_E1_DIR);
      count_direction[D_AXIS]=-1;
    }else{
      WRITE(E1_DIR_PIN, !INVERT_E1_DIR);
      count_direction[D_AXIS]=1;
    }
#else
    if(out_bits & (1<<X_AXIS)){
      WRITE(X_DIR_PIN, INVERT_X_DIR);
      count_direction[X_AXIS]=-1;
    }else{
      WRITE(X_DIR_PIN, !INVERT_X_DIR);
      count_direction[X_AXIS]=1;
    }

    if(out_bits & (1<<Y_AXIS)){
      WRITE(Y_DIR_PIN, INVERT_Y_DIR);
      count_direction[Y_AXIS]=-1;
    }else{
      WRITE(Y_DIR_PIN, !INVERT_Y_DIR);
      count_direction[Y_AXIS]=1;
    }
    if ((out_bits & (1<<Z_AXIS))) {   // -direction
      WRITE(Z_DIR_PIN,INVERT_Z_DIR);
      count_direction[Z_AXIS]=-1;
    }else{ // +direction
      WRITE(Z_DIR_PIN,!INVERT_Z_DIR);
      count_direction[Z_AXIS]=1;
    }
#endif

    if ((out_bits & (1<<E_AXIS)) != 0) {  // -direction
      REV_E_DIR();
      count_direction[E_AXIS]=-1;
    }
    else { // +direction
      NORM_E_DIR();
      count_direction[E_AXIS]=1;
    }

    for(int8_t i=0; i < step_loops; i++) { // Take multiple steps per interrupt (For high speed moves)
      MSerial.checkRx(); // Check for serial chars.

      counter_a += current_block->steps_a;
      if (counter_a > 0) {
        WRITE(X_STEP_PIN, !INVERT_X_STEP_PIN);
        counter_a -= current_block->step_event_count;
        if(current_block->count_it){
          count_position[A_AXIS]+=count_direction[A_AXIS];
        }
        // TODO: could we use the delay for something, rather than just waiting?
        // For examle read a sensor that feels if a step has been skipped?
        // Five nops tested to be shortest possible delay using atmega 2560 (16Mhz) and drv8825
        // driver chip on a RAMPS v1.4.
        __asm__ volatile("nop\n\t"
                         "nop\n\t"
                         "nop\n\t"
                         "nop\n\t"
                         "nop\n\t");
        WRITE(X_STEP_PIN, INVERT_X_STEP_PIN);
      }

      counter_b += current_block->steps_b;
      if (counter_b > 0) {
        WRITE(Y_STEP_PIN, !INVERT_Y_STEP_PIN);
        counter_b -= current_block->step_event_count;
        if(current_block->count_it){
          count_position[B_AXIS]+=count_direction[B_AXIS];
        }
        __asm__ volatile("nop\n\t"
                         "nop\n\t"
                         "nop\n\t"
                         "nop\n\t"
                         "nop\n\t");
        WRITE(Y_STEP_PIN, INVERT_Y_STEP_PIN);
      }

      counter_c += current_block->steps_c;
      if (counter_c > 0) {
        WRITE(Z_STEP_PIN, !INVERT_Z_STEP_PIN);
        counter_c -= current_block->step_event_count;
        if(current_block->count_it){
          count_position[C_AXIS]+=count_direction[C_AXIS];
        }
        __asm__ volatile("nop\n\t"
                         "nop\n\t"
                         "nop\n\t"
                         "nop\n\t"
                         "nop\n\t");
        WRITE(Z_STEP_PIN, INVERT_Z_STEP_PIN);
      }

      // D motor should be connected to E1_STEP_PIN
      counter_d += current_block->steps_d;
      if (counter_d > 0) {
        WRITE(E1_STEP_PIN, !INVERT_E1_STEP_PIN);
        counter_d -= current_block->step_event_count;
        if(current_block->count_it){
          count_position[D_AXIS]+=count_direction[D_AXIS];
        }
        __asm__ volatile("nop\n\t"
                         "nop\n\t"
                         "nop\n\t"
                         "nop\n\t"
                         "nop\n\t");
        WRITE(E1_STEP_PIN, INVERT_E1_STEP_PIN);
      }

      counter_e += current_block->steps_e;
      if (counter_e > 0) {
        WRITE_E_STEP(!INVERT_E_STEP_PIN);
        counter_e -= current_block->step_event_count;
        if(current_block->count_it){
          count_position[E_AXIS]+=count_direction[E_AXIS];
        }
        __asm__ volatile("nop\n\t"
                         "nop\n\t"
                         "nop\n\t"
                         "nop\n\t"
                         "nop\n\t");
        WRITE_E_STEP(INVERT_E_STEP_PIN);
      }
      step_events_completed += 1;
      if(step_events_completed >= current_block->step_event_count) break;
    }
    // Calculare new timer value
    unsigned short timer;
    unsigned short step_rate;
    if (step_events_completed <= (unsigned long int)current_block->accelerate_until) {
      MultiU24X24toH16(acc_step_rate, acceleration_time, current_block->acceleration_rate);
      acc_step_rate += current_block->initial_rate;
      // upper limit
      if(acc_step_rate > current_block->nominal_rate)
        acc_step_rate = current_block->nominal_rate;
      // step_rate to timer interval
      timer = calc_timer(acc_step_rate);
      OCR1A = timer;
      acceleration_time += timer;
    }else if (step_events_completed > (unsigned long int)current_block->decelerate_after) {
      MultiU24X24toH16(step_rate, deceleration_time, current_block->acceleration_rate);

      if(step_rate > acc_step_rate) { // Check step_rate stays positive
        step_rate = current_block->final_rate;
      }else{
        step_rate = acc_step_rate - step_rate; // Decelerate from aceleration end point.
      }

      // lower limit
      if(step_rate < current_block->final_rate)
        step_rate = current_block->final_rate;

      // step_rate to timer interval
      timer = calc_timer(step_rate);
      OCR1A = timer;
      deceleration_time += timer;
    }else{
      OCR1A = OCR1A_nominal;
      // ensure we're running at the correct step rate, even if we just came off an acceleration
      step_loops = step_loops_nominal;
    }

    // If current block is finished, reset pointer
    if (step_events_completed >= current_block->step_event_count) {
      current_block = NULL;
      plan_discard_current_block();
    }
  }
}

#if defined(HAVE_TMC2130)
// Stepper objects of TMC2310 steppers used
TMC2130Stepper stepperA(X_ENABLE_PIN, X_DIR_PIN, X_STEP_PIN, A_CHIP_SELECT);
TMC2130Stepper stepperB(Y_ENABLE_PIN, Y_DIR_PIN, Y_STEP_PIN, B_CHIP_SELECT);
TMC2130Stepper stepperC(Z_ENABLE_PIN, Z_DIR_PIN, Z_STEP_PIN, C_CHIP_SELECT);
TMC2130Stepper stepperD(E1_ENABLE_PIN, E1_DIR_PIN, E1_STEP_PIN, D_CHIP_SELECT);
TMC2130Stepper stepperE(E0_ENABLE_PIN, E0_DIR_PIN, E0_STEP_PIN, E_CHIP_SELECT);

void tmc2130_init(TMC2130Stepper &st, const uint16_t microsteps, const uint16_t maxcurrent){
  st.begin(); // sets blank_time(24)
 /* ==== General Configuration Strategy ==================
    - Use spreadCycle with coolStep
    - Use spreadCycle+chopSync instead of stealthChop
    - Stall detection is sent to diag0
       to prepare for future upgrade that makes use of such data */

  // ============== COOLSTEP THRESHOLDS ===================
  st.mode_sw_speed(102); // Sets THIGH to 102 = 16777216/(100*1630), where 16777216 is CPU freq, 100 is mm/s, 1630 is ca steps/mm.
  st.coolstep_min_speed(294); // Sets TCOOLTHRS = 294, roughly equal to 35 mm/s movement
  st.sgt(11); // Sets SGT to 11. This makes stallGuard a bit less sensitive, and creates range [SEMIN*32, (SEMIN+SEMAX+1)*32] for coolStep
  st.semin(0x1);
  st.semax(0x3);
  st.stealth_max_speed(0x406); // TPWMTHRS = 1030 TSTEPS

  // ================  GCONF   ============================
  // See datasheet GCONF table, page 25 of tmc2130 datasheet
  st.stealthChop(1);
  st.diag0_active_high(1);
  st.diag0_stall(1);
  /* GCONF settings:
     - No test mode
     - No direct mode
     - Not emergency stopped
     - No halved hysteresis for step frequency comparison (1/16, not 1/32)
     - DIAG1 is active when it's low
     - DIAG0 is active when it's high
     - No output toggle when steps are skipped in dcStep mode
     - No active diag1 when chopper is on (for one phase)
     - No diag1 active on index position
     - No diag1 active on motor stall
     - diag0 is active on motor stall
     - No diag0 active on over temperature prewarning
     - No diag0 active on driver errors
     - No inverse motor direction
     - No commutation mode
     ? Disable stealthChop voltage PWM mode. Or just "stealthChop".
     - No internal rsense
     - No analog current reference

     |17|16|15|14|13|12|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0
       0  0  0  0  0  1  0  0  0  0  1  0  0  0  0  0  0  0
     in binary:  0b000001000010000000
     in hex: 0x1080
     Reference from TRAMS-Firmware
       0  0  0  0  0  1  0  0  0  0  1  0  0  0  0  1  0  0
  */

  // ================ CHOPCONF ============================
  // See datasheet CHOPCONF table, page 34 of tmc2130 datasheet
  st.microsteps(microsteps);
  //st.sync(0x6); // No autible difference
  st.vhighchm(1);
  st.vhighfs(1);
  st.tbl(0x1);
  //st.hend(0x1);
  st.hstrt(0x4); // Reduces noise during spreadCycle movement a little bit. TODO: tune hend and hstrt a bit more...
  st.toff(0x5);
  /*
     - Short to GND protection is ON
     - Disable double edge step pulses
     - Disable interpolation to 256 microsteps
     - Set 1/16 microstepping
     - SYNC for chopSync function: 6: see page 53 of datasheet
     - High velocity chopper mode (which switch from spreadCycle to fast decay at high speeds > VHIGH)
     - Switch to fullstep at high velocities
     - Sense resistor voltage based current scaling: Low sensitivity, high sense resistor voltage
     - Set comparator blank time to 24 clocks
     - Chopper mode: spreadCycle
     - Random toff time is disabled
     - (Only applies in fast decay mode): Does not disable current comparator usage for termination of fast decay cycle
     - (Only applies in fast decay mode): most significant byte of fast decay setting TFD is zero
     - Hysteresis is 0 for the hysteresis chopper (stock Marlin sets this to -2. TRAMS-Firmware sets it to 0)
     - Hysteresis start value is 4. Stock Marlin sets this to 1. TRAMS-Firmware sets it to 4.
     - toff time is 5. Stock Marlin uses 8. TRAMS-Firmware uses 5.

     |31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0
       0  0  0  0  0  1  0  0  0  1  1  0  1  1  0  0  1  0  0  0  0  0  0  1  1  1  0  1  0  1  0  1

       in binary: 0b00000100011011001000000111010101
       in hex: 0x46C81D5

     Reference: What Trinamic used in their TRAMS-Firmware
       0  0  0  1  0  1  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  1  1  1  0  1  0  1  0  1
  */

  // ================ COOLCONF ============================
  // See datasheet COOLCONF table, page 36 of tmc2130 datasheet
  // SGT, SEMIN, SEMAX is set above, see COOLSTEP THRESHOLDS
  st.sfilt(1);
  st.sedn(0x1);
  st.seup(0x3);
  // * filtering for stallGuard2 data, not high time resolution
  // * Require +11 torque to indicate stallGuard2 stall
  // * Minimum current: 1/2 of irun
  // * For each 8 stallGuard2 value decrease current step speed by one
  // * Medium stallGuard2 hysteresis value for smart current control
  // * Maximum current increment step width
  // * Medium stallGuard2 value threshold for smartCurrent control, and smart current control is enabled
  //                  |25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10| 9| 8| 7| 6| 5| 4| 3| 2| 1| 0
  // the_COOLCONF = 0b  0  1  0  0  0  0  1  0  1  1  0  0  1  0  0  0  1  1  0  1  1  0  0  0  0  1
  // in bin: 0b01000010110010001101100001
  // in hex: 0x10B2361
  //

  // ================ PWMCONF ============================
  // See page 39 and onwards in datasheet for these settings
  // stealthChop enabled in GCONF
  st.stealth_amplitude(255);
  st.stealth_gradient(10); // Allow big PWM change. (15 is max but not recommended)
  st.stealth_autoscale(1);
  st.stealth_freq(0);

  st.power_down_delay(255);
  st.interpolate(INTERPOLATE);
  st.setCurrent(maxcurrent, 0.11, HOLD_MULTIPLIER); // Sense resistor is 0.11 ohm
}
#endif // defined(HAVE_TMC2130)

void st_init()
{
  digipot_init(); //Initialize Digipot Motor Current
  microstep_init(); //Initialize Microstepping Pins

#if defined(HAVE_TMC2130)
  delay(500);  // Let power stabilize before configuring the steppers
  tmc2130_init(stepperA, ABCDE_MICROSTEPS, ABCDE_MAXCURRENT);
  tmc2130_init(stepperB, ABCDE_MICROSTEPS, ABCDE_MAXCURRENT);
  tmc2130_init(stepperC, ABCDE_MICROSTEPS, ABCDE_MAXCURRENT);
  tmc2130_init(stepperD, ABCDE_MICROSTEPS, ABCDE_MAXCURRENT);
  tmc2130_init(stepperE, ABCDE_MICROSTEPS, ABCDE_MAXCURRENT);
#endif // defined(HAVE_TMC2130)

  //Initialize Dir Pins
#if defined(X_DIR_PIN) && X_DIR_PIN > -1
  SET_OUTPUT(X_DIR_PIN);
#endif
#if defined(X2_DIR_PIN) && X2_DIR_PIN > -1
  SET_OUTPUT(X2_DIR_PIN);
#endif
#if defined(Y_DIR_PIN) && Y_DIR_PIN > -1
  SET_OUTPUT(Y_DIR_PIN);

#if defined(Y_DUAL_STEPPER_DRIVERS) && defined(Y2_DIR_PIN) && (Y2_DIR_PIN > -1)
  SET_OUTPUT(Y2_DIR_PIN);
#endif
#endif
#if defined(Z_DIR_PIN) && Z_DIR_PIN > -1
  SET_OUTPUT(Z_DIR_PIN);

#if defined(Z_DUAL_STEPPER_DRIVERS) && defined(Z2_DIR_PIN) && (Z2_DIR_PIN > -1)
  SET_OUTPUT(Z2_DIR_PIN);
#endif
#endif
#if defined(E0_DIR_PIN) && E0_DIR_PIN > -1
  SET_OUTPUT(E0_DIR_PIN);
#endif
#if defined(E1_DIR_PIN) && (E1_DIR_PIN > -1)
  SET_OUTPUT(E1_DIR_PIN);
#endif
#if defined(E2_DIR_PIN) && (E2_DIR_PIN > -1)
  SET_OUTPUT(E2_DIR_PIN);
#endif
#if defined(E3_DIR_PIN) && (E3_DIR_PIN > -1)
  SET_OUTPUT(E3_DIR_PIN);
#endif

  //Initialize Enable Pins - steppers default to disabled.

#if defined(X_ENABLE_PIN) && X_ENABLE_PIN > -1
  SET_OUTPUT(X_ENABLE_PIN);
  if(!X_ENABLE_ON) WRITE(X_ENABLE_PIN,HIGH);
#endif
#if defined(X2_ENABLE_PIN) && X2_ENABLE_PIN > -1
  SET_OUTPUT(X2_ENABLE_PIN);
  if(!X_ENABLE_ON) WRITE(X2_ENABLE_PIN,HIGH);
#endif
#if defined(Y_ENABLE_PIN) && Y_ENABLE_PIN > -1
  SET_OUTPUT(Y_ENABLE_PIN);
  if(!Y_ENABLE_ON) WRITE(Y_ENABLE_PIN,HIGH);

#if defined(Y_DUAL_STEPPER_DRIVERS) && defined(Y2_ENABLE_PIN) && (Y2_ENABLE_PIN > -1)
  SET_OUTPUT(Y2_ENABLE_PIN);
  if(!Y_ENABLE_ON) WRITE(Y2_ENABLE_PIN,HIGH);
#endif
#endif
#if defined(Z_ENABLE_PIN) && Z_ENABLE_PIN > -1
  SET_OUTPUT(Z_ENABLE_PIN);
  if(!Z_ENABLE_ON) WRITE(Z_ENABLE_PIN,HIGH);

#if defined(Z_DUAL_STEPPER_DRIVERS) && defined(Z2_ENABLE_PIN) && (Z2_ENABLE_PIN > -1)
  SET_OUTPUT(Z2_ENABLE_PIN);
  if(!Z_ENABLE_ON) WRITE(Z2_ENABLE_PIN,HIGH);
#endif
#endif
#if defined(E0_ENABLE_PIN) && (E0_ENABLE_PIN > -1)
  SET_OUTPUT(E0_ENABLE_PIN);
  if(!E_ENABLE_ON) WRITE(E0_ENABLE_PIN,HIGH);
#endif
#if defined(E1_ENABLE_PIN) && (E1_ENABLE_PIN > -1)
  SET_OUTPUT(E1_ENABLE_PIN);
  if(!E_ENABLE_ON) WRITE(E1_ENABLE_PIN,HIGH);
#endif
#if defined(E2_ENABLE_PIN) && (E2_ENABLE_PIN > -1)
  SET_OUTPUT(E2_ENABLE_PIN);
  if(!E_ENABLE_ON) WRITE(E2_ENABLE_PIN,HIGH);
#endif
#if defined(E3_ENABLE_PIN) && (E3_ENABLE_PIN > -1)
  SET_OUTPUT(E3_ENABLE_PIN);
  if(!E_ENABLE_ON) WRITE(E3_ENABLE_PIN,HIGH);
#endif

  //endstops and pullups

#if defined(X_MIN_PIN) && X_MIN_PIN > -1
  SET_INPUT(X_MIN_PIN);
#ifdef ENDSTOPPULLUP_XMIN
  WRITE(X_MIN_PIN,HIGH);
#endif
#endif

#if defined(Y_MIN_PIN) && Y_MIN_PIN > -1
  SET_INPUT(Y_MIN_PIN);
#ifdef ENDSTOPPULLUP_YMIN
  WRITE(Y_MIN_PIN,HIGH);
#endif
#endif

#if defined(Z_MIN_PIN) && Z_MIN_PIN > -1
  SET_INPUT(Z_MIN_PIN);
#ifdef ENDSTOPPULLUP_ZMIN
  WRITE(Z_MIN_PIN,HIGH);
#endif
#endif

#if defined(X_MAX_PIN) && X_MAX_PIN > -1
  SET_INPUT(X_MAX_PIN);
#ifdef ENDSTOPPULLUP_XMAX
  WRITE(X_MAX_PIN,HIGH);
#endif
#endif

#if defined(Y_MAX_PIN) && Y_MAX_PIN > -1
  SET_INPUT(Y_MAX_PIN);
#ifdef ENDSTOPPULLUP_YMAX
  WRITE(Y_MAX_PIN,HIGH);
#endif
#endif

#if defined(Z_MAX_PIN) && Z_MAX_PIN > -1
  SET_INPUT(Z_MAX_PIN);
#ifdef ENDSTOPPULLUP_ZMAX
  WRITE(Z_MAX_PIN,HIGH);
#endif
#endif


  //Initialize Step Pins
#if defined(X_STEP_PIN) && (X_STEP_PIN > -1)
  SET_OUTPUT(X_STEP_PIN);
  WRITE(X_STEP_PIN,INVERT_X_STEP_PIN);
  disable_x();
#endif
#if defined(X2_STEP_PIN) && (X2_STEP_PIN > -1)
  SET_OUTPUT(X2_STEP_PIN);
  WRITE(X2_STEP_PIN,INVERT_X_STEP_PIN);
  disable_x();
#endif
#if defined(Y_STEP_PIN) && (Y_STEP_PIN > -1)
  SET_OUTPUT(Y_STEP_PIN);
  WRITE(Y_STEP_PIN,INVERT_Y_STEP_PIN);
#if defined(Y_DUAL_STEPPER_DRIVERS) && defined(Y2_STEP_PIN) && (Y2_STEP_PIN > -1)
  SET_OUTPUT(Y2_STEP_PIN);
  WRITE(Y2_STEP_PIN,INVERT_Y_STEP_PIN);
#endif
  disable_y();
#endif
#if defined(Z_STEP_PIN) && (Z_STEP_PIN > -1)
  SET_OUTPUT(Z_STEP_PIN);
  WRITE(Z_STEP_PIN,INVERT_Z_STEP_PIN);
#if defined(Z_DUAL_STEPPER_DRIVERS) && defined(Z2_STEP_PIN) && (Z2_STEP_PIN > -1)
  SET_OUTPUT(Z2_STEP_PIN);
  WRITE(Z2_STEP_PIN,INVERT_Z_STEP_PIN);
#endif
  disable_z();
#endif
#if defined(E0_STEP_PIN) && (E0_STEP_PIN > -1)
  SET_OUTPUT(E0_STEP_PIN);
  WRITE(E0_STEP_PIN,INVERT_E_STEP_PIN);
  disable_e0();
#endif
#if defined(E1_STEP_PIN) && (E1_STEP_PIN > -1)
  SET_OUTPUT(E1_STEP_PIN);
  WRITE(E1_STEP_PIN,INVERT_E_STEP_PIN);
  disable_e1();
#endif
#if defined(E2_STEP_PIN) && (E2_STEP_PIN > -1)
  SET_OUTPUT(E2_STEP_PIN);
  WRITE(E2_STEP_PIN,INVERT_E_STEP_PIN);
  disable_e2();
#endif
#if defined(E3_STEP_PIN) && (E3_STEP_PIN > -1)
  SET_OUTPUT(E3_STEP_PIN);
  WRITE(E3_STEP_PIN,INVERT_E_STEP_PIN);
  disable_e3();
#endif

  // waveform generation = 0100 = CTC
  TCCR1B &= ~(1<<WGM13);
  TCCR1B |=  (1<<WGM12);
  TCCR1A &= ~(1<<WGM11);
  TCCR1A &= ~(1<<WGM10);

  // output mode = 00 (disconnected)
  TCCR1A &= ~(3<<COM1A0);
  TCCR1A &= ~(3<<COM1B0);

  // Set the timer pre-scaler
  // Generally we use a divider of 8, resulting in a 2MHz timer
  // frequency on a 16MHz MCU. If you are going to change this, be
  // sure to regenerate speed_lookuptable.h with
  // create_speed_lookuptable.py
  TCCR1B = (TCCR1B & ~(0x07<<CS10)) | (2<<CS10);

  OCR1A = 0x4000;
  TCNT1 = 0;
  ENABLE_STEPPER_DRIVER_INTERRUPT();

  enable_endstops(true); // Start with endstops active. After homing they can be disabled
  sei();
}


// Block until all buffered steps are executed
void st_synchronize()
{
  while( blocks_queued()) {
    manage_heater();
    manage_inactivity();
  }
}

void st_set_position(const long &a, const long &b, const long &c, const long &d, const long &e)
{
  CRITICAL_SECTION_START;
  count_position[A_AXIS] = a;
  count_position[B_AXIS] = b;
  count_position[C_AXIS] = c;
  count_position[D_AXIS] = d;
  count_position[E_AXIS] = e;
  CRITICAL_SECTION_END;
}

void st_set_e_position(const long &e)
{
  CRITICAL_SECTION_START;
  count_position[E_AXIS] = e;
  CRITICAL_SECTION_END;
}

long st_get_position(uint8_t axis)
{
  long count_pos;
  CRITICAL_SECTION_START;
  count_pos = count_position[axis];
  CRITICAL_SECTION_END;
  return count_pos;
}

void quickStop()
{
  DISABLE_STEPPER_DRIVER_INTERRUPT();
  while(blocks_queued())
    plan_discard_current_block();
  current_block = NULL;
  ENABLE_STEPPER_DRIVER_INTERRUPT();
}

void digitalPotWrite(int address, int value) // From Arduino DigitalPotControl example
{
#if defined(DIGIPOTSS_PIN) && DIGIPOTSS_PIN > -1
  digitalWrite(DIGIPOTSS_PIN,LOW); // take the SS pin low to select the chip
  SPI.transfer(address); //  send in the address and value via SPI:
  SPI.transfer(value);
  digitalWrite(DIGIPOTSS_PIN,HIGH); // take the SS pin high to de-select the chip:
  //delay(10);
#endif
}

void digipot_init() //Initialize Digipot Motor Current
{
#if defined(DIGIPOTSS_PIN) && DIGIPOTSS_PIN > -1
  const uint8_t digipot_motor_current[] = DIGIPOT_MOTOR_CURRENT;

  SPI.begin();
  pinMode(DIGIPOTSS_PIN, OUTPUT);
  for(int i=0;i<=4;i++)
    //digitalPotWrite(digipot_ch[i], digipot_motor_current[i]);
    digipot_current(i,digipot_motor_current[i]);
#endif
#ifdef MOTOR_CURRENT_PWM_XY_PIN
  pinMode(MOTOR_CURRENT_PWM_XY_PIN, OUTPUT);
  pinMode(MOTOR_CURRENT_PWM_Z_PIN, OUTPUT);
  pinMode(MOTOR_CURRENT_PWM_E_PIN, OUTPUT);
  digipot_current(0, motor_current_setting[0]);
  digipot_current(1, motor_current_setting[1]);
  digipot_current(2, motor_current_setting[2]);
  //Set timer5 to 31khz so the PWM of the motor power is as constant as possible. (removes a buzzing noise)
  TCCR5B = (TCCR5B & ~(_BV(CS50) | _BV(CS51) | _BV(CS52))) | _BV(CS50);
#endif
}

void digipot_current(uint8_t driver, int current)
{
#if defined(DIGIPOTSS_PIN) && DIGIPOTSS_PIN > -1
  const uint8_t digipot_ch[] = DIGIPOT_CHANNELS;
  digitalPotWrite(digipot_ch[driver], current);
#endif
#ifdef MOTOR_CURRENT_PWM_XY_PIN
  if (driver == 0) analogWrite(MOTOR_CURRENT_PWM_XY_PIN, (long)current * 255L / (long)MOTOR_CURRENT_PWM_RANGE);
  if (driver == 1) analogWrite(MOTOR_CURRENT_PWM_Z_PIN, (long)current * 255L / (long)MOTOR_CURRENT_PWM_RANGE);
  if (driver == 2) analogWrite(MOTOR_CURRENT_PWM_E_PIN, (long)current * 255L / (long)MOTOR_CURRENT_PWM_RANGE);
#endif
}

void microstep_init()
{
  const uint8_t microstep_modes[] = MICROSTEP_MODES;

#if defined(E1_MS1_PIN) && E1_MS1_PIN > -1
  pinMode(E1_MS1_PIN,OUTPUT);
  pinMode(E1_MS2_PIN,OUTPUT);
#endif

#if defined(X_MS1_PIN) && X_MS1_PIN > -1
  pinMode(X_MS1_PIN,OUTPUT);
  pinMode(X_MS2_PIN,OUTPUT);
  pinMode(Y_MS1_PIN,OUTPUT);
  pinMode(Y_MS2_PIN,OUTPUT);
  pinMode(Z_MS1_PIN,OUTPUT);
  pinMode(Z_MS2_PIN,OUTPUT);
  pinMode(E0_MS1_PIN,OUTPUT);
  pinMode(E0_MS2_PIN,OUTPUT);
  for(int i=0;i<=4;i++) microstep_mode(i,microstep_modes[i]);
#endif
}

void microstep_ms(uint8_t driver, int8_t ms1, int8_t ms2)
{
  if(ms1 > -1) switch(driver)
  {
    case 0: digitalWrite( X_MS1_PIN,ms1); break;
    case 1: digitalWrite( Y_MS1_PIN,ms1); break;
    case 2: digitalWrite( Z_MS1_PIN,ms1); break;
    case 3: digitalWrite(E1_MS1_PIN,ms1); break;
#if defined(E1_MS1_PIN) && E1_MS1_PIN > -1
    case 4: digitalWrite(E0_MS1_PIN,ms1); break;
#endif
  }
  if(ms2 > -1) switch(driver)
  {
    case 0: digitalWrite( X_MS2_PIN,ms2); break;
    case 1: digitalWrite( Y_MS2_PIN,ms2); break;
    case 2: digitalWrite( Z_MS2_PIN,ms2); break;
    case 3: digitalWrite(E1_MS2_PIN,ms2); break;
#if defined(E1_MS2_PIN) && E1_MS2_PIN > -1
    case 4: digitalWrite(E0_MS2_PIN,ms2); break;
#endif
  }
}

void microstep_mode(uint8_t driver, uint8_t stepping_mode)
{
  switch(stepping_mode)
  {
    case 1: microstep_ms(driver,MICROSTEP1); break;
    case 2: microstep_ms(driver,MICROSTEP2); break;
    case 4: microstep_ms(driver,MICROSTEP4); break;
    case 8: microstep_ms(driver,MICROSTEP8); break;
    case 16: microstep_ms(driver,MICROSTEP16); break;
  }
}

void microstep_readings()
{
  SERIAL_PROTOCOLPGM("MS1,MS2 Pins\n");
  SERIAL_PROTOCOLPGM("X: ");
  SERIAL_PROTOCOL(   digitalRead(X_MS1_PIN));
  SERIAL_PROTOCOLLN( digitalRead(X_MS2_PIN));
  SERIAL_PROTOCOLPGM("Y: ");
  SERIAL_PROTOCOL(   digitalRead(Y_MS1_PIN));
  SERIAL_PROTOCOLLN( digitalRead(Y_MS2_PIN));
  SERIAL_PROTOCOLPGM("Z: ");
  SERIAL_PROTOCOL(   digitalRead(Z_MS1_PIN));
  SERIAL_PROTOCOLLN( digitalRead(Z_MS2_PIN));
  SERIAL_PROTOCOLPGM("E0: ");
  SERIAL_PROTOCOL(   digitalRead(E0_MS1_PIN));
  SERIAL_PROTOCOLLN( digitalRead(E0_MS2_PIN));
#if defined(E1_MS1_PIN) && E1_MS1_PIN > -1
  SERIAL_PROTOCOLPGM("E1: ");
  SERIAL_PROTOCOL(   digitalRead(E1_MS1_PIN));
  SERIAL_PROTOCOLLN( digitalRead(E1_MS2_PIN));
#endif
}

