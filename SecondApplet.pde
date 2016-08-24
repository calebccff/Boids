import processing.core.*;

public class SecondApplet extends PApplet{
  int w, h;
  
  SecondApplet(int _w, int _h){
    w = _w; h = _h;
  }
  
  public void settings(){
    size(w, h);
  }
  
  public void setup(){
    surface.setTitle("Debugging");
    surface.setLocation(5, 5);
  }
  
  public void draw(){
    background(0);
    fill(255,220,0);
    text("FPS: "+frameRate+"\nFramecount: "+frameCount+"\nMillis: "+millis()+"\nGen: "+gen+"\nNum: "+boids.size()+"\nAverage aggro: "+aveAggro+"\nAverage max speed: "+aveSpM+"\nAverage turn speed: "+aveSpT+"\nAverage intelligence: "+aveIntel,10,15);
    fill(255, 40, 40);
    ArrayList<Boid> fittest = new ArrayList();
    for(int i = 0; i < boids.size(); i++){
      fittest.add(boids.get(i));
    }
    int finished = 0;
    int[] fittestnums = {0,0,0};
    while(finished != 2){
      for(int i = 0; i < fittest.size()-1; i++){
        try{
          if(fittest.get(i).fitness() < fittest.get(i+1).fitness()){
            finished = 0;
            Boid t = fittest.get(i);
            fittest.remove(i);
            fittest.add(t);
          }else{
            finished++;
          }
        }catch(Exception e){}
      }
    }
    for(int i = 0; i < boids.size(); i++){
      for(int j = 0; j < 3; j++){
        if(fittest.get(j) == boids.get(i)){
          fittestnums[j] = i;
        }
      }
    }
    for(int i = 0; i < 3; i++){
      text(""+int(i+1)+": No. "+fittestnums[i]+"\n"+fittest.get(i).info+"\n", 10, 150+i*160);
    }
    
  }
  
  public void displayText(String text, int x, int y){
    text(text, x, y);
  }
}