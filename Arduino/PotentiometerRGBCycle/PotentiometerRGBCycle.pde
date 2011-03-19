int potpin = 2;              // Switch connected to digital pin 2

int rpin = 9;
int gpin = 10;
int bpin = 11;
float h;
int h_int;
int r=0, g=0, b=0;

int val=0;

void h2rgb(float h, int &R, int &G, int &B);

void setup()                    // run once, when the sketch starts
{
  Serial.begin(9600);           // set up Serial library at 9600 bps
}


void loop()                     // run over and over again
{
  val=analogRead(potpin);    // Read the pin and display the value
  //Serial.println(val);
  h = ((float)val)/1024;
  h_int = (int) 360*h;
  h2rgb(h,r,g,b);
  Serial.print("Potentiometer value: ");
  Serial.print(val);
  Serial.print(" = Hue of ");
  Serial.print(h_int);
  Serial.print("degrees. In RGB this is: ");
  Serial.print(r);
  Serial.print(" ");
  Serial.print(g);
  Serial.print(" ");
  Serial.println(b);

  analogWrite(rpin, r);
  analogWrite(gpin, g);
  analogWrite(bpin, b);
}

void h2rgb(float H, int& R, int& G, int& B) {

  int var_i;
  float S=1, V=1, var_1, var_2, var_3, var_h, var_r, var_g, var_b;

  if ( S == 0 )                       //HSV values = 0 ÷ 1
  {
    R = V * 255;
    G = V * 255;
    B = V * 255;
  }
  else
  {
    var_h = H * 6;
    if ( var_h == 6 ) var_h = 0;      //H must be < 1
    var_i = int( var_h ) ;            //Or ... var_i = floor( var_h )
    var_1 = V * ( 1 - S );
    var_2 = V * ( 1 - S * ( var_h - var_i ) );
    var_3 = V * ( 1 - S * ( 1 - ( var_h - var_i ) ) );

    if      ( var_i == 0 ) {
      var_r = V     ;
      var_g = var_3 ;
      var_b = var_1 ;
    }
    else if ( var_i == 1 ) {
      var_r = var_2 ;
      var_g = V     ;
      var_b = var_1 ;
    }
    else if ( var_i == 2 ) {
      var_r = var_1 ;
      var_g = V     ;
      var_b = var_3 ;
    }
    else if ( var_i == 3 ) {
      var_r = var_1 ;
      var_g = var_2 ;
      var_b = V     ;
    }
    else if ( var_i == 4 ) {
      var_r = var_3 ;
      var_g = var_1 ;
      var_b = V     ;
    }
    else                   {
      var_r = V     ;
      var_g = var_1 ;
      var_b = var_2 ;
    }

    R = (1-var_r) * 255;                  //RGB results = 0 ÷ 255
    G = (1-var_g) * 255;
    B = (1-var_b) * 255;
  }
}
 

