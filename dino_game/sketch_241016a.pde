import processing.serial.*;

Serial myPort;  // Create object from Serial class
String val;     // Data received from the serial port

boolean gameStarted = false;  // To track if the game has started

// dino positions
PImage dino;
PImage dinoStand;
PImage dinoJump;
PImage dinoDuck1;
PImage dinoDuck2;
PImage dinoRun1;
PImage dinoRun2;
PImage dinoTank;

// obstacles
PImage currentObstacle;  // Currently active obstacle image
PImage birdDown;
PImage birdUp;
PImage singleCactus;
PImage doubleCactus;
PImage tripleCactus;
PImage maxCactus;
PImage alien_spaceship;
PImage tankBeam;
PImage explosion;
PImage[] obstacles;  // Declare the obstacles array globally
String[] word_obstacle;

int speed = 5;  // inital game speed - possibly change with potentiometer
int lastSpeedIncreaseTime = 0;  // To track the last time speed was increased
int speedIncreaseInterval = 30000;  // 30 seconds in milliseconds

// cloud for background
int numClouds = 4;
float[] cloudX = new float[numClouds];
float[] cloudY = new float[numClouds];
float[] cloudSpeed = new float[numClouds];
float[] cloudSize = new float[numClouds];
PImage cloudImage;

int dinoWidth = 120;  // Desired dino width
int dinoHeight = 90;  // Desired dino height

int dinoX = 30, dinoY, groundY;
int jumpHeight = 200;  // Adjusted for larger canvas
int jumpProgress = 0;
boolean isJumping = false;

boolean isTankMode = false;  // Flag to check if dino is in tank mode
boolean isShooting = false;  // Flag to check if beam is being shot
boolean explosionActive = false;
int beamX, beamY;
int explosionTimer = 0; // Timer for explosion

int spaceshipX, spaceshipY;
int spaceshipSpeed = 3;  // Speed of alien spaceship

boolean currentObject = false;
int obstacleX = width;  // Start obstacle at the right edge
int obstacleY = groundY - 50;  // Set obstacle height (adjust as needed)
int obstacleWidth;
int obstacleHeight;

boolean gameOver = false;  // Track game over state

// animation timing
int lastFrameChangeTime = 0;
int animationInterval = 500;  // Time in milliseconds to change frames
boolean useRunFrame1 = true;
boolean useBirdUp = true;

int score = 0;  // Initialize score variable
int lastScoreTime = 0;  // To track the last time score was incremented

// start game screen and sizing dino or collision
void setup() {
  size(800, 500);  // Set window size to 500x500
  
  // images need to be in the sketch folder
  
  // cloud image for background
  cloudImage = loadImage("cloud.jpg");  
  for (int i = 0; i < numClouds; i++) {
    cloudX[i] = random(width, width + 200);  // Start clouds off-screen to the right
    cloudY[i] = random(50, 200);  // Random vertical positions
    cloudSize[i] = random(50, 150);  // Random sizes for the clouds
    cloudSpeed[i] = random(0.5, 1.5);  // Random speed for each cloud
  }

  dinoStand = loadImage("transparent_dino.png");
  dinoJump = loadImage("transparent_dino.png");
  dino = dinoStand;  // Set initial dino state to standing
  dinoDuck1 = loadImage("dino_duck_back.png");
  dinoDuck2 = loadImage("dino_duck_front.png");
  dinoRun1 = loadImage("dino_run_front.png");
  dinoRun2 = loadImage("dino_run_back.png");
  dinoTank = loadImage("tank.png");

  birdDown = loadImage("bird_down.png");
  birdUp = loadImage("bird_up.png");
  singleCactus = loadImage("cactus1.png");
  doubleCactus = loadImage("cactus2.png");
  tripleCactus = loadImage("cactus3.png");
  // maxCactus = loadImage("large-cactus.png");
  maxCactus = loadImage("file.png");
  alien_spaceship = loadImage("alien.png");
  tankBeam = loadImage("beam.png");
  explosion = loadImage("explosion.png");
  obstacles = new PImage[] {birdDown, birdUp, singleCactus, doubleCactus, tripleCactus, maxCactus};
  word_obstacle = new String[] {"bird", "singleCactus", "doubleCactus", "tripleCactus", "maxCactus"};

  // Set initial dino position
  dinoY = height - dinoHeight - 45;  // Adjust for larger canvas and dino size
  groundY = height - 68;  // Adjust for larger canvas
  // height - 65 is feetare below ground line
  
  // Setup serial communication with Arduino
  printArray(Serial.list());
  String portName = Serial.list()[6];  // Make sure you choose the correct port
  println(portName);
  myPort = new Serial(this, portName, 9600); // Ensure baud rate matches your Arduino
}

void draw() {
  background(255);  // White background
  
  if (!gameStarted) {
    displayStarterScreen();  // Show the starter screen
    checkForGameStart();  // Check for button press to start the game
    return;  // Skip the game logic until the game starts
  }
   
  if (gameOver) {
    displayGameOver();  // Show the "Game Over" screen
    checkForGameReset();  // Check for button press to reset the game
    return;  // Skip further game updates if gameOver is true
  }

  score();

  // increase speed every 30 seconds
  increaseSpeed();
  
  // Draw ground
  stroke(0);  // Black color for ground line
  line(0, groundY, width, groundY);
  
  // draw clouds
  cloud();

  // Read from the Arduino
  if (myPort.available() > 0) {
    String data = myPort.readStringUntil('\n');
    if (data != null) {
      data = trim(data);
      String[] vals = split(data, ',');
      if (vals.length == 5) {
        int xVal = int(vals[0]);
        int yVal = int(vals[1]);
        int zVal = int(vals[2]);
        int buttonState = int(vals[3]);
        int potValue = int(vals[4]);

        // Handle jump, duck, and stand states based on joystick input
        if (yVal > 3000 && !isJumping) {  // Joystick down for duck
          // dino = dinoDuck1;  // Switch to duck image
          handleDinoDucking();
        } else if (yVal < 1000) {  // Joystick up for jump
          isJumping = true;
          jumpProgress = 0;
          // dino = dinoJump;  // Switch to jump image
        } else {
          // dino = dinoStand;  // Default to standing image
          handleDinoRunning();
        }
        
        if (zVal == 0 && gameOver) {  // Button pressed (0 value) and game is over
          resetGame();  // Reset game state
        }
        // Use potentiometer to adjust speed
        // speed = (int) map(potValue, 0, 1023, 2, 10);
        adjustSpeed(potValue);  // Call function to adjust speed based on potValue
      }
    }
  }

    // Handle the jumping logic
  if (isJumping) {
    jump();  // Call the jump function if currently jumping
  }

  // Draw the dino
  if (dino == dinoDuck1 || dino == dinoDuck2) {  // image for ducking dino
    image(dino, dinoX, dinoY + 50, dinoWidth - 50, dinoHeight - 45);
  } else if (dino == dinoRun1 || dino == dinoRun2) { //image for jumping dino
    image(dino, dinoX, dinoY + 20, dinoWidth - 75, dinoHeight - 25);
  } else { // jumping or standing
    println(dino);
    image(dino, dinoX, dinoY, dinoWidth, dinoHeight);
  }
  
  // Call the obstacle function to move/draw the obstacle
  if (currentObject) {
    obstacle();  // Move and draw the obstacle
  } else {
    background_no_obstacle();  // Spawn a new obstacle
  }

  // Check for collisions between dino and obstacle
  // if (collision(dinoX, dinoY, obstacleX, obstacleY)) {
  if (collision(dinoX, dinoY, dinoWidth, dinoHeight, obstacleX, obstacleY, obstacleWidth, obstacleHeight, dino)) {
    gameOver = true;  // Set game over state
    // noLoop();  // Stop the game
  }
}

void background_no_obstacle(){
  int randomIndex = (int) random(0, obstacles.length);  // Random index for obstacle
  currentObstacle = obstacles[randomIndex];  // Select a random obstacle
  obstacleX = width;  // Start the obstacle at the right edge of the screen
  currentObject = true;  // Set flag to indicate an obstacle is active

  // Set obstacle Y position based on its type (bird or cactus)
  if (currentObstacle == birdDown || currentObstacle == birdUp) {
    obstacleY = groundY - 90;  // Set bird to fly above the ground
  } else {
    obstacleY = groundY - 30;  // Set cacti to be on the ground
  }
}

void handleBirdFlying() {
  int currentTime = millis();
  if (currentTime - lastFrameChangeTime > animationInterval) {
    lastFrameChangeTime = currentTime;  // Reset the timer

    // Alternate between the two bird frames
    useBirdUp = !useBirdUp;
  }

  if (useBirdUp) {
    currentObstacle = birdUp;  // Display bird flying up frame
  } else {
    currentObstacle = birdDown;  // Display bird flying down frame
  }
}

void obstacle(){
   obstacleX -= speed;  // Move obstacle leftward
   
  if (currentObstacle == birdDown || currentObstacle == birdUp) {
    handleBirdFlying();
  }
/*  
  if (currentObstacle == maxCactus) {
    image(currentObstacle, obstacleX, obstacleY - 30, 100, 70);  // draw obstacle
  } else if (currentObstacle == tripleCactus) {
    image(currentObstacle, obstacleX, obstacleY - 20, 60, 60);  // draw obstacle
  } else {
    image(currentObstacle, obstacleX, obstacleY - 10, 50, 50);  // draw obstacle
  }
*/
  if (currentObstacle == maxCactus) {
     obstacleWidth = 100;
     obstacleHeight = 70;
     image(currentObstacle, obstacleX, obstacleY - 30, obstacleWidth, obstacleHeight);  // Draw obstacle
   } else if (currentObstacle == tripleCactus) {
     obstacleWidth = 60;
     obstacleHeight = 60;
     image(currentObstacle, obstacleX, obstacleY - 20, obstacleWidth, obstacleHeight);  // Draw obstacle
   } else if (currentObstacle == tripleCactus) {
     obstacleWidth = 60;
     obstacleHeight = 60;
     image(currentObstacle, obstacleX, obstacleY - 20, obstacleWidth, obstacleHeight);  // Draw obstacle
   } else if (currentObstacle == birdDown || currentObstacle == birdUp) {
     obstacleWidth = 50;  // Example width for birds
     obstacleHeight = 50;  // Example height for birds
     image(currentObstacle, obstacleX, obstacleY, obstacleWidth, obstacleHeight);  // Draw obstacle
   } else {
     obstacleWidth = 50;
     obstacleHeight = 50;
     image(currentObstacle, obstacleX, obstacleY - 10, obstacleWidth, obstacleHeight);  // Draw obstacle
   }
   /*
   
   */
   // Reset obstacle when it goes off the screen
  if (obstacleX < -50) {  // If obstacle has moved off-screen (left side)
    currentObject = false;  // Reset flag, allowing a new obstacle to spawn
  }
}
/* 
boolean collision(int dinoX, int dinoY, int obstacleX, int obstacleY) {
  int dinoRight = dinoX + dinoWidth/2;
  int dinoBottom = dinoY + dinoHeight/2;
  int obstacleRight = obstacleX - 25;  // Assuming obstacle width is 50
  int obstacleBottom = obstacleY - 25;  // Assuming obstacle height is 50
  
  // Check if the dino and obstacle overlap
  if (dinoRight > obstacleX && dinoX < obstacleRight && dinoBottom > obstacleY && dinoY < obstacleBottom) {
    return true;  // Collision detected
  } else {
    return false;  // No collision
  }
}
*/

boolean collision(int dinoX, int dinoY, 
                  int dinoWidth, int dinoHeight, 
                  int obstacleX, int obstacleY, 
                  int obstacleWidth, int obstacleHeight, 
                  PImage dino) {
 
  // Adjust dino boundaries based on its current state (ducking, running, jumping)
  int adjustedDinoX = dinoX;
  int adjustedDinoY = dinoY;
  int adjustedDinoWidth = dinoWidth;
  int adjustedDinoHeight = dinoHeight;
  
  if (dino == dinoDuck1 || dino == dinoDuck2) {  // Adjust for ducking dino
    adjustedDinoY += 50;
    adjustedDinoWidth -= 50;
    adjustedDinoHeight -= 45;
  } else if (dino == dinoRun1 || dino == dinoRun2) {  // Adjust for running dino
    adjustedDinoY += 20;
    adjustedDinoWidth -= 75;
    adjustedDinoHeight -= 25;
  }
  
  // Dino's boundaries
  int dinoLeft = adjustedDinoX - adjustedDinoWidth / 2;
  int dinoRight = adjustedDinoX + adjustedDinoWidth / 2;
  int dinoTop = adjustedDinoY - adjustedDinoHeight / 2;
  int dinoBottom = adjustedDinoY + adjustedDinoHeight / 2;

  // Obstacle's boundaries
  int obstacleLeft = obstacleX - obstacleWidth / 4;
  int obstacleRight = obstacleX + obstacleWidth / 4;
  int obstacleTop = obstacleY - obstacleHeight / 4;
  int obstacleBottom = obstacleY + obstacleHeight / 4;
  
  // Check for collision
  boolean horizontalOverlap = dinoRight > obstacleLeft && dinoLeft < obstacleRight;
  boolean verticalOverlap = dinoBottom > obstacleTop && dinoTop < obstacleBottom;

  return (horizontalOverlap && verticalOverlap);
}

void jump() {
  dino = dinoJump;  // Switch to jump image

  // Move the dino up until the peak of the jump is reached, then move it down
  if (jumpProgress < jumpHeight / 2) {
    dinoY -= 5;  // Move dino up (adjust speed as needed)
  } else {
    dinoY += 5;  // Move dino down
  }

  jumpProgress += 5;  // Increment jump progress

  // Check if the jump is complete
  if (jumpProgress >= jumpHeight) {
    isJumping = false;  // Jump is complete
    jumpProgress = 0;  // Reset jump progress for the next jump
    dinoY = height - dinoHeight - 50;  // Reset dino to ground level
    dino = dinoStand;  // Switch back to standing image
  }
}

void handleDinoRunning() {
  int currentTime = millis();
  if (currentTime - lastFrameChangeTime > animationInterval) {
    lastFrameChangeTime = currentTime;  // Reset the timer

    // Alternate between the two running frames
    useRunFrame1 = !useRunFrame1;
  }

  if (useRunFrame1) {
    dino = dinoRun1;  // Display first running frame
  } else {
    dino = dinoRun2;  // Display second running frame
  }
}

void handleDinoDucking() {
  int currentTime = millis();
  if (currentTime - lastFrameChangeTime > animationInterval) {
    lastFrameChangeTime = currentTime;  // Reset the timer

    // Alternate between the two running frames
    useRunFrame1 = !useRunFrame1;
  }

  if (useRunFrame1) {
    dino = dinoDuck1;  // Display first running frame
  } else {
    dino = dinoDuck2;  // Display second running frame
  }
}

void cloud() {
  for (int i = 0; i < numClouds; i++) {
    // Move the cloud from right to left
    cloudX[i] -= cloudSpeed[i];
    
    // If the cloud moves off the screen to the left, reset it to the right
    if (cloudX[i] < -cloudSize[i]) {
      cloudX[i] = width + random(50, 200);  // Reset position to just off the right edge
      cloudY[i] = random(50, 200);          // Reset to a new random height
      cloudSize[i] = random(50, 150);       // Reset to a new random size
      cloudSpeed[i] = random(0.5, 1.5);     // Randomize speed again
    }
    
    // Draw the cloud at its current position and size
    image(cloudImage, cloudX[i], cloudY[i], cloudSize[i], cloudSize[i] / 2);  // Adjust height for cloud aspect ratio
  }
}

void displayGameOver() {
  fill(0);  // Black text
  textAlign(CENTER);
  textSize(32);
  // Display "Game Over" message
  text("Game Over", width / 2, height / 2 - 20);
  
  // Display the final score
  textSize(25);
  text("Score: " + score, width / 2, height / 2 + 20);  // Concatenate the score with the label
  
  // Display prompt to restart the game
  textSize(20);
  text("Press Joystick for New Game", width / 2, height / 2 + 60);
}

void resetGame() {
  gameOver = false;  // Clear game over state
  obstacleX = width;  // Reset obstacle position
  currentObject = false;  // Reset obstacle flag
  score = 0;  // Increment score

  loop();  // Restart the game loop
}

void score() {
  // Check if half of a second (500 milliseconds) has passed
  if (millis() - lastScoreTime > 500) {
    score++;  // Increment score
    lastScoreTime = millis();  // Update the last score increment time
  }

  // Display the score on the screen
  fill(0);  // Set text color to black
  textSize(24);  // Set text size
  text("Score: " + score, width - 120, 40);  // Display score at the top-right of the screen
  
  if (score % 50 == 0 && score != 0) {
    println("LED should turn on");  // Debug statement to confirm this part is running
    myPort.write('1');
  }
}


// Function to increase the game speed every 30 seconds
void increaseSpeed() {
  int currentTime = millis();
  
  // If 30 seconds have passed since the last speed increase
  if (currentTime - lastSpeedIncreaseTime > speedIncreaseInterval) {
    speed += 1;  // Increase the speed by 1
    lastSpeedIncreaseTime = currentTime;  // Update the last speed increase time
    println("Speed increased to: " + speed);  // For debugging purposes
  }
}


void adjustSpeed(int potValue) {
  // Map potentiometer values to game speeds
  if (potValue <= 1365) {
    speed = 10;  // Easy level: slow speed
  } else if (potValue > 1365 && potValue <= 2730) {
    speed = 6;  // Medium level: moderate speed
  } else if (potValue > 2730) {
    speed = 4;   // Hard level: fast speed
  }
  
  // 0 to 1365: Easy level (slow speed). - arrow up
  // 1366 to 2730: Medium level (moderate speed). - arrow left
  // 2731 to 4095: Hard level (fast speed). - arrow down
}

// Function to display the starter screen
void displayStarterScreen() {
  textAlign(CENTER, CENTER);  // Center the text
  textSize(32);  // Set text size
  fill(0);  // Set text color to black
  text("Oh no! You are offline :(", width / 2, height / 2 - 50);  // First line
  text("Would you like to play a game in the meantime?", width / 2, height / 2);  // Second line
}

// Function to check for game start (button press or joystick)
void checkForGameStart() {
  if (myPort.available() > 0) {
    String data = myPort.readStringUntil('\n');
    if (data != null) {
      data = trim(data);
      String[] vals = split(data, ',');
      if (vals.length == 5) {
        int zVal = int(vals[2]);  // Read the joystick button value
        int buttonState = int(vals[3]);
        if (zVal == 0 || buttonState == 0) {  // Button pressed (0 value)
          gameStarted = true;  // Start the game
        }
      }
    }
  }
}

void checkForGameReset() {
  if (myPort.available() > 0) {
    String data = myPort.readStringUntil('\n');
    if (data != null) {
      data = trim(data);
      String[] vals = split(data, ',');
      if (vals.length == 5) {
        int zVal = int(vals[2]);  // Read the button state
        int buttonState = int(vals[3]);

        if (zVal == 0 || buttonState == 0) {  // Button pressed (0 value)
          resetGame();  // Reset the game state
        }
      }
    }
  }
}
