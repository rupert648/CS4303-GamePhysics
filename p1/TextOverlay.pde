final class TextOverlay {
  // constants
  final int TimeToDisplay = 3000; // 3 seconds

  boolean displaying = false;
  long startTime;
  String text;

  public boolean checkDisplay() {
    // prevent below check if not necessary
    if (!displaying) return false;

    long current = System.currentTimeMillis();
    if (current - startTime > TimeToDisplay) {
      displaying = false;
      return false;
    }

    return true;
  }

  public void setStartTime() {
    displaying = true;
    startTime = System.currentTimeMillis();
  }

  public void setText(String text) {
    this.text = text;
  }

  public void draw() {
    if (!displaying) return;

    rectMode(CENTER);
    fill(0);
    rect(width/2, height/2, 300, 80);

    fill(255, 215, 0);
    textAlign(CENTER, CENTER);
    textSize(40);
    text(text, width/2, height/2);
    textAlign(LEFT);

    rectMode(CORNER);
  }
}