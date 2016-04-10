/*---------------------------------------------------------------
Imports
----------------------------------------------------------------*/


/*---------------------------------------------------------------
Variables
----------------------------------------------------------------*/
// BUTTON VARIABLES
color rectColor = color(50, 55, 100);
color rectHighlightColor = color(150, 155, 155);
color rectPressedColor = color(100, 105, 155);
int buttonWidth = 74;
int buttonHeight = 35;
int distanceFromLeft = (width/2) - (buttonWidth/2);
int distanceFromTop = (height/5) * 2; //  distance from top to start drawing buttons;
int distanceBetweenButtons = 33;
String[] buttonNames = {"One", "Two", "Three"}; // array of button names;
String[] danceFileNames= {"better_dance_recording.csv", "good_dance_recording.csv", "csvPoseData.csv"}; // array of associated File names to go with buttons
Boolean[] buttonIsPressed = {false, false, false};
Boolean[] buttonIsOver = {false, false, false};
Boolean [] keysPressed = new Boolean[20];

//SET SIZE OF WINDOW
int width = 640; // window width
int height = 480; // window height


/*---------------------------------------------------------------
Draws the right screen size with other set parameters
----------------------------------------------------------------*/
void drawScreen(){
  frame.setTitle("DanceCraft"); //sets window title
  size(width,height, P3D);
  font=createFont("Arial", 48);
  textFont(font); 
}
