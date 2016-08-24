import javax.swing.*;

ArrayList<Boid> boids; //Create the ArrayList for the boids.
float aveAggro, aveSpM, aveSpT, aveIntel, mutationRate;
int gen;
boolean debug[] = {false,false,false};
SecondApplet s;

void settings(){
  size(displayWidth-230, displayHeight-76, FX2D); //FX2D renderer gives an increased framerate.
}


void setup(){
  surface.setTitle("Boids");
  surface.setLocation(215, 0);
  s = new SecondApplet(displayWidth-(displayWidth-200), displayHeight-76);
  PApplet.runSketch(new String[] {"DebugWindow"}, s);
  frameRate(60);
  //textFont(createFont("Consolas", 32, true));
  setups(int(random(0, 100000))); //Intitalise the boids, done seperately so that they can be reset without restarting.
}
void setups(int seed){
  randomSeed(seed); //Set the random seed.
  boids = new ArrayList<Boid>(); //Initialise the ArrayList.
  aveAggro = 0; //Reset the averages.
  aveSpM = 0;
  aveSpT = 0;
  aveIntel = 0;
  gen = 0;
  mutationRate = 0.1;
  for (int i = 0; i < 100; i++){ //Initialise the boids and calculate the averages.
    boids.add(new Boid());
    aveAggro += boids.get(i).aggro;
    aveSpM += boids.get(i).spM;
    aveSpT += boids.get(i).spT;
    aveIntel += boids.get(i).intel;
  }
  aveAggro /= boids.size();
  aveSpM /= boids.size();
  aveSpT /= boids.size();
  aveIntel /= boids.size();
  frameCount = 0;
}
void draw(){
  background(25, 50, 75); //Refresh the background.
  //textFont(f);
  if (debug[1]){ //Display boundry lines (when boids are considered too close to the walls).
    stroke(255);
    line(50, 0, 50, height);
    line(0, 50, width, 50);
    line(width-50, 0, width-50, height);
    line(0, height-50, width, height-50);
  }
  
  for (int i = 0; i < boids.size(); i++){ //Make each boid move and display.
    if (frameCount % boids.get(i).intel == 0){ //More inteligent boids (lower intel) make decisions more often.
      boids.get(i).input();
    }
    boids.get(i).move();
    boids.get(i).display();
    fill(255, 150, 25);
    text(i, boids.get(i).posX, boids.get(i).posY);
  }
  for (int i = boids.size() - 1; i >= 0; i--){
    if (boids.get(i).del){ //Remove boids that have been eaten or have starved.
      boids.remove(i);
      if ((random(20)<1 && boids.size()<95) || boids.size() < 20){ //Breed the boids when there are only 20 left.
        breed();
      }
    }
  }
}
void breed(){ //new breed function which uses a mating pool and gives each Boid a chance to pass on it's genes
  aveAggro = 0; //Reset the averages.
  aveSpM = 0;
  aveSpT = 0;
  aveIntel = 0;
  ArrayList<Boid> matingPool = new ArrayList(); //Create the mating pool
  for(int i = 0; i < boids.size(); i++){
    int n = int(boids.get(i).fitness()); //Add each Boid to the pool /fitness/ number of time (higher fitness = higher chance of passing on genes)
    for(int j = 0; j < n; j++){
      matingPool.add(boids.get(i));
    }
  }
  for(int i = 0; i < 200-boids.size(); i++){ //Breed 100 new boids
    int a = int(random(matingPool.size()));
    int b = int(random(matingPool.size()));
    boids.add(new Boid(matingPool.get(a), matingPool.get(b))); //A Boid can breed multiple times, potentially with itself
  }
  for(int i = 0; i < boids.size(); i++){ //Reset the averages
    aveAggro += boids.get(i).aggro;
    aveSpM += boids.get(i).spM;
    aveSpT += boids.get(i).spT;
    aveIntel += boids.get(i).intel;
    boids.get(i).full = boids.get(i).fitness()<2?boids.get(i).full:1; //If the boid has a low fitness the don't reset hunger (Boid is more likely to die in next generation)
    boids.get(i).escaped = 0; //Reset counters so the surviving Boids don't start a generation with a higher fitness
    boids.get(i).caught = 0;
  }
  if(boids.size() > 0){
    aveAggro /= boids.size();
    aveSpM /= boids.size();
    aveSpT /= boids.size();
    aveIntel /= boids.size();
  }
  gen++;
}
void open(){ //Loading from a file.
  aveAggro = 0; //Reset the averages.
  aveSpM = 0;
  aveSpT = 0;
  aveIntel = 0;
  while (boids.size() != 0){ //Reset the ArrayList.
    boids.remove(0);
  }
  String[] data = loadStrings("save.txt"); //Open the file.
  int len = (data.length-1)/20;
  for(int i = 0; i < len; i++){ //Load each boid using the respective lines of the file.
    boids.add(new Boid(subset(data,i*20,19)));
  }
  for(int i = 0; i < boids.size(); i++){ //Relocate their targets and recalculate the averages.
    boids.get(i).close = boids.get(int(data[i*20+19]));
    aveAggro += boids.get(i).aggro;
    aveSpM += boids.get(i).spM;
    aveSpT += boids.get(i).spT;
    aveIntel += boids.get(i).intel;
  }
  gen = int(data[len]);
  aveAggro /= boids.size();
  aveSpM /= boids.size();
  aveSpT /= boids.size();
  aveIntel /= boids.size();
}
void push(){ //Saving to a file.
  String data = "";
  for (int i = 0; i < boids.size(); i++){ //Yes there is likely a much more efficient way of doing this why are you asking. (Somebody please do this better)
    data += boids.get(i).posX+"\n";
    data += boids.get(i).posY+"\n";
    data += boids.get(i).dir+"\n";
    data += boids.get(i).aggro+"\n";
    data += boids.get(i).spM+"\n";
    data += boids.get(i).spA+"\n";
    data += boids.get(i).spD+"\n";
    data += boids.get(i).spT+"\n";
    data += boids.get(i).hung+"\n";
    data += boids.get(i).eat+"\n";
    data += boids.get(i).full+"\n";
    data += boids.get(i).vel+"\n";
    data += boids.get(i).intel+"\n";
    data += boids.get(i).w+"\n";
    data += boids.get(i).a+"\n";
    data += boids.get(i).d+"\n";
    data += boids.get(i).click+"\n";
    data += boids.get(i).press+"\n";
    data += boids.get(i).del+"\n";
    if (boids.get(i).close == null){ // Store 'Forever alone' if the Boid doesn't have a target or if it can't be found, or the index of the target otherwise.
      data += "Forever alone\n";
    }else{
      boolean foundClose = false;
      for(int j = 0; j < boids.size(); j++){
        if (boids.get(i).close == boids.get(j)){
          data += j+"\n";
          foundClose = true;
          break;
        }
      }
      if(!foundClose){
        data+="Forever alone\n";
      }
    }
  }
  data += gen+"\n";
  saveStrings("save.txt",split(data, "\n"));
}
void keyPressed(){ //Key inputs.
  if (key == ' '){ //Pause.
    noLoop();
  }
  else if (key == 'd' || key == 'D'){ //Enable debugging.
    debug[0] = !debug[0];
  }
  else if (key == 'f' || key == 'F'){
    debug[1] = !debug[1];
  }
  else if (key == 'g' || key == 'G'){
    debug[2] = !debug[2];
  }
  else if (key == 'o' || key == 'O'){ //Load a file.
    open();
  }
  else if (key == 'p' || key == 'P'){ //Save a file.
    push();
  }
  else if (key == '1'){ //Restart the simulation with a given seed.
    setups(1);
  }
  else if (key == '2'){
    setups(2);
  }
  else if (key == '3'){
    setups(3);
  }
  else if (key == '4'){
    setups(4);
  }
  else if (key == '5'){
    setups(5);
  }
  else if (key == '6'){
    setups(6);
  }
  else if (key == '7'){
    setups(7);
  }
  else if (key == '8'){
    setups(8);
  }
  else if (key == '9'){
    setups(9);
  }
  else if (key == '0'){
    setups(0);
  }
  
}
void keyReleased(){
  if (key == ' '){ //Continue.
    loop();
  }
}