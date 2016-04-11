import processing.video.*;

Movie tutorial = new Movie(this, "bee.mov");
void movieSetup(){
  size(200, 200);
  
}

void moviePlay(){
  tutorial.play();
}



void movieEvent(Movie m) {
  m.read();
}



