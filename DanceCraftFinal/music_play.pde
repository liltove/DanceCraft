import ddf.minim.*;

//AudioPlayer player;
AudioPlayer soundtrack;
Minim minim;//audio context
int track = 0; //initial track number
String[] musicFiles= {"music/01Coming Over_filous Remix.mp3", "music/02New Resolution.mp3", "music/07AnthemsforaSeventeenYearOldGirl.mp3"};
//int track = currentDaySelected; //initialize the track to whatever is the current day selected
String trackNum; //holds track number for calling from file

void musicSetup(){
  //start the music player
  minim = new Minim(this);
  getTrack(track);
}

void musicPlay(){
    getTrack(track);   //Loads the corresponding track to be played.
    soundtrack.play();

//loop of music playing
  if (music){
    //plays the music
    if(!soundtrack.isPlaying()){
      soundtrack.pause();
      soundtrack.rewind();
      soundtrack.play();
    }
  }
}//Boolean music

//pause music
void pauseMusic(){
 soundtrack.pause();
}

void stop()
{
  soundtrack.close();
  minim.stop();
  super.stop();
}

void getTrack(int track){
 //track = currentDaySelected; //So we can index the correct track in the array
 println("Loading music: " + musicFiles[track]);
 soundtrack = minim.loadFile(musicFiles[track], 2048);  //Check
 //soundtrack = minim.loadFile("music/ferrisWheel.mp3", 2048);  //Commented out what was the previous default music file
 //println("playing music.");
}

//There is no random track with 3 designated tracks for the corresponding 3 days
//Commenting the entire function for now as it is not being invoked anywhere.
/*void randomTrack(){
  track = int(random(23)) + 1;
  println("Now playing track number: " + track);
  getTrack(track);
}*/
