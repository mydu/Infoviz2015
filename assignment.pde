/*
  Author: Mengying DU
*/

import controlP5.*;

ControlP5 cp5;

float scaleFactor = 1.0;
float translateX = 0.0;
float translateY = 50.0;

//Data related variables
float minX, maxX; // store the bounding box of all points
float minY, maxY;
int minPopulation, maxPopulation;
int minDensity, maxDensity;
int numPoints; // total number of places seen

//Display related variable
int minPopulationDisplay;
int minDensityDisplay;
float powMinPopulation, powMaxPopulation;
float logMinPopulation, logMaxPopulation;
float sqrtMinDensity, sqrtMaxDensity;
Place highlighted_place = null;
Place selected_place = null;
ArrayList<Place> highlighted_places = null;

Place places[];

void setup() {
  size(800, 800);
  noStroke();
  colorMode(HSB, 360, 100, 100, 100);
  readData();
  println(sqrtMinDensity);
  println(sqrtMaxDensity);
  createSlider();
}
void createSlider(){
  cp5 = new ControlP5(this);
  
  cp5.addSlider("minPopulationDisplay")
     .setPosition(20,20)
     .setSize(200,20)
//     .setLabel("Puplation Filter")
     .setRange(logMinPopulation,logMaxPopulation)
     .setValue(logMinPopulation+10);
//     .setNumberOfTickMarks(10);
//     .setRange(int(log2(minPopulation+1)),int(log2(maxPopulation)))
//     .setNumberOfTickMarks(int(log2(maxPopulation)))
//     .setColorTickMark(100)
//     .setSliderMode(Slider.FLEXIBLE);
//   println(cp5.getController("minPopulationDisplay").getValue()); 
     cp5.getController("minPopulationDisplay").getValueLabel().setVisible(false);
     
   cp5.addSlider("minDensityDisplay")
     .setPosition(20,60)
     .setSize(200,20)
     .setRange(sqrtMinDensity,sqrtMaxDensity)
     .setValue(sqrtMinDensity+10);
     cp5.getController("minPopulationDisplay").getValueLabel().setVisible(false);
     cp5.getController("minDensityDisplay").getValueLabel().setVisible(false);
}
void draw() {
  background(0,0,100);
  pushMatrix();
  translate(translateX,translateY);
  scale(scaleFactor);
  minPopulationDisplay=int(pow(2,cp5.getController("minPopulationDisplay").getValue()));
  minDensityDisplay=int(pow(cp5.getController("minDensityDisplay").getValue(),2));
  cp5.getController("minPopulationDisplay").getCaptionLabel()
                                            .setColor(color(209,100,43))
                                            .setSize(16) 
                                            .setText("Population larger than "+minPopulationDisplay);
  cp5.getController("minDensityDisplay").getCaptionLabel()
                                            .setColor(color(209,100,43))
                                            .setSize(16) 
                                            .setText("Density larger than "+minDensityDisplay);
 
  for (int i = 0; i < numPoints; ++i) {
    Place p = places[i];
    if(p.population >= minPopulationDisplay&&p.density >=minDensityDisplay){
      p.draw();
    }
  }
  
  drawInfos();
  popMatrix();
}

void readData() {
  
//  String[] lines = loadStrings("villes.tsv");
  String[] lines = loadStrings("villes.csv");
  parseInfo(lines[0]);

  places = new Place[numPoints];
  for (int i = 0; i < numPoints; ++i) {
    String pieces[] = split(lines[i+2], ',');
    int postalCode = int(pieces[0]);
    float x = float(pieces[1]);
    float y = float(pieces[2]);
    x = map(x, minX, maxX, 0, 800);
    y = 800 - map(y, minY, maxY, 0, 800);
    String name = pieces[4];
    int population = int(pieces[5]);
    int density = int(pieces[8]);
    places[i] = new Place(postalCode, name, x, y, population, density);
  }
}

void parseInfo(String line) { // Parse one line
  String infoString = line.substring(2); // remove the #
  String[] pieces = split(infoString, ',');
  numPoints = int(pieces[0]);
  minX = float(pieces[1]);
  maxX = float(pieces[2]);
  minY = float(pieces[3]);
  maxY = float(pieces[4]);
  minPopulation = int(pieces[5]);
  maxPopulation = int(pieces[6]);
  powMinPopulation = pow(minPopulation, 0.7);
  powMaxPopulation = pow(maxPopulation, 0.7);
  logMinPopulation = log2(minPopulation+1);
  logMaxPopulation = log2(maxPopulation);
  
  minDensity = int(pieces[11]);
  maxDensity = int(pieces[12]);
  sqrtMinDensity = sqrt(minDensity);
  sqrtMaxDensity = sqrt(maxDensity);
}

class Place {
  int postalCode;
  String name;
  float x;
  float y;
  float population;
  float density;

  boolean highlighted;
  boolean selected;
  int w; //width
  int b; //brightness

  Place(int postalCode, String name, float x, float y,
        float population, float density){
    this.postalCode = postalCode;
    this.name = name;
    this.x = x;
    this.y = y;
    this.population = population;
    this.density = density;
    this.w = int(map(pow(population, 0.7), powMinPopulation, powMaxPopulation, 0, 100));
//    this.w = int(map(log2(population), logMinPopulation, logMaxPopulation, 0, 100));
    this.b = int(map(sqrt(density), sqrtMinDensity, sqrtMaxDensity, 80, 0));
    // if (this.population < 20000) {
    //   //still not a city
    //   this.w = 1;
    // }
    // else if(this.population < 100000){
    //   //city
    //   this.w = 5;
    // }
    // else if(this.population < 1000000){
    //   //big city
    //   this.w = 10;
    // } else{
    //   //super big city
    //   this.w = 20;
    // }
  }

  boolean contains(float x, float y){
    float dx = this.x - x;
    float dy = this.y - y;
    float d = sqrt(pow(dx, 2) + pow(dy, 2));
    int offset = 1;
    if(d <= (this.w / 2.0 + offset)){
      return true;
    }
    else{
      return false;
    }
  }

  void draw() {
    color c = color(270,80,80);
    if(this.w < 2){
//     set(int(this.x), int(this.y), c);
       ellipse(int(this.x),int(this.y),1, 1);
    }else{
      if(this.highlighted == true){
        fill(0,100,100, 100-int(this.w*0.8));
      }else{
        fill(210,100,this.b, 100-int(this.w*0.8));
      }
      ellipse(int(this.x),int(this.y),this.w, this.w);
    }
  }
}


void drawInfos(){
  fill(0, 0, 0);
  textSize(15);
  //text("x:"+mouseX+",y:"+mouseY, 20, 20);
//  text("Display population above " + minPopulationDisplay, 20, 20);


  // Place p = highlighted_place;
  // if(p != null){
  //   fill(60,100,100, 50);
  //   textSize(15);
  //   float w = textWidth(p.name);
  //   rect(p.x+p.w/2, p.y-p.w/2, w, -15);
  //   fill(0, 0, 0);
  //   text(p.name, p.x+p.w/2, p.y-p.w/2);
  // }

  if(highlighted_places != null && highlighted_places.size()>= 1){
    int n = highlighted_places.size();
    //get best display position
    Place place = highlighted_places.get(0);
    float maxX = place.x+place.w/2;
    float minY = place.y;
    float maxY = place.y;
    for(Place p: highlighted_places){
      if(p.x+p.w/2 > maxX){
        maxX = p.x+p.w/2;
      }
      if(p.y < minY){
        minY = p.y;
      }
      if(p.y > maxY){
        maxY = p.y;
      }
    }

    int hight = 15;
    int x = int(maxX);
    int y = int((minY+maxY)/2 - hight*n/2) ;
    if(y < hight){
      y = hight;
    }
    if(selected_place!=null){
      for(int i = 0; i < highlighted_places.size(); i++){
        Place p = highlighted_places.get(i);
        if(p==selected_place){
          color c=color(0,100,100, 100-int(selected_place.w*0.8));
          stroke(c);
          fill(c);
          //line from circle center to text
          line(p.x, p.y, x, y+i*hight-hight/2);
          noStroke();
          //rect round text
          textSize(hight);
          float w = textWidth(p.name);
          rect(x, y+i*hight+3, w, -hight);
          //text
          fill(0, 0, 0);
          text(p.name+"\n"+" population:"+p.population+" density:"+p.density, x, y+i*hight);
        }
      }
    }
    else{
      for(int i = 0; i < highlighted_places.size(); i++){
      Place p = highlighted_places.get(i);
      color c;
      if(i % 3 == 0){
        c = color(60,80,80,80);
      }
      else if(i % 3 == 1){
        c = color(120,80,80,80);
      }
      else{
        c = color(180,80,80,80);
      }
      stroke(c);
      fill(c);
      //line from circle center to text
      line(p.x, p.y, x, y+i*hight-hight/2);
      noStroke();
      //rect round text
      textSize(hight);
      float w = textWidth(p.name);
      rect(x, y+i*hight+3, w, -hight);
      //text
      fill(0, 0, 0);
      text(p.name, x, y+i*hight);
      }
    }
  }
}

Place pick(float x, float y){
  for (int i = numPoints-1; i >= 0; i--) {
    Place p = places[i];
    if(p.population < minPopulationDisplay || p.density < minDensityDisplay){
      continue;
    }
    if(p.contains(x, y)){
      return p;
    }
  }
  return null;
}

ArrayList<Place> pickAll(float x, float y){
  ArrayList<Place> placeList = new ArrayList<Place>();
  for (int i = 0; i < numPoints; i++) {
    Place p = places[i];
    if(p.population < minPopulationDisplay || p.density < minDensityDisplay){
      continue;
    }
    if(p.contains(x, y)){
      placeList.add(p);
    }
  }
  return placeList;
}


void keyPressed(){
  if (key == 'r') {
    scaleFactor = 1;
    translateX = 0.0;
    translateY = 0.0;
  }
//  if(key == CODED){
//    if(keyCode == UP){
//      if(minPopulationDisplay < 500000){
//        minPopulationDisplay = minPopulationDisplay * 2;
//      }
//    }
//    else if(keyCode == DOWN){
//      if(minPopulationDisplay >= 2){
//        minPopulationDisplay = minPopulationDisplay / 2;
//      }
//    }
//  }
//  redraw();
}

void mouseMoved(){
  selected_place=null;
  Place p = pick((mouseX-translateX)/scaleFactor, (mouseY-translateY)/scaleFactor);
  highlighted_places = pickAll((mouseX-translateX)/scaleFactor, (mouseY-translateY)/scaleFactor);
//  Place p = pick(mouseX, mouseY);
//  highlighted_places = pickAll(mouseX, mouseY);
  if(p == null){
    if(highlighted_place != null){
      highlighted_place.highlighted = false;
    }
    highlighted_place = null;
  }
  else{
    if(highlighted_place == null){
      p.highlighted = true;
      highlighted_place = p;
      //      println("x:"+mouseX+", y:"+mouseY + ", city:" + p.name);
    }else if(p.name != highlighted_place.name){
      p.highlighted = true;
      highlighted_place.highlighted = false;
      highlighted_place = p;
      //      println("x:"+mouseX+", y:"+mouseY + ", city:" + p.name);
    }
  }
}

void mouseClicked(){
  if(mouseButton == LEFT && highlighted_place != null){
    Place p = highlighted_place;
    p.selected = true;
    selected_place = p;
//    highlighted_place=null;
//    highlighted_places=null;
  }
//   if(p == null){
//    if(highlighted_place != null){
//      highlighted_place.highlighted = false;
//    }
//    highlighted_place = null;
//  }
//  else{
//    if(highlighted_place == null){
//      p.highlighted = true;
//      highlighted_place = p;
//      //      println("x:"+mouseX+", y:"+mouseY + ", city:" + p.name);
//    }else if(p.name != highlighted_place.name){
//      p.highlighted = true;
//      highlighted_place.highlighted = false;
//      highlighted_place = p;
//      //      println("x:"+mouseX+", y:"+mouseY + ", city:" + p.name);
//    }
//  }
}

void mouseDragged(MouseEvent e) {
  translateX += mouseX - pmouseX;
  translateY += mouseY - pmouseY;
//  for (int i = 0; i < numPoints; ++i) {
//    places[i].x=(places[i].x+translateX)/scaleFactor;
//    places[i].y=(places[i].y+translateY)/scaleFactor;
//  }
}

void mouseWheel(MouseEvent e) {
  translateX -= mouseX;
  translateY -= mouseY;
  float delta = e.getCount() > 0 ? 1.05 : e.getCount() < 0 ? 1.0/1.05 : 1.0;
  scaleFactor *= delta;
  translateX *= delta;
  translateY *= delta;
  translateX += mouseX;
  translateY += mouseY;
}

// Calculates the base-10 logarithm of a number
float log2 (float x) {
  return (log(x) / log(2));
}
