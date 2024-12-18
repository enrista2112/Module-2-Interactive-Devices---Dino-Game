# Module 2 Interactive Devices: Dino Game
Inspired by Chrome's offline Dinosaur game, Dino game is an interactive version of this game. Players guide a pixelated t-rex across a side-scrolling landscape, avoiding obstacles to achieve a higher score. The game is controlled using an ESP32 TTGO T-display with joystick, button, and potentiometer input. This README will guide you through replicating the design, installation, and setup.

Here is a link to my blog post documenting my artistic journey making this game: https://flashy-tellurium-248.notion.site/Module-2-Interactive-Devices-Dino-Game-12c69c37328680d48f23d637f92d3378.

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
https://i.giphy.com/media/v1.Y2lkPTc5MGI3NjExdWoybXpiaXBhaXZybGUyYTRub2MwdjljZG8za2hvNm96ZnpuZ3A4NCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/GggkhAY3nwX241qqnb/giphy.gif

## Dino Game

Here’s a preview of the Dino Game in action:

![Dino Game GIF](https://i.giphy.com/media/v1.Y2lkPTc5MGI3NjExdWoybXpiaXBhaXZybGUyYTRub2MwdjljZG8za2hvNm96ZnpuZ3A4NCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/GggkhAY3nwX241qqnb/giphy.gif)

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
   - Connect the **potentiometer** to set the game speed when starting.
   - Connect the **LED** to flash when reaching a milstone,
   - A Fritzing diagram of my circuit has been provided below.
<img width="743" alt="Screenshot 2024-10-27 at 5 20 59 PM" src="https://github.com/user-attachments/assets/80dc597f-4541-4559-af3f-bba3b0febaea">

2. **Install Libraries**:
   - `TFT_eSPI`
   - `Adafruit_ST7789`

3. **Upload Arduino Code**:
   - Open Arduino IDE, load `dino.ino`, and upload.
   - Set the board to ESP32 TTGO T-Display and the correct COM port.
   - Compile and upload the code.
  
3. **Upload Processing Code**:
   - For visualization, open `dino_game.pd` in Processing IDE.
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
