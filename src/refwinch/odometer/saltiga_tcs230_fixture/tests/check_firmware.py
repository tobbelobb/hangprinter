#!/usr/bin/env python3
"""Run the actual .ino's feature, classifier, UART parser and EEPROM code on host.
Hardware timing is covered by Uno compilation and physical serial checks instead.
"""
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
ARDUINO = r'''
#pragma once
#include <cstdint>
#include <cstring>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <algorithm>
#include <sstream>
#include <iomanip>
#include <string>
using std::isfinite;
struct __FlashStringHelper {};
#define F(s) reinterpret_cast<const __FlashStringHelper *>(s)
#define min(a,b) ((a)<(b)?(a):(b))
#define max(a,b) ((a)>(b)?(a):(b))
#define _BV(x) (1u<<(x))
const int LOW=0,HIGH=1,OUTPUT=1,INPUT=0;
const int CS12=2,CS11=1,CS10=0,TOIE1=0,TOV1=0;
uint8_t TCCR1A=0,TCCR1B=0,TIMSK1=0,TIFR1=0;
uint16_t TCNT1=0;
uint32_t nowMs=0;
void pinMode(int,int) {} void digitalWrite(int,int) {}
uint32_t millis() {return nowMs;} uint32_t micros() {static uint32_t t=0;return t+=1000;}
void delay(uint32_t n) {nowMs+=n;}
struct TestSerial {
  std::string input,output;
  void begin(int) {} int available() {return input.size();}
  int read() {char c=input[0];input.erase(0,1);return c;}
  void print(const __FlashStringHelper *v) {output+=reinterpret_cast<const char *>(v);}
  void print(char v) {output+=v;}
  void print(signed char v) {print(int(v));}
  void print(unsigned char v) {print(unsigned(v));}
  template<class T> void print(T v) {std::ostringstream s;s<<v;output+=s.str();}
  void print(float v,int digits) {std::ostringstream s;s<<std::fixed<<std::setprecision(digits)<<v;output+=s.str();}
  void println() {output+='\n';}
  template<class T> void println(T v) {print(v);println();}
  void println(float v,int digits) {print(v,digits);println();}
} Serial;
'''
EEPROM = r'''
#pragma once
struct TestEEPROM {
  unsigned char bytes[1024]={};
  template<class T> void put(int addr,const T &v) {memcpy(bytes+addr,&v,sizeof(v));}
  template<class T> void get(int addr,T &v) {memcpy(&v,bytes+addr,sizeof(v));}
} EEPROM;
'''
TEST = r'''
#include <cassert>
#include "SKETCH_PATH"
void send(const char *line) {
  Serial.input=line;
  while(Serial.available()) handleCommands();
}
int main() {
  Reading a[4]={{100,3,true},{200,3,true},{50,3,true},{400,3,true}};
  float x[4], clear;
  assert(colourFeatures(a,x,clear) && clear==400 && x[0]==.25f && x[1]==.5f);
  assert(fabs(x[3]-log(401.0f))<1e-5);
  scalePct=20;for(auto &r:a) r.hz*=.2f;
  assert(colourFeatures(a,x,clear) && fabs(clear-400)<1e-4);
  a[1].settled=false;assert(!colourFeatures(a,x,clear));a[1].settled=true;
  send("@");assert(modelReceiving && Serial.output.find("# model line ready")!=std::string::npos);
  send("N 2 0 0 0 0 0 1 1 1 1 0\n");assert(!modelReceiving && !paletteReady);
  send("@C 0 Black 0.25 0.5 0.125 5.9939614 0.01 3000\n");
  send("@W\n");assert(!paletteReady); // Missing second class must not commit.
  send("@C 1 Blue 0.25 0.5 0.125 8.006617 0.01 3000\n");
  send("@W\n");assert(paletteReady && paletteValid(palette));
  assert(colourFeatures(a,x,clear));
  ColourResult r=classifyColour(x,clear,true);assert(r.nearest==0 && r.accepted==0);
  x[3]=8.006617f;r=classifyColour(x,3000,true);assert(r.nearest==1 && r.accepted==1);
  x[0]=99;r=classifyColour(x,3000,true);assert(r.accepted==-1 && r.nearest>=0);
  r=classifyColour(x,3000,false);assert(r.nearest==-1 && r.accepted==-1);
  PaletteModel saved;EEPROM.get(PALETTE_ADDRESS,saved);
  assert(saved.checksum==paletteChecksum(saved));
  saved.mean[0]+=1;assert(saved.checksum!=paletteChecksum(saved));
  // An overlong model row is drained, not interpreted as calibration commands.
  bool oldWhite=haveWhite;Serial.input="@"+std::string(250,'w')+"\n";handleCommands();
  assert(!modelReceiving && haveWhite==oldWhite);
  send("@N 2 0 0 0 0 0 0 0 0 0 0\n"); // All-zero invStd must retain active model.
  assert(paletteReady);
  send("a\n");assert(datasetMode && !clearOnly && !plotMode);
  send("h\n");assert(specialPlot==1 && clearOnly && plotMode);
  send("d\n");assert(specialPlot==2 && !clearOnly && plotMode);
  send("p\n");assert(specialPlot==0 && plotMode && !datasetMode);
  memset(&palette,0,sizeof(palette));paletteReady=false;specialPlot=0;
  setup();assert(paletteReady && palette.count==2 && specialPlot==2);
  send("@N 2 0 0 0 0 0 1 1 1 0 0\n");
  send("@C 0 Black 0.25 0.5 0.125 0 0.01 3000\n");
  send("@C 1 Blue 0.5 0.5 0.125 0 0.01 3000\n");send("@W\n");
  assert(paletteReady && palette.invStd[3]==0);
  x[0]=.25;x[1]=.5;x[2]=.125;x[3]=99;
  assert(classifyColour(x,400,true).accepted==0);
  palette.normalization=1;
  assert(colourFeatures(a,x,clear) && fabs(x[0]-2.0f/7)<1e-6 && fabs(x[1]-4.0f/7)<1e-6);
  palette.darkHz=500;Serial.output.clear();a[3].hz=0;
  colourPlot(a);
  assert(Serial.output.find("LowClear:1")!=std::string::npos);
  assert(Serial.output.find("Invalid:1")!=std::string::npos);
  puts("Firmware feature/classifier/parser/EEPROM checks passed");
}
'''
with tempfile.TemporaryDirectory(prefix='saltiga-fw-test-') as tmp:
    p = Path(tmp)
    (p/'avr').mkdir(); (p/'util').mkdir()
    (p/'Arduino.h').write_text(ARDUINO)
    (p/'EEPROM.h').write_text(EEPROM)
    (p/'avr/interrupt.h').write_text('#define ISR(name) void name()\n#define TIMER1_OVF_vect fakeTimerISR\n')
    (p/'util/atomic.h').write_text('#define ATOMIC_RESTORESTATE 0\n#define ATOMIC_BLOCK(x) for(bool once=true;once;once=false)\n')
    source = p/'test.cpp'
    source.write_text(TEST.replace('SKETCH_PATH', str(ROOT/'uno_saltiga_test/uno_saltiga_test.ino')))
    subprocess.run(['g++', '-std=c++11', '-D__AVR_ATmega328P__', '-I', tmp, str(source), '-o', str(p/'test')], check=True)
    subprocess.run([str(p/'test')], check=True)
