## State of Hangprinter v3 firmware as of Sep 18, 2018

### Marlin
The version of Marlin in this directory is tested and to run fairly stable on a Hangprinter v3.
For the latest fixes, features, and developments, use the [bugfix-1.1.x branch of stock Marlin](https://github.com/marlinfirmware/Marlin/tree/bugfix-1.1.x), which now
includes official support for Hangprinter.

### Smart Stepper
Smart Stepper is a development of the Mechaduino board, capable of advanced closed loop stepper motor control.
The Smart Stepper boards provide Hangprinter with closed loop control (no skipped steps), torque mode, and encoder readings, which enable Hangprinter's semi-automatic calibration
procedure.

### No Mechaduino?
The Mechaduino board is very good, but the Smart Stepper board is even better.
It is recommended to use the SmartStepper firmware even if you have Mechaduino hardware.
The Mechaduino firmware contained bugs that degraded Hangprinter accuracy slightly (see [this snippet](https://gitlab.com/snippets/1752083) for details).

To compile for a Mechaduino board, you might have to uncomment
```
#define MECHADUINO_HARDWARE
```
in `boards.h`, and comment out
```
#define NEMA17_SMART_STEPPER_3_21_2017
```
in the same file.

### Smart Stepper Wiring
The Smart Stepper LCD screens can not be used on a Hangprinter, since the SDA and SCL pins are needed for communicating with the host controller (RAMPS or whatever board
you've chosen for your HP3).

The Smart Stepper boards need to be configured with their own i2c addresses.
Marlin expects motor A to have i2c address 0x0a, motor b to have address 0x0b etc.
To check which i2c address your Smart Stepper has, issue
```
i2cid
```
via the serial port.
To set the address to for example `0x0b`, issue
```
i2cid 0x0b
```

It's recommended to check out the `ctrlmode` command as well.
There are two modes that can both work well with Hangprinter.

 * `controller Simple-Position-PID(2)`
 * `controller Current-Position-PID(3)`

The latter will give more silent and efficient operation on almost all motors, but requires you to do PID tuning through the `ppid` command.
