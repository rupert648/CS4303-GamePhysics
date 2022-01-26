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
    stroke(0);
    rect(position.x, position.y, 50, 50);
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
}
