final class Satellite extends Explodable {
    final int HORIZONTAL_VEL = 1;
    final int SAT_LENGTH = 75;
    final int SAT_HEIGHT = 40;
  
    PVector velocity;
    PImage image;

    boolean isSatellite;

    public Satellite(int x, int y, boolean isSatellite, PImage image) {
        super.position = new PVector(x, y);
        this.isSatellite = isSatellite;
        this.velocity = new PVector(isSatellite ? HORIZONTAL_VEL : HORIZONTAL_VEL * -1, 0);
        this.image = image;
    }
    
    void draw(ArrayList<Meteor> meteors, GameState gamestate) {
        if (exploded) {
            if (!explosionAnimationCompleted) {
                drawExplosion();
                // blow up any other meteors this explosion impacts
                int numbBlownUp = checkObjectAndDestroyImpacted(meteors, -1);

                gamestate.updateScore(numbBlownUp);
            }

            return;
        }
        if (isSatellite && position.x > width) explode();
        else if (!isSatellite && position.x < 0) explode();

        image(image, position.x, position.y, SAT_LENGTH, SAT_HEIGHT);

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