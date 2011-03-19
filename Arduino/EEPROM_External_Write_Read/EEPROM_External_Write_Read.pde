//TMP36 Pin Variables
int sensorPin = 2; //the analog pin the TMP36's Vout (sense) pin is connected to
                        //the resolution is 10 mV / degree centigrade with a
                        //500 mV offset to allow for negative temperatures

/*
 * setup() - this function runs once when you turn your Arduino on
 * We initialize the serial connection with the computer
 */
float tmpC = 0.0;
int avg = 1;
int logs = 10;  //number of times to collect data before averaging
int addr = 1; //starting address of the EEPROM 
int temp = 0;
//the address of the device is actually 0x50 (or 80 in binary) or 101000 because all my address pins are pulled to ground


//Begin EEPROM code

#include <Wire.h>

void i2c_eeprom_write_byte( int deviceaddress, unsigned int eeaddress, byte data ) {
  int rdata = data;
  Wire.beginTransmission(deviceaddress);
  Wire.send((int)(eeaddress >> 8)); // MSB
  Wire.send((int)(eeaddress & 0xFF)); // LSB
  Wire.send(rdata);
  Wire.endTransmission();
}

// WARNING: address is a page address, 6-bit end will wrap around
// also, data can be maximum of about 30 bytes, because the Wire library has a buffer of 32 bytes
void i2c_eeprom_write_page( int deviceaddress, unsigned int eeaddresspage, byte* data, byte length ) {
  Wire.beginTransmission(deviceaddress);
  Wire.send((int)(eeaddresspage >> 8)); // MSB
  Wire.send((int)(eeaddresspage & 0xFF)); // LSB
  byte c;
  for ( c = 0; c < length; c++)
    Wire.send(data[c]);
  Wire.endTransmission();
}

byte i2c_eeprom_read_byte( int deviceaddress, unsigned int eeaddress ) {
  byte rdata = 0xFF;
  Wire.beginTransmission(deviceaddress);
  Wire.send((int)(eeaddress >> 8)); // MSB
  Wire.send((int)(eeaddress & 0xFF)); // LSB
  Wire.endTransmission();
  Wire.requestFrom(deviceaddress,1);
  if (Wire.available()) rdata = Wire.receive();
  return rdata;
}

// maybe let's not read more than 30 or 32 bytes at a time!
void i2c_eeprom_read_buffer( int deviceaddress, unsigned int eeaddress, byte *buffer, int length ) {
  Wire.beginTransmission(deviceaddress);
  Wire.send((int)(eeaddress >> 8)); // MSB
  Wire.send((int)(eeaddress & 0xFF)); // LSB
  Wire.endTransmission();
  Wire.requestFrom(deviceaddress,length);
  int c = 0;
  for ( c = 0; c < length; c++ )
    if (Wire.available()) buffer[c] = Wire.receive();
}





//End EEPROM code

 
void setup()
{
  Serial.begin(9600);  //Start the serial connection with the computer
                       //to view the result open the serial monitor 
  Wire.begin();
}
 
void loop()                     // run over and over again
{

for(avg = 0; avg < logs; avg++){  
  
 //getting the voltage reading from the temperature sensor
 int reading = analogRead(sensorPin);  

 // converting that reading to voltage, for 3.3v arduino use 3.3
 float voltage = reading * 4.88 / 1024; 
 
 // print out the voltage
 //Serial.print(voltage); Serial.println(" volts");
 
 // now print out the temperature
 float temperatureC = (voltage - 0.5) * 100 ;  //converting from 10 mv per degree wit 500 mV offset
                                               //to degrees ((volatge - 500mV) times 100)
 tmpC = tmpC + temperatureC; 
 Serial.print(avg); Serial.print(": ");
 Serial.println(tmpC);
 delay(1000); 
}
if(avg = logs){
  
  Serial.print("Temperature Total is: ");
  Serial.println(tmpC);
  tmpC = tmpC / logs;
  
  
  
  Serial.println(avg);                                             
 Serial.print(tmpC); Serial.println(" degress C");
 
  // now convert to Fahrenheight
 float temperatureF = (tmpC * 9 / 5) + 32;
 Serial.print(temperatureF); Serial.println(" degress F");
 
 
 //log the temperature to the EEPROM
 i2c_eeprom_write_byte( 0x50, addr, temperatureF );
 delay(10);
 
 //read back what was just logged to check that it went ok
 Serial.print("I just wrote to and read back the value ");
 temp = i2c_eeprom_read_byte( 0x50, addr );
 Serial.print(temp); Serial.print(" degrees F to the EEPROM at address "); Serial.println(addr);
 
 
 //increment the address to go to the next spot
 addr = addr++; 
 

tmpC = 0; 
avg = 1;

}                                    //waiting a second
}
