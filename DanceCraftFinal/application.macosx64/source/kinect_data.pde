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
 
  kinect.alternativeViewPointDepthToImage();
 kinect.setDepthColorSyncEnabled(true); 
 
 // enable skeleton generation for all joints
 kinect.enableUser();

oldPosition = new PVector();

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
  
 if(kinect.isTrackingSkeleton(1)){
   //get vector of current position
   PVector currentPosition = new PVector();
   //kinect.getJointPositionSkeleton(1,SimpleOpenNI.SKEL_LEFT_HAND, currentPosition);
   calcPoints(1,SimpleOpenNI.SKEL_LEFT_HAND,currentPosition, sumLH);
   calcPoints(1,SimpleOpenNI.SKEL_RIGHT_HAND,currentPosition, sumRH);
   calcPoints(1,SimpleOpenNI.SKEL_TORSO,currentPosition, sumT);
   calcPoints(1,SimpleOpenNI.SKEL_LEFT_FOOT,currentPosition, sumLF);
   calcPoints(1,SimpleOpenNI.SKEL_RIGHT_FOOT,currentPosition, sumRF);
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

   //save the current position with a place holder
   PVector placeHolderPosition = new PVector();
   placeHolderPosition = currentPosition;
   
   //calculate the distance between vectors by transforming currentPosition
   currentPosition.sub(oldPosition); 
   
   //store magnitude
   offByDistance = currentPosition.mag();
   
   sum = int(abs(offByDistance - oldDistance));
   println(jointID+"sum: "+sum);
   println(jointID+"old sum: "+oldsum);
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

