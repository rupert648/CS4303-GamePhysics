final class Hud {
  
  PVector position;
  
  public Hud(int x, int y) {
    position = new PVector(x, y) ;
  }
  
  public void draw(int wave, int score, long strength, boolean mouseDown, boolean outOfAmmo) {
    // text look
    textSize(36);
    fill(204, 102, 0);

    String waveString = "Wave: " + Integer.toString(wave);
    text(waveString, position.x, position.y);
    String scoreString = "Score: " + Integer.toString(score);
    text(scoreString, position.x, position.y + 40);
    
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
