# Hangprinter version 4 configures its ODrives like is described in this file

# WARNING: Use ODriveFirmware version 0.5.1.
# I have not been able to make later versions work
# I have tested 0.5.2 and 0.5.4

#odrv0.config.brake_resistance = 0.4699999988079071 # Default
# Later ODrive Firmware versions (0.5.2 onwards) might disable break resistor by default
# So you need to set a boolean to true to enable it again:
#odrv0.config.enable_brake_resistor = True;

#odrv0.axis0.motor.config.pole_pairs = 7            # Default
#odrv0.axis0.controller.torque_setpoint = 0        # Default. Torque mode with zero torque

#odrv0.axis1.motor.config.pole_pairs = 7            # Default
#odrv0.axis1.controller.torque_setpoint = 0        # Default. Torque mode with zero torque

# 7500 rpm specced for AMT-10 here:
# https://docs.google.com/spreadsheets/d/1OBDwYrBb5zUPZLrhL98ezZbg94tUsZcdTuwiVNgVqpU/edit#gid=0
# Being conservative, we use 4500
# (4500/60)*2400 = 180000
odrv0.axis0.controller.config.vel_limit = 180000
# At 140000 the plastic parts starts to resonate

odrv0.axis0.encoder.config.cpr = 8192     # AMT102-V
odrv0.axis0.motor.config.current_lim = 20 # Strong enough...
odrv0.axis0.motor.config.current_lim_margin=18
odrv0.axis0.motor.config.calibration_current = 20
odrv0.axis0.motor.config.torque_constant = 8.27/310 # = 0.0266774193548387

odrv0.axis1.controller.config.vel_limit = 180000
odrv0.axis1.encoder.config.cpr = 8192     # AMT102-V
odrv0.axis1.motor.config.current_lim = 20 # Strong enough...
odrv0.axis1.motor.config.current_lim_margin=18
odrv0.axis1.motor.config.calibration_current = 20
odrv0.axis1.motor.config.torque_constant = 8.27/310 # = 0.0266774193548387

# PID tuning
odrv0.axis0.controller.config.pos_gain = 47
odrv0.axis0.controller.config.vel_integrator_gain = 0.2
odrv0.axis0.controller.config.vel_gain = 0.09

odrv0.axis1.controller.config.pos_gain = 47
odrv0.axis1.controller.config.vel_integrator_gain = 0.2
odrv0.axis1.controller.config.vel_gain = 0.09


# The AMT102-V has an index signal.
# See https://docs.odriverobotics.com/encoders#encoder-with-index-signal
odrv0.axis0.encoder.config.use_index = True
odrv0.axis1.encoder.config.use_index = True

odrv0.axis0.requested_state = AXIS_STATE_ENCODER_INDEX_SEARCH
odrv0.axis1.requested_state = AXIS_STATE_ENCODER_INDEX_SEARCH
# wait
odrv0.axis0.requested_state = AXIS_STATE_ENCODER_OFFSET_CALIBRATION
odrv0.axis1.requested_state = AXIS_STATE_ENCODER_OFFSET_CALIBRATION
# wait

odrv0.axis0.encoder.config.pre_calibrated = True
odrv0.axis0.config.startup_encoder_index_search = True
odrv0.axis0.motor.config.pre_calibrated = True
odrv0.axis1.encoder.config.pre_calibrated = True
odrv0.axis1.config.startup_encoder_index_search = True
odrv0.axis1.motor.config.pre_calibrated = True

# Have the same startup sequence automatically from now on
odrv0.axis0.config.startup_encoder_offset_calibration = False # True if you don't use encoder indexing
odrv0.axis0.config.startup_motor_calibration = False # True if you don't use encoder indexing
odrv0.axis0.config.startup_closed_loop_control = True

odrv0.axis1.config.startup_encoder_offset_calibration = False # True if you don't use encoder indexing
odrv0.axis1.config.startup_motor_calibration = False # True if you don't use encoder indexing
odrv0.axis1.config.startup_closed_loop_control = True

# Interface
odrv0.config.enable_uart = False
odrv0.axis0.config.can_heartbeat_rate_ms = 0 # Disable heartbeat
odrv0.axis1.config.can_heartbeat_rate_ms = 0 # Disable heartbeat

#odrv0.can.set_baud_rate(250000) # Default
# odrv0.axis0.config.can_node_id = 40 # A
# odrv0.axis1.config.can_node_id = 41 # B
# For the other board
odrv0.axis0.config.can_node_id = 42 # C
odrv0.axis1.config.can_node_id = 43 # D

odrv0.axis0.config.step_gpio_pin = 1
odrv0.axis0.config.dir_gpio_pin = 2
#odrv0.axis0.controller.config.steps_per_circular_range = 400 # 25*16
odrv0.axis0.config.turns_per_step = 0.0025 # 1/(25*16) = 0.0025
odrv0.axis0.config.enable_step_dir = True

#odrv0.axis1.config.step_gpio_pin = 7 # Default
#odrv0.axis1.config.dir_gpio_pin = 8  # Default
#odrv0.axis1.controller.config.steps_per_circular_range = 400 # 25*16
odrv0.axis1.config.turns_per_step = 0.0025 # 1/(25*16) = 0.0025
odrv0.axis1.config.enable_step_dir = True

# WARNING: Anticogging calibration is very finicky
# Calibrate anti cogging like this
# odrv0.axis0.controller.config.vel_gain = 0.05
# odrv0.axis0.controller.start_anticogging_calibration()

# Check progress with:
# odrv0.axis0.controller.config.anticogging
# As long as calib_anticogging is True, the calibration is still going on
# You can also check the odrv0.axis0.controller.input_pos to see progress
# When odrv0.axis0.controller.config.anticogging.index reaches 3600, calibration is done
# When it's done:
# odrv0.axis0.controller.config.anticogging.pre_calibrated = True
# odrv0.axis0.controller.config.anticogging.anticogging_enabled = True
# odrv0.axis0.controller.config.vel_gain = 0.09


odrv0.save_configuration()
odrv0.reboot()
