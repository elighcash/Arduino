/* Photocell simple testing sketch. 

Connect one end of the photocell to 5V, the other end to Analog 0.
Then connect one end of a 10K resistor from Analog 0 to ground 
Connect LED from pin 11 through a resistor to ground 
For more information see www.ladyada.net/learn/sensors/cds.html */

#include "WProgram.h"
void setup(void);
void loop(void);
int potPin = 0;     // the cell and 10K pulldown are connected to a0
int potReading;     // the analog reading from the sensor divider
int speakerTone;
int speakerPin = 2;
int speakerPin2 = 9;

void setup(void) {
  // We'll send debugging information via the Serial monitor
  Serial.begin(9600);   
}

void loop(void) {
  potReading = analogRead(potPin);  
  
  Serial.print("Analog reading is totally ");
  Serial.println(potReading);     // the raw analog reading
  
  speakerTone = map(potReading, 0, 1023, 0, 255);
  analogWrite(speakerPin, speakerTone);
  
  Serial.print("Mapped reading is currently ");
  Serial.println(speakerTone);     // the raw analog reading
  
  digitalWrite(speakerPin2,HIGH);
  
  delay(300);
}

int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

