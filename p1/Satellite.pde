final class Satellite extends Explodable {
    final int HORIZONTAL_VEL = 1;
    final int SAT_LENGTH = 50;
    final int SAT_HEIGHT = 25;
  
    PVector velocity;

    public Satellite(int x, int y) {
        position = new PVector(x, y);
        velocity = new PVector(HORIZONTAL_VEL, 0);
    }
    
    void draw(ArrayList<Meteor> meteors, GameState gamestate) {
        if (exploded) {
            if (!explosionAnimationCompleted) {
                drawExplosion();
                // blow up any other meteors this explosion impacts
                // TODO: expand to check smartMeteors
                int numbBlownUp = checkObjectAndDestroyImpacted(meteors, -1);

                gamestate.updateScore(numbBlownUp);
            }

            return;
        }
        if (position.x > width) explode();

        fill(0, 255, 0);
        rect(position.x, position.y, SAT_LENGTH, SAT_HEIGHT);
        noFill();

        attemptToFire();
    }

    // handle movement. Returns true if not out of play area
    // What about collision detection with enemies?
    void move() {
        if (exploded) return;
        position.add(velocity);
    }

    boolean attemptToFire() {
        if (exploded || position.x < 0) return false;
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
}