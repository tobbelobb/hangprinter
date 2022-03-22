## ODrive Usage On Hangprinter

Hangprinter uses stock ODrive Firmware version 0.5.5 or later.

Use a <a href="https://odriverobotics.com/shop/usb-isolator">USB isolator</a> between your laptop and your ODrive.

The source is kept here:
[https://github.com/madcowswe/ODrive](github.com/madcowswe/ODrive).

[The official ODrive docs](https://docs.odriverobotics.com/v/0.5.5/getting-started.html) are helpful in explaining many of the commands.

### How to Configure

Read every line of `configure_odrive.py`, including the comments manually before executing any of them.
Most of it can be copy/pasted in blocks, but in some places you have to wait.

I've included config dumps of my own ODrives here, and it might be tempting to use upload them directly to your own ODrives, like this

```
$ odrivetool restore-config odrive-config-AB.json  # With AB ODrive connected
$ odrivetool restore-config odrive-config-CD.json  # With CD ODrive connected
```

After those commands, you need to confirm that your break resistance matches the configured one.
You also need to do a calibration sequence and set a couple of variables:
odrivetool:
```
odrv0.config.brake_resistance = your_measured_value
odrv0.axis0.requested_state = AXIS_STATE_FULL_CALIBRATION_SEQUENCE
# wait...
odrv0.axis1.requested_state = AXIS_STATE_FULL_CALIBRATION_SEQUENCE
# wait...
odrv0.axis0.encoder.config.pre_calibrated = True
odrv0.axis1.encoder.config.pre_calibrated = True
odrv0.axis0.requested_state = AXIS_STATE_IDLE
odrv0.axis1.requested_state = AXIS_STATE_IDLE
odrv0.save_configuration()
# wait...
```

Also, the config backup does not include anti-cogging, so you have to set that up separately.
Look into `config_odrive.py` for how I set up anti-cogging.
