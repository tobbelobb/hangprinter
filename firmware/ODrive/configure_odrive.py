# This is meant for resetting A-motor if its oDrive settings get erased
# Could also speed up configuration of the other motors considerably

import odrive
odrv0 = odrive.find_any()

# Default values used on the dev setup.
# If your setup is different in any way, you might have to change these values
#odrv0.config.brake_resistance = 0.4699999988079071 # Default
# Later ODrive Firmware versions (0.5.2 onwards) might disable break resistor by default
# So you need to set a boolean to true to enable it again:
# odrv0.config.enable_brake_resistor = true;

#odrv0.axis0.motor.config.pole_pairs = 7            # Default
#odrv0.axis0.controller.current_setpoint = 0        # Default. Torque mode with zero torque

#odrv0.axis1.motor.config.pole_pairs = 7            # Default
#odrv0.axis1.controller.current_setpoint = 0        # Default. Torque mode with zero torque

# 4500 rpm specced here:
# https://docs.google.com/spreadsheets/d/1OBDwYrBb5zUPZLrhL98ezZbg94tUsZcdTuwiVNgVqpU/edit#gid=0
# (4500/60)*2400 = 180000
#odrv0.axis0.controller.config.vel_limit = 180000
# At 140000 the plastic parts starts to resonate
odrv0.axis0.controller.config.vel_limit = 40
odrv0.axis0.encoder.config.cpr = 8192     # AMT102-V
# The AMT102-V has an index signal.
# See https://docs.odriverobotics.com/encoders#encoder-with-index-signal
# for how to use it
# You do things like
# odrv0.axis0.encoder.config.use_index = True
# odrv0.axis0.requested_state = AXIS_STATE_ENCODER_INDEX_SEARCH
# odrv0.axis0.requested_state = AXIS_STATE_ENCODER_OFFSET_CALIBRATION
# odrv0.axis0.encoder.config.pre_calibrated = True
# odrv0.axis0.config.startup_encoder_index_search = True
# odrv0.axis0.motor.config.pre_calibrated = True
odrv0.axis0.motor.config.current_lim = 20 # Strong enough...
odrv0.axis0.motor.config.current_lim_margin=18
odrv0.axis0.motor.config.calibration_current = 20
odrv0.axis0.motor.config.torque_constant = 8.27/310 # = 0.0266774193548387
# kv was measured to be ca 310. We don't know exactly

odrv0.axis1.controller.config.vel_limit = 40
odrv0.axis1.encoder.config.cpr = 8192     # AMT102-V
odrv0.axis1.motor.config.current_lim = 20 # Strong enough...
odrv0.axis1.motor.config.current_lim_margin=18
odrv0.axis1.motor.config.calibration_current = 20
odrv0.axis1.motor.config.torque_constant = 8.27/310 # = 0.0266774193548387

# Enforce startup sequence this time
odrv0.axis0.requested_state = AXIS_STATE_FULL_CALIBRATION_SEQUENCE
# Wait for calibration to finish...
while my_drive.axis0.current_state != AXIS_STATE_IDLE:
    time.sleep(0.1)
odrv0.axis0.requested_state = AXIS_STATE_CLOSED_LOOP_CONTROL

odrv0.axis1.requested_state = AXIS_STATE_FULL_CALIBRATION_SEQUENCE
# Wait for calibration to finish...
while my_drive.axis1.current_state != AXIS_STATE_IDLE:
    time.sleep(0.1)
odrv0.axis1.requested_state = AXIS_STATE_CLOSED_LOOP_CONTROL

# Have the same startup sequence automatically from now on
odrv0.axis0.config.startup_encoder_offset_calibration = False # True if you don't use encoder indexing
odrv0.axis0.config.startup_motor_calibration = False # True if you don't use encoder indexing
odrv0.axis0.config.startup_closed_loop_control = True

odrv0.axis1.config.startup_encoder_offset_calibration = False # True if you don't use encoder indexing
odrv0.axis1.config.startup_motor_calibration = False # True if you don't use encoder indexing
odrv0.axis1.config.startup_closed_loop_control = True

# PID tuning
odrv0.axis0.controller.config.pos_gain = 47
odrv0.axis0.controller.config.vel_integrator_gain = 0.2
odrv0.axis0.controller.config.vel_gain = 0.09

odrv0.axis1.controller.config.pos_gain = 47
odrv0.axis1.controller.config.vel_integrator_gain = 0.2
odrv0.axis1.controller.config.vel_gain = 0.09

# Interface
odrv0.config.enable_uart = False
# Later ODrive Firmware versions (0.5.2 onwards) require you to disable the default uart like this instead:
# odrv0.config.enable_uart_a = False

#odrv0.can.set_baud_rate(250000) # Default
# odrv0.axis0.config.can_node_id = 40 # A
# odrv0.axis1.config.can_node_id = 41 # B
# For the other board
odrv0.axis0.config.can_node_id = 42 # C
odrv0.axis1.config.can_node_id = 43 # D
# Later ODrive Firmware versions (0.5.2 onwards) configure can_node_id like this:
# odrv0.axis0.config.can.node_id = 42

odrv0.axis0.config.step_gpio_pin = 1
odrv0.axis0.config.dir_gpio_pin = 2
odrv0.axis0.config.turns_per_step = 0.0025 # 1/(25*16) = 0.0025
# Later ODrive Firmware versions (0.5.2 onwards) configure turns_per_step like this:
# odrv0.axis0.axis.controller.config.steps_per_circular_range = 400 # 25*16

odrv0.axis0.config.enable_step_dir = True

#odrv0.axis1.config.step_gpio_pin = 7 # Default
#odrv0.axis1.config.dir_gpio_pin = 8  # Default
odrv0.axis1.config.turns_per_step = 0.0025 # 1/(25*16) = 0.0025
odrv0.axis1.config.enable_step_dir = True

# Calibrate anti cogging like this
# odrv0.axis0.controller.config.vel_gain = 0.05
# odrv0.axis0.controller.start_anticogging_calibration()

# Check progress with:
# odrv0.axis0.controller.config.anticogging
# As long as calib_anticogging is True, the calibration is still going on
# You can also check the odrv0.axis0.controller.input_pos to see progress

# When it's done:
# odrv0.axis0.controller.config.anticogging.pre_calibrated = True
# odrv0.axis0.controller.config.anticogging.anticogging_enabled = True
# odrv0.axis0.controller.config.vel_gain = 0.09


odrv0.save_configuration()
odrv0.reboot()
