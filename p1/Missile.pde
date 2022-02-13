final class Missile {
  
  // constants
  final float LAUNCH_TIME = 1.6;  // the time for which the missile is being launched from the slingshot
  final float EXPLOSION_RADIUS = 100;  // max size of the explosion
  final float EXPLOSION_EXPANSION_RATE = 4; // rate at which explosion expands
  
  // The missile is represented by another handsome rectangle
  // the position field indicates the top-left of that rectangle.  
  PVector position ;
  int missileWidth, missileHeight ;
  float mass ;
  
  // movement
  PVector direction;
  PVector velocity;

  // explosion
  PVector explosionPosition;
  boolean exploded = false;
  boolean explosionAnimationCompleted = false;
  float explosionCurrentRadius = 0;

  public Missile(int x, int y, int missileWidth, int missileHeight, float mass) {
    position = new PVector(x, y) ;
    this.missileWidth = missileWidth ;
    this.missileHeight = missileHeight ;
    this.mass = mass;
  }
  
  public void setDirection(float closestBallistaX, float closestBallistaY) {
    float distX = mouseX - closestBallistaX ;
    float distY = mouseY - closestBallistaY ;
    
    // direction is used to calc initial velocity (but it is just the velocity normalised)
    direction = new PVector(distX, distY);  
    direction.normalize();
  }

  void setInitialSpeed(float initialForce) {
    // force will occur in the direction we are aiming
    // a = f / m
    float a = initialForce / mass ;
    
    // v = a * t
    float speedIncrease = a * LAUNCH_TIME;
    
    velocity = direction.copy();
    velocity = velocity.mult(speedIncrease);
  }

  public void setExplosionLocation() {
    explosionPosition = position.copy();
  }
  
  // getters
  int getX() {return (int)position.x ;}
  int getY() {return (int)position.y ;}

  
  void draw(ArrayList<Meteor> meteors, GameState gamestate) {
    if (exploded) {
      if (!explosionAnimationCompleted) {
        drawExplosion();
        int numbBlownUp = checkMeteorsAndDestroyImpacted(meteors);

        gamestate.updateScore(numbBlownUp);
      }

      return;
    };


    fill(200) ;
    rect(position.x, position.y, missileWidth, missileHeight) ;
  }

  void drawExplosion() {
    // check if reached max size
    if (explosionCurrentRadius >= EXPLOSION_RADIUS) {
      explosionAnimationCompleted = true;
      return;
    }

    explosionCurrentRadius += EXPLOSION_EXPANSION_RATE;
    fill(255, 255, 0);
    circle(explosionPosition.x, explosionPosition.y, explosionCurrentRadius);

  }
  
  void updateSpeed(float gravityForce, float dragForce, Floor floor) {
    
    // check collision with floor
    if (collidingWithFloor(floor)) {
      bounceFloor();
      // if we have bounced a lot, don't update the velocity anymore
      // prevents gravity affecting ball once on the ground
      if (velocity.y == 0) {
        computeFriction(floor);      
        return;
      };
    };
    
    if (collidingWithWall()) bounceWall();
   
    // update due to gravity
    velocity.y += gravityForce;
    
    // force acts parallel (and opposite) to the direction of travel
    // magnitude of force is also dependent on the current velocity
    PVector drag = velocity.copy().mult(-1 * dragForce);
    

    velocity.add(drag);
  }
  
  void setSpeed(float x, float y) {
    velocity.y = y;
    velocity.x = x;
  }
  
  // handle movement. Returns true if not out of play area
  // What about collision detection with enemies?
  boolean move() {
    position.y += ( velocity.y );
    position.x += ( velocity.x );
    
    return true;
  }  
  
  boolean collidingWithFloor(Floor floor) {
    int floorCollisionPosition = height - floor.getHeight() + 10;
    
    return position.y >= floorCollisionPosition;
  }
  
  boolean collidingWithWall() {
    return position.x >= width || position.x <= 0;
  }
  
  void bounceFloor() {
    // if velocity.y < certain amount then stop bouncing
    if (velocity.y < 0.05) {
      velocity.y = 0;
      return;
    }
    // trying to reverse y
    velocity.y = velocity.y * -1;
  }
  
  void bounceWall() {
    // if very low velocity to stop odd behaviour just set to 0
    if (velocity.x < 0.05 && velocity.x > 0) { velocity.x = 0; return; }
    else if (velocity.x > -0.05 && velocity.x < 0) { velocity.x = 0; return; }
    
    // reverse velocity
    velocity.x = velocity.x * -1;
  }
  
  void computeFriction(Floor floor) {
    if (velocity.x == 0) return;
    // if velocity very low stop ball
    else if (velocity.x < 0.05 && velocity.x > 0) { velocity.x = 0; return; }
    else if (velocity.x > -0.05 && velocity.x < 0) { velocity.x = 0; return; }
    // friction force constant no matter mass
    // proportional to frictional constant of floor
    
    // acceleration is in opposite direction to x velocity
    float a = floor.getMu();
    // change in velocity = a * some time difference
    float accelTime = 0.1;
    float vDiff = accelTime * a;
    
    if (velocity.x < 0) {
      velocity.x += vDiff;
    } else {
      velocity.x -= vDiff;
    }
       
  }

  void explode() {
    exploded = true;
    setExplosionLocation();
  }

  int checkMeteorsAndDestroyImpacted(ArrayList<Meteor> meteors) {
    int numbBlownUp = 0;
    for (int i = 0; i < meteors.size(); i++) {
      if (meteors.get(i).inImpactArea(position, explosionCurrentRadius)) {
        meteors.get(i).destroy();
        numbBlownUp++;
      }
    }

    return numbBlownUp;
  }
}
