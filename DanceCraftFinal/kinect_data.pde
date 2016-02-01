/*---------------------------------------------------------------
Imports
----------------------------------------------------------------*/
// import kinect library
import SimpleOpenNI.*;

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

// points variable array for each userID
int[] points = new int[6];

// mapping of users
int[] userMapping;
// background image
PImage backgroundImage;
// image from rgb camera
PImage rgbImage;

//Joint array
String[] joint = {"HEAD", "NECK", "LEFT_SHOULDER", "RIGHT_SHOULDER", "LEFT_ELBOW", "RIGHT_ELBOW", "LEFT_HAND", "RIGHT_HAND", "TORSO", "LEFT_HIP", "RIGHT_HIP", "LEFT_KNEE", "RIGHT_KNEE", "LEFT_FOOT", "RIGHT_FOOT"};

int fileWritten = 1;
String dataLocation = new String();
String poseDataLocation = "data/csvPoseData.csv";
String anglesLocation = "data/csvAngles.csv";
float threshold = 50;

float offByDistance = 0.0;
float oldDistance = 0.0;
PVector oldPosition;

int sum = 0;
int oldsum = 0;
int sumLH = 0;
int sumRH = 0;
int sumT = 0;
int sumLF = 0;
int sumRF = 0;


float[][] poseJointArray;
PVector[][] skel_data;

//Table for Kinect Data to be stored in CSV
Table table;
Table tablePose;
Table tableAngles;
Table loadedSkelTable = new Table();

PVector[] j1;

//Counter for the poses
int pose=1;
boolean p=false;


/*---------------------------------------------------------------
Starts new kinect object and enables skeleton tracking.
Draws window
----------------------------------------------------------------*/
void kinectSetup()
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


  oldPosition = new PVector();

  table=new Table();
  //table.addColumn("pose",Table.INT);
  table.addColumn("joint",Table.INT);
  table.addColumn("x",Table.FLOAT);
  table.addColumn("y",Table.FLOAT);
  table.addColumn("z", Table.FLOAT);

  tablePose=new Table();
  tablePose.addColumn("Pose",Table.INT);
  tablePose.addColumn("Joint",Table.INT);
  tablePose.addColumn("x",Table.FLOAT);
  tablePose.addColumn("y",Table.FLOAT);
  tablePose.addColumn("z", Table.FLOAT);

  tableAngles=new Table();
  tableAngles.addColumn("Pose",Table.INT);
  tableAngles.addColumn("LH1",Table.FLOAT);  //(1-8)-(1-4)  Spine and Elbow (L)
  tableAngles.addColumn("LH2",Table.FLOAT);  //(1-2)-(2-4)  Neck-Shoulder- Shoulder-Elbow (L)
  tableAngles.addColumn("LH3",Table.FLOAT);  //(2-4)-(4-6)  Shoulder-Elbow- Elbow-Wrist (L)
  tableAngles.addColumn("H1", Table.FLOAT);  //(0-1)-(1-2)  Head-Neck- Neck-Shoulder
  tableAngles.addColumn("RH1", Table.FLOAT); //(1-8)-(1-5)  Spine and Elbow (R)
  tableAngles.addColumn("RH2", Table.FLOAT); //(1-3)-(3-5)  Neck-Shoulder- Shoulder-Elbow (R)
  tableAngles.addColumn("RH3", Table.FLOAT); //(3-5)-(5-7)  Shoulder-Elbow- Elbow-Wrist (R)
  tableAngles.addColumn("SP1", Table.FLOAT); //(1-8)-(8-9)  Spine- Hip
  tableAngles.addColumn("LL1", Table.FLOAT); //(8-9)-(9-13)  Entire Leg- HipTorso (L)
  tableAngles.addColumn("LL2", Table.FLOAT); //(9-11)-(11-13)  Hip-Knee- Knee-Leg (L)
  tableAngles.addColumn("RL1", Table.FLOAT); //(8-10)-(10-14)  Entire Leg- HipTorso (R)
  tableAngles.addColumn("RL2", Table.FLOAT); //(10-12)-(12-14) Hip-Knee- Knee-Leg (R)

  poseJointArray= new float[3][15];

  j1=new PVector[15];

} // void setup()

/*---------------------------------------------------------------
Updates Kinect. Gets users tracking and draws skeleton and
head if confidence of tracking is above threshold
----------------------------------------------------------------*/
void kinectDance(){

  // update the camera
  kinect.update();

   // get the Kinect color image
  rgbImage = kinect.rgbImage();

   // prepare the color pixels
  loadPixels();
  // get pixels for the user tracked
  userMapping = kinect.userMap();

  // for the length of the pixels tracked, color them
  // in with the rgb camera
  for (int i =0; i < userMapping.length; i++) {
    // if the pixel is part of the user
    if (userMapping[i] != 0) {

      // set the sketch pixel to the rgb camera pixel
      pixels[i] = rgbImage.pixels[i];
    } // if (userMap[i] != 0)

   } // (int i =0; i < userMap.length; i++)


  // update any changed pixels
  updatePixels();

  //get the list of users
  int[] users = kinect.getUsers();

  if (recordMode == true) {
    //Do stuff we're currently doing like drawing the skeleton and saving it.

   //iterate through each users
   for(int i = 0; i < users.length; i++)
   {
     //check if the user has skeleton
    if(kinect.isTrackingSkeleton(users[i]) && isPaused == false) {
      //get vector of current position
      PVector currentPosition = new PVector();
      //kinect.getJointPositionSkeleton(1,SimpleOpenNI.SKEL_LEFT_HAND, currentPosition);
      calcPoints(users[i],SimpleOpenNI.SKEL_HEAD,currentPosition, sum);           //0
      calcPoints(users[i],SimpleOpenNI.SKEL_NECK,currentPosition, sum);           //1
      calcPoints(users[i],SimpleOpenNI.SKEL_LEFT_SHOULDER,currentPosition, sum);  //2
      calcPoints(users[i],SimpleOpenNI.SKEL_RIGHT_SHOULDER,currentPosition, sum); //3
      calcPoints(users[i],SimpleOpenNI.SKEL_LEFT_ELBOW,currentPosition, sum);     //4
      calcPoints(users[i],SimpleOpenNI.SKEL_RIGHT_ELBOW,currentPosition, sum);    //5
      calcPoints(users[i],SimpleOpenNI.SKEL_LEFT_HAND,currentPosition, sumLH);    //6
      calcPoints(users[i],SimpleOpenNI.SKEL_RIGHT_HAND,currentPosition, sumRH);   //7
      calcPoints(users[i],SimpleOpenNI.SKEL_TORSO,currentPosition, sumT);         //8
      calcPoints(users[i],SimpleOpenNI.SKEL_LEFT_HIP,currentPosition, sum);       //9
      calcPoints(users[i],SimpleOpenNI.SKEL_RIGHT_HIP,currentPosition, sum);      //10
      calcPoints(users[i],SimpleOpenNI.SKEL_LEFT_KNEE,currentPosition, sum);      //11
      calcPoints(users[i],SimpleOpenNI.SKEL_RIGHT_KNEE,currentPosition, sum);     //12
      calcPoints(users[i],SimpleOpenNI.SKEL_LEFT_FOOT,currentPosition, sumLF);    //13
      calcPoints(users[i],SimpleOpenNI.SKEL_RIGHT_FOOT,currentPosition, sumRF);   //14

      if(p==true){
      computeAngles(pose);}
      p=false;
      pose=pose+1;


     // Writing the specific poses for the CSV back to the poses file
     saveTable(tablePose, poseDataLocation);
     // And reloading it
     //loadData();

      //Draw skeleton on top of player as they play
     drawSkeleton(users[i]);
     //readCsv(users[i], dataLocation);
     }
   }

   //saveTable(tableAngles, anglesLocation);

 } else {
   background(255);
   fill(0);
   textSize(32);
   textAlign(CENTER);
   text ("Press P to load a dance", width/2, height/2);
 }

} // void draw()

/*---------------------------------------------------------------
When a new user is found, print new user detected along with
userID and start pose detection. Input is userID
----------------------------------------------------------------*/
void onNewUser(SimpleOpenNI curContext, int userId){
 println("New User Detected - userId: " + userId);
 // start tracking of user id
 curContext.startTrackingSkeleton(userId);
} //void onNewUser(SimpleOpenNI curContext, int userId)

/*---------------------------------------------------------------
Print when user is lost. Input is int userId of user lost
----------------------------------------------------------------*/
void onLostUser(SimpleOpenNI curContext, int userId){
 // print user lost and user id
 println("User Lost - userId: " + userId);
} //void onLostUser(SimpleOpenNI curContext, int userId)


/*---------------------------------------------------------------
Create points for each userID
----------------------------------------------------------------*/
void addPoints(int id){
   //this function is called when a particular userID *moves*
  points[id] = points[id] + 1;
  //points[id]=points[id]/1000;
}

void calcPoints(int userID, int jointID, PVector currentPosition, int oldsum){
   kinect.getJointPositionSkeleton(userID,jointID, currentPosition);

   println(jointID);
   println(currentPosition.x);
   println(currentPosition.y);
   println(currentPosition.z);

   AddToCSV(jointID,currentPosition.x,currentPosition.y, currentPosition.z);
   //This function saves a pose into a table
   if(keyPressed)
   {
     if(key=='q'||key=='Q')
     {
       AddPose(pose,jointID,currentPosition.x,currentPosition.y, currentPosition.z);
       println("Pose saved!");
       p=true;
     }
   }

   //createXML(1,1, jointID,currentPosition.x,currentPosition.y, currentPosition.z);
   //save the current position with a place holder
   PVector placeHolderPosition = new PVector();
   placeHolderPosition = currentPosition;

   //calculate the distance between vectors by transforming currentPosition
   currentPosition.sub(oldPosition);

   //store magnitude
   offByDistance = currentPosition.mag();

   sum = int(abs(offByDistance - oldDistance));
   //println(jointID+"sum: "+sum);
   //println(jointID+"old sum: "+oldsum);
   if((abs(sum-oldsum)) > threshold){
     points[0] = points[0] + 1;
   }
   oldDistance = offByDistance;
   oldPosition = placeHolderPosition;

   switch(jointID){
     case 6:
        sumLH = sum;
        break;
     case 7:
        sumRH = sum;
        break;
     case 8:
        sumT = sum;
        break;
     case 13:
        sumLF = sum;
        break;
     case 14:
        sumRF = sum;
        break;
   }

}

/*------------------------------------------------------------
Storing the joint positions for each pose in a xml file
------------------------------------------------------------*/
/*void createXML(int userId, int pose, int jointID1, float x, float y, float z){
    XML root=loadXML("subset.xml");
    XML poses;
    //poses=root.addChild(pose.toString());
sk

    XML jointID;
    //jointID=poses.AddChild(jointID1.toString());
    //jointID=poses.addChild("joint");
    XML x1;
    //x1=jointID.AddChild(x.toString());
    XML y1;
    //y1=jointID.AddChild(y.toString());
    XML z1;
    //z1=jointID.AddChild(z.toString());
    saveXML(root, "subset.xml");
}*/

/*void storeJoints(){

}

void createXML(){
  XML root = loadXML("subset.xml");
  println("I loaded");
  println(root.getName());
  root.setName("newname");
  println(root.getName());
  XML firstChild = root.getChild("exerciseONE");
  println(firstChild.getName());

  root.removeChild(firstChild);

  XML pose;
  pose = root.addChild("test");
  pose.setContent("im the content for test");

  saveXML(root, "subset.xml");
  println("im done");
}*/

/*--------------------------------------------------------------
Writing all joint data to a table for CSV file format
--------------------------------------------------------------*/
void AddToCSV(int _joint, float _x, float _y, float _z) {
  // Create a new row
  TableRow row = table.addRow();
  // Set the values of that row
  //row.setInt("pose",_pose);
  row.setInt("joint",_joint);
  row.setFloat("x", _x);
  row.setFloat("y", _y);
  row.setFloat("z", _z);
  row.setString("jointname", joint[_joint]);
}



/*--------------------------------------------------------------
Storing each pose to a table
--------------------------------------------------------------*/
void AddPose(int _pose,int _joint, float _x, float _y, float _z) {
  // Create a new row
  TableRow rowP = tablePose.addRow();
  // Set the values of that row
  rowP.setInt("Pose",_pose);
  rowP.setInt("Joint",_joint);
  rowP.setFloat("x", _x);
  rowP.setFloat("y", _y);
  rowP.setFloat("z", _z);
}

/*--------------------------------------------------------------
Compute angles for the pose-joint data from the csv
--------------------------------------------------------------*/
void computeAngles(int poseNo) {

  for (TableRow row : tablePose.findRows(str(poseNo), "Pose")) {
    poseJointArray[0][row.getInt("Joint")]=row.getFloat("x");
    poseJointArray[1][row.getInt("Joint")]=row.getFloat("y");
    poseJointArray[2][row.getInt("Joint")]=row.getFloat("z");
  }

  for(int i=0;i<15;i=i+1){
      j1[i]=new PVector(poseJointArray[0][i],poseJointArray[1][i],poseJointArray[2][i]);
  }

  //Vectors between joints
  PVector pv01 = PVector.sub(j1[0], j1[1]);
  PVector pv12 = PVector.sub(j1[1], j1[2]);
  PVector pv13 = PVector.sub(j1[1], j1[3]);
  PVector pv14 = PVector.sub(j1[1], j1[4]);
  PVector pv15 = PVector.sub(j1[1], j1[5]);
  PVector pv18 = PVector.sub(j1[1], j1[8]);
  PVector pv24 = PVector.sub(j1[2], j1[4]);
  PVector pv35 = PVector.sub(j1[3], j1[5]);
  PVector pv46 = PVector.sub(j1[4], j1[6]);
  PVector pv57 = PVector.sub(j1[5], j1[7]);
  PVector pv89 = PVector.sub(j1[8], j1[9]);
  PVector pv810 = PVector.sub(j1[8], j1[10]);
  PVector pv911 = PVector.sub(j1[9], j1[11]);
  PVector pv913 = PVector.sub(j1[9], j1[13]);
  PVector pv1012 = PVector.sub(j1[10], j1[12]);
  PVector pv1014 = PVector.sub(j1[10], j1[14]);
  PVector pv1113 = PVector.sub(j1[11], j1[13]);
  PVector pv1214 = PVector.sub(j1[12], j1[14]);

  //
//  float lh1=AngleBetweenTwoVectors(pv18,pv14);
//  float lh2=AngleBetweenTwoVectors(pv12,pv24);
//  float lh3=AngleBetweenTwoVectors(pv24,pv46);
//  float h1=AngleBetweenTwoVectors(pv01,pv12);
//  float rh1=AngleBetweenTwoVectors(pv18,pv15);
//  float rh2=AngleBetweenTwoVectors(pv13,pv35);
//  float rh3=AngleBetweenTwoVectors(pv35,pv57);
//  float sp1=AngleBetweenTwoVectors(pv18,pv89);
//  float ll1=AngleBetweenTwoVectors(pv89,pv913);
//  float ll2=AngleBetweenTwoVectors(pv911,pv1113);
//  float rl1=AngleBetweenTwoVectors(pv810,pv1014);
//  float rl2=AngleBetweenTwoVectors(pv1012,pv1214);

  float lh1=PVector.angleBetween(pv18,pv14);
  float lh2=PVector.angleBetween(pv12,pv24);
  float lh3=PVector.angleBetween(pv24,pv46);
  float h1=PVector.angleBetween(pv01,pv12);
  float rh1=PVector.angleBetween(pv18,pv15);
  float rh2=PVector.angleBetween(pv13,pv35);
  float rh3=PVector.angleBetween(pv35,pv57);
  float sp1=PVector.angleBetween(pv18,pv89);
  float ll1=PVector.angleBetween(pv89,pv913);
  float ll2=PVector.angleBetween(pv911,pv1113);
  float rl1=PVector.angleBetween(pv810,pv1014);
  float rl2=PVector.angleBetween(pv1012,pv1214);

  AddAngle(poseNo,lh1,lh2,lh3,h1,rh1,rh2,rh3,sp1,ll1,ll2,rl1,rl2);
}

float AngleBetweenTwoVectors(PVector v1, PVector v2){    //https://social.msdn.microsoft.com/Forums/en-US/8516bab7-c28b-4834-82c9-b3ef911cd1f7/using-kinect-to-calculate-angles-between-human-body-joints?forum=kinectsdk
  float dotProduct = 0.0f;
  dotProduct= PVector.dot(v1, v2);
  print("DP"+dotProduct);
  return (float)Math.acos(dotProduct);
}

/*--------------------------------------------------------------
Storing each angle for each pose to a table
--------------------------------------------------------------*/
void AddAngle(int _pose,float _lh1, float _lh2, float _lh3, float _h1, float _rh1, float _rh2, float _rh3, float _sp1, float _ll1, float _ll2, float _rl1, float _rl2) {
  // Create a new row
  TableRow rowA = tableAngles.addRow();
  // Set the values of that row
  rowA.setInt("Pose",_pose);
  rowA.setFloat("LH1", _lh1);
  rowA.setFloat("LH2", _lh2);
  rowA.setFloat("LH3", _lh3);
  rowA.setFloat("H1", _h1);
  rowA.setFloat("RH1", _rh1);
  rowA.setFloat("RH2", _rh2);
  rowA.setFloat("RH3", _rh3);
  rowA.setFloat("SP1", _sp1);
  rowA.setFloat("LL1", _ll1);
  rowA.setFloat("LL2", _ll2);
  rowA.setFloat("RL1", _rl1);
  rowA.setFloat("RL2", _rl2);
}



//Save the Skeleton Data to a specific location
void saveSkeletonTable(File selection) {
  dataLocation = selection.getAbsolutePath();  //Assign path selected by user into var for use in filename
  saveTable(table, dataLocation + "/" + fileName, "csv"); //Write table to location
  cp5.remove("input"); //ControlP5 controller removes text input box from dance screen
  typingFileName = false;
  isPaused = false;
}


/*-------------------------------------------------
Draw a rudimentary skeleton on top of the player
-----------------------------------------------------*/

void drawSkeleton (int userId) {
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
  drawJoint(userId,SimpleOpenNI.SKEL_TORSO);
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

void drawJoint (int userId, int jointID) {
  PVector joint = new PVector();
  float confidence = kinect.getJointPositionSkeleton(userId, jointID, joint);
  if (confidence < 0.5) {
    return;
  }
  PVector convertedJoint = new PVector();
  kinect.convertRealWorldToProjective (joint, convertedJoint);
  ellipse(convertedJoint.x, convertedJoint.y, 5, 5);
}
