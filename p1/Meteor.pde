final class Meteor {

    // CONSTANTS
    float METEOR_RADIUS = 20;
    float METEOR_TRAIL_LENGTH = 50;
    int TRAIL_LENGTH = 100;
    final float EXPLOSION_RADIUS = 100;  // max size of the explosion
    final float EXPLOSION_EXPANSION_RATE = 2; // rate at which explosion expands

    // images
    PImage image;
    
    PVector position;
    PVector velocity;

    PVector[] trail = new PVector[TRAIL_LENGTH];

    // explosion
    PVector explosionPosition;
    boolean isDestroyed = false;
    boolean explosionAnimationCompleted = false;
    float explosionCurrentRadius = 0;

    public Meteor(int x, int y) {
        position = new PVector(x, y);
        // set trail
        for (int i = 0; i < TRAIL_LENGTH; i++) {
            trail[i] = new PVector(x,y);
        }
        // load in image
        image = loadImage("../images/meteor.png");
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
        // add horizontal speed to account for gravity
        // this makes them more "loopy"
        if (left) {
            if (position.x > height / 2) {
                randXDir -= 3;
            }
        } else {
            if (position.x < height / 2) {
                randXDir += 3;
            }
        }

        velocity = new PVector(randXDir, randYDir);    

        // set speed
        float speed = 0.1 + gs.getWave()*0.01;
        // speed +- 50%
        float multiplier = 0.5 + rand.nextFloat();
        speed = speed * multiplier;

        velocity.mult(speed);    
    }

    public void checkFloorCollision(Floor floor, City[] cities, Ballista[] ballistae) {
        if (collidingWithFloor(floor)) {
            checkCities(cities);
            checkBallistae(ballistae);

            destroy();
            return;
        }
    }

    public void updateSpeed(float gravityForce, float dragForce) {
        if (isDestroyed) return;

        // apply less gravity to meteors -> better for gameplay
        velocity.y += gravityForce*0.01;

        // force acts parallel (and opposite) to the direction of travel
        // magnitude of force is also dependent on the current speed

        // TODO: mess with drag coefficients to make it fun for meteors
        PVector drag = velocity.copy().mult(-1 * dragForce * 0.01);

        velocity.y += drag.y;
        velocity.x += drag.x;
    }

    public void move() {
        if (isDestroyed) return;

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

    public void draw(ArrayList<Meteor> meteors, int thisIndex) {
        if (isDestroyed) {
            if (!explosionAnimationCompleted) {
                drawExplosion();
                // blow up any other meteors this explosion impacts
                checkMeteorsAndDestroyImpacted(meteors, thisIndex);
            }

            return;
        }

        drawTrail();
        image(image, position.x, position.y, METEOR_RADIUS, METEOR_RADIUS);

        
    }

    public void drawTrail() {
        for (int i = 0 ; i < TRAIL_LENGTH; i++) {
            circle(trail[i].x, trail[i].y, METEOR_RADIUS / 10);
            circle(trail[i].x+3, trail[i].y, METEOR_RADIUS / 20);
            circle(trail[i].x-3, trail[i].y, METEOR_RADIUS / 20);
        }
    }

    void drawExplosion() {
        if (explosionCurrentRadius >= EXPLOSION_RADIUS) {
            explosionAnimationCompleted = true;
            return;
        }

        explosionCurrentRadius += EXPLOSION_EXPANSION_RATE;
        fill(0, 255, 0);
        circle(explosionPosition.x, explosionPosition.y, explosionCurrentRadius);
    }

    public float getHeight(Floor floor) {
        return floor.getHeight() - position.y;
    }

    boolean collidingWithFloor(Floor floor) {
        int floorCollisionPosition = height - floor.getHeight() + 10;
        
        return position.y >= floorCollisionPosition;
    }

    boolean inImpactArea(PVector missilePos, float explosionRadius) {
        // if in circle around missilePos of explosion Radius then destroy it
        float distance = missilePos.dist(position);
        return distance < explosionRadius;
    }

    void destroy() {
        isDestroyed = true;
        setExplosionLocation();
    }

    void setExplosionLocation() {
        explosionPosition = position.copy();
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

    int checkMeteorsAndDestroyImpacted(ArrayList<Meteor> meteors, int thisIndex) {
        int numbBlownUp = 0;
        for (int i = 0; i < meteors.size(); i++) {
            // skip yourself
            if (i == thisIndex) continue;

            if (meteors.get(i).inImpactArea(position, explosionCurrentRadius)) {
                meteors.get(i).destroy();
                numbBlownUp++;
            }
        }

        return numbBlownUp;
    }

}