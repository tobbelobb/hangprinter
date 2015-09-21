/* pins on the Melzi v1 W/ATmega 644p */
#define Y_STEP_PIN    22
#define Y_DIR_PIN     23
#define Y_MIN_PIN     19
#define Y_ENABLE_PIN  14

/* direction offsets, 8 motors possible */
#define X_DIR_OFFSET 0
#define Y_DIR_OFFSET 1
#define Z_DIR_OFFSET 2
#define E_DIR_OFFSET 3

#define LED_PIN 27

/* basic settings */
#define SERIAL_BAUD_RATE 115200
#define DEFAULT_DELAY    800

/* because i'm lazy */
#define p(x) Serial.print(x)
#define pn(x) Serial.println(x)
#define aw(x,v) analogWrite(x,v)
#define dw(x,v) digitalWrite(x,v)
/* the a4988 stepper driver steps at high-low-high cycle on step pin */
#define STEP_ENGINE(e, d) aw(LED_PIN, 0); dw(e, LOW); dw(e, HIGH); delayMicroseconds(d); aw(LED_PIN, 255);

/* the magic */
#define MAX_ENGINES 8
#define BUFSZ       128    /* max 256 */
#define MESSAGESZ   10
typedef struct {
    uint32_t id;       /* id = 0 means ctrl-msg */
    uint8_t pin;
    uint8_t val;
    uint32_t duration; /* in microseconds */
} message;
typedef struct {
    uint32_t def_delay;
} configuration;
typedef struct {
    message msg[BUFSZ];
    uint8_t head, tail;
} ring_buf;

volatile static ring_buf msg_buf = {{},0,0};
volatile static boolean ringflag = false;
volatile static configuration conf = {DEFAULT_DELAY};    /* should be loaded from EEPROM */ 

void setup() {
    /* enable motors */
    pinMode(Y_STEP_PIN, OUTPUT);
    dw(Y_STEP_PIN, HIGH);
//    pinMode(Y_DIR_PIN, OUTPUT);
//    pinMode(Y_MIN_PIN, INPUT);
    pinMode(Y_ENABLE_PIN, OUTPUT);
    digitalWrite(Y_ENABLE_PIN, LOW);
    Serial.begin(SERIAL_BAUD_RATE);
    pn("*************** commands ***************\n* 0:       toggle dir                  *\n* 1 - 255: number of steps on y-engine *\n****************************************");
    /* turn led pin on after setup */
    pinMode(LED_PIN, OUTPUT);
    aw(LED_PIN, 255);
}

void toggle_dir(uint8_t p, uint8_t o) {
    static uint8_t dir = 0;
    uint8_t msk = 0x01 << o;
    if((dir >> o) & 0x01){ dw(p, LOW); dir &= ~msk; }
    else{ dw(p, HIGH); pn(HIGH); dir |= msk; }
    p("dir toggled to ");
    pn((dir >> o) & 0x01);
}

void parse_msg() {
    uint8_t i;
    volatile uint8_t *upper = (ringflag ? &msg_buf.tail : &msg_buf.head);
    volatile uint8_t *lower = (ringflag ? &msg_buf.head : &msg_buf.tail);
    if(*upper > *lower) {
        for(i = 0; i < MESSAGESZ; i++) {
//            if(msg_buf.head > msg_buf.tail)
        }
        msg_buf.head = (msg_buf.head + 1) % BUFSZ;
        if(!ringflag && msg_buf.head < msg_buf.tail) ringflag = true;
    }
    else {
        /* wait til buf is cleared */
    }
}

/* this sucker should run continously */
void run() {
    
}

void loop() {
    uint8_t i, n, p;
    if((i = Serial.available()) >= MESSAGESZ) {
        parse_msg();
        /* first should be engine *
        n = Serial.read();
        for(n = 0; i; --i) {
            if(n > 9) {
                pn("NaN");
                return;
            }
            n += (Serial.read() - 48) * 10 * i;
        }
        p("# steps: ");
        pn(n);
        /* step n times *
        if(!n) toggle_dir(Y_DIR_PIN, Y_DIR_OFFSET);
        for(i = 0; i < n; i++){ STEP_ENGINE(Y_STEP_PIN, 10); } */
    }
}
