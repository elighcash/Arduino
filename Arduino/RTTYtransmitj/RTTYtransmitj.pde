/*
  AVA Radio Data Transmission Test
  Transmits data via NTX2  
  
 Created 2011
 by Upu http://ava.upuaut.net
 RTTY code from Rob Harrison Icarus Project. 
  
 */

#include <string.h>
#include <util/crc16.h>

int RADIO_SPACE_PIN=4;
int RADIO_MARK_PIN=5; 
char DATASTRING[200];
 
void setup() {                
pinMode(RADIO_SPACE_PIN,OUTPUT);
pinMode(RADIO_MARK_PIN,OUTPUT);

}

void loop() {

   sprintf(DATASTRING,"KJ6DYL TEST RTTY TESTING TESTING TESTING TESTINTG TESTING TESTING ON\n");

// If you uncomment the lines below and comment out the line above a CRC Checksum will be appended to the end of the DATASTRING
//  sprintf(DATASTRING,"M6UPU TEST RTTY BEACON");
//  unsigned int CHECKSUM = gps_CRC16_checksum(DATASTRING);
//  char checksum_str[6];
//  sprintf(checksum_str, "*%04X\n", CHECKSUM);
//  strcat(DATASTRING,checksum_str);

  noInterrupts();
  rtty_txstring (DATASTRING);
  interrupts();
  delay(2000);
}


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
	*/

	int i;

	rtty_txbit (0); // Start bit

	// Send bits for for char LSB first	

	for (i=0;i<7;i++) // Change this here 7 or 8 for ASCII-7 / ASCII-8
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
                    digitalWrite(RADIO_MARK_PIN, HIGH);
                    digitalWrite(RADIO_SPACE_PIN, LOW);
		}
		else
		{
		  // low
                    digitalWrite(RADIO_SPACE_PIN, HIGH);
                    digitalWrite(RADIO_MARK_PIN, LOW);

		}
//                delayMicroseconds(1680); // 600 baud unlikely to work.
                  delayMicroseconds(3370); // 300 baud
//                delayMicroseconds(10000); // For 50 Baud uncomment this and the line below. 
//                delayMicroseconds(10150); // For some reason you can't do 20150 it just doesn't work.

}

void callback()
{
  digitalWrite(RADIO_SPACE_PIN, digitalRead(RADIO_SPACE_PIN) ^ 1);
}
uint16_t gps_CRC16_checksum (char *string)
{
	size_t i;
	uint16_t crc;
	uint8_t c;
 
	crc = 0xFFFF;
 
	// Calculate checksum ignoring the first two $s
	for (i = 2; i < strlen(string); i++)
	{
		c = string[i];
		crc = _crc_xmodem_update (crc, c);
	}
 
	return crc;
}          
