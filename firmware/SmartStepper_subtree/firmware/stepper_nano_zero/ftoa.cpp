
#include "board.h"
#include "ftoa.h"
/*******************************************************************
  *  FUNCTION: ftoa
  *  AUTHOR 		= 	TRAMPAS STERN
  *  FILE 		=	strio.c
  *  DATE		=   2/6/2003  4:27:14 PM
  *
  *  PARAMETERS: long,*str, int count
  *
  *  DESCRIPTION: Convets an float to string
  *			format 'f', 'E', or 'e'
  *
  *
  *  RETURNS:
  *
  * NOTE this code was found on the web and modified to actually work
  *******************************************************************/
 int ftoa (float x, char *str, char  prec, char format)
 {

 	int ie, i, k, ndig, fstyle;
 	double y;
 	char *start;

 	start=str;

 	//based on percission set number digits
 	ndig=prec+1;
 	if (prec<0)
 		ndig=7;
 	if (prec>22)
 		ndig=23;

 	fstyle = 0;	//exponent 'e'
 	if  (format == 'f' || format == 'F')
 		fstyle = 1;	//normal 'f'
 	if (format=='g' || format=='G')
 		fstyle=2;

 	ie = 0;
 	/* if x negative, write minus and reverse */
 	if ( x < 0)
 	{
 	  *str++ = '-';
 	  x = -x;
 	}

 	//if (x<0.0) then increment by 10 till betwen 1.0 and 10.0
 	if (x!=0.0)
 	{
 		while (x < 1.0)
 		{
 		  x =x* 10.0;
 		  ie--;
 		}
 	}

    	//if x>10 then let's shift it down
 	while (x >= 10.0)
 	{
 		x = x*(1.0/10.0);
 		ie++;
 	}

 	if (ABS(ie)>MAX_MANTISA)
 	{
 		if (fstyle==1)
 		{
 			fstyle=0;
 			format='e';
 			//ie=2;
 		}
 	}


 	/* in f format, number of digits is related to size */
 	if (fstyle)
 		ndig =ndig + ie;

 	if(prec==0 && ie>ndig && fstyle)
 	{
 		ndig=ie;
 	}

 	/* round. x is between 1 and 10 and ndig will be printed to
 	   right of decimal point so rounding is ... */
 	y=1;
 	for (i = 1; i < ndig; i++)	//find lest significant digit
 	  y = y *(1.0/10.0); 		//multiply by 1/10 is faster than divides

 	x = x+ y *(1.0/2.0);			//add rounding

 	/* repair rounding disasters */
 	if (x >= 10.0)
 	{
 		x = 1.0;
 		ie++;
 		ndig++;
 	}

 	//check and see if the number is less than 1.0
 	if (fstyle && ie<0)
 	{
 		*str++ = '0';
 		if (prec!=0)
 			*str++ = '.';
 		if (ndig < 0)
 			ie = ie-ndig; /* limit zeros if underflow */
 		for (i = -1; i > ie; i--)
 			*str++ = '0';
 	}

 	//for each digit
 	for (i=0; i < ndig; i++)
 	{
 		float b;
 		k = x;						//k = most significant digit
 		*str++ = k + '0';			//output the char representation
 		if (((!fstyle && i==0) || (fstyle && i==ie)) && prec!=0)
 			*str++ = '.';			//output a decimal point
 		b=(float)k;
 		//multiply by 10 before subtraction to remove
 		//errors from limited number of bits in float.
 		b=b*10.0;
 		x=x*10.0;
 		x =x - b;				//subtract k from x
 		//b=x+b;
 		//x =x* 10.0;					//get next digit
 	}

 /* now, in estyle,  put out exponent if not zero */
 	if (!fstyle && ie != 0)
 	{
 		*str++ = format;
 		if (ie < 0)		//if number has negative exponent
 		{
 			ie = -ie;
 			*str++ = '-';
 		}

 		//now we need to convert the exponent to string
 		for (k=1000; k>ie; k=k/10);		//find the decade of exponent

 		for (; k > 0; k=k/10)
 		{
 			char t;
 			t=DIV(ie,k);
 			*str++ = t + '0';
 			ie = ie -(t*k);
 		}

 	}
 	*str++ = '\0';
 	return (str-start);	//return string length
 }
