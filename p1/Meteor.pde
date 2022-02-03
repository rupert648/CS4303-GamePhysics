final class Meteor {

    // CONSTANTS
    float METEOR_RADIUS = 10;
    float METEOR_TRAIL_LENGTH = 50;
    
    PVector position;
    PVector velocity;

    public Meteor(int x, int y) {
        position = new PVector(x, y);
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
                maxTheta = atan(position.x/height);
            } else {
                maxTheta = atan((width-position.x)/height);
            }

            // check new theta is less than this max
            float newTheta = atan(randXDir/randYDir);

            hitsFloor = newTheta < maxTheta;
        }

        // set direction
        randXDir = left ? randXDir * -1.0 : randXDir;

        velocity = new PVector(randXDir, randYDir);    

        // set speed
        float speed = 5.0 + gs.getWave();
        // speed +- 20%
        float multiplier = 0.8 + rand.nextFloat() * 0.4;
        speed = speed * multiplier;
        
        velocity.mult(speed);    
    }

    public void move() {
        position.x += velocity.x;
        position.y += velocity.y;
    }

    public void draw() {
        fill(255, 0, 0);
        circle(position.x, position.y, METEOR_RADIUS);
    }

    public float getHeight(Floor floor) {
        return floor.getHeight() - position.y;
    }
}