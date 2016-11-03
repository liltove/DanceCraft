import ddf.minim.*;
import ddf.minim.signals.*;

//AudioPlayer player;
AudioPlayer soundtrack;
AudioPlayer sounds;
Minim minim;//audio context
Minim minim2;
int track = 0; //initial track number
int voiceover = 0; //initial voiceover number
String[] musicFiles= {"music/2.mp3", "music/01Coming Over_filous Remix.mp3", "music/02New Resolution.mp3", "music/07AnthemsforaSeventeenYearOldGirl.mp3"};
String[] soundFiles = {"music/voiceover/warmup.mp3", "music/voiceover/technique- intro.mp3", "music/voiceover/technique- 1.mp3",
                      "music/voiceover/bird- intro- 1.mp3", "music/voiceover/bird- 2.mp3", 
                      "music/voiceover/car- intro.mp3", "music/voiceover/car- 1.mp3", "music/voiceover/car- 2.mp3", 
                      "music/voiceover/snow- intro.mp3", "music/voiceover/snow- 1.mp3", "music/voiceover/snow- 2.mp3"
                      };
//int track = currentDaySelected; //initialize the track to whatever is the current day selected
String trackNum; //holds track number for calling from file

void musicSetup(){
  //start the music player
  minim = new Minim(this);
  minim2 = new Minim(this);
  getTrack(track);
  getSounds(voiceover);
  soundtrack.loop(10);
}

void musicPlay(){
    if(!soundtrack.isPlaying()){
      getTrack(track);   //Loads the corresponding track to be played.
      soundtrack.play();
    }
}

void voiceoverPlay(){
  if(!sounds.isPlaying()){
      getSounds(3);   //Loads the corresponding track to be played.
      sounds.play();
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

void getSounds(int tracks){
 //track = currentDaySelected; //So we can index the correct track in the array
 println("Loading voiceover: " + soundFiles[tracks]);
 sounds = minim2.loadFile(soundFiles[tracks], 2048);  //Check
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

void changeSounds(int tracks){
 if (voiceover == tracks){
   //println("Track: " + track + ", Changing to tracks: " + tracks);
 } else {
   println("Sound: " + track + ", Changing to sound: " + tracks);
   voiceover = tracks; //set the new track to specified integer
     if (sounds.isPlaying()){
       sounds.pause(); //stop current music
       sounds.rewind(); //set back to beginning of track
     }
   voiceoverPlay();
 }
}

void changeTrackToDanceDay(){
  if (currentDaySelected == 1 || currentDaySelected == 3 ){
      changeTracks(2);
    } else {
      changeTracks(3);
    }
}