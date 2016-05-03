//This class based on code found here: http://www.goldb.org/stopwatchjava.html
public class StopWatchTimer {
  int startTime = 0, stopTime = 0;
  boolean running = false;

  void start() {
    startTime = millis();
    running = true;
  }
  void stop() {
    stopTime = millis();
    running = false;
  }
  int getElapsedTime() {
    int elapsed;
    if (running) {
      elapsed = (millis() - startTime);
    }
    else {
      elapsed = (stopTime - startTime);
    }
      return elapsed;
  }

  int getSeconds() {
    return (getElapsedTime() / 1000) % 60;
  }

  int getMinutes() {
    return (getElapsedTime() / (1000*60)) % 60;
  }
  int getHours() {
    return (getElapsedTime() / (1000*60*60)) % 24;
  }
}
