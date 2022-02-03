final class Hud {
  
  PVector position;
  
  public Hud(int x, int y) {
    position = new PVector(x, y) ;
  }
  
  public void draw(int score, long strength, boolean mouseDown, boolean outOfAmmo) {
    textSize(36);
    String stringScore = "SCORE: " + Integer.toString(score);
    fill(204, 102, 0);
    text(stringScore, position.x, position.y);
    
    drawPowerBar(strength, mouseDown, outOfAmmo);
  }
  
  public void drawPowerBar(long strength, boolean mouseDown, boolean outOfAmmo) {
    // outer rectangle
    stroke(255);
    fill(0);
    rect(mouseX-30, mouseY-100, 10, 100);
    
    // inner rectangle
    if (outOfAmmo) {
      fill(255, 0, 0);
      rect(mouseX-30, mouseY-100, 10, 100);
    }
    if (!mouseDown) return;
    if (!outOfAmmo) {
      float height = strength * 0.1 > 100 ? 100: strength * 0.1;
      fill(204,102,0);
      rect(mouseX-30, mouseY-100, 10, height);
    } 
  }
}
