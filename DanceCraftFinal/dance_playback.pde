/*
This file contains the functions necessary for playing back "dances" recorded
by the user.
*/
//-------------------------------------------------------------//
float offsetX; //The offset x of the skeleton
float offsetY; // The offset y of the skeleton
float midWidth = 320 * 4; //middle width of the left half screen
float midHeight = 720; //middle height of the left haft screen

String[] danceFileNames= {"prewarmUp.csv", "mirror.csv"};
String[] danceChoreoFiles= {"combo1_first8.csv", "combo1_first8.csv", "combo1_third8.csv", "combo1_third8.csv"};

/*--------------------------------------------------------------
reads the csv and retrieves the joint coordinate information
--------------------------------------------------------------*/
Boolean readCsv(String selection)
{
  //read the csv file if something has been selected
  if (selection != null) {
    println(selection);
    loadedSkelTable = loadTable(selection, "header");
    //println(table);
    skel_data = new PVector [loadedSkelTable.getRowCount()/15][15]; //Initalize skel_data w/ row size = number of "skeletons" and column size = number of joints.
    int i = 0; //count the number of skeletons that are read
    int index; //count the join of the i skeleton that are read
    //iterate through each row of the table
    for (TableRow row : loadedSkelTable.rows()) {
      //println (row);
      //get the joint position
      index = row.getInt("joint");
      //println ("Index is --->" + index);
      //Create a new PVector to hold the stuff we're about to grab from the table
      PVector joint = new PVector();
      //Insert that PVector into the skel_data array
      skel_data[i][index] = joint;
      //println ("Inital Value at skel_data" + "[" +i+ "]" + "[" +index+ "]" + "---------->" + skel_data[i][index]);
      //set coordinates of index joint for i skeleton
      skel_data[i][index].x = row.getFloat("x");
      skel_data[i][index].y = row.getFloat("y");
      skel_data[i][index].z = row.getFloat("z");
      //println ("FINAL Value at skel_data" + "[" +i+ "]" + "[" +index+ "]" + "---------->" + skel_data[i][index]);
      //println ("Table row count is ---->" + table.getRowCount());
      //once the iteration has read all 14 joint, it starts recording a new skeleton
      if (index == 14)
      {
        i++;
      }
    }
    //println ("For loop finished!");
    //Ready to start dance Playback
    //dancePlayback = true;
    println("Exiting readCSV function");
    return true;

  } else {
    println ("No file selected or incorrect file type.  Must be CSV.");
    return false;
  }
}

/*--------------------------------------------------------------
draws the points of each of the joints
--------------------------------------------------------------*/
void playBack(Integer rowNum)
{
  if (rowNum < skel_data.length) {  //Compare number passed to function and make sure its less than the length of the array of skeleton data
    //println ("Drawing!" + ' ' + rowNum);
    offsetX = alignX(skel_data[0][8]);
    offsetY = alignY(skel_data[0][8]);
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
    dancePlayback = false;
    numIterationsCompleted = 0;
  }
}

/*--------------------------------------------------------------
draws the points based on the coordinates
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
  line(xA, yA, xB, yB);

}

float alignX(PVector skeA)
{
  if(skeA.x < midWidth)
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
void playVideo(String filename){
  //read the file specified
  while (!dancePlayback) {
    dancePlayback = readCsv(sketchPath(recordingsFolder + "/" + filename).toString());
  }
}

/*--------------------------------------------------------------
assigns the appropriate list of filenames depending on the current day selected
--------------------------------------------------------------*/
void fileForDaySelected(){
  
 if (currentDaySelected == 1) {
   danceChoreoFiles[0] = "combo1_first8.csv";
   danceChoreoFiles[2] = "combo1_third8.csv";
 } else if (currentDaySelected == 2) {
   danceChoreoFiles[0] = "bird_first8.csv";
   danceChoreoFiles[2] = "bird_third8.csv";
 } else if (currentDaySelected == 3) {
   danceChoreoFiles[0] = "car_first8.csv";
   danceChoreoFiles[2] = "car_third8.csv";   
 }
}

/*--------------------------------------------------------------
logic for playing through the list of files
--------------------------------------------------------------*/
 void playDances(){
  //enter dance phase
  phase = "dance";
  
  //loop through each csv file in the current day's dances
  //loop until reach every current file name in array
  for (int i = 0; i < danceFileNames.length; i++) {
      playVideo(danceFileNames[i]);
      playBack (numIterationsCompleted); //play back the skeletons
      numIterationsCompleted++;
  }
  
  //when all done playing the dances, go back to title screen
  phase = "title";
//  //check to see if the user is either watching a recording or is recording their dances
//  //if they are not doing either of these things, then exit to main menu
//  if (recordMode == false && dancePlayback == false){
//     phase = "title";
//  }
 }
