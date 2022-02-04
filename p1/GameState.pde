final class GameState {
  private int wave;
  private int difficulty;
  
  // keep in gamestate so we can in future adjust throughout game
  private float gravityForce;
  private float dragForce;  
  
  public GameState(int wave, float gravityForce, float dragForce) {
    this.wave = wave;
    this.gravityForce = gravityForce;
    this.dragForce = dragForce;
  }
  
  // getters
  public int getWave() { return wave; }
  public int getDifficulty() { return difficulty; }
  public float getGravity() { return gravityForce; }
  public float getDrag() { return dragForce; }

  // incrementers
  public void incWave() { wave++; }
}
