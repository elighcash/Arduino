// RGB LED - Color Control With Potentiometers
//
// Matthew L Beckler 
// matthew at mbeckler dot org

int redPin = 11;
int bluePin = 10;
int greenPin = 9;

int redIn = 0;
int greenIn = 1;
int blueIn = 2;

int redVal;
int greenVal;
int blueVal;

void setup()
{
  // nothing to do here
}

void loop()
{
  redVal = analogRead(redIn);
  greenVal = analogRead(greenIn);
  blueVal = analogRead(blueIn);
  
  // analogRead returns a value between 0 and 1023
  // analogWrite wants a value between 0 and 255
  // That means we need to map the input range to
  // the correct output range.
  redVal = map(redVal, 0, 1023, 0, 255);
  greenVal = map(greenVal, 0, 1023, 0, 255);
  blueVal = map(blueVal, 0, 1023, 0, 255);

  analogWrite(redPin, redVal);
  analogWrite(greenPin, greenVal);
  analogWrite(bluePin, blueVal);
}
