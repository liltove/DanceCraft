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

int[] refKinect = new int[25];

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
      drawBack(skel_data[rowNum][0], skel_data[rowNum][1]); //Head and neck
      drawBack(skel_data[rowNum][1], skel_data[rowNum][2]); //Neck and left shoulder
      drawBack(skel_data[rowNum][2], skel_data[rowNum][4]); //Left shoulder and Left elbow
      drawBack(skel_data[rowNum][4], skel_data[rowNum][6]); //Left elbow and left hand
      drawBack(skel_data[rowNum][1], skel_data[rowNum][3]); //Neck and right shoulder
      drawBack(skel_data[rowNum][3], skel_data[rowNum][5]); //Right shoulder and right elbow
      drawBack(skel_data[rowNum][5], skel_data[rowNum][7]); //Right elbow and right hand
      drawBack(skel_data[rowNum][2], skel_data[rowNum][8]); //Left shoulder and TORSO
      drawBack(skel_data[rowNum][3], skel_data[rowNum][8]); //Right shoulder and TORSO
      drawBack(skel_data[rowNum][8], skel_data[rowNum][9]); //Torso and left Hip
      drawBack(skel_data[rowNum][9], skel_data[rowNum][11]); //Left hip and left Knee
      drawBack(skel_data[rowNum][11], skel_data[rowNum][13]); //left knee and left foot
      drawBack(skel_data[rowNum][8], skel_data[rowNum][10]); ///Torso and right hip
      drawBack(skel_data[rowNum][10], skel_data[rowNum][12]); //Right hip and right knee
      drawBack(skel_data[rowNum][12], skel_data[rowNum][14]); //Right knee and right foot
      drawBack(skel_data[rowNum][10], skel_data[rowNum][9]); //Right hip and left hip
    } else {

      // BEGIN MODEL PLAYING
      pushMatrix();
      ZZoint[] zzpoint = new ZZoint[25];
      
      // stuff grabbed from prev data
      zzpoint[ZZkeleton.HEAD] = new ZZoint(skel_data[rowNum][0]);
      zzpoint[ZZkeleton.NECK] = new ZZoint(skel_data[rowNum][1]);
      zzpoint[ZZkeleton.SHOULDER_LEFT] = new ZZoint(skel_data[rowNum][2]);
      zzpoint[ZZkeleton.SHOULDER_RIGHT] = new ZZoint(skel_data[rowNum][3]);
      zzpoint[ZZkeleton.ELBOW_LEFT] = new ZZoint(skel_data[rowNum][4]);
      zzpoint[ZZkeleton.ELBOW_RIGHT] = new ZZoint(skel_data[rowNum][5]);
      zzpoint[ZZkeleton.HAND_LEFT] = new ZZoint(skel_data[rowNum][6]);
      zzpoint[ZZkeleton.HAND_RIGHT] = new ZZoint(skel_data[rowNum][7]);
      zzpoint[ZZkeleton.TORSO] = new ZZoint(skel_data[rowNum][8]);
      zzpoint[ZZkeleton.HIP_LEFT] = new ZZoint(skel_data[rowNum][9]);
      zzpoint[ZZkeleton.HIP_RIGHT] = new ZZoint(skel_data[rowNum][10]);
      zzpoint[ZZkeleton.KNEE_LEFT] = new ZZoint(skel_data[rowNum][11]);
      zzpoint[ZZkeleton.KNEE_RIGHT] = new ZZoint(skel_data[rowNum][12]);
      zzpoint[ZZkeleton.FOOT_LEFT] = new ZZoint(skel_data[rowNum][13]);
      zzpoint[ZZkeleton.FOOT_RIGHT] = new ZZoint(skel_data[rowNum][14]);


      // generated stuff
      
      // calcul du bassin waist
      
      zzpoint[ZZkeleton.WAIST] = zzpoint[ZZkeleton.HIP_LEFT].copy();
      zzpoint[ZZkeleton.WAIST].avg(zzpoint[ZZkeleton.HIP_RIGHT]);
      
      // calcul de la racine root
      zzpoint[ZZkeleton.ROOT] = zzpoint[ZZkeleton.WAIST].copy();
      zzpoint[ZZkeleton.ROOT].avg(zzpoint[ZZkeleton.TORSO]);
          
      // copie des poignets dans les mains
      zzpoint[ZZkeleton.WRIST_LEFT] = zzpoint[ZZkeleton.HAND_LEFT];
      zzpoint[ZZkeleton.WRIST_RIGHT] = zzpoint[ZZkeleton.HAND_RIGHT];

      zzpoint[ZZkeleton.ANKLE_LEFT] = zzpoint[ZZkeleton.FOOT_LEFT];
      zzpoint[ZZkeleton.ANKLE_RIGHT] = zzpoint[ZZkeleton.FOOT_RIGHT];
      zzpoint[ZZkeleton.INDEX_LEFT] = zzpoint[ZZkeleton.HAND_LEFT];
      zzpoint[ZZkeleton.THUMB_LEFT] = zzpoint[ZZkeleton.HAND_RIGHT];
      zzpoint[ZZkeleton.INDEX_RIGHT] = zzpoint[ZZkeleton.HAND_LEFT];
      zzpoint[ZZkeleton.THUMB_RIGHT] = zzpoint[ZZkeleton.HAND_RIGHT];

//      // mise a jour des infos mains
//      joinedHands.set(zzpoint[ZZkeleton.HAND_RIGHT]);
//      joinedHands.sub(zzpoint[ZZkeleton.HAND_LEFT]);
//      joinedHands.state = joinedHands.mag() < 50 ? 1 : 0;

      better.addEch(zzpoint);
      pushMatrix();
      popMatrix();
            if (better.dataAvailable()) {    // si on a des donnees optimisees disponibles
              clone.move(better.getOptimizedValue());  // on fait bouger l'avatar
              //println("BETTER??");
            }
      clone.move(zzpoint);
      clone.translate(width / 2, (height / 2)+100, 0);
      clone.draw();
      popMatrix();
      // END MODEL PLAYING
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
void drawBack(PVector skeA, PVector skeB)
{

  //Set color of skeleton "bones" to black
  stroke(0);
  //Set weight of line
  strokeWeight (5);

  float xA = 0.25 * (offsetX + skeA.x);
  float yA = 0.25 * ((-skeA.y) + offsetY);
  float xB = 0.25 * (offsetX + skeB.x);
  float yB = 0.25 * ((-skeB.y) + offsetY);
  //draw a point for the first position (divided in half to fit on left side of screen.  Negated Y value to flip skeleton right side up)
  ellipse(xA, yA, 5, 5);
  //draw a point for the second position (divided in half to fit on left side of screen.  Negated Y value to flip skeleton right side up)
  ellipse(xB, yB, 5, 5);
  //draw a joint between two  (divided in half to fit all of skeleton onto vertical area of screen.  Negated Y value to flip skeleton right side up)
  //line(xA, yA, xB, yB);
  //draw oval from one joint to another
  Float xs = (xA + xB) / 2;
  Float ys = (yA + yB) / 2;
  Float distance = sqrt(sq(xA - xB) + sq(yA - yB));
  Float radius = distance / 2;
  Float xM = (xA - xB) / 2;
  Float yM = (yA - yB) / 2;
  Float xC = xM - radius;
  Float yC = yM;
  Float thirdDis = sqrt(sq(xA - xC) + sq(yA - yC));
  //Float arcDistance = sqrt(sq(xA - xC) + sq(yA - yC));
  //Float cosRad = cos(1 - (sq(arcDistance) / (2 * sq(radius))));
  //Float radians = acos(cosRad);
  Float cosRad = cos((sq(radius) + sq(radius) - sq(thirdDis)) / (2 * radius * radius));
  Float radians = acos(cosRad);
  println(radians);
  fill(0,0,0);
  rotate(radians);
  ellipse(xs, ys, distance, 25);
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

/*--------------------------------------------------------------
 play back model on screen
 --------------------------------------------------------------*/
void populateRefKinect(){
  //Matching du skeleton avec une kinect1
      refKinect[ZZkeleton.WAIST] = -100;
      refKinect[ZZkeleton.ROOT] = -101;
      refKinect[ZZkeleton.NECK] = SimpleOpenNI.SKEL_NECK;
      refKinect[ZZkeleton.HEAD] = SimpleOpenNI.SKEL_HEAD;
      refKinect[ZZkeleton.SHOULDER_LEFT] = SimpleOpenNI.SKEL_LEFT_SHOULDER;
      refKinect[ZZkeleton.ELBOW_LEFT] = SimpleOpenNI.SKEL_LEFT_ELBOW;
      refKinect[ZZkeleton.WRIST_LEFT] = SimpleOpenNI.SKEL_LEFT_HAND; // inversion main poignet
      refKinect[ZZkeleton.HAND_LEFT] = -100;                 // inversion avec wrist
      refKinect[ZZkeleton.SHOULDER_RIGHT] = SimpleOpenNI.SKEL_RIGHT_SHOULDER;  
      refKinect[ZZkeleton.ELBOW_RIGHT] = SimpleOpenNI.SKEL_RIGHT_ELBOW;
      refKinect[ZZkeleton.WRIST_RIGHT] = SimpleOpenNI.SKEL_RIGHT_HAND; // inversion main poignet
      refKinect[ZZkeleton.HAND_RIGHT] = -100;                // inversion main poignet
      refKinect[ZZkeleton.HIP_LEFT] = SimpleOpenNI.SKEL_LEFT_HIP;  
      refKinect[ZZkeleton.KNEE_LEFT] = SimpleOpenNI.SKEL_LEFT_KNEE;
      refKinect[ZZkeleton.ANKLE_LEFT] = SimpleOpenNI.SKEL_LEFT_FOOT; // ankle left            // INVERSION pied cheville
      refKinect[ZZkeleton.FOOT_LEFT] = -100;              // INVERSION pied cheville
      refKinect[ZZkeleton.HIP_RIGHT] = SimpleOpenNI.SKEL_RIGHT_HIP;  
      refKinect[ZZkeleton.KNEE_RIGHT] = SimpleOpenNI.SKEL_RIGHT_KNEE;
      refKinect[ZZkeleton.ANKLE_RIGHT] = SimpleOpenNI.SKEL_RIGHT_FOOT; // ankle right            // INVERSION pied cheville
      refKinect[ZZkeleton.FOOT_RIGHT] = -100;    // INVERSION pied cheville
      refKinect[ZZkeleton.TORSO] = SimpleOpenNI.SKEL_TORSO;  
      refKinect[ZZkeleton.INDEX_LEFT] = SimpleOpenNI.SKEL_LEFT_FINGERTIP;
      refKinect[ZZkeleton.THUMB_LEFT] = -100;
      refKinect[ZZkeleton.INDEX_RIGHT] = SimpleOpenNI.SKEL_RIGHT_FINGERTIP;
      refKinect[ZZkeleton.THUMB_RIGHT] = -100;
      println("here");
}
