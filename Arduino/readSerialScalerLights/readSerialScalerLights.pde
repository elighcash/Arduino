/*
  Analog input, serial output
 
 Reads an analog input pin, prints the results to the serial monitor.
 
 The circuit:

 * potentiometer connected to analog pin 0.
   Center pin of the potentiometer goes to the analog pin.
   side pins of the potentiometer go to +5V and ground
 
 created over and over again
 by Tom Igoe and everyone who's ever used Arduino
 
 */
 
 
 int white1 = 8;
 int white2 = 9;
 int green1 = 10;
 int green2 = 11;
 int red = 13;
 
 void setup() {
  Serial.begin(9600); 
  
  pinMode(white1, OUTPUT);
  pinMode(white2, OUTPUT);
  pinMode(green1, OUTPUT);
  pinMode(green2, OUTPUT);
  pinMode(red, OUTPUT);
  
 }
 
 void loop() {
  // read the analog input into a variable:
   int analogValue = analogRead(0) * 5;
   // print the result:
   Serial.println(analogValue);
   // wait 10 milliseconds for the analog-to-digital converter
   // to settle after the last reading:
   
   if (analogValue >= 0) {
    digitalWrite(white1, HIGH);
  } 
  
 else{
    digitalWrite(white1,LOW); 
 } 
   if (analogValue > 100) {
    digitalWrite(white2, HIGH);
  } 
   else{
    digitalWrite(white2,LOW); 
 } 
 
   if (analogValue > 200) {
    digitalWrite(green1, HIGH);
  } 
   else{
    digitalWrite(green1,LOW);
 } 
 
 
   if (analogValue > 300) {
    digitalWrite(green2, HIGH);
  } 
   else{
    digitalWrite(green2,LOW);
 } 
 
 
   if (analogValue > 500) {
    digitalWrite(red, HIGH);
  } 
   else{
    digitalWrite(red,LOW);
 } 
 
 

   
   
   
   
   
   
   
   
 }
