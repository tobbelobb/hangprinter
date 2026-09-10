# MA600A programmer and commissioning fixture

The breakout works at its factory defaults without programming. This directory contains a small service tool for changing the MA600A configuration after assembly, especially bias-current trimming (BCT) for a side-shaft magnet.

The programmer consists of:

- an Arduino-compatible board running [`ma600a_programmer/ma600a_programmer.ino`](ma600a_programmer/ma600a_programmer.ino);
- six spring probes connected to TP1 through TP6;
- direct SPI wiring for a 3.3 V controller or a classic ATmega328P Uno/Nano;
- the optional printable [`pogo-fixture/ma600a_pogo_guide.stl`](pogo-fixture/ma600a_pogo_guide.stl), with editable [`OpenSCAD source`](pogo-fixture/ma600a_pogo_guide.scad).

TP7 is deliberately absent from the programmer connector. It is the breakout's regulated 3.3 V rail and is for measurement only.

## Easiest controller choices

A 3.3 V Arduino-compatible board is simplest: Raspberry Pi Pico/RP2040, Arduino Zero, MKR, Nano 33, Due, ESP32, or a similar board. Power the breakout from 5 V and connect its SPI pins directly to 3.3 V GPIO.

A classic 5 V Uno or Nano using an ATmega328P can connect directly. The MA600A specifies a 2.5–5.5 V input-high range, and 3.3 V from CIPO exceeds the ATmega328P's 3.0 V minimum input-high level at 5 V supply. Optional 1 kΩ series resistors in `/CS`, SCLK and COPI limit current if a probe slips without disturbing 100 kHz operation.

Do not assume every 5 V Arduino is equivalent. In particular, check another MCU's guaranteed input-high threshold before relying on a 3.3 V CIPO signal. Use a proper bidirectional logic interface or choose a 3.3 V controller if its threshold is too high. The Uno's `3.3V` pin does not change its GPIO voltage.

## Parts

- one Arduino-compatible controller;
- six P50-B1 or similar spring probes with tips no larger than the 1 mm pads;
- perfboard, wire and a connector between the probe head and Arduino;
- optionally, three 1 kΩ series resistors for an Uno/Nano's `/CS`, SCLK and COPI wires;
- an optional printed probe guide and a small clamp or elastic band.

Measure the body of the probes you buy before printing. `pogo_hole_d` in the OpenSCAD file is the finished-hole target and defaults to 0.80 mm. Print a short hole-size coupon first if the printer's dimensional error is unknown.

## Wiring

The sketch defaults to the hardware SPI pins of the selected Arduino core and uses pin D10 for chip select.

| Breakout pad | Signal | 3.3 V controller | Classic Uno/Nano |
|---|---|---|---|
| TP1 | +5V | USB/VBUS 5 V | 5V |
| TP2 | GND | GND | GND |
| TP3 | /CS | D10 or configured CS | D10, optionally through 1 kΩ |
| TP4 | SCLK | SCK | D13, optionally through 1 kΩ |
| TP5 | COPI | MOSI/COPI | D11, optionally through 1 kΩ |
| TP6 | CIPO | MISO/CIPO | D12 directly |
| TP7 | +3V3 | **leave disconnected** | **leave disconnected** |

CIPO is driven by the MA600A at 3.3 V and connects directly to D12 on a classic ATmega328P Uno/Nano. No divider belongs on CIPO.

Do not connect an external supply to TP7. Do not press signal probes onto an unpowered breakout. Keep the grounds connected before making the remaining contacts.

### Probe order and geometry

Viewed from the component side, TP1 through TP5 form a vertical line at 2 mm pitch. TP6 is 2 mm to the right of TP5.

```text
TP1  +5V   o
TP2  GND   o
TP3  /CS   o
TP4  SCLK  o
TP5  COPI  o---o  TP6 CIPO
```

The printable guide uses this exact pattern. Its triangular corner notch identifies TP1. The guide only holds the probes at the correct spacing; align it to the labeled board pads and hold it with a clamp, elastic band, or a custom fixture body suited to the probes you buy.

## Load and use the sketch

1. Open `ma600a_programmer.ino` in the Arduino IDE.
2. Select the controller board and port, then upload it.
3. Disconnect the probe head, arrange the wiring, and check for shorts.
4. Connect GND, then +5 V, then place the four signal probes.
5. Open Serial Monitor at **115200 baud** with newline line endings.
6. Type `config`. Factory BCT should read 0, and factory PPR should read 512.
7. Type `angle` and rotate the magnet. A changing 16-bit value confirms the link.

The sketch uses SPI mode 0, MSB first, at 100 kHz. Register writes are volatile until `save` is explicitly issued.

Useful commands:

```text
help
angle
stream 200 20
config
read 0x02
write 0x0d 0x08
bct x 129
bct y 129
bct off
calc-bct 2.0
ppr 512
zero 20.0
direction cw
save 0 CONFIRM
restore
```

`stream 200 20` prints 200 CSV samples 20 ms apart. `save 0 CONFIRM` stores BCT, zero, direction, PPR and the other block-0 settings to NVM. It deliberately takes about 650 ms. Use `save 1 CONFIRM` only after deliberately writing the 32-point correction table at registers `0x20` through `0x3f`.

## BCT commissioning for the side-shaft installation

BCT compensates the unequal radial and tangential field amplitudes produced by side-shaft geometry. Perform it on the actual magnet, shaft, air gap and nearby steelwork. Calibrate BCT before changing zero angle or rotation direction.

1. Mount the breakout and magnet in their final relative positions.
2. Run `bct off`. This changes RAM only.
3. Rotate the shaft through one mechanical revolution in equal known increments. A 3D-printer stepper fixture is adequate for finding the large double-sine error; use full steps or a geared output because microstep position is not a precision angular reference.
4. At each reference angle, record the MA600A angle. Remove the constant angular offset, unwrap the readings through 360°, then calculate `sensor angle - mechanical angle`.
5. If the radial-to-tangential field ratio `k` is known, run `calc-bct k`. The datasheet formula is `round(258 × (1 - 1/k))`. Examples: k=1.5 → 86, k=2 → 129, k=3 → 172.
6. Trim the axis with the larger field amplitude. For the common geometry where the sensor X axis is radial, start with `bct x value`; if the package is rotated by 90°, start with Y. If orientation is uncertain, measure both X and Y candidates and keep the one that reduces the double-sine error.
7. Repeat the angle sweep and adjust the BCT value to minimize peak and RMS angle error. Values above 200 are more temperature-sensitive according to the datasheet.
8. Power-cycle once before committing to prove that the trial value was volatile. Reapply the chosen setting, repeat the sweep, then issue `save 0 CONFIRM` once.
9. Power-cycle again and run `config` to verify that the setting restored from NVM.
10. Only after BCT is final, set zero, direction, PPR, or a 32-point correction table.

An empirical sweep is often easier than measuring `B_RAD` and `B_TAN`: try X and Y with coarse BCT steps such as 0, 32, 64, …, 192, then refine around the best value. Never enable both X and Y; the datasheet says equal trimming of both axes has the same linearity effect as BCT=0.

## Register and persistence notes

The commands implement the MA600A Rev. 1.0 protocol:

- register read: `0xD200 | address`, followed by `0x0000`;
- register write: `0xEA54`, `(address << 8) | value`, followed by `0x0000`;
- store block 0 or 1: `0xEA55`, then `0xEA00 | block`;
- restore all blocks: `0xEA56`.

The sketch waits longer than the datasheet's 600 ms minimum NVM-store time and 240 µs minimum restore time. Avoid repeatedly saving trial values; NVM should be written once after commissioning has converged.

Factory defaults used by this board are:

- IO2 = A;
- IO4 = B;
- IO3 = Z;
- 512 pulses/rev, or 2048 quadrature edges/rev;
- BCT disabled.
