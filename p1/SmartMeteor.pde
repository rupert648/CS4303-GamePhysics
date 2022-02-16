final class SmartMeteor extends Meteor {
    public SmartMeteor(int x, int y, PImage image) {
        position = new PVector(x, y);
        // set trail
        for (int i = 0; i < TRAIL_LENGTH; i++) {
            trail[i] = new PVector(x,y);
        }
        // load in image
        this.image = image;
    }
}