import ddf.minim.*;

//AudioPlayer player;
AudioPlayer soundtrack;
Minim minim;//audio context
int track = 1; //initial track number
String trackNum; //holds track number for calling from file

void musicSetup(){
  //start the music player
  minim = new Minim(this);
  getTrack(track);
}

void musicPlay(){
    //getTrack(track);
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
  //trackNum = "music/"+track+".mp3";
  //soundtrack = minim.loadFile(trackNum, 2048);
  soundtrack = minim.loadFile("music/ferrisWheel.mp3", 2048);
  println("playing music.");
}

void randomTrack(){
  track = int(random(23)) + 1;
  println("Now playing track number: " + track);
  getTrack(track);
}
