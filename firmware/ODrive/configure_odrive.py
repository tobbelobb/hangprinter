# This is meant for resetting A-motor if its oDrive settings get erased
# Could also speed up configuration of the other motors considerably

import odrive
odrv0 = odrive.find_any()

# Default values used on the dev setup.
# If your setup is fifferent in any way, you might have to change these values
#odrv0.config.brake_resistance = 0.4699999988079071 # Default

#odrv0.axis0.motor.config.pole_pairs = 7            # Default
#odrv0.axis0.controller.current_setpoint = 0        # Default. Torque mode with zero torque

#odrv0.axis1.motor.config.calibration_current = 10  # Default
#odrv0.axis1.motor.config.pole_pairs = 7            # Default
#odrv0.axis1.controller.current_setpoint = 0        # Default. Torque mode with zero torque

# 4500 rpm specced here:
# https://docs.google.com/spreadsheets/d/1OBDwYrBb5zUPZLrhL98ezZbg94tUsZcdTuwiVNgVqpU/edit#gid=0
# (4500/60)*2400 = 180000
#odrv0.axis0.controller.config.vel_limit = 180000
# At 140000 the plastic parts starts to resonate
odrv0.axis0.controller.config.vel_limit = 130000
odrv0.axis0.encoder.config.cpr = 2400     # Generic 600 ppr optical encoder
odrv0.axis0.motor.config.current_lim = 30 # Strong enough...
odrv0.axis0.motor.config.calibration_current = 15

odrv0.axis1.controller.config.vel_limit = 130000
odrv0.axis1.encoder.config.cpr = 2400     # Generic 600 ppr optical encoder
odrv0.axis1.motor.config.current_lim = 30 # Strong enough...
odrv0.axis1.motor.config.calibration_current = 15

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
odrv0.axis0.config.startup_encoder_offset_calibration = True
odrv0.axis0.config.startup_closed_loop_control = True
odrv0.axis0.config.startup_motor_calibration = True

odrv0.axis1.config.startup_encoder_offset_calibration = True
odrv0.axis1.config.startup_closed_loop_control = True
odrv0.axis1.config.startup_motor_calibration = True

# PID tuning
odrv0.axis0.controller.config.pos_gain = 70
odrv0.axis0.controller.config.vel_integrator_gain = 0.002
odrv0.axis0.controller.config.vel_gain = 0.004

odrv0.axis1.controller.config.pos_gain = 70
odrv0.axis1.controller.config.vel_integrator_gain = 0.002
odrv0.axis1.controller.config.vel_gain = 0.004

# Interface
odrv0.config.enable_uart = True

odrv0.axis0.config.step_gpio_pin = 6
odrv0.axis0.config.dir_gpio_pin = 5
odrv0.axis0.config.counts_per_step = 6.0 # 2400/(25*16) = 6
odrv0.axis0.config.enable_step_dir = True

#odrv0.axis1.config.step_gpio_pin = 7 # Default
#odrv0.axis1.config.dir_gpio_pin = 8  # Default
odrv0.axis1.config.counts_per_step = 6.0 # 2400/(25*16) = 6
odrv0.axis1.config.enable_step_dir = True

odrv0.save_configuration()
odrv0.reboot()
