final class Ballista {
  // constants
  final int BALLISTA_SIZE = 50;

  // images
  PImage base;
  PImage main;

  PVector position;
  int ammo;
  
  public Ballista(int x, int y, int ammo) {
    position = new PVector(x, y);
    this.ammo = ammo;

    // load images (for animations etc)
    base = loadImage("../images/BallistaBase.png");
    main = loadImage("../images/BallistaMain.png");
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
