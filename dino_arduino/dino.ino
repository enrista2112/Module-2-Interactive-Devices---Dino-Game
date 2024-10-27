// Define pins
#define JOY_X_PIN 39       // Joystick X-axis
#define JOY_Y_PIN 32       // Joystick Y-axis
#define JOY_SW_PIN 33      // Joystick button (Z-axis)
#define BUTTON_PIN 2       // Button for shooting
#define LED_PIN 15         // LED to flash at milestone
#define POT_PIN 13         // Potentiometer to adjust game speed

void setup() {
  Serial.begin(9600);  // Start serial communication
  pinMode(JOY_SW_PIN, INPUT_PULLUP);  // Joystick button with pull-up resistor
  pinMode(BUTTON_PIN, INPUT_PULLUP);  // Button with pull-up resistor
  // pinMode(POT_PIN, INPUT_PULLUP);  // Potentiometer with pull-up resistor
  pinMode(LED_PIN, OUTPUT);  // LED as output
}

void loop() {
  // Read joystick values
  int xVal = analogRead(JOY_X_PIN);  // X-axis value
  int yVal = analogRead(JOY_Y_PIN);  // Y-axis value
  int zVal = digitalRead(JOY_SW_PIN);  // Joystick button (Z-axis)
  
  // Read button state
  int buttonState = digitalRead(BUTTON_PIN);  // Button press for shooting
  
  // Read potentiometer value
  int potValue = analogRead(POT_PIN);  // Potentiometer to adjust game speed

  // Send joystick, button, and potentiometer values to Processing
  // Serial.printf("%d,%d,%d,%d,%d", xVal, yVal, zVal, buttonState);
  Serial.printf("%d,%d,%d,%d,%d", xVal, yVal, zVal, buttonState, potValue);
  // buttonState is 0 when pushed
  // zVal is 0 when pushed 
  // Val is 4095 when joystick pushed down and 0 when pushed up resting - 
  // yVal is 4095 when joystick pushed right and 0 when left - resting is 1890

  Serial.println();
  
  // Check for LED control from Processing (milestone hit)
/*  if (Serial.available() > 0) {
    char ledCommand = Serial.read();  // Receive command from Processing
    if (ledCommand == '1') {
      digitalWrite(LED_PIN, HIGH);  // Turn on LED (milestone hit)
    } else {
      digitalWrite(LED_PIN, LOW);   // Turn off LED
    }
  }
*/
  if (Serial.available() > 0) {
    char incomingData = Serial.read();  // Read the incoming data

    // Turn on the LED if '1' is received, turn it off if '0' is received
    if (incomingData == '1') {
      digitalWrite(LED_PIN, HIGH);  // Turn on LED
    } else if (incomingData == '0') {
      digitalWrite(LED_PIN, LOW);  // Turn off LED
    }
  }
  delay(100);  // Delay between loop iterations
}
 