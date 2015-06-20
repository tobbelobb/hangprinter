/* Copyright (c) 2002  Michael Stumpf  <mistumpf@de.pepperl-fuchs.com>
   Copyright (c) 2006  Dmitry Xmelkov
   All rights reserved.

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are met:

   * Redistributions of source code must retain the above copyright
     notice, this list of conditions and the following disclaimer.
   * Redistributions in binary form must reproduce the above copyright
     notice, this list of conditions and the following disclaimer in
     the documentation and/or other materials provided with the
     distribution.
   * Neither the name of the copyright holders nor the names of
     contributors may be used to endorse or promote products derived
     from this software without specific prior written permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
   ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
   POSSIBILITY OF SUCH DAMAGE. */

/* $Id: hypot.S 1173 2007-01-14 15:04:40Z dmix $ */

#include "fp32def.h"
#include "asmdef.h"
#include "ntz.h"

/* double hypot (double x, double y);
     The hypot() function returns `sqrt (x*x + y*y)'. This is the length
     of the hypotenuse of a right triangle with sides of length x and y,
     or the distance of the point (x, y) from the origin. Using this
     function instead of the direct formula is wise, since the error is
     much smaller. No underflow with small x and y. No overflow if
     result is in range.

   Notes:
     * Combination of NaN and Inf args is valid (like Glibc). Result: Inf.
 */

#define	EDIFF_2BIG	13	/* such exponents difference is too big	*/
/* Next 2 constants are without 127-displacement.	*/
#define EXP_2BIG	63	/* exponent is too big, scaling needed	*/
#define EXP_2SMALL	(-63)	/* exponent is too small, scaling need.	*/
/* Next 2 values are positive both.
   SCALE_BIG is increased by 1 to provide '-SCALE_SMALL & SCALE_BIG':
   this is used below.	*/
#define SCALE_BIG	(126 - EXP_2BIG + 2)
#define SCALE_SMALL	(149 + EXP_2SMALL + 1)

/* Assert: no overlap	*/
#if	EXP_2BIG - SCALE_BIG - (EDIFF_2BIG - 1) <= EXP_2SMALL	\
     || EXP_2SMALL + SCALE_SMALL + (EDIFF_2BIG - 1) >= EXP_2BIG
# error
#endif

#define	exp_lo	r20		/* ldexp (float x, int exp);		*/
#define	exp_hi	r21

#define	rC0	r14
#define	rC1	r15
#define	rC2	r16
#define	rC3	r17

FUNCTION hypot

.L_nf:	rcall	_U(__fp_pscA)
	breq	1f		; hypot(Inf, *) --> Inf
	rcall	_U(__fp_pscB)
	breq	1f		; hypot(*, Inf) --> Inf
	rjmp	_U(__fp_nan)	; NaN and finite, or both NaN
1:	rjmp	_U(__fp_inf)	; T is 0 after __fp_split3()

.L_retB:
	X_movw	rA0, rB0
	X_movw	rA2, rB2
.L_retA:
	rjmp	_U(__fp_mpack)

ENTRY hypot
  ; clear signs
	andi	rA3, 0x7f
	andi	rB3, 0x7f
  ; split and check args
	rcall	_U(__fp_split3)
	brcs	.L_nf
	tst	rA3
	breq	.L_retB
	tst	rB3
	breq	.L_retA
  ; sort exponents
	clr	ZH		; scale factor
	cp	rA3, rB3
	brsh	3f

  ; exponent A < exponent B
  ; is an A too small ?
	mov	ZL, rB3
	sub	ZL, rA3
	cpi	ZL, EDIFF_2BIG
	brsh	.L_retB		; the A is too small
  ; is it needed to decrease scale ?
	cpi	rB3, 127 + EXP_2BIG
	brlo	2f
	ldi	ZH, SCALE_BIG		; positive for 'sub' instruction
	rjmp	.L_scale
  ; is it needed to increase scale ?
2:	cpi	rA3, 127 + EXP_2SMALL
	brsh	.L_sc0
	rjmp	.L_right

  ; exponent A >= exponent B
  ; is B too small?
3:	mov	ZL, rA3
	sub	ZL, rB3
	cpi	ZL, EDIFF_2BIG
	brsh	.L_retA
  ; is it needed to decrease scale ?
	cpi	rA3, 127 + EXP_2BIG
	brlo	4f
	ldi	ZH, SCALE_BIG		; positive for 'sub' instruction
	rjmp	.L_scale
  ; is it needed to increase scale ?
4:	cpi	rB3, 127 + EXP_2SMALL
	brsh	.L_sc0
.L_right:			; 'shift to right' entry
	ldi	ZH, -(SCALE_SMALL)
  ; normalize A, if needed
	tst	rA2
	brmi	6f
5:	dec	rA3
	lsl	rA0
	rol	rA1
	rol	rA2
	brpl	5b
  ; normalize B, if needed
6:	tst	rB2
	brmi	8f
7:	dec	rB3
	lsl	rB0
	rol	rB1
	rol	rB2
	brpl	7b
8:
  ; scale and save the scale factor
.L_scale:
	sub	rA3, ZH
	sub	rB3, ZH
.L_sc0:				; `scale is 0' entry
	push	ZH

  ; calculate sqrt(A*A + B*B)
#if  defined(__AVR_HAVE_MOVW__) && __AVR_HAVE_MOVW__
	push	rC3
	push	rC2
	push	rC1
	push	rC0
	
	movw	rC0, rB0
	movw	rC2, rB2
	
	clr	rAE
	mov	rBE, rAE
	movw	rB0, rA0
	movw	rB2, rA2
	rcall	_U(__mulsf3_pse)
	
	movw	rB0, rC0
	movw	rB2, rC2
	
	push	rAE
	movw	rC0, rA0
	movw	rC2, rA2

	clr	rBE
	mov	rAE, rBE
	movw	rA0, rB0
	movw	rA2, rB2
	rcall	_U(__mulsf3_pse)

	pop	rBE	
	movw	rB0, rC0
	movw	rB2, rC2
	
	pop	rC0
	pop	rC1
	pop	rC2
	pop	rC3
	
#else	/* to __AVR_HAVE_MOVW__	*/
	push	rB3
	push	rB2
	push	rB1
	push	rB0
	
	clr	rAE
	mov	rBE, rAE
	mov	rB0, rA0
	mov	rB1, rA1
	mov	rB2, rA2
	mov	rB3, rA3
	rcall	_U(__mulsf3_pse)
	
	pop	rB0
	pop	rB1
	pop	rB2
	pop	rB3

	push	rA3
	push	rA2
	push	rA1
	push	rA0
	push	rAE
	
	clr	rBE
	mov	rAE, rBE
	mov	rA0, rB0
	mov	rA1, rB1
	mov	rA2, rB2
	mov	rA3, rB3
	rcall	_U(__mulsf3_pse)
	
	pop	rBE
	pop	rB0
	pop	rB1
	pop	rB2
	pop	rB3
#endif	/* ! __AVR_HAVE_MOVW__	*/
	
	rcall	_U(__addsf3x)
	rcall	_U(__fp_round)
	rcall	_U(sqrt)

  ; restore a scale
#if (-SCALE_SMALL & SCALE_BIG) == 0
# error
#endif
	pop	exp_lo
	sbrs	exp_lo, ntz(-SCALE_SMALL & SCALE_BIG)
	ret			; scale == 0
	clr	exp_hi
	sbrc	exp_lo, 7
	com	exp_hi
	rjmp	_U(ldexp)
ENDFUNC
