class Explodable {
    final float EXPLOSION_RADIUS = 100;  // max size of the explosion
    final float EXPLOSION_EXPANSION_RATE = 4; // rate at which explosion expands

    PVector position;

    // explosion
    PVector explosionPosition;
    boolean exploded = false;
    boolean explosionAnimationCompleted = false;
    float explosionCurrentRadius = 0;

    public void drawExplosion() {
        // check if reached max size
        if (explosionCurrentRadius >= EXPLOSION_RADIUS) {
        explosionAnimationCompleted = true;
        return;
        }

        explosionCurrentRadius += EXPLOSION_EXPANSION_RATE;
        fill(255, 255, 0);
        circle(explosionPosition.x, explosionPosition.y, explosionCurrentRadius);

    }

    public void setExplosionLocation() {
        explosionPosition = position.copy();
    }
    
    // getters
    public int getX() {return (int) position.x ;}
    public int getY() {return (int) position.y ;}
    public boolean isExploded() {return exploded; }

    public void explode() {
        exploded = true;
        setExplosionLocation();
    }
}