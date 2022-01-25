final class PlayerMissile {
  // The missile is represented by another handsome rectangle
  // the position field indicates the top-left of that rectangle.  
  PVector position ;
  int missileWidth, missileHeight ;
  int moveIncrement ;
  
  PlayerMissile(int x, int y, int missileWidth, int missileHeight, int moveIncrement) {
    position = new PVector(x, y) ;
    this.missileWidth = missileWidth ;
    this.missileHeight = missileHeight ;
    this.moveIncrement = moveIncrement ;
  }
  
  // reuse this object rather than go through object creation
  void reset(int x, int y) {
    position.x = x ;
    position.y = y ;
  }
  
  // getters
  int getX() {return (int)position.x ;}
  int getY() {return (int)position.y ;}
  // The missile is displayed as a rectangle
  void draw() {
    fill(200) ;
    rect(position.x, position.y, missileWidth, missileHeight) ;
  }
  
  // handle movement. Returns true if not out of play area
  // What about collision detection with enemies?
  boolean move() {
    return (position.y -= moveIncrement) >= 0 ;
  }  
}
