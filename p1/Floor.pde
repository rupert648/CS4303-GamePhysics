final class Floor {

  private int floorHeight;
  
  public Floor(int floorHeight) {
    this.floorHeight = floorHeight;
  }
  
  public void draw() {
    fill(255, 218, 185);
    
    rect(0, height - floorHeight, width, height);
    
    fill(255);
  }
  
  // getters
  public int getHeight() { return floorHeight; }
  
}
