/*
   planner.c - buffers movement commands and manages the acceleration profile plan
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

/* The ring buffer implementation gleaned from the wiring_serial library by David A. Mellis. */

/*
    Reasoning behind the mathematics in this module (in the key of 'Mathematica'):

    s == speed, a == acceleration, t == time, d == distance

    Basic definitions:

    Speed[s_, a_, t_] := s + (a*t)
    Travel[s_, a_, t_] := Integrate[Speed[s, a, t], t]

    Distance to reach a specific speed with a constant acceleration:

    Solve[{Speed[s, a, t] == m, Travel[s, a, t] == d}, d, t]
    d -> (m^2 - s^2)/(2 a) --> estimate_acceleration_distance()

    Speed after a given distance of travel with constant acceleration:

    Solve[{Speed[s, a, t] == m, Travel[s, a, t] == d}, m, t]
    m -> Sqrt[2 a d + s^2]

    DestinationSpeed[s_, a_, d_] := Sqrt[2 a d + s^2]

    When to start braking (di) to reach a specified destionation speed (s2) after accelerating
    from initial speed s1 without ever stopping at a plateau:

    Solve[{DestinationSpeed[s1, a, di] == DestinationSpeed[s2, a, d - di]}, di]
    di -> (2 a d - s1^2 + s2^2)/(4 a) --> intersection_distance()

    IntersectionDistance[s1_, s2_, a_, d_] := (2 a d - s1^2 + s2^2)/(4 a)
    */

#include "Marlin.h"
#include "planner.h"
#include "stepper.h"
#include "temperature.h"
#include "language.h"

//===========================================================================
//=============================public variables ============================
//===========================================================================

unsigned long minsegmenttime;
float max_feedrate[NUM_AXIS]; // set the max speeds


#ifdef EXPERIMENTAL_LINE_BUILDUP_COMPENSATION_FEATURE
float spool_buildup_factor = DEFAULT_SPOOL_BUILDUP_FACTOR;

// steps per mm calculations
const float steps_per_unit_times_r[DIRS] = {(float)MECHANICAL_ADVANTAGE_A*STEPS_PER_SPOOL_RADIAN[A_AXIS],
                                            (float)MECHANICAL_ADVANTAGE_B*STEPS_PER_SPOOL_RADIAN[B_AXIS],
                                            (float)MECHANICAL_ADVANTAGE_C*STEPS_PER_SPOOL_RADIAN[C_AXIS],
                                            (float)MECHANICAL_ADVANTAGE_D*STEPS_PER_SPOOL_RADIAN[D_AXIS]};

const float k2[DIRS] = {-(float)nr_of_lines_in_direction[A_AXIS]*spool_buildup_factor,
                        -(float)nr_of_lines_in_direction[B_AXIS]*spool_buildup_factor,
                        -(float)nr_of_lines_in_direction[C_AXIS]*spool_buildup_factor,
                        -(float)nr_of_lines_in_direction[D_AXIS]*spool_buildup_factor};

const float k0[DIRS] = {2*steps_per_unit_times_r[A_AXIS]/k2[A_AXIS],
                        2*steps_per_unit_times_r[B_AXIS]/k2[B_AXIS],
                        2*steps_per_unit_times_r[C_AXIS]/k2[C_AXIS],
                        2*steps_per_unit_times_r[D_AXIS]/k2[D_AXIS]};

const float spool_radii2[DIRS] = { SPOOL_RADII[A_AXIS]*SPOOL_RADII[A_AXIS],
                                   SPOOL_RADII[B_AXIS]*SPOOL_RADII[B_AXIS],
                                   SPOOL_RADII[C_AXIS]*SPOOL_RADII[C_AXIS],
                                   SPOOL_RADII[D_AXIS]*SPOOL_RADII[D_AXIS] };

// NOTE: This calculation assumes that ABC spools are mounted close to the D-anchor!
//       It also assumes that doubled lines for mechanical advantage is between mover and anchor, not between anchor and anchor.
const float line_on_spool_origo[DIRS] = { (float)ACTION_POINTS_A*MOUNTED_LINE[A_AXIS]
                                          // Line between D anchor and A anchor.
                                          // This is inexact by probably a few centimeters, depending on where lineroller_A_winch is mounted in ceiling
                                         -(float)ACTION_POINTS_A*sqrt((anchor_D_z - anchor_A_z)*(anchor_D_z - anchor_A_z) + anchor_A_x*anchor_A_x + anchor_A_y*anchor_A_y)
                                          // Line between anchor a and mover
                                         -(float)nr_of_lines_in_direction[A_AXIS]*sqrt(anchor_A_x*anchor_A_x + anchor_A_y*anchor_A_y + anchor_A_z*anchor_A_z),

                                          (float)ACTION_POINTS_B*MOUNTED_LINE[B_AXIS]
                                         -(float)ACTION_POINTS_B*sqrt((anchor_D_z - anchor_B_z)*(anchor_D_z - anchor_B_z) + anchor_B_x*anchor_B_x + anchor_B_y*anchor_B_y)
                                         -(float)nr_of_lines_in_direction[B_AXIS]*sqrt(anchor_B_x*anchor_B_x + anchor_B_y*anchor_B_y + anchor_B_z*anchor_B_z),

                                          (float)ACTION_POINTS_C*MOUNTED_LINE[C_AXIS]
                                         -(float)ACTION_POINTS_C*sqrt((anchor_D_z - anchor_C_z)*(anchor_D_z - anchor_C_z) + anchor_C_x*anchor_C_x + anchor_C_y*anchor_C_y)
                                         -(float)nr_of_lines_in_direction[C_AXIS]*sqrt(anchor_C_x*anchor_C_x + anchor_C_y*anchor_C_y + anchor_C_z*anchor_C_z),

                                          (float)nr_of_lines_in_direction[D_AXIS]*(MOUNTED_LINE[D_AXIS] - anchor_D_z)
                                        };

const float k1[DIRS] = {spool_buildup_factor*(line_on_spool_origo[A_AXIS] + (float)nr_of_lines_in_direction[A_AXIS]*INITIAL_DISTANCES[A_AXIS]) + spool_radii2[A_AXIS],
                        spool_buildup_factor*(line_on_spool_origo[B_AXIS] + (float)nr_of_lines_in_direction[B_AXIS]*INITIAL_DISTANCES[B_AXIS]) + spool_radii2[B_AXIS],
                        spool_buildup_factor*(line_on_spool_origo[C_AXIS] + (float)nr_of_lines_in_direction[C_AXIS]*INITIAL_DISTANCES[C_AXIS]) + spool_radii2[C_AXIS],
                        spool_buildup_factor*(line_on_spool_origo[D_AXIS] + (float)nr_of_lines_in_direction[D_AXIS]*INITIAL_DISTANCES[D_AXIS]) + spool_radii2[D_AXIS]};

const float sqrtk1[DIRS] = {sqrt(k1[A_AXIS]),
                            sqrt(k1[B_AXIS]),
                            sqrt(k1[C_AXIS]),
                            sqrt(k1[D_AXIS])};

#endif // EXPERIMENTAL_LINE_BUILDUP_COMPENSATION_FEATURE

unsigned long max_acceleration_units_per_sq_second[NUM_AXIS]; // Use M201 to override by software
float minimumfeedrate;
float acceleration;         // Normal acceleration mm/s^2  THIS IS THE DEFAULT ACCELERATION for all moves. M204 SXXXX
float retract_acceleration; //  mm/s^2   filament pull-pack and push-forward  while standing still in the other axis M204 TXXXX
float max_xy_jerk; //speed than can be stopped at once, if i understand correctly.
float max_z_jerk;
float max_e_jerk;
float mintravelfeedrate;
unsigned long axis_steps_per_sqr_second[NUM_AXIS];

float axis_steps_per_unit[NUM_AXIS] = DEFAULT_AXIS_STEPS_PER_UNIT;

#ifdef EXPERIMENTAL_LINE_BUILDUP_COMPENSATION_FEATURE
long position[NUM_AXIS] = {lround(k0[A_AXIS]*(sqrt(k1[A_AXIS] + k2[A_AXIS]*INITIAL_DISTANCES[A_AXIS]) - sqrtk1[A_AXIS])),
                           lround(k0[B_AXIS]*(sqrt(k1[B_AXIS] + k2[B_AXIS]*INITIAL_DISTANCES[B_AXIS]) - sqrtk1[B_AXIS])),
                           lround(k0[C_AXIS]*(sqrt(k1[C_AXIS] + k2[C_AXIS]*INITIAL_DISTANCES[C_AXIS]) - sqrtk1[C_AXIS])),
                           lround(k0[D_AXIS]*(sqrt(k1[D_AXIS] + k2[D_AXIS]*INITIAL_DISTANCES[D_AXIS]) - sqrtk1[D_AXIS])), 0};
// The current position of the tool in absolute steps
#else
long position[NUM_AXIS] = {INITIAL_DISTANCES[A_AXIS]*axis_steps_per_unit[A_AXIS],
                           INITIAL_DISTANCES[B_AXIS]*axis_steps_per_unit[B_AXIS],
                           INITIAL_DISTANCES[C_AXIS]*axis_steps_per_unit[C_AXIS],
                           INITIAL_DISTANCES[D_AXIS]*axis_steps_per_unit[D_AXIS], 0};
#endif // EXPERIMENTAL_LINE_BUILDUP_COMPENSATION_FEATURE

static float previous_speed[NUM_AXIS]; // Speed of previous path line segment
static float previous_nominal_speed; // Nominal speed of previous path line segment

#ifdef AUTOTEMP
float autotemp_max=250;
float autotemp_min=210;
float autotemp_factor=0.1;
bool autotemp_enabled=false;
#endif

unsigned char g_uc_extruder_last_move[4] = {0,0,0,0};

//===========================================================================
//=================semi-private variables, used in inline  functions    =====
//===========================================================================
block_t block_buffer[BLOCK_BUFFER_SIZE];            // A ring buffer for motion instfructions
volatile unsigned char block_buffer_head;           // Index of the next block to be pushed
volatile unsigned char block_buffer_tail;           // Index of the block to process now

//===========================================================================
//=============================private variables ============================
//===========================================================================
#ifdef PREVENT_DANGEROUS_EXTRUDE
float extrude_min_temp=EXTRUDE_MINTEMP;
#endif
#ifdef XY_FREQUENCY_LIMIT
#define MAX_FREQ_TIME (1000000.0/XY_FREQUENCY_LIMIT)
// Used for the frequency limit
static unsigned char old_direction_bits = 0;               // Old direction bits. Used for speed calculations
static long x_segment_time[3]={MAX_FREQ_TIME + 1,0,0};     // Segment times (in us). Used for speed calculations
static long y_segment_time[3]={MAX_FREQ_TIME + 1,0,0};
#endif

// Returns the index of the next block in the ring buffer
// NOTE: Removed modulo (%) operator, which uses an expensive divide and multiplication.
static int8_t next_block_index(int8_t block_index) {
  block_index++;
  if (block_index == BLOCK_BUFFER_SIZE) {
    block_index = 0;
  }
  return(block_index);
}


// Returns the index of the previous block in the ring buffer
static int8_t prev_block_index(int8_t block_index) {
  if (block_index == 0) {
    block_index = BLOCK_BUFFER_SIZE;
  }
  block_index--;
  return(block_index);
}

//===========================================================================
//=============================functions         ============================
//===========================================================================

// Calculates the distance (not time) it takes to accelerate from initial_rate to target_rate using the
// given acceleration:
FORCE_INLINE float estimate_acceleration_distance(float initial_rate, float target_rate, float acceleration)
{
  if (acceleration!=0) {
    return((target_rate*target_rate-initial_rate*initial_rate)/
        (2.0*acceleration));
  }
  else {
    return 0.0;  // acceleration was 0, set acceleration distance to 0
  }
}

// This function gives you the point at which you must start braking (at the rate of -acceleration) if
// you started at speed initial_rate and accelerated until this point and want to end at the final_rate after
// a total travel of distance. This can be used to compute the intersection point between acceleration and
// deceleration in the cases where the trapezoid has no plateau (i.e. never reaches maximum speed)

FORCE_INLINE float intersection_distance(float initial_rate, float final_rate, float acceleration, float distance)
{
  if (acceleration!=0) {
    return((2.0*acceleration*distance-initial_rate*initial_rate+final_rate*final_rate)/
        (4.0*acceleration) );
  }
  else {
    return 0.0;  // acceleration was 0, set intersection distance to 0
  }
}

// Calculates trapezoid parameters so that the entry- and exit-speed is compensated by the provided factors.

void calculate_trapezoid_for_block(block_t *block, float entry_factor, float exit_factor) {
  unsigned long initial_rate = ceil(block->nominal_rate*entry_factor); // (step/min)
  unsigned long final_rate = ceil(block->nominal_rate*exit_factor); // (step/min)

  // Limit minimal step rate (Otherwise the timer will overflow.)
  if(initial_rate <120) {
    initial_rate=120;
  }
  if(final_rate < 120) {
    final_rate=120;
  }

  long acceleration = block->acceleration_st;
  int32_t accelerate_steps =
    ceil(estimate_acceleration_distance(initial_rate, block->nominal_rate, acceleration));
  int32_t decelerate_steps =
    floor(estimate_acceleration_distance(block->nominal_rate, final_rate, -acceleration));

  // Calculate the size of Plateau of Nominal Rate.
  int32_t plateau_steps = block->step_event_count-accelerate_steps-decelerate_steps;

  // Is the Plateau of Nominal Rate smaller than nothing? That means no cruising, and we will
  // have to use intersection_distance() to calculate when to abort acceleration and start braking
  // in order to reach the final_rate exactly at the end of this block.
  if (plateau_steps < 0) {
    accelerate_steps = ceil(intersection_distance(initial_rate, final_rate, acceleration, block->step_event_count));
    accelerate_steps = max(accelerate_steps,0); // Check limits due to numerical round-off
    accelerate_steps = min((uint32_t)accelerate_steps,block->step_event_count);//(We can cast here to unsigned, because the above line ensures that we are above zero)
    plateau_steps = 0;
  }

  CRITICAL_SECTION_START;  // Fill variables used by the stepper in a critical section
  if(block->busy == false) { // Don't update variables if block is busy.
    block->accelerate_until = accelerate_steps;
    block->decelerate_after = accelerate_steps+plateau_steps;
    block->initial_rate = initial_rate;
    block->final_rate = final_rate;
  }
  CRITICAL_SECTION_END;
}

// Calculates the maximum allowable speed at this point when you must be able to reach target_velocity using the
// acceleration within the allotted distance.
FORCE_INLINE float max_allowable_speed(float acceleration, float target_velocity, float distance) {
  return  sqrt(target_velocity*target_velocity-2*acceleration*distance);
}

// The kernel called by planner_recalculate() when scanning the plan from last to first entry.
void planner_reverse_pass_kernel(block_t *previous, block_t *current, block_t *next) {
  if(!current) {
    return;
  }

  if (next) {
    // If entry speed is already at the maximum entry speed, no need to recheck. Block is cruising.
    // If not, block in state of acceleration or deceleration. Reset entry speed to maximum and
    // check for maximum allowable speed reductions to ensure maximum possible planned speed.
    if (current->entry_speed != current->max_entry_speed) {

      // If nominal length true, max junction speed is guaranteed to be reached. Only compute
      // for max allowable speed if block is decelerating and nominal length is false.
      if ((!current->nominal_length_flag) && (current->max_entry_speed > next->entry_speed)) {
        current->entry_speed = min( current->max_entry_speed,
            max_allowable_speed(-current->acceleration,next->entry_speed,current->millimeters));
      }
      else {
        current->entry_speed = current->max_entry_speed;
      }
      current->recalculate_flag = true;

    }
  } // Skip last block. Already initialized and set for recalculation.
}

// planner_recalculate() needs to go over the current plan twice. Once in reverse and once forward. This
// implements the reverse pass.
void planner_reverse_pass() {
  uint8_t block_index = block_buffer_head;

  //Make a local copy of block_buffer_tail, because the interrupt can alter it
  CRITICAL_SECTION_START;
  unsigned char tail = block_buffer_tail;
  CRITICAL_SECTION_END;

  if(((block_buffer_head-tail + BLOCK_BUFFER_SIZE) & (BLOCK_BUFFER_SIZE - 1)) > 3) {
    block_index = (block_buffer_head - 3) & (BLOCK_BUFFER_SIZE - 1);
    block_t *block[3] = {
      NULL, NULL, NULL         };
    while(block_index != tail) {
      block_index = prev_block_index(block_index);
      block[2]= block[1];
      block[1]= block[0];
      block[0] = &block_buffer[block_index];
      planner_reverse_pass_kernel(block[0], block[1], block[2]);
    }
  }
}

// The kernel called by planner_recalculate() when scanning the plan from first to last entry.
void planner_forward_pass_kernel(block_t *previous, block_t *current, block_t *next) {
  if(!previous) {
    return;
  }

  // If the previous block is an acceleration block, but it is not long enough to complete the
  // full speed change within the block, we need to adjust the entry speed accordingly. Entry
  // speeds have already been reset, maximized, and reverse planned by reverse planner.
  // If nominal length is true, max junction speed is guaranteed to be reached. No need to recheck.
  if (!previous->nominal_length_flag) {
    if (previous->entry_speed < current->entry_speed) {
      double entry_speed = min( current->entry_speed,
          max_allowable_speed(-previous->acceleration,previous->entry_speed,previous->millimeters) );

      // Check for junction speed change
      if (current->entry_speed != entry_speed) {
        current->entry_speed = entry_speed;
        current->recalculate_flag = true;
      }
    }
  }
}

// planner_recalculate() needs to go over the current plan twice. Once in reverse and once forward. This
// implements the forward pass.
void planner_forward_pass() {
  uint8_t block_index = block_buffer_tail;
  block_t *block[3] = {
    NULL, NULL, NULL   };

  while(block_index != block_buffer_head) {
    block[0] = block[1];
    block[1] = block[2];
    block[2] = &block_buffer[block_index];
    planner_forward_pass_kernel(block[0],block[1],block[2]);
    block_index = next_block_index(block_index);
  }
  planner_forward_pass_kernel(block[1], block[2], NULL);
}

// Recalculates the trapezoid speed profiles for all blocks in the plan according to the
// entry_factor for each junction. Must be called by planner_recalculate() after
// updating the blocks.
void planner_recalculate_trapezoids() {
  int8_t block_index = block_buffer_tail;
  block_t *current;
  block_t *next = NULL;

  while(block_index != block_buffer_head) {
    current = next;
    next = &block_buffer[block_index];
    if (current) {
      // Recalculate if current block entry or exit junction speed has changed.
      if (current->recalculate_flag || next->recalculate_flag) {
        // NOTE: Entry and exit factors always > 0 by all previous logic operations.
        calculate_trapezoid_for_block(current, current->entry_speed/current->nominal_speed,
            next->entry_speed/current->nominal_speed);
        current->recalculate_flag = false; // Reset current only to ensure next trapezoid is computed
      }
    }
    block_index = next_block_index( block_index );
  }
  // Last/newest block in buffer. Exit speed is set with MINIMUM_PLANNER_SPEED. Always recalculated.
  if(next != NULL) {
    calculate_trapezoid_for_block(next, next->entry_speed/next->nominal_speed,
        MINIMUM_PLANNER_SPEED/next->nominal_speed);
    next->recalculate_flag = false;
  }
}

// Recalculates the motion plan according to the following algorithm:
//
//   1. Go over every block in reverse order and calculate a junction speed reduction (i.e. block_t.entry_factor)
//      so that:
//     a. The junction jerk is within the set limit
//     b. No speed reduction within one block requires faster deceleration than the one, true constant
//        acceleration.
//   2. Go over every block in chronological order and dial down junction speed reduction values if
//     a. The speed increase within one block would require faster accelleration than the one, true
//        constant acceleration.
//
// When these stages are complete all blocks have an entry_factor that will allow all speed changes to
// be performed using only the one, true constant acceleration, and where no junction jerk is jerkier than
// the set limit. Finally it will:
//
//   3. Recalculate trapezoids for all blocks.

void planner_recalculate() {
  planner_reverse_pass();
  planner_forward_pass();
  planner_recalculate_trapezoids();
}

void plan_init() {
  block_buffer_head = 0;
  block_buffer_tail = 0;
  memset(position, 0, sizeof(position)); // clear position
// Assume printer is started in origo
// Why is this done again? Seems it does same as line 98...
// Not sure how to treat this with dynamic steps/mm. May it be initialized to zero? (done above)
#ifdef EXPERIMENTAL_LINE_BUILDUP_COMPENSATION_FEATURE
  // axis_steps_per_unit is used for acceleration planning
  calculate_axis_steps_per_unit(INITIAL_DISTANCES);
  for(int i=0; i<DIRS; i++){
    position[i] = lround(k0[i]*(sqrt(k1[i] + k2[i]*INITIAL_DISTANCES[i]) - sqrtk1[i]));
  }
#else
  for(int i=0; i<DIRS; i++){
    position[i] = INITIAL_DISTANCES[i]*axis_steps_per_unit[i];
  }
#endif

  previous_speed[A_AXIS] = 0.0;
  previous_speed[B_AXIS] = 0.0;
  previous_speed[C_AXIS] = 0.0;
  previous_speed[D_AXIS] = 0.0;
  previous_speed[E_AXIS] = 0.0;
  previous_nominal_speed = 0.0;
}

#ifdef AUTOTEMP
void getHighESpeed()
{
  static float oldt=0;
  if(!autotemp_enabled){
    return;
  }
  if(degTargetHotend0()+2<autotemp_min) {  //probably temperature set to zero.
    return; //do nothing
  }

  float high=0.0;
  uint8_t block_index = block_buffer_tail;

  while(block_index != block_buffer_head) {
    if((block_buffer[block_index].steps_a != 0) ||
        (block_buffer[block_index].steps_b != 0) ||
        (block_buffer[block_index].steps_c != 0) ||
        (block_buffer[block_index].steps_d != 0)) {
      float se=(float(block_buffer[block_index].steps_e)/float(block_buffer[block_index].step_event_count))*block_buffer[block_index].nominal_speed;
      //se; mm/sec;
      if(se>high)
      {
        high=se;
      }
    }
    block_index = (block_index+1) & (BLOCK_BUFFER_SIZE - 1);
  }

  float g=autotemp_min+high*autotemp_factor;
  float t=g;
  if(t<autotemp_min)
    t=autotemp_min;
  if(t>autotemp_max)
    t=autotemp_max;
  if(oldt>t)
  {
    t=AUTOTEMP_OLDWEIGHT*oldt+(1-AUTOTEMP_OLDWEIGHT)*t;
  }
  oldt=t;
#ifdef EXTRUDERS
  setTargetHotend0(t);
#endif
}
#endif

// Check of a, b, c and d axis activity not relevant for the hangprinter...
void check_axes_activity()
{
  unsigned char e_active = 0;
  unsigned char tail_fan_speed = fanSpeed;
  block_t *block;

  if(block_buffer_tail != block_buffer_head)
  {
    uint8_t block_index = block_buffer_tail;
    tail_fan_speed = block_buffer[block_index].fan_speed;
    while(block_index != block_buffer_head)
    {
      block = &block_buffer[block_index];
      if(block->steps_e != 0) e_active++;
      block_index = (block_index+1) & (BLOCK_BUFFER_SIZE - 1);
    }
  }
  if((DISABLE_E) && (e_active == 0))
  {
    disable_e0();
  }
#if defined(FAN_PIN) && FAN_PIN > -1
#ifdef FAN_KICKSTART_TIME
  static unsigned long fan_kick_end;
  if (tail_fan_speed) {
    if (fan_kick_end == 0) {
      // Just starting up fan - run at full power.
      fan_kick_end = millis() + FAN_KICKSTART_TIME;
      tail_fan_speed = 255;
    } else if (fan_kick_end > millis())
      // Fan still spinning up.
      tail_fan_speed = 255;
  } else {
    fan_kick_end = 0;
  }
#endif//FAN_KICKSTART_TIME
#ifdef FAN_SOFT_PWM
  fanSpeedSoftPwm = tail_fan_speed;
#else
  analogWrite(FAN_PIN,tail_fan_speed);
#endif//!FAN_SOFT_PWM
#endif//FAN_PIN > -1
#ifdef AUTOTEMP
  getHighESpeed();
#endif
}

float junction_deviation = 0.1;
// Add a new linear movement to the buffer. steps_x, _y and _z is the absolute position in
// mm. Microseconds specify how many microseconds the move should take to perform. To aid acceleration
// calculation the caller must also provide the physical length of the line in millimeters.
//
// Help, why does this comment contradict comments in planner.h?
// I'm quite sure steps_a, _b, ... are absolute step count along each axis,
// and that a, b, c, d are relative positions in mm that we plan on taking. tobben 9 sep 2015
void plan_buffer_line(const float* line_lengths, const float* prev_line_lengths, const float &e,
                     float feed_rate, const uint8_t &extruder, unsigned char count_it){
  // Calculate the buffer head after we push this byte
  int next_buffer_head = next_block_index(block_buffer_head);

  // If the buffer is full: good! That means we are well ahead of the robot.
  // Rest here until there is room in the buffer.
  while(block_buffer_tail == next_buffer_head)
  {
    manage_heater();
    manage_inactivity();
  }

  // Prepare to set up new block
  block_t *block = &block_buffer[block_buffer_head];

  // Mark block as not busy (Not executed by the stepper interrupt)
  block->busy = false;

  // Mark if this is a move that will have its steps counted or not
  block->count_it = count_it;

  // The target position of the tool in absolute steps
  // Calculate target position in absolute steps
  //this should be done after the wait, because otherwise a M92 code within the gcode disrupts this calculation somehow
  //
  // To find target position of stepper motor:
  // Integrate steps per mm function a/sqrt(c0 + c1*x) from 0 to line_lengths[ABCD_AXIS]
  long target[NUM_AXIS];
#if defined(EXPERIMENTAL_LINE_BUILDUP_COMPENSATION_FEATURE)
  target[A_AXIS] = lround(k0[A_AXIS]*(sqrt(k1[A_AXIS] + k2[A_AXIS]*line_lengths[A_AXIS]) - sqrtk1[A_AXIS]));
  target[B_AXIS] = lround(k0[B_AXIS]*(sqrt(k1[B_AXIS] + k2[B_AXIS]*line_lengths[B_AXIS]) - sqrtk1[B_AXIS]));
  target[C_AXIS] = lround(k0[C_AXIS]*(sqrt(k1[C_AXIS] + k2[C_AXIS]*line_lengths[C_AXIS]) - sqrtk1[C_AXIS]));
  target[D_AXIS] = lround(k0[D_AXIS]*(sqrt(k1[D_AXIS] + k2[D_AXIS]*line_lengths[D_AXIS]) - sqrtk1[D_AXIS]));
#else
  target[A_AXIS] = lround(line_lengths[A_AXIS]*axis_steps_per_unit[A_AXIS]);
  target[B_AXIS] = lround(line_lengths[B_AXIS]*axis_steps_per_unit[B_AXIS]);
  target[C_AXIS] = lround(line_lengths[C_AXIS]*axis_steps_per_unit[C_AXIS]);
  target[D_AXIS] = lround(line_lengths[D_AXIS]*axis_steps_per_unit[D_AXIS]);
#endif // EXPERIMENTAL_LINE_BUILDUP_COMPENSATION_FEATURE
  target[E_AXIS] = lround(e*axis_steps_per_unit[E_AXIS]);

  // Number of steps for each axis
  //SERIAL_ECHO("position[A_AXIS]: ");
  //SERIAL_ECHOLN(position[A_AXIS]);
  block->steps_a = labs(target[A_AXIS]-position[A_AXIS]);
  block->steps_b = labs(target[B_AXIS]-position[B_AXIS]);
  block->steps_c = labs(target[C_AXIS]-position[C_AXIS]);
  block->steps_d = labs(target[D_AXIS]-position[D_AXIS]);

  //SERIAL_ECHO("block->steps_d: ");
  //SERIAL_ECHOLN(block->steps_d);

  block->steps_e = labs(target[E_AXIS]-position[E_AXIS]);
  block->steps_e *= volumetric_multiplier[active_extruder];
  block->steps_e *= extrudemultiply;
  block->steps_e /= 100;
  block->step_event_count = max(block->steps_a, max(block->steps_b, max(block->steps_c, max(block->steps_d, block->steps_e))));

  // Bail if this is a zero-length block
  if (block->step_event_count <= dropsegments) return;

  block->fan_speed = fanSpeed;

  // Compute direction bits for this block
  block->direction_bits = 0;

  if(target[A_AXIS] < position[A_AXIS]) block->direction_bits |= (1<<A_AXIS);
  if(target[B_AXIS] < position[B_AXIS]) block->direction_bits |= (1<<B_AXIS);
  if(target[C_AXIS] < position[C_AXIS]) block->direction_bits |= (1<<C_AXIS);
  if(target[D_AXIS] < position[D_AXIS]) block->direction_bits |= (1<<D_AXIS);
  if(target[E_AXIS] < position[E_AXIS]) block->direction_bits |= (1<<E_AXIS);

  block->active_extruder = extruder;

#if !defined(HANGPRINTER)
  //enable active axes
  if(block->steps_a != 0) enable_x();
  if(block->steps_b != 0) enable_y();
  if(block->steps_c != 0) enable_z();
  if(block->steps_d != 0) enable_e1();
#endif

  // Enable extruder(s)
  if(block->steps_e != 0){
    enable_e0();
    if(feed_rate<minimumfeedrate) feed_rate=minimumfeedrate;
  }else{
    if(feed_rate<mintravelfeedrate) feed_rate=mintravelfeedrate;
  }

  float delta_mm[NUM_AXIS];
  delta_mm[A_AXIS] = line_lengths[A_AXIS] - prev_line_lengths[A_AXIS];
  delta_mm[B_AXIS] = line_lengths[B_AXIS] - prev_line_lengths[B_AXIS];
  delta_mm[C_AXIS] = line_lengths[C_AXIS] - prev_line_lengths[C_AXIS];
  delta_mm[D_AXIS] = line_lengths[D_AXIS] - prev_line_lengths[D_AXIS];
  delta_mm[E_AXIS] =((target[E_AXIS]-position[E_AXIS])/axis_steps_per_unit[E_AXIS])*volumetric_multiplier[active_extruder]*extrudemultiply/100.0;

  if (block->steps_a <=dropsegments && block->steps_b <=dropsegments && block->steps_c <=dropsegments && block->steps_d <=dropsegments ){
    block->millimeters = fabs(delta_mm[E_AXIS]);
  }else{ // TODO: is this sqrt'ing and squaring really needed? What do we want block->millimeters for? tobben 21. may 2015
    block->millimeters = sqrt(square(delta_mm[A_AXIS]) + square(delta_mm[B_AXIS]) + square(delta_mm[C_AXIS]) + square(delta_mm[D_AXIS]));
    //SERIAL_ECHO("block->millimeters: ");
    //SERIAL_ECHOLN(block->millimeters);
  }
  float inverse_millimeters = 1.0/block->millimeters;  // Inverse millimeters to remove multiple divides

  // Calculate speed in mm/second for each axis. No divide by zero due to previous checks.
  float inverse_second = feed_rate * inverse_millimeters;

  int moves_queued=(block_buffer_head-block_buffer_tail + BLOCK_BUFFER_SIZE) & (BLOCK_BUFFER_SIZE - 1);

  // Why do we need nominal_speed and nominal_rate? These seems to be the only places where the expensive value block->millimeters ends up. tobben 10 sep 2015
  block->nominal_speed = block->millimeters * inverse_second; // (mm/sec) Always > 0 (won't this always be = feed_rate? tobben 10 sep 2015)
  block->nominal_rate = ceil(block->step_event_count * inverse_second); // (step/sec) Always > 0

  // Calculate and limit speed in mm/sec for each axis
  float current_speed[NUM_AXIS];
  float speed_factor = 1.0; //factor <=1 do decrease speed
  for(int i=0; i < NUM_AXIS; i++){
    current_speed[i] = delta_mm[i] * inverse_second;
    if(fabs(current_speed[i]) > max_feedrate[i])
      speed_factor = min(speed_factor, max_feedrate[i] / fabs(current_speed[i]));
  }

  // Max segement time in us.
// TODO: Will Hangprinter have any frequency limit? build on this code? tobben 21. may 2015
#ifdef XY_FREQUENCY_LIMIT
#define MAX_FREQ_TIME (1000000.0/XY_FREQUENCY_LIMIT)
  // Check and limit the xy direction change frequency
  unsigned char direction_change = block->direction_bits ^ old_direction_bits;
  old_direction_bits = block->direction_bits;
  segment_time = lround((float)segment_time / speed_factor);

  if((direction_change & (1<<X_AXIS)) == 0){
    x_segment_time[0] += segment_time;
  }else{
    x_segment_time[2] = x_segment_time[1];
    x_segment_time[1] = x_segment_time[0];
    x_segment_time[0] = segment_time;
  }
  if((direction_change & (1<<Y_AXIS)) == 0){
    y_segment_time[0] += segment_time;
  }else{
    y_segment_time[2] = y_segment_time[1];
    y_segment_time[1] = y_segment_time[0];
    y_segment_time[0] = segment_time;
  }
  long max_x_segment_time = max(x_segment_time[0], max(x_segment_time[1], x_segment_time[2]));
  long max_y_segment_time = max(y_segment_time[0], max(y_segment_time[1], y_segment_time[2]));
  long min_xy_segment_time =min(max_x_segment_time, max_y_segment_time);
  if(min_xy_segment_time < MAX_FREQ_TIME)
    speed_factor = min(speed_factor, speed_factor * (float)min_xy_segment_time / (float)MAX_FREQ_TIME);
#endif // XY_FREQUENCY_LIMIT

  // Correct the speed
  if( speed_factor < 1.0){
    for(unsigned char i=0; i < NUM_AXIS; i++)
      current_speed[i] *= speed_factor;
    block->nominal_speed *= speed_factor;
    block->nominal_rate *= speed_factor;
  }

  // Compute and limit the acceleration rate for the trapezoid generator.
  float steps_per_mm = block->step_event_count/block->millimeters;
  if(block->steps_a == 0 && block->steps_b == 0 && block->steps_c == 0 && block->steps_d == 0){
    block->acceleration_st = ceil(retract_acceleration * steps_per_mm); // convert to: acceleration steps/sec^2
  }else{
    block->acceleration_st = ceil(acceleration * steps_per_mm); // convert to: acceleration steps/sec^2
    // Limit acceleration per axis
    if(((float)block->acceleration_st * (float)block->steps_a / (float)block->step_event_count) > axis_steps_per_sqr_second[A_AXIS])
      block->acceleration_st = axis_steps_per_sqr_second[A_AXIS];
    if(((float)block->acceleration_st * (float)block->steps_b / (float)block->step_event_count) > axis_steps_per_sqr_second[B_AXIS])
      block->acceleration_st = axis_steps_per_sqr_second[B_AXIS];
    if(((float)block->acceleration_st * (float)block->steps_c / (float)block->step_event_count) > axis_steps_per_sqr_second[C_AXIS])
      block->acceleration_st = axis_steps_per_sqr_second[C_AXIS];
    if(((float)block->acceleration_st * (float)block->steps_d / (float)block->step_event_count) > axis_steps_per_sqr_second[D_AXIS])
      block->acceleration_st = axis_steps_per_sqr_second[D_AXIS];
    if(((float)block->acceleration_st * (float)block->steps_e / (float)block->step_event_count) > axis_steps_per_sqr_second[E_AXIS])
      block->acceleration_st = axis_steps_per_sqr_second[E_AXIS];
  }
  block->acceleration = block->acceleration_st / steps_per_mm;
  block->acceleration_rate = (long)((float)block->acceleration_st * (16777216.0 / (F_CPU / 8.0)));

  // Start with a safe speed
  float vmax_junction = max_xy_jerk/2;
  float vmax_junction_factor = 1.0;
  if(fabs(current_speed[D_AXIS]) > max_z_jerk/2)
    vmax_junction = min(vmax_junction, max_z_jerk/2);
  if(fabs(current_speed[E_AXIS]) > max_e_jerk/2)
    vmax_junction = min(vmax_junction, max_e_jerk/2);
  vmax_junction = min(vmax_junction, block->nominal_speed);
  float safe_speed = vmax_junction;

  if ((moves_queued > 1) && (previous_nominal_speed > 0.0001)) {
// uses L1 norm instead of L2 norm... tobben 9 sep 2015
    float jerk = max(fabs(current_speed[A_AXIS]-previous_speed[A_AXIS]),
                     max(fabs(current_speed[B_AXIS]-previous_speed[B_AXIS]),
                         fabs(current_speed[C_AXIS]-previous_speed[C_AXIS])));
    vmax_junction = block->nominal_speed;
    if (jerk > max_xy_jerk) {
      vmax_junction_factor = (max_xy_jerk/jerk);
    }
    if(fabs(current_speed[D_AXIS] - previous_speed[D_AXIS]) > max_z_jerk) {
      vmax_junction_factor = min(vmax_junction_factor, (max_z_jerk/fabs(current_speed[D_AXIS] - previous_speed[D_AXIS])));
    }
    if(fabs(current_speed[E_AXIS] - previous_speed[E_AXIS]) > max_e_jerk) {
      vmax_junction_factor = min(vmax_junction_factor, (max_e_jerk/fabs(current_speed[E_AXIS] - previous_speed[E_AXIS])));
    }
    vmax_junction = min(previous_nominal_speed, vmax_junction * vmax_junction_factor); // Limit speed to max previous speed
  }
  block->max_entry_speed = vmax_junction;

  // Initialize block entry speed. Compute based on deceleration to user-defined MINIMUM_PLANNER_SPEED.
  double v_allowable = max_allowable_speed(-block->acceleration,MINIMUM_PLANNER_SPEED,block->millimeters);
  block->entry_speed = min(vmax_junction, v_allowable);

  // Initialize planner efficiency flags
  // Set flag if block will always reach maximum junction speed regardless of entry/exit speeds.
  // If a block can de/ac-celerate from nominal speed to zero within the length of the block, then
  // the current block and next block junction speeds are guaranteed to always be at their maximum
  // junction speeds in deceleration and acceleration, respectively. This is due to how the current
  // block nominal speed limits both the current and next maximum junction speeds. Hence, in both
  // the reverse and forward planners, the corresponding block junction speed will always be at the
  // the maximum junction speed and may always be ignored for any speed reduction checks.
  if (block->nominal_speed <= v_allowable) {
    block->nominal_length_flag = true;
  }else{
    block->nominal_length_flag = false;
  }
  block->recalculate_flag = true; // Always calculate trapezoid for new block

  // Update previous path unit_vector and nominal speed
  memcpy(previous_speed, current_speed, sizeof(previous_speed)); // previous_speed[] = current_speed[]
  previous_nominal_speed = block->nominal_speed;

  calculate_trapezoid_for_block(block, block->entry_speed/block->nominal_speed,
      safe_speed/block->nominal_speed);

  // Move buffer head
  block_buffer_head = next_buffer_head;

  // Update position
  if(block->count_it){
    memcpy(position, target, sizeof(target)); // position[] = target[]
  }

  planner_recalculate();

  st_wake_up();
}

void plan_set_position(const float* line_lengths, const float &e)
{
#ifdef EXPERIMENTAL_LINE_BUILDUP_COMPENSATION_FEATURE
  for(int i=0; i<DIRS; i++){
    position[i] = lround(k0[i]*(sqrt(k1[i] + k2[i]*line_lengths[i]) - sqrtk1[i]));
  }
#else
  for(int i=0; i<DIRS; i++){
    position[i] = lround(line_lengths[i]*axis_steps_per_unit[i]);
  }
#endif // EXPERIMENTAL_LINE_BUILDUP_COMPENSATION_FEATURE
  position[E_AXIS] = lround(e*axis_steps_per_unit[E_AXIS]);
  st_set_position(position[A_AXIS], position[B_AXIS], position[C_AXIS], position[D_AXIS], position[E_AXIS]);
  previous_nominal_speed = 0.0; // Resets planner junction speeds. Assumes start from rest.
  previous_speed[A_AXIS] = 0.0;
  previous_speed[B_AXIS] = 0.0;
  previous_speed[C_AXIS] = 0.0;
  previous_speed[D_AXIS] = 0.0;
  previous_speed[E_AXIS] = 0.0;
}

void plan_set_e_position(const float &e)
{
  position[E_AXIS] = lround(e*axis_steps_per_unit[E_AXIS]);
  st_set_e_position(position[E_AXIS]);
}

uint8_t movesplanned()
{
  return (block_buffer_head-block_buffer_tail + BLOCK_BUFFER_SIZE) & (BLOCK_BUFFER_SIZE - 1);
}

#ifdef PREVENT_DANGEROUS_EXTRUDE
void set_extrude_min_temp(float temp)
{
  extrude_min_temp=temp;
}
#endif

#if defined(EXPERIMENTAL_LINE_BUILDUP_COMPENSATION_FEATURE)
// This is used for acceleration planning
// It is not used for calculating correct number of steps at different positions
void calculate_axis_steps_per_unit(const float* line_lengths){
  // Divide by new radius to find new steps/mm
  axis_steps_per_unit[A_AXIS] =
    steps_per_unit_times_r[A_AXIS]/sqrt(spool_buildup_factor*(line_on_spool_origo[A_AXIS] + (float)nr_of_lines_in_direction[A_AXIS]*(INITIAL_DISTANCES[A_AXIS] - line_lengths[A_AXIS])) + spool_radii2[A_AXIS]);
  axis_steps_per_unit[B_AXIS] =
    steps_per_unit_times_r[B_AXIS]/sqrt(spool_buildup_factor*(line_on_spool_origo[B_AXIS] + (float)nr_of_lines_in_direction[B_AXIS]*(INITIAL_DISTANCES[B_AXIS] - line_lengths[B_AXIS])) + spool_radii2[B_AXIS]);
  axis_steps_per_unit[C_AXIS] =
    steps_per_unit_times_r[C_AXIS]/sqrt(spool_buildup_factor*(line_on_spool_origo[C_AXIS] + (float)nr_of_lines_in_direction[C_AXIS]*(INITIAL_DISTANCES[C_AXIS] - line_lengths[C_AXIS])) + spool_radii2[C_AXIS]);
  axis_steps_per_unit[D_AXIS] =
    steps_per_unit_times_r[D_AXIS]/sqrt(spool_buildup_factor*(line_on_spool_origo[D_AXIS] + (float)nr_of_lines_in_direction[D_AXIS]*(INITIAL_DISTANCES[D_AXIS] - line_lengths[D_AXIS])) + spool_radii2[D_AXIS]);
}
#endif

// Calculate the steps/s^2 acceleration rates, based on the mm/s^s
void reset_acceleration_rates(){
#if defined(EXPERIMENTAL_LINE_BUILDUP_COMPENSATION_FEATURE)
  calculate_axis_steps_per_unit(line_lengths);
#endif
  for(int8_t i=0; i < NUM_AXIS; i++)
    axis_steps_per_sqr_second[i] = max_acceleration_units_per_sq_second[i] * axis_steps_per_unit[i];
}
