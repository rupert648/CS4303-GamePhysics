final class Floor {

  private int floorHeight;
  private float mu;  // coefficient of friction
  
  public Floor(int floorHeight, float mu) {
    this.floorHeight = floorHeight;
    this.mu = mu;
  }
  
  public void draw() {
    fill(255, 218, 185);
    
    rect(0, height - floorHeight, width, height);
    
    fill(255);
  }
  
  // getters
  public int getHeight() { return floorHeight; }
  public float getMu() { return mu; }
  
}
