/**********************************************************************
 *      Author: tstern
 *
 *	Misfit Tech invests time and resources providing this open source code,
 *	please support Misfit Tech and open-source hardware by purchasing
 *	products from Misfit Tech, www.misifittech.net!
 *
 *	Written by Trampas Stern  for Misfit Tech.
 *	BSD license, check license.txt for more information
 *	All text above, must be included in any redistribution
 *********************************************************************/
#include "nonvolatile.h"
#include "Flash.h"  //thanks to Kent Larsen for pointing out the lower case error
#include <Arduino.h>




//we use this so we can hard code calibration table
// be sure to set the last word as status flag
// this save time calibrating each time we do a code build
#ifdef NZS_FAST_CAL
__attribute__((__aligned__(FLASH_ROW_SIZE))) const uint16_t NVM_flash[16767]={  //allocates 33280 bytes
#else
__attribute__((__aligned__(FLASH_ROW_SIZE))) const uint16_t NVM_flash[256]={  //allocates 512 bytes
#endif
//35791,36134,36471,36788,37122,37463,37801,38118,38451,38791,39127,39447,39778,40121,40457,40783,41114,41459,41797,42120,42455,42801,43140,43465,43803,44151,44493,44818,45156,45506,45851,46178,46519,46869,47215,47542,47886,48236,48582,48910,49252,49605,49947,50272,50615,50963,51303,51631,51968,52316,52652,52974,53313,53654,53989,54307,54642,54980,55314,55630,55959,56299,56633,56946,57273,57615,57948,58259,58585,58926,59261,59575,59901,60242,60574,60888,61217,61558,61892,62208,62538,62878,63213,63528,63855,64195,64526,64844,65169,65507,304,618,941,1278,1609,1918,2238,2574,2901,3208,3529,3860,4188,4491,4810,5143,5463,5770,6089,6415,6737,7044,7359,7688,8009,8313,8629,8955,9276,9583,9898,10223,10544,10849,11163,11485,11806,12108,12423,12746,13066,13368,13680,14005,14323,14621,14935,15259,15576,15876,16189,16513,16827,17133,17445,17771,18088,18393,18709,19031,19352,19656,19976,20304,20627,20933,21254,21585,21908,22219,22540,22873,23200,23510,23835,24172,24502,24813,25141,25479,25810,26125,26454,26797,27130,27447,27777,28122,28456,28777,29110,29456,29792,30114,30449,30790,31131,31453,31786,32131,32471,32793,33127,33472,33809,34129,34462,34806,35143,35464,

			0xFFFF
};



static_assert (sizeof(nvm_t)<sizeof(NVM_flash), "nvm_t structure larger than allocated memory");




//FLASH_ALLOCATE(NVM_flash, sizeof(nvm_t));


bool nvmWriteCalTable(void *ptrData, uint32_t size)
{
	bool x=true;
	flashWrite(&NVM->CalibrationTable,ptrData,size);
	return true;
}

bool nvmWrite_sPID(float Kp, float Ki, float Kd)
{
	PIDparams_t pid;

	pid.Kp=Kp;
	pid.Ki=Ki;
	pid.Kd=Kd;
	pid.parametersVaild=true;

	flashWrite((void *)&NVM->sPID,&pid,sizeof(pid));
	return true;
}

bool nvmWrite_vPID(float Kp, float Ki, float Kd)
{
	PIDparams_t pid;

	pid.Kp=Kp;
	pid.Ki=Ki;
	pid.Kd=Kd;
	pid.parametersVaild=true;

	flashWrite((void *)&NVM->vPID,&pid,sizeof(pid));
	return true;
}

bool nvmWrite_pPID(float Kp, float Ki, float Kd)
{
	PIDparams_t pid;

	pid.Kp=Kp;
	pid.Ki=Ki;
	pid.Kd=Kd;
	pid.parametersVaild=true;

	flashWrite((void *)&NVM->pPID,&pid,sizeof(pid));
	return true;
}

bool nvmWriteSystemParms(SystemParams_t &systemParams)
{
	systemParams.parametersVaild=true;

	flashWrite((void *)&NVM->SystemParams,&systemParams,sizeof(systemParams));
	return true;
}

bool nvmWriteMotorParms(MotorParams_t &motorParams)
{
	motorParams.parametersVaild=true;

	flashWrite((void *)&NVM->motorParams,&motorParams,sizeof(motorParams));
	return true;
}

#ifdef HP_I2C
bool nvmWriteNetworkingParms(NetworkingParams_t &networkingParams)
{
	networkingParams.parametersVaild=true;

	flashWrite((void *)&NVM->networkingParams, &networkingParams, sizeof(networkingParams));
	return true;
}
#endif

bool nvmErase(void)
{
	bool data=false;
	uint16_t cs=0;

	flashWrite((void *)&NVM->CalibrationTable.status,&data,sizeof(data));
	flashWrite((void *)&NVM->sPID.parametersVaild ,&data,sizeof(data));
	flashWrite((void *)&NVM->vPID.parametersVaild ,&data,sizeof(data));
	flashWrite((void *)&NVM->pPID.parametersVaild ,&data,sizeof(data));
	flashWrite((void *)&NVM->motorParams.parametersVaild ,&data,sizeof(data));
	flashWrite((void *)&NVM->SystemParams.parametersVaild ,&data,sizeof(data));
#ifdef NZS_FAST_CAL
	flashWrite((void *)&NVM->FastCal.checkSum,&cs,sizeof(cs));
#endif
#ifdef HP_I2C
	flashWrite((void *)&NVM->networkingParams.parametersVaild ,&data,sizeof(data));
#endif
}

