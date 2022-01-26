final class Hud {
  
  PVector position;
  
  public Hud(int x, int y) {
    position = new PVector(x, y) ;
  }
  
  public void draw(int score, long strength, boolean mouseDown) {
    textSize(36);
    String stringScore = "SCORE: " + Integer.toString(score);
    fill(204, 102, 0);
    text(stringScore, position.x, position.y);
    
    drawPowerBar(strength, mouseDown);
  }
  
  public void drawPowerBar(long strength, boolean mouseDown) {
    // outer rectangle
    stroke(255);
    fill(0);
    rect(mouseX-30, mouseY-100, 10, 100);
    
    // inner rectangle
    if (!mouseDown) return;
    
    float height = strength * 0.1 > 100 ? 100: strength * 0.1;
    fill(204,102,0);
    rect(mouseX-30, mouseY-100, 10, height);
  }
}
