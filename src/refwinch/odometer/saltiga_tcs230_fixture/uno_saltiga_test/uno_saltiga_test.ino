/* TCS230/TCS3200 -> Arduino UNO R3 / ATmega328P (not UNO R4).
   VCC=5V, GND=GND, OE=GND, OUT=D5 (hardware T1 clock),
   S0=D8, S1=D9, S2=D10, S3=D11. Read printed module labels.
   Serial 115200. Commands: e empty-fixture baseline; w white reference;
   x erase saved calibration; c clear-only; r RGB+clear; 1/2/3 scaling 100/20/2%;
   p RGB + brightness Serial Plotter (default); v diagnostic CSV;
   [/] slower/faster display (100..5000 ms); minimum interval 200 ms.
   Four 100 ms gates give roughly 2.5 complete scans/s.
   +/- double/halve measurement gate (2..100 ms). Default 100 ms, 100%. Changing gate clears calibration.
   Plot RGB ratios 0..1 in IDE 2; reference lines Min:0 Max:1.
   Brightness appears after successful w: net clear / white net clear.
   Empty fixture = 0, white reference = 1; brighter readings may exceed 1.
   Set gate first, then e with no line, then w with stationary white line.
   Calibration, gate and scale survive resets/monitor changes in EEPROM.
   Recalibrate after changing the fixture, lighting or reference.
   Set LEGACY_PLOT_SCALE=true for IDE 1: maps plot values to -5..+5.
   CSV ratios remain 0..1; brightness=-1 means no white calibration.
   Frequency is proportional to light; larger Hz = brighter.
   RGB channels are sequential. This is a slow hand-pull bench test.
   Timer1 reserved: no Servo library / PWM on D9 or D10.
*/
#include <Arduino.h>
#include <EEPROM.h>
#include <math.h>
#include <stddef.h>
#include <avr/interrupt.h>
#include <util/atomic.h>
#if !defined(__AVR_ATmega328P__)
#error "Select Arduino Uno R3 (ATmega328P); this uses its Timer1 registers."
#endif
const uint8_t S0_PIN=8, S1_PIN=9, S2_PIN=10, S3_PIN=11, OUT_PIN=5;
const bool LEGACY_PLOT_SCALE=false;
volatile uint16_t wraps=0;
ISR(TIMER1_OVF_vect) { ++wraps; }
uint32_t gateUs=100000;
uint8_t scalePct=100;
bool clearOnly=false, haveEmpty=false, haveWhite=false;
bool plotMode=true;
uint32_t displayIntervalMs=200;
float emptyHz[4]={0,0,0,0}, gain[3]={1,1,1};
float whiteClearHz=0;
struct Reading {float hz; uint32_t count; bool settled;};
Reading measure(uint8_t channel); // Keep Arduino's generated prototypes after type.

// Versioned record at EEPROM address 0. Writes happen only on calibration or
// settings commands, never on each scan. EEPROM.put updates changed bytes.
struct SavedCalibration {
  uint32_t tag, gate;
  uint8_t scale, flags;
  float empty[4], gains[3], whiteClear;
  uint16_t checksum;
};
const uint32_t CALIBRATION_TAG=0x534C5401UL; // SLT, format version 1
uint16_t calibrationChecksum(const SavedCalibration &saved);
void applyScale(uint8_t pct);

uint16_t calibrationChecksum(const SavedCalibration &saved) {
  const uint8_t *bytes=(const uint8_t *)&saved;
  uint16_t crc=0xFFFF;
  for(uint8_t i=0;i<offsetof(SavedCalibration,checksum);++i) {
    crc ^= bytes[i];
    for(uint8_t bit=0;bit<8;++bit) crc=(crc&1)?(crc>>1)^0xA001:crc>>1;
  }
  return crc;
}
void saveCalibration() {
  SavedCalibration saved={};
  saved.tag=CALIBRATION_TAG; saved.gate=gateUs; saved.scale=scalePct;
  saved.flags=(haveEmpty?1:0)|(haveWhite?2:0);
  for(uint8_t i=0;i<4;++i) saved.empty[i]=emptyHz[i];
  for(uint8_t i=0;i<3;++i) saved.gains[i]=gain[i];
  saved.whiteClear=whiteClearHz;
  saved.checksum=calibrationChecksum(saved);
  EEPROM.put(0,saved);
}
bool restoreCalibration() {
  SavedCalibration saved;
  EEPROM.get(0,saved);
  if(saved.tag!=CALIBRATION_TAG || saved.checksum!=calibrationChecksum(saved)) return false;
  if(saved.gate<2000 || saved.gate>100000 || saved.flags>3) return false;
  if(saved.scale!=2 && saved.scale!=20 && saved.scale!=100) return false;
  for(uint8_t i=0;i<4;++i)
    if(!isfinite(saved.empty[i]) || saved.empty[i]<0) return false;
  for(uint8_t i=0;i<3;++i)
    if(!isfinite(saved.gains[i]) || saved.gains[i]<=0) return false;
  if(!isfinite(saved.whiteClear) || saved.whiteClear<0 ||
     ((saved.flags&2) && saved.whiteClear<=0)) return false;
  gateUs=saved.gate; applyScale(saved.scale);
  haveEmpty=saved.flags&1; haveWhite=saved.flags&2;
  for(uint8_t i=0;i<4;++i) emptyHz[i]=saved.empty[i];
  for(uint8_t i=0;i<3;++i) gain[i]=saved.gains[i];
  whiteClearHz=saved.whiteClear;
  return true;
}

void status(const __FlashStringHelper *message) {
  // Text and raw Hz would spoil the plot's labels and display scale.
  // Switch to v before calibration if you need its status messages.
  if(!plotMode) Serial.println(message);
}
void csvHeader() {
  Serial.println(F("t_ms,R_Hz,G_Hz,B_Hz,C_Hz,r,g,b,signal_Hz,min_count,settled,scale_pct,gate_us,brightness"));
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
void clearCalibration() {
  haveEmpty=haveWhite=false; whiteClearHz=0;
  for(uint8_t i=0;i<3;++i) gain[i]=1;
  for(uint8_t i=0;i<4;++i) emptyHz[i]=0;
}
void setGate(uint32_t us) {
  if(us==gateUs) return;
  gateUs=us; clearCalibration(); saveCalibration();
  status(F("# gate changed; calibrations cleared; repeat e then w"));
}
void applyScale(uint8_t pct) {
  scalePct=pct;
  digitalWrite(S0_PIN,pct==2?LOW:HIGH);
  digitalWrite(S1_PIN,pct==20?LOW:HIGH);
}
void setScale(uint8_t pct) {
  applyScale(pct); clearCalibration(); saveCalibration();
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
    haveEmpty=true; haveWhite=false; whiteClearHz=0;
    for(uint8_t i=0;i<3;++i) gain[i]=1;
    saveCalibration();
    status(F("# empty baseline saved in EEPROM"));
  } else {
    float corrected[3], mean=0;
    for(uint8_t i=0;i<3;++i) {
      corrected[i]=sum[i]-(haveEmpty?emptyHz[i]:0); mean+=corrected[i]/3;
      if(corrected[i]<=1000000.0f/gateUs*5) stable=false;
    }
    float correctedClear=sum[3]-(haveEmpty?emptyHz[3]:0);
    if(correctedClear<=1000000.0f/gateUs*5) stable=false;
    if(!stable) {status(F("# white calibration rejected: low signal; improve light"));return;}
    for(uint8_t i=0;i<3;++i) gain[i]=mean/corrected[i];
    whiteClearHz=correctedClear; haveWhite=true;
    saveCalibration();
    status(F("# white gains and brightness reference saved in EEPROM"));
  }
  if(!stable) status(F("# warning: at least one channel failed settling"));
}
void setup() {
  Serial.begin(115200);
  pinMode(S0_PIN,OUTPUT);pinMode(S1_PIN,OUTPUT);
  pinMode(S2_PIN,OUTPUT);pinMode(S3_PIN,OUTPUT);pinMode(OUT_PIN,INPUT);
  TCCR1A=0;TCCR1B=0;TIMSK1=_BV(TOIE1);applyScale(100);
  restoreCalibration(); // Read only at boot; never overwrite saved calibration here.
  if(!plotMode) csvHeader();
}
void handleCommands() {
  while(Serial.available()) {
    char c=Serial.read();
    if(c=='e') calibration(false);
    else if(c=='w') calibration(true);
    else if(c=='x') {clearCalibration();saveCalibration();status(F("# saved calibration cleared"));}
    else if(c=='c') {plotMode=false;clearOnly=true;csvHeader();}
    else if(c=='r') clearOnly=false;
    else if(c=='p') {plotMode=true;clearOnly=false;}
    else if(c=='v') {plotMode=false;csvHeader();}
    else if(c=='1') setScale(100);
    else if(c=='2') setScale(20);
    else if(c=='3') setScale(2);
    else if(c=='+') setGate(min(100000UL,gateUs*2));
    else if(c=='-') setGate(max(2000UL,gateUs/2));
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
  // Clear is independent of RGB fractions: a tiny blue residual can give
  // b=1 while this brightness remains near zero. This is reflected signal
  // relative to the paper reference, not photometric luminance.
  float clearSignal=a[3].hz-(haveEmpty?emptyHz[3]:0);
  float brightness=haveWhite?max(0.0f,clearSignal)/whiteClearHz:-1.0f;
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
      float ratio=total>0?v[i]/total:0;
      Serial.print(LEGACY_PLOT_SCALE?10.0f*ratio-5.0f:ratio,4);
    }
    Serial.print(LEGACY_PLOT_SCALE?F("\tMin:-5\tMax:5"):F("\tMin:0\tMax:1"));
    // Append after existing traces so their plotter colours stay unchanged.
    // Omit until calibrated rather than showing a false zero brightness.
    if(haveWhite) {
      Serial.print(F("\tBrightness:"));
      Serial.print(LEGACY_PLOT_SCALE?10.0f*brightness-5.0f:brightness,4);
    }
    Serial.println();
  } else {
    Serial.print(t);
    for(uint8_t i=0;i<4;++i) {Serial.print(',');Serial.print(a[i].hz,1);}
    for(uint8_t i=0;i<3;++i) {Serial.print(',');Serial.print(total>0?v[i]/total:0,4);}
    Serial.print(',');Serial.print(total,1);Serial.print(',');Serial.print(minimum);
    Serial.print(',');Serial.print(settled?1:0);Serial.print(',');Serial.print(scalePct);
    Serial.print(',');Serial.print(gateUs);
    Serial.print(',');Serial.println(brightness,4);
  }
  // Display pacing is independent of the measurement gate: no averaging or
  // smoothing, and commands remain responsive between complete scans.
  while((uint32_t)(millis()-t)<displayIntervalMs) {
    handleCommands();
    delay(1);
  }
}
