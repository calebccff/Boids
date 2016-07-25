ArrayList<Boid> boids; //Create the ArrayList for the boids.
float aveAggro, aveSpM, aveSpT, aveIntel;
int gen;
boolean debug[] = {false,false,false};
void setup(){
  fullScreen(FX2D); //FX2D renderer gives an increased framerate.
  frameRate(75);
  setups(int(random(0, 10000))); //Intitalise the boids, done seperately so that they can be reset without restarting.
}
void setups(int seed){
  randomSeed(seed); //Set the random seed.
  boids = new ArrayList<Boid>(); //Initialise the ArrayList.
  aveAggro = 0; //Reset the averages.
  aveSpM = 0;
  aveSpT = 0;
  aveIntel = 0;
  gen = 0;
  for (int i = 0; i < 100; i++){ //Initialise the boids and calculate the averages.
    boids.add(new Boid());
    aveAggro += boids.get(i).aggro;
    aveSpM += boids.get(i).spM;
    aveSpT += boids.get(i).spT;
    aveIntel += boids.get(i).intel;
  }
  aveAggro /= 100;
  aveSpM /= 100;
  aveSpT /= 100;
  aveIntel /= 100;
  frameCount = 0;
}
void draw(){
  background(0); //Refresh the background.
  if (debug[1]){ //Display boundry lines (when boids are considered too close to the walls).
    stroke(255);
    line(50, 0, 50, height);
    line(0, 50, width, 50);
    line(width-50, 0, width-50, height);
    line(0, height-50, width, height-50);
  }
  if (debug[0]){ //Display debug info (framerate, generation, population, averages)
    fill(255,255,0);
    text("FPS: "+round(frameRate)+"\nGen: "+gen+"\nNum: "+boids.size()+"\nAverage aggro: "+aveAggro+"\nAverage max speed: "+aveSpM+"\nAverage turn speed: "+aveSpT+"\nAverage intelligence: "+aveIntel,10,10);
  }
  for (int i = 0; i < boids.size(); i++){ //Make each boid move and display.
    if (frameCount % boids.get(i).intel == 1){ //More inteligent boids (lower intel) make decisions more often.
      boids.get(i).input();
    }
    boids.get(i).move();
    boids.get(i).display();
  }
  for (int i = boids.size() - 1; i >= 0; i--){
    if (boids.get(i).del){ //Remove boids that have been eaten or have starved.
      boids.remove(i);
      if (boids.size() == 20){ //Breed the boids when there are only 20 left.
        breed();
      }
    }
  }
  
}
void breed(){ //Create the next generation from the current generation.
  aveAggro = 0; //Reset the averages.
  aveSpM = 0;
  aveSpT = 0;
  aveIntel = 0;
  for (int i = 0; i < 10; i++){
    boids.get(i*2).full = 1; //Reset the fullness of the surviving boids. (Unlike some programmers, we take care of our boids.)
    boids.get(i*2+1).full = 1;
    aveAggro += boids.get(i*2).aggro; //Recalculate the averages.
    aveAggro += boids.get(i*2+1).aggro;
    aveSpM += boids.get(i*2).spM;
    aveSpM += boids.get(i*2+1).spM;
    aveSpT += boids.get(i*2).spT;
    aveSpT += boids.get(i*2+1).spT;
    aveIntel += boids.get(i*2).intel;
    aveIntel += boids.get(i*2+1).intel;
    for (int j = 0; j < 10; j++){
      boids.add(new Boid(boids.get(i*2),boids.get(i*2+1))); //Initialise the new boids from 2 parents.
      aveAggro += boids.get(20+i).aggro;
      aveSpM += boids.get(20+i).spM;
      aveSpT += boids.get(20+i).spT;
      aveIntel += boids.get(20+i).intel;
    }
  }
  aveAggro /= 120;
  aveSpM /= 120;
  aveSpT /= 120;
  aveIntel /= 120;
  gen++;
  frameCount = 0; //Reset framecount each generation (so they all make a decision on the first frame).
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
  aveAggro /= 100;
  aveSpM /= 100;
  aveSpT /= 100;
  aveIntel /= 100;
}
void push(){ //Saving to a file.
  String data = "";
  for (int i = 0; i < boids.size(); i++){ //Yes there is likely a much more efficient way of doing this why are you asking.
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
    if (boids.get(i).close == null){ // Store 'Forever alone' if the boid doesn't have a target or if it can't be found, or the index of the target otherwise.
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