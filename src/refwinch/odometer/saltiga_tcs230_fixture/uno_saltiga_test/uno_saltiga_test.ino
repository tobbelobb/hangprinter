/* TCS230/TCS3200 -> Arduino UNO R3 / ATmega328P (not UNO R4).
   VCC=5V, GND=GND, OE=GND, OUT=D5 (hardware T1 clock),
   S0=D8, S1=D9, S2=D10, S3=D11. Read printed module labels.
   Serial 115200. Commands: e empty-fixture baseline; w white reference;
   x reset calibration; c clear-only; r RGB+clear; 1/2/3 scaling 100/20/2%;
   p RGB Serial Plotter (default); v diagnostic CSV;
   [/] slower/faster display (100..5000 ms); default 200 ms (5 updates/s).
   +/- double/halve measurement gate (2..100 ms). Default 20 ms, 100%.
   Plot lines: R:0..1 G:0..1 B:0..1 Min:0 Max:1. Keep anchors enabled.
   Frequency is proportional to light; larger Hz = brighter.
   RGB channels are sequential. This is a slow hand-pull bench test.
   Timer1 reserved: no Servo library / PWM on D9 or D10.
*/
#include <Arduino.h>
#include <avr/interrupt.h>
#include <util/atomic.h>
#if !defined(__AVR_ATmega328P__)
#error "Select Arduino Uno R3 (ATmega328P); this uses its Timer1 registers."
#endif
const uint8_t S0_PIN=8, S1_PIN=9, S2_PIN=10, S3_PIN=11, OUT_PIN=5;
volatile uint16_t wraps=0;
ISR(TIMER1_OVF_vect) { ++wraps; }
uint32_t gateUs=20000;
uint8_t scalePct=100;
bool clearOnly=false, haveEmpty=false, haveWhite=false;
bool plotMode=true;
uint32_t displayIntervalMs=200;
float emptyHz[4]={0,0,0,0}, gain[3]={1,1,1};
struct Reading {float hz; uint32_t count; bool settled;};
Reading measure(uint8_t channel); // Keep Arduino's generated prototypes after type.

void status(const __FlashStringHelper *message) {
  // Text and raw Hz would spoil the plot's labels and 0..1 scale.
  // Switch to v before calibration if you need its status messages.
  if(!plotMode) Serial.println(message);
}
void csvHeader() {
  Serial.println(F("t_ms,R_Hz,G_Hz,B_Hz,C_Hz,r,g,b,signal_Hz,min_count,settled,scale_pct,gate_us"));
}

Reading measure(uint8_t channel) {
  const uint8_t s2[4]={LOW,HIGH,LOW,HIGH}; // R G B clear
  const uint8_t s3[4]={LOW,HIGH,HIGH,LOW};
  digitalWrite(S2_PIN,s2[channel]); digitalWrite(S3_PIN,s3[channel]);
  // Hardware counts fast pulses even when digitalRead cannot follow them.
  // Settle by counting edges in hardware as well, no polling pulse aliasing.
  ATOMIC_BLOCK(ATOMIC_RESTORESTATE) {
    TCCR1B=0; TCNT1=0; wraps=0; TIFR1=_BV(TOV1);
    TCCR1B=_BV(CS12)|_BV(CS11)|_BV(CS10);
  }
  uint32_t waitStart=micros();
  while(TCNT1<2 && (uint32_t)(micros()-waitStart)<50000UL) {}
  bool settled=TCNT1>=2;
  uint32_t start;
  ATOMIC_BLOCK(ATOMIC_RESTORESTATE) {
    TCCR1B=0; TCNT1=0; wraps=0; TIFR1=_BV(TOV1);
    start=micros(); TCCR1B=_BV(CS12)|_BV(CS11)|_BV(CS10);
  }
  while((uint32_t)(micros()-start)<gateUs) {}
  uint32_t elapsed, count;
  ATOMIC_BLOCK(ATOMIC_RESTORESTATE) {
    TCCR1B=0; elapsed=micros()-start;
    uint16_t low=TCNT1, high=wraps;
    if(TIFR1&_BV(TOV1)) {++high; TIFR1=_BV(TOV1);}
    count=((uint32_t)high<<16)|low;
  }
  Reading out={count*1000000.0f/elapsed,count,settled};
  return out;
}
void setScale(uint8_t pct) {
  scalePct=pct;
  digitalWrite(S0_PIN,pct==2?LOW:HIGH);
  digitalWrite(S1_PIN,pct==20?LOW:HIGH);
  haveEmpty=false; haveWhite=false;
  for(uint8_t i=0;i<3;++i) gain[i]=1;
  status(F("# scale changed; calibrations cleared"));
}
void calibration(bool white) {
  // Place stationary white line/reference BEFORE issuing w; no line for e.
  float sum[4]={0,0,0,0}; bool stable=true;
  for(uint8_t n=0;n<8;++n) for(uint8_t i=0;i<4;++i) {
    Reading a=measure(i); sum[i]+=a.hz/8; stable &= a.settled;
  }
  if(!white) {
    for(uint8_t i=0;i<4;++i) emptyHz[i]=sum[i];
    haveEmpty=true; haveWhite=false;
    for(uint8_t i=0;i<3;++i) gain[i]=1;
    status(F("# empty baseline saved in RAM"));
  } else {
    float corrected[3], mean=0;
    for(uint8_t i=0;i<3;++i) {
      corrected[i]=sum[i]-(haveEmpty?emptyHz[i]:0); mean+=corrected[i]/3;
      if(corrected[i]<=1000000.0f/gateUs*5) stable=false;
    }
    if(!stable) {status(F("# white calibration rejected: low signal; improve light"));return;}
    for(uint8_t i=0;i<3;++i) gain[i]=mean/corrected[i];
    haveWhite=true; status(F("# white gains saved in RAM"));
  }
  if(!stable) status(F("# warning: at least one channel failed settling"));
}
void setup() {
  Serial.begin(115200);
  pinMode(S0_PIN,OUTPUT);pinMode(S1_PIN,OUTPUT);
  pinMode(S2_PIN,OUTPUT);pinMode(S3_PIN,OUTPUT);pinMode(OUT_PIN,INPUT);
  TCCR1A=0;TCCR1B=0;TIMSK1=_BV(TOIE1);setScale(100);
  if(!plotMode) csvHeader();
}
void handleCommands() {
  while(Serial.available()) {
    char c=Serial.read();
    if(c=='e') calibration(false);
    else if(c=='w') calibration(true);
    else if(c=='x') {haveEmpty=haveWhite=false;for(uint8_t i=0;i<3;++i) gain[i]=1;}
    else if(c=='c') {plotMode=false;clearOnly=true;csvHeader();}
    else if(c=='r') clearOnly=false;
    else if(c=='p') {plotMode=true;clearOnly=false;}
    else if(c=='v') {plotMode=false;csvHeader();}
    else if(c=='1') setScale(100);
    else if(c=='2') setScale(20);
    else if(c=='3') setScale(2);
    else if(c=='+') gateUs=min(100000UL,gateUs*2);
    else if(c=='-') gateUs=max(2000UL,gateUs/2);
    else if(c=='[') displayIntervalMs=min(5000UL,displayIntervalMs*2);
    else if(c==']') displayIntervalMs=max(100UL,displayIntervalMs/2);
  }
}
void loop() {
  handleCommands();
  uint32_t t=millis();Reading a[4];
  for(uint8_t i=0;i<4;++i) {
    if(clearOnly && i<3) {a[i]={0,0,true};continue;}
    a[i]=measure(i);
  }
  float v[3],total=0;
  for(uint8_t i=0;i<3;++i) {
    float raw=a[i].hz-(haveEmpty?emptyHz[i]:0);
    v[i]=(raw>0?raw:0)*gain[i];total+=v[i];
  }
  uint32_t minimum=0xFFFFFFFFUL;bool settled=true;
  for(uint8_t i=(clearOnly?3:0);i<4;++i) {
    if(a[i].count<minimum) minimum=a[i].count;
    settled &= a[i].settled;
  }
  if(plotMode) {
    const char labels[3]={'R','G','B'};
    for(uint8_t i=0;i<3;++i) {
      if(i) Serial.print('\t');
      Serial.print(labels[i]);Serial.print(':');
      Serial.print(total>0?v[i]/total:0,4);
    }
    Serial.println(F("\tMin:0\tMax:1"));
  } else {
    Serial.print(t);
    for(uint8_t i=0;i<4;++i) {Serial.print(',');Serial.print(a[i].hz,1);}
    for(uint8_t i=0;i<3;++i) {Serial.print(',');Serial.print(total>0?v[i]/total:0,4);}
    Serial.print(',');Serial.print(total,1);Serial.print(',');Serial.print(minimum);
    Serial.print(',');Serial.print(settled?1:0);Serial.print(',');Serial.print(scalePct);
    Serial.print(',');Serial.println(gateUs);
  }
  // Display pacing is independent of the measurement gate: no averaging or
  // smoothing, and commands remain responsive between complete scans.
  while((uint32_t)(millis()-t)<displayIntervalMs) {
    handleCommands();
    delay(1);
  }
}
