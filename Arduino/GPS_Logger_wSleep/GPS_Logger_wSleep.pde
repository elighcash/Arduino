// this is a generic logger that does checksum testing so the data written should be always good
// Assumes a SiRF Star III chipset logger attached to pin 0 and 1

#include "AF_SDLog.h"
#include "util.h"
#include <avr/pgmspace.h>
#include <avr/sleep.h>

// power saving modes

// Wake (log) for ## seconds, setting to 0 ignores
#define WAKETIME 0

// Sleep for ## seconds
#define SLEEPDELAY 60

#define TURNOFFGPS 0
#define LOG_RMC_FIXONLY 1

AF_SDLog card;
File f;

#define led1Pin 4
#define led2Pin 3
#define powerPin 2

#define BUFFSIZE 75
char buffer[BUFFSIZE];
uint8_t bufferidx = 0;
uint8_t fix = 0; // current fix data
uint8_t i;
unsigned long time;
unsigned int elapsed_time;

/* EXAMPLE

$PSRF100,<protocol>,<baud>,<DataBits>,<StopBits>,<Parity>*CKSUM<CR><LF>
<protocol> 0=SiRF Binary, 1=NMEA, 4=USER1
<baud> 1200, 2400, 4800, 9600, 19200, 38400
<DataBits> 8,7. Note that SiRF protocol is only valid for 8 data bits
<StopBits> 0,1
<Parity> 0=None, 1=Odd, 2=Even
Note: checksum is required

Example 1: Switch to SiRF Binary protocol at 9600,8,N,1
$PSRF100,0,9600,8,1,0*0C<CR><LF>
Do NOT do this, or you will not be able to get back to NMEA protocol

Example 2: Switch to User1 protocol at 38400,8,N,1
$PSRF100,4,38400,8,1,0*38<CR><LF>

*/

#define SERIAL_SET "$PSRF100,1,38400,8,1,0*0E\r\n"

/* EXAMPLE

$PSRF103,<msg>,<mode>,<rate>,<cksumEnable>*CKSUM<CR><LF>

<msg> 00=GGA,01=GLL,02=GSA,03=GSV,04=RMC,05=VTG
<mode> 00=SetRate,01=Query
<rate> Output every <rate>seconds, off=00,max=255
<cksumEnable> 00=disable Checksum,01=Enable checksum for specified message
Note: checksum is required

Example 1: Query the GGA message with checksum enabled
$PSRF103,00,01,00,01*25

Example 2: Enable VTG message for a 1Hz constant output with checksum enabled
$PSRF103,05,00,01,01*20

Example 3: Disable VTG message
$PSRF103,05,00,00,01*21

*/

// GGA-Global Positioning System Fixed Data, message 103,00
#define LOG_GGA 1
#define GGA_ON   "$PSRF103,00,00,01,01*25\r\n"
#define GGA_OFF  "$PSRF103,00,00,00,01*24\r\n"

// GLL-Geographic Position-Latitude/Longitude, message 103,01
#define LOG_GLL 1
#define GLL_ON   "$PSRF103,01,00,01,01*24\r\n"
#define GLL_OFF  "$PSRF103,01,00,00,01*25\r\n"

// GSA-GNSS DOP and Active Satellites, message 103,02
#define LOG_GSA 1
#define GSA_ON   "$PSRF103,02,00,01,01*27\r\n"
#define GSA_OFF  "$PSRF103,02,00,00,01*26\r\n"

// GSV-GNSS Satellites in View, message 103,03
#define LOG_GSV 1
#define GSV_ON   "$PSRF103,03,00,01,01*26\r\n"
#define GSV_OFF  "$PSRF103,03,00,00,01*27\r\n"

// RMC-Recommended Minimum Specific GNSS Data, message 103,04
#define LOG_RMC 1
#define RMC_ON   "$PSRF103,04,00,01,01*21\r\n"
#define RMC_OFF  "$PSRF103,04,00,00,01*20\r\n"

// VTG-Course Over Ground and Ground Speed, message 103,05
#define LOG_VTG 0
#define VTG_ON   "$PSRF103,05,00,01,01*20\r\n"
#define VTG_OFF  "$PSRF103,05,00,00,01*21\r\n"

// Switch Development Data Messages On/Off, message 105
#define LOG_DDM 0
#define DDM_ON   "$PSRF105,01*3E\r\n"
#define DDM_OFF  "$PSRF105,00*3F\r\n"

// Wide Area Augmentation System, message 151
#define USE_WAAS 0
#define WAAS_ON    "$PSRF151,01*3F\r\n"
#define WAAS_OFF   "$PSRF151,00*3E\r\n"


// read a Hex value and return the decimal equivalent
uint8_t parseHex(char c) {
  if (c < '0')
    return 0;
  if (c <= '9')
    return c - '0';
  if (c < 'A')
    return 0;
  if (c <= 'F')
    return (c - 'A')+10;
}

// blink out an error code
void error(uint8_t errno) {
  while(1) {
    for (i=0; i<errno; i++) {
      digitalWrite(led1Pin, HIGH);
      digitalWrite(led2Pin, HIGH);
      delay(100);
      digitalWrite(led1Pin, LOW);
      digitalWrite(led2Pin, LOW);
      delay(100);
    }
    for (; i<10; i++) {
      delay(200);
    }
  }
}

void setup()
{
  WDTCSR |= (1 << WDCE) | (1 << WDE);
  WDTCSR = 0;
  Serial.begin(9600);
  putstring_nl("\r\nGPSlogger");
  pinMode(led1Pin, OUTPUT);
  pinMode(led2Pin, OUTPUT);
  pinMode(powerPin, OUTPUT);
  digitalWrite(powerPin, LOW);

  if (!card.init_card()) {
    putstring_nl("Card init. failed!");
    error(1);
  }
  if (!card.open_partition()) {
    putstring_nl("No partition!");
    error(2);
  }
  if (!card.open_filesys()) {
    putstring_nl("Can't open filesys");
    error(3);
  }
  if (!card.open_dir("/")) {
    putstring_nl("Can't open /");
    error(4);
  }

  strcpy(buffer, "GPSLOG00.TXT");
  for (buffer[6] = '0'; buffer[6] <= '9'; buffer[6]++) {
    for (buffer[7] = '0'; buffer[7] <= '9'; buffer[7]++) {
      //putstring("\ntrying to open ");Serial.println(buffer);
      f = card.open_file(buffer);
      if (!f)
        break;
      card.close_file(f);
    }
    if (!f)
      break;
  }

  if(!card.create_file(buffer)) {
    putstring("couldnt create ");
    Serial.println(buffer);
    error(5);
  }
  f = card.open_file(buffer);
  if (!f) {
    putstring("error opening ");
    Serial.println(buffer);
    card.close_file(f);
    error(6);
  }
  putstring("writing to ");
  Serial.println(buffer);
  putstring_nl("ready!");

  putstring(SERIAL_SET);
  delay(250);

  if (LOG_DDM)
    putstring(DDM_ON);
  else
    putstring(DDM_OFF);
  delay(250);

  if (LOG_GGA)
    putstring(GGA_ON);
  else
    putstring(GGA_OFF);
  delay(250);

  if (LOG_GLL)
    putstring(GLL_ON);
  else
    putstring(GLL_OFF);
  delay(250);

  if (LOG_GSA)
    putstring(GSA_ON);
  else
    putstring(GSA_OFF);
  delay(250);

  if (LOG_GSV)
    putstring(GSV_ON);
  else
    putstring(GSV_OFF);
  delay(250);

  if (LOG_RMC)
    putstring(RMC_ON);
  else
    putstring(RMC_OFF);
  delay(250);

  if (LOG_VTG)
    putstring(VTG_ON);
  else
    putstring(VTG_OFF);
  delay(250);

  if (USE_WAAS)
    putstring(WAAS_ON);
  else
    putstring(WAAS_OFF);
  time = 0;
  elapsed_time = 0;
}

void loop()
{
  //Serial.println(Serial.available(), DEC);
  char c;
  uint8_t sum;

  // read one 'line'
  if (Serial.available()) {
    c = Serial.read();
    //Serial.print(c, BYTE);
    if (bufferidx == 0) {
      while (c != '$')
        c = Serial.read(); // wait till we get a $
    }
    buffer[bufferidx] = c;

    //Serial.print(c, BYTE);
    if (c == '\n') {
      //putstring_nl("EOL");
      //Serial.print(buffer);
      buffer[bufferidx+1] = 0; // terminate it

      if (buffer[bufferidx-4] != '*') {
        // no checksum?
        Serial.print('*', BYTE);
        bufferidx = 0;
        return;
      }
      // get checksum
      sum = parseHex(buffer[bufferidx-3]) * 16;
      sum += parseHex(buffer[bufferidx-2]);

      // check checksum
      for (i=1; i < (bufferidx-4); i++) {
        sum ^= buffer[i];
      }
      if (sum != 0) {
        //putstring_nl("Cxsum mismatch");
        Serial.print('~', BYTE);
        bufferidx = 0;
        return;
      }
      // got good data!

      if (strstr(buffer, "GPRMC")) {
        // find out if we got a fix
        char *p = buffer;
        p = strchr(p, ',')+1;
        p = strchr(p, ',')+1;       // skip to 3rd item

        if (p[0] == 'V') {
          digitalWrite(led1Pin, LOW);
          fix = 0;
        } else {
          digitalWrite(led1Pin, HIGH);
          fix = 1;
        }
      }
      if (LOG_RMC_FIXONLY) {
        if (!fix) {
          Serial.print('_', BYTE);
          bufferidx = 0;
          return;
        }
      }
      // rad. lets log it!
      Serial.print(buffer);
      Serial.print('#', BYTE);
      digitalWrite(led2Pin, HIGH);      // sets the digital pin as output

      if(card.write_file(f, (uint8_t *) buffer, bufferidx) != bufferidx) {
         putstring_nl("can't write!");
    return;
      }

      digitalWrite(led2Pin, LOW);

      bufferidx = 0;

      // turn off GPS module?
      if (TURNOFFGPS) {
        digitalWrite(powerPin, HIGH);
      }
      elapsed_time = millis() - time;
      if (elapsed_time >= WAKETIME * 1000) {
        sleep_sec(SLEEPDELAY);
        digitalWrite(powerPin, LOW);
        elapsed_time = 0;
        time = millis();
      }
      return;
    }
    bufferidx++;
    if (bufferidx == BUFFSIZE-1) {
      Serial.print('!', BYTE);
      bufferidx = 0;
    }
  } else {

  }

}

void sleep_sec(uint8_t x) {
  while (x--) {
     // set the WDT to wake us up!
    WDTCSR |= (1 << WDCE) | (1 << WDE); // enable watchdog & enable changing it
    WDTCSR = (1<< WDE) | (1 <<WDP2) | (1 << WDP1);
    WDTCSR |= (1<< WDIE);
    set_sleep_mode(SLEEP_MODE_PWR_DOWN);
    sleep_enable();
    sleep_mode();
    sleep_disable();
  }
}

SIGNAL(WDT_vect) {
  WDTCSR |= (1 << WDCE) | (1 << WDE);
  WDTCSR = 0;
}
