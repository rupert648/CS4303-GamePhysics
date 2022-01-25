
import java.util.*;
// Constants
final int numberOfBallistae = 3;
final int ammoPerBallistae = 10;

GameState gamestate;
Hud hud;
Ballista[] ballistae = new Ballista[numberOfBallistae];

// Initialise display and game elements
// NB Accessing displayWidth/Height pre setup() doesn't seem to work out
void setup() {
  size(1000,1000);
  
  
  // initialise the GameState.
  gamestate = new GameState(0);
  // initialise the Hud;
  hud = new Hud(width - 150, 50);
  // initialise cursor crosshair
  cursor(CROSS);
  // initialise the ballistae
  initialiseBallistae();
  
}

// update and render
void draw() {
background(0);
 hud.draw(gamestate.getWave());
 drawBallistae();
 drawLine();
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
  // get closest ballista
  Ballista closest = getClosestBallista();

  stroke(255, 0, 0);
  line(mouseX, mouseY, closest.position.x, closest.position.y);
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
