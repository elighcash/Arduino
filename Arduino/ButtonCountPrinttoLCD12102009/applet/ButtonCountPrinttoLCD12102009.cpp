/*
  Button
 
 Turns on and off a light emitting diode(LED) connected to digital  
 pin 13, when pressing a pushbutton attached to pin 7. 
 
 
 The circuit:
 * LED attached from pin 13 to ground 
 * pushbutton attached to pin 2 from +5V
 * 10K resistor attached to pin 2 from ground
 
 * Note: on most Arduinos there is already an LED on the board
 attached to pin 13.
 
 
 created 2005
 by DojoDave <http://www.0j0.org>
 modified 17 Jun 2009
 by Tom Igoe
 
  http://www.arduino.cc/en/Tutorial/Button
 */
 #include <SoftwareSerial.h>
#include "SparkFunSerLCD.h"
#include "WProgram.h"
void setup();
void loop();
SparkFunSerLCD led(3,2,16); // desired pin, rows, cols
// constants won't change. They're used here to 
// set pin numbers:
const int buttonPin = 2;     // the number of the pushbutton pin
const int ledPin =  13;      // the number of the LED pin
int count = 0;
int priorState = 0;

// variables will change:
int buttonState = 0;         // variable for reading the pushbutton status

void setup() {
  
   led.setup();
  delay(1000); 
  
  led.bright(50);
  pinMode(ledPin, OUTPUT);      
  // initialize the pushbutton pin as an input:
  pinMode(buttonPin, INPUT);     
}

void loop(){
  // read the state of the pushbutton value:
  buttonState = digitalRead(buttonPin);
if (buttonState != priorState) {
  
  // check if the pushbutton is pressed.
  // if it is, the buttonState is HIGH:
  if (buttonState == HIGH) { 
    count = count ++;    
    // turn LED on:    
    digitalWrite(ledPin, HIGH); 
   led.at(1,1,"Light is on."); 
   led.at(2,1,count);

  } 
  else {
    // turn LED off:
    digitalWrite(ledPin, LOW); 
    led.at(1,1,"Lights out.     ");
  }
  
  priorState = buttonState;
}
}

int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

