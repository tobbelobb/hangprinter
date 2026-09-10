/*
  MA600A breakout commissioning programmer

  Connections are documented in ../README.md. The breakout must be powered
  from 5 V. Never feed its TP7 3V3 test point.
*/

#include <Arduino.h>
#include <SPI.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>

constexpr uint8_t CS_PIN = 10;
constexpr uint32_t SERIAL_BAUD = 115200;
constexpr uint32_t SPI_HZ = 100000;
const SPISettings MA600A_SPI(SPI_HZ, MSBFIRST, SPI_MODE0);

constexpr uint8_t REG_ZERO0 = 0x00;
constexpr uint8_t REG_ZERO1 = 0x01;
constexpr uint8_t REG_BCT0 = 0x02;
constexpr uint8_t REG_BCT1 = 0x03;
constexpr uint8_t REG_ABZ0 = 0x04;
constexpr uint8_t REG_ABZ1 = 0x05;
constexpr uint8_t REG_DIR = 0x09;
constexpr uint8_t REG_HYST = 0x0c;
constexpr uint8_t REG_FILTER = 0x0d;
constexpr uint8_t REG_STATUS = 0x1a;

char input_line[96];
uint8_t input_length = 0;

uint16_t transferFrame(uint16_t tx) {
  SPI.beginTransaction(MA600A_SPI);
  digitalWrite(CS_PIN, LOW);
  delayMicroseconds(1);
  const uint8_t rx_high = SPI.transfer(static_cast<uint8_t>(tx >> 8));
  const uint8_t rx_low = SPI.transfer(static_cast<uint8_t>(tx));
  delayMicroseconds(1);
  digitalWrite(CS_PIN, HIGH);
  SPI.endTransaction();
  delayMicroseconds(1);
  return (static_cast<uint16_t>(rx_high) << 8) | rx_low;
}

uint16_t readAngleRaw() { return transferFrame(0x0000); }

uint8_t readRegister(uint8_t address) {
  transferFrame(0xd200 | address);
  return static_cast<uint8_t>(transferFrame(0x0000));
}

bool writeRegister(uint8_t address, uint8_t value) {
  transferFrame(0xea54);
  transferFrame((static_cast<uint16_t>(address) << 8) | value);
  const uint8_t echoed = static_cast<uint8_t>(transferFrame(0x0000));
  const uint8_t readback = readRegister(address);
  if (echoed != value || readback != value) {
    Serial.print(F("VERIFY FAILED: echo=0x"));
    if (echoed < 0x10) Serial.print('0');
    Serial.print(echoed, HEX);
    Serial.print(F(" readback=0x"));
    if (readback < 0x10) Serial.print('0');
    Serial.println(readback, HEX);
    return false;
  }
  return true;
}

void storeBlock(uint8_t block) {
  transferFrame(0xea55);
  transferFrame(0xea00 | block);
  delay(650);
}

void restoreAll() {
  transferFrame(0xea56);
  delayMicroseconds(300);
}

void clearErrors() { transferFrame(0xd700); }

void printHex8(uint8_t value) {
  Serial.print(F("0x"));
  if (value < 0x10) Serial.print('0');
  Serial.print(value, HEX);
}

void printHelp() {
  Serial.println(F("MA600A commands:"));
  Serial.println(F("  help                         show this list"));
  Serial.println(F("  angle                        read one 16-bit angle"));
  Serial.println(F("  stream [count] [delay_ms]    print angle CSV (defaults 100, 20)"));
  Serial.println(F("  config                       decode important settings"));
  Serial.println(F("  read <address>               read an 8-bit register"));
  Serial.println(F("  write <address> <value>      volatile register write"));
  Serial.println(F("  bct x|y <0..255>             volatile side-shaft trim"));
  Serial.println(F("  bct off                      disable BCT in RAM"));
  Serial.println(F("  calc-bct <k>                 calculate BCT from Brad/Btan"));
  Serial.println(F("  ppr <1..4096>                volatile ABZ pulses/revolution"));
  Serial.println(F("  zero <degrees>               volatile zero angle"));
  Serial.println(F("  direction cw|ccw             volatile positive direction"));
  Serial.println(F("  save 0|1 CONFIRM             store one register block to NVM"));
  Serial.println(F("  restore                      reload all settings from NVM"));
  Serial.println(F("  clear-errors                 clear MA600A error flags"));
}

bool parseUnsigned(const char *text, uint32_t maximum, uint32_t &value) {
  if (text == nullptr || *text == '\0' || *text == '-') return false;
  char *end = nullptr;
  const unsigned long parsed = strtoul(text, &end, 0);
  if (*end != '\0' || parsed > maximum) return false;
  value = parsed;
  return true;
}

void printConfig() {
  const uint16_t zero = static_cast<uint16_t>(readRegister(REG_ZERO0)) |
                        (static_cast<uint16_t>(readRegister(REG_ZERO1)) << 8);
  const uint8_t bct = readRegister(REG_BCT0);
  const uint8_t bct_axis = readRegister(REG_BCT1);
  const uint8_t abz0 = readRegister(REG_ABZ0);
  const uint8_t abz1 = readRegister(REG_ABZ1);
  const uint16_t ppt = ((abz0 >> 5) & 0x07) |
                       (static_cast<uint16_t>(abz1) << 3) |
                       (static_cast<uint16_t>(abz0 & 0x01) << 11);
  const bool reverse = (readRegister(REG_DIR) & 0x80) != 0;
  Serial.print(F("zero_raw="));
  Serial.print(zero);
  Serial.print(F(" zero_deg="));
  Serial.println(static_cast<double>(zero) * 360.0 / 65536.0, 4);
  Serial.print(F("bct="));
  Serial.print(bct);
  Serial.print(F(" axis="));
  if ((bct_axis & 0x03) == 0x01) Serial.println(F("X"));
  else if ((bct_axis & 0x03) == 0x02) Serial.println(F("Y"));
  else if ((bct_axis & 0x03) == 0x00) Serial.println(F("off"));
  else Serial.println(F("INVALID (X and Y both enabled)"));
  Serial.print(F("ppr="));
  Serial.println(ppt + 1);
  Serial.print(F("positive_direction="));
  Serial.println(reverse ? F("CCW") : F("CW"));
  Serial.print(F("hysteresis="));
  Serial.println(readRegister(REG_HYST));
  Serial.print(F("filter_width="));
  Serial.println(readRegister(REG_FILTER) & 0x0f);
  Serial.print(F("status="));
  printHex8(readRegister(REG_STATUS));
  Serial.println();
}

void commandAngle() {
  const uint16_t raw = readAngleRaw();
  Serial.print(F("raw="));
  Serial.print(raw);
  Serial.print(F(" degrees="));
  Serial.println(static_cast<double>(raw) * 360.0 / 65536.0, 4);
}

void commandStream(int argc, char **argv) {
  uint32_t count = 100, delay_ms = 20;
  if ((argc >= 2 && !parseUnsigned(argv[1], 10000, count)) ||
      (argc >= 3 && !parseUnsigned(argv[2], 60000, delay_ms)) || count == 0) {
    Serial.println(F("Usage: stream [1..10000] [0..60000]"));
    return;
  }
  Serial.println(F("sample,raw,degrees"));
  for (uint32_t i = 0; i < count; ++i) {
    const uint16_t raw = readAngleRaw();
    Serial.print(i);
    Serial.print(',');
    Serial.print(raw);
    Serial.print(',');
    Serial.println(static_cast<double>(raw) * 360.0 / 65536.0, 4);
    if (delay_ms) delay(delay_ms);
  }
}

void commandRead(int argc, char **argv) {
  uint32_t address;
  if (argc != 2 || !parseUnsigned(argv[1], 0xff, address)) {
    Serial.println(F("Usage: read <0x00..0xff>"));
    return;
  }
  printHex8(static_cast<uint8_t>(address));
  Serial.print(F(" = "));
  printHex8(readRegister(static_cast<uint8_t>(address)));
  Serial.println();
}

void commandWrite(int argc, char **argv) {
  uint32_t address, value;
  if (argc != 3 || !parseUnsigned(argv[1], 0xff, address) ||
      !parseUnsigned(argv[2], 0xff, value)) {
    Serial.println(F("Usage: write <0x00..0xff> <0x00..0xff>"));
    return;
  }
  if (writeRegister(static_cast<uint8_t>(address), static_cast<uint8_t>(value)))
    Serial.println(F("OK (volatile; use save only after verification)"));
}

void commandBct(int argc, char **argv) {
  if (argc == 2 && strcasecmp(argv[1], "off") == 0) {
    if (writeRegister(REG_BCT1, 0x00)) Serial.println(F("BCT disabled (volatile)."));
    return;
  }
  uint32_t value;
  if (argc != 3 || !parseUnsigned(argv[2], 255, value) ||
      (strcasecmp(argv[1], "x") != 0 && strcasecmp(argv[1], "y") != 0)) {
    Serial.println(F("Usage: bct x|y <0..255>, or: bct off"));
    return;
  }
  const uint8_t axis = strcasecmp(argv[1], "x") == 0 ? 0x01 : 0x02;
  if (writeRegister(REG_BCT0, static_cast<uint8_t>(value)) && writeRegister(REG_BCT1, axis)) {
    Serial.print(F("BCT set to "));
    Serial.print(value);
    Serial.print(F(" on axis "));
    Serial.print(axis == 0x01 ? 'X' : 'Y');
    Serial.println(F(" (volatile)."));
    if (value > 200) Serial.println(F("Warning: datasheet notes increased temperature sensitivity above 200."));
  }
}

void commandCalcBct(int argc, char **argv) {
  if (argc != 2) {
    Serial.println(F("Usage: calc-bct <k>, where k=Brad/Btan and k>=1"));
    return;
  }
  char *end = nullptr;
  const double k = strtod(argv[1], &end);
  if (*argv[1] == '\0' || *end != '\0' || !(k >= 1.0) || k > 1000000.0) {
    Serial.println(F("k must be a number >= 1."));
    return;
  }
  const long result = static_cast<long>(258.0 * (1.0 - 1.0 / k) + 0.5);
  Serial.print(F("calculated_bct="));
  Serial.println(result);
  if (result > 255) Serial.println(F("Result exceeds the 8-bit register; empirical calibration is required."));
  else if (result > 200) Serial.println(F("Warning: datasheet notes increased temperature sensitivity above 200."));
}

void commandPpr(int argc, char **argv) {
  uint32_t ppr;
  if (argc != 2 || !parseUnsigned(argv[1], 4096, ppr) || ppr == 0) {
    Serial.println(F("Usage: ppr <1..4096>"));
    return;
  }
  const uint16_t ppt = static_cast<uint16_t>(ppr - 1);
  const uint8_t old_abz0 = readRegister(REG_ABZ0);
  const uint8_t new_abz0 = (old_abz0 & 0x1e) |
                           static_cast<uint8_t>((ppt & 0x07) << 5) |
                           static_cast<uint8_t>((ppt >> 11) & 0x01);
  const uint8_t new_abz1 = static_cast<uint8_t>((ppt >> 3) & 0xff);
  if (writeRegister(REG_ABZ0, new_abz0) && writeRegister(REG_ABZ1, new_abz1)) {
    Serial.print(F("PPR set to "));
    Serial.print(ppr);
    Serial.println(F(" (volatile)."));
  }
}

void commandZero(int argc, char **argv) {
  if (argc != 2) {
    Serial.println(F("Usage: zero <0.0..359.999>"));
    return;
  }
  char *end = nullptr;
  const double degrees = strtod(argv[1], &end);
  if (*argv[1] == '\0' || *end != '\0' || !(degrees >= 0.0 && degrees < 360.0)) {
    Serial.println(F("Degrees must be in the range 0 <= angle < 360."));
    return;
  }
  uint32_t rounded = static_cast<uint32_t>(degrees * 65536.0 / 360.0 + 0.5);
  if (rounded > 65535) rounded = 65535;
  const uint16_t raw = static_cast<uint16_t>(rounded);
  if (writeRegister(REG_ZERO0, static_cast<uint8_t>(raw)) &&
      writeRegister(REG_ZERO1, static_cast<uint8_t>(raw >> 8))) {
    Serial.print(F("Zero set to raw "));
    Serial.print(raw);
    Serial.println(F(" (volatile)."));
  }
}

void commandDirection(int argc, char **argv) {
  if (argc != 2 || (strcasecmp(argv[1], "cw") != 0 && strcasecmp(argv[1], "ccw") != 0)) {
    Serial.println(F("Usage: direction cw|ccw"));
    return;
  }
  uint8_t value = readRegister(REG_DIR) & 0x7f;
  if (strcasecmp(argv[1], "ccw") == 0) value |= 0x80;
  if (writeRegister(REG_DIR, value)) Serial.println(F("Direction changed (volatile)."));
}

void commandSave(int argc, char **argv) {
  uint32_t block;
  if (argc != 3 || !parseUnsigned(argv[1], 1, block) || strcmp(argv[2], "CONFIRM") != 0) {
    Serial.println(F("Usage: save 0|1 CONFIRM"));
    return;
  }
  Serial.println(F("Writing NVM; keep power and probes steady..."));
  storeBlock(static_cast<uint8_t>(block));
  Serial.println(F("Store command complete. Power-cycle and run config to verify."));
}

void processCommand(char *line) {
  char *argv[5];
  int argc = 0;
  for (char *token = strtok(line, " \t"); token != nullptr && argc < 5; token = strtok(nullptr, " \t"))
    argv[argc++] = token;
  if (argc == 0) return;
  if (strcasecmp(argv[0], "help") == 0) printHelp();
  else if (strcasecmp(argv[0], "angle") == 0) commandAngle();
  else if (strcasecmp(argv[0], "stream") == 0) commandStream(argc, argv);
  else if (strcasecmp(argv[0], "config") == 0) printConfig();
  else if (strcasecmp(argv[0], "read") == 0) commandRead(argc, argv);
  else if (strcasecmp(argv[0], "write") == 0) commandWrite(argc, argv);
  else if (strcasecmp(argv[0], "bct") == 0) commandBct(argc, argv);
  else if (strcasecmp(argv[0], "calc-bct") == 0) commandCalcBct(argc, argv);
  else if (strcasecmp(argv[0], "ppr") == 0) commandPpr(argc, argv);
  else if (strcasecmp(argv[0], "zero") == 0) commandZero(argc, argv);
  else if (strcasecmp(argv[0], "direction") == 0) commandDirection(argc, argv);
  else if (strcasecmp(argv[0], "save") == 0) commandSave(argc, argv);
  else if (strcasecmp(argv[0], "restore") == 0) {
    restoreAll();
    Serial.println(F("Registers restored from NVM."));
  } else if (strcasecmp(argv[0], "clear-errors") == 0) {
    clearErrors();
    Serial.println(F("Error-clear command sent."));
  } else Serial.println(F("Unknown command. Type help."));
}

void setup() {
  pinMode(CS_PIN, OUTPUT);
  digitalWrite(CS_PIN, HIGH);
  SPI.begin();
  Serial.begin(SERIAL_BAUD);
  delay(50);
  Serial.println(F("MA600A programmer ready. Type help."));
  Serial.println(F("Writes are volatile until: save 0 CONFIRM"));
}

void loop() {
  while (Serial.available() > 0) {
    const char c = static_cast<char>(Serial.read());
    if (c == '\r') continue;
    if (c == '\n') {
      input_line[input_length] = '\0';
      processCommand(input_line);
      input_length = 0;
    } else if (input_length < sizeof(input_line) - 1) {
      input_line[input_length++] = c;
    } else {
      input_length = 0;
      Serial.println(F("Input line too long; discarded."));
    }
  }
}
