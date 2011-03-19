/*
Hall Effect
 
 */
 
//#include <math.h> // (no semicolon)
 #include <SoftwareSerial.h>
#include "SparkFunSerLCD.h"
#include "WProgram.h"
void setup();
void loop();
SparkFunSerLCD led(3,2,16); // desired pin, rows, cols

int sensorPin =  0;           // Hall Effect Sensor connected to analog pin 0
int reading = 0;              // Variable set up to read the Hall Sensor status
unsigned long lastSeen = 0;   // Stores the time in milliseconds that the Arduino reports by millis()
float rpm = 0;                // Variable to store the RPMs
float circum = 5.5;           // Circumference of the tire in feet
long mph = 0;                // Variable to store the MPH
int revs = 0;                 // Used to keep the revolutions of the wheel
int revThreshold = 10;        // Decrease (increase) this number to increase (decrease) number of readings used in the average

// The setup() method runs once, when the sketch starts
void setup()   { 
  
   led.setup();
  delay(1000); 
  
  led.bright(50);
//Begin Serial Communication
Serial.begin(9600);
//set the variable equal to the current millisecond count (not really necessary)
lastSeen = millis();    

led.at(2,1,"Speed:"); 
}

// the loop() method runs over and over again,
// as long as the Arduino has power

void loop()                     
{
  
// Read the Hall Sensor Pin and give back a value.  The sensor that I bought from Adafruit.com seems to hover at
// an analog reading of about 100 and will go all the way to about 5 when the magnet is present
  reading = analogRead(sensorPin);  
   
// If the hall effect sensor is LOW it means that the magnet is there.  The 10 is arbitrary.  The sensor
//actually pulls the pin all the way down to about 5, so the 10 is enough to verify that the pin is low
if(reading < 10){ 
  revs = revs++;   // Increment the revolutions up by one
  led.at(1,1,revs);
  delay(20);       // Wait a moment to let the magnet pass and not trigger revs twice
}

if(revs >= revThreshold){

// RPM = (60 seconds * Number of rotations since prior "lastSeen") / ((time since lastSeen) / 1000) in order go to seconds from milliseconds
  rpm = ((60.0 * revThreshold) / ((float)  (millis() - lastSeen)  / 1000.0));  // I don't know if that (float) is even necessary
  mph = rpm * 60.0 * circum / 5280.0;  // RPM * 60 minutes/hour * circumference of the tire in feet / 5280 feet in a mile
  lastSeen = millis();                 // Set the lastSeen variable equal to the current millis() reading in order to start the cycle over again
  revs = 0;                            // Set revs back to zero so that we can collect revThreshold number of readings agian
  led.at(1,1,"       ");           // Print the speed on a serial display
  led.at(2,8,mph);        
 
  delay(10);                            // Chill Out!
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

