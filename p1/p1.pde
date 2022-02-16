
import java.util.*;
// WORLD CONSTANTS
final int FLOOR_HEIGHT = 75;
final float FRICTION_CONSTANT = 0.5;

// BALLISTA CONSTANTS
final int NUMB_BALLISTA = 3;
final int BALLISTA_MAX_AMMO = 10;

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

// CITY CONSTANTS
final int START_NUMB_CITIES = 6;

// CONTROL CONSTANTS
final char EXPLODE_KEY = ' ';

// Game Items
PImage background;
GameState gamestate;
Hud hud;
TextOverlay textOverlay;
Floor floor;
Ballista[] ballistae = new Ballista[NUMB_BALLISTA];
Ballista selectedBallista;

// Missiles
ArrayList<Missile> missiles = new ArrayList<>();
int toBlowUpIndex = 0;
int indexToBlowUpTo = 0;

// Meteors
ArrayList<Meteor> meteors = new ArrayList<>();  // array list allows easy splitting

// cities
City[] cities = new City[START_NUMB_CITIES];

// Timing
long startClick = 0;
long clickLength = 0;
long endClick = 0;
boolean mouseDown = false;

// blowing stuff up
boolean blowingUpMissiles = false;
int FRAMES_BETWEEN_EXPLOSIONS = 10;
int framesSinceLast = 0;

// images
PImage meteorImg;


// Initialise display and game elements
// NB Accessing displayWidth/Height pre setup() doesn't seem to work out
void setup() {
  size(1000,1000);
  // load background img
  background = loadImage("../images/Background.png");
  
  // initialise the GameState.
  gamestate = new GameState(0, GRAVITY_CONSTANT, DRAG_CONSTANT);
  // initialise the Hud;
  hud = new Hud(width - 150, 50);
  textOverlay = new TextOverlay();

  loadImages();

  // initialise floor
  floor = new Floor(FLOOR_HEIGHT, FRICTION_CONSTANT);
  // initialise cursor crosshair
  cursor(CROSS);
  // initialise the ballistae
  initialiseBallistae();
  // set initial selected ballista
  selectedBallista = ballistae[1];
  // initialise cities
  initialiseCities();

  initialiseWave();  
}

// update and render
void draw() {
  // reset background to remove previous frame drawings
  background(background);

  if (textOverlay.displaying) {
    if (!textOverlay.checkDisplay()) {
      // finish running if game finished
      if (allCitiesDestroyed()) System.exit(0);
      // once stopped displaying, launch the new wave
      nextWave();
    } else {
      textOverlay.draw();
      floor.draw();
      drawCities();
      drawMeteors();
      drawBallistae();  
    }

    return;
  }

  // perform check every 30 frames
  if (frameCount % 30 == 0 && allCitiesDestroyed()) {
    textOverlay.setStartTime();
    textOverlay.setText("You Lost");

    return;
  }

  // perform check every 30 frames
  if (frameCount % 10 == 0 && waveFinished()) {
    textOverlay.setStartTime();
    textOverlay.setText("Wave " + Integer.toString(gamestate.getWave()+2));
    // update score to respect remainining cities
    updateScoreForSurvivingCities();

    gamestate.checkIfCanAddNewCity(cities);

    return;
  }
  
  // standard wave rendering
  clickLength = System.currentTimeMillis();
  
  hud.draw(
    gamestate.getWave(),
    gamestate.getScore(),
    clickLength - startClick,
    mouseDown,
    selectedBallista.isOutOfAmmo()
  );
  floor.draw();
  drawCities();
  drawLine();
  drawMissiles();
  drawMeteors();
  drawBallistae();


  if (blowingUpMissiles) {
    blowUpMissilesOnScreen();
  }
}

void mousePressed() {
  // no clicking intermission
  if (textOverlay.displaying) return;

  // set startClickTime
  mouseDown = true;
  startClick = System.currentTimeMillis();
}

void mouseReleased() {
  // no clicking intermission
  if (textOverlay.displaying) return;

  endClick = System.currentTimeMillis();
  
  long diff = endClick-startClick;
   
  // use to calc strength of shot
  float launchForce = calcLaunchForce(diff);
  
  // check ammo or disabled
  if (selectedBallista.isDisabled() || !selectedBallista.decrementAmmo()) {
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
  // no clicking whilst text on screen
  if (textOverlay.displaying) return;

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
      blowingUpMissiles = true;
      // blow up all current missiles
      indexToBlowUpTo = missiles.size() - 1;
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
  for (int i = 0; i < NUMB_BALLISTA; i++) {
    int xPos;

    switch(i) {
      case 0: xPos = 30; break;
      case 1: xPos = (width / 2) - 25 ; break;
      case 2: xPos = width - 30 - 50; break;
      default: xPos = width / 2;
    }
     
    int yPos = height - 100;
    
    ballistae[i] = new Ballista(xPos, yPos, BALLISTA_MAX_AMMO);
  }
}

void initialiseCities() {
  int yPos = height - 75;

  for (int i = 0; i < START_NUMB_CITIES; i++) {
    int xPos = (width * (i+1)) / START_NUMB_CITIES;
    xPos -= 100;
    cities[i] = new City(xPos, yPos);
  }

}

void drawBallistae() {
  for (int i = 0; i < NUMB_BALLISTA; i++) {
    ballistae[i].draw();
  }
}

void drawCities() {
  for (int i = 0; i < START_NUMB_CITIES; i++) {
    cities[i].draw();
  }
}

void drawLine() {
  if (selectedBallista.disabled) stroke(255, 0, 0);
  else stroke(0, 255, 0);
  line(mouseX, mouseY, selectedBallista.position.x, selectedBallista.position.y);
}

void drawMissiles() {
  for (int i = 0; i < missiles.size(); i++) {
    // move missile if not exploded
    if (!missiles.get(i).exploded) {
      missiles.get(i).updateSpeed(gamestate.getGravity(), gamestate.getDrag(), floor);
      missiles.get(i).move();
    }
    
    missiles.get(i).draw(meteors, gamestate);
  }
}

void drawMeteors() {
  for (int i = 0; i < meteors.size(); i++) {
    meteors.get(i).checkFloorCollision(floor, cities, ballistae);

    meteors.get(i).updateSpeed(gamestate.getGravity(), gamestate.getDrag());

    meteors.get(i).move();
    
    meteors.get(i).draw(meteors, i);
  }
}

void initialiseWave() {

  int numbMeteorInWave = START_NUMBER_METEOR + (gamestate.getWave() * 5);

  for (int i = 0; i < numbMeteorInWave; i++) {
    Random rand = new Random();

    int xPos = rand.nextInt(width);
    
    // give random start pos above the screen
    // therefore gives "impression" of coming in spread out
    // rather than all at once
    int yPosAboveScreen = rand.nextInt(1000);
    int yPos = yPosAboveScreen * -1;

    Meteor m = new Meteor(xPos, yPos, meteorImg);
    m.setInitialSpeed(gamestate, floor);

    // only after 2nd wave
    if (gamestate.getWave() > 1) {
      // randomise whether meteor will split
      // 1 in 5 chance
      boolean willSplit = ((int) random(0, 5)) == 1;
      m.setWillSplit(willSplit);

      // random height of split
      float val = 500;
      if (willSplit) {
        val = random(0, height-500);
        m.setSplitHeight(val);
        System.out.println(val);
      }
    }

    meteors.add(m);
  }
}

void blowUpMissilesOnScreen() {
  if (framesSinceLast >= FRAMES_BETWEEN_EXPLOSIONS) {
     // blow next boi up

      if (toBlowUpIndex <= indexToBlowUpTo && missiles.size() != 0) {
        missiles.get(toBlowUpIndex).explode();

        framesSinceLast = 0;
        toBlowUpIndex++;
      } else if (toBlowUpIndex == indexToBlowUpTo) {
        // have blown up all missiles so far
        framesSinceLast = 0;
        blowingUpMissiles = false;
      }
   }

   framesSinceLast++;
}

boolean waveFinished() {
  
  // check all are destroyed
  for (int i = 0; i < meteors.size(); i++) {
    Meteor current = meteors.get(i);
    if (!current.isDestroyed) {
      return false;
    }
  }

  return true;
}

void resetVariables() {
  missiles = new ArrayList<>();
  meteors = new ArrayList<>();
  indexToBlowUpTo = 0;
  toBlowUpIndex = 0;

  // reset ammo
  for (int i = 0; i < NUMB_BALLISTA; i++) {
    ballistae[i].setAmmo(BALLISTA_MAX_AMMO);
    // enable ballistae
    ballistae[i].undisable();
  }
}

void nextWave() {
  resetVariables();
  // increment wave
  gamestate.incWave();
  initialiseWave();
}

boolean allCitiesDestroyed() {
  for (int i = 0; i < START_NUMB_CITIES; i++) {
    if (!cities[i].destroyed) return false;
  }

  return true;
}

void updateScoreForSurvivingCities() {
  int surviving = 0;
  for (int i = 0; i < START_NUMB_CITIES; i++) {
    if (!cities[i].destroyed) surviving++;
  }

  gamestate.updateScoreCities(surviving);
}

void loadImages() {
  meteorImg = loadImage("../images/meteor.png");
}