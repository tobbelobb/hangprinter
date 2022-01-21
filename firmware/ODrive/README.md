## ODrive Usage On Hangprinter

Use stock ODrive Firmware version 0.5.1.
I have not been able to make anti-cogging calibration work in later versions.
I have tested 0.5.2 and 0.5.4.

Use a <a href="https://odriverobotics.com/shop/usb-isolator">USB isolator</a> between your laptop and your ODrive.

The source is kept here:
[https://github.com/madcowswe/ODrive](github.com/madcowswe/ODrive).

[The official ODrive docs](https://docs.odriverobotics.com/) are helpful in explaining many of the commands.

### How to Configure

Read every line of `configure_odrive.py`, including the comments manually before executing any of them.
Most of it can be copy/pasted in blocks, but in some places you have to wait.

I've included config dumps of my own ODrives here, and it might be tempting to use upload them directly to your own ODrives, like this

```
$ odrivetool restore-config odrive-config-AB.json  # With AB ODrive connected
$ odrivetool restore-config odrive-config-CD.json  # With CD ODrive connected
```

I haven't tried this myself, but at least one user has reported saving time by doing ODrive config this way.
Be aware that some lower level config will be slightly off/wrong in your ODrive after you "restore" from my backup.
I know at least these config values will be slightly off:

```
odrv0.axis0.encoder.config.offset_float
odrv0.axis0.encoder.config.offset
odrv0.axis1.encoder.config.offset_float
odrv0.axis1.encoder.config.offset
odrv0.axis0.motor.config.phase_inductance
odrv0.axis0.motor.config.phase_resistance
odrv0.axis1.motor.config.phase_inductance
odrv0.axis1.motor.config.phase_resistance
```

My guess is that they can get fixed up by a few commands in the odrivetool:
```
odrv0.axis0.requested_state = AXIS_STATE_ENCODER_INDEX_SEARCH
# wait...
odrv0.axis1.requested_state = AXIS_STATE_ENCODER_INDEX_SEARCH
# wait...
odrv0.axis0.requested_state = AXIS_STATE_ENCODER_OFFSET_CALIBRATION
# wait...
odrv0.axis1.requested_state = AXIS_STATE_ENCODER_OFFSET_CALIBRATION
# wait...
```

Also, the config backup does not include anti-cogging, so you have to set that up separately.
Look into `config_odrive.py` for how I set up anti-cogging.
