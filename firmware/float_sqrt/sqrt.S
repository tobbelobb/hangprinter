/* Copyright (c) 2002  Michael Stumpf  <mistumpf@de.pepperl-fuchs.com>
   Copyright (c) 2006  Dmitry Xmelkov
   Copyright (c) 2008  Ruud v Gessel
   
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

#if !defined(__AVR_TINY__)

#include "fp32def.h"
#include "asmdef.h"

/*  double sqrt (double);
    Square root function.
 */

FUNCTION sqrt

;.L_nf:	brne	.L_pk		; NaN, return as is
;	brtc	.L_pk		; sqrt(+Inf) --> +Inf
;.L_nan:	XJMP	_U(__fp_nan)
;.L_pk:	XJMP	_U(__fp_mpack)

ENTRY sqrt
ALIAS_ENTRY sqrtf
  ; split and check arg.
	XCALL	_U(__fp_splitA) ; What does __fp_splitA do? Rolls bits over so exponent is in rA3 and rB3, and mantissas are ...
;	brcs	.L_nf		; !isfinite(A)
;	tst	rA3 ; compare exponent with zero
;	breq	.L_pk		; return 0 with original sign
;	brts	.L_nan		; sqrt(negative) --> NaN
  ; exponent bias
	subi	rA3, 127 ; So now rA3 contains our exponent
	sbc	rB3, rB3	; exponent high byte. Carry flag written in exponent rB3
  ; normalize, if A is subnormal. Hangprinter will never have to do with subnormal lengths
	;sbrs	rA2, 7
	;XCALL	_U(__fp_norm2)

#define	msk0	r0
#define msk1	r1
#define msk2	rBE

	clr	msk0		; msk1=R1 already 0
	ldi	msk2, 0x60	; Initial rotation mask =	01100000.00000000.00000000
	ldi	rB2, 0xa0
	X_movw	rB0, msk0	; Initial developing root =	10100000.00000000.00000000

	subi	rA2, 0x80 ;; Why would we want to subtract highest bit here?
	lsr	rB3 ; logical shift right
	ror	rA3		; Divide exponent by 2, C==>exponent was odd
	brcc	1f		; Jump for even exponent in argument
	subi	rA2, lo8(-0x40)	; Initial remainder for odd exponent.

	; Loop for upper 23 bits
.Loop:	lsl	rA0
	rol	rA1
	rol	rA2		; Shift left remainder argument
	brcs	2f		; C --> Bit is always 1 (rA * 2 gave C)
1:	cp	rB0, rA0
	cpc	rB1, rA1
	cpc	rB2, rA2	; Does test value fit?
	brcc	3f		; NC --> nope, bit is 0
2:	sub	rA0, rB0
	sbc	rA1, rB1
	sbc	rA2, rB2	; Prepare remainder argument for next bits
	or	rB0, msk0
	or	rB1, msk1
	or	rB2, msk2	; Set developing bit to 1
3:	lsr	msk2
	ror	msk1
	ror	msk0		; Shift right mask, C --> end loop
	eor	rB0, msk0
	eor	rB1, msk1
	eor	rB2, msk2	; Shift right test bit in developing root
	brcc	.Loop		; Develop 23 bits of the sqrt

	; Loop for bit 0 and rounding
.Loop1:	lsl	rA0
	rol	rA1
	rol	rA2		; Shift left remainder argument	
	brcs	4f		; C--> Last bits always 1
	cp	rB0, rA0
	cpc	rB1, rA1
	cpc	rB2, rA2	; Test for last bit 1
	brcc	5f		; Nope, stays the same
4:	sbc	rA0, rB0	; MUST BE SBC !!
	sbc	rA1, rB1
	sbc	rA2, rB2	; Prepare remainder argument for next bit
	add	rB0, msk0
	adc	rB1, msk1
	adc	rB2, msk1	; Add 1 to result
5:	com	msk2		; ZF if second time
	brne	.Loop1		; 1 for last bit, 1 for rounding

	X_movw	rA0, rB0
	mov	rA2, rB2	; Copy to rA

	subi	rA3, lo8(-127)	; exponent bias
	lsl	rA2
	lsr	rA3
	ror	rA2
	ret
ENDFUNC

#endif /* !defined(__AVR_TINY__) */
