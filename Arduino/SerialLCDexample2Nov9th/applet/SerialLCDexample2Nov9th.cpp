#include "WProgram.h"
void setup();
void loop();
void selectLineOne();
void selectLineTwo();
void goTo(int position);
void clearLCD();
void backlightOn();
void backlightOff();
void backlight40();
void backlight75();
void serCommand();
int potpin = 0;
int reading = 0;
void setup()
{
  Serial.begin(9600);
  backlightOn();
  
     Serial.print(0xFE, BYTE);   //command flag
   Serial.print(0x04, BYTE);   //scroll left command.
  
}

void loop()
{  
  selectLineOne();
  reading = analogRead(potpin);
  Serial.print("Nick Siemsen Freaking Rocks!!");
  selectLineTwo();
  Serial.print(reading/2);
  delay(100);
   Serial.print(0xFE, BYTE);   //command flag
   Serial.print(0x18, BYTE);   //scroll left command.




}

void selectLineOne(){  //puts the cursor at line 0 char 0.
   Serial.print(0xFE, BYTE);   //command flag
   Serial.print(128, BYTE);    //position
}
void selectLineTwo(){  //puts the cursor at line 0 char 0.
   Serial.print(0xFE, BYTE);   //command flag
   Serial.print(192, BYTE);    //position
}
void goTo(int position) { //position = line 1: 0-15, line 2: 16-31, 31+ defaults back to 0
if (position<16){ Serial.print(0xFE, BYTE);   //command flag
              Serial.print((position+128), BYTE);    //position
}else if (position<32){Serial.print(0xFE, BYTE);   //command flag
              Serial.print((position+48+128), BYTE);    //position 
} else { goTo(0); }
}

void clearLCD(){
   Serial.print(0xFE, BYTE);   //command flag
   Serial.print(0x01, BYTE);   //clear command.
}
void backlightOn(){  //turns on the backlight
    Serial.print(0x7C, BYTE);   //command flag for backlight stuff
    Serial.print(157, BYTE);    //light level.
}
void backlightOff(){  //turns off the backlight
    Serial.print(0x7C, BYTE);   //command flag for backlight stuff
    Serial.print(128, BYTE);     //light level for off.
}

void backlight40(){ //sets backlight to 40%
    Serial.print(0x7C, BYTE);  //command flag
    Serial.print(140, BYTE);   //command to set to 40%
}    
    
void backlight75(){ //sets backlight to 75%
    Serial.print(0x7C, BYTE);  //command flag
    Serial.print(150, BYTE);   //command to set to 75%
}  


void serCommand(){   //a general function to call the command flag for issuing all other commands   
  Serial.print(0xFE, BYTE);
}

int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

