//import processing.video.*;
import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
//import controlP5.*;
import java.util.ArrayList;

//ControlP5 cp5;
PFont font;

String phase, mode;
Boolean teacherMode = false; //Change this to true if you want to record new teacher dances
Boolean playTeacherRecording = true;
Boolean teacherDone = false;
Boolean playingBack = false;
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

//CHANGE THIS LINE IF YOU DON'T WANT TO START AT THE BEGINNING!!
int currentDanceSegment = 2; //which segment of the dance are we on //0- warmup, 1- technique, 2- choreo
int currentChoreoSegment = 0; //which segment of choreo are we on //0- first 8, 1- record, 2- second 8, 3- record
int playthroughChoreo = 0; //final play through of all choreo files
int numTimesTutorialPressed = 0;  //used to keep track of the times Tutorial button is pressed
Boolean waitingToRecord = true; //waiting on record mode
Boolean recorded = false;
//Boolean watchRecording = false; //do they want to replay what they just recorded?
Boolean savedRecording = false; //did the choreo get saved?
//Boolean finishedRecording = false; //are they all done recording?

//holds tutorial movie
//Movie tutorial;

//dance backgrounds
PImage danceBackdrop;
String[] danceBG = {"Day1BG.png", "Day2BG.png", "Day3BG.png"};

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

float k = 0.0;
PVector pos;

//SET SIZE OF WINDOW
int width = 640; // window width
int height = 480; // window height

void setup() {
  size(640, 480);

  logFile = createWriter(dataPath("") + "/DanceCraftUserLog" + currentDate + "_" + currentTime + ".txt");
  beginWritingLogFile(); //Begin creation of log file for DC researchers
  logFile.println ("Time of day launched:" + " " + currentTimeWithColons); //Log the time of day that the program was lanuched.
  frameRate(30);

  smooth();
  drawScreen();
  if (teacherMode) {
    phase = "teacherMode";
  } else {
    phase = "title";
  }
  println(phase);
  //music = true;
  figure = true;

  //COMMENT OUT THIS LINE TO RUN WITHOUT KINECT
  kinectSetup();

  minim = new Minim(this);
  musicSetup();
  //movieSetup();

  background = 0;

  initializeQueueArray();

  //Fill the Boolean array keysPressed with falses
  for (int i = 0; i < keysPressed.length; i++) {
    keysPressed[i] = false;
  }

  //Function defined at end of this file that allows for code after program quit to run
  prepareExitHandler();
  
  // to countdown seconds before choreo segment 2 starts
  countdown_time = millis();//store the current time
}

/*---------------------------------------------------------------
 Detect which phase of the program we are in and call appropriate draw function.
 ----------------------------------------------------------------*/
void draw() {
  //update time
  getCurrentTime();

  if (phase=="title") {
    drawTitleScreen();
    changeTracks(0); //reset to title music
  } else if (phase=="dance") {
    drawDanceScreen();
    playDances();
  } else if (phase=="tutorial") {
    pauseMusic(); //pause any music
    //drawMovie();
  } else if (phase=="teacherMode") {
    pauseMusic();
    drawDanceScreen();
    teacherRecording();
  }
}

/*---------------------------------------------------------------
 Senses when mouse is clicked and does appropriate action.
 ----------------------------------------------------------------*/
void mousePressed() {
  // go through each button
  for (int i = 0; i < buttonNames.length; i++) {
    // check to see if the mouse is currently hovering over the button
    if (buttonIsOver[i]) {
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
    if (buttonIsOver[i] && buttonIsPressed[i]) {
      //if it's tutorial, play the tutorial video, else select the day
      if (buttonNames[i].equals("Tutorial")) {
        println("Tutorial pressed");
        phase = "tutorial";

        buttonIsPressed[i] = false;
        buttonIsOver[i] = false;
        //tutorial.jump(0);
        //tutorial.play();
      } else {
        //update days to set which day is selected
        currentDaySelected = i+1;
        //Write information to log file
        logFile.println ("Time: " + currentTimeWithColons + "--" + "User has selected the dance sequence for Day " + currentDaySelected + "\n");
        //Create a timer to keep track of the fact the user has clicked on one of the dances
        totalTime.start();
        //make sure filenames are up to date
        fileForDaySelected();
        //change background image to appropriate day
        danceBackdrop = loadImage(danceBG[i]);
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
void keyPressed() {
  //Switch to recording mode if you're pressing SPACE
  if (keyPressed) {
    if (key == ' ' && phase == "dance" && recordMode == false  && allowRecordModeActivationAgain == true) {
      recordMode = true;
      waitingToRecord = true;
      allowRecordModeActivationAgain = false;
      println("Record Mode Activated");
      logFile.println("Record Mode Activated at: " + currentTimeWithColons);
    } else if (key == ' ' && phase == "dance" && recordMode == true && allowRecordModeActivationAgain == true ) {
      recordMode = false;
      allowRecordModeActivationAgain = false;
      //save recorded table to file
      //saveSkeletonTable("test", fullRecordTable);
      println("Record Mode Deactivated");
      logFile.println("Record Mode Deactivated at: " + currentTimeWithColons);
    } else if (key == ' ' && teacherMode) { //space bar starts and stops recording
      if (recordMode) {
        recordMode = false;
        keepRecordedDance();
      } else {
        recordMode = true;
      }
    } else if (key == 'm' || key =='M') {
      phase = "model";
    } else if (key == 'k' || key == 'K') {
      //only if they've finished recording
      if (!recordMode && !waitingToRecord) {
        keepRecordedDance();
        logFile.println ("Keeping recorded dance for Day  " + currentDaySelected + ", Choreo " + currentChoreoSegment + " at: " + currentTimeWithColons);
      } else if (teacherMode) {
        keepRecordedDance();
        println("Keep recorded dance");
      }
    } else if (key == 'r' || key == 'R') {
      //only if they've finished recording
      if (!recordMode && !waitingToRecord) {
        logFile.println ("Redoing recorded dance for Day  " + currentDaySelected + ", Choreo " + currentChoreoSegment + " at: " + currentTimeWithColons);
        redoRecordedDance();
      } else if (teacherMode) {
        println("redoing recorded dance");
        redoRecordedDance();
      }
    } else if (key == 'p' || key == 'P') {
      //play back the teacher's recording if in teacherMode  
      currentDanceSegment = 0;
      if (teacherMode) {
        if (!recordMode) {
          playingBack = true;
        }
      }
    } else if (key == 'v' || key == 'V') {
      //mark for voiceover in the CSV file
      println(curRow);
      markVoiceover(curRow);
    }
  }
}


void keyReleased() {
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

void getCurrentTime() {
  currentDay = String.valueOf(day());
  currentMonth = String.valueOf(month());
  currentYear = String.valueOf(year());
  currentHour = String.valueOf (hour());
  currentMinute = String.valueOf (minute());
  currentSecond = String.valueOf (second());
  currentTime = currentHour + currentMinute + currentSecond;
  currentTimeWithColons = currentHour + ":" + currentMinute + ":" + currentSecond;
  currentDate = currentMonth + "_" + currentDay + "_" + currentYear;
}

/*---------------------------------------------------------------
 Runs upon exiting the program, shuts down logging functions.
 ----------------------------------------------------------------*/
void prepareExitHandler () {
  Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {
    public void run () {
      System.out.println("SHUTDOWN HOOK");
      musicStop();
      totalTime.stop();
      logFile.println ("Time: " + currentTimeWithColons + "--" + "User has exited the game " + "\n");
      logFile.println ("Total time user has played: " + totalTime.getSeconds() + " seconds");
      saveSkeletonTable(currentDaySelected + "USERDATA" + currentTime, fullRecordTable); //save full play through of skeletal data
      closeLogFile();
      // application exit code here
    }
  }
  ));
}