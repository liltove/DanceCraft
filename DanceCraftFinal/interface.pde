/*---------------------------------------------------------------
Imports
----------------------------------------------------------------*/


/*---------------------------------------------------------------
Variables
----------------------------------------------------------------*/
//SET SIZE OF WINDOW
int width = 640; // window width
int height = 480; // window height

// BUTTON VARIABLES
color rectColor = color(50, 55, 100);
color rectHighlightColor = color(150, 155, 155);
color rectPressedColor = color(100, 105, 155);
int buttonWidth = 74;
int buttonHeight = 35;
int distanceFromLeft = (width/2) - (buttonWidth/2);
int distanceFromTop = (height/5) * 2; //  distance from top to start drawing buttons;
int distanceBetweenButtons = 33;
String[] buttonNames = {"One", "Two", "Three"}; // array of button names;
//String[] danceFileNames= {"better_dance_recording.csv", "good_dance_recording.csv", "csvPoseData.csv"}; // array of associated File names to go with buttons
Boolean[] buttonIsPressed = {false, false, false};
Boolean[] buttonIsOver = {false, false, false};
Boolean [] keysPressed = new Boolean[20];

/*---------------------------------------------------------------
Draws the right screen size with other set parameters
----------------------------------------------------------------*/
void drawScreen(){
  frame.setTitle("DanceCraft"); //sets window title
  size(width,height, P3D);
  font=createFont("Arial", 48);
  textFont(font); 
}

/*---------------------------------------------------------------
Draw the dance screen. Calls the animation/background image. Calls Kinect class.
----------------------------------------------------------------*/
void drawDanceScreen() {
  background(255);
  int passedTime = millis() - startTime;
  int secs = passedTime/1000 %60;
  int mins = passedTime/1000/60;

  textSize(30);
  fill(0);
  
  textAlign(LEFT);
  time = (nf(mins, 2) + ":" + nf(secs, 2));

  fill(255,255,255,75);
  rectMode(CORNER);
  noStroke();
  rect(82,51,15,15,7);
  rect(82,71,15,15,7);
  fill(255);
  textSize(18);
  textAlign(LEFT);

  playDances();

  //COMMENT OUT THIS LINE TO RUN WITHOUT KINECT
  //kinectDance();
}

/*---------------------------------------------------------------
Draw the main title screen.
----------------------------------------------------------------*/
void drawTitleScreen() {
   background(255); //makes background white
   textSize(32);
   textAlign(CENTER);
   fill(0); //fills in letters black
   text ("FANCY DANCECRAFT TITLE", width/2, height/5); //puts title in top center of screen

  //if on title screen, then set day back to 0
  currentDaySelected = 0;
  
   int y = 0;
  // ADDING BUTTONS
  
  // go throgh each button
  for (int i = 0; i < buttonNames.length; i++) {
    
    // calculate the distance of that button from the top of the screen
    y = distanceFromTop + buttonHeight*i + distanceBetweenButtons*i;
    
    // if the cursor is currently hovering over the button
    if (mouseX >= distanceFromLeft && mouseX <= distanceFromLeft+buttonWidth && 
    mouseY >= y && mouseY <= y+buttonHeight) {
      // check to see if the button is NOT currently pressed
      if(!buttonIsPressed[i]) {
        // then color it as highlighted
        fill(rectHighlightColor);
      } else {
        // if the button is being pressed, then color it as pressed
        fill(rectPressedColor);
      }
      // and mark that the mouse is currently over that button
      buttonIsOver[i] = true;
    } else { // if the mouse isn't over this button
      // reset the color
      fill(rectColor);
      // mark that the mouse is NOT over this button
      buttonIsOver[i] = false;
    }
    
    stroke(255);
    rect(distanceFromLeft, y, buttonWidth, buttonHeight);
    
    fill(255);
    textSize(18);
    textAlign(CENTER, CENTER);
    text(buttonNames[i], distanceFromLeft,y,buttonWidth,buttonHeight-5);
  }
   
   //toggleRecordMode();
}
