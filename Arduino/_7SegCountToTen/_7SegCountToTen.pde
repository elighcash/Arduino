/* Blink without Delay
 
 Turns on and off a light emitting diode(LED) connected to a digital  
 pin, without using the delay() function.  This means that other code
 can run at the same time without being interrupted by the LED code.
 
  The circuit:
 * LED attached from pin 13 to ground.
 * Note: on most Arduinos, there is already an LED on the board
 that's attached to pin 13, so no hardware is needed for this example.
 
 
 created 2005
 by David A. Mellis
 modified 17 Jun 2009
 by Tom Igoe
 
 http://www.arduino.cc/en/Tutorial/BlinkWithoutDelay
 */


 int timer = 1000;           // The higher the number, the slower the timing.
 int ledPins[] = { 
   2, 7, 4, 6, 5, 3, 8, 9 };       // an array of pin numbers to which LEDs are attached
 int pinCount =8;           // the number of pins (i.e. the length of the array)
 void setup() {
   int thisPin;
   // the array elements are numbered from 0 to (pinCount - 1).
   // use a for loop to initialize each pin as an output:
   for (int thisPin = 0; thisPin < pinCount; thisPin++)  {
     pinMode(ledPins[thisPin], OUTPUT);      
   }
 }
void loop()
{
 //one
  digitalWrite(6 , HIGH);
  digitalWrite(4, HIGH);
  delay(timer);
  digitalWrite(6 , LOW);
  digitalWrite(4, LOW);
  delay(timer);
//two  
  digitalWrite(7 , HIGH);
  digitalWrite(6, HIGH);
    digitalWrite(10 , HIGH);
  digitalWrite(1, HIGH);
    digitalWrite(2 , HIGH);
  delay(timer);
     digitalWrite(7 , LOW  );
  digitalWrite(6, LOW );
    digitalWrite(10 , LOW );
  digitalWrite(1, LOW );
    digitalWrite(2 , LOW);
    
  delay(timer);
 //three 
  
    digitalWrite(7 , HIGH);
  digitalWrite(6, HIGH);
    digitalWrite(10 , HIGH);
  digitalWrite(4, HIGH);
    digitalWrite(2 , HIGH);
  delay(timer);
     digitalWrite(7 , LOW  );
  digitalWrite(6, LOW );
    digitalWrite(10 , LOW );
  digitalWrite(4, LOW );
    digitalWrite(2 , LOW);
    
  delay(timer);
//four  
      digitalWrite(9 , HIGH);
  digitalWrite(6, HIGH);
    digitalWrite(10 , HIGH);
  digitalWrite(4, HIGH);

  delay(timer);
     digitalWrite(9 , LOW  );
  digitalWrite(6, LOW );
    digitalWrite(10 , LOW );
  digitalWrite(4, LOW );

    
  delay(timer);
  
 //five 
  
     digitalWrite(7 , HIGH);
  digitalWrite(9, HIGH);
    digitalWrite(10 , HIGH);
  digitalWrite(4, HIGH);
    digitalWrite(2 , HIGH);
  delay(timer);
     digitalWrite(7 , LOW  );
  digitalWrite(9, LOW );
    digitalWrite(10 , LOW );
  digitalWrite(4, LOW );
    digitalWrite(2 , LOW);
    
  delay(timer);
  
 //six 
 
 
      digitalWrite(1 , HIGH);
  digitalWrite(9, HIGH);
    digitalWrite(10 , HIGH);
  digitalWrite(4, HIGH);
    digitalWrite(2 , HIGH);
  delay(timer);
     digitalWrite(1 , LOW  );
  digitalWrite(9, LOW );
    digitalWrite(10 , LOW );
  digitalWrite(4, LOW );
    digitalWrite(2 , LOW);
    
  delay(timer);
  
  //seven
  

    digitalWrite(7 , HIGH);
  digitalWrite(4, HIGH);
    digitalWrite(6 , HIGH);
  delay(timer);

    digitalWrite(7 , LOW );
  digitalWrite(4, LOW );
    digitalWrite(6 , LOW);
    
  delay(timer);
  
  
 //eight
      digitalWrite(1 , HIGH);
  digitalWrite(9, HIGH);
    digitalWrite(7 , HIGH);
  digitalWrite(4, HIGH);
    digitalWrite(6, HIGH);
    digitalWrite(2 , HIGH);
  delay(timer);
     digitalWrite(1 , LOW  );
  digitalWrite(9, LOW );
    digitalWrite(7 , LOW );
        digitalWrite(6 , LOW );
  digitalWrite(4, LOW );
    digitalWrite(2 , LOW);
    
  delay(timer);
 
 
 
  //nine
      digitalWrite(10 , HIGH);
  digitalWrite(9, HIGH);
    digitalWrite(7 , HIGH);
  digitalWrite(4, HIGH);
    digitalWrite(6, HIGH);

  delay(timer);
     digitalWrite(10 , LOW  );
  digitalWrite(9, LOW );
    digitalWrite(7 , LOW );
        digitalWrite(6 , LOW );
  digitalWrite(4, LOW );
 
    
  delay(timer);
  
    //zero
      digitalWrite(1 , HIGH);
  digitalWrite(9, HIGH);
    digitalWrite(7 , HIGH);
  digitalWrite(4, HIGH);
    digitalWrite(6, HIGH);
   digitalWrite(2, HIGH);
         digitalWrite(5 , HIGH);
  delay(timer);
     digitalWrite(1 , LOW  );
  digitalWrite(9, LOW );
    digitalWrite(7 , LOW );
        digitalWrite(6 , LOW );
  digitalWrite(4, LOW );
   digitalWrite(2, LOW );
    digitalWrite(5, LOW );   
  delay(timer);
 
  }

