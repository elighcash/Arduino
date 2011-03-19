

/* 
	NOTE: you must: #include <SoftwareSerial.h>
	BEFORE including the SparkFunSerLCD.h header
        This is the code that fucking works!
*/

#include <SoftwareSerial.h>
#include <SparkFunSerLCD.h>

SparkFunSerLCD led(2,2,16); // desired pin, rows, cols

void setup () {

  led.setup();
  delay(1000);
  led.at(1,1,"Milliseconds");
  delay(1000);
  led.off();
  delay(1000);
  led.on();
  led.at(2,1,"m:");
  
  for (int b=0; b<101; b+=5) {
    led.bright(b); b+=5;
    led.at(2,3,millis());
    delay(500);
  }
  
  led.cursorBlock();
  for (int x=5; x<9; x++) {
    led.pos(1,x);
    delay(500);
  }
  
  led.cursorUnderline();
  for (int x=10; x<15; x++) {
    led.pos(1,x);
    delay(500);
  }

  led.cursorOff();
}

void loop () {
  led.at(2,3,millis());
}

