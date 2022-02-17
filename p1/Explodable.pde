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

    int checkObjectAndDestroyImpacted(ArrayList<? extends Explodable> explodableList, int skipIndex) {
        int numbBlownUp = 0;
        for (int i = 0; i < explodableList.size(); i++) {
            Explodable current = explodableList.get(i);

            boolean onScreen = current.position.x > 0 &&
                current.position.x < width &&
                current.position.y > 0;

            if (onScreen &&
                !current.isExploded() &&
                // have to hit within the inner half of the explosion
                current.inImpactArea(position, explosionCurrentRadius)) {
                    current.explode();
                    numbBlownUp++;
                    break;
                }
        }

        return numbBlownUp;
    }
    
    // getters
    public int getX() {return (int) position.x ;}
    public int getY() {return (int) position.y ;}
    public boolean isExploded() {return exploded; }

    public void explode() {
        exploded = true;
        setExplosionLocation();
    }

    boolean inImpactArea(PVector meteorPos, float explosionRadius) {
        // if in circle around missilePos of explosion Radius then destroy it
        float distance = meteorPos.dist(position);
        return distance < explosionRadius;
    }
}