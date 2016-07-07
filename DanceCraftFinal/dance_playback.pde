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
Boolean readCsv(String selection)
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
void playBack(Integer rowNum)
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
void drawBack(PVector skeA, PVector skeB, Boolean thicker, Boolean isHead)
{

  //Set color of skeleton "bones" to black
  stroke(0);
  //Set weight of line
  strokeWeight (5);
  //load texture image
  //PImage txt = loadImage("crumpledPaper.jpg");

  float xA = 0.25 * (offsetX + skeA.x);
  float yA = 0.25 * ((-skeA.y) + offsetY);
  float xB = 0.25 * (offsetX + skeB.x);
  float yB = 0.25 * ((-skeB.y) + offsetY);
  
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
//  println("point A: (" + xA + ", " + yA + ")");
//  println("point B: (" + xB + ", " + yB + ")");
//  println("midpoint: (" + xM + ", " + yM + ")");
//  println("new point: (" + newX + ", " + newY + ")");
//  println("distance: " + distance);

//  Float cosRad = cos((sq(radius) + sq(radius) - sq(newY)) / (2 * radius * radius));
  Float cosRad = cos(1 - (sq(newY) / (2 * sq(radius))));
  Float radians = acos(cosRad);
//  println("radians: " + radians);

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

float alignX(PVector skeA)
{
  if (skeA.x < midWidth)
    return  midWidth - skeA.x;
  else
    return skeA.x - midWidth;
}
float alignY(PVector skeA)
{
  return skeA.y + midHeight;
}


/*---------------------------------------------------------------
 Takes in the name of the csv skeleton file you want to play back and plays it
 ----------------------------------------------------------------*/
void playVideo(String filename) {
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
void fileForDaySelected() {

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
void playDances() {
  music = true;
  //loop through each csv file in the current day's dances
  //loop until reach every current file name in array
  if (currentDanceSegment < danceFileNames.length) {
    playVideo(danceFileNames[currentDanceSegment]);
  } else if (currentChoreoSegment == 0 || currentChoreoSegment == 2) {
    playVideo(danceChoreoFiles[currentChoreoSegment]);
  } else if (currentChoreoSegment == 1 || currentChoreoSegment == 3) {
    //countdown to the recording
    if (recordMode && waitingToRecord && !finishedRecording) { //haven't recorded yet and record mode activated
      countdownRecord();
    } else if (!recordMode && waitingToRecord && !finishedRecording) { //haven't recorded yet and record mode waiting
      drawMessage("Press SPACE to begin recording.");
    } else if (!recordMode && !waitingToRecord && !finishedRecording) { //finished recording but not saved yet
      //save current recording to csv file
      if (currentChoreoSegment == 1){
          saveSkeletonTable(currentDaySelected + "choreo_" + currentChoreoSegment, choreoA); //save full play through of skeletal data
        }else{
          saveSkeletonTable(currentDaySelected + "choreo_" + currentChoreoSegment, choreoB); //save full play through of skeletal data
        }
        finishedRecording = true;
    } else if (!recordMode && !waitingToRecord && finishedRecording) { //finished recording, dance is saved in csv
      //check to see if they want to save the dance
      drawMessage("To KEEP recorded dance, press 'k'." + '\n' + "To WATCH recorded dance, press 'w'." + '\n' + "To REDO recorded dance, press 'r'.");
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

void keepRecordedDance(){
  currentChoreoSegment++;
  finishedRecording = false;
  waitingToRecord = true;
  countdownReady = 0;
}

void watchRecordedDance(){
  finishedRecording = false;
  playVideo(danceChoreoFiles[currentChoreoSegment]);
  //finishedRecording = true;
}

void redoRecordedDance(){
  finishedRecording = false;
  waitingToRecord = true;
  countdownReady = 0;
}
