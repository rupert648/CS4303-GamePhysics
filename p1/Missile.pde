final class Missile extends Explodable {
  
  // constants
  final float LAUNCH_TIME = 1.6;  // the time for which the missile is being launched from the slingshot
  
  // The missile is represented by another handsome rectangle
  // the position field indicates the top-left of that rectangle.  
  int missileWidth, missileHeight ;
  float mass ;
  
  // movement
  PVector direction;
  PVector velocity;

  // image
  PImage image;

  public Missile(int x, int y, int missileWidth, int missileHeight, float mass, PImage image) {
    position = new PVector(x, y) ;
    this.missileWidth = missileWidth ;
    this.missileHeight = missileHeight ;
    this.mass = mass;
    this.image = image;
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
  
  void draw(ArrayList<Meteor> meteors, Satellite[] satellites, GameState gamestate) {
    if (exploded) {
      if (!explosionAnimationCompleted) {
        drawExplosion();
        int numbBlownUp = checkMeteorsAndDestroyImpacted(meteors);

        gamestate.updateScore(numbBlownUp);

        // TODO: add check for smart meteors
        checkSmartMeteors(smartMeteors);

        // TODO: add score for these
        checkSatellitesAndDestroyImpacted(satellites);
      }

      return;
    };

    float ang = atan2(velocity.x, velocity.y);

    // rotate to face direction of travel
    pushMatrix();
    imageMode(CENTER);
    translate(position.x, position.y);
    rotate(-ang-PI);
    translate(-position.x, -position.y);
    image(image, position.x, position.y, missileWidth, missileHeight);
    popMatrix();
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
    position.add(velocity);
    
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
        // prevents weird mechanics
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

    int checkMeteorsAndDestroyImpacted(ArrayList<Meteor> meteors) {
        // TODO: only check those on screen for collision
        int numbBlownUp = 0;
        for (int i = 0; i < meteors.size(); i++) {
            Meteor current = meteors.get(i);
            // comparisons cheaper than calculating distance
            // better to check OS than to calc distance
            boolean onScreen = current.position.x > 0 &&
                current.position.x < width &&
                current.position.y > 0;

            if (onScreen &&
                !current.isExploded() &&
                current.inImpactArea(position, explosionCurrentRadius)
            ) {
                current.explode();
                numbBlownUp++;
            }
        }

        return numbBlownUp;
    }

    void checkSmartMeteors(ArrayList<SmartMeteor> sMeteors) {
        int numbBlownUp = 0;
        for (int i = 0; i < sMeteors.size(); i++) {
            SmartMeteor current = sMeteors.get(i);

            boolean onScreen = current.position.x > 0 &&
                current.position.x < width &&
                current.position.y > 0;

            if (onScreen &&
                !current.isExploded() &&
                // have to hit within the inner half of the explosion
                current.inImpactArea(position, EXPLOSION_RADIUS)) {
                    current.explode();
                    break;
                }

            if (current.willCollideExplosion(EXPLOSION_RADIUS, explosionPosition)) {
                current.changeCourseToAvoid(EXPLOSION_RADIUS, explosionPosition);
            }

        }
    }

    void checkSatellitesAndDestroyImpacted(Satellite[] satellites) {
        for (int i = 0; i < satellites.length; i++) {
            if (satellites[i] != null && satellites[i].inImpactArea(position, explosionCurrentRadius)) {
            satellites[i].explode();
            }
        }
    }
}
