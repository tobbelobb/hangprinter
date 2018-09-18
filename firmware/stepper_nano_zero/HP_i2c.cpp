#include "HP_i2c.h"
#include <stdio.h>
#include <Wire.h>


void give_angle()
{
	// Accessing zeroAngleOffset and currentLocation variables
	// are ok as they are both declared volatile
	float ang = -ANGLE_T0_DEGREES(stepperCtrl.getCurrentAngleNoEncoderRead());
	Wire.write((byte*)&ang, 4);
}


void handle_i2c_cmd(int numBytes)
{
	if(numBytes >= 1)
	{
		size_t bufsize = 50;
		size_t offset = 0;
		uint8_t recv[bufsize];

		recv[0] = Wire.read();
		size_t i = 1;
		if(numBytes > 1)
		{
			while (Wire.available() && i < bufsize)
			{
				recv[i] = Wire.read();
				i++;
			}
		}
		if(i >= bufsize)
			return;
		recv[i] = '\0';

		// Parse
		if (i >= 8 && numBytes == 8 && !strncmp((char *)recv, "G95 ", 4))
		{ // RepRapFirmware
			stepperCtrl.got_G95_float = true;
			offset = 4;
		}
		else if ((i >= 3 && numBytes == 3 && !strncmp((char *)recv, "G96", 3)) || (i >= 4 && numBytes == 4 && !strncmp((char *)recv, "G96 ", 4)))
		{ // RepRapFirmware
			stepperCtrl.got_G96 = true;
		}
		else if (i >= 5 && numBytes == 5 && recv[0] == 0x5f)
		{ // Marlin
			stepperCtrl.got_G95_float = true;
			offset = 1;
		}
		else if (numBytes == 1 && recv[0] == 0x60)
		{ // Marlin
			stepperCtrl.got_G96 = true;
		}

		if (stepperCtrl.got_G95_float)
		{
			union {
				uint8_t b[4]; // hard coded 4 instead of sizeof(float)
				float fval;
			} requested_torque;
			if(i >= offset + 3)
			{
				for (size_t j = 0; j < 4; j++)
				{ // float has size 4
					requested_torque.b[j] = recv[offset + j];
				}
				// Setting torque value is ok in here,
				// since torque variable is declared volatile
				if (fabs(requested_torque.fval) <= -127.0)
				{
					stepperCtrl.setTorque(-127);
				}
				else if (fabs(requested_torque.fval) >= 127.0)
				{
					stepperCtrl.setTorque(127);
				}
				else
				{
					stepperCtrl.setTorque((int8_t)requested_torque.fval);
				}
			}
		}
	}
	stepperCtrl.i2c_master_wants_something = true;
}

void setup_HP_I2C()
{
	Wire.begin(NVM->networkingParams.i2c_id);
	Wire.onRequest(give_angle);
	Wire.onReceive(handle_i2c_cmd);
}
