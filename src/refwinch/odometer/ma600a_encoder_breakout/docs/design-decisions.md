# Design decisions — v0.1

## D1 — Sensor: MA600A
**Variant:** buildup + no-buildup.

Reason: native ABZ, 1–4096 PPR, 10 mT functional field floor, and explicit side-shaft/off-axis support. This is the strongest fit for the RefWinch odometer's orbiting magnet geometry.

## D2 — No MCU
The encoder is a sensor board, not a smart peripheral. Default MA600A configuration already supplies quadrature. An MCU would add cost, firmware, boot behavior and another failure mode without solving a required function.

## D3 — 5 V input, local 3.3 V LDO
MA600A supply is 3.0–3.6 V. Use MP20056GJ-33, following the same regulator family used by the Chinese reference module. It is active, low-noise, and the TSOT23-5 fixed-3.3 V part needs only input/output capacitors.

## D4 — JST-GH 6-pin board connector
JST-GH is keyed/locking and proven in small robotics boards. The board connector does not attempt to mate physically with CLN17 V3. A cable maps between them, preventing our PCB from depending on a still-changing controller connector.

Pin order: GND, +5V, A, B, Z, reserved.

## D5 — SPI only on test pads
Normal users only need power + ABZ. Keep `/CS`, `SCLK`, `COPI`, and `CIPO` on production/programming pads. This permits PPR, zero, off-axis compensation and calibration to be stored in NVM without adding a second user connector.

## D6 — 512 PPR default for first article
Do not make production programming a prerequisite for the first PCB. Factory default is 512 pulses/rev = 2048 edges/rev. After physical testing, choose whether RefWinch standardizes on 512, 1024 or another PPR and program NVM during production test.

## D7 — Magnetic keepout dominates placement
Sensor center at board tip. No passive components within 5 mm; target >=6 mm. No mounting screw or connector metal near the sensing point. Minimize copper near the sensor and avoid a ground pour beneath/around the sensing tip except essential connections.

## D8 — Two-layer, single-sided assembly
2-layer FR-4, 1.6 mm, all components on top. This keeps manufacturing cheap and lets PCBWay/JLCPCB assemble the board in one pass.

## D9 — No ESD/line-driver components in v0.1
The first article is deliberately minimal. If cable tests show ringing, EMI or ESD problems, add output damping/protection based on measurements rather than pre-emptively adding parts near the magnetic sensor.
