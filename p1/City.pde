final class City {
  // constants
  final int CITY_SIZE = 50;

  PVector position;
  boolean destroyed = false;
  PImage city;

  public City(int x, int y) {
    position = new PVector(x,y);

    city = loadImage("../images/city.png");
  }

  public void draw() {
    // dont draw if destroyed
    if (destroyed) return;

    image(city, position.x, position.y, CITY_SIZE, CITY_SIZE);
  }

  public void destroy() {
    destroyed = true;
  }

  boolean inImpactArea(PVector meteorPos, float explosionRadius) {
        // if in circle around missilePos of explosion Radius then destroy it

        float distance = meteorPos.dist(position);
        return distance < explosionRadius;
    }
}