final class City extends Explodable {
  // constants
  final int CITY_SIZE = 50;

  boolean destroyed = false;
  PImage city;

  public City(int x, int y, PImage city) {
    super.position = new PVector(x,y);

    this.city = city;
  }

  public void draw() {
    // dont draw if destroyed
    if (destroyed) return;

    image(city, position.x, position.y, CITY_SIZE, CITY_SIZE);
  }

  public void destroy() {
    destroyed = true;
  }
}