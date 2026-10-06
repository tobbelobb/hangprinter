/* TCS230/TCS3200 -> Arduino UNO R3 / ATmega328P (not UNO R4).
   VCC=5V, GND=GND, OE=GND, OUT=D5 (hardware T1 clock),
   S0=D8, S1=D9, S2=D10, S3=D11. Read printed module labels.
   Serial 115200. Commands: e empty-fixture baseline; w white reference;
   x erase saved calibration; c clear-only; r RGB+clear; 1/2/3 scaling 100/20/2%;
   p RGB + brightness Serial Plotter (default without palette); v diagnostic CSV;
   f fast: reciprocal pulse timing, 2 ms/channel target, no display delay;
   s slow: pulse counting, 100 ms/channel, 200 ms minimum display interval.
   [/] slower/faster reporting (0..5000 ms); 0 means every complete scan.
   +/- double/halve acquisition window (fast 0.1..100 ms; slow 2..100 ms).
   Fast/slow switches and window changes keep calibration.
   Default slow (roughly 2.5 scans/s); fast/slow mode survives reset.
   Calibration always uses pulse timing at 100 ms/channel; allow 4 s.
   Plot RGB ratios 0..1 in IDE 2; reference lines Min:0 Max:1.
   Brightness appears after successful w: net clear / white net clear.
   Empty fixture = 0, white reference = 1; brighter readings may exceed 1.
   Set gate first, then e with no line, then w with stationary white line.
   Calibration, acquisition mode/window and scale survive resets in EEPROM.
   Recalibrate after changing the fixture, lighting or reference.
   Set LEGACY_PLOT_SCALE=true for IDE 1: maps plot values to -5..+5.
   CSV ratios remain 0..1; brightness=-1 means no white calibration.
   Frequency is proportional to light; larger Hz = brighter.
   RGB/clear are sequential: moving boundaries can mix colours in one row.
   a raw RGBC + normalized feature/classification CSV; h absolute-clear plot;
   d palette indicators (one hot, Unknown for invalid/outside trained radius).
   Features: RGB/clear or RGB/(R+G+B), plus log(1+C*100/scale); no e/w dependence.
   Host palette import: @N normalization, @C class, @W EEPROM commit.
   Send '@', wait for '# model line ready', then send the rest of each row.
   Models survive reset separately from white calibration; low clear alone
   cannot tell black line from a clogged sensor. Dark floor defaults disabled.
   CSV includes scan_us, row_us and reciprocal (1=fast) for timing checks.
   scan_us excludes serial output; row_us is time between scan starts.
   Timer1 reserved: no Servo library / PWM on D9 or D10.
*/
#include <Arduino.h>
#include <EEPROM.h>
#include <math.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
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
bool reciprocalMode=false, calibrating=false;
uint32_t previousScanUs=0;
bool havePreviousScan=false;
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
const uint32_t CALIBRATION_TAG=0x534C5402UL; // SLT, format version 2; same record layout as v1
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
  saved.flags=(haveEmpty?1:0)|(haveWhite?2:0)|(reciprocalMode?4:0);
  for(uint8_t i=0;i<4;++i) saved.empty[i]=emptyHz[i];
  for(uint8_t i=0;i<3;++i) saved.gains[i]=gain[i];
  saved.whiteClear=whiteClearHz;
  saved.checksum=calibrationChecksum(saved);
  EEPROM.put(0,saved);
}
bool restoreCalibration() {
  SavedCalibration saved;
  EEPROM.get(0,saved);
  if((saved.tag!=CALIBRATION_TAG && saved.tag!=0x534C5401UL) ||
     saved.checksum!=calibrationChecksum(saved)) return false;
  if(saved.flags>7 || saved.gate<((saved.flags&4)?100UL:2000UL) ||
     saved.gate>100000) return false;
  if(saved.scale!=2 && saved.scale!=20 && saved.scale!=100) return false;
  for(uint8_t i=0;i<4;++i)
    if(!isfinite(saved.empty[i]) || saved.empty[i]<0) return false;
  for(uint8_t i=0;i<3;++i)
    if(!isfinite(saved.gains[i]) || saved.gains[i]<=0) return false;
  if(!isfinite(saved.whiteClear) || saved.whiteClear<0 ||
     ((saved.flags&2) && saved.whiteClear<=0)) return false;
  reciprocalMode=saved.flags&4;
  displayIntervalMs=reciprocalMode?0:200;
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
  Serial.println(F("t_ms,R_Hz,G_Hz,B_Hz,C_Hz,r,g,b,signal_Hz,min_count,settled,scale_pct,gate_us,brightness,scan_us,row_us,reciprocal"));
}

// Atomically read the extended external-pulse counter without stopping it.
uint32_t pulseCount() {
  uint32_t count;
  ATOMIC_BLOCK(ATOMIC_RESTORESTATE) {
    uint16_t low=TCNT1, high=wraps;
    if(TIFR1&_BV(TOV1)) {
      ++high; TIFR1=_BV(TOV1); wraps=high;
      low=TCNT1;
    }
    count=((uint32_t)high<<16)|low;
  }
  return count;
}
Reading measure(uint8_t channel) {
  const uint8_t s2[4]={LOW,HIGH,LOW,HIGH}; // R G B clear
  const uint8_t s3[4]={LOW,HIGH,HIGH,LOW};
  const uint32_t windowUs=calibrating?100000UL:gateUs;
  digitalWrite(S2_PIN,s2[channel]); digitalWrite(S3_PIN,s3[channel]);
  // Discard two edges after switching filters. The device needs one new
  // output period to respond; dark channels can make settling take longer.
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
  if(reciprocalMode || calibrating) {
    // Calibration uses the same long-window estimator in both modes.
    // Time actual output periods, rather than rounding to an integer number
    // of pulses inside a short fixed gate. D5 wiring is unchanged. Poll the
    // hardware counter; multiple edges between polls remain accounted for.
    // Uno micros() has 4 us ticks, plus polling jitter: not a precision
    // hardware-capture timestamp. Endpoint error matters for very short runs.
    uint32_t firstCount=0, firstTime=0, lastCount=0, lastTime=0;
    bool haveFirst=false, complete=false;
    const uint32_t timeoutUs=windowUs+50000UL;
    while((uint32_t)(micros()-start)<timeoutUs) {
      uint32_t count=pulseCount();
      if(count!=lastCount) {
        uint32_t now=micros();
        if(!haveFirst) {firstCount=count;firstTime=now;haveFirst=true;}
        lastCount=count;lastTime=now;
        if(count>firstCount && (uint32_t)(now-firstTime)>=windowUs) {
          complete=true;break;
        }
      }
    }
    TCCR1B=0;
    uint32_t periods=lastCount-firstCount;
    uint32_t elapsed=lastTime-firstTime;
    Reading out={periods && elapsed?periods*1000000.0f/elapsed:0,
                 periods,settled && complete};
    return out;
  }
  while((uint32_t)(micros()-start)<windowUs) {}
  TCCR1B=0;
  uint32_t elapsed=micros()-start, count=pulseCount();
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
  gateUs=us;
  // Saved references are Hz measured with a fixed 100 ms calibration window.
  // Live window changes affect precision, not the reference units.
  saveCalibration();
  status(F("# acquisition window changed; calibration kept"));
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
void setAcquisition(bool fast) {
  const uint32_t target=fast?2000UL:100000UL;
  bool changed=reciprocalMode!=fast || gateUs!=target;
  reciprocalMode=fast;gateUs=target;displayIntervalMs=fast?0:200;
  if(changed) saveCalibration();
  havePreviousScan=false;
  status(fast?F("# fast mode; calibration kept"):
              F("# slow mode; calibration kept"));
}
void calibration(bool white) {
  // Place stationary white line/reference BEFORE issuing w; no line for e.
  float sum[4]={0,0,0,0}; bool stable=true;
  calibrating=true;
  for(uint8_t n=0;n<8;++n) for(uint8_t i=0;i<4;++i) {
    Reading a=measure(i); sum[i]+=a.hz/8; stable &= a.settled;
  }
  calibrating=false;havePreviousScan=false;
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
      if(corrected[i]<=50.0f) stable=false;
    }
    float correctedClear=sum[3]-(haveEmpty?emptyHz[3]:0);
    if(correctedClear<=50.0f) stable=false;
    if(!stable) {status(F("# white calibration rejected: low signal; improve light"));return;}
    for(uint8_t i=0;i<3;++i) gain[i]=mean/corrected[i];
    whiteClearHz=correctedClear; haveWhite=true;
    saveCalibration();
    status(F("# white gains and brightness reference saved in EEPROM"));
  }
  if(!stable) status(F("# warning: at least one channel failed settling"));
}
// Palette features deliberately use absolute sensor output, independent of e/w.
// Ratios cancel common intensity; log(clear) retains the distinction between
// black and blue. Global training-set standard deviations balance the axes.
const uint8_t MAX_COLOURS=8, FEATURE_COUNT=4;
struct PaletteClass {
  char name[12];
  float centre[4], radius2;
  uint32_t samples;
};
struct PaletteModel {
  uint32_t tag;
  uint8_t count, normalization; // 0 RGB/clear, 1 RGB/(R+G+B)
  float mean[4], invStd[4], darkHz;
  PaletteClass colours[MAX_COLOURS];
  uint16_t checksum;
};
struct ColourResult {
  int8_t nearest, accepted;
  float distance2, margin;
};
const uint32_t PALETTE_TAG=0x53435002UL;
const int PALETTE_ADDRESS=64; // Calibration occupies bytes 0..43.
PaletteModel palette={};
bool paletteReady=false, datasetMode=false;
uint8_t specialPlot=0, stagedClasses=0; // 1 absolute clear, 2 category indicators
char modelLine[192];
uint8_t modelLength=0;
bool modelReceiving=false, modelOverflow=false;
uint32_t modelByteMs=0;
static_assert(PALETTE_ADDRESS+sizeof(PaletteModel)<=1024,"Palette exceeds Uno EEPROM");
uint16_t paletteChecksum(const PaletteModel &model);
bool paletteValid(const PaletteModel &model);
bool colourFeatures(const Reading a[4], float x[4], float &absoluteClear);
ColourResult classifyColour(const float x[4], float absoluteClear, bool valid);
void datasetRow(uint32_t t, const Reading a[4], uint32_t scanUs, uint32_t rowUs);
void colourPlot(const Reading a[4]);

uint16_t paletteChecksum(const PaletteModel &model) {
  const uint8_t *bytes=(const uint8_t *)&model;
  uint16_t crc=0xFFFF;
  for(uint16_t i=0;i<offsetof(PaletteModel,checksum);++i) {
    crc^=bytes[i];
    for(uint8_t bit=0;bit<8;++bit) crc=(crc&1)?(crc>>1)^0xA001:crc>>1;
  }
  return crc;
}
bool validName(const char *name) {
  uint8_t n=0;
  while(n<12 && name[n]) {
    char c=name[n++];
    if(!((c>='A' && c<='Z') || (c>='a' && c<='z') ||
         (c>='0' && c<='9') || c=='_' || c=='-')) return false;
  }
  return n>0 && n<12;
}
bool paletteValid(const PaletteModel &model) {
  if(model.tag!=PALETTE_TAG || model.count<2 || model.count>MAX_COLOURS || model.normalization>1 ||
     !isfinite(model.darkHz) || model.darkHz<0) return false;
  for(uint8_t j=0;j<4;++j)
    if(!isfinite(model.mean[j]) || !isfinite(model.invStd[j]) || model.invStd[j]<0)
      return false;
  bool active=false;for(uint8_t j=0;j<4;++j) active |= model.invStd[j]>0;
  if(!active) return false;
  for(uint8_t i=0;i<model.count;++i) {
    const PaletteClass &c=model.colours[i];
    if(!validName(c.name) || !c.samples || !isfinite(c.radius2) || c.radius2<=0)
      return false;
    for(uint8_t k=0;k<i;++k)
      if(!strcmp(c.name,model.colours[k].name)) return false;
    for(uint8_t j=0;j<4;++j) if(!isfinite(c.centre[j])) return false;
  }
  return true;
}
bool colourFeatures(const Reading a[4], float x[4], float &absoluteClear) {
  absoluteClear=a[3].hz*(100.0f/scalePct);
  for(uint8_t j=0;j<4;++j) x[j]=0;
  for(uint8_t j=0;j<4;++j)
    if(!a[j].settled || !isfinite(a[j].hz) || a[j].hz<0) return false;
  if(a[3].hz<=0 || !isfinite(absoluteClear)) return false;
  float denominator=palette.normalization==1?a[0].hz+a[1].hz+a[2].hz:a[3].hz;
  if(!isfinite(denominator) || denominator<=0) return false;
  for(uint8_t j=0;j<3;++j) {
    x[j]=a[j].hz/denominator;
    if(!isfinite(x[j])) return false;
  }
  x[3]=log(1.0f+absoluteClear);
  return isfinite(x[3]);
}
ColourResult classifyColour(const float x[4], float absoluteClear, bool valid) {
  ColourResult result={-1,-1,-1,0};
  if(!valid || !paletteReady) return result;
  float z[4];
  for(uint8_t j=0;j<4;++j) z[j]=(x[j]-palette.mean[j])*palette.invStd[j];
  float best=INFINITY, second=INFINITY;
  for(uint8_t i=0;i<palette.count;++i) {
    float d2=0;
    for(uint8_t j=0;j<4;++j) {
      float d=z[j]-palette.colours[i].centre[j];d2+=d*d;
    }
    if(d2<best) {second=best;best=d2;result.nearest=i;}
    else if(d2<second) second=d2;
  }
  if(result.nearest<0 || !isfinite(best)) return result;
  result.distance2=best;
  // Relative separation between first and second choice, not a probability.
  result.margin=isfinite(second) && second>0?(second-best)/second:0;
  if(best<=palette.colours[result.nearest].radius2 && absoluteClear>=palette.darkHz)
    result.accepted=result.nearest;
  return result;
}
bool nextFloat(float &value) {
  char *token=strtok(NULL," ,\t");
  if(!token) return false;
  char *end;
  value=strtod(token,&end);
  return *end==0 && isfinite(value);
}
bool nextInteger(uint32_t &value) {
  char *token=strtok(NULL," ,\t");
  if(!token || !*token) return false;
  for(char *p=token;*p;++p) if(*p<'0' || *p>'9') return false;
  char *end;
  unsigned long v=strtoul(token,&end,10);
  if(*end) return false;
  value=v;return true;
}
void modelCommand() {
  char *command=strtok(modelLine," ,\t");
  bool ok=false;
  if(command && !strcmp(command,"@N")) {
    uint32_t count, normalization;float mean[4], inv[4], dark;
    ok=nextInteger(count) && count>=2 && count<=MAX_COLOURS &&
       nextInteger(normalization) && normalization<=1;
    for(uint8_t j=0;j<4 && ok;++j) ok=nextFloat(mean[j]);
    for(uint8_t j=0;j<4 && ok;++j) ok=nextFloat(inv[j]) && inv[j]>=0;
    bool active=false;for(uint8_t j=0;j<4 && ok;++j) active |= inv[j]>0;
    ok=ok && active && nextFloat(dark) && dark>=0 && !strtok(NULL," ,\t");
    if(ok) {
      memset(&palette,0,sizeof(palette));palette.tag=PALETTE_TAG;palette.count=count;palette.normalization=normalization;
      for(uint8_t j=0;j<4;++j) {palette.mean[j]=mean[j];palette.invStd[j]=inv[j];}
      palette.darkHz=dark;stagedClasses=0;paletteReady=false;
      Serial.println(F("# model normalization accepted"));
    }
  } else if(command && !strcmp(command,"@C")) {
    uint32_t id=0, samples=0;PaletteClass row={};
    ok=nextInteger(id) && id<palette.count && !paletteReady && palette.tag==PALETTE_TAG;
    char *name=ok?strtok(NULL," ,\t"):NULL;
    ok=ok && name && strlen(name)<sizeof(row.name);
    if(ok) {strcpy(row.name,name);ok=validName(row.name);}
    for(uint8_t j=0;j<4 && ok;++j) ok=nextFloat(row.centre[j]);
    ok=ok && nextFloat(row.radius2) && row.radius2>0 && nextInteger(samples) && samples>0 &&
       !strtok(NULL," ,\t");
    if(ok) {
      row.samples=samples;palette.colours[id]=row;stagedClasses|=(1<<id);
      Serial.println(F("# model class accepted"));
    }
  } else if(command && !strcmp(command,"@W")) {
    ok=!strtok(NULL," ,\t") && !paletteReady &&
       stagedClasses==((1U<<palette.count)-1) && paletteValid(palette);
    if(ok) {
      palette.checksum=paletteChecksum(palette);EEPROM.put(PALETTE_ADDRESS,palette);
      paletteReady=true;Serial.println(F("# palette saved in EEPROM"));
    }
  }
  if(!ok) Serial.println(F("# model command rejected"));
}
void datasetHeader() {
  Serial.println(F("t_ms,R_Hz,G_Hz,B_Hz,C_Hz,scale_pct,gate_us,reciprocal,scan_us,row_us,settled,clear100_Hz,R_feature,G_feature,B_feature,log_clear100,normalization,valid,nearest_id,class_id,distance2,margin,low_clear"));
}
void datasetRow(uint32_t t, const Reading a[4], uint32_t scanUs, uint32_t rowUs) {
  float x[4], absoluteClear;bool valid=colourFeatures(a,x,absoluteClear);
  ColourResult result=classifyColour(x,absoluteClear,valid);
  Serial.print(t);
  for(uint8_t j=0;j<4;++j) {Serial.print(',');Serial.print(a[j].hz,2);}
  Serial.print(',');Serial.print(scalePct);Serial.print(',');Serial.print(gateUs);
  Serial.print(',');Serial.print(reciprocalMode?1:0);
  Serial.print(',');Serial.print(scanUs);Serial.print(',');Serial.print(rowUs);
  bool settled=true;for(uint8_t j=0;j<4;++j) settled &= a[j].settled;
  Serial.print(',');Serial.print(settled?1:0);
  Serial.print(',');Serial.print(absoluteClear,2);
  for(uint8_t j=0;j<4;++j) {Serial.print(',');Serial.print(x[j],6);}
  Serial.print(',');Serial.print(palette.normalization);
  Serial.print(',');Serial.print(valid?1:0);
  Serial.print(',');Serial.print(result.nearest);Serial.print(',');Serial.print(result.accepted);
  Serial.print(',');Serial.print(result.distance2,5);Serial.print(',');Serial.print(result.margin,5);
  Serial.print(',');Serial.println(paletteReady && palette.darkHz>0 && isfinite(absoluteClear) && absoluteClear<palette.darkHz?1:0);
}
void colourPlot(const Reading a[4]) {
  float x[4], absoluteClear;bool valid=colourFeatures(a,x,absoluteClear);
  ColourResult result=classifyColour(x,absoluteClear,valid);
  // Match the existing IDE plot palette: RGB first, then its other colours.
  // Model IDs keep their JSON order; only the displayed series order changes.
  const char *order[7]={"Red","Green","Blue","Orange","Purple","Yellow","Black"};
  uint8_t emitted=0;
  for(uint8_t pass=0;pass<8 && paletteReady;++pass) {
    for(uint8_t i=0;i<palette.count;++i) {
      if((emitted & (1<<i)) || (pass<7 && strcmp(palette.colours[i].name,order[pass]))) continue;
      if(emitted) Serial.print('\t');
      Serial.print(palette.colours[i].name);Serial.print(':');
      Serial.print(result.accepted==i?1:0);emitted|=(1<<i);
    }
  }
  if(emitted) Serial.print('\t');
  Serial.print(F("Unknown:"));Serial.print(result.accepted<0?1:0);
  Serial.print(F("\tLowClear:"));Serial.print(paletteReady && palette.darkHz>0 && isfinite(absoluteClear) && absoluteClear<palette.darkHz?1:0);
  Serial.print(F("\tInvalid:"));Serial.print(valid?0:1);
  Serial.println(F("\tMin:0\tMax:1"));
}

void setup() {
  Serial.begin(115200);
  pinMode(S0_PIN,OUTPUT);pinMode(S1_PIN,OUTPUT);
  pinMode(S2_PIN,OUTPUT);pinMode(S3_PIN,OUTPUT);pinMode(OUT_PIN,INPUT);
  TCCR1A=0;TCCR1B=0;TIMSK1=_BV(TOIE1);applyScale(100);
  restoreCalibration(); // Read only at boot; never overwrite saved calibration here.
  EEPROM.get(PALETTE_ADDRESS,palette);
  paletteReady=paletteValid(palette) && palette.checksum==paletteChecksum(palette);
  if(!paletteReady) memset(&palette,0,sizeof(palette));
  else specialPlot=2; // A trained palette opens directly as category indicators.
  if(!plotMode) csvHeader();
}
void handleCommands() {
  while(Serial.available()) {
    char c=Serial.read();
    if(modelReceiving) {
      modelByteMs=millis();
      if(c=='\r') continue;
      if(c=='\n') {
        modelLine[modelLength]=0;
        if(modelOverflow) Serial.println(F("# model command rejected"));
        else modelCommand();
        modelReceiving=false;modelLength=0;continue;
      }
      if(modelLength<sizeof(modelLine)-1) modelLine[modelLength++]=c;
      else modelOverflow=true;
      continue;
    }
    if(c=='@') {
      plotMode=false;datasetMode=false;specialPlot=0;
      modelReceiving=true;modelOverflow=false;modelLength=1;modelLine[0]='@';modelByteMs=millis();
      // Host waits for this before sending the rest. Drain input continuously
      // while receiving: the Uno's 64-byte UART buffer cannot hold model rows.
      Serial.println(F("# model line ready"));continue;
    }
    if(c=='e') calibration(false);
    else if(c=='w') calibration(true);
    else if(c=='x') {clearCalibration();saveCalibration();status(F("# saved calibration cleared"));}
    else if(c=='c') {plotMode=false;datasetMode=false;specialPlot=0;clearOnly=true;csvHeader();}
    else if(c=='r') clearOnly=false;
    else if(c=='p') {plotMode=true;datasetMode=false;specialPlot=0;clearOnly=false;}
    else if(c=='v') {plotMode=false;datasetMode=false;specialPlot=0;clearOnly=false;csvHeader();}
    else if(c=='a') {plotMode=false;datasetMode=true;specialPlot=0;clearOnly=false;datasetHeader();}
    else if(c=='h') {plotMode=true;datasetMode=false;specialPlot=1;clearOnly=true;}
    else if(c=='d') {plotMode=true;datasetMode=false;specialPlot=2;clearOnly=false;}
    else if(c=='f') setAcquisition(true);
    else if(c=='s') setAcquisition(false);
    else if(c=='1') setScale(100);
    else if(c=='2') setScale(20);
    else if(c=='3') setScale(2);
    else if(c=='+') setGate(min(100000UL,gateUs*2));
    else if(c=='-') setGate(max(reciprocalMode?100UL:2000UL,gateUs/2));
    else if(c=='[') displayIntervalMs=displayIntervalMs?min(5000UL,displayIntervalMs*2):20;
    else if(c==']') displayIntervalMs=displayIntervalMs<=20?0:displayIntervalMs/2;
  }
}
void loop() {
  handleCommands();
  if(modelReceiving) {
    if((uint32_t)(millis()-modelByteMs)>5000) {
      modelReceiving=false;modelLength=0;Serial.println(F("# model input timed out"));
    } else {delay(1);return;}
  }
  uint32_t t=millis(), scanStart=micros();Reading a[4];
  uint32_t rowUs=havePreviousScan?scanStart-previousScanUs:0;
  previousScanUs=scanStart;havePreviousScan=true;
  for(uint8_t i=0;i<4;++i) {
    if(clearOnly && i<3) {a[i]={0,0,true};continue;}
    a[i]=measure(i);
  }
  uint32_t scanUs=micros()-scanStart;
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
  if(datasetMode) datasetRow(t,a,scanUs,rowUs);
  else if(plotMode && specialPlot==1) {
    Serial.print(F("Clear100_Hz:"));Serial.println(a[3].hz*(100.0f/scalePct),2);
  } else if(plotMode && specialPlot==2) colourPlot(a);
  else if(plotMode) {
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
    Serial.print(',');Serial.print(brightness,4);
    Serial.print(',');Serial.print(scanUs);Serial.print(',');Serial.print(rowUs);
    Serial.print(',');Serial.println(reciprocalMode?1:0);
  }
  // Display pacing is independent of the measurement gate: no averaging or
  // smoothing, and commands remain responsive between complete scans.
  while((uint32_t)(millis()-t)<displayIntervalMs) {
    handleCommands();
    delay(1);
  }
}
