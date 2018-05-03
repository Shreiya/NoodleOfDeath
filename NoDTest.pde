// Let's talk!

/* Keyboard Commands:
  f - start sending filecopy.nc
  s - Stop!
  r - Restart after stop (work in progress)

   */


import processing.serial.*;

Serial port;
int portnumber;

String [] lines;
int linePointer;

boolean sending;
boolean waiting;
boolean stopped;

int millisLastLine;

void setup(){
  // List serial devices
  String [] devices = Serial.list();
  for(String s : devices){
    println(s);
  }
  
    // Set port number
  portnumber = 4;

  port = new Serial(this,devices[portnumber],115200);

  lines = loadStrings("filecopy.nc");

  sending = false;
  waiting = false;

  stopped = false;

  millisLastLine = 0;


}

void draw(){

  if(!sending){
    if(port.available() > 0){
      print(port.readChar());
    }
  }
  // If sending file...
  else{
    // If not waiting for a response, send the next line and wait
    if(!waiting){
      String l = lines[linePointer];  
      // Send line
      port.write(l+"\n");
      println(String.format("Sending line %d: %s...",linePointer,l));

      // Prepare for next line
      linePointer++;
      // Start to wait
      waiting = true;
    }
    // If waiting for a response, check if there's a response
    else{
      // Wait for 4 characters: ok\r\n
      if(port.available()>=4){
        if(stopped){
          for(int j=0; j<8; j++){
            print(port.readChar());
          }
          stopped = false;
        }
        // Read the characters / empty the buffer
        for(int j=0; j<4; j++){
          print(port.readChar());
        }
        waiting = false;

        // If the last line was sent, finish
        if(linePointer == lines.length){
          sending = false;
          println("Finished!");
          linePointer = 0;
        }
      }


    }


  }


}

void keyPressed(){
  switch(key){
    // Home
    // Send file
    case 'f':
      println("Loading and sending file...");
      lines = loadStrings("filecopy.nc");
      sending = true;
      linePointer = 0;
      break;

    case 's':// Stop
      port.write("!\n");
      println("Stopping!");
      stopped = true;
      waiting = false;
      break;


  }
}