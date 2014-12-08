//import ddf.minim.*;
//
////AudioPlayer player;
//AudioPlayer soundtrack;
//Minim minim;//audio context
//int track = 1; //initial track number
//String trackNum; //holds track number for calling from file
//
//void musicSetup(){
//  //start the music player
//  minim = new Minim(this);
//  //randomTrack();
//}
//
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
