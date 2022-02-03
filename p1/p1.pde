
import java.util.*;
// WORLD CONSTANTS
final int FLOOR_HEIGHT = 75;
final float FRICTION_CONSTANT = 0.5;

// BALLISTA CONSTANTS
final int numberOfBallistae = 3;
final int ammoPerBallistae = 10;

// MISSILE CONSTANTS
final int MISSILE_SIZE_X = 10;
final int MISSILE_SIZE_Y = 10;
final float MISSILE_MASS = 5;

// METEOR CONSTANTS
final int START_NUMBER_METEOR = 10;

// FORCE CONSTANTS
final float GRAVITY_CONSTANT = 0.2;
final float DRAG_CONSTANT = 0.01;
final float MIN_LAUNCH_FORCE = 50.0;
final float MAX_LAUNCH_FORCE = 100.0;
final float LAUNCH_FORCE_MULTIPLER = 0.1;

// CONTROL CONSTANTS
final char EXPLODE_KEY = ' ';


// Game Items
GameState gamestate;
Hud hud;
Floor floor;
Ballista[] ballistae = new Ballista[numberOfBallistae];
Ballista selectedBallista;

// Missiles
ArrayList<Missile> missiles = new ArrayList<>();
int toBlowUpIndex = 0;

// Meteors
ArrayList<Meteor> meteors = new ArrayList<>();

// Timing
long startClick = 0;
long clickLength = 0;
long endClick = 0;
boolean mouseDown = false;

// Initialise display and game elements
// NB Accessing displayWidth/Height pre setup() doesn't seem to work out
void setup() {
  size(1000,1000);
  
  // initialise the GameState.
  gamestate = new GameState(0, GRAVITY_CONSTANT, DRAG_CONSTANT);
  // initialise the Hud;
  hud = new Hud(width - 150, 50);
  // initialise floor
  floor = new Floor(FLOOR_HEIGHT, FRICTION_CONSTANT);
  // initialise cursor crosshair
  cursor(CROSS);
  // initialise the ballistae
  initialiseBallistae();
  // set initial selected ballista
  selectedBallista = ballistae[1];

  initialiseWave();  
}

// update and render
void draw() {
 background(0);
 
 clickLength = System.currentTimeMillis();
 
 hud.draw(gamestate.getWave(), clickLength - startClick, mouseDown);
 floor.draw();
 drawBallistae();
 drawLine();
 drawMissiles();
 drawMeteors();
}

void mousePressed() {
  // set startClickTime
  mouseDown = true;
  startClick = System.currentTimeMillis();
}

void mouseReleased() {
  endClick = System.currentTimeMillis();
  
  long diff = endClick-startClick;
   
  // use to calc strength of shot
  float launchForce = calcLaunchForce(diff);
  
  // check ammo
  if (!selectedBallista.decrementAmmo()) {
    // reset variables
    startClick = 0;
    clickLength = 0;
    mouseDown = false;
    return;  
  }

  shoot(launchForce);
  
  // reset variables
  startClick = 0;
  clickLength = 0;
  mouseDown = false;  
}

void keyPressed() {
  switch(key) {
    case '1':
      selectedBallista = ballistae[0];
      break;
    case '2':
      selectedBallista = ballistae[1];
      break;
    case '3':
      selectedBallista = ballistae[2];
      break;
    case EXPLODE_KEY:
      if (toBlowUpIndex < missiles.size()) {
        missiles.get(toBlowUpIndex++).explode();
      }
      break;
  }
}

void shoot(float launchForce) {
  // instantiate missile
  Missile newMiss = new Missile(
    (int) selectedBallista.position.x,
    (int) selectedBallista.position.y,
    MISSILE_SIZE_X, MISSILE_SIZE_Y, 
    MISSILE_MASS
  );
    
  // set dir and speed
  newMiss.setDirection(selectedBallista.position.x, selectedBallista.position.y);
  newMiss.setInitialSpeed(launchForce);
  
  // add new missile
  missiles.add(newMiss);
}

float calcLaunchForce(long diff) {
  float force = LAUNCH_FORCE_MULTIPLER * diff;
  
  if (MIN_LAUNCH_FORCE > force) return MIN_LAUNCH_FORCE;
  else if (MAX_LAUNCH_FORCE < force) return MAX_LAUNCH_FORCE;
  
  return force;
}

void initialiseBallistae() {
  for (int i = 0; i < numberOfBallistae; i++) {
    int xPos;

    switch(i) {
      case 0: xPos = 30; break;
      case 1: xPos = (width / 2) - 25 ; break;
      case 2: xPos = width - 30 - 50; break;
      default: xPos = width / 2;
    }
     
    int yPos = height - 100;
    
    ballistae[i] = new Ballista(xPos, yPos, ammoPerBallistae);
  }
}

void drawBallistae() {
  for (int i = 0; i < numberOfBallistae; i++) {
    ballistae[i].draw();
  }
}

void drawLine() {
  stroke(255, 0, 0);
  line(mouseX, mouseY, selectedBallista.position.x, selectedBallista.position.y);
}

void drawMissiles() {
  for (int i = 0; i < missiles.size(); i++) {
    // move missile if not exploded
    if (!missiles.get(i).exploded) {
      missiles.get(i).updateSpeed(gamestate.getGravity(), gamestate.getDrag(), floor);
      missiles.get(i).move();
    }
    
    missiles.get(i).draw();
  }
}

void drawMeteors() {
  for (int i = 0; i < meteors.size(); i++) {
    meteors.get(i).move();
    meteors.get(i).draw();
  }
}

Ballista getselectedBallista() {
  Ballista closest = ballistae[0];
  float closestDist = ballistae[0].cursorDistance();
  
  for (int i = 1; i < numberOfBallistae; i++) {
    float newDist = ballistae[i].cursorDistance();
    if (newDist < closestDist) {
      closest = ballistae[i];
      closestDist = newDist;
    }
  }
  
  return closest;
}

void initialiseWave() {

  int numbMeteorInWave = START_NUMBER_METEOR + (gamestate.getWave() * 5);

  for (int i = 0; i < numbMeteorInWave; i++) {
    Random rand = new Random();

    int xPos = rand.nextInt(width);
    // start off screen
    int yPos = 20;

    Meteor m = new Meteor(xPos, yPos);
    m.setInitialSpeed(gamestate, floor);

    meteors.add(m);
  }
}
