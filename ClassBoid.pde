class Boid{ //The boids.
  PVector _vel = new PVector(0,0); //Directional velocity.
  int intel; //Inteligence (follows golf rules).
  float posX, posY, dir, aggro, spM, spA, spD, spT, hung, eat, full = 1, vel = 0; //The various properties (position, direction, velocity, etc).
  boolean w = false, a = false, d = false, click = false, press = false, del = false; //W, A and D for movement (legacy from user controlled program).
  Boid close = null; //The target boid.
  Boid(){ //First constructor (random numbers).
    posX = random(width*0.1,width*0.9);
    posY = random(height*0.1,height*0.9);
    dir = random(0,360);
    aggro = random(0,1); //Aggro affects some others (e.g. more aggressive = slower).
    spM = map(aggro,0,1,4.5,1.5)+random(-0.5,0.5);
    spA = spM/random(7.5,12.5);
    spD = spM/random(17.5,22.5);
    spT = random(5,5+aggro*10);
    hung = random(0.001,0.001+aggro*0.001);
    eat = hung*random(20,40);
    intel = int(random(2,31));
  }
  Boid(Boid father, Boid mother){ //Second constructor (breeding).
    posX = random(width*0.1,width*0.9); //Random location.
    posY = random(height*0.1,height*0.9);
    dir = random(0,360);
    aggro = ((father.aggro+mother.aggro)/2)*random(0.9,1.1); //Average of the parents, with random mutations.
    spM = ((father.spM+mother.spM)/2)*random(0.9,1.1);
    spA = ((father.spA+mother.spA)/2)*random(0.9,1.1);
    spD = ((father.spD+mother.spD)/2)*random(0.9,1.1);
    spT = ((father.spT+mother.spT)/2)*random(0.9,1.1);
    hung = ((father.hung+mother.hung)/2)*random(0.9,1.1);
    eat = ((father.eat+mother.eat)/2)*random(0.9,1.1);
    intel = ceil(((father.intel+mother.intel)/2)*random(0.9,1.1)); //Ceil rounds intelligence up (don't want a Boid with intelligence of 0).
  }
  Boid(String[] data){ //Third constuctor (file).
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
  void input(){ //Work out how I needs to move.
    try{ //Is my target already dead?
      if (close.del){
        close = null;
      }
    }
    catch(NullPointerException e){
      close = null;
    }
    if (close == null || dist(posX,posY,close.posX,close.posY) >= spM*120){ //If I don't have a target or my current one is further than 120 frames away, lock on to the closest boid within 60 frames.
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
      w = vel>spM?false:int(random(0,2))==0;
      a = a?int(random(0,4))!=0:int(random(0,4))==0;
      d = d?int(random(0,4))!=0:int(random(0,4))==0;
    }
    else{ //Find my intended next angle (based on who the predator/prey between us is).
      float ang = degrees(atan2(close.posY-posY,close.posX-posX));
      float turn;
      if (close.aggro > aggro){
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
      if (boids.get(i).aggro > aggro && dist <= 15){
        del = true;
        boids.get(i).full += boids.get(i).eat;
      }
    }
  }
  void display(){ //Draw the boid in the correct location/direction.
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
  triangle(-15,-10,-15,10,15,-0);
  popMatrix();
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
    if (debug[2]){ //Show information as text.
      fill(255,0,0);
      text("Aggro: "+aggro+"\nMax speed: "+spM+"\nTurning speed: "+spT+"\nFullness: "+full+"\nHunger rate: "+hung+"\nIntelligence: "+intel,posX,posY);
    }
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
}