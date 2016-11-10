import ddf.minim.*;
import ddf.minim.signals.*;

//AudioPlayer player;
AudioPlayer soundtrack; // to play the main sound tracks
AudioPlayer sounds; // to play the voiceovers 
Minim minim;//audio context
Minim minim2;
int track = 0; //initial track number
int voiceover = 0; //initial voiceover number
String[] musicFiles= {"music/menu.mp3", "music/warmup_technique.mp3", "music/choreo_segments.mp3"};
//String[] musicFiles= {"music/silence.mp3", "music/silence.mp3", "music/silence.mp3"};
String[] soundFiles = {
  "music/voiceover/warmup.mp3", "music/voiceover/technique- intro- 1.mp3",
  "music/voiceover/snow- intro- 1.mp3", "music/voiceover/snow- 2.mp3", 
  "music/voiceover/bird- intro- 1.mp3", "music/voiceover/bird- 2.mp3", 
  "music/voiceover/car- intro- 1.mp3", "music/voiceover/car- 2.mp3"  
}; // ignore the first sound file 

void musicSetup() {
  //start the music player
  minim = new Minim(this);
  minim2 = new Minim(this);
  getTrack(track);
  getSounds(voiceover);
  soundtrack.loop(10);
}

void musicPlay() {
  if (!soundtrack.isPlaying()) {
    getTrack(track);   //Loads the corresponding track to be played.
    soundtrack.play();
  }
}

void voiceoverPlay() {
  if (!sounds.isPlaying()) {
    getSounds(voiceover);   //Loads the corresponding voiceover to be played.
    sounds.play();
  }
}

//pause music
void pauseMusic() {
  soundtrack.pause();
}

void musicStop()
{
  soundtrack.close();
  minim.stop();
  super.stop();
}

void getTrack(int tracks) {
  //track = currentDaySelected; //So we can index the correct track in the array
  println("Loading music: " + musicFiles[tracks]);
  soundtrack = minim.loadFile(musicFiles[tracks], 2048);  //Check
  //soundtrack = minim.loadFile("music/ferrisWheel.mp3", 2048);  //Commented out what was the previous default music file
}

void getSounds(int voiceovers) {
  //track = currentDaySelected; //So we can index the correct track in the array
  println("Loading voiceover: " + soundFiles[voiceovers]);
  sounds = minim2.loadFile(soundFiles[voiceovers], 2048);  //Check
  //soundtrack = minim.loadFile("music/ferrisWheel.mp3", 2048);  //Commented out what was the previous default music file
}

void changeTracks(int tracks) {
  if (track == tracks) {
    //println("Track: " + track + ", Changing to tracks: " + tracks);
  } else {
    println("Track: " + track + ", Changing to tracks: " + tracks);
    track = tracks; //set the new track to specified integer
    if (soundtrack.isPlaying()) {
      soundtrack.pause(); //stop current music
      soundtrack.rewind(); //set back to beginning of track
    }
    musicPlay();
  }
}

void changeSounds(int voiceovers) {
  if (voiceover == voiceovers) {
    //println("Track: " + track + ", Changing to tracks: " + tracks);
  } else {
    println("Sound: " + voiceover + ", Changing to sound: " + voiceovers);
    voiceover = voiceovers; //set the new track to specified integer
    if (sounds.isPlaying()) {
      sounds.pause(); //stop current music
      sounds.rewind(); //set back to beginning of track
    }
    voiceoverPlay();
  }
}

void changeTrackToDanceDay() {
  if (currentDanceSegment == 0 || currentDanceSegment == 1) { // warmup and technique
    changeTracks(1);
  } else if (currentDanceSegment == 2) { // choreos
    changeTracks(2);
  }
}

void changeSoundToChoreoSegment() {
  if (currentDanceSegment == 0) { // warmup 
    changeSounds(0);
  } else if (currentDanceSegment == 1) { // technique 
    changeSounds(1);
  }
  
  // choreos 
  
  else if (currentDaySelected == 1) { // snow
    if (currentChoreoSegment == 0) { 
      changeSounds(2);
    } else if (currentChoreoSegment == 2) {
      changeSounds(3);
    } else { // when recording: currentDanceSegment == 1 or 3
      // no music playing;
    }
  } else if (currentDaySelected == 2) { // bird
    if (currentChoreoSegment == 0) { 
      changeSounds(4); // CHANGE
    } else if (currentChoreoSegment == 2) {
      changeSounds(5); // CHANGE
    } else { // when recording: currentDanceSegment == 1 or 3
      // no music playing;
    }
  } else if (currentDaySelected == 3) { // car
    if (currentChoreoSegment == 0) { 
      changeSounds(6);
    } else if (currentChoreoSegment == 2) {
      changeSounds(7);
    } else { // when recording: currentDanceSegment == 1 or 3
      // no music playing;
    }
  }
}