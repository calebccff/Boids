ArrayList<Boid> boids;
float aveAggro, aveSpM, aveSpT, aveIntel;
int gen, seed = 0;
boolean debug[] = {false,false,false};
void setup(){
  fullScreen(FX2D);
  setups();
}
void setups(){
  randomSeed(seed);
  boids = new ArrayList<Boid>();
  aveAggro = 0;
  aveSpM = 0;
  aveSpT = 0;
  aveIntel = 0;
  gen = 0;
  for (int i = 0; i < 100; i++){
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
  background(0);
  if (debug[1]){
    stroke(255);
    line(50, 0, 50, height);
    line(0, 50, width, 50);
    line(width-50, 0, width-50, height);
    line(0, height-50, width, height-50);
  }
  for (int i = 0; i < boids.size(); i++){
    if (frameCount % boids.get(i).intel == 1){
      boids.get(i).input();
    }
    boids.get(i).move();
    boids.get(i).display();
  }
  for (int i = boids.size() - 1; i >= 0; i--){
    if (boids.get(i).del){
      boids.remove(i);
      if (boids.size() == 20){
        breed();
        break;
      }
    }
  }
  if (debug[0]){
    fill(255,255,0);
    text("FPS: "+frameRate+"\nGen: "+gen+"\nNum: "+boids.size()+"\nAverage aggro: "+aveAggro+"\nAverage max speed: "+aveSpM+"\nAverage turn speed: "+aveSpT+"\nAverage intelligence: "+aveIntel,10,10);
  }
}
void breed(){
  aveAggro = 0;
  aveSpM = 0;
  aveSpT = 0;
  aveIntel = 0;
  for (int i = 0; i < 10; i++){
    boids.get(i*2).full = 1;
    boids.get(i*2+1).full = 1;
    aveAggro += boids.get(i*2).aggro;
    aveAggro += boids.get(i*2+1).aggro;
    aveSpM += boids.get(i*2).spM;
    aveSpM += boids.get(i*2+1).spM;
    aveSpT += boids.get(i*2).spT;
    aveSpT += boids.get(i*2+1).spT;
    aveIntel += boids.get(i*2).intel;
    aveIntel += boids.get(i*2+1).intel;
    for (int j = 0; j < 10; j++){
      boids.add(new Boid(boids.get(i*2),boids.get(i*2+1)));
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
  frameCount = 0;
}
void open(){
  aveAggro = 0;
  aveSpM = 0;
  aveSpT = 0;
  aveIntel = 0;
  String[] data = loadStrings("save.txt");
  while (boids.size() != 0){
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
void push(){
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
void keyPressed(){
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
    seed = 1;
    setups();
  }
  else if (key == '2'){
    seed = 2;
    setups();
  }
  else if (key == '3'){
    seed = 3;
    setups();
  }
  else if (key == '4'){
    seed = 4;
    setups();
  }
  else if (key == '5'){
    seed = 5;
    setups();
  }
  else if (key == '6'){
    seed = 6;
    setups();
  }
  else if (key == '7'){
    seed = 7;
    setups();
  }
  else if (key == '8'){
    seed = 8;
    setups();
  }
  else if (key == '9'){
    seed = 9;
    setups();
  }
  else if (key == '0'){
    seed = 0;
    setups();
  }
  
}
void keyReleased(){
  if (key == ' '){
    loop();
  }
}