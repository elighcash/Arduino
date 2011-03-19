// RFID reader for Arduino 
// Wiring version by BARRAGAN <http://people.interaction-ivrea.it/h.barragan> 
// Modified for Arudino by djmatic

#include <FatReader.h>
#include <SdReader.h>
#include <avr/pgmspace.h>
#include "WaveUtil.h"
#include "WaveHC.h"
int  val = 0; 
char code[10]; 
int bytesread = 0; 
//Below are the individual RFID codes for each tag, named for the person they were given to.
const char nick[] = "3C00907EA7"; //red one 0009469607
const char vanessa[] = "3C00906358"; //red one 0009462616
const char zack[] = "3C00CDBAD2"; //blue one 0013482706
const char tyler[] = "3C0090B73C"; //yellow one 0009484092
const char tony[] = "3C00909470"; //yellow one 0009475184
const char filler[] = "0101010101";

SdReader card;    // This object holds the information for the card
FatVolume vol;    // This holds the information for the partition on the card
FatReader root;   // This holds the information for the filesystem on the card
FatReader f;      // This holds the information for the file we're play

WaveHC wave;      // This is the only wave (audio) object, since we will only play one at a time

#define DEBOUNCE 100  // button debouncer

// this handy function will return the number of bytes currently free in RAM, great for debugging!   
int freeRam(void)
{
  extern int  __bss_end; 
  extern int  *__brkval; 
  int free_memory; 
  if((int)__brkval == 0) {
    free_memory = ((int)&free_memory) - ((int)&__bss_end); 
  }
  else {
    free_memory = ((int)&free_memory) - ((int)__brkval); 
  }
  return free_memory; 
} 

void sdErrorCheck(void)
{
  if (!card.errorCode()) return;
  putstring("\n\rSD I/O error: ");
  Serial.print(card.errorCode(), HEX);
  putstring(", ");
  Serial.println(card.errorData(), HEX);
  while(1);
}

void setup() { 

Serial.begin(2400); // RFID reader SOUT pin connected to Serial RX pin at 2400bps 
pinMode(7,OUTPUT);   // Set digital pin 2 as OUTPUT to connect it to the RFID /ENABLE pin 
digitalWrite(7, LOW);                  // Activate the RFID reader

   putstring("Free RAM: ");       // This can help with debugging, running out of RAM is bad
  Serial.println(freeRam());      // if this is under 150 bytes it may spell trouble!
  
  // Set the output pins for the DAC control. This pins are defined in the library
  pinMode(2, OUTPUT);
  pinMode(3, OUTPUT);
  pinMode(4, OUTPUT);
  pinMode(5, OUTPUT);
 
  // pin13 LED
  pinMode(13, OUTPUT);
  
    //  if (!card.init(true)) { //play with 4 MHz spi if 8MHz isn't working for you
  if (!card.init()) {         //play with 8 MHz spi (default faster!)  
    putstring_nl("Card init. failed!");  // Something went wrong, lets print out why
    sdErrorCheck();
    while(1);                            // then 'halt' - do nothing!
  }
  
  // enable optimize read - some cards may timeout. Disable if you're having problems
  card.partialBlockRead(true);
 
// Now we will look for a FAT partition!
  uint8_t part;
  for (part = 0; part < 5; part++) {     // we have up to 5 slots to look in
    if (vol.init(card, part)) 
      break;                             // we found one, lets bail
  }
  if (part == 5) {                       // if we ended up not finding one  :(
    putstring_nl("No valid FAT partition!");
    sdErrorCheck();      // Something went wrong, lets print out why
    while(1);                            // then 'halt' - do nothing!
  }
  
  // Lets tell the user about what we found
  putstring("Using partition ");
  Serial.print(part, DEC);
  putstring(", type is FAT");
  Serial.println(vol.fatType(),DEC);     // FAT16 or FAT32?
  
  // Try to open the root directory
  if (!root.openRoot(vol)) {
    putstring_nl("Can't open root dir!"); // Something went wrong,
    while(1);                             // then 'halt' - do nothing!
  }
  
  // Whew! We got past the tough parts.
  putstring_nl("Ready!");
  
}  


 void loop() { 
   



  if(Serial.available() > 0) {          // if data available from reader 
    if((val = Serial.read()) == 10) {   // check for header 
      bytesread = 0; 
      while(bytesread<10) {              // read 10 digit code 
        if( Serial.available() > 0) { 
          val = Serial.read(); 
          if((val == 10)||(val == 13)) { // if header or stop bytes before the 10 digit reading 
            break;                       // stop reading 
          } 
          code[bytesread] = val;         // add the digit           
          bytesread++;                   // ready to read next digit  
        } 
      } 
      if(bytesread == 10) {              // if 10 digit read is complete 
        Serial.print("TAG code is: ");   // possibly a good TAG 
        Serial.println(code);            // print the TAG code 
      } 
      bytesread = 0; 

      delay(500);

//Here is where we start to check if the RFID data read matches one of our authorized users.    
//Check to see if it is Nick  
 if(strcmp( code, nick ) == 0){

  Serial.println("ACCESS GRANTED. Welcome Nick."); 
   accessFlash();
   playcomplete("NICKHOME.WAV"); //note that these file names sometimes do strange things when loaded onto the SD card.
   playfile("HUSTLIN.WAV");  //the first .WAV "NICKHOME.WAV" plays a greeting, then this line plays the song.
     Serial.flush( );
 }
//Check to see if it is Vanessa
else if(strcmp( code, vanessa ) == 0){
 
  Serial.println("ACCESS GRANTED. Welcome Vanessa.");
  accessFlash();
  playcomplete("VANESS~1.WAV");
  playfile("GRAYRACE.WAV");
  Serial.flush( );
}
//Check to see if it is Zack
else if(strcmp( code, zack ) == 0){
 
  Serial.println("ACCESS GRANTED. Welcome Zack.");
  accessFlash();
  playcomplete("ZACKHOME.WAV");
  playfile("THEBOSS.WAV");
  Serial.flush( );
}
//Check to see if it is Tyler
else if(strcmp( code, tyler ) == 0){
 
  Serial.println("ACCESS GRANTED. Welcome Tyler.");
  accessFlash();
  playcomplete("TYLERH~1.WAV");
  playfile("06MAND~1.WAV");
  Serial.flush( );
}
//Check to see if it is Tony
else if(strcmp( code, tony ) == 0){
 
  Serial.println("ACCESS GRANTED. Welcome Tony.");
  accessFlash();
  playcomplete("TONYHOME.WAV");
  Serial.flush( );
}

else{
  Serial.println(code);
  Serial.println("ACCESS DENIED");
  deniedFlash();
  Serial.flush( );
}


} 
 }

} 


void accessFlash(){
   digitalWrite(13, HIGH);
   delay(100);
   digitalWrite(13, LOW);
      delay(100);
      digitalWrite(13, HIGH);
   delay(100);
   digitalWrite(13, LOW);
      delay(100);
      digitalWrite(13, HIGH);
   delay(100);
   digitalWrite(13, LOW);
     delay(1000);
}
void deniedFlash(){
   digitalWrite(12, HIGH);
   delay(100);
   digitalWrite(12, LOW);
      delay(100);
      digitalWrite(12, HIGH);
   delay(100);
   digitalWrite(12, LOW);
      delay(100);
      digitalWrite(12, HIGH);
   delay(100);
   digitalWrite(12, LOW);
     delay(1000);
}

// Plays a full file from beginning to end with no pause.
void playcomplete(char *name) {
  // call our helper to find and play this name
  playfile(name);
  while (wave.isplaying) {
  // do nothing while its playing
  }
  // now its done playing
}

void playfile(char *name) {
  // see if the wave object is currently doing something
  if (wave.isplaying) {// already playing something, so stop it!
    wave.stop(); // stop it
  }
  // look in the root directory and open the file
  if (!f.open(root, name)) {
    putstring("Couldn't open file "); Serial.print(name); return;
  }
  // OK read the file and turn it into a wave object
  if (!wave.create(f)) {
    putstring_nl("Not a valid WAV"); return;
  }
  
  // ok time to play! start playback
  wave.play();
}
// extra stuff
// digitalWrite(2, HIGH);             // deactivate RFID reader 





