/*
GPS Locator v1.1

Changelog:

v1.1:
Added a limit to the number of attempts
Added automatic shut down delay through the inclusion of a Pololu Momentary Power Switch
Updated the SparkFunSerLCD library to use NewSoftSerial instead of SoftwareSerial because  
  the Software Serial library was causing weird characters to appear on the screen.

End Changelog

About:

Code modified from Lady Ada's GPS shield code at http://www.ladyada.net/make/gpsshield
This code gets a fix on the GPS, does some simple calculations, and tells you how far away from 
a preset destination you are currently standing.  

The idea for this project is directly lifted from an AWESOME wedding gift and is detailed at 
http://arduiniana.org/projects/the-reverse-geo-cache-puzzle/

Calculation help provided by the following sites:
http://www.csgnetwork.com/gpsdistcalc.html
http://www.meridianworlddata.com/Distance-Calculation.asp

The code below doesn't stop reporting position until the unit is powered down.  I intend to make changes
so that is it more like the arduiniana project and limits the number of times that you can check the 
distance.

Once you arrive at the destination, nothing special really happens in this code, but I leave that open
to you.  Arduiniana used the arrival code to turn a servo that he has modified into a locking system on 
a decorative box.  Only once you arrived at the destination would the box open! Sweet.

The Sparkfun Serial LCD prints some garbage at times, probably because of the NewSoftSerial data
and the data coming from the GPS unit.  No big deal.

There are parts of this code that are not really used but could be incorporated into a logging system
so that you could go back later and see when the user pressed the button to check location.
Examples of unused data are time, month, year, groundspeed, and track angle.

End About

*/

//GPS TX should connect to pin 2, RX connects to pin 3 and PWR connects to pin 4.
// Sparkfun Serial LCD 16x2 was used and is connected to digital pin 7

#include <EEPROM.h>         //Used to read and write the number of user attempts to the onboard memory.  
#include <NewSoftSerial.h>  //For the GPS and the Sparkfun LCD
#include <math.h> // (no semicolon) Included because we need the square root calculation in calculating distance from destination
//#include <SoftwareSerial.h>  //IMPORTANT!  Not needed, I updated the SparkFunSerLCD.cpp and .h files to use NewSoftSerial instead of SoftwareSerial.  Just open those files with a text editor and replace all instances of "SoftwareSerial" with "NewSoftSerial".
#include "SparkFunSerLCD.h"  //Sparkfun Serial LCD library
SparkFunSerLCD led(7,2,16);  //Sparkfun Serial LCD connected to pin 7, 2 rows, 16 columns

/*Enter your destination next

The easy way to find it is to go to google.com/maps and center the map on
the location you want as your destination.  Then enter the following into 
the address bar and you will get the values you need in GPS degrees decimal
to enter below.  

Enter the following into the address bar:

javascript:void(prompt('',gApplication.getMap().getCenter()));

Credit for the above javascript line goes to - http://www.tech-recipes.com/rx/2403/google_maps_get_latitude_longitude_values/

*/

// SET ALL OF THE IMPORTANT VARIABLES BELOW THAT WILL CHANGE THE BEHAVIOR OF THE UNIT

//------------------------------------------BEGIN USER INPUT--------------------------------------------------------//
//Set your latitude/longitude coordinates below.
float destinationLat = 33.9757;
float destinationLon = -117.8373;
float threshold = 0.1;  //this is how close in km the unit has to be before it executes the arrival code.  
                        //For instance, a 1.0 would mean that the arrival code would execute within a one kilometer circle of the destination.
int shutdownDelay = 30000; //The number of milliseconds that the distance from location will display before the unit shuts down and an attempt is logged
int allowedAttempts = 30;      //Total number of attempts allowed to locate the desination

//-------------------------------------------END USER INPUT----------------------------------------------------------//




NewSoftSerial mySerial =  NewSoftSerial(2, 3);  //Serial pins for the GPS unit
#define powerpin 4    //Power pin of the GPS unit, low turns it on

#define GPSRATE 4800  //baud rate of the GPS unit you are using
//#define GPSRATE 38400


// GPS parser for 406a
#define BUFFSIZ 90 // plenty big
char buffer[BUFFSIZ];
char *parseptr;
char buffidx;
char GPSstatus;
uint8_t hour, minute, second, year, month, date;
uint32_t latitude, longitude;
uint8_t groundspeed, trackangle;
char latdir, longdir;  //Defines the N, S, E and West
char status;           //Defines the status of the GPS lock, V for Void(no lock), A for Active(Lock)
int velocity, angle, distance, distanceDec, kmtimes, attempts;  //Speed, track angle, Distance from destination, Decimal point for distance from destination, number of times we have received a good lock, number times we have calculated distance this time on
long lat, lon, lattemp, lontemp;  //variables to store the latitude and longitude from the GPS unit
float latdeg, londeg, x, y, km;   //Variables to hold the latitude and longitude in degrees instead of what the GPS unit puts out.  x, y, and km are used to calculate the distance from your destination
int pololuPin = 6; //pin for the pololu power switch OFF pin
int addr = 0;      //address of the EEPROM used to store the number of attempts.  Each byte can store a value 0 to 255.


void setup() 
{ 
  
  led.setup();
  delay(3000);
  led.bright (75);                    // set LCD Brightness
  
  pinMode(pololuPin, OUTPUT);          // define the Pololu Switch Off pin as an output
  
  if (powerpin) {
    pinMode(powerpin, OUTPUT);
  }
  Serial.begin(9600);
  mySerial.begin(GPSRATE);
 
   digitalWrite(powerpin, LOW);         // pull low to turn on!
} 
 
 
void loop() 
{   
  uint32_t tmp;

  // print out information received from the GPS unit  
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
    
    // find the comma and go over 1 space to get the Status letter
    parseptr = strchr(parseptr, ',') + 1;
    status = parseptr[0];
    
    // slide over two places to start getting latitude/longitude data
    parseptr += 2; 
    
    
// If your GPS does not have a lock yet then tell the user that they are being located 
if(status != 'A'){    
  //Serial.println("GPS is locating you");
  led.empty();
  led.print("GPS is locating you");
  }
  
// If the lock is money, then do this    
else{ 
   
    // grab latitude & long data
    // latitude
    latitude = parsedecimal(parseptr);
    if (latitude != 0) {
      latitude *= 10000;
      
      parseptr = strchr(parseptr, '.')+1;
      latitude += parsedecimal(parseptr);
      
      // This next conversion is only to display the long variable on the Sparkfun LCD screen.  I couldn't display the floats
      lat = (long) latitude;
      
      // The next two lines are used to convert the latitude data in GPS output into Degrees.  The math for this came from http://www.csgnetwork.com/gpsdistcalc.html    
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
      // Again converting to a long in order to display on the Sparkfun Serial LCD
      lon = (long) longitude;
      // Again converting from GPS coordinates into Degrees Decimal
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
    //calculate date but adjust by 1 day less if the hour is after 16:00 since the GPS outputs GMT and I want PST
    if(hour > 16) {
     date = (tmp / 10000) - 1; 
    }
    else{
    date = tmp / 10000;
    }
    month = (tmp / 100) % 100;
    year = (tmp % 100) + 2000;
    
    //distance between location and destination - calculation help came from http://www.meridianworlddata.com/Distance-Calculation.asp
      //rough distance measurement is this first block     
    x = 111.2057 * (destinationLat - latdeg);
    y = 85.2952 * (destinationLon - londeg);
    km = sqrt((x * x) + (y * y));
    
//more accurate distance measurement but requires more computation time and doesn't really seem to matter much for my purposes
    //km = 6378.7 * acos(sin(latdeg/57.2958) * sin(destinationLat/57.2958) + cos(latdeg/57.2958) * cos(destinationLat/57.2958) * cos((destinationLon/57.2958) - (londeg/57.2958)));
    
    //reformatting the km variable into integers to display on the Sparkfun Serial LCD
    distance = km;
    distanceDec = (km * 10) - (distance * 10);
    
    //This section is the ADAFRUIT code that Serial prints some useful data but is not needed right now.  Good for debugging.
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
// kmtimes is a variable that I set up because the very first km distance from destination calculation was always way off.  
// I haven't spent the time to find out why and this was an easy workaround.  Lazy, I know.
if(kmtimes > 1){

// If you are within a certain distance of the final location, declared as threshold in the setup, then execute this code to open the box, light an LED, sing a song, etc.   
   if(km < threshold){
   // Arrival code below.  All that this does is print "Arrival" to the Sparkfun Serial LCD
     led.empty();
     led.at(1,1,"Arrival");
     led.at(2,1,"Password: 123456");
     delay(3000);
     //Cycle again
     led.empty();
     led.at(1,1,"Arrival");
     led.at(2,1,"Password: 123456");
     delay(shutdownDelay);
     digitalWrite(pololuPin, HIGH);
     
   }
   
// If you are not within the threshold distance, then tell the user how far they are   
   else{  

  attempts = EEPROM.read(addr);   //read the number of attempts so far
  
  if(allowedAttempts - attempts < 1){
  led.empty();
   led.at(1,1,"No More Tries");
   led.at(2,1,"Left. SORRY!");
   delay(5000);
   led.empty();
   led.at(1,1,"Return to Sender");
   delay(5000);
   //Cycle again
   led.at(1,1,"No More Tries");
   led.at(2,1,"Left. SORRY!");
   delay(5000);
   led.empty();
   led.at(1,1,"Return to Sender");
   delay(5000);
   
   digitalWrite(pololuPin, HIGH);
  }

else{  
  attempts += 1;                  //add one to the number of attempts 
  EEPROM.write(addr, attempts);   //write to the EEPROM the new number of tries so far
  
  allowedAttempts = allowedAttempts - attempts;  //display the number of attempts left.  Allowed attempts less number of tries so far.
     
  led.empty();  //clear the screen
  delay(100);
  led.at(1,1,"Incorrect. You ");
  led.at(2,1,"are ");
  led.print(distance);   //I have only allowed 3 digits for distance.  You will have to edit where this stuff prints if you want to make the distance more than 999.99km
                          // 1000km will only display as 100km.  9999999999km will only display 999km.  Just the first three digits.
  led.print(".");        //Put in a decimal point
  led.print(distanceDec);    //Display the integer we set up earlier to display the decimal points.  It will cut off at 2 decimals since my LCD screen is 16x2 only
  led.at(2,11,"km off");
  
  delay(5000);
  
  led.empty();   
  led.at(1,1,allowedAttempts);
  led.print(" Attempts");
  led.at(2,1,"Remaining!");
  //Cycle again
  
  delay(shutdownDelay);       // delay the specified amount of time
  digitalWrite(pololuPin, HIGH);   //write the pololu pin high.  If the "off" pin on the pololu power switch gets >1 volt, it will turn the unit off
}
 }
  } 

// This runs if the count of kmtimes is less than declared in the if statement above.  Remember that this is because the first distance calculation gets messed up so I need it to 
// run through the entire program one more time at least before I will display any distance data to the user.
else{ 
//this iterates kmtimes integer up by one since the very first active fix wasn't giving me back the correct distance calculation
kmtimes +=1;
//Serial.println("Calculating Distance");  //LOL, not really but it looks nice
led.empty();
led.at(1,1,"Calculating");
led.at(2,1,"Distance");
delay(500);
   }   
  }    
 }
}

  //Serial.println(buffer);

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
