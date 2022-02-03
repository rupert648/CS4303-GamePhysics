final class Missile {
  
  // constants
  final float LAUNCH_TIME = 1.6;  // the time for which the missile is being launched from the slingshot
  final float EXPLOSION_RADIUS = 60;  // max size of the explosion
  final float EXPLOSION_EXPANSION_RATE = 2; // rate at which explosion expands
  
  // The missile is represented by another handsome rectangle
  // the position field indicates the top-left of that rectangle.  
  PVector position ;
  int missileWidth, missileHeight ;
  float mass ;
  
  // movement
  PVector direction;
  PVector speed;

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
    
    // direction is used to calc initial speed (but it is just the speed normalised)
    direction = new PVector(distX, distY);  
    direction.normalize();
  }

  void setInitialSpeed(float initialForce) {
    // force will occur in the direction we are aiming
    // a = f / m
    float a = initialForce / mass ;
    
    // v = a * t
    float speedIncrease = a * LAUNCH_TIME;
    
    speed = direction.copy();
    speed = speed.mult(speedIncrease);
  }

  public void setExplosionLocation() {
    explosionPosition = position.copy();
  }
  
  // getters
  int getX() {return (int)position.x ;}
  int getY() {return (int)position.y ;}
  // The missile is displayed as a rectangle
  void draw() {
    if (exploded) {
      if (!explosionAnimationCompleted) {
        drawExplosion();
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
      // if we have bounced a lot, don't update the speed anymore
      // prevents gravity affecting ball once on the ground
      if (speed.y == 0) {
        computeFriction(floor);      
        return;
      };
    };
    
    if (collidingWithWall()) bounceWall();
   
    // update due to gravity
    speed.y += gravityForce;
    
    // force acts parallel (and opposite) to the direction of travel
    // magnitude of force is also dependent on the current speed
    PVector drag = speed.copy().mult(-1 * dragForce);
    
    speed.y += drag.y;
    speed.x += drag.x;
    
    
    // update direction for future use
    direction = speed.copy();
    direction.normalize();
  }
  
  void setSpeed(float x, float y) {
    speed.y = y;
    speed.x = x;
  }
  
  // handle movement. Returns true if not out of play area
  // What about collision detection with enemies?
  boolean move() {
    position.y += ( speed.y );
    position.x += ( speed.x );
    
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
    // if speed.y < certain amount then stop bouncing
    if (speed.y < 0.05) {
      speed.y = 0;
      return;
    }
    // trying to reverse y
    speed.y = speed.y * -1;
  }
  
  void bounceWall() {
    // if very low speed to stop odd behaviour just set to 0
    if (speed.x < 0.05 && speed.x > 0) { speed.x = 0; return; }
    else if (speed.x > -0.05 && speed.x < 0) { speed.x = 0; return; }
    
    // reverse speed
    speed.x = speed.x * -1;
  }
  
  void computeFriction(Floor floor) {
    if (speed.x == 0) return;
    // if speed very low stop ball
    else if (speed.x < 0.05 && speed.x > 0) { speed.x = 0; return; }
    else if (speed.x > -0.05 && speed.x < 0) { speed.x = 0; return; }
    // friction force constant no matter mass
    // proportional to frictional constant of floor
    
    // acceleration is in opposite direction to x speed
    float a = floor.getMu();
    // change in velocity = a * some time difference
    float accelTime = 0.1;
    float vDiff = accelTime * a;
    
    if (speed.x < 0) {
      speed.x += vDiff;
    } else {
      speed.x -= vDiff;
    }
       
  }

  void explode() {
    exploded = true;
    setExplosionLocation();
  }
}
