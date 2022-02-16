final class Satellite {
    final int HORIZONTAL_VEL = 1;
    final int SAT_LENGTH = 50;
    final int SAT_HEIGHT = 25;
    final float EXPLOSION_RADIUS = 100;  // max size of the explosion
    final float EXPLOSION_EXPANSION_RATE = 2; // rate at which explosion expands

    PVector position;
    PVector velocity;

    // explosion
    PVector explosionPosition;
    boolean isDestroyed = false;
    boolean explosionAnimationCompleted = false;
    float explosionCurrentRadius = 0;

    public Satellite(int x, int y) {
        position = new PVector(x, y);
        velocity = new PVector(HORIZONTAL_VEL, 0);
    }
    
    void draw(ArrayList<Meteor> meteors, GameState gamestate) {
        if (isDestroyed) {
            if (!explosionAnimationCompleted) {
                drawExplosion();
                // blow up any other meteors this explosion impacts
                int numbBlownUp = checkMeteorsAndDestroyImpacted(meteors);

                gamestate.updateScore(numbBlownUp);
            }

            return;
        }
        if (position.x > width) destroy();

        fill(0, 255, 0);
        rect(position.x, position.y, SAT_LENGTH, SAT_HEIGHT);
        noFill();

        attemptToFire();
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

    // handle movement. Returns true if not out of play area
    // What about collision detection with enemies?
    void move() {
        if (isDestroyed) return;
        position.add(velocity);
    }

    boolean attemptToFire() {
        if (isDestroyed || position.x < 0) return false;
        // one in 500 chance to fire each frame
        int val = (int) random(0, 501);
        return val == 50;
    }

    void fire(ArrayList<Meteor> meteors, PImage meteorImg) {
        Meteor newMeteor = new Meteor((int) position.x, (int) position.y, meteorImg);
        // give small initial downwards velocity
        PVector initialVelocity = new PVector(0, 0.2);
        newMeteor.specifyInitialSpeed(initialVelocity);

        meteors.add(newMeteor);
    }

    void destroy() {
        isDestroyed = true;
        setExplosionLocation();
    }

    void setExplosionLocation() {
        explosionPosition = position.copy();
    }

    int checkMeteorsAndDestroyImpacted(ArrayList<Meteor> meteors) {
        int numbBlownUp = 0;
        for (int i = 0; i < meteors.size(); i++) {
            Meteor current = meteors.get(i);
            // comparisons cheaper than calculating distance
            // better to check OS than to calc distance
            boolean onScreen = current.position.x > 0 &&
                current.position.x < width &&
                current.position.y > 0;

            if (onScreen &&
                !meteors.get(i).isDestroyed &&
                meteors.get(i).inImpactArea(position, explosionCurrentRadius)
            ) {
                meteors.get(i).destroy();
                numbBlownUp++;
            }
        }

        return numbBlownUp;
    }


    boolean inImpactArea(PVector missilePos, float explosionRadius) {
        // if in circle around missilePos of explosion Radius then destroy it
        float distance = missilePos.dist(position);
        return distance < explosionRadius;
    }
}