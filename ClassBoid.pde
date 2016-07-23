class Boid{
  PVector _vel = new PVector(0,0);
  int intel;
  float posX, posY, dir, aggro, spM, spA, spD, spT, hung, eat, full = 1, vel = 0;
  boolean w = false, a = false, d = false, click = false, press = false, del = false;
  Boid close = null;
  Boid(){
    posX = random(width*0.1,width*0.9);
    posY = random(height*0.1,height*0.9);
    dir = random(0,360);
    aggro = random(0,1);
    spM = map(aggro,0,1,4.5,1.5)+random(-0.5,0.5);
    spA = spM/random(7.5,12.5);
    spD = spM/random(17.5,22.5);
    spT = random(5,5+aggro*10);
    hung = random(0.001,0.001+aggro*0.001);
    eat = hung*random(20,40);
    intel = int(random(2,31));
  }
  Boid(Boid father, Boid mother){
    posX = random(width*0.1,width*0.9);
    posY = random(height*0.1,height*0.9);
    dir = random(0,360);
    aggro = ((father.aggro+mother.aggro)/2)*random(0.9,1.1);
    spM = ((father.spM+mother.spM)/2)*random(0.9,1.1);
    spA = ((father.spA+mother.spA)/2)*random(0.9,1.1);
    spD = ((father.spD+mother.spD)/2)*random(0.9,1.1);
    spT = ((father.spT+mother.spT)/2)*random(0.9,1.1);
    hung = ((father.hung+mother.hung)/2)*random(0.9,1.1);
    eat = ((father.eat+mother.eat)/2)*random(0.9,1.1);
    intel = ceil(((father.intel+mother.intel)/2)*random(0.9,1.1));
  }
  Boid(String[] data){
    posX = float(data[0]);
    posY = float(data[1]);
    dir = float(data[2]);
    aggro = float(data[3]);
    spM = float(data[4]);
    spA = float(data[5]);
    spD = float(data[6]);
    spT = float(data[7]);
    hung = float(data[8]);
    eat = float(data[9]);
    full = float(data[10]);
    vel = float(data[11]);
    intel = int(data[12]);
    w = boolean(data[13]);
    a = boolean(data[14]);
    d = boolean(data[15]);
    click = boolean(data[16]);
    press = boolean(data[17]);
    del = boolean(data[18]);
    
  }
  void input(){
    //Is it already dead?
    try{
      if (close.del){
        close = null;
      }
    }
    catch(NullPointerException e){
      close = null;
    }
    //Find the closest boid
    float dist = spM*60;
    if (close == null){
      for (int i = 0; i < boids.size(); i++){
        if (dist(posX,posY,boids.get(i).posX,boids.get(i).posY) < dist && boids.get(i) != this){
          dist = dist(posX,posY,boids.get(i).posX,boids.get(i).posY);
          close = boids.get(i);
        }
      }
    }
    else{
      dist = dist(posX,posY,close.posX,close.posY);
    }
    if (dist >= spM*120 || close == null){
      //If none of them are close, move randomly
      w = vel>spM?false:int(random(0,2))==0;
      a = a?int(random(0,4))!=0:int(random(0,4))==0;
      d = d?int(random(0,4))!=0:int(random(0,4))==0;
      close = null;
    }
    else{
      //Find the intended next angle (based on predator/prey)
      float ang = degrees(atan2(close.posY-posY,close.posX-posX));
      float turn;
      if (close.aggro > aggro){
        turn = map((dir-ang+3600)%360,0,360,180,-180);
      }
      else{
        turn = map((dir-ang+3780)%360,0,360,180,-180);
      }
      //Do nothing if within 20 of intended angle
      if (turn < 20 && turn > -20){
        a = false;
        d = false;
      }
      //Is it quicker to turn left or right
      else if (turn < 0){
        a = true;
        d = false;
      }
      else{
        a = false;
        d = true;
      }
    }
    if(posY > height-50){ //150 from bottom
      if(dir < 300 && dir > 240){ //Do nothing if pointing up
        a = false;
        d = false;
      }else if(dir < 240 && dir > 90){ //Turn CW if pointing left
        a = false;
        d = true;
      }else{ //Turn CCW if pointing right
        a = true;
        d = false;
      }
    }else if(posY < 50){ //150 from top
      if(dir < 120 && dir > 60){ //Do nothing if pointing down
        a = false;
        d = false;
      }else if(dir < 270 && dir > 120){ //Turn CCW if pointing left
        a = true;
        d = false;
      }else{ //Turn CW if pointing right
        a = false;
        d = true;
      }
    }else if(posX > width-50){ //150 from right
      if(dir < 210 && dir > 150){ //Do nothing if pointing left
        a = false;
        d = false;
      }else if(dir < 150 && dir > 0){ //Turn CW if pointing down
        a = false;
        d = true;
      }else{ //Turn CCW if pointing up
        a = true;
        d = false;
      }
    }else if(posX < 50){ //150 from left
      if(dir < 30 || dir > 330){ //Do nothing if pointing right
        a = false;
        d = false;
      }else if(dir < 330 && dir > 20){ //Turn CW if pointing up
        a = false;
        d = true;
      }else{ //Turn CCW if pointing down
        a = true;
        d = false;
      }
    }
    //Speed limit
    w = vel<spM*0.9;
  }
  void move(){
    //Accelerate/decelerate
    if (w){
      vel += spA;
      if (vel > spM){
        vel = spM;
      }
    }
    else if (vel > 0){
      vel -= spD;
    }
    //Turn
    if (a){
      dir -= spT;
    }
    if (d){
      dir += spT;
    }
    dir = (dir+3600)%360;
    //Move
    _vel = new PVector(vel,0).rotate(radians(dir));
    posX += _vel.x;
    posY += _vel.y;
    //Wall collision
    if (posX > width){
      posX = width;
    }
    if (posX < 0){
      posX = 0;
    }
    if (posY > height){
      posY = height;
    }
    if (posY < 0){
      posY = 0;
    }
    //Die of hunger
    full -= hung;
    if (full <= 0){
      del = true;
    }
    //Be killed
    for (int i = 0; i < boids.size(); i++){
      float dist = dist(posX,posY,boids.get(i).posX,boids.get(i).posY);
      if (boids.get(i).aggro > aggro && dist <= 15){
        del = true;
        boids.get(i).full += boids.get(i).eat;
      }
    }
  }
  void display(){
  pushMatrix();
  translate(posX,posY);
  rotate(radians(dir));
  noStroke();
  if (click){
    if (hover()){
      fill(aggro>2?color(50,50,25,map(full,0,1,0,255)):color(map(aggro,0,2,250,50),map(aggro,0,2,250,50),map(aggro,0,2,150,25),map(full,0,1,0,255)));
      if (mousePressed && !press){
        press = true;
        click = false;
      }
    }
    else{
      fill(aggro>2?color(50,50,0,map(full,0,1,0,255)):color(map(aggro,0,2,250,50),map(aggro,0,2,250,50),0,map(full,0,1,0,255)));
      press = false;
    }
  }
  else{
    if (hover()){
      fill(aggro>2?color(50,25,25,map(full,0,1,0,255)):color(map(aggro,0,2,250,50),map(aggro,0,2,150,25),map(aggro,0,2,150,25),map(full,0,1,0,255)));
      if (mousePressed && !press){
        press = true;
        click = true;
      }
    }
    else{
      fill(aggro>2?color(50,map(full,0,1,0,255)):color(map(aggro,0,2,250,50),map(full,0,1,0,255)));
      press = false;
    }
  }
  triangle(-15,-10,-15,10,15,-0);
  popMatrix();
  if (debug[1] && close != null){
      if (close.aggro > aggro){
        stroke(0,255,0);
        line(posX,posY,lerp(posX,close.posX,0.5),lerp(posY,close.posY,0.5));
        stroke(0,0,255);
        line(close.posX,close.posY,lerp(posX,close.posX,0.5),lerp(posY,close.posY,0.5));
      }
      else{
        stroke(0,0,255);
        line(posX,posY,lerp(posX,close.posX,0.5),lerp(posY,close.posY,0.5));
        stroke(0,255,0);
        line(close.posX,close.posY,lerp(posX,close.posX,0.5),lerp(posY,close.posY,0.5));
      }
    }
    if (debug[2]){
      fill(255,0,0);
      text("Aggro: "+aggro+"\nMax speed: "+spM+"\nTurning speed: "+spT+"\nFullness: "+full+"\nHunger rate: "+hung+"\nIntelligence: "+intel,posX,posY);
    }
  }
  boolean hover(){
    float x = mouseX - posX;
    float y = mouseY - posY;
    float theta = _vel.heading() + PI/2;
    float d = dist(0,0,y,x);
    float a = atan2(y,x);
    x = cos(a-theta)*d;
    y = sin(a-theta)*d;
    return x > -15 && x < 15 && y > -10 && y < 10;
  }
}