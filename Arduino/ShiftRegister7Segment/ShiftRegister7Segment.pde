int latchpin = 8; //pin 12 on the shift register
int clockpin = 12; //pin 11 on the shift register
int datapin = 11; //pin 14 on the shift register

void setup()
{
  pinMode(latchpin, OUTPUT);
  pinMode(clockpin, OUTPUT);
  pinMode(datapin, OUTPUT);
}

void loop()
{
  for (int loopy = 0; loopy<256; loopy++)
  {
    digitalWrite(latchpin, LOW);
    shiftOut(datapin, clockpin, MSBFIRST, loopy);
    digitalWrite(latchpin, HIGH);
    delay(100);
  }
}
