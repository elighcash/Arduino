/* Taken from:
** The Icarus Project
** (c) Robert Harrison
** rharrison@hgf.com
** December 2008
**
** rtty.c and rtty.h
** Revison 0.01
** 
**/

#define ASCII_BIT 8
//#define BAUD_RATE 20150     // 10000 = 100 BAUD 20150 : This is the old line - NJS
#define BAUD_RATE 5000
//maybe I should make this 5000 for 50 BAUD - NJS
//Original BAUD_RATE was 20150
void rtty_txbit (int bit);
void rtty_txbyte (char c);
void rtty_txstring (char * string);

void rtty_txstring (char * string)
{

	/* Simple function to sent a char at a time to 
	** rtty_txbyte function. 
	** NB Each char is one byte (8 Bits)
	*/

	char c;

	c = *string++;

	while ( c != '\0')
	{
		rtty_txbyte (c);
		c = *string++;
	}
}


void rtty_txbyte (char c)
{
	/* Simple function to sent each bit of a char to 
	** rtty_txbit function. 
	** NB The bits are sent Least Significant Bit first
	**
	** All chars should be preceded with a 0 and 
	** proceded with a 1. 0 = Start bit; 1 = Stop bit
	**
	** ASCII_BIT = 7 or 8 for ASCII-7 / ASCII-8
	*/

	int i;

	rtty_txbit (0); // Start bit

	// Send bits for for char LSB first	

	for (i=0;i<ASCII_BIT;i++)
	{
		if (c & 1) rtty_txbit(1); 

			else rtty_txbit(0);	

		c = c >> 1;

	}

	rtty_txbit (1); // Stop bit
}

void rtty_txbit (int bit)
{
		if (bit)
		{
		  // high
                    digitalWrite(10, HIGH); //Used to be pin 11
                    digitalWrite(9, LOW);
                    
		}
		else
		{
		  // low
                    digitalWrite(9, HIGH);
                    digitalWrite(10, LOW); //Used to be pin 11
		}
		delayMicroseconds(BAUD_RATE); 
                //delay(500);
                //analogWrite(3, 248);
                //delay(1000);
}

void callback()
{
  digitalWrite(9, digitalRead(9) ^ 1);
}

void setup()
{
  pinMode(9, OUTPUT);
  pinMode(10, OUTPUT); //Used to be pin 11
  Serial.begin(9600);
  Serial.println("TEST");
}

void loop()
{
  rtty_txstring ("Test Arduino TEST TEST KJ6DYL TEST\r\r");
  delay(1000);
}
