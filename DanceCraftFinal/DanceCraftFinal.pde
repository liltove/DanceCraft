import processing.video.*;
import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import controlP5.*;
import java.util.ArrayList;

ControlP5 cp5;
PFont font;

String phase, mode;
String [] files;
String username, time;
String desktopPath = "\\records/";
String recordingsFolder = "data"; // this is the folder that kinect skeleton recordings is in
String recordingName = "better_dance_recording.csv"; // this is the file to temporarily use for the target recording to play
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
int currentDanceSegment = 1; //which segment of the dance are we on
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


// 3D Model stuff
protected ZZModel clone;        // modele courant
protected ZZkinect zzKinect;        // capteur kinect
protected ArrayList<ZZModel> avatars;  // modeles
protected ZZoptimiseur better;      // optimisation
final int NBCAPT = 3;  // nombre de captures pour moyennage


float normLength = -25;

float k = 0.0;
PVector pos;

void setup() {
  logFile = createWriter(dataPath("") + "/DanceCraftUserLog" + currentDate + "_" + currentTime + ".txt");
  beginWritingLogFile(); //Begin creation of log file for DC researchers
  logFile.println ("Time of day launched:" + " " + currentTime); //Log the time of day that the program was lanuched.
  smooth();
  drawScreen();
  phase = "title";
  //music = true;
  figure = true;

  //COMMENT OUT THIS LINE TO RUN WITHOUT KINECT
  kinectSetup();

  minim = new Minim(this);
  musicSetup();
  movieSetup();

  background = 0;

  //Fill the Boolean array keysPressed with falses
  for (int i = 0; i < keysPressed.length; i++) {
    keysPressed[i] = false;
  }

  // 3D Model stuff
    avatars = ZZModel.loadModels(this, "./modeldata/avatars.bdd");

    // recuperation du premier clone pour affichage
    clone = avatars.get(0);

    // Orientation et echelle du modele
    for (int i = 0; i < avatars.size (); i++) {
      avatars.get(i).scale(64);
      avatars.get(i).rotateY(PI);
      avatars.get(i).rotateX(PI);
      avatars.get(i).initBasis();
    }

    // initiallisation de l'optimiseur, NOT SURE IF WE NEED THIS OPTIMIZER OR NOT LEAVING FOR NOW
  better = new ZZoptimiseur(NBCAPT, clone.getSkeleton().getJoints());

  //Function defined at end of this file that allows for code after program quit to run
  prepareExitHandler();
}

/*---------------------------------------------------------------
Detect which phase of the program we are in and call appropriate draw function.
----------------------------------------------------------------*/
void draw() {
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
void keyPressed() {
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
} //End of KeyPressed function  //Methods

/*---------------------------------------------------------------
Runs upon exiting the program, shuts down logging functions.
----------------------------------------------------------------*/
void prepareExitHandler () {
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
