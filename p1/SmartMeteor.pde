final class SmartMeteor extends Meteor {
    float gravityForce;
    float dragForce;

    public SmartMeteor(int x, int y, PImage image, float gravityForce, float dragForce) {
        super(x, y, image);
        this.gravityForce = gravityForce;
        this.dragForce = dragForce;
    }

    public boolean willCollideExplosion(float radius, PVector explosionPos) {
        // simulate 25 frames ahead
        int framesToCheck = 25;
        PVector positionCopy = position.copy();
        PVector velocityCopy = velocity.copy();

        boolean mayBeImpacted = false;

        for (int i = 0; i < framesToCheck; i++) {
            velocityCopy = simulateUpdateSpeed(velocityCopy);
            positionCopy = simulateMove(positionCopy, velocityCopy);

            float distance = positionCopy.dist(explosionPos);
            if (distance < radius) {    // within explosion
                mayBeImpacted = true;
                break;
            }
        }

        return mayBeImpacted;
    }

    public void changeCourseToAvoid(float radius, PVector explosionPos) {
        // add velocity in opposite direction from explosion point
        PVector dirFromExp = new PVector(position.x - explosionPos.x, position.y - explosionPos.y);
        dirFromExp.normalize().mult(0.1);
        // often y value is far too high still
        dirFromExp.y *= 0.5;

        velocity.add(dirFromExp);
    }

    public PVector simulateUpdateSpeed(PVector velocityCopy) {
        // apply less gravity to meteors -> better for gameplay
        velocityCopy.y += gravityForce*GRAVITY_STRENGTH;

        // force acts parallel (and opposite) to the direction of travel
        // magnitude of force is also dependent on the current speed

        PVector drag = velocityCopy.copy().mult(-1 * dragForce * DRAG_STRENGTH);

        velocityCopy.y += drag.y;
        velocityCopy.x += drag.x;

        return velocityCopy;
    }

    public PVector simulateMove(PVector positionCopy, PVector velocityCopy) {
        updateTrail();

        positionCopy.x += velocityCopy.x;
        positionCopy.y += velocityCopy.y;

        return positionCopy;
    }

    public void changeCourseToAvoid() {

    }
}