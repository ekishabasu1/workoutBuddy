import controlP5.*;
import beads.*;
import org.jaudiolibs.beads.*;
import java.util.*;

Notification notification;
BiquadFilter duckFilter;

float HP_CUTOFF = 5000.0;



String primary_muscle; 
int muscle_activity_quads;
int muscle_activity_glutes;
int muscle_activity_abductors;
int muscle_activity_hamstrings;
int knee_flag;
int spine_flag;
int foot_placement;
String training_mode;
int primary_muscle_value;
//declare global variables at the top of your sketch
SamplePlayer music;
// store the length, in ms, of the music SamplePlayer
// endListener to detect beginning/end of music playback, rewind, FF
Bead musicEndListener;

ControlP5 p5;
Bead endListener;




SamplePlayer beep;
SamplePlayer correct;
SamplePlayer alert;


ScrollableList primaryMuscleMode;
ScrollableList trainingMode;

Gain masterGain;
Gain musicGain;

Glide masterGainGlide;
Glide musicGainGlide;
Glide filterGlide;

Reverb reverb;

String eventDataJSON1 = "data.json";
String eventDataJSON2 = "bad.json";
String eventDataJSON3 = "injury.json";

TextToSpeechMaker ttsMaker; 
NotificationServer notificationServer;
ArrayList<Notification> notifications;

MyNotificationListener myNotificationListener;

Queue<Notification> soundsToPlay = new LinkedList<Notification>();

boolean isSoundPlaying = false; 
//end global variables

//runs once when the Play button above is pressed
void setup() {
  size(1000,1000);
  ac = new AudioContext();
  p5 =  new ControlP5(this);
  
  music = getSamplePlayer("music.wav");
  
  

  ttsMaker = new TextToSpeechMaker();

  beep = getSamplePlayer("beep.wav");
  beep.pause(true);
  
  correct = getSamplePlayer("correct.wav");
  correct.pause(true);
  
  alert = getSamplePlayer("alert.wav");

  String exampleSpeech = "Starting";
  ttsExamplePlayback(exampleSpeech); //see ttsExamplePlayback below for usage
  
  alert.setEndListener(endListener);
  
  alert.pause(true);


  musicGainGlide = new Glide(ac, 1.0, 500);
  musicGain = new Gain(ac, 1, musicGainGlide);
  
  masterGainGlide = new Glide(ac, 1.0, 500);
  masterGain = new Gain(ac, 1, masterGainGlide);

  filterGlide = new Glide(ac, 10.0, 500);
  duckFilter = new BiquadFilter(ac, BiquadFilter.HP, filterGlide, 0.5);
  
  duckFilter.addInput(correct);
  musicGain.addInput(duckFilter);
  masterGain.addInput(musicGain);
  
  masterGain.addInput(alert);
  
  ac.out.addInput(masterGain);

  //START NotificationServer setup
  notificationServer = new NotificationServer();
  
  //instantiating a custom class (seen below) and registering it as a listener to the server
  myNotificationListener = new MyNotificationListener();
  notificationServer.addListener(myNotificationListener);
  
    
    primaryMuscleMode = p5.addScrollableList("primaryMuscleMode")
    .setPosition(10, 5)
    .setSize(120, 160)
    .setColorForeground(color(220))
    .setColorActive(color(120))
    .setType(ScrollableList.LIST)
    .addItem("Glute biased", 0)
    .addItem("Hamstring biased", 1)
    .addItem("Abductor biased", 2)
    .addItem("Quadricep biased", 3);
        
    trainingMode = p5.addScrollableList("trainingMode")
    .setPosition(150, 5)
    .setSize(120, 160)
    .setColorForeground(color(220))
    .setColorActive(color(120))
    .setType(ScrollableList.LIST)
    .addItem("Normal", 0)
    .addItem("Injury", 1);
    
  
  p5.addButton("startEventStream")
    .setPosition(40,400)
    .setSize(150,20)
    .setLabel("Good Muscle Acitivation");
    
  p5.addButton("badStream")
    .setPosition(40,459)
    .setSize(150,20)
    .setLabel("Bad Muscle Activation");

    
    p5.addSlider("GainSlider")
    .setPosition(120,100)
    .setSize(20,100)
    .setRange(0,100)
    .setValue(50)
    .setLabel("Gain");
    
  p5.addButton("update")
    .setPosition(40,500)
    .setSize(150,20)
    .setLabel("Update Values");
    
 p5.addButton("injuryStream")
    .setPosition(40,600)
    .setSize(150,20)
    .setLabel("Injury Training Mode");
    
  p5.addSlider("footPlacement")
    .setPosition(50,100)
    .setSize(20,100)
    .setRange(0,3)
    .setValue(1)
    .setLabel("Foot Placement");
    
   p5.addSlider("kneeFlag")
    .setPosition(250,100)
    .setSize(20,100)
    .setRange(0,3)
    .setValue(1)
    .setLabel("Knee Flag");
    
    
  p5.addSlider("spineFlag")
    .setPosition(350,100)
    .setSize(20,100)
    .setRange(0,1)
    .setValue(0.5)
    .setLabel("Spine Flag");
    
    p5.addSlider("gluteActivity")
    .setPosition(50,250)
    .setSize(20,100)
    .setRange(0,3)
    .setValue(1)
    .setLabel("Glute Activity");
    
      p5.addSlider("quadActivity")
    .setPosition(150,250)
    .setSize(20,100)
    .setRange(0,3)
    .setValue(1)
    .setLabel("Quad Activity");
    
    p5.addSlider("abdActivity")
    .setPosition(250,250)
    .setSize(20,100)
    .setRange(0,3)
    .setValue(1)
    .setLabel("Abductor Activity");
    
    p5.addSlider("hamActivity")
    .setPosition(350,250)
    .setSize(20,100)
    .setRange(0,3)
    .setValue(1)
    .setLabel("Hamstring Activity");

    
 ac.start();
}


public void addEndListener() {
  if (correct.getEndListener() == null) {
    correct.setEndListener(musicEndListener);
  }
}


public void Stop()
{
  music.pause(true);
}

void startEventStream() {
  //loading the event stream, which also starts the timer serving events
    keyPressed(eventDataJSON1);
}

void badStream() {
  //loading the event stream, which also starts the timer serving events
    keyPressed(eventDataJSON2);
}

void injuryStream() {
  //loading the event stream, which also starts the timer serving events
    keyPressed(eventDataJSON3);
}



void draw() {  
  //this method must be present (even if empty) to process events such as keyPressed()  
if (!soundsToPlay.isEmpty()) {

    notification = soundsToPlay.poll();
    println("DEQUEUED === " + notification.toString());
    // sonification
    String mode = null;
    if (isUpdated == true) {
          
    if (primary_muscle == null) {
      primary_muscle = "Glutes";
    }
    
   if (training_mode == null) {
      training_mode = "Normal";
    }
      mode = primary_muscle;
    } else if (isUpdated == false) {
      mode = notification.getPrimaryMuscle();
    }
    
    if (notification.getFootPlacement() == 3 || foot_placement == 3) {
        
    String exampleSpeech = "Fix Foot Placement";
    ttsExamplePlayback(exampleSpeech);
    
    } 
    
    if (notification.getFootPlacement() != 3 || foot_placement != 3) {
      
    }
    
    if (isUpdated == false) {
      if (notification.getTrainingMode() == 2) {
      
   if (notification.getSpineFlag() == 2 && notification.getKneeFlag() == 2 ) {
      
    //String exampleSpeech = "Spine and Knee in danger";
    //ttsExamplePlayback(exampleSpeech);
      filterGlide.setValue(HP_CUTOFF);
      musicGainGlide.setValue(.75);
      alert.setToLoopStart();
      alert.start();
    
    } else if (notification.getSpineFlag() == 2 && notification.getKneeFlag() < 2) {
        String exampleSpeech = "Spine in danger";
        ttsExamplePlayback(exampleSpeech);
    } else if (notification.getSpineFlag() < 2 && notification.getKneeFlag() == 2) {
         String exampleSpeech = "Knee in danger";
        ttsExamplePlayback(exampleSpeech);   
    } 
      } else {
            
   if (notification.getSpineFlag() == 3 && notification.getKneeFlag() == 3 ) {
      
    String exampleSpeech = "Spine and Knee in danger";
    ttsExamplePlayback(exampleSpeech);

    
    } else if (notification.getSpineFlag() == 3 && notification.getKneeFlag() < 3) {
        String exampleSpeech = "Spine in danger";
        ttsExamplePlayback(exampleSpeech);
    } else if (notification.getSpineFlag() < 3 && notification.getKneeFlag() == 3) {
         String exampleSpeech = "Knee in danger";
        ttsExamplePlayback(exampleSpeech);   
    }
      
      }
    
  
    
    } else if (isUpdated == true) {
    
if (training_mode == "Injury") {
      
   if (notification.getSpineFlag() == 2 && notification.getKneeFlag() == 2 ) {
      
    //String exampleSpeech = "Spine and Knee in danger";
    //ttsExamplePlayback(exampleSpeech);
      filterGlide.setValue(HP_CUTOFF);
      musicGainGlide.setValue(.75);
      alert.setToLoopStart();
      alert.start();
    
    } else if (notification.getSpineFlag() == 2 && notification.getKneeFlag() < 2) {
        String exampleSpeech = "Spine in danger";
        ttsExamplePlayback(exampleSpeech);
    } else if (notification.getSpineFlag() < 2 && notification.getKneeFlag() == 2) {
         String exampleSpeech = "Knee in danger";
        ttsExamplePlayback(exampleSpeech);   
    } 
      } else {
            
   if (notification.getSpineFlag() == 3 && notification.getKneeFlag() == 3 ) {
      
    String exampleSpeech = "Spine and Knee in danger";
    ttsExamplePlayback(exampleSpeech);

    
    } else if (notification.getSpineFlag() == 3 && notification.getKneeFlag() < 3) {
        String exampleSpeech = "Spine in danger";
        ttsExamplePlayback(exampleSpeech);
    } else if (notification.getSpineFlag() < 3 && notification.getKneeFlag() == 3) {
         String exampleSpeech = "Knee in danger";
        ttsExamplePlayback(exampleSpeech);   
    }
      
      }
    
  
    }

    switch (mode) {
      case "Quads":
        quadMode(notification);
        break;
      case "Glutes":
      gluteMode(notification);
        break;
      case "Hamstrings":
      hamstringMode(notification);
        break;
      case "Abductors":
      abductorMode(notification);
        break;
    }
    try {
      Thread.sleep(1000);
    } catch (InterruptedException e) {
      Thread.currentThread().interrupt();
    }
  }
}

void keyPressed(String json) {
    notificationServer.stopEventStream(); //always call this before loading a new stream
    notificationServer.loadEventStream(json);
    println("**** New event stream loaded: " + eventDataJSON2 + " ****");
    
}

Boolean isUpdated = false;

class MyNotificationListener implements NotificationListener {
  
  public MyNotificationListener() {
    //setup here
  }
  
  //this method must be implemented to receive notifications
  public void notificationReceived(Notification notification) { 
    
    soundsToPlay.add(notification);

   //You can experiment with the timing by altering the timestamp values (in ms) in the exampleData.json file
    //(located in the data directory)
  }
}

public void quadMode(Notification notification) {
  if(notification.getMuscleActivityQuads() > 1 || muscle_activity_quads > 1){
    music.pause(true);
    correct.setToLoopStart();
    correct.start();
  } else if (notification.getMuscleActivityQuads() == 1 || muscle_activity_quads == 1 ) {
      correct.pause(true);
          alert.setToLoopStart();

      alert.start();
  }
}

public void hamstringMode(Notification notification) {
  if(notification.getMuscleActivityHamstrings() > 1 || muscle_activity_hamstrings > 1){
    alert.pause(true);
    music.pause(true);
    correct.setToLoopStart();
    correct.start();
  } else if (notification.getMuscleActivityHamstrings() == 1 || muscle_activity_hamstrings == 1) {
      correct.pause(true);
                alert.setToLoopStart();

      alert.start(); 
  }

}

public void abductorMode(Notification notification) {
  if(notification.getMuscleActivityAbductors() > 1 || muscle_activity_abductors > 1){
        alert.pause(true);
        music.pause(true);
    correct.setToLoopStart();
    correct.start();
  } else if (notification.getMuscleActivityAbductors() == 1 || muscle_activity_abductors == 1) {
      correct.pause(true);
                alert.setToLoopStart();

      alert.start();    
  }
}

public void gluteMode(Notification notification) {
  if(notification.getMuscleActivityGlutes() > 1 || muscle_activity_glutes > 1){
        alert.pause(true);
music.pause(true);
    correct.setToLoopStart();
    correct.start();
  } else if (notification.getMuscleActivityGlutes() == 1 || muscle_activity_glutes == 1) {
      correct.pause(true);
                alert.setToLoopStart();

      alert.start();    
  }
}


public void primaryMuscleMode() {
int val = (int)primaryMuscleMode.getValue();
switch(val) {      

  case 0:
        primary_muscle = "Glutes";
        break;
     case 1:
        primary_muscle = "Hamstrings";
        break;
    case 2:
        primary_muscle = "Abductors";
        break;
    case 3:
        primary_muscle = "Quads";
        break;
}

}

public void trainingMode() {
  
training_mode = "Normal";

}

public void footPlacement(int value) {

foot_placement = value;
  
}

public void kneeFlag(int value) {

knee_flag = value;

}

public void spineFlag(int value) {

 spine_flag = value;

}

public void gluteActivity(int value) {


 muscle_activity_glutes = value;

}

public void quadActivity(int value) {
  muscle_activity_quads = value;
}

public void hamstringActivity(int value) {
  muscle_activity_hamstrings = value;

}

public void abductorActivity(int value) {
  muscle_activity_abductors = value;
}

void ttsExamplePlayback(String inputSpeech) {
  
  String ttsFilePath = ttsMaker.createTTSWavFile(inputSpeech);
  println("File created at " + ttsFilePath);
  SamplePlayer sp = getSamplePlayer(ttsFilePath, true); 
  
  ac.out.addInput(sp);
  sp.setToLoopStart();
  sp.start();
  println("TTS: " + inputSpeech);
}
