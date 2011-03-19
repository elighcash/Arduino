#include <EEPROM.h>

#include "WProgram.h"
void setup();
void loop();
void setup()
{
  // write a 0 to all 512 bytes of the EEPROM
  for (int i = 0; i < 512; i++)
    EEPROM.write(i, 0);

  // turn the LED on when we're done
  digitalWrite(13, HIGH);
}

void loop()
{
}

int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

