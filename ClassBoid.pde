class Boid{ //The boids.
  PVector _vel = new PVector(0,0); //Directional velocity.
  int intel, escaped = 0, caught = 0, millis = millis(), site;; //Inteligence (follows golf rules).
  float posX, posY, startX, startY, dir, aggro, spM, spA, spD, spT, hung, eat, full = 1, vel = 0, habit = 0, size = 1; //The various properties (position, direction, velocity, etc).
  boolean chased = false, w = false, a = false, d = false, click = false, press = false, del = false; //W, A and D for movement (legacy from user controlled program).
  String info = "";
  Boid close = null; //The target boid.
  Boid(){ //First constructor (random numbers).
    posX = random(width);
    posY = random(height);
    startX = posX;
    startY = posY;
    dir = random(0,360);
    aggro = random(0,1); //Aggro affects some others (e.g. more aggressive = slower).
    spM = map(aggro,0,1,4.5,1.5)+random(-0.5,0.5);
    spA = spM/random(7.5,12.5);
    spD = spM/random(17.5,22.5);
    spT = random(5,5+aggro*10);
    hung = random(0.001,0.001+aggro*0.001);
    eat = hung*random(20,40);
    intel = ceil(random(2,31));
    habit = random(-2, 2);
    size = map(aggro, 0, 1, 0.3, 0.5)+random(0.5);
    site = round(random(80, 150));
  }
  Boid(Boid parentA, Boid parentB){ //Second constructor (breeding) each gene is either recessive, dominant or nuetral and has a chance to be mutated in the child
    posX = random(10,width-10); //set positions
    posY = random(10,height-10);
    startX = posX; //store the start positions, used in fitness so that boids which moved very little are more likely to have a fitness of 0 and not breed
    startY = posY;
    dir = random(0,360); //Set direction
    if(random(1) < mutationRate){ //chance to mutate
      aggro = random(1.5); //ignore parents genes and choose randomly
    }if(parentA.aggro > parentB.aggro){ //Else favour lower aggression
      aggro = parentB.aggro*random(0.9, 1.1);
    }else{
      aggro = parentA.aggro*random(0.9, 1.1);
    }
    if(random(1) < mutationRate){
      spM = random(1, 6);
    }else if(parentA.spM > parentB.spM){ //Favour higher max speed
      spM = parentB.spM*random(0.9, 1.4);
    }else{
      spM = parentA.spM*random(0.9, 1.4);
    }if(spM < 0.5){
      spM = 0.8;
    }
    if(random(1) < mutationRate){
      spA = spM/random(7.5,12.5);
    }else{  //Chance to mutate, else take average from parents
      spA = ((parentA.spA+parentB.spA)/2)*random(0.9, 1.1);
    }
    if(random(1) < mutationRate){
      spD = spM/random(17.5,22.5);
    }else{ //Same as above
      spD = ((parentA.spD+parentB.spD)/2)*random(0.9, 1.1);
    }
    if(random(1) < mutationRate){
      spT = random(5,5+aggro*10);
    }else if(parentA.spT < aveSpT*1.1 && parentB.spT < aveSpT*1.1){ //Encourage slightly below average turning speed
      spT = ((parentA.spT+parentB.spT)/2)*random(0.9, 1.1);
    }else if(parentA.spT > parentB.spT){
      spT = parentB.spT*random(0.9, 1.1);
    }else{
      spT = parentA.spT*random(0.9, 1.1);
    }
    if(random(1) < mutationRate){
      hung = random(0.001,0.001+aggro*0.001);
    }else if(parentA.hung > parentB.hung){ //Lower hung is better as Boid is less likely to starve (dominant)
      hung = parentB.hung*random(0.9, 1.1);
    }else{
      hung = parentA.hung*random(0.9, 1.1);
    }
    if(random(1) < mutationRate){
      eat = hung*random(20,40);
    }else if(parentA.eat < parentB.eat){ //Higher eat is better as Boid will recover more fullness
      eat = parentB.eat*random(0.9, 1.1);
    }else{
      eat = parentA.eat*random(0.9, 1.1);
    }
    if(random(1) < mutationRate){
      intel = int(random(2,31));
    }else if(parentA.intel < aveIntel*1.1 && parentB.intel < aveIntel*1.1){  //Favour lower intel, if both parents have below average inteligence, so will child
      intel = ceil(((parentA.intel+parentB.intel)/2)*random(0.9, 1.1));
    }else if(parentA.intel > parentB.intel){
      intel = ceil(parentB.intel+random(-2, 2));
    }else{
      intel = ceil(parentA.intel+random(-2, 2));
    }if(intel < 2){
      intel = 2;
    }
    if(random(1) < mutationRate){
      habit = random(-2, 2);
    }else{  //Habit makes Boids prefer turning left or right
      habit = ((parentA.habit+parentB.habit)/2)*random(0.9, 1.1);
    }
    if(random(1) < mutationRate){
      size = random(1, 1.2);
    }else if(parentA.size > 1 && parentB.size > 1){
      size = ((parentA.size+parentB.size)/2)*random(0.9, 1.1);
    }else if(parentA.size < parentB.size){
      size = parentB.size*random(0.9, 1.1);
    }else{
      size = parentA.size*random(0.9, 1.1);
    }if(size < 2){
      size = 2;
    }
    if(random(1) < mutationRate){
      site = round(random(80, 150));
    }else if(parentA.site > 150 && parentB.site > 150){ //If both parents can see further than the max then pass on those genes
      site = round(((parentA.site+parentB.site)/2)*random(0.9, 1.1));
    }else if(parentA.site < parentB.site){ //Else use genes from the parent with the best site
      site = round(parentB.site*random(0.9, 1.1));
    }else{
      site = round(parentA.site*random(0.9, 1.1));
    }
  }
  Boid(String[] data){ //Third constuctor (file).
    posX = float(data[0]);
    posY = float(data[1]);
    startX = posX;
    startY = posY;
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
  void input(){ //Work out how I needs to move.
    try{ //Is my target already dead?
      if (close.del){
        close = null;
      }
    }
    catch(NullPointerException e){
      close = null;
    }
    if (close == null || dist(posX,posY,close.posX,close.posY) >= spM*site){ //If I don't have a target or my current one is further than 120 frames away, lock on to the closest boid within 60 frames.
      close = null;
      float dist = spM*60;
      for (int i = 0; i < boids.size(); i++){
        if (dist(posX,posY,boids.get(i).posX,boids.get(i).posY) < dist && boids.get(i) != this){
          dist = dist(posX,posY,boids.get(i).posX,boids.get(i).posY);
          close = boids.get(i);
        }
      }
    }
    if (close == null){ //If I don't have a target, move randomly.
      if(chased){
        escaped++;
        chased = false;
      }
      w = vel>spM?false:int(random(0,2))==0;
      a = a?int(random(0,4+habit))!=0:int(random(0,4+habit))==0;
      d = d?int(random(0,4+habit))!=0:int(random(0,4-habit))==0;
    }
    else{ //Find my intended next angle (based on who the predator/prey between us is).
      float ang = degrees(atan2(close.posY-posY,close.posX-posX));
      float turn;
      if (close.aggro > aggro){
        chased = true;
        turn = map((dir-ang+3600)%360,0,360,180,-180);
      }
      else{
        turn = map((dir-ang+3780)%360,0,360,180,-180);
      }
      if (turn < 20 && turn > -20){ //Don't turn if I'm already within 20 of intended angle.
        a = false;
        d = false;
      }
      else if (turn < 0){ //Is it quicker to turn left or right?
        a = true;
        d = false;
      }
      else{
        a = false;
        d = true;
      }
    }
    if(posY > height-50){ // If I'm 150 from the bottom...
      if(dir < 300 && dir > 240){ //Do nothing if pointing up.
        a = false;
        d = false;
      }else if(dir < 240 && dir > 90){ //Turn CW if pointing left.
        a = false;
        d = true;
      }else{ //Turn CCW if pointing right.
        a = true;
        d = false;
      }
    }else if(posY < 50){ //If I'm 150 from the top...
      if(dir < 120 && dir > 60){ //Do nothing if pointing down.
        a = false;
        d = false;
      }else if(dir < 270 && dir > 120){ //Turn CCW if pointing left.
        a = true;
        d = false;
      }else{ //Turn CW if pointing right.
        a = false;
        d = true;
      }
    }else if(posX > width-50){ //If I'm 150 from the right...
      if(dir < 210 && dir > 150){ //Do nothing if pointing left.
        a = false;
        d = false;
      }else if(dir < 150 && dir > 0){ //Turn CW if pointing down.
        a = false;
        d = true;
      }else{ //Turn CCW if pointing up.
        a = true;
        d = false;
      }
    }else if(posX < 50){ //If I'm 150 from the left...
      if(dir < 30 || dir > 330){ //Do nothing if pointing right.
        a = false;
        d = false;
      }else if(dir < 330 && dir > 20){ //Turn CW if pointing up.
        a = false;
        d = true;
      }else{ //Turn CCW if pointing down.
        a = true;
        d = false;
      }
    }
    w = vel<spM*0.9; //Don't go over the speed limit!
  }
  void move(){
    if (w){ //Accelerate/decelerate.
      vel += spA;
      if (vel > spM){
        vel = spM;
      }
    }
    else if (vel > 0){
      vel -= spD;
    }
    if (a){ //Turn.
      dir -= spT;
    }
    if (d){
      dir += spT;
    }
    dir = (dir+3600)%360;
    _vel = new PVector(vel,0).rotate(radians(dir)); //Move (in the correct direction, by the correct amount).
    posX += _vel.x;
    posY += _vel.y;
    if (posX > width){ //Hit the walls.
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
    full -= hung; // Starve to death. :(
    if (full <= 0){
      del = true;
    }
    for (int i = 0; i < boids.size(); i++){ // Be eaten. :(
      float dist = dist(posX,posY,boids.get(i).posX,boids.get(i).posY);
      if (boids.get(i).aggro > aggro && dist <= width*0.008*size){
        if(random(2-(size/2)) < 1 && millis()-millis<50){ //Chance that prey can escape predator but get's injured (loses speed)
          spM-=random(1);
          if(spM < 0.5){
            spM = 0.5;
          }
          millis = millis();
        }else if(millis()-millis > 1000){
          del = true;
          boids.get(i).caught++;
          boids.get(i).full += boids.get(i).eat;
        }
      }
    }
  }
  void display(){ //Draw the boid in the correct location/direction.
  size+=0.00001;
  pushMatrix();
  translate(posX,posY);
  rotate(radians(dir));
  noStroke();
  if (click){ //Brightness shows aggro, transparency shows fullness.
    if (hover()){ //Marked and hovered over, so light yellow.
      fill(aggro>2?color(50,50,25,map(full,0,1,0,255)):color(map(aggro,0,2,250,50),map(aggro,0,2,250,50),map(aggro,0,2,150,25),map(full,0,1,0,255)));
      if (mousePressed && !press){
        press = true;
        click = false;
      }
    }
    else{ //Marked and not hovered over, so red.
      fill(aggro>2?color(50,25,25,map(full,0,1,0,255)):color(map(aggro,0,2,250,50),map(aggro,0,2,150,25),map(aggro,0,2,150,25),map(full,0,1,0,255)));
      press = false;
    }
  }
  else{
    if (hover()){ //Not marked and hovered over, so dark yellow.
      fill(aggro>2?color(50,50,0,map(full,0,1,0,255)):color(map(aggro,0,2,250,50),map(aggro,0,2,250,50),0,map(full,0,1,0,255)));
      if (mousePressed && !press){
        press = true;
        click = true;
      }
    }
    else{ //Not marked and not hovered over, so grey.
      fill(aggro>2?color(50,map(full,0,1,0,255)):color(map(aggro,0,2,250,50),map(full,0,1,0,255)));
      press = false;
    }
  }
  triangle(-width*0.008*size,-width*0.003*size,-width*0.008*size,width*0.003*size,width*0.008*size,0);
  //triangle(-15,-10,-15,10,15,-0);
  popMatrix();
  if(debug[2]){
    fill(255, 40, 40);
    text(info, posX, posY);
  }
  if (debug[1] && close != null){ //Show lines for predator/prey.
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
      info = "Aggro: "+aggro+"\nMax speed: "+spM+"\nTurning speed: "+spT+"\nFullness: "+full+"\nHunger rate: "+hung+"\nIntelligence: "+intel+"\nFitness: "+fitness()+"\nHabit: "+habit+"\nSize: "+size+"\nSite: "+site;
  }
  boolean hover(){ //Calculate if the mouse is over the boid (as the hitbox rotates with the boid).
    float x = mouseX - posX;
    float y = mouseY - posY;
    float theta = _vel.heading() + PI/2;
    float d = dist(0,0,y,x);
    float a = atan2(y,x);
    x = cos(a-theta)*d;
    y = sin(a-theta)*d;
    return x > -15 && x < 15 && y > -10 && y < 10;
  }
  float fitness(){
    return pow(escaped*2+caught, 2)+1;
  }
}