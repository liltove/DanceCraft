import processing.video.*;
import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
//import saito.objloader.*; 
// https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/saitoobjloader/OBJLoader.zip
import controlP5.*;
import java.util.ArrayList;

ControlP5 cp5;

Minim minim; //audio context
int track = 1; //initial track number
String trackNum; //holds track number for calling from file

PFont font;

String phase, mode;
String [] files;
String username, time;
String desktopPath = "\\records/"; 
String recordingsFolder = "data"; // this is the folder that kinect skeleton recordings is in
String recordingName = "better_dance_recording.csv"; // this is the file to temporarily use for the target recording to play
String fileName = new String();

Boolean typingUsername, music, figure, animationPlaying, animation2playing, showPoints, showResponses, showEncouragements;
Boolean isPaused = false;
Boolean typingFileName = false;
Boolean recordMode = false; //is program currently recording?
Boolean dancePlayback = false; //is program currently playing back a recording?
Boolean allowRecordModeActivationAgain = true;

int startTime;
int background;
//int count;
//int response;
int numIterationsCompleted = 0; //Used to drawback skeletons
int currentDaySelected = 0; //which day is selected to play appropriate dance files

// 3D Model stuff
/*OBJModel model;
OBJModel tmpmodel;
String modelsFolder = "models";
String modelName = "steve.obj";
float rotX;
float rotY;*/
protected ZZModel clone;        // modele courant
protected ZZkinect zzKinect;        // capteur kinect
protected ArrayList<ZZModel> avatars;  // modeles
protected ZZoptimiseur better;      // optimisation
final int NBCAPT = 3;  // nombre de captures pour moyennage


float normLength = -25;

float k = 0.0;
PVector pos;

void setup() {
  smooth();
  drawScreen();
  phase = "title";
  //music = true;
  figure = true;
  
  cp5 = new ControlP5(this);
  
  //COMMENT OUT THIS LINE TO RUN WITHOUT KINECT
   //kinectSetup();

  minim = new Minim(this);
  //musicSetup();

  background = 0;

  //Fill the Boolean array keysPressed with falses
  for (int i = 0; i < keysPressed.length; i++) {
    keysPressed[i] = false;
  }
  
  //randomTrack();
  //soundtrack.play();
  
  // 3D Model stuff
    /*model = new OBJModel(this, modelsFolder+ "/"+modelName, "relative", QUADS);
    tmpmodel = new OBJModel(this, modelsFolder+ "/"+modelName, "relative", QUADS);
    model.scale(25);
    model.translateToCenter();
    tmpmodel.scale(25);
    tmpmodel.translateToCenter();
    pos = new PVector();*/
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
}

/*---------------------------------------------------------------
Detect which phase of the program we are in and call appropriate draw function.
----------------------------------------------------------------*/
void draw() {
  
  if (phase=="title") {
    drawTitleScreen();
  } else if (phase=="dance") {
      drawDanceScreen();
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
      //update days to set which day is selected
      currentDaySelected = i+1;
      //make sure filenames are up to date
      fileForDaySelected();
      //enter the "dance" phase of the program
      phase = "dance";
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
      allowRecordModeActivationAgain = false;
      println("Record Mode Activated");
      //Draw red circle indicatiing that we are recording
      fill (189, 41, 2);
      ellipse (width-20, 20, 10, 10);
    } else if (key == ' ' && phase == "dance" && recordMode == true && allowRecordModeActivationAgain == true ) {
      recordMode = false;
      allowRecordModeActivationAgain = false;
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
} //End of KeyPressed function

/// BEGIN 3d stuff
/*void draw3d(){
   background(255);
  noStroke();
//  pushMatrix();
  translate(width / 2, height / 2, 0); 
  rotateY(PI*1.5);
  tmpmodel.draw();
//  popMatrix();
  animation();
}*/

/*void draw3dold() {
  lights();

    pos.x = sin(radians(frameCount)) * 200;
    pos.y = cos(radians(frameCount)) * 200;  

    pushMatrix();

    translate(width / 2, height / 2, 0); 

    rotateX(rotY);
    rotateY(rotX);

    pushMatrix();
    
    drawPoint(pos);

    popMatrix();

    //rotateY(PI*1.5);
    //we have to get the faces out of each segment.
    // a segment is all verts of the one material
    for (int j = 0; j < model.getSegmentCount(); j++) {

        Segment segment = model.getSegment(j);
        Face[] faces = segment.getFaces();

        drawFaces( faces );

        drawNormals( faces );
        
    }
    
    popMatrix();
}*/

/*void animation(){
  int magnitude = 30;

  int i = (int)k%52;
  
    PVector orgv = model.getVertex(i);
    PVector tmpv = new PVector();
    if((k-(int)k)>.98) {
      tmpv.x = orgv.x; // Z -  is backwards, + is forwards
      tmpv.y = orgv.y; // up and down + is down, - is up
      tmpv.z = orgv.z; // * (abs(cos(.2)) * 0.3 - 1.0); + is left, - is right
    }
    else {
      tmpv.x = orgv.x+ random(-1*magnitude,magnitude); // Z -  is backwards, + is forwards
      tmpv.y = orgv.y+ random(-1*magnitude,magnitude); // up and down + is down, - is up
      tmpv.z = orgv.z+ random(-1*magnitude,magnitude); // * (abs(cos(.2)) * 0.3 - 1.0); + is left, - is right
    }
    tmpmodel.setVertex(i, tmpv);

//  for(int i = 0; i < model.getVertexCount(); i++){
//    PVector orgv = model.getVertex(i);
//    PVector tmpv = new PVector();
//    tmpv.x = orgv.x * (abs(sin(i*0.2)) * 0.3 + 1.0);
//    tmpv.y = orgv.y * (abs(cos(i*0.4)) * 0.3 + 1.0);
//    tmpv.z = orgv.z * (abs(cos(i/5)) * 0.3 + 1.0);
//    tmpmodel.setVertex(i, tmpv);
//  }
  k+=0.01;
}*/


/*void drawFaces(Face[] fc) {

    // draw faces
    noStroke();

    beginShape(QUADS);

    for (int i = 0; i < fc.length; i++)
    {
        PVector[] vs = fc[i].getVertices();
        PVector[] ns = fc[i].getNormals();

        // if the majority of the face is pointing to the position we draw it.
        if(fc[i].isFacingPosition(pos)) {

            for (int k = 0; k < vs.length; k++) {
                normal(ns[k].x, ns[k].y, ns[k].z);
                vertex(vs[k].x, vs[k].y, vs[k].z);
            }
        }
    }
    endShape();
}



void drawNormals( Face[] fc ) {

    beginShape(LINES);
    // draw face normals
    for (int i = 0; i < fc.length; i++) {
        PVector v = fc[i].getCenter();
        PVector n = fc[i].getNormal();

        // scale the alpha of the stroke by the facing amount.
        // 0.0 = directly facing away
        // 1.0 = directly facing 
        // in truth this is the dot product normalized
        stroke(255, 0, 255, 255.0 * fc[i].getFacingAmount(pos));

        vertex(v.x, v.y, v.z);
        vertex(v.x + (n.x * normLength), v.y + (n.y * normLength), v.z + (n.z * normLength));
    }
    endShape();
}


void drawPoint(PVector p){
 
    translate(p.x, p.y, p.z);

    noStroke();
    ellipse(0,0,20,20);
    rotateX(HALF_PI);
    ellipse(0,0,20,20);
    rotateY(HALF_PI);
    ellipse(0,0,20,20);   
    
}*/
// END 3D STUFF



//creates the static background
//void backgrnd(){
  //if(background == 0){
    //background = int(random(4)) + 1;
    //String dncbg = "elements/" + background + ".png";
    //dancebg = loadImage(dncbg);
    //image(dancebg,width/2,height/2,width,height);
  //}
//}

//void musicPlay(){
//  //calls a random track from the music folder
//    randomTrack();
//    soundtrack.play();
//
////loop of music playing
//  while(music == true){
//    //plays the music
//    if(!soundtrack.isPlaying()){
//      soundtrack.pause();
//      soundtrack.rewind();
//      randomTrack();
//      soundtrack.play();
//    }
//  }
//}//Boolean music
//
//void stop()
//{
//  soundtrack.close();
//  minim.stop();
//  super.stop();
//}
//
//void getTrack(int track){
//  trackNum = "music/"+track+".mp3";
//  soundtrack = minim.loadFile(trackNum, 2048);
//}
//
//void randomTrack(){
//  track = int(random(23)) + 1;
//  println("Now playing track number: " + track);
//  getTrack(track);
//}
