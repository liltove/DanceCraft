import processing.video.*;
import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

import controlP5.*;

ControlP5 cp5;

Minim minim; //audio context
//audio context
int track = 1; //initial track number
String trackNum; //holds track number for calling from file

PFont font;

String phase, mode;
String [] files;
String username, time;
String desktopPath = "\\records/"; 
String recordingsFolder = "data"; // this is the folder that kinect skeleton recordings is in
String recordingName = "better_dance_recording.csv"; // this is the file to temporarily use for the target recording to play
String fileName = new String();


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
String[] danceFileNames= {"better_dance_recording.csv", "good_dance_recording.csv", "csvPoseData.csv"}; // array of associated File names to go with buttons
Boolean[] buttonIsPressed = {false, false, false};
Boolean[] buttonIsOver = {false, false, false};
Boolean [] keysPressed = new Boolean[20];

Boolean typingUsername, music, figure, animationPlaying, animation2playing, showPoints, showResponses, showEncouragements;
Boolean isPaused = false;
Boolean typingFileName = false;
Boolean recordMode = false; //is program currently recording?
Boolean dancePlayback = false; //is program currently playing back a recording?
Boolean allowRecordModeActivationAgain = true;

int startTime;
int background;
int count;
int response;
int numIterationsCompleted = 0; //Used to drawback skeletons

void setup() {
  smooth();
  phase = "title";
  size(width,height);
  font=createFont("Arial", 48);
  textFont(font);

  count = 0;
  response = 0;
  username = "";
  typingUsername = false;
  music = true;
  figure = true;
  
  cp5 = new ControlP5(this);
  
  //COMMENT OUT THIS LINE TO RUN WITHOUT KINECT
  //kinectSetup();
  
  minim = new Minim(this);
  //musicSetup();

  background = 0;

  //Fill the Boolean array keysPressed with falses
  for (int i = 0; i < keysPressed.length; i++) {
    keysPressed[i] = false;
  }
  //randomTrack();
  //soundtrack.play();
}

/*---------------------------------------------------------------
Detect which phase of the program we are in and call appropriate draw function.
----------------------------------------------------------------*/
void draw() {
  
  if (phase=="title") {
    drawTitleScreen();
  }
  else if (phase=="dance") {
    //Branch to playback recorded dance
    if (dancePlayback == true) {
      background(255);  //Clear background
      playBack (numIterationsCompleted); //play back the skeletons
      numIterationsCompleted++;
    } else {
      drawDanceScreen();
    }
  }
  else if (phase=="record"){
    //Branch to the recording screen, to record teacher's dances
    //THIS MIGHT LOOK DIFFERENT THAN THE DANCE PHASE?
  }
}

/*---------------------------------------------------------------
Draw the dance screen. Calls the animation/background image. Calls Kinect class.
----------------------------------------------------------------*/
void drawDanceScreen() {
  background(255);

  typingUsername = false;
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

  //COMMENT OUT THIS LINE TO RUN WITHOUT KINECT
  //kinectDance();
  
  //check to see if the user is either watching a recording or is recording their dances
  //if they are not doing either of these things, then exit to main menu
  if (recordMode == false && dancePlayback == false){
     phase = "title"; 
  }
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


/*---------------------------------------------------------------
Senses when mouse is clicked and does appropriate action.
----------------------------------------------------------------*/
void mousePressed() {
  
  // go through each button
  for (int i = 0; i < buttonNames.length; i++) {
    // check to see if the mouse is currently hovering over the button
    if(buttonIsOver[i]) {
      // if so then mark this button as pressed
      buttonIsPressed[i] = true;
    }
  }
  //println(mouseX,mouseY);
}

void mouseReleased() {
  
  // goes through each button
  for (int i = 0; i < buttonNames.length; i++) {
    // checks to see if the mouse is currently hovering over it
    // and if the mouse press event started on that button
    if(buttonIsOver[i] && buttonIsPressed[i]) {
      //enter the "dance" phase of the program
      phase = "dance";
      // if so, then start the next video 
      playVideo(danceFileNames[i]);
    }
    // clear the button presse flag under all instances, because the mouse is released
    // and we're ready for the next mouse event
    buttonIsPressed[i] = false;
  }
}
/*---------------------------------------------------------------
Detects when a key has been pressed and does appropriate action.
----------------------------------------------------------------*/
void keyPressed() {
  //println("Key pressed is --->" + key);
  //println ("Key code is ---->" + keyCode);
  //Key code for shift key is 16 and ctrl is 17

  //Check to see the phase of the game
  /*if (phase == "dance") {
    if (recordMode == false) { //If we're not recording, allow user to load a dance when P pressed
      if (key == 'p' || key =='P') {
        //selectInput("Select the Dance you wish to load", "readCsv");
        playVideo(recordingName);
      }
    }
  }*/
  
   //Switch to recording mode if you're pressing SPACE
  if (keyPressed){
    if (key == ' ' && phase == "dance" && recordMode == false  && allowRecordModeActivationAgain == true){
      recordMode = true;
      allowRecordModeActivationAgain = false;
      println("Record Mode Activated");
      //Draw red circle indicatiing that we are recording
      fill (189, 41, 2);
      ellipse (width-20, 20, 10, 10);
    } else if (key == ' ' && phase == "dance" && recordMode == true && allowRecordModeActivationAgain == true ) {
      recordMode = false;
      allowRecordModeActivationAgain = false;
      println("Record Mode Deactivated");
    }
  }
    // Listen for user pressing the "L" key.  Sets typingFileName to TRUE.  Prompts user to pick location.
   /* if(key=='l'|| key=='L') {
      isPaused = true;
      typingFileName = true;
      text("Name Your Dance",200,200);
      //Create box to type in
      cp5.addTextfield ("input")
        .clear()
        .setPosition (width/2, (height/2)-40)
        .setSize (200,80)
        .setFocus(true);
    }

    //Capture the input
    if (typingFileName == true) {
      if (key == ENTER){
        fileName = cp5.get(Textfield.class, "input").getText();
        typingFileName = false;
        selectFolder("Where do you wish to save your dance?", "saveSkeletonTable");
      }
    }*/

}

void playVideo(String filename){
  //read the file specified
  readCsv(sketchPath(recordingsFolder + "/" + filename).toString());
}


void keyReleased(){
   //When you release a special key, make sure to set it's value back to false in the keysPressed array
   if (key == CODED && keyCode <= keysPressed.length-1 ) {
     keysPressed[keyCode] = false;
     println ("Value in array for key pressed: --->" + keysPressed[keyCode]);
   }
   //Allow Record Mode to be active once at least one either SHIFT or CTRL is let up
   if (!keysPressed[16] || !keysPressed[17]) {
     allowRecordModeActivationAgain = true;
   }
} //End of KeyPressed function





//creates the static background
//void backgrnd(){
  //if(background == 0){
    //background = int(random(4)) + 1;
    //String dncbg = "elements/" + background + ".png";
    //dancebg = loadImage(dncbg);
    //image(dancebg,width/2,height/2,width,height);
  //}
//}

//void musicPlay(){
//  //calls a random track from the music folder
//    randomTrack();
//    soundtrack.play();
//
////loop of music playing
//  while(music == true){
//    //plays the music
//    if(!soundtrack.isPlaying()){
//      soundtrack.pause();
//      soundtrack.rewind();
//      randomTrack();
//      soundtrack.play();
//    }
//  }
//}//Boolean music
//
//void stop()
//{
//  soundtrack.close();
//  minim.stop();
//  super.stop();
//}
//
//void getTrack(int track){
//  trackNum = "music/"+track+".mp3";
//  soundtrack = minim.loadFile(trackNum, 2048);
//}
//
//void randomTrack(){
//  track = int(random(23)) + 1;
//  println("Now playing track number: " + track);
//  getTrack(track);
//}
