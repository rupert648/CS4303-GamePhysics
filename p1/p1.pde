
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

// FORCE CONSTANTS
final float GRAVITY_CONSTANT = 0.5;
final float DRAG_CONSTANT = 0.01;
final float MIN_LAUNCH_FORCE = 50.0;
final float MAX_LAUNCH_FORCE = 100.0;
final float LAUNCH_FORCE_MULTIPLER = 0.1;


GameState gamestate;
Hud hud;
Floor floor;
Ballista[] ballistae = new Ballista[numberOfBallistae];
Ballista closestBallista;

long startClick = 0;
long intermediate = 0;
long endClick = 0;
boolean mouseDown = false;


ArrayList<Missile> missiles = new ArrayList<>();

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
  
}

// update and render
void draw() {
 background(0);
 // get closest ballista
 closestBallista = getClosestBallista();
 
 intermediate = System.currentTimeMillis();
 
 hud.draw(gamestate.getWave(), intermediate - startClick, mouseDown);
 floor.draw();
 drawBallistae();
 drawLine();
 drawMissiles();
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
  
  if (!closestBallista.decrementAmmo()) return;
  
  Missile newMiss = new Missile(
    (int) closestBallista.position.x,
    (int) closestBallista.position.y,
    MISSILE_SIZE_X, MISSILE_SIZE_Y, 
    MISSILE_MASS
  );
  
  // decrement ammo on Ballista
  
  // set dir
  newMiss.setDirection(closestBallista.position.x, closestBallista.position.y);
  newMiss.setInitialSpeed(launchForce);
  
  // add new missile
  missiles.add(newMiss);
  
  // reset variables
  startClick = 0;
  intermediate = 0;
  mouseDown = false;  
}

float calcLaunchForce(long diff) {
  float force = LAUNCH_FORCE_MULTIPLER * diff;
  
  if (MIN_LAUNCH_FORCE > force) return MIN_LAUNCH_FORCE;
  else if (MAX_LAUNCH_FORCE < force) return MAX_LAUNCH_FORCE;
  
  return force;
}

void initialiseBallistae() {
  for (int i = 0; i < numberOfBallistae; i++) {
    int xPos = (width / (i+1)) - (i == 0 ? 350: 50);
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
  line(mouseX, mouseY, closestBallista.position.x, closestBallista.position.y);
}

void drawMissiles() {
  // TODO: add check that not above screen (remove if so)
  for (int i = 0; i < missiles.size(); i++) {
    // move missile
    missiles.get(i).updateSpeed(gamestate.getGravity(), gamestate.getDrag(), floor);
    missiles.get(i).move();
    
    missiles.get(i).draw();
  }
}

Ballista getClosestBallista() {
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
