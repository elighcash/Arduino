// A simple sketch to read GPS data and parse the $GPRMC string 
// see http://www.ladyada.net/make/gpsshield for more info
//TX should connect to pin 2, RX connects to pin 3 and PWR connects to pin 4.

#include <NewSoftSerial.h>
#include <math.h> // (no semicolon)
#include <SoftwareSerial.h>
#include "SparkFunSerLCD.h"
SparkFunSerLCD led(7,2,16);

NewSoftSerial mySerial =  NewSoftSerial(2, 3);
#define powerpin 4

#define GPSRATE 4800
//#define GPSRATE 38400


// GPS parser for 406a
#define BUFFSIZ 90 // plenty big
char buffer[BUFFSIZ];
char *parseptr;
char buffidx;
uint8_t hour, minute, second, year, month, date;
uint32_t latitude, longitude;
uint8_t groundspeed, trackangle;
char latdir, longdir;
char status;
int velocity, angle, distance, distanceDec;
long lat, lon, lattemp, lontemp;
float latdeg, londeg, x, y, km;
float destinationLat = 33.97570724099378;
float destinationLon = -117.83733308315277;


void printDouble( double val, unsigned int precision){
// prints val with number of decimal places determine by precision
// NOTE: precision is 1 followed by the number of zeros for the desired number of decimial places
// example: printDouble( 3.1415, 100); // prints 3.14 (two decimal places)

    Serial.print (int(val));  //prints the int part
    Serial.print("."); // print the decimal point
    unsigned int frac;
    if(val >= 0)
	  frac = (val - int(val)) * precision;
    else
	  frac = (int(val)- val ) * precision;
    Serial.println(frac,DEC) ;
}



void setup() 
{ 
  
  led.setup();
  delay(3000);
  led.bright (75);
  
  
  if (powerpin) {
    pinMode(powerpin, OUTPUT);
  }
  pinMode(13, OUTPUT);
  Serial.begin(GPSRATE);
  mySerial.begin(GPSRATE);
   
  // prints title with ending line break 
  Serial.println("GPS parser"); 
 
   digitalWrite(powerpin, LOW);         // pull low to turn on!
} 
 
 
void loop() 
{ 
  uint32_t tmp;
  
  Serial.print("\n\rread: ");
  readline();
  
  // check if $GPRMC (global positioning fixed data)
  if (strncmp(buffer, "$GPRMC",6) == 0) {
    
    // hhmmss time data
    parseptr = buffer+7;
    tmp = parsedecimal(parseptr); 
    //some code to convert to Pacific Time
    if(tmp >= 80000){
    
      hour = (tmp / 10000) - 8;
    }
    else{
      hour = 16 + (tmp /10000); 
    }
    //end Pacific Time conversion
    
    minute = (tmp / 100) % 100;
    second = tmp % 100;
    
    parseptr = strchr(parseptr, ',') + 1;
    status = parseptr[0];
    parseptr += 2;
    
    // grab latitude & long data
    // latitude
    latitude = parsedecimal(parseptr);
    if (latitude != 0) {
      latitude *= 10000;
      
      parseptr = strchr(parseptr, '.')+1;
      latitude += parsedecimal(parseptr);
      lat = (long) latitude;
      lattemp = (lat / 1000000) * 1000000;
      latdeg = (lattemp / 1000000.0) + ((lat - lattemp) / 600000.0); 
      
      if (latdir == 'S'){
      latdeg = -latdeg;
      }
    }
    parseptr = strchr(parseptr, ',') + 1;
    // read latitude N/S data
    if (parseptr[0] != ',') {
      latdir = parseptr[0];
    }
    
    //Serial.println(latdir);
    
    // longitude
    parseptr = strchr(parseptr, ',')+1;
    longitude = parsedecimal(parseptr);
    if (longitude != 0) {
      longitude *= 10000;
      
      parseptr = strchr(parseptr, '.')+1;
      longitude += parsedecimal(parseptr);
      lon = (long) longitude;
      lontemp = (lon / 1000000) * 1000000;
      londeg = (lontemp / 1000000.0) + ((lon - lontemp) / 600000.0); 
      if (longdir == 'W'){
      londeg = -londeg;
      }
    }
    parseptr = strchr(parseptr, ',')+1;
    // read longitude E/W data
    if (parseptr[0] != ',') {
      longdir = parseptr[0];
    }
    

    // groundspeed
    parseptr = strchr(parseptr, ',')+1;
    groundspeed = parsedecimal(parseptr);
    velocity = (int) groundspeed;
    // track angle
    parseptr = strchr(parseptr, ',')+1;
    trackangle = parsedecimal(parseptr);
    angle = (int) trackangle;

    // date
    parseptr = strchr(parseptr, ',')+1;
    tmp = parsedecimal(parseptr); 
    //calculate date but adjust by 1 day less if the hour is after 16:00 since this reads GMT
    if(hour > 16) {
     date = (tmp / 10000) - 1; 
    }
    else{
    date = tmp / 10000;
    }
    month = (tmp / 100) % 100;
    year = (tmp % 100) + 2000;
    
    //distance between location and destination
      //rough distance measurement
    x = 111.2057 * (destinationLat - latdeg);
    y = 85.2952 * (destinationLon - londeg);
    km = sqrt((x * x) + (y * y));
    
      //more accurate distance measurement but requires more computation time
    //km = 6378.7 * acos(sin(latdeg/57.2958) * sin(destinationLat/57.2958) + cos(latdeg/57.2958) * cos(destinationLat/57.2958) * cos((destinationLon/57.2958) - (londeg/57.2958)));
    
    //reformatting the km variable into integers to display on the Sparkfun Serial LCD
    //since I had troubles printing longs and floats to it
    distance = km;
    distanceDec = (km * 100) - (distance * 100);
    
    //This section is the ADAFRUIT code that Serial prints some useful data 
  /*  Serial.print("\nTime: ");
    Serial.print(hour, DEC); Serial.print(':');
    Serial.print(minute, DEC); Serial.print(':');
    Serial.println(second, DEC);
    Serial.print("Date: ");
    Serial.print(month, DEC); Serial.print('/');
    Serial.print(date, DEC); Serial.print('/');
    Serial.println(year, DEC);
    
    Serial.print("Lat: "); 
    if (latdir == 'N')
       Serial.print('+');
    else if (latdir == 'S')
       Serial.print('-');

    Serial.print(latitude/1000000, DEC); Serial.print('\°', BYTE); Serial.print(' ');
    Serial.print((latitude/10000)%100, DEC); Serial.print('\''); Serial.print(' ');
    Serial.print((latitude%10000)*6/1000, DEC); Serial.print('.');
    Serial.print(((latitude%10000)*6/10)%100, DEC); Serial.println('"');
   
    Serial.print("Long: ");
    if (longdir == 'E')
       Serial.print('+');
    else if (longdir == 'W')
       Serial.print('-');
    Serial.print(longitude/1000000, DEC); Serial.print('\°', BYTE); Serial.print(' ');
    Serial.print((longitude/10000)%100, DEC); Serial.print('\''); Serial.print(' ');
    Serial.print((longitude%10000)*6/1000, DEC); Serial.print('.');
    Serial.print(((longitude%10000)*6/10)%100, DEC); Serial.println('"');
    
    Serial.print("Speed is:");
    Serial.println(groundspeed, DEC);
    Serial.print("Track Angle is:");
    Serial.println(trackangle, DEC);
    
    */
    
    //My debugging data and testing if my integer variables worked
    Serial.print("Latitude in Degrees is:");
    printDouble(latdeg,10000);
    Serial.print("Longitude in Degrees is:");
    printDouble(londeg,10000);
    Serial.print("Distance from Destination is:");
    printDouble(km,100);
    Serial.print("Distance is also:");
    Serial.print(distance);
    Serial.print(".");
    Serial.print(distanceDec);
   
  
  // Uncomment this if you want basic speed data.  velocity is in MPH 
   // led.at(1,1,"Speed:");
   // led.at(1,8,velocity);
    //led.at(2,1,"Angle:");
   // led.at(2,8,angle);  
   // led.at(1,1,"                ");


// If you are within a certain distance of the final location, then execute this code to open the box, light an LED, sing a song, etc.   
   if(km < 0.1){
     led.at(1,1,"SEI QUA DUDE!!!!");
   }
   
// If you are not within the threshold distance, then tell the user how far they are   
   else{  
  led.at(1,1,"              "); 
  led.at(1,1,"Incorrect. You ");
  led.at(2,1,"are ");
  led.at(2,5,distance);
  led.at(2,8,".");
  led.at(2,9,distanceDec);    
  led.at(2,12,kmOFF");
  
   }    
  }
  //Serial.println(buffer);
}
//other stuff that came with the ADAFRUIT Code and is used to chop up the NMEA data lines from the GPS
uint32_t parsedecimal(char *str) {
  uint32_t d = 0;
  
  while (str[0] != 0) {
   if ((str[0] > '9') || (str[0] < '0'))
     return d;
   d *= 10;
   d += str[0] - '0';
   str++;
  }
  return d;
}

void readline(void) {
  char c;
  
  buffidx = 0; // start at begninning
  while (1) {
      c=mySerial.read();
      if (c == -1)
        continue;
      Serial.print(c);
      if (c == '\n')
        continue;
      if ((buffidx == BUFFSIZ-1) || (c == '\r')) {
        buffer[buffidx] = 0;
        return;
      }
      buffer[buffidx++]= c;
  }
}
