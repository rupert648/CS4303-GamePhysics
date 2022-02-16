final class Ballista implements Collidable {
  // constants
  final int BALLISTA_SIZE = 30;

  // images
  PImage base;
  PImage main;

  PVector position;
  int ammo;
  boolean disabled;
  
  public Ballista(int x, int y, int ammo, PImage base, PImage main) {
    position = new PVector(x, y);
    this.ammo = ammo;
    disabled = false;


    this.base = base;
    this.main = main;
  }
  
  public void draw() {
    // rectangle for now
    fill(255) ;
    stroke(0);
    image(base, position.x, position.y, BALLISTA_SIZE, BALLISTA_SIZE);


    // calc angle between position and mouse
    float ang = atan2(position.x-mouseX, position.y-mouseY);

    // rotate image to face mouse
    pushMatrix();
    imageMode(CENTER);
    translate(position.x, position.y);
    rotate(-ang-HALF_PI);
    image(main, 0, 0, BALLISTA_SIZE, BALLISTA_SIZE);
    popMatrix();

    // draw ammo
    textSize(25);
    fill(255, 0, 0);
    text(Integer.toString(ammo), position.x, position.y+35);
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

  boolean inImpactArea(PVector meteorPos, float explosionRadius) {
    // if in circle around missilePos of explosion Radius then destroy it

    float distance = meteorPos.dist(position);
    return distance < explosionRadius;
  }

  void disable() {
    disabled = true;
  }

  void undisable() {
    disabled = false;
  }

  boolean isDisabled() {
    return disabled;
  }
}
