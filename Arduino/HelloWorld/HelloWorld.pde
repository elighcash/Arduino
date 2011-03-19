/*
 * Math is fun!
 */

int a = 5;
int b = 10;
int c = 20;

void setup()                    // run once, when the sketch starts
{
  Serial.begin(9600);           // set up Serial library at 9600 bps

  Serial.println("Here is some math: ");

  Serial.print("a = ");
  Serial.println(a);
  Serial.print("b = ");
  Serial.println(b);
  Serial.print("c = ");
  Serial.println(c);

  Serial.print("a + b = ");       // add
  Serial.println(a + b);

  Serial.print("a * c = ");       // multiply
  Serial.println(a * c);
  
  Serial.print("c / b = ");       // divide
  Serial.println(c / b);
  
  Serial.print("b - c = ");       // subtract
  Serial.println(b - c);
  
  Serial.print("a / c = ");       //divide with decimals
  Serial.println(a / c);
  
    Serial.print("The remainder of c % a = ");       // remainder
  Serial.println(c % a);
  
  
}

void loop()                     // we need this to be here even though its empty
{
}

