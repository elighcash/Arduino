/*
This lets you mash a button connected to pin 2 on the Arduino and counts how many times
you have pressed it in a 10 second time period.  The timer and number of button presses is
refreshed on the screen. The game goes like this...

Turn on Arduino, timer counts down 3, 2, 1....GO!
You press the button as many times as you can in 10 seconds.
Arduino prints the timer and number of presses to the screen as you go.
At the end, Arduino prints "TIme's UP!" and the final score (final number of button presses).

Next thing to do...
Implement high score module.
Add a "Settings" button so that the user can override the start of the game and go into a settings
menu where they can see number of attempts, see high scores, change times, etc.
Make sure that if I put in a variable timer then I post the time with the high scores.

Created 12 Dec 2009
By: Nick Siemsen
 modified 7 Aug 2010

 */
 #include <SoftwareSerial.h>
#include "SparkFunSerLCD.h"
SparkFunSerLCD led(3,2,16); // desired pin, rows, cols
// constants won't change. They're used here to 
// set pin numbers:
const int buttonPin = 2;     // the number of the pushbutton pin
const int ledPin =  13;      // the number of the LED pin
int count = 0;
int priorState = 0;
int second=30, minute=2, hour=0; // declare time variables
int buttonState = 0;         // variable for reading the pushbutton status
  static unsigned long lastTick = 0; // set up a local variable to hold the last time we decremented one second
  static unsigned long timer = 0;

void setup() {
  
   led.setup();
  delay(1000); 
  
  led.bright(50);
  pinMode(ledPin, OUTPUT);      
  // initialize the pushbutton pin as an input:
  pinMode(buttonPin, INPUT);     

  led.at(1,1,"Ready!");
  delay(500);
  led.at(1,1,"                                                      ");
  led.at(1,1,"3");
  delay(1000);
  led.at(1,1,"2");
  delay(1000);
  led.at(1,1,"1");
  delay(1000);
  led.at(1,1,"GO!!!!!!!!!");
  delay(200);


  lastTick = millis();

led.at(1,1,"Time:");

  led.at(1,8,"        ");
   led.at (2,1,"Score:");


}
void loop(){


if(timer >= 10000) {

  led.at(1,1,"TIME IS UP!");
  led.at(2,1,"Final Score:");
  led.at(2,13,count);
}

else{
  timer = millis() - lastTick;
    led.at(1,5,timer);
  // read the state of the pushbutton value:
  buttonState = digitalRead(buttonPin);
if (buttonState != priorState) {
  
  // check if the pushbutton is pressed.
  // if it is, the buttonState is HIGH:
  if (buttonState == HIGH) { 
    count = count ++;    
    // turn LED on:    
    digitalWrite(ledPin, HIGH); 

   
   led.at(2,7,count);

  } 
  else {
    // turn LED off:
    digitalWrite(ledPin, LOW); 
  }
  
  priorState = buttonState;
}
}
}
