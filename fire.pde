ArrayList<Particle> particles;
Box box;
boolean flowing = false;
PImage img;
PImage smoke_texture;
PShape logs;
float rx = 0, ry = 0, rz = 0, scale = 1;
void setup(){
  size(800, 800, P3D);
  noStroke();
  frameRate(24);
  logs = loadShape("fre005.obj");
  box = new Box();
 // smoke_texture = loadImage("https://www.freeiconspng.com/uploads/smoke-overlay-png-smoke-png-image-smokes-1.png");
  img = loadImage("https://png.pngtree.com/element_our/md/20180524/md_5b06da6b757d6.png");
  lights();
  particles = new ArrayList<Particle>();
}

void draw(){  
  background(50); 
  lights();
  translate(width/2, height/2, 0);
  fill(0);
  text(particles.size(),200,-200); 
  rotateX(rx);
  rotateY(ry);
  rotateZ(rz);
  scale(scale);
  translate(0,150,0);
  scale(0.2);
  rotateX(1.5708);
  shape(logs,0,0);
  rotateX(-1.5708);
  scale(5);
  translate(0,-150,0);
  if(flowing){
    for(int i = 0; i < 40; i++){
      if(particles.size() < 10000){
        float vx = 0;
        float vz = 0;
        float posx = random(-40,40);
        float posz = random(-30,30);
        if(posz < 0){
          vz = random(0.3,0.5);
        }
        if(posz >= 0){
          vz = random(-0.5,-.2);
        }
        if(posx < 0){
          vx = random(0.3,0.5);
        }
        if(posx >= 0){
          vx = random(-0.5,-.2);
        }
        float vy = randomGaussian() * 0.3 - 1.0;
        PVector velocity = new PVector(vx,vy,vz);
        particles.add(new Particle(new PVector(posx,85,posz),velocity));
      }
    }
  }
  if(keyPressed){
    if(key == 'z'){
      scale-=0.01;
    }
    if(key == 'x'){
      scale+=0.01;
    }
    if(keyCode == UP){
      rx += 0.01;
    }
    if(keyCode == DOWN){
      rx -= 0.01;
    }
    if(keyCode == LEFT){
     // println(ry);
      ry -= 0.01;
    }
    if(keyCode == RIGHT){
      ry += 0.01;
    }
  
  }
  for(int i = particles.size() - 1; i >= 0; i--){
    Particle p = particles.get(i);
    p.update();
    //float dx = map(mouseX, 0, width, -0.2, 0.2);
    //PVector wind = new PVector(dx, 0);
    //p.applyForce(wind);
    p.display();  
    p.checkEdges();
    if(p.finished()){
      particles.remove(i);
    }
  }
  box.display();
    
}
void keyPressed(){
  println(keyCode);
  if(keyCode == 83 && !flowing){
    flowing = true;
  }
  else if(keyCode == 83 && flowing){
    flowing = false;
  }
  println(flowing);
}
  
class Particle{
  PVector location;
  PVector velocity;
  PVector acceleration;
  PVector[][] sphere_arr;
  int total = 5;
  float radius;
  float mass;
  float life;
  int g;

   
  Particle(PVector loc, PVector vel){
    velocity = new PVector(vel.x,vel.y,vel.z);
    acceleration = new PVector(0,0,0);

    mass = random(10);
    radius = mass / 3;
    location = new PVector(loc.x,loc.y,loc.z);
    life = 255;
    sphere_arr = new PVector[total + 1][total + 1];
    g = 0;
    
  }
  
  void applyForce(PVector force){
    PVector f = PVector.div(force,mass);
    acceleration.add(f);
  }
  
  void update(){
    velocity.add(acceleration); 
    location.add(velocity);
   // acceleration.mult(0);
    life-=2.5;
    g+=2;
  }
  
  //This bit of code has been used from this program by Dan Shiffman
  //https://github.com/CodingTrain/website/blob/master/CodingChallenges/CC_025_SphereGeometry/Processing/CC_025_SphereGeometry/CC_025_SphereGeometry.pde
  void display(){
   float r = radius;
   for (int i = 0; i < total+1; i++) {
    float lat = map(i, 0, total, 0, PI);
    for (int j = 0; j < total+1; j++) {
      float lon = map(j, 0, total, 0, TWO_PI);
      float x = r * sin(lat) * cos(lon);
      float y = r * sin(lat) * sin(lon);
      float z = r * cos(lat);
      sphere_arr[i][j] = new PVector(x, y, z);
     }
   }
   for (int i = 0; i < total; i++) {
    fill(255,g,0,life);
    noStroke();
    beginShape(TRIANGLE_STRIP);
    for (int j = 0; j < total+1; j++) {
      PVector v1 = sphere_arr[i][j];
      vertex(v1.x + location.x, v1.y + location.y, v1.z + location.z);
      PVector v2 = sphere_arr[i+1][j];
      vertex(v2.x + location.x, v2.y + location.y, v2.z + location.z);
      }
     endShape();
    }   
  }
  void checkEdges(){
    
    // check collision with floor and sides of box
    if(location.x + radius > 150){
      location.x = 150 - radius;
      velocity.x *= random(-.75,-.95);
    }
    if(location.x - radius < -150){
      location.x = -150 + radius;
      velocity.x *= random(-.75,-.95);
    }
    if(location.y + radius > 150){
      location.y = 150 - radius;
      velocity.y *= random(-.5,-.1);
    }
    if(location.y - radius < -150){
      location.y = -150 + radius;
      velocity.y *= random(-.5,-.1);
    }
    if(location.z + radius > 150){
      location.z = 150 - radius;
      velocity.z *= random(-.75,-.95);
    }
    if(location.z - radius < -150){
      location.z = -150 + radius;
      velocity.z *= random(-.75,-.95);
    }
   
  }
  boolean finished(){
    if(life < 0.0){
      return true;
    }else{
      return false;
    }
  } 
}

// The cube for which the particles are bounded to 
class Box{
  float hit = 0;
  void display(){
    // x right
 
    beginShape(QUADS);
    stroke(255);
    noFill();
    vertex( 150, -150,  150, 0, 0); 
    vertex( 150, -150, -150, 150, 0); 
    vertex( 150,  150, -150, 150, 150); 
    vertex( 150,  150,  150, 0, 150); 

    vertex(-150, -150, -150, 0, 0); 
    vertex(-150, -150,  150, 150, 0); 
    vertex(-150,  150,  150, 150, 150); 
    vertex(-150,  150, -150, 0, 150); 

    vertex(-150,  150,  150, 0, 0); 
    vertex( 150,  150,  150, 150, 0); 
    vertex( 150,  150, -150, 150, 150); 
    vertex(-150,  150, -150, 0, 150); 

    vertex(-150, -150, -150, 0, 0); 
    vertex( 150, -150, -150, 150, 0); 
    vertex( 150, -150,  150, 150, 150); 
    vertex(-150, -150,  150, 0, 150);


    vertex(-150,-150,150,0,0);
    vertex(150,-150,150,150,0);
    vertex(150,150,150,150,150);
    vertex(-150,150,150,0,150);

    vertex(150,-150,-150,0,0);
    vertex(-150,-150,-150,150,0);
    vertex(-150,150,-150,150,150);
    vertex(150,150,-150,0,150);
    endShape();

  }
}
