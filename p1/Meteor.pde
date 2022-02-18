class Meteor extends Explodable {

    // CONSTANTS
    float METEOR_RADIUS = 20;
    float METEOR_TRAIL_LENGTH = 50;
    int TRAIL_LENGTH = 100;
    final float EXPLOSION_RADIUS = 100;  // max size of the explosion
    final float EXPLOSION_EXPANSION_RATE = 2; // rate at which explosion expands
    final float GRAVITY_STRENGTH = 0.005;
    final float DRAG_STRENGTH = 0.001;

    // images
    PImage image;
    
    PVector velocity;

    PVector[] trail = new PVector[TRAIL_LENGTH];

    boolean addedLoopyness = false;

    // splitting
    boolean willSplit = false;
    float splitHeight = 0;
    boolean hasSplit = false;

    public Meteor(int x, int y, PImage image) {
        position = new PVector(x, y);
        // set trail
        for (int i = 0; i < TRAIL_LENGTH; i++) {
            trail[i] = new PVector(x,y);
        }
        // load in image
        this.image = image;
    }

    public void setInitialSpeed(GameState gs, Floor floor) {
        // need to make sure its heading towards the ground
        // magnitude of all of their speeds should be similar
        Random rand = new Random();

        float meteorHeight = getHeight(floor);

        // xDir positive or negative?
        boolean left = rand.nextBoolean();

        boolean hitsFloor = false;
        float randXDir = 0.0;
        float randYDir = 0.0;

        while (!hitsFloor) {
            // check that it intersects with floor
            // if not retry
            randXDir = rand.nextFloat();
            // x^2 + y^2 = 1
            randYDir = sqrt(1 - sq(randXDir));

            float maxTheta;

            // calculate max x and y
            if (left) {
                maxTheta = atan(position.x/(height-position.y));
            } else {
                maxTheta = atan((width-position.x)/(height-position.y));
            }

            // check new theta is less than this max
            float newTheta = atan(randXDir/randYDir);

            hitsFloor = newTheta < maxTheta;
        }

        // set direction - 
        randXDir = left ? randXDir * -1.0: randXDir;


        velocity = new PVector(randXDir, randYDir);    

        // set speed
        float speed = 0.1 + gs.getWave()*0.01;
        // speed +- 50%
        float multiplier = 0.5 + rand.nextFloat();
        speed = speed * multiplier;

        velocity.mult(speed);    
    }

    public void specifyInitialSpeed(PVector initial) {
        velocity = initial;
    }

    public void checkFloorCollision(Floor floor, City[] cities, Ballista[] ballistae) {
        if (collidingWithFloor(floor)) {
            checkCities(cities);
            checkBallistae(ballistae);

            explode();
            return;
        }
    }

    public void updateSpeed(float gravityForce, float dragForce) {
        if (exploded) return;

        // apply less gravity to meteors -> better for gameplay
        velocity.y += gravityForce*GRAVITY_STRENGTH;

        // force acts parallel (and opposite) to the direction of travel
        // magnitude of force is also dependent on the current speed

        PVector drag = velocity.copy().mult(-1 * dragForce * DRAG_STRENGTH);

        velocity.y += drag.y;
        velocity.x += drag.x;
    }

    public void move() {
        if (exploded) return;

        updateTrail();

        position.x += velocity.x;
        position.y += velocity.y;
    }

    public void updateTrail() {
        for (int i = TRAIL_LENGTH-1; i > 0; i--) {
            trail[i] = trail[i-1];
        }

        trail[0] = position.copy();
    }

    public void draw(ArrayList<Meteor> meteors, ArrayList<SmartMeteor> smartMeteors, ArrayList<Satellite> satellites, int thisIndex, GameState gamestate) {
        // don't draw if above screen
        if (position.y < -10) return;
        
        if (exploded) {
            if (!explosionAnimationCompleted) {
                drawExplosion();
                // blow up any other meteors this explosion impacts
                int numbBlownUp = checkObjectAndDestroyImpacted(meteors, thisIndex);

                gamestate.updateScore(numbBlownUp);

                numbBlownUp = checkSmartMeteors(smartMeteors);

                gamestate.updateScoreSM(numbBlownUp);

                numbBlownUp = checkObjectAndDestroyImpacted(satellites, -1);

                gamestate.updateScoreSatellite(numbBlownUp);
            }

            return;
        }

        if (!addedLoopyness && position.y > -10) {
            // add some x speed to make "more loopy"
            // position check prevents meteors going off screen
            if (velocity.x > 0 && position.x < width-200) {
                velocity.x += 0.3;
            } else if (velocity.x < 0 && position.x > 200) {
                velocity.x -= 0.3;
            }
            addedLoopyness = true;
        }

        if (willSplit && !hasSplit && checkSplitHeight()) {
            split(meteors);
        }

        drawTrail();
        image(image, position.x, position.y, METEOR_RADIUS, METEOR_RADIUS);
    }

    public void drawTrail() {
        for (int i = 0 ; i < TRAIL_LENGTH; i++) {
            stroke(255, 0, 0 );
            circle(trail[i].x, trail[i].y, METEOR_RADIUS / 10);
            stroke(255, 215, 0 );
            circle(trail[i].x+3, trail[i].y, METEOR_RADIUS / 20);
            stroke(255, 215, 0 );
            circle(trail[i].x-3, trail[i].y, METEOR_RADIUS / 20);
        }
    }


    public float getHeight(Floor floor) {
        return floor.getHeight() - position.y;
    }

    boolean collidingWithFloor(Floor floor) {
        int floorCollisionPosition = height - floor.getHeight() + 10;
        
        return position.y >= floorCollisionPosition;
    }

    void checkCities(City[] cities) {
        for (int i = 0; i < cities.length; i++) {
            if (cities[i].inImpactArea(position, EXPLOSION_RADIUS)) {
                cities[i].destroy();
            }
        }
    }

    void checkBallistae(Ballista[] ballistae) {
        for (int i = 0; i < ballistae.length; i++) {
            if (ballistae[i].inImpactArea(position, EXPLOSION_RADIUS)) {
                ballistae[i].disable();
            }
        }
    }

    int checkSmartMeteors(ArrayList<SmartMeteor> smartMeteors) {
        int result = checkObjectAndDestroyImpacted(smartMeteors, -1);

        for (SmartMeteor current: smartMeteors) {
            if (current.willCollideExplosion(EXPLOSION_RADIUS, explosionPosition)) {
                current.changeCourseToAvoid(EXPLOSION_RADIUS, explosionPosition);
            }
        }

        return result;
    }
    

    // code for splitting
    void setWillSplit(boolean willSplit) {
        this.willSplit = willSplit;
    }

    void setSplitHeight(float splitHeight) {
        this.splitHeight = splitHeight;
    }

    boolean checkSplitHeight() {
        return position.y > splitHeight;
    }

    void split(ArrayList<Meteor> meteors) {
        // create new meteor just with opposite x value for now
        Meteor newMeteor = new Meteor((int) position.x, (int) position.y, this.image);
        float xVel = velocity.x > 0 ? velocity.x * -1  - 10: velocity.x * -1 + 10;
        PVector initialVelocity = new PVector(velocity.x * -1, velocity.y);
        newMeteor.specifyInitialSpeed(initialVelocity);

        // add to array
        meteors.add(newMeteor);

        // set hasSplit to true
        hasSplit = true;
    }

}