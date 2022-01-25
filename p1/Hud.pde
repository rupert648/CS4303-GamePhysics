final class Hud {
  PVector position;
  
  public Hud(int x, int y) {
    position = new PVector(x, y) ;
  }
  
  public void draw(int score) {
    textSize(36);
    String stringScore = "SCORE: " + Integer.toString(score);
    fill(204, 102, 0);
    text(stringScore, position.x, position.y);
  }
}
