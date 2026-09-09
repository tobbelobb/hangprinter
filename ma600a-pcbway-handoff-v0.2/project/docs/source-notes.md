# Source notes

## MA600A — Monolithic Power Systems

Relevant facts from MA600A Rev. 1.0 (2025-06-05):

- 3.3 V supply; 7.5 mA typical combined AVDD + DVDD current.
- Functional magnetic field: 10–150 mT; optimal linearity: 20–80 mT.
- End-of-shaft and side-shaft/off-axis mounting supported.
- ABZ quadrature: 1–4096 pulses/rev.
- Factory default: 512 pulses/rev.
- Default I/O matrix: IO2=A, IO4=B, IO3=Z.
- TEST must connect to GND.
- COPI and SCLK have internal pulldowns; /CS has internal pullup.
- AVDD bypass: 1 uF. DVDD bypass: 0.1 uF.
- MPS warns that a 0603 capacitor 3 mm from sensor center can add up to 0.2 degrees second-harmonic error; recommends >=5 mm distance.
- Keep high-current paths and ground away from the sensor.
- Exposed pad: no electrical connection; MPS recommends floating it to reduce mechanical stress.

Source: https://www.monolithicpower.com/en/documentview/productdocument/index/version/2/document_type/Datasheet/lang/EN/sku/MA600A

## MP20056 — Monolithic Power Systems

Relevant facts:

- `MP20056GJ-33`: fixed 3.3 V, TSOT23-5.
- VIN 2.5–5.5 V.
- Pin 1 VIN, pin 2 GND, pin 3 EN, pin 4 FB, pin 5 VOUT.
- EN may be tied to VIN and must not float.
- VIN bypass 2.2 uF; VOUT bypass 4.7 uF.
- In the fixed 3.3 V TSOT23 application, FB is not populated with an external divider.

Source: https://www.monolithicpower.com/en/documentview/productdocument/index/version/2/document_type/Datasheet/lang/en/sku/MP20056/

## Chinese reference board

`MA600A + MP20056GJ quadrature magnetic encoder module`, published on OSHWHub. Useful as evidence that this minimal architecture is practical. We are not cloning its PCB; our layout follows MPS guidance and RefWinch requirements.

Source: https://oshwhub.com/mps-core-source-square/ma600a-mp20056gj

## Westly Bouchard AS5047P board

Used only as the quality/packaging benchmark for an open hardware project: KiCad sources, README, STEP, BOM, centroid and Gerbers arranged so a user can submit to PCBWay directly.

Source: https://github.com/Westly-Bouchard/AS5047P-Board
