/*
Copyright (C) Trampas Stern  name of author

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

#include "command.h"
#include <string.h>


#define ASCII_BACKSPACE 0x08
#define ASCII_ESC 0x1B
#define ASCII_UP_ARROW 0x9b
//const char CMD_ANSI_UP[]= {ASCII_ESC,'[','A',0};

int strcicmp(char const *a, char const *b)
{
    for (;; a++, b++) {
        int d = tolower(*a) - tolower(*b);
        if (d != 0 || !*a)
            return d;
    }
}

int CommandInit(sCmdUart *ptrUart, uint8_t (*kbhit)(void), uint8_t (*getch)(void),uint8_t (*putch)(char data),uint8_t (*puts)(uint8_t *buffer, uint8_t size) )
{
	ptrUart->kbhit=kbhit;
	ptrUart->getch=getch;
	ptrUart->putch=putch;
	ptrUart->puts=puts;
	ptrUart->histIndex=0;
	ptrUart->buffIndex=0;
	return 0;
}

#ifdef PGM_P //check and see if the PGM_P is defined for the AVR

int CommandPrintf(sCmdUart *ptrUart, const char *fmt, ...)
{
    int ret=0;
	char vastr[MAX_STRING]={0};
	//char str[MAX_STRING]={0};
	char *ptr;
    va_list ap;

    //LOG("Command printf");
    memset(vastr,0,MAX_STRING);
    va_start(ap,fmt);
    ret=vsprintf(vastr,(const char *)fmt,ap);
    //ret=sprintf(vastr,"%s\r\n",str);
    //LOG("%s",vastr);
    if (ptrUart->puts!=NULL)
    {
    	return ptrUart->puts((uint8_t *)vastr, (uint8_t)ret);
    }

    if (ptrUart->putch!=NULL)
    {
		ptr=vastr;
		while(*ptr)
		{
			ptrUart->putch(*ptr++);
		}

		return ret;
    }
    return 0;
}


#else
int CommandPrintf(sCmdUart *ptrUart, char *fmt, ...)
{
    int ret=0;
	char vastr[MAX_STRING]={0};
	char *ptr;
    va_list ap;


    memset(vastr,0,MAX_STRING);
    va_start(ap,fmt);
    ret=vsprintf(vastr,(char *)fmt,ap);
    if (ptrUart->puts!=NULL)
    {
    	return ptrUart->puts((uint8_t *)vastr, (uint8_t)ret);
    }

    if (ptrUart->putch!=NULL)
    {
		ptr=vastr;
		while(*ptr)
		{
			ptrUart->putch(*ptr++);
		}

		return ret;
    }
    return 0;
}
#endif


// the delimiter is command/parameter delimiter
// by default a ' '0x20 is used but for the TDR with GUI a ':' was preferred, not sure why
// set to ' '/0x20 if you want normal command parsing, like DOS
unsigned int CommandParse(sCmdUart *ptrUart,sCommand *ptrCmds, char *str, char delimitor )
{
	char *ptr;
	char *ptr2;
	unsigned int i;
	//char cmd[MAX_STRING];
	char buff[MAX_CMD_LENGTH];
	char argv[MAX_ARGS][MAX_ARG_LENGTH];
	char *ptrArgv[MAX_ARGS];
	unsigned int numArgs;
	int emptyArg=0;

	sCommand cmd_list;


	while (*str==0x20 || *str=='\n' || *str=='\r' || *str=='\t') str++;
	//first we need find command and arguments
	ptr=strchr(str,delimitor); //find first char

	//LOG("2parsing %s",str);


	if (ptr==0)
	{
		//we have two options, frist whole thing is command
		//second bad command
		if(strlen(str)>0)
			ptr=str+strlen(str);
		else
			return 0; //bad command
	}

	//copy string to command buffer.
	i=0;
	ptr2=str;
	while(ptr!=0 && ptr!=ptr2 && i<(MAX_CMD_LENGTH-1))
	{
		//if (*ptr2!='\n' && *ptr2!='\r') //do not include newlines
		{
			buff[i++]=*ptr2;
		}
		ptr2++;
	}
	buff[i]=0;

	//now buff contains the command let's get the args
	numArgs=0;
	while(*ptr!=0 && (*ptr==' ' || *ptr==delimitor))
		ptr++; //increment pointer past ' '
	if (*ptr!=0)
	{
		if (*ptr==34) // " char
		{
			ptr++;
			ptr2=strchr(ptr,34); //find match
		} else if (*ptr==39) // 'char
		{
			ptr++;
			ptr2=strchr(ptr,39); //find match
		} else
		{
			ptr2=strchr(ptr,delimitor);
		}
		if (ptr2==0)
		{
			//we have two options, frist whole thing is command
			//second bad command
			//LOG("strlen ptr is %d",strlen(ptr));
			if(strlen(ptr)>0)
				ptr2=ptr+strlen(ptr);
		}
		emptyArg=0;
		while((ptr2!=0 && numArgs<MAX_ARGS) || emptyArg==1)
		{
			int j;
			emptyArg=0;
			j=0;
			//LOG("arg %s",ptr);
			while (ptr2!=ptr && j<(MAX_ARG_LENGTH-1) && ptr2!=0)
			{
				argv[numArgs][j++]=*ptr++;
			}
			argv[numArgs][j++]=0;
			numArgs++;
			ptr2=0;
			if (*ptr!=0)
			{
				if (*ptr==34 || *ptr==39) ptr++;
				if (*ptr==delimitor && strlen(ptr)==1)
				{
					//LOG("Empty arg");
					emptyArg=1;
				}
				while(*ptr!=0 && (*ptr==' ' || *ptr==delimitor))//p || *ptr==34 || *ptr==39))
					ptr++; //increment pointer past ' '
				if (*ptr==34) // " char
				{
					ptr++;
					ptr2=strchr(ptr,34); //find match
				} else if (*ptr==39) // 'char
				{
					ptr++;
					ptr2=strchr(ptr,39); //find match
				} else
				{
					ptr2=strchr(ptr,delimitor);
				}
				if (ptr2==0)
				{
					//we have two options, frist whole thing is command
					//second bad command
					if(strlen(ptr)>0)
						ptr2=ptr+strlen(ptr);
				}
			}
		}
	}

	for(i=0; i<MAX_ARGS; i++)
	{
		ptrArgv[i]=argv[i];
	}

	//now let's parse the command
	i=0;
	memcpy(&cmd_list, &ptrCmds[i], sizeof(sCommand));


	//LOG("command is %s %d",buff,numArgs);

	while(cmd_list.function!=0)
	{
		/*char str[20];
		strcpy_P(str,cmd_list.name);
		LOG("checkign '%s' to '%s'",buff,str);
		LOG("comapre is %d",strcmp_P(buff,cmd_list.name));
*/

		//memcpy_P(&p, cmd_list.name, sizeof(PGM_P));
#ifdef PGM_P //check and see if the PGM_P is defined for the AVR
		if (strlen(buff)==strlen_P(cmd_list.name))
		{
			if (strcicmp(buff,cmd_list.name)==0) //ignore device ID
#else
		if (strlen(buff)==strlen(cmd_list.name))
		{
			if (strcicmp(buff,cmd_list.name)==0) //ignore device ID
#endif
			{
				//LOG("calling function");
				//return 1;
				return (*cmd_list.function)(ptrUart,numArgs,ptrArgv);
			}
		}
		i=i+1;
		memcpy(&cmd_list, &ptrCmds[i], sizeof(sCommand));
	}
	CommandPrintf(ptrUart,PSTR("Unknown command (try 'help')\n\r"));
	return -1;
}

//This function will process commands from the UART
int CommandProcess(sCmdUart *ptrUart,sCommand *ptrCmds, char delimitor, char *cmdPrompt)
{
	if(ptrUart->kbhit())
	{
		ptrUart->data=ptrUart->getch();

		//echo the data
		ptrUart->putch(ptrUart->data);

		//if the data is the CR we need to process buffer
		if (ptrUart->data==0x0D)
		{
			ptrUart->putch(0x0A);
			if (strlen(ptrUart->buffer)>0)
			{
				if (ptrUart->lastChar!=ASCII_UP_ARROW)
				{
					strcpy(ptrUart->bufferHist[ptrUart->histIndex],ptrUart->buffer);
					ptrUart->histIndex=(ptrUart->histIndex+1) % CMD_HISTORY;
				}
				CommandParse(ptrUart,ptrCmds,ptrUart->buffer,delimitor);
			}

			CommandPrintf(ptrUart,PSTR("\n\r%s"),cmdPrompt);
			ptrUart->buffIndex=0;
			ptrUart->buffer[ptrUart->buffIndex]=0;
		}

		if (ptrUart->data==ASCII_BACKSPACE) //backspace
		{
			if (ptrUart->buffIndex>0)
			{
				ptrUart->buffIndex--;
				ptrUart->buffer[ptrUart->buffIndex]='\0';
				//Echo the backspace
				ptrUart->putch(' ');
				ptrUart->putch(ASCII_BACKSPACE);
			}
		}else if (ptrUart->data != 0x0A && ptrUart->data !=0x0D && ptrUart->data<127)
		{
			ptrUart->buffer[ptrUart->buffIndex++]=ptrUart->data;
			ptrUart->buffer[ptrUart->buffIndex]=0;
		}
		if (ptrUart->buffIndex>=(MAX_CMD_LENGTH-1))
		{
			CommandPrintf(ptrUart,PSTR("\n\rERROR: Command buffer overflow\n\r"));\
			ERROR("Command buffer overflow");
			ptrUart->buffIndex=0;
			ptrUart->buffer[0]=0;
			CommandPrintf(ptrUart,PSTR("\n\r%s"),cmdPrompt);
		}
	}


	if (strstr(ptrUart->buffer,ANSI_UP)) //up arrow
	{
		uint8_t i;

		CommandPrintf(ptrUart,PSTR("\n\r%s"),cmdPrompt);
		i=CMD_HISTORY-1;
		if (ptrUart->histIndex>0)
		{
			i=ptrUart->histIndex-1;
		}
		if (strlen(ptrUart->bufferHist[i])>0)
		{
			strcpy(ptrUart->buffer,ptrUart->bufferHist[i]);
			ptrUart->buffIndex=strlen(ptrUart->buffer);
			CommandPrintf(ptrUart,PSTR("%s"),ptrUart->buffer);
		}else
		{
			ptrUart->buffIndex=0;
			ptrUart->buffer[0]=0;
		}
		ptrUart->data=ASCII_UP_ARROW;
	}


	ptrUart->lastChar=ptrUart->data;
	return 0;
}

