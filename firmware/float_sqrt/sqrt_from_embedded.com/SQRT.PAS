Listing 1

PROGRAM Sqrt0;

{ A variant record to let us get to the exponent }
TYPE
   fp_record =  RECORD
      CASE boolean of
         true: (r: real);
         false:(n: array[1..6] of byte);
      END;

VAR Guess: fp_record;
    x, e, Root: real;
    i: integer;            { To count the iterations }

BEGIN
   ReadLn(x);
   Root := Sqrt(x);         { To give us something to compare to }
   WITH Guess DO BEGIN
      r := x;
      n[1] := $81 + (n[1] - $81) div 2;
      i := 1;
      REPEAT               { The iteration loop }
         e := (r - x/r)/2.0;
         r := r - e;
         WriteLn(i, ' ', r, ' ', abs(r - Root));
         Inc(i);
      UNTIL Abs(e/r) <= 1.0e-12;         { The stopping criterion }
   END;
ReadLn;                      { So Turbo will show us the output! }
END.

---------------------------------------------------------------------- 
Listing 2 

PROGRAM Sqrt1;

VAR r, x, e, Root: real;
    i: integer;
BEGIN
   ReadLn(x);
   Root := Sqrt(x);
   r := 0.840896415;
   i := 1;
   REPEAT
      e := (r - x/r)/2.0;
      r := r - e;
      WriteLn(i, ' ', r, ' ', Abs(r - Root));
      Inc(i);
      UNTIL Abs(e/r) <= 1.0e-12;
ReadLn;
END.
 
---------------------------------------------------------------------- 
Listing 3

{ Pascal Template for Floating Point Square Root }

FUNCTION Root(x: real): real;

CONST A = 0.41731942;      { Magic numbers for trial value }
      B = 0.590178532;

TYPE                        { Variant record to adjust exponent}
   FP_Record =  record
      CASE boolean OF
         true: (r: real);
         false:(n: array[1..6] of byte);
      END;

VAR Trial: FP_Record;      { Trial Solution }
    Exp: byte;               { Exponent to play with }
BEGIN

{ First, take care of special cases }

   IF x < 0.0 THEN BEGIN
      WriteLn(^G, 'Error: Square root of negative number.');
      Halt;
      END
   ELSE IF x = 0.0 THEN
      Root := 0.0
   ELSE    WITH Trial DO BEGIN

{ Get x so we can play with its exponent}

      r := x;
      Exp := n[1];

{ Force x to be in the range 0.5 .. 1.0 }

      n[1] := $80;

{ Compute trial solution via linear approximation }

      r := A + B*r;
      n[1] := $40 + Exp div 2;
      IF Odd(Exp) THEN
         r := 1.414213562*r;

{ Now, do three successive Newton iterations
   (for higher speed, leave out one or more)   }

      r := (x/r + r)/2.0;
      r := (x/r + r)/2.0;
      r := (x/r + r)/2.0;

{ And return the result }

      Root := r;
   END;
END;
 
---------------------------------------------------------------------- 
Listing 4

{ Pascal Template for Integer Square Root }

FUNCTION Root(x: integer): integer;


TYPE                        { Variant record to permit shifting }
   Long =  record
      CASE boolean OF
         true: (L: LongInt);
         false:(Lo, Hi: Integer);
      END;

VAR Arg: Long;             { The 'accumulator' }
    i, r, Temp: integer;   { r is the root     }
BEGIN

{ First, take care of special cases }

   IF x < 0 THEN BEGIN
      WriteLn(^G, 'Error: Square root of negative number.');
      Halt;
      END
   ELSE IF x = 0 THEN
      Root := 0
   ELSE WITH Arg DO BEGIN

{ Initialize L and r }

      L := x;
      r := 0;

{ Begin computation loop }

      for i := 1 to 8 do begin   
         r := r SHL 1;      { Shift both registers }            
         L := L SHL 2;

{ Check the range of Hi.  Reduce if we can }

         Temp := 2 * r + 1;
         IF Hi >= Temp THEN BEGIN
            Hi := Hi - Temp;
            r := r + 1;
         END;
      END;                  

{ At end of loop, answer resides in r }

      Root := r;                  
   END;
END;
