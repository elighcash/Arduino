/*
Author:         BeMasher
Description:    Code sample in C for firing the IR sequence that mimics the
                ML-L1 or ML-L3 IR remote control for most Nikon SLR's.

Based off of:   http://make.refractal.org/?p=3
                http://www.cibomahto.com/2008/10/october-thing-a-day-day-7-nikon-camera-intervalometer-part-1/
                http://ilpleut.be/doku.php/code:nikonremote:start
                http://www.bigmike.it/ircontrol/

Notes:          This differs slightly from the other 3 versions I found in that this doesn't use the built in
                delay functions that the Arduino comes with. I discovered that they weren't accurate enough for
                the values I was trying to give them. The delayMicrosecond() function is only accurate between about
                4uS and 16383uS which isn't a very workable range for the values we need to delay in for this project.
                The ASM code that Matt wrote works well but is limited to only pin 12 and I haven't got a good enough
                grasp of the architecture to modify the code to work on any pin. So this is what I've come up with to
                produce the same result.
*/
#define button 2         //trigger button
#define IR_LED 13        //Pin the IR LED is on
#define DELAY 13         //Half of the clock cycle of a 38.4Khz signal
#define DELAY_OFFSET 4   //The amount of time the micros() function takes to return a value
#define SEQ_LEN 4        //The number of long's in the sequence
int buttonStatus = 0;
unsigned long seq_on[] = {2000, 390, 410, 400};        //Period in uS the LED should oscillate
unsigned long seq_off[] = {27830, 1580, 3580, 0};      //Period in uS that should be delayed between pulses

void setup() {
    Serial.begin(19200);        //Initialize Serial at 19200 baud
    pinMode(IR_LED, OUTPUT);    //Set the IR_LED pin to output
    pinMode(button, INPUT);
}

void customDelay(unsigned long time) {
    unsigned long end_time = micros() + time;    //Calculate when the function should return to it's caller
    while(micros() < end_time);                  //Do nothing 'till we get to the end time
}

void oscillationWrite(int pin, int time) {
    unsigned long end_time = micros() + time;    //Calculate when function should return to it's caller
    while(micros() < end_time) {                 //Until we get to the end time oscillate the LED at 38.4Khz
        digitalWrite(pin, HIGH);
        customDelay(DELAY);
        digitalWrite(pin, LOW);
        customDelay(DELAY - DELAY_OFFSET);        //Assume micros() takes about 4uS to return a value
    }
}

void triggerCamera() {
    for(int i = 0; i < SEQ_LEN; i++) {            //For each long in the sequence
        oscillationWrite(IR_LED, seq_on[i]);      //Oscillate for the current long's value in uS
        customDelay(seq_off[i]);                  //Delay for the current long's value in uS
    }
    customDelay(63200);                            //Wait about 63mS before repeating the sequence
    for(int i = 0; i < SEQ_LEN; i++) {
        oscillationWrite(IR_LED, seq_on[i]);
        customDelay(seq_off[i]);
    }
}

void loop() {
   // if(Serial.available()) {        //Wait 'till something is connected
      //  if(Serial.read() != 0) {    //If anything but 0 is sent take a photo
        buttonStatus = digitalRead(button);
        Serial.println(buttonStatus);
        if(buttonStatus == HIGH) {
            triggerCamera();        //Take a photo
            digitalWrite(IR_LED,LOW);
        }
        else{
          digitalWrite(IR_LED, LOW);
          
        }
        delay(100);                 //Delay an arbitrary amount of time, serial isn't instantaneous
   // }
//}
}
