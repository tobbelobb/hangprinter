## State of Hangprinter v3 firmware as of Sep 18, 2018

### Marlin
Hangprinter support was merged into Marlin's develpopment branch on Sep 9, 2018.
In this repo you'll find a copy of that development branch.
At the time of writing this, Hangprinter support has not been included in any Marlin releases yet, so we use the dev branch for now.

### Smart Stepper
Smart Stepper is a development of the Mechaduino board, capable of advanced closed loop stepper motor control.
The Smart Stepper boards provide Hangprinter with closed loop control (no skipped steps), torque mode, and encoder readings, which enable Hangprinter's semi-automatic calibration
procedure.

### No Mechaduino?
It is recommended to use the SmartStepper firmware even if you have Mechaduino hardware.
The Mechaduino firmware contained bugs that degraded Hangprinter accuracy slightly (see [this snippet](https://gitlab.com/snippets/1752083) for details).

To compile Smart Stepper Firmware for a Mechaduino board, you uncomment
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
