# Smart Stepper (also known as the nano zero stepper)
Firmware to turn a stepper motor into servo motor: see http://misfittech.net for hardware! 



If you want to support the work on the firmware and hardware consider buying hardware from www.misfittech.net or buying me a beer using the donation button. 

[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=4JAEK4G24W2U4)

# How to Install 
[Hardware install](http://misfittech.net/2016/11/29/installing-the-nano-zero-stepper/)

[Arduino install] (http://misfittech.net/2016/07/27/arduino_install/) for building firmware

[Further Details and to purchase Hardware] (http://misfittech.net/product/nano-zero-stepper/)


# Command List

## Smart Stepper Command Line Interface
The smart stepper uses a command line interface where the prompt is “:>” 

### help 
The help command will return a list of commands that the smart stepper supports. 

### getcal
This command will print out the 200 point calibration table.  This is useful if you are doing firmware development and do not want to calibrate each time you update firmware.  You can take this table and copy it into the nonvolatile.cpp file as shown below

### calibrate
This will run a 200 point calibration of the encoder. 

### testcal 
This will test the calibration and report the maximum error in degrees. 

### step
This will move the motor one step clockwise, the step size is based on the current microstep setting.  To move the motor counterclockwise use “step 1”. To move the motor clockwise 16 steps used “step 0 16” to move motor counterclockwise 16 steps use “step 1 16”

### feedback 
This commands disable/enables feedback control loop. 
The plan is to discountinue this command in the future and use the “controlmode” command to put controller in open or one of the many closed loop operational modes. 

### readpos
Reads the current motor position and reports it as degrees.

### encoderdiag
This command will read and report the AS5047D internal registers for diagnostic purposes. 

### microsteps 
This command gets/sets the number of microsteps the smart stepper will use for the step command and the step pin.  The number of microsteps does not affect the resolution of the controller but rather how fine you can set the position. 

### spid
This command sets the Kp, Ki, and Kd terms for the simple positional PID controller. 

### ppid
This command sets the Kp, Ki, and Kd terms for the positional PID controller. 

### vpid
This command sets the Kp, Ki, and Kd terms for the velocity PID controller. 

### velocity 
This sets the velocity to rotate motor when unit is configured for velocity PID mode of operation. 

### boot
This command will put the microprocessor in the boot loader mode.  Alternatively this can be done by double pressing the reset button. 

### factoryreset 
This erases the calibration and other system and motor parameters such that unit is reset to the factory ship state.  After this command the unit will need to be calibrated to the motor again. 

### dirpin
This command sets which direction the motor will rotate when direction pin is pulled high. The direction pin is only sampled when the step pin has a rising edge. 
‘dirpin 0’ will set the motor to rotate clockwise when dir pin is high
‘dirpin 1’ will set the motor to rotate counter-clockwise when dir pin is high

### errorlimit
Gets set the maximum number of degrees of error that is acceptable, any posistioning error about the error limit will assert the error pin, when error pin is set as error output. 
For example:
:>errorlimit 1.8 
Will set the error limit to 1.8 degrees. 

### ctrlmode
Gets/Sets the feedback controller mode of operation. The command takes an integer from 0 through 4 to set the control mode per table below:
Controller off - 	0  -- this is not currently used
Open-Loop - 	1  -- this is open loop with no feedback
Simple PID -   2  -- simple positional PID, which is factory default 
Positional PID - 3 -- current based PID mode, requires tuning for your machine
Velocity PID - 4 -- velocity based PID, requires tuning for your machine and speed range

If you are unsure what you are doing leave unit in the Simple PID mode of operation. 

### maxcurrent
This sets the maximum current that will be pushed into the motor. To set the current for maximum of 2.0A you would use command “maxcurrent 2000” as the argument is in milliAmps. 

### holdcurrent
For the Simple Positional PID mode the minimal current (ie current with no positional error) is the hold current. You set this current based on the required holding torque you need for your application. The higher the hold current, the hotter and noisier the motor will be but also the larger the holding torque. 
For the Positional PID mode the PID tuning params have to be set correctly such that the control loop will dynamically determine the holding torque. This tuning of the PID can be difficult, hence the simple PID mode will work most of the time out of the box by setting maximum current and holding current. 

### motorwiring
The firmware always uses a positive angle as a clockwise rotation. A stepper motor however could have wiring done with one coil reversed wired, which will cause motor to normally operate in opposite direction. The Smart Stepper firmware will detect the motor wiring direction, using the encoder, and the firmware will compensate for a reverse wired motor.  The reverse or forward wiring of a motor is detected on first power up after factory reset. If the wiring changes after that you can compensate using this command. 
HOWEVER  it is better to do a factory reset and recalibrate motor if wiring changes. 

### stepsperrotation
The Smart Stepper firmware will with first power on after factory reset detect the number of full steps per rotation for the stepper motor and store in flash memory. This command will read this parameter from flash and allow user to change this parameter if motor is changed.
HOWEVER  it is better to do a factory reset and recalibrate motor if motorchanges. 

### move
The move command will request the motor to move to an absolute angle position.  Optionally the user can specify the rotational speed (RPMs) by which the move should happen. For example if the current motor position is at angle 0 and you issue ‘move 3600” the motor will turn 10 rotations clockwise to angle of 3600 degrees. If issue the ‘move 3600’ again nothing will happen as motor is already at angle 3600. 
If motor is at angle 0 and user issues the command ‘move 3600 20’ then motor will move to 10 rotations clockwise to angle of 3600 at a rate of 20 RPMs. 

### stop
If user issues a move command that takes a long time and wants to stop the move before completion then user can issue the stop command command which will stop a move operation. 

### setzero
This command will take the current motor position and set it to absolute angle of  zero. Note that if you are in the middle move it will take the position at the time of the command and use it, thus it is recommend a move be stopped or wait for completion before issuing the setzero. 

## License:
All nano stepper related materials are released under the Creative Commons Attribution Share-Alike 4.0 License
Much of the work is based on Mechaduino project:
https://github.com/jcchurch13/Mechaduino-Firmware

This firmware also runs on the Mechaduino hardware and has many improvements over stock Mechaduino firmware. 
Note the Mechaduino 0.1 does have a few hardware issues that the firmware can not fix:

