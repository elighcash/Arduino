#include  <LiquidCrystal.h>

LiquidCrystal lcd(7, 8, 9, 10, 11, 12);

byte arrow[8] = {
	B00100,
	B00100,
	B00100,
	B00100,
	B00100,
	B11111,
	B01110,
	B00100
};

byte newCharb[8] = {
	B00100,
	B00100,
	B00100,
	B11111,
	B11111,
	B11111,
	B11111,
	B00100
};

byte newCharc[8] = {
	B11111,
	B00100,
	B00100,
	B00100,
	B00100,
	B11111,
	B01110,
	B00100
};



void setup() {
	lcd.createChar(0, arrow);
        lcd.createChar(1, newCharb);
        lcd.createChar(2, newCharc);
	lcd.begin(16, 2);
	lcd.write(0);
	lcd.write(1);
	lcd.write(2);
        lcd.print("X");
        



}

void loop() {



}
