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

/*-------------------------------------------------
Save the Skeleton Data to a specific location
-----------------------------------------------------*/
void saveSkeletonTable(File selection) {
  dataLocation = selection.getAbsolutePath();  //Assign path selected by user into var for use in filename
  saveTable(table, dataLocation + "/" + fileName + ".csv", "csv"); //Write table to location
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

/*-------------------------------------------------
Draw the joint bubbles on the skeleton on the player skeleton
-----------------------------------------------------*/
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
