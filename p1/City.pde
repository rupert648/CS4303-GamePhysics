final class City {
  // constants
  final int CITY_SIZE = 25;

  PVector position;
  boolean destroyed = false;

  public City(int x, int y) {
    position = new PVector(x,y);
  }

  public void draw() {
    // dont draw if destroyed
    if (destroyed) return;

    fill(255,215,0);
    stroke(0);
    rect(position.x, position.y, CITY_SIZE, CITY_SIZE);
  }

  public void destroy() {
    destroyed = true;
  }

  boolean inImpactArea(PVector meteorPos, float explosionRadius) {
        // if in circle around missilePos of explosion Radius then destroy it

        // TODO: change to use the centre of the city square, not the top left as it is currently
        float distance = meteorPos.dist(position);
        return distance < explosionRadius;
    }
}