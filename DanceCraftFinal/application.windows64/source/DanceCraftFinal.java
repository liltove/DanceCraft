import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.video.*; 
import ddf.minim.*; 
import ddf.minim.signals.*; 
import ddf.minim.analysis.*; 
import ddf.minim.effects.*; 
import controlP5.*; 
import java.util.ArrayList; 
import SimpleOpenNI.*; 
import ddf.minim.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class DanceCraftFinal extends PApplet {









ControlP5 cp5;
PFont font;

String phase, mode;
String [] files;
String username, time;
String desktopPath = "\\records/";
String recordingsFolder = "data"; // this is the folder that kinect skeleton recordings is in
//String recordingName = "better_dance_recording.csv"; // this is the file to temporarily use for the target recording to play
String fileName = new String();

Boolean typingUsername, music, figure, animationPlaying, animation2playing, showPoints, showResponses, showEncouragements;
//Boolean isPaused = false;
Boolean typingFileName = false;
Boolean recordMode = false; //is program currently recording?
Boolean dancePlayback = false; //is program currently playing back a recording?
Boolean allowRecordModeActivationAgain = true;


int startTime;
int background;
int numIterationsCompleted = 0; //Used to drawback skeletons
int currentDaySelected = 0; //which day is selected to play appropriate dance files
int currentDanceSegment = 2; //which segment of the dance are we on
int currentChoreoSegment = 0; //which segment of choreo are we on
int playthroughChoreo = 0; //final play through of all choreo files
int numTimesTutorialPressed = 0;  //used to keep track of the times Tutorial button is pressed
Boolean waitingToRecord = true; //waiting on record mode
Boolean recorded = false;

//holds tutorial movie
Movie tutorial;

//Logging stuff
String currentDay = String.valueOf(day());
String currentMonth = String.valueOf(month());
String currentYear = String.valueOf(year());
String currentHour = String.valueOf (hour());
String currentMinute = String.valueOf (minute());
String currentSecond = String.valueOf (second());
String currentTime = currentHour + currentMinute + currentSecond;
String currentTimeWithColons = currentHour + ":" + currentMinute + ":" + currentSecond;
String currentDate = currentMonth + "_" + currentDay + "_" + currentYear;
StopWatchTimer totalTime = new StopWatchTimer();
PrintWriter logFile;

float normLength = -25;

float k = 0.0f;
PVector pos;

public void setup() {
  logFile = createWriter(dataPath("") + "/DanceCraftUserLog" + currentDate + "_" + currentTime + ".txt");
  beginWritingLogFile(); //Begin creation of log file for DC researchers
  logFile.println ("Time of day launched:" + " " + currentTime); //Log the time of day that the program was lanuched.
  smooth();
  drawScreen();
  phase = "title";
  //music = true;
  figure = true;

  //COMMENT OUT THIS LINE TO RUN WITHOUT KINECT
  //kinectSetup();

  minim = new Minim(this);
  musicSetup();
  movieSetup();

  background = 0;

  //Fill the Boolean array keysPressed with falses
  for (int i = 0; i < keysPressed.length; i++) {
    keysPressed[i] = false;
  }

  //Function defined at end of this file that allows for code after program quit to run
  prepareExitHandler();
}

/*---------------------------------------------------------------
Detect which phase of the program we are in and call appropriate draw function.
----------------------------------------------------------------*/
public void draw() {
  if (phase=="title") {
    drawTitleScreen();
  } else if (phase=="dance") {
      drawDanceScreen();
      playDances();
      musicPlay();
  } else if (phase=="tutorial"){
    //drawDanceScreen();
    drawMovie();

  }
}

/*---------------------------------------------------------------
Senses when mouse is clicked and does appropriate action.
----------------------------------------------------------------*/
public void mousePressed() {
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

public void mouseReleased() {
  // goes through each button
  for (int i = 0; i < buttonNames.length; i++) {
    // checks to see if the mouse is currently hovering over it
    // and if the mouse press event started on that button
    if(buttonIsOver[i] && buttonIsPressed[i]) {
      //if it's tutorial, play the tutorial video, else select the day
     if(buttonNames[i].equals("Tutorial")){
       println("Tutorial pressed");
       phase = "tutorial";

      buttonIsPressed[i] = false;
      buttonIsOver[i] = false;
      tutorial.jump(0);
      tutorial.play();
     }
     else{
      //update days to set which day is selected
      currentDaySelected = i+1;
      //Write information to log file
      logFile.println ("Time: " + currentTimeWithColons + "--" + "User has selected the dance sequence for Day " + currentDaySelected + "\n");
      //Create a timer to keep track of the fact the user has clicked on one of the dances
      totalTime.start();
      //make sure filenames are up to date
      fileForDaySelected();
      //enter the "dance" phase of the program
      phase = "dance";
    }
    }
    // clear the button presse flag under all instances, because the mouse is released
    // and we're ready for the next mouse event
    buttonIsPressed[i] = false;
  }
}

/*---------------------------------------------------------------
Detects when a key has been pressed and does appropriate action.
----------------------------------------------------------------*/
public void keyPressed() {
  //Switch to recording mode if you're pressing SPACE
  if (keyPressed){
    if (key == ' ' && phase == "dance" && recordMode == false  && allowRecordModeActivationAgain == true){
      recordMode = true;
      waitingToRecord = true;
      allowRecordModeActivationAgain = false;
      println("Record Mode Activated");
    } else if (key == ' ' && phase == "dance" && recordMode == true && allowRecordModeActivationAgain == true ) {
      recordMode = false;
      allowRecordModeActivationAgain = false;
      //save recorded table to file
      //saveSkeletonTable("test", fullRecordTable);
      println("Record Mode Deactivated");
    } else if(key == 'm' || key =='M') {
       phase = "model";
    }
  }
}


public void keyReleased(){
   //When you release a special key, make sure to set it's value back to false in the keysPressed array
   if (key == CODED && keyCode <= keysPressed.length-1 ) {
     keysPressed[keyCode] = false;
     println ("Value in array for key pressed: --->" + keysPressed[keyCode]);
   }
   //Allow Record Mode to be active once at least one either SHIFT or CTRL is let up
   if (!keysPressed[16] || !keysPressed[17]) {
     allowRecordModeActivationAgain = true;
   }
} //End of KeyPressed function  //Methods

/*---------------------------------------------------------------
Runs upon exiting the program, shuts down logging functions.
----------------------------------------------------------------*/
public void prepareExitHandler () {
 Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {
   public void run () {
     System.out.println("SHUTDOWN HOOK");
     totalTime.stop();
     logFile.println ("Total time user has played: " + totalTime.getSeconds() + " seconds");
     saveSkeletonTable(currentDaySelected + "USERDATA" + currentTime, fullRecordTable); //save full play through of skeletal data
     closeLogFile();
// application exit code here
     }
   }));
}
/*
This file contains the functions necessary for playing back "dances" recorded
 by the user.
 */
//-------------------------------------------------------------//
float offsetX; //The offset x of the skeleton
float offsetY; // The offset y of the skeleton
float midWidth = 320 * 4; //middle width of the left half screen
float midHeight = 720; //middle height of the left haft screen

String[] danceFileNames= {
  "prewarmUp.csv", "mirror.csv"
};
String[] danceChoreoFiles= {
  "combo1_first8.csv", "1choreo_1.csv", "combo1_third8.csv", "1choreo_2.csv"
};

boolean useModel = false;

/*--------------------------------------------------------------
 reads the csv and retrieves the joint coordinate information, loads them
 into a table
 --------------------------------------------------------------*/
public Boolean readCsv(String selection)
{
  //read the csv file if something has been selected
  if (selection != null) {
    println(selection);
    loadedSkelTable = loadTable(selection, "header");
    skel_data = new PVector [loadedSkelTable.getRowCount()/15][15]; //Initalize skel_data w/ row size = number of "skeletons" and column size = number of joints.
    int i = 0; //count the number of skeletons that are read
    int index; //count the join of the i skeleton that are read
    
    //iterate through each row of the table
    for (TableRow row : loadedSkelTable.rows ()) {
      //println (row);
      //get the joint position
      index = row.getInt("joint");
      //Create a new PVector to hold the stuff we're about to grab from the table
      PVector joint = new PVector();
      //Insert that PVector into the skel_data array
      skel_data[i][index] = joint;
      //set coordinates of index joint for i skeleton
      skel_data[i][index].x = row.getFloat("x");
      skel_data[i][index].y = row.getFloat("y");
      skel_data[i][index].z = row.getFloat("z");
      if (index == 14)
      {
        i++;
      }
    }
    //Ready to start dance Playback
    println("Exiting readCSV function");
    return true;
  } else {
    println ("No file selected or incorrect file type.  Must be CSV.");
    return false;
  }
}

/*--------------------------------------------------------------
 draws the points of each of the joints OR draws the 3D model depending on
 if model is turned on or off
 --------------------------------------------------------------*/
public void playBack(Integer rowNum)
{
  PVector jointPos = new PVector();
  int realNum;
  //println("playing " + rowNum);
  
  if (rowNum < skel_data.length) {  //Compare number passed to function and make sure its less than the length of the array of skeleton data
    //println ("Drawing!" + ' ' + rowNum);
    offsetX = alignX(skel_data[0][8]);
    offsetY = alignY(skel_data[0][8]);

    if (!useModel) {
      drawBack(skel_data[rowNum][0], skel_data[rowNum][1], false, true); //Head and neck
      drawBack(skel_data[rowNum][1], skel_data[rowNum][2], false, false); //Neck and left shoulder
      drawBack(skel_data[rowNum][2], skel_data[rowNum][4], false, false); //Left shoulder and Left elbow
      drawBack(skel_data[rowNum][4], skel_data[rowNum][6], false, false); //Left elbow and left hand
      drawBack(skel_data[rowNum][1], skel_data[rowNum][3], false, false); //Neck and right shoulder
      drawBack(skel_data[rowNum][3], skel_data[rowNum][5], false, false); //Right shoulder and right elbow
      drawBack(skel_data[rowNum][5], skel_data[rowNum][7], false, false); //Right elbow and right hand
      drawBack(skel_data[rowNum][2], skel_data[rowNum][8], true, false); //Left shoulder and TORSO
      drawBack(skel_data[rowNum][3], skel_data[rowNum][8], true, false); //Right shoulder and TORSO
      drawBack(skel_data[rowNum][8], skel_data[rowNum][9], true, false); //Torso and left Hip
      drawBack(skel_data[rowNum][9], skel_data[rowNum][11], false, false); //Left hip and left Knee
      drawBack(skel_data[rowNum][11], skel_data[rowNum][13], false, false); //left knee and left foot
      drawBack(skel_data[rowNum][8], skel_data[rowNum][10], true, false); ///Torso and right hip
      drawBack(skel_data[rowNum][10], skel_data[rowNum][12], false, false); //Right hip and right knee
      drawBack(skel_data[rowNum][12], skel_data[rowNum][14], false, false); //Right knee and right foot
      drawBack(skel_data[rowNum][10], skel_data[rowNum][9], false, false); //Right hip and left hip
    }
  } else {
    dancePlayback = false;
    numIterationsCompleted = 0;

    if (currentDanceSegment < danceFileNames.length) {
      currentDanceSegment++;
      println("Dance Segment: " + currentDanceSegment);
    } else if (currentChoreoSegment < danceChoreoFiles.length) {
      currentChoreoSegment++;
      println("Choreo Segment: " + currentChoreoSegment);
    } else {
      playthroughChoreo++;
      println("Choreo Playthrough: " + playthroughChoreo);
    }
  }
}

/*--------------------------------------------------------------
 draws the points based on the coordinates, adjusts where the drawing occurs on screen
 --------------------------------------------------------------*/
public void drawBack(PVector skeA, PVector skeB, Boolean thicker, Boolean isHead)
{

  //Set color of skeleton "bones" to black
  stroke(0);
  //Set weight of line
  strokeWeight (5);
  //load texture image
  //PImage txt = loadImage("crumpledPaper.jpg");

  float xA = 0.25f * (offsetX + skeA.x);
  float yA = 0.25f * ((-skeA.y) + offsetY);
  float xB = 0.25f * (offsetX + skeB.x);
  float yB = 0.25f * ((-skeB.y) + offsetY);
  
  //draw a point for the first position (divided in half to fit on left side of screen.  Negated Y value to flip skeleton right side up)
  ellipseMode(CENTER);
  rotate(0);
  if (isHead){
    fill(0,0,0);
    ellipse(xA, yA, 40, 60);
  } else {
    ellipse(xA, yA, 5, 5);
  }
  
  //draw a point for the second position (divided in half to fit on left side of screen.  Negated Y value to flip skeleton right side up)
  ellipse(xB, yB, 5, 5);
  
  //draw a joint between two  (divided in half to fit all of skeleton onto vertical area of screen.  Negated Y value to flip skeleton right side up)
  //line(xA, yA, xB, yB);
  
  //Begin drawing the limb between the joints
  //draw oval from one joint to another
  Float distance = sqrt(sq(xA - xB) + sq(yA - yB));
  Float radius = distance / 2;
  Float heigh = distance / 4;
  
  //what to modify the point by to get midpoint
  Float xMod = (xA - xB) / 2;
  Float yMod = (yA - yB) / 2;
  
  //placeholders for midpoints and what will be the new point to calc angle from
  Float xM;
  Float yM;
  Float newX;
  Float newY;
  //figure out which point is the one to be modified to find midpoint
  if (xMod >= 0){
    if (xA > xB){
      xM = xB + xMod;
      yM = yB + yMod;
      newX = xA - xM;
      newY = yA - yM;
    } else {
      xM = xA + xMod;
      yM = yA + yMod;
      newX = xB - xM;
      newY = yB - yM;
    }
  } else {
    if (xA > xB){
      xM = xA + xMod;
      yM = yA + yMod;
      newX = xA - xM;
      newY = yA - yM;
    } else {
      xM = xB + xMod;
      yM = yB + yMod;
      newX = xA - xM;
      newY = yA - yM;
    }
  }
  println("point A: (" + xA + ", " + yA + ")");
  println("point B: (" + xB + ", " + yB + ")");
  println("midpoint: (" + xM + ", " + yM + ")");
  println("new point: (" + newX + ", " + newY + ")");
  println("distance: " + distance);

//  Float cosRad = cos((sq(radius) + sq(radius) - sq(newY)) / (2 * radius * radius));
  Float cosRad = cos(1 - (sq(newY) / (2 * sq(radius))));
  Float radians = acos(cosRad);
  println("radians: " + radians);

  fill(0,0,0);
  //texture(txt);
  
  pushMatrix();
  translate(xM, yM);
  rotate(PI * radians);
  if (thicker){
    ellipse(0, 0, distance, 45);
  } else {
    ellipse(0, 0, distance, 10);
  }
  
  popMatrix();
}

public float alignX(PVector skeA)
{
  if (skeA.x < midWidth)
    return  midWidth - skeA.x;
  else
    return skeA.x - midWidth;
}
public float alignY(PVector skeA)
{
  return skeA.y + midHeight;
}


/*---------------------------------------------------------------
 Takes in the name of the csv skeleton file you want to play back and plays it
 ----------------------------------------------------------------*/
public void playVideo(String filename) {
  //read the file specified
  if (!dancePlayback) {
    //Load a CSV of skeleton data from into a table and return true if successful.  Otherwise return false.
    dancePlayback = readCsv(sketchPath(recordingsFolder + "/" + filename).toString());
  }
  playBack (numIterationsCompleted); //play back the skeletons
  numIterationsCompleted++;
}



/*--------------------------------------------------------------
 assigns the appropriate list of filenames depending on the current day selected
 --------------------------------------------------------------*/
public void fileForDaySelected() {

  if (currentDaySelected == 1) {
    danceChoreoFiles[0] = "combo1_first8.csv";
    danceChoreoFiles[1] = "1choreo_1.csv";
    danceChoreoFiles[2] = "combo1_third8.csv";
    danceChoreoFiles[3] = "1choreo_3.csv";
  } else if (currentDaySelected == 2) {
    danceChoreoFiles[0] = "bird_first8.csv";
    danceChoreoFiles[1] = "2choreo_1.csv";
    danceChoreoFiles[2] = "bird_third8.csv";
    danceChoreoFiles[3] = "2choreo_3.csv";
  } else if (currentDaySelected == 3) {
    danceChoreoFiles[0] = "car_first8.csv";
    danceChoreoFiles[1] = "3choreo_1.csv";
    danceChoreoFiles[2] = "car_third8.csv";
    danceChoreoFiles[3] = "3choreo_3.csv";
  }
}

/*--------------------------------------------------------------
 logic for playing through the list of files
 --------------------------------------------------------------*/
public void playDances() {
  music = true;
  //loop through each csv file in the current day's dances
  //loop until reach every current file name in array
  if (currentDanceSegment < danceFileNames.length) {
    playVideo(danceFileNames[currentDanceSegment]);
  } else if (currentChoreoSegment == 0 || currentChoreoSegment == 2) {
    playVideo(danceChoreoFiles[currentChoreoSegment]);
  } else if (currentChoreoSegment == 1 || currentChoreoSegment == 3) {
    //countdown to the recording
    if (recordMode && waitingToRecord) { //haven't recorded yet and record mode activated
      countdownRecord();
    } else if (!recordMode && waitingToRecord) { //haven't recorded yet and record mode waiting
      drawMessage("Press SPACE to begin recording.");
    } else if (!recordMode && !waitingToRecord) { //finished recording
      if (currentChoreoSegment == 1){
        saveSkeletonTable(currentDaySelected + "choreo_" + currentChoreoSegment, choreoA); //save full play through of skeletal data
      }else{
        saveSkeletonTable(currentDaySelected + "choreo_" + currentChoreoSegment, choreoB); //save full play through of skeletal data
      }
      
      currentChoreoSegment++;
      waitingToRecord = true;
      countdownReady = 0;
    }
  } else if (playthroughChoreo < danceChoreoFiles.length) {
    playVideo(danceChoreoFiles[playthroughChoreo]);
  }

  //when all done reset counters and go back to title screen
  if (currentDanceSegment == danceFileNames.length && currentChoreoSegment == danceChoreoFiles.length && playthroughChoreo == danceChoreoFiles.length) {
    currentDanceSegment = 0; //reset segment count
    currentChoreoSegment = 0; //reset choreo segment count
    println("Dance Segment: " + currentDanceSegment);
    println("Choreo Segment: " + currentChoreoSegment);
    pauseMusic();
    music = false;
    phase = "title";
  }
}
/*---------------------------------------------------------------
File contains the logic to record diagnostic information regarding
choices player made, dances played back, etc.
----------------------------------------------------------------*/
public void beginWritingLogFile () {
  //Check to see if file exists
  //String[] arrayOfFileLines = loadFile()  
   logFile.println ("DANCECRAFT LOG FILE" + "\n");
   logFile.println ("___________________________________________________________" + "\n");
   logFile.println ("Username: TEST User Name" + "\n");
 }

public void closeLogFile () {
  //Close and finalize log file
  logFile.flush();
  logFile.close();
}
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
int rectColor = color(50, 55, 100);
int rectHighlightColor = color(150, 155, 155);
int rectPressedColor = color(100, 105, 155);
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
int countdownReady = 0;

PImage[] buttonImages = new PImage[4];

//Title Background Color
int backgroundColorTitle = color(51,51,153);

//Title Screen Images
PImage title;

/*---------------------------------------------------------------
Draws the right screen size with other set parameters
----------------------------------------------------------------*/
public void drawScreen(){
  frame.setTitle("DanceCraft"); //sets window title
  size(width,height, P3D);
  font=createFont("Arial", 48);
  textFont(font); 
}

/*---------------------------------------------------------------
Draw the dance screen. Calls the animation/background image. Calls Kinect class.
----------------------------------------------------------------*/
public void drawDanceScreen() {
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
  
  recordIndicator();
  
  if (phase == "tutorial"){
     image(tutorial, 0, 0, 340, 300);
     tutorial.read(); 
  } else if (phase == "dance"){
     //COMMENT OUT THIS LINE TO RUN WITHOUT KINECT
     //kinectDance(); 
  }
}

/*---------------------------------------------------------------
Draw the main title screen.
----------------------------------------------------------------*/
public void drawTitleScreen() {
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
    
    //fill(255);
    //textSize(18);
    //textAlign(CENTER, CENTER);
    //text(buttonNames[i], distanceFromLeft,y,buttonWidth,buttonHeight-5);
    image(buttonImages[i], distanceFromLeft,y,buttonWidth,buttonHeight-5);
  }
}

/*---------------------------------------------------------------
Draw String to screen
----------------------------------------------------------------*/
public void drawMessage(String message){
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
public void clearScreen(){
 background(255); 
}

/*---------------------------------------------------------------
counts down to when recording starts
----------------------------------------------------------------*/
public void countdownRecord(){
  if (countdownReady < countdownTimer.length){
    drawMessage(countdownTimer[countdownReady]);
    delay(800);
    countdownReady++;
  }else if (countdownReady == countdownTimer.length){
    waitingToRecord = false;
  }
}

/*---------------------------------------------------------------
Display a RED dot when RecordMode is true
----------------------------------------------------------------*/
public void recordIndicator(){
  if (recordMode){
    //Draw red circle indicatiing that we are recording
    fill (189, 41, 2);
    ellipse (width-20, 20, 20, 20);
  }
}


/*---------------------------------------------------------------
Imports
----------------------------------------------------------------*/
// import kinect library


/*---------------------------------------------------------------
Variables
----------------------------------------------------------------*/
// create kinect object
SimpleOpenNI kinect;
// boolean if kinect is tracking
boolean tracking = false;
// image storage from kinect
PImage kinectDepth;
// int of each user being tracked
int[] userID;

// mapping of users
int[] userMapping;
int[] depthValues;
// background image
PImage backgroundImage;
// image from rgb camera
PImage rgbImage;

//Joint array
String[] joint = {"HEAD", "NECK", "LEFT_SHOULDER", "RIGHT_SHOULDER", "LEFT_ELBOW", "RIGHT_ELBOW", "LEFT_HAND", "RIGHT_HAND", "TORSO", "LEFT_HIP", "RIGHT_HIP", "LEFT_KNEE", "RIGHT_KNEE", "LEFT_FOOT", "RIGHT_FOOT"};

//used to save recorded skeleton data
int fileWritten = 1;
String dataLocation = new String();
String poseDataLocation = "data/csvPoseData.csv";
String anglesLocation = "data/csvAngles.csv";
float threshold = 50;


float[][] poseJointArray;
PVector[][] skel_data;

//Table for Kinect Data to be stored in CSV
//Table table = new Table();
Table fullRecordTable = setUpTable();
Table choreoA = setUpTable();
Table choreoB = setUpTable();
Table loadedSkelTable = new Table();

PVector[] j1;



/*---------------------------------------------------------------
Starts new kinect object and enables skeleton tracking.
Draws window
----------------------------------------------------------------*/
public void kinectSetup()
{

 // start a new kinect object
 kinect = new SimpleOpenNI(this);
 kinect.setMirror(true);
 // enable depth sensor
 kinect.enableDepth();

 // enable color camera
  kinect.enableRGB(1280, 1024, 15);

 //trim the camera for better Image
 kinect.alternativeViewPointDepthToImage();
 kinect.setDepthColorSyncEnabled(true);

 // enable skeleton generation for all joints
 kinect.enableUser();

} // void setup()

/*---------------------------------------------------------------
Updates Kinect. Gets users tracking and draws skeleton and
head if confidence of tracking is above threshold
----------------------------------------------------------------*/
public void kinectDance(){

  // update the camera
  kinect.update();

   // get the Kinect color image
  rgbImage = kinect.rgbImage();

   // prepare the color pixels
  loadPixels();

  //tint(255, 126);  // Display at half opacity

  //Create black color to turn user into a shadow
  //color black = color (0, 0, 0, 63);
  // get pixels for the user tracked
  userMapping = kinect.userMap();

  // for the length of the pixels tracked, color them
  // in with the rgb camera
  for (int i =0; i < userMapping.length; i++) {
    // if the pixel is part of the user
    if (userMapping[i] != 0) {
      // set the pixel color of the part of the display that is the user to black
      pixels[i] = color (50, 50, 100, 63);
    }
  } // (int i =0; i < userMap.length; i++)

  // update any changed pixels
  updatePixels();

  //get the list of users
  int[] users = kinect.getUsers();

  for(int i = 0; i < users.length; i++)
   {
     
     //check if the user has skeleton
    if(kinect.isTrackingSkeleton(users[i])) {
     PVector currentPosition = new PVector();
     //add information to table
     //drawSkeleton(users[i]);
     recordingDance(users[i], currentPosition, fullRecordTable);
       
       //if in recordMode, save the users tracked information to data files
       if(recordMode){
          //PVector currentPosition = new PVector();
          //add information to table
          if (currentChoreoSegment == 1){
            recordingDance(users[i], currentPosition, choreoA);
          }else{
            recordingDance(users[i], currentPosition, choreoB);
          }
          //recordingDance(users[i], currentPosition, choreoA);
        }
    }
   }
} //end KinectDance function

/*---------------------------------------------------------------
When a new user is found, print new user detected along with
userID and start pose detection. Input is userID
----------------------------------------------------------------*/
public void onNewUser(SimpleOpenNI curContext, int userId){
 println("New User Detected - userId: " + userId);
 // start tracking of user id
 curContext.startTrackingSkeleton(userId);
} //void onNewUser(SimpleOpenNI curContext, int userId)

/*---------------------------------------------------------------
Print when user is lost. Input is int userId of user lost
----------------------------------------------------------------*/
public void onLostUser(SimpleOpenNI curContext, int userId){
 // print user lost and user id
 println("User Lost - userId: " + userId);
} //void onLostUser(SimpleOpenNI curContext, int userId)

/*--------------------------------------------------------------
Recording all joint data and sending to CSV File
--------------------------------------------------------------*/
public void recordingDance(int userID, PVector currentPosition, Table table) {
//add information to table
          AddToCSV(userID, SimpleOpenNI.SKEL_HEAD,currentPosition, table); //0
          AddToCSV(userID, SimpleOpenNI.SKEL_NECK,currentPosition, table); //1
          AddToCSV(userID, SimpleOpenNI.SKEL_LEFT_SHOULDER,currentPosition, table); //2
          AddToCSV(userID, SimpleOpenNI.SKEL_RIGHT_SHOULDER,currentPosition, table); //3
          AddToCSV(userID, SimpleOpenNI.SKEL_LEFT_ELBOW,currentPosition, table); //4
          AddToCSV(userID, SimpleOpenNI.SKEL_RIGHT_ELBOW,currentPosition, table); //5
          AddToCSV(userID, SimpleOpenNI.SKEL_LEFT_HAND,currentPosition, table); //6
          AddToCSV(userID, SimpleOpenNI.SKEL_RIGHT_HAND,currentPosition, table); //7
          AddToCSV(userID, SimpleOpenNI.SKEL_TORSO,currentPosition, table); //8
          AddToCSV(userID, SimpleOpenNI.SKEL_LEFT_HIP,currentPosition, table); //9
          AddToCSV(userID, SimpleOpenNI.SKEL_RIGHT_HIP,currentPosition, table); //10
          AddToCSV(userID, SimpleOpenNI.SKEL_LEFT_KNEE,currentPosition, table); //11
          AddToCSV(userID, SimpleOpenNI.SKEL_RIGHT_KNEE,currentPosition, table); //12
          AddToCSV(userID, SimpleOpenNI.SKEL_LEFT_FOOT,currentPosition, table); //13
          AddToCSV(userID, SimpleOpenNI.SKEL_RIGHT_FOOT,currentPosition, table); //14
}

/*--------------------------------------------------------------
Writing all joint data to a table for CSV file format
--------------------------------------------------------------*/
public void AddToCSV(int userID, int _joint, PVector currentPosition, Table table) {
  kinect.getJointPositionSkeleton(userID, _joint, currentPosition);
  
  float _x = currentPosition.x;
  float _y = currentPosition.y;
  float _z = currentPosition.z;
  
  // Create a new row
  TableRow row = table.addRow();
  //println(table.getRowCount() + " total rows in table");
  
  // Set the values of that row
  row.setInt("joint", _joint);
  row.setFloat("x", _x);
  row.setFloat("y", _y);
  row.setFloat("z", _z);
  row.setString("jointname", joint[_joint]);
  row.setString("time", currentTime);
}

/*-------------------------------------------------
Save the Skeleton Data to a specific location
-----------------------------------------------------*/
public void saveSkeletonTable(String fileName, Table table) {
  //dataLocation = selection.getAbsolutePath();  //Assign path selected by user into var for use in filename

  saveTable(table, "data/" + fileName + ".csv", "csv"); //Write table to location
  println("saved "+fileName+".csv");
  println(table.getRowCount() + " total rows in table");
  //isPaused = false;
}

/*-------------------------------------------------
Draw a rudimentary skeleton on top of the player
-----------------------------------------------------*/
public void drawSkeleton (int userId) {
	//Set color of skeleton "bones" to black
	stroke(0);
	//Set weight of line
	strokeWeight (5);

	kinect.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);
	kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
	kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
	kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);
	kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
	kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
	kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
	kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
	kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
	kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
	kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
        kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);
	kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
	kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
	kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
	kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_LEFT_HIP);

  noStroke();

  fill(255,0,0);

  //Begin drawing the joints of the skeleton
  drawJoint(userId, SimpleOpenNI.SKEL_HEAD);
  drawJoint(userId, SimpleOpenNI.SKEL_NECK);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_ELBOW);
  drawJoint(userId, SimpleOpenNI.SKEL_NECK);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  drawJoint(userId, SimpleOpenNI.SKEL_TORSO);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HIP);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_KNEE);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_HIP);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_FOOT);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_KNEE);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HIP);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_FOOT);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_HAND);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HAND);

}

/*-------------------------------------------------
Draw the joint bubbles on the skeleton on the player skeleton
-----------------------------------------------------*/
public void drawJoint (int userId, int jointID) {
  PVector joint = new PVector();
  float confidence = kinect.getJointPositionSkeleton(userId, jointID, joint);
  if (confidence < 0.5f) {
    return;
  }
  PVector convertedJoint = new PVector();
  kinect.convertRealWorldToProjective (joint, convertedJoint);
  ellipse(convertedJoint.x, convertedJoint.y, 5, 5);
}


public Table setUpTable (){
 Table table = new Table();
 //Add colums to table that is going to store CSV data of skeleton
 table.addColumn("joint", Table.INT);
 table.addColumn("x", Table.FLOAT);
 table.addColumn("y", Table.FLOAT);
 table.addColumn("z", Table.FLOAT);
 table.addColumn("jointname", Table.STRING);
 table.addColumn("time", Table.STRING);
 
 return table;
}
//Movie tutorial;



public void movieSetup(){
    tutorial = new Movie(this, "elements/bee.mov");
}

public void drawMovie(){
   if (tutorial.available()) {
     tutorial.read();
     image(tutorial, 0, 0, width, height);
   }
}


public void movieEvent(Movie m) {
//  println("playing frame" + m.time() + " out of " + m.duration());
//  m.read();
 if(m.time()+.1f >= m.duration()) {// 1 && !m.available()){
   println("STOPPING???");
//   tutorial.stop();
   phase="title";
 }
}


//AudioPlayer player;
AudioPlayer soundtrack;
Minim minim;//audio context
int track = 1; //initial track number
String trackNum; //holds track number for calling from file

public void musicSetup(){
  //start the music player
  minim = new Minim(this);
  getTrack(track);
}

public void musicPlay(){
    //getTrack(track);
    soundtrack.play();
    
//loop of music playing
  if (music){ 
    //plays the music
    if(!soundtrack.isPlaying()){
      soundtrack.pause();
      soundtrack.rewind();
      soundtrack.play();
    }
  }
}//Boolean music

//pause music
public void pauseMusic(){
 soundtrack.pause(); 
}

public void stop()
{
  soundtrack.close();
  minim.stop();
  super.stop();
}

public void getTrack(int track){
  //trackNum = "music/"+track+".mp3";
  //soundtrack = minim.loadFile(trackNum, 2048);
  soundtrack = minim.loadFile("music/ferrisWheel.mp3", 2048);
  println("playing music.");
}

public void randomTrack(){
  track = PApplet.parseInt(random(23)) + 1;
  println("Now playing track number: " + track);
  getTrack(track);
}
//This class based on code found here: http://www.goldb.org/stopwatchjava.html
public class StopWatchTimer {
  int startTime = 0, stopTime = 0;
  boolean running = false;

  public void start() {
    startTime = millis();
    running = true;
  }
  public void stop() {
    stopTime = millis();
    running = false;
  }
  public int getElapsedTime() {
    int elapsed;
    if (running) {
      elapsed = (millis() - startTime);
    }
    else {
      elapsed = (stopTime - startTime);
    }
      return elapsed;
  }

  public int getSeconds() {
    return (getElapsedTime() / 1000) % 60;
  }

  public int getMinutes() {
    return (getElapsedTime() / (1000*60)) % 60;
  }
  public int getHours() {
    return (getElapsedTime() / (1000*60*60)) % 24;
  }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--hide-stop", "DanceCraftFinal" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
