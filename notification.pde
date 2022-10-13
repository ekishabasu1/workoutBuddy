
class Notification {
  //USING PRIORITY LEVEL AS TRAINING MODE FOR SOME REASON
  String primary_muscle;
  int timestamp;  
  int muscle_activity_quads;
  int muscle_activity_glutes;
  int muscle_activity_abductors;
  int muscle_activity_hamstrings;
  int knee_flag;
  int spine_flag;
  int foot_placement;
  int training_mode;
  
  public Notification() {
    
  //this.timestamp = 1000;
  //this.primary_muscle = "Glutes";
  //this.muscle_activity_glutes = 1;
  //this.muscle_activity_quads = 1;
  //this.muscle_activity_hamstrings = 1;
  //this.muscle_activity_abductors = 1;
  //this.spine_flag = 1;
  //this.knee_flag = 1;
  //this.foot_placement = 1;
  
  }
  
  
  public Notification(JSONObject json) {
    
    this.primary_muscle = json.getString("primary_muscle");
    this.timestamp = json.getInt("timestamp");
    this.muscle_activity_quads = json.getInt("muscle_activity_quads");
    this.muscle_activity_glutes = json.getInt("muscle_activity_glutes");
    this.muscle_activity_abductors = json.getInt("muscle_activity_abductors");
    this.muscle_activity_hamstrings = json.getInt("muscle_activity_hamstrings");

    this.knee_flag = json.getInt("knee_flag");
    this.spine_flag = json.getInt("spine_flag");
    this.foot_placement = json.getInt("foot_placement");
    this.training_mode =  json.getInt("training_mode");
  }
 
  public String getPrimaryMuscle() { return primary_muscle; }
  public int getTimestamp() { return timestamp; }
  public int getMuscleActivityHamstrings() { return muscle_activity_hamstrings ;}
  public int getMuscleActivityGlutes() { return muscle_activity_glutes ;}
  public int getMuscleActivityAbductors() { return muscle_activity_abductors ;}
  public int getMuscleActivityQuads() { return muscle_activity_quads ;}

  public int getKneeFlag() { return knee_flag ;}
  public int getSpineFlag() { return spine_flag ;}
  public int getFootPlacement() { return foot_placement ;}
    public int getTrainingMode() { return training_mode ;}


  public String toString() {
      String output = getPrimaryMuscle() + ": ";
      output += "(timestamp: " + getTimestamp() + ") ";
      output += "(muscle_activity_quads: " + getMuscleActivityQuads() + ") ";
      output += "(muscle_activity_ham: " + getMuscleActivityHamstrings() + ") ";
      output += "(muscle_activity_glutes: " + getMuscleActivityGlutes() + ") ";
      output += "(muscle_activity_abd: " + getMuscleActivityAbductors() + ") ";
      output += "(knee_flag: " + getKneeFlag() + ") ";
      output += "(spine_flag: " +  getSpineFlag() + ") ";
      output += "(foot_placement: " + getFootPlacement() + ") ";
      return output;
      
    }
}
