# Programming / production-test interface

Normal operation does not require programming.

Factory defaults provide:

- IO2 = A
- IO4 = B
- IO3 = Z
- 512 pulses/rev (2048 edges/rev)

Expose these pogo pads:

1. +5V
2. GND
3. /CS
4. SCLK
5. COPI
6. CIPO
7. +3V3 (measurement only)

Use SPI to change PPR, zero angle, side-shaft compensation or the user correction table, then store the relevant register block(s) to NVM.

A production programming script should be added only after the mechanical odometer resolution requirement is frozen.
