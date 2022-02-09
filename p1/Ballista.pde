final class Ballista {
  // constants
  final int BALLISTA_SIZE = 50;

  PVector position;
  int ammo;
  
  public Ballista(int x, int y, int ammo) {
    position = new PVector(x, y);
    this.ammo = ammo;
  }
  
  public void draw() {
    // rectangle for now
    fill(255) ;
    stroke(0);
    rect(position.x, position.y, BALLISTA_SIZE, BALLISTA_SIZE);
    fill(0);
    text(Integer.toString(ammo), position.x+8, position.y+35);
  }
  
  public float cursorDistance() {
    float xDist = mouseX-position.x;
    float yDist = mouseY-position.y;
    
    return sqrt(xDist * xDist + yDist * yDist);
  }
  
  public boolean decrementAmmo() {
    if (ammo == 0) return false;
    
    ammo--;
    return true;
  }

  public boolean isOutOfAmmo() {
    return ammo <= 0;
  }

  public void setAmmo(int amount) {
    ammo = amount;
  }
}
