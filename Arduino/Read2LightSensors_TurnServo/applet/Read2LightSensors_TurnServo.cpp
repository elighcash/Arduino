/*
  Analog input, serial output
 
 Reads an analog input pin, prints the results to the serial monitor.
 
 The circuit:

 * potentiometer connected to analog pin 0.
   Center pin of the potentiometer goes to the analog pin.
   side pins of the potentiometer go to +5V and ground
 
 created over and over again
 by Tom Igoe and everyone who's ever used Arduino
 
 */
 
 #include <Servo.h> 
 
#include "WProgram.h"
void setup();
void loop();
Servo myservo;  // create servo object to control a servo 
 
 
 const int threshold = 200;
 int val;
 int delta;
 const int ledPin = 13;
 void setup() {
  Serial.begin(9600); 
  myservo.attach(9);  // attaches the servo on pin 9 to the servo object 

 }
 
 void loop() {
  // read the analog input into a variable:
   int leftValue = analogRead(0);
   int rightValue = analogRead(1);
   val = map(val, 0,180, 1, 179);  
   
   delta = leftValue - rightValue;
   
if( 0 <= val <= 180){
}  
if (delta > threshold) {
           val = val + 5;
           myservo.write(val);
          digitalWrite(ledPin,LOW);
}
if (rightValue - leftValue > threshold) {
          val = val - 5;
          myservo.write(val);
          digitalWrite(ledPin,LOW);
}
else {
        digitalWrite(ledPin,HIGH);
}
           



//  val = analogRead(0);            // reads the value of the potentiometer (value between 0 and 1023) 
//  val = map(val, 0, 1023, 0, 179);     // scale it to use it with the servo (value between 0 and 180) 
 // myservo.write(val);                  // sets the servo position according to the scaled value 



   // print the result:
   Serial.print("Left Value is ");
  Serial.println(leftValue);
   Serial.print("Right Value is ");
  Serial.println(rightValue);

   // wait 10 milliseconds for the analog-to-digital converter
   // to settle after the last reading:

 }

int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

