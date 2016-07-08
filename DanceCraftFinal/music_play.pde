import ddf.minim.*;

//AudioPlayer player;
AudioPlayer soundtrack;
Minim minim;//audio context
int track = 0; //initial track number
String[] musicFiles= {"music/2.mp3", "music/01Coming Over_filous Remix.mp3", "music/02New Resolution.mp3", "music/07AnthemsforaSeventeenYearOldGirl.mp3"};
//int track = currentDaySelected; //initialize the track to whatever is the current day selected
String trackNum; //holds track number for calling from file

void musicSetup(){
  //start the music player
  minim = new Minim(this);
  getTrack(track);
  soundtrack.loop(10);
}

void musicPlay(){
    if(!soundtrack.isPlaying()){
      getTrack(track);   //Loads the corresponding track to be played.
      soundtrack.play();
    }
}

//pause music
void pauseMusic(){
    soundtrack.pause();
}

void musicStop()
{
  soundtrack.close();
  minim.stop();
  super.stop();
}

void getTrack(int tracks){
 //track = currentDaySelected; //So we can index the correct track in the array
 println("Loading music: " + musicFiles[tracks]);
 soundtrack = minim.loadFile(musicFiles[tracks], 2048);  //Check
 //soundtrack = minim.loadFile("music/ferrisWheel.mp3", 2048);  //Commented out what was the previous default music file
}

void changeTracks(int tracks){
 if (track == tracks){
   //println("Track: " + track + ", Changing to tracks: " + tracks);
 } else {
   println("Track: " + track + ", Changing to tracks: " + tracks);
   track = tracks; //set the new track to specified integer
     if (soundtrack.isPlaying()){
       soundtrack.pause(); //stop current music
       soundtrack.rewind(); //set back to beginning of track
     }
   musicPlay();
 }
}

void changeTrackToDanceDay(){
  if (currentDaySelected == 1 || currentDaySelected ==3 ){
      changeTracks(2);
    } else {
      changeTracks(3);
    }
}
