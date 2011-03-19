int receiverPin = 0; // input from the ir receiver.

//unsigned long duration; // time shutter is open
int sensorValue = 0;        // value read from the pot
int outputValue = 0;

void setup()
{
  pinMode(receiverPin, INPUT);
  Serial.begin(9600);
}

void loop()
{
  //digitalWrite(ledPin, !digitalRead(receiverPin)) ;
  //duration = pulseIn(receiverPin, LOW);
  //if(duration != 0 )
  //{
  //  Serial.println(duration);
  //}
  
  sensorValue = analogRead(receiverPin);
    Serial.print("sensor = " );                       
  Serial.println(sensorValue); 
}
