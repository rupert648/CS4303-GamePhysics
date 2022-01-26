final class Missile {
  
  // constants
  final float LAUNCH_TIME = 1.6;  // the time for which the missile is being launched from the slingshot
  
  // The missile is represented by another handsome rectangle
  // the position field indicates the top-left of that rectangle.  
  PVector position ;
  int missileWidth, missileHeight ;
  float mass ;
  
  // movement
  PVector direction;
  PVector speed;
  
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
  
  // getters
  int getX() {return (int)position.x ;}
  int getY() {return (int)position.y ;}
  // The missile is displayed as a rectangle
  void draw() {
    fill(200) ;
    rect(position.x, position.y, missileWidth, missileHeight) ;
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
  
  void updateSpeed(float gravityForce, float dragForce, Floor floor) {
    
    // check collision with floor
    if (collidingWithFloor(floor)) bounce();
    if (speed.y == 0) return;
    
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
  
  void bounce() {
    // if speed.y < certain amount then stop bouncing
    if (speed.y < 0.05) {
      speed.y = 0;
      return;
    }
    // trying to reverse y
    speed.y = speed.y * -1;
  }
}