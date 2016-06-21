/*---------------------------------------------------------------
File contains the logic to record diagnostic information regarding
choices player made, dances played back, etc.
----------------------------------------------------------------*/
void beginWritingLogFile () {
  //Check to see if file exists
  //String[] arrayOfFileLines = loadFile()  
   logFile.println ("DANCECRAFT LOG FILE" + "\n");
   logFile.println ("___________________________________________________________" + "\n");
   logFile.println ("Username: TEST User Name" + "\n");
 }

void closeLogFile () {
  //Close and finalize log file
  logFile.flush();
  logFile.close();
}
