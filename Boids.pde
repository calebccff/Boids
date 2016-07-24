ArrayList<Boid> boids; //Create the arraylist for the boids
float aveAggro, aveSpM, aveSpT, aveIntel;
int gen;
boolean debug[] = {false,false,false};
void setup(){
  fullScreen(FX2D); //FX2D renderer gives increased framerate
  frameRate(75);
  setups(int(random(0, 10000))); //intitalise the boids, done seperately so that they can be reset whithout restarting
}
void setups(int seed){
  randomSeed(seed); //set the random seed
  boids = new ArrayList<Boid>(); //Initialise the arraylist and create the boids
  aveAggro = 0; //initilise the average variables
  aveSpM = 0;
  aveSpT = 0;
  aveIntel = 0;
  gen = 0;
  for (int i = 0; i < 100; i++){ //Calculate the average variables for the first generation and add the boids
    boids.add(new Boid()); //add a boid to the arraylist
    aveAggro += boids.get(i).aggro; //add to average VVV
    aveSpM += boids.get(i).spM;
    aveSpT += boids.get(i).spT;
    aveIntel += boids.get(i).intel;
  }
  aveAggro /= 100; //Calculate the averages
  aveSpM /= 100;
  aveSpT /= 100;
  aveIntel /= 100;
  frameCount = 0;
}
void draw(){
  background(0); //refresh the background
  if (debug[1]){ //Display debug info
    stroke(255);
    line(50, 0, 50, height); //lines to show when boids start to move away from the walls
    line(0, 50, width, 50);
    line(width-50, 0, width-50, height);
    line(0, height-50, width, height-50);
  }
  if (debug[0]){ //Display averages and other info
    fill(255,255,0);
    text("FPS: "+round(frameRate)+"\nGen: "+gen+"\nNum: "+boids.size()+"\nAverage aggro: "+aveAggro+"\nAverage max speed: "+aveSpM+"\nAverage turn speed: "+aveSpT+"\nAverage intelligence: "+aveIntel,10,10);
  }
  for (int i = 0; i < boids.size(); i++){ //make each boid move
    if (frameCount % boids.get(i).intel == 1){ //more inteligent boids change direction more often
      boids.get(i).input();
    }
    boids.get(i).move();
    boids.get(i).display();
  }
  for (int i = boids.size() - 1; i >= 0; i--){
    if (boids.get(i).del){ //remove boids which have been eaten
      boids.remove(i);
      if (boids.size() == 20){ //breed the boids if there are only 20 left
        breed();
        break;
      }
    }
  }
  
}
void breed(){ //create new boids using the information about the current boids
  aveAggro = 0; //reset averages
  aveSpM = 0;
  aveSpT = 0;
  aveIntel = 0;
  for (int i = 0; i < 10; i++){
    boids.get(i*2).full = 1; //reset the fullness of the surviving boids (they deserve it)
    boids.get(i*2+1).full = 1;
    aveAggro += boids.get(i*2).aggro; //recaulculate averages
    aveAggro += boids.get(i*2+1).aggro;
    aveSpM += boids.get(i*2).spM;
    aveSpM += boids.get(i*2+1).spM;
    aveSpT += boids.get(i*2).spT;
    aveSpT += boids.get(i*2+1).spT;
    aveIntel += boids.get(i*2).intel;
    aveIntel += boids.get(i*2+1).intel;
    for (int j = 0; j < 10; j++){
      boids.add(new Boid(boids.get(i*2),boids.get(i*2+1))); //create new boids from 2 parents
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
  frameCount = 0; //reset framecount each generation
}
void open(){ //loading from save file
  aveAggro = 0; //reset averages (again)
  aveSpM = 0;
  aveSpT = 0;
  aveIntel = 0;
  String[] data = loadStrings("save.txt"); //open the file
  while (boids.size() != 0){ //delete all exisitng boids
    boids.remove(0);
  }
  int len = (data.length-1)/20;
  for(int i = 0; i < len; i++){
    boids.add(new Boid(subset(data,i*20,19)));
  }
  for(int i = 0; i < boids.size(); i++){
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
void push(){ //save all the information about current boids
  String data = "";
  for (int i = 0; i < boids.size(); i++){
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
    if (boids.get(i).close == null){
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
void keyPressed(){ //detects keys to enable debugging and respawn all boids from a random seed
  if (key == ' '){
    noLoop();
  }
  else if (key == 'd' || key == 'D'){
    debug[0] = !debug[0];
  }
  else if (key == 'f' || key == 'F'){
    debug[1] = !debug[1];
  }
  else if (key == 'g' || key == 'G'){
    debug[2] = !debug[2];
  }
  else if (key == 'o' || key == 'O'){
    open();
  }
  else if (key == 'p' || key == 'P'){
    push();
  }
  else if (key == '1'){
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
  if (key == ' '){
    loop();
  }
}