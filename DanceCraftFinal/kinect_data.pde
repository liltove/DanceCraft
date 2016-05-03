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

// mapping of users
int[] userMapping;
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
Table table;
Table tablePose;
Table tableAngles;
Table loadedSkelTable = new Table();

PVector[] j1;



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

  tint(255, 127);  // Display at half opacity

  //Create black color to turn user into a shadow
  color black = color (0,0,0);
  // get pixels for the user tracked
  userMapping = kinect.userMap();

  // for the length of the pixels tracked, color them
  // in with the rgb camera
  for (int i =0; i < userMapping.length; i++) {
    // if the pixel is part of the user
    if (userMapping[i] != 0) {
      // set the pixel color of the part of the display that is the user to black
      pixels[i] = black;
    }
  } // (int i =0; i < userMap.length; i++)

  // update any changed pixels
  updatePixels();

  //get the list of users
  int[] users = kinect.getUsers();

  for(int i = 0; i < users.length; i++)
   {
     //check if the user has skeleton
    if(kinect.isTrackingSkeleton(users[i]) && isPaused == false) {
      //Draw skeleton on top of player as they play
     //drawSkeleton(users[i]);


     //if in recordMode, save the users tracked information to choreo files
//     if(recordMode){
//       PVector currentPosition = new PVector();
//       //add information to table
//       AddToCSV(SimpleOpenNI.SKEL_HEAD,currentPosition.x,currentPosition.y, currentPosition.z); //0
//       AddToCSV(SimpleOpenNI.SKEL_NECK,currentPosition.x,currentPosition.y, currentPosition.z); //1
//       AddToCSV(SimpleOpenNI.SKEL_LEFT_SHOULDER,currentPosition.x,currentPosition.y, currentPosition.z); //2
//       AddToCSV(SimpleOpenNI.SKEL_RIGHT_SHOULDER,currentPosition.x,currentPosition.y, currentPosition.z); //3
//       AddToCSV(SimpleOpenNI.SKEL_LEFT_ELBOW,currentPosition.x,currentPosition.y, currentPosition.z); //4
//       AddToCSV(SimpleOpenNI.SKEL_RIGHT_ELBOW,currentPosition.x,currentPosition.y, currentPosition.z); //5
//       AddToCSV(SimpleOpenNI.SKEL_LEFT_HAND,currentPosition.x,currentPosition.y, currentPosition.z); //6
//       AddToCSV(SimpleOpenNI.SKEL_RIGHT_HAND,currentPosition.x,currentPosition.y, currentPosition.z); //7
//       AddToCSV(SimpleOpenNI.SKEL_TORSO,currentPosition.x,currentPosition.y, currentPosition.z); //8
//       AddToCSV(SimpleOpenNI.SKEL_LEFT_HIP,currentPosition.x,currentPosition.y, currentPosition.z); //9
//       AddToCSV(SimpleOpenNI.SKEL_RIGHT_HIP,currentPosition.x,currentPosition.y, currentPosition.z); //10
//       AddToCSV(SimpleOpenNI.SKEL_LEFT_KNEE,currentPosition.x,currentPosition.y, currentPosition.z); //11
//       AddToCSV(SimpleOpenNI.SKEL_RIGHT_KNEE,currentPosition.x,currentPosition.y, currentPosition.z); //12
//       AddToCSV(SimpleOpenNI.SKEL_LEFT_FOOT,currentPosition.x,currentPosition.y, currentPosition.z); //13
//       AddToCSV(SimpleOpenNI.SKEL_RIGHT_FOOT,currentPosition.x,currentPosition.y, currentPosition.z); //14
//     }

     }
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
  row.setInt("joint",_joint);
  row.setFloat("x", _x);
  row.setFloat("y", _y);
  row.setFloat("z", _z);
  row.setString("jointname", joint[_joint]);
}

/*-------------------------------------------------
Save the Skeleton Data to a specific location
-----------------------------------------------------*/
void saveSkeletonTable(String fileName) {
  //dataLocation = selection.getAbsolutePath();  //Assign path selected by user into var for use in filename

  saveTable(table, "data/choreo" + fileName + ".csv", "csv"); //Write table to location
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



//Save the Skeleton Data to a specific location
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
	stroke(128, 0, 128);
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
