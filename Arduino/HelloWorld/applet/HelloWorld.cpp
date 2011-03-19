/*
 * Math is fun!
 */

#include "math.h"               // include the Math Library

#include "WProgram.h"
void setup();
void loop();
int a = 3;
int b = 4;
int h;

void setup()                    // run once, when the sketch starts
{
  Serial.begin(9600);           // set up Serial library at 9600 bps

  Serial.println("Lets calculate a hypoteneuse");

  Serial.print("a = ");
  Serial.println(a);

  Serial.print("b = ");
  Serial.println(b);
  
  h = sqrt( a*a + b*b );
  
  Serial.print("h = ");
  Serial.println(h);
}

void loop()                // we need this to be here even though its empty
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

