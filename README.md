# Module-2-Interactive-Devices---Dino-Game
Inspired by Chrome's offline Dinosaur game, Dino game is an interactive game where player guides a pixelated t-rex across a side-scrolling landscape, avoiding obstacles to achieve a higher score. The game is controlled using an ESP32 TTGO T-display with joystick, button, and potentiometer input. This README will guide you through replicating the design, installation, and setup.

### Project Overview
The Dino Game was developed with the goal of creating a dynamic and challenging experience where players control a dino character to avoid obstacles and gain points based on how long they run. The game has responsive jumping and ducking mechanics, along with adjustable game speed and interactive displays.

## Design Goals
This project aims to:
- Build an engaging, hardware-controlled game that responds to physical input.
- Experiment with interaction design through joystick, potentiometer, and button inputs.
- Make a simple yet challenging game that can be replicated with minimal hardware requirements.

## Key Features  <!-- H3: For subsections within a section -->
- **Jump and Duck Controls**: Use the joystick to make the dino jump or duck.
- **Scoring**: Points increase with time.
- **Initializing Speed**: Use potentiometer to set speed.
- **Speed Adjustment**: Speed increases over time.
- **Start and Replay Game**: Use button or joystick button to start or replay the game.
- **PNG Files**: Use PNG files to represent different dino positions and objects in the game.

## Materials Needed
- **ESP32 TTGO T-Display** with TFT screen
- **Joystick** (to control character actions)
- **Potentiometer** (to adjust speed during gameplay)
- **Button** (to start and replay game)
- **Arduino IDE** installed on your computer
- **Processing IDE** for real-time data visualization

## Installation
1. **Hardware Setup**:
   - Connect the **joystick** to the ESP32 TTGO.
   - Connect the **button** to reset the game when pressed.

2. **Install Libraries**:
   - `TFT_eSPI`
   - `Adafruit_ST7789`

3. **Upload Arduino Code**:
   - Open Arduino IDE, load `Dino_Game.ino`, and upload.
   - Set the board to ESP32 TTGO T-Display and the correct COM port.
   - Compile and upload the code.
  
3. **Upload Processing Code**:
   - For visualization, open Dino_Game.pde in Processing IDE.
   - Run the Processing sketch after the game is running on the ESP32 TTGO.
  
## Gameplay
The objective is to survive as long as possible while avoiding obstacles.

## Code Explanation
The Dino Game code is structured to handle the game logic, user inputs, and rendering of graphics on the screen.

### Main Loop (`void draw()`)
The main loop, implemented in the draw() function, continuously updates the game state by checking for user inputs, rendering graphics, and managing the game's logic. It begins by setting the background and handling the game state—either displaying the starter screen or the game-over screen. If the game is active, it reads joystick inputs to determine whether the dino should jump, duck, or run, and updates the dino's position and appearance accordingly. It handles obstacles, including moving the obstacle across the screen and collision detection. Aditional functions are implemented and called upon during the draw() function to peform these actions such as:
- void checkForGameReset()
- void checkForGameStart()
- void displayStarterScreen()
- void checkForGameReset()
- void resetGame()
- void displayGameOver() {
- void adjustSpeed(int potValue)
- void increaseSpeed()
- void score()
- void cloud()
- void handleDinoDucking()
- void handleDinoRunning()
- void jump()
- boolean collision(int dinoX, int dinoY, int dinoWidth, int dinoHeight, int obstacleX, int obstacleY, int obstacleWidth, int obstacleHeight, PImage dino)
- void obstacle()
- void handleBirdFlying()
- void background_no_obstacle()
