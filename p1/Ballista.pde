final class Ballista {
  PVector position;
  int ammo;
  
  public Ballista(int x, int y, int ammo) {
    position = new PVector(x, y);
    this.ammo = ammo;
  }
  
  public void draw() {
    // rectangle for now
    fill(255) ;
    rect(position.x, position.y, 50, 50);
  }
  
  public float cursorDistance() {
    float xDist = mouseX-position.x;
    float yDist = mouseY-position.y;
    
    return sqrt(xDist * xDist + yDist * yDist);
  }
  
  public void decrementAmmo() {
    ammo--;
  }
}
