/*---------------------------------------------------------------
 Imports
 ----------------------------------------------------------------*/


/*---------------------------------------------------------------
 Variables
 ----------------------------------------------------------------*/

// BUTTON VARIABLES
color rectColor = color(50, 55, 100);
color rectHighlightColor = color(150, 155, 155);
color rectPressedColor = color(100, 105, 155);
int buttonWidth = 90;
int buttonHeight = 35;
int distanceFromLeft = (width/2) - (buttonWidth/2);
int distanceFromTop = (height/5) * 2; //  distance from top to start drawing buttons;
int distanceBetweenButtons = 33;
String[] buttonNames = {"One", "Two", "Three", "Tutorial"}; // array of button names;
String[] buttonImgs = {"Day1.png", "Day2.png", "Day3.png", "Help.png"}; //array of button images
//String[] danceFileNames= {"better_dance_recording.csv", "good_dance_recording.csv", "csvPoseData.csv"}; // array of associated File names to go with buttons
Boolean[] buttonIsPressed = {false, false, false, false};
Boolean[] buttonIsOver = {false, false, false, false};
Boolean [] keysPressed = new Boolean[20];
String[] countdownTimer = {"5", "4", "3", "2", "1"};
String[] countdownTimer_choreoSeg2 = {"4", "3", "2", "1"};
int countdownReady = 0;

PImage[] buttonImages = new PImage[4];

//Title Background Color
color backgroundColorTitle = color(51, 51, 153);

//Title Screen Images
PImage title;

//Countdown timer for choreo segment 2
int countdown_time; // to countdown seconds before choreo segment 2 starts
int wait = 1000; 

/*---------------------------------------------------------------
 Draws the right screen size with other set parameters
 ----------------------------------------------------------------*/
void drawScreen() {
  surface.setTitle("DanceCraft"); //sets window title

  font=createFont("Arial", 48);
  textFont(font);
}

/*---------------------------------------------------------------
 Draw the dance screen. Calls the animation/background image. Calls Kinect class.
 ----------------------------------------------------------------*/
void drawDanceScreen() {
  background(255);
  if (phase=="dance") {
    background(danceBackdrop);
  }
  int passedTime = millis() - startTime;
  int secs = passedTime/1000 %60;
  int mins = passedTime/1000/60;

  textSize(30);
  fill(0);

  textAlign(LEFT);
  time = (nf(mins, 2) + ":" + nf(secs, 2));

  fill(255, 255, 255, 75);
  rectMode(CORNER);
  noStroke();
  rect(82, 51, 15, 15, 7);
  rect(82, 71, 15, 15, 7);
  fill(255);
  textSize(18);
  textAlign(LEFT);

  recordIndicator();
  countdown_choreoSeg2();

  if (phase == "tutorial") {
    image(tutorial, 0, 0, 340, 300);
    tutorial.read();
  } else if (phase == "dance" || phase == "teacherMode") {
    //COMMENT OUT THIS LINE TO RUN WITHOUT KINECT
    kinectDance();
  }
}

/*---------------------------------------------------------------
 Draw the main title screen.
 ----------------------------------------------------------------*/
void drawTitleScreen() {
  title = loadImage("DanceCraft.png");

  //background(255); //makes background white
  background(backgroundColorTitle);
  textSize(32);
  textAlign(CENTER);
  fill(0); //fills in letters black
  image(title, width/4, height/4); //puts title in top center of screen

  //if on title screen, then set day back to 0
  currentDaySelected = 0;

  int y = 0;
  // ADDING BUTTONS

  // go throgh each button
  for (int i = 0; i < buttonNames.length; i++) {
    buttonImages[i] = loadImage(buttonImgs[i]); //assign the images to the buttons

    // calculate the distance of that button from the top of the screen
    y = distanceFromTop + buttonHeight*i + distanceBetweenButtons*i;

    // if the cursor is currently hovering over the button
    if (mouseX >= distanceFromLeft && mouseX <= distanceFromLeft+buttonWidth && 
      mouseY >= y && mouseY <= y+buttonHeight) {
      // check to see if the button is NOT currently pressed
      if (!buttonIsPressed[i]) {
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

    //fill(255);
    //textSize(18);
    //textAlign(CENTER, CENTER);
    //text(buttonNames[i], distanceFromLeft,y,buttonWidth,buttonHeight-5);
    image(buttonImages[i], distanceFromLeft, y, buttonWidth, buttonHeight-5);
  }
}

/*---------------------------------------------------------------
 Draw String to screen
 ----------------------------------------------------------------*/
void drawMessage(String message) {
  clearScreen();
  textSize(32);
  textAlign(CENTER);
  fill(0); //fills in letters black
  println("Print message: " + message);
  text (message, width/2, height/5); //puts message in top center of screen
}

/*---------------------------------------------------------------
 Clear everything from screen
 ----------------------------------------------------------------*/
void clearScreen() {
  background(255);
  if (phase == "dance") {
    background(danceBackdrop);
  }
}

/*---------------------------------------------------------------
 Counts down to when recording starts
 ----------------------------------------------------------------*/
void countdownRecord() {
  if (countdownReady < countdownTimer.length) {
    drawMessage(countdownTimer[countdownReady]);
    delay(800);
    countdownReady++;
  } else if (countdownReady == countdownTimer.length) {
    waitingToRecord = false;
  }
}

void countdown_choreoSeg2() {
  textSize(35);
  fill(0);

  if (currentChoreoSegment == 2) {
    if (countdownReady < countdownTimer_choreoSeg2.length) {
      text(countdownTimer_choreoSeg2[countdownReady], 550, 50);
      if (millis() - countdown_time >= wait) {
        countdown_time = millis();//also update the stored time
        countdownReady++;
      }
    }
  }


  //check the difference between now and the previously stored time is greater than the wait interval
}

/*---------------------------------------------------------------
 Display a RED dot when RecordMode is true
 ----------------------------------------------------------------*/
void recordIndicator() {
  if (recordMode) {
    //Draw red circle indicatiing that we are recording
    fill (189, 41, 2);
    ellipse (width-20, 20, 20, 20);
  }
}