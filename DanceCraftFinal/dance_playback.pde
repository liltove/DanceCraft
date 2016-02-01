/*
This file contains the functions necessary for playing back "dances" recorded
by the user.
*/
//-------------------------------------------------------------//

void readCsv(File selection)
{
  //read the csv file if something has been selected
  if (selection != null) {
    println(selection.toString());
    loadedSkelTable = loadTable(selection.toString(), "header");
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
      println ("FINAL Value at skel_data" + "[" +i+ "]" + "[" +index+ "]" + "---------->" + skel_data[i][index]);
      //println ("Table row count is ---->" + table.getRowCount());
      //once the iteration has read all 14 joint, it starts recording a new skeleton
      if (index == 14)
      {
        i++;
      }
    }
    println ("For loop finished!");
    //Ready to start dance Playback
    dancePlayback = true;
    println("Exiting readCSV function");

  } else {
    println ("No file selected or incorrect file type.  Must be CSV.");
  }
}

void playBack(Integer rowNum)
{
  if (rowNum < skel_data.length) {  //Compare number passed to function and make sure its less than the length of the array of skeleton data
    println ("Drawing!" + ' ' + rowNum);
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

void drawBack(PVector skeA, PVector skeB)
{

   //Set color of skeleton "bones" to black
  stroke(0);
  //Set weight of line
  strokeWeight (5);
  //draw a point for the first position (divided in half to fit on left side of screen.  Negated Y value to flip skeleton right side up)
  ellipse((.5)*skeA.x, (.25)*(-skeA.y)+150, 5, 5);
  //draw a point for the second position (divided in half to fit on left side of screen.  Negated Y value to flip skeleton right side up)
  ellipse((.5)*skeB.x, (.25)*(-skeB.y)+150, 5, 5);
  //draw a joint between two  (divided in half to fit all of skeleton onto vertical area of screen.  Negated Y value to flip skeleton right side up)
  line((.5)*skeA.x, (.25)*(-skeA.y)+150, (.5)*skeB.x, (.25)*(-skeB.y)+150);

  //noStroke();

}
