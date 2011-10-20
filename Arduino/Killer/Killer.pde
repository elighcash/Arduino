// Sweep
// by BARRAGAN <http://barraganstudio.com> 
// This example code is in the public domain.


#include <Servo.h> 
 
Servo myservo;  // create servo object to control a servo 
                // a maximum of eight servo objects can be created 

int pos = 0;    // variable to store the servo position 
int threshold = 400;

void setup() 
{ 
  Serial.begin(9600); 
  myservo.attach(9);  // attaches the servo on pin 9 to the servo object 
} 
 
 
void loop() {
  myservo.write(0); 
  int sensorValue = analogRead(A0);
if(sensorValue < threshold) {
     myservo.write(180);            
       delay(5000);                    
     myservo.write(0);     
       delay(5000);                    
}
else {
  Serial.println(sensorValue, DEC);
}
} 
