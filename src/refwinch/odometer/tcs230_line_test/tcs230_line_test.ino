// Uno R3, one TCS230 module, no external libraries.
// VCC=5V, GND=GND, OUT=D2, S0=D4, S1=D5, S2=D6, S3=D7.
// Tie OE to GND if exposed. Supply LEDs through the module, not an I/O pin.
#include <Arduino.h>
#include <util/atomic.h>

const uint8_t OUT_PIN = 2, S0_PIN = 4, S1_PIN = 5, S2_PIN = 6, S3_PIN = 7;
const uint32_t MAX_CHANNEL_US = 125000UL;
const uint16_t TARGET_EDGES = 9; // Eight complete periods.
uint8_t scalePercent = 20; // Send '2' for 2%, '0' for 20% in Serial Monitor.

volatile bool acquiring = false;
volatile uint8_t discardEdges = 0;
volatile uint16_t edgeCount = 0;
volatile uint32_t firstEdgeUs = 0, lastEdgeUs = 0;

struct Reading {
  float hz;
  uint32_t midpointUs;
  bool valid;
};

void onRisingEdge() {
  if (!acquiring) return;
  if (discardEdges) { --discardEdges; return; }
  const uint32_t now = micros();
  if (!edgeCount) firstEdgeUs = now;
  lastEdgeUs = now;
  ++edgeCount;
}

void setScale(uint8_t percent) {
  scalePercent = percent;
  digitalWrite(S0_PIN, percent == 20 ? HIGH : LOW);
  digitalWrite(S1_PIN, percent == 20 ? LOW : HIGH);
}

Reading readChannel(uint8_t channel) {
  // Datasheet table: R=00, G=11, B=01, Clear=10 on S2/S3.
  const uint8_t selectS2[4] = {LOW, HIGH, LOW, HIGH};
  const uint8_t selectS3[4] = {LOW, HIGH, HIGH, LOW};
  acquiring = false;
  digitalWrite(S2_PIN, selectS2[channel]);
  digitalWrite(S3_PIN, selectS3[channel]);
  delayMicroseconds(1000);
  ATOMIC_BLOCK(ATOMIC_RESTORESTATE) {
    edgeCount = 0;
    firstEdgeUs = lastEdgeUs = 0;
    discardEdges = 2; // Discard switching/transient periods, even in dim light.
    acquiring = true;
  }
  const uint32_t started = micros();
  while (uint32_t(micros()-started) < MAX_CHANNEL_US) {
    uint16_t edges;
    ATOMIC_BLOCK(ATOMIC_RESTORESTATE) { edges = edgeCount; }
    if (edges >= TARGET_EDGES) break;
  }
  uint16_t edges;
  uint32_t first, last;
  ATOMIC_BLOCK(ATOMIC_RESTORESTATE) {
    acquiring = false;
    edges = edgeCount;
    first = firstEdgeUs;
    last = lastEdgeUs;
  }
  const uint32_t elapsed = uint32_t(last-first); // Handles micros() wrap.
  Reading result = {0, started+uint32_t(micros()-started)/2, false};
  if (edges >= 2 && elapsed) {
    result.hz = (edges-1)*1000000.0f/elapsed;
    result.midpointUs = first+elapsed/2;
    // Above 15 kHz this interrupt/micros reader needs a lower scale or
    // hardware counter. Do not treat such readings as calibrated data.
    result.valid = result.hz <= 15000.0f;
  }
  return result;
}

void printFrequency(const Reading &r) {
  if (r.valid) Serial.print(r.hz, 2);
  else Serial.print(F("nan")); // Missing pulses are NOT a zero-Hz reading.
}

void setup() {
  Serial.begin(115200);
  pinMode(OUT_PIN, INPUT);
  pinMode(S0_PIN, OUTPUT); pinMode(S1_PIN, OUTPUT);
  pinMode(S2_PIN, OUTPUT); pinMode(S3_PIN, OUTPUT);
  setScale(scalePercent);
  attachInterrupt(digitalPinToInterrupt(OUT_PIN), onRisingEdge, RISING);
  Serial.println(F("start_us,end_us,r_us,g_us,b_us,c_us,r_hz,g_hz,b_hz,c_hz,r_fraction,g_fraction,b_fraction,valid_mask,scale_pct"));
}

void loop() {
  while (Serial.available()) {
    const char command = Serial.read();
    if (command=='2') setScale(2);
    if (command=='0') setScale(20);
  }
  Reading reading[4];
  const uint32_t start = micros();
  for (uint8_t i=0; i<4; ++i) reading[i] = readChannel(i);
  const uint32_t end = micros();
  uint8_t validMask = 0;
  for (uint8_t i=0; i<4; ++i) if (reading[i].valid) validMask |= (1<<i);
  Serial.print(start); Serial.print(','); Serial.print(end);
  for (uint8_t i=0; i<4; ++i) { Serial.print(','); Serial.print(reading[i].midpointUs); }
  for (uint8_t i=0; i<4; ++i) { Serial.print(','); printFrequency(reading[i]); }
  const float sum = reading[0].hz+reading[1].hz+reading[2].hz;
  for (uint8_t i=0; i<3; ++i) {
    Serial.print(',');
    if ((validMask & 7)==7 && sum>0) Serial.print(reading[i].hz/sum, 5);
    else Serial.print(F("nan"));
  }
  Serial.print(','); Serial.print(validMask);
  Serial.print(','); Serial.println(scalePercent);
}
